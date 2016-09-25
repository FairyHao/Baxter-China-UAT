public with sharing class AceSessionPageController
{
	public Coaching_Session__c session{get;set;}
	public User u{set;get;} //辅导人
	private User coachee;//被辅导人
	public List<SelectOption> coachingRelList{set;get;}//被辅导人
	public List<Coaching_Session__c> coachingRelatedList{set;get;} //辅导课程的相关列表
	public List<Coaching_Session__c> coachingRelatedSRList{set;get;} //辅导课程的相关列表
	public List<Event> coachingRelatedEventList{get;set;}	// SR协防列表
	public String tip1{get;set;}
	public String tip2{get;set;}
	public String tip3{get;set;}
	public Boolean isSR{get;set;}	// 被辅导人是否是SR
	public String userStr{set;get;}	// 选择的被辅导人
	public Plan__c plan{get;set;}
	public Integer count{get;set;}
	public List<SelectOption> optionList{get;set;}
	public Boolean isCreate{get;set;}


	public AceSessionPageController(ApexPages.StandardController con)
	{
		
		optionList = new List<SelectOption>();
		coachingRelatedList = new List<Coaching_Session__c>();
		coachingRelatedSRList = new List<Coaching_Session__c>();
		coachingRelatedEventList = new List<Event>();
		coachingRelList = new List<SelectOption>();
		tip1 = '本次聚焦的辅导目标，应用GROW模型商讨并确认具体辅导目标';
		tip2 = '辅导后回顾及反馈，回顾行动及目标达成情况、给予反馈，并确定下一步行动计划';
		tip3 = '针对确认的辅导目标，准备行动方案、步骤、所需资源、有何困难、需要什么帮助等';

		String cid = con.getId();
		List<Coaching_Session__c> sList = [select id,LoggedIn_User__c,Rep_Id__c,Rep_Id__r.Alias,VisitAfter__c,VisitBefore__c,startDate__c,FocusText__c,OwnerId,isCompleted__c,VisitPlan__c from Coaching_Session__c Where id=:cid];
		if (cid !=NULL && sList.size() != 0) {
			session = sList[0];
			System.debug('sessss==>'+session);
			isCreate = false;
			u = [select id,Name,Alias,Ace_Role__c,Profile.Name,isAceAdmin__c from User where id =:session.LoggedIn_User__c];
			userStr = session.Rep_Id__c;
			// if (u.Ace_Role__c == 'SM' ) {
			//     isSM = true;
			// } else if (u.Ace_Role__c == 'SEM' || u.isAceAdmin__c == true) {
			//     isSM = false;
			// }
		} else {
			isCreate = true;

			u = [select id,Name,Alias,Ace_Role__c,Profile.Name,isAceAdmin__c from User where id =:UserInfo.getUserId()];
			if (u.Ace_Role__c != 'SEM' && u.Ace_Role__c != 'SM' && u.Profile.Name != '系统管理员' && !u.isAceAdmin__c) {
			    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '您没有权限创建辅导会谈!');
			    ApexPages.addMessage(msg);
			    return;
			}

			// if (u.Ace_Role__c == 'SM') {
			//     // tip1 = '确立目标-确定今天的重点辅导目标，应用GROW模型商讨今天的拜访行动及步骤，需要准备的资源，有无疑问';
			//     // tip2 = '回顾整个拜访与目标达成的情况，给予反馈，并确定下一步行动计划';
			//     isSM = true;
			// } else if (u.Ace_Role__c == 'SEM' || u.isAceAdmin__c){
			// 	// tip1 = '1.确立目标-回顾上一轮辅导后跟进计划的执行情况，确定今天要练习的重点技能，即辅导目标  2.为今天的重点技能练习作准备，促进SM今天辅导目标的达成';
			//  	// tip2 = '一起回顾整个协访辅导，辅导目标达成的情况，给予反馈，并确定下一步行动计划';
			//     isSM = false;
			// }
			session = new Coaching_Session__c();
			session.isCompleted__c = false;
		}
		
		if (isCreate) {
			List<User> uList = getCoachingRel(u.Id);
			
			for (User u : uList) {
				coachingRelList.add(new SelectOption(u.Id,u.Alias));
			}
			coachingRelList.sort();
		} else{
			getPlanByUser();
		}
	}

	// 找被辅导人
	private List<User> getCoachingRel(String uid)
	{
		if (u.Ace_Role__c == 'SEM' || u.Ace_Role__c == 'SM' || u.isAceAdmin__c) {
			String sql = 'select id,Name,Alias from User where (ManagerId =\''+u.Id+'\' or Coaching_Manager__c =\''+u.Id+'\')';
			if(u.Ace_Role__c == 'SEM')
			{
				sql+= ' '+'and (Ace_Role__c = \'SEM\' or Ace_Role__c = \'SM\' or Ace_Role__c = \'SR\')';  // dean 2016-06-12
			}
			if(u.Ace_Role__c == 'SM')
			{
				sql+= ' '+'and Ace_Role__c = \'SR\' ';  
			}
			if(u.isAceAdmin__c)
			{
				sql = 'select id,name,Alias from User where Ace_Role__c = \'SM\'';  
			}
			System.debug('sql==>'+sql);
			List<User> coachingUserList = Database.query(sql);
			return coachingUserList;
		}
		return new List<User>();
		
	}


	// 根据 辅导人和被辅导人加上周期找plan
	public void getPlanByUser(){
		if (session.startDate__c == NULL) {
		    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请选择辅导日期!');
		    ApexPages.addMessage(msg);
		    userStr = 'none';
		    return;
		}
		if (userStr == 'none' || userStr == NULL) {
		    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请选择一个被辅导人!');
		    ApexPages.addMessage(msg);
		    return;
		}
		String pdate = getcurrPeriod(session.startDate__c);
		List<Plan__c> pList = [SELECT Id, OwnerId,Name, CreatedDate, Created_Date__c,
								Focus_Area_Note__c, Identifier__c, Plan_Session_Id__c, Rep_Id__c, 
								Session_Allocated_Goal_Update__c, Session_Status__c, User_Id__c, 
								isArchive__c, IPad_Key__c, Period_1__c, Period_value__c, 
								Rep_First_Name__c, Rep_Last_Name__c, 
								Rep_SM_Country__c, Role_Id__c, User_Role__c FROM Plan__c where User_Id__c =:u.Id and Rep_Id__c =:userStr and Period_1__c=:pdate and status__c = '通过'];
		if (pList.size() == 0) {
		    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '该被辅导人没有辅导计划不能创建辅导会谈!');
		    ApexPages.addMessage(msg);
		    return;
		}

		plan = pList[0];
		this.count = getSessionCountByUser();
		getPlanFocus();

		coachee = [SELECT id,Name,Alias,Ace_Role__c,Profile.Name,isAceAdmin__c FROM User WHERE id =:userStr];
		if (coachee.Ace_Role__c == 'SM' || coachee.Ace_Role__c == 'SEM' ) {
			getSessionByUser();
		    getAllSessionList();
		    isSR = false;
		} else if(coachee.Ace_Role__c == 'SR'){
			getSessionByUser();
			getAllEvent();
			isSR = true;
		}else{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '被辅导人的AceRole不正确');
		    ApexPages.addMessage(msg);
		    return;
		}
	}

	// 查询当前创建课程时间前1月的
	public void getSessionByUser(){
		coachingRelatedList.clear();
		Date sDate =  session.startDate__c.addMonths(-1);
		coachingRelatedList = [select id,name,startDate__c,VisitAfter__c,VisitBefore__c,FocusText__c,Rep_Id__r.Alias,VisitPlan__c FROM Coaching_Session__c WHERE Rep_Id__c =: userStr and startDate__c >=:sDate and startDate__c <=:session.startDate__c AND LoggedIn_User__c =:u.Id];
	}

	// 找出sm 对sr的辅导
	public void getAllSessionList(){
		coachingRelatedSRList.clear();
		Date sDate = session.startDate__c.addMonths(-1);
		coachingRelatedSRList = [select id,name,startDate__c,VisitAfter__c,VisitBefore__c,FocusText__c,Rep_Id__r.Alias,VisitPlan__c FROM Coaching_Session__c WHERE   startDate__c >=:sDate and startDate__c <=:session.startDate__c AND LoggedIn_User__c =:userStr order by Rep_Id__c];
	}

	// sr 参与的协防
	public void getAllEvent(){
		Date sDate = session.startDate__c;
		System.debug('=='+sDate.year()+'=='+sDate.month()+'=='+sDate.day());
        Set<ID> set_AccEvent = new Set<ID>();
        for (Event e :[select Id,Subject,StartDateTime,EndDateTime,GAExecuteResult__c,Owner.Name,GAPlan__c,Done__c,Comment1__c from Event where RecordType.DeveloperName = 'V2_Event' And Done__c = true And OwnerId =:userStr And CALENDAR_YEAR(StartDateTime) =: sDate.year() And DAY_IN_MONTH(StartDateTime) = :sDate.day() and CALENDAR_MONTH(startDateTime) =:sdate.month()] ) {
        	set_AccEvent.add(e.Id);
        }
        Set<String> ids = new Set<String>();
        for(EventRelation er : [Select id,Status,EventId From EventRelation Where EventId IN:set_AccEvent]){
            if(er.Status=='已接受' || er.Status=='Accepted'){
                ids.add(er.EventId);
            }
        }
        for(AssVisitComments__c AssVisitComm : [Select Id,EventId__c,IsAssVisit__c From AssVisitComments__c Where EventId__c IN:set_AccEvent And ReUser__c =: userStr]){
            ids.add(AssVisitComm.EventId__c);
        }
        coachingRelatedEventList = [select Id,Subject,StartDateTime,EndDateTime,GAExecuteResult__c,Owner.Name,GAPlan__c,Done__c,Comment1__c from Event WHERE id IN:ids];
	}

	// 
	public Integer getSessionCountByUser(){
		List<Plan__c> tList = [select Id from Plan__c where Rep_Id__c = :userStr and CreatedDate <=: plan.CreatedDate];
		return tList.size();
	}

	public void getPlanFocus(){
		optionList.clear();
		for (Plan_Detail__c obj : [select FocusAre__c from Plan_Detail__c where Plan__c =:plan.Id and isFocusArea_Selected__c = TRUE order by FocusAre__c]) {
			if (obj.FocusAre__c != NULL) {
				optionList.add(new SelectOption(obj.FocusAre__c,obj.FocusAre__c));
			}
		}
	}

	public String  getcurrPeriod(Datetime d)
    {
        String bodyOne;
        String bodyTwo;
        String period;

        integer i = d.month();
        integer j = d.year();
        if(i >= 2 && i <= 7 ){ bodyOne = 'Feb-Jul' ;}
        if((i >= 8 && i <= 12)){ bodyOne = 'Aug-Jan';j++;}
        if(i == 1){bodyOne = 'Aug-Jan';}  


        bodyTwo = String.valueOf( j );    

        bodyTwo = bodyTwo.substring(2, 4);

        period = bodyOne + ' ' + bodyTwo;
        return period;
    }

	public PageReference doSave(){
		if (session.startDate__c == NULL) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'开始日期不能为空!');
		    ApexPages.addMessage(msg);
		    return null;
		}
		session.LoggedIn_User__c = u.Id;
		if(userStr == null && userStr == '' )
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'被辅导人不能为空!');
		    ApexPages.addMessage(msg);
		    return null;
		}

		session.Rep_Id__c = userStr;
		insert session;
		Coaching_Session__Share share = new Coaching_Session__Share();
		share.ParentId = session.Id;
		share.UserOrGroupId = userStr;
		share.AccessLevel = 'read';
		insert share;

		User coachee =[select id,ManagerId from user where id =:userStr];
		if(coachee.ManagerId == null)
        {
          return null; 
        }
		User manager = [select id from User where id =:coachee.ManagerId];
		if(manager.id != u.id)
		{
			Coaching_Session__Share share2 = new Coaching_Session__Share();
			share2.ParentId = session.Id;
			share2.UserOrGroupId = manager.Id;
			share2.AccessLevel = 'read';
			insert share2;
		}
		

		return new PageReference('/'+session.Id);
	}

	public PageReference doCancel(){
		String[] types = new String[]{'Coaching_Session__c'};
		String str = '';
		Schema.DescribeSobjectResult[] results = schema.describeSObjects(types);
    	for(Schema.DescribeSobjectResult res : results)
    	{
    		 str = res.getKeyPrefix();
    	}
		PageReference pageRef = new PageReference('/'+str);
		return pageRef;
	}

}
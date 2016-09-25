public with sharing class AceSessionPageUpdateController {
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
	public Boolean isSR{get;set;}	// 是否是SM辅导还是SR辅导
	public String userStr{set;get;}	// 选择的被辅导人
	public Plan__c plan{get;set;}
	public Integer count{get;set;}
	public List<SelectOption> optionList{get;set;}
	public Boolean isCreate{get;set;}
	public Boolean IsAllowEditOwner{set;get;}
	public Boolean IsCompeted{set;get;}
	public Boolean oldCompleted{set;get;}//是否完成旧值

	public AceSessionPageUpdateController(ApexPages.StandardController con) {
		isCreate = false;
		tip1 = '本次聚焦的辅导目标，应用GROW模型商讨并确认具体辅导目标';
		tip2 = '辅导后回顾及反馈，回顾行动及目标达成情况、给予反馈，并确定下一步行动计划';
		tip3 = '针对确认的辅导目标，准备行动方案、步骤、所需资源、有何困难、需要什么帮助等';

		String cid = con.getId();
		List<Coaching_Session__c> sList = [select id,LoggedIn_User__c,Rep_Id__c,Rep_Id__r.Alias,VisitAfter__c,VisitBefore__c,startDate__c,FocusText__c,OwnerId,isCompleted__c,VisitPlan__c from Coaching_Session__c Where id=:cid];
		session = sList[0];
		userStr = session.Rep_Id__c;
		System.debug('log:==>'+session.LoggedIn_User__c);
		u = [select id,Name,Alias,Ace_Role__c,Profile.Name,isAceAdmin__c from User where IsActive =true and id =:session.LoggedIn_User__c];
		coachee = [select id,Name,Alias,Ace_Role__c,Profile.Name,isAceAdmin__c from User where IsActive =true and id =:userStr];
		optionList = new List<SelectOption>();
		coachingRelatedList = new List<Coaching_Session__c>();
		coachingRelatedSRList = new List<Coaching_Session__c>();
		coachingRelatedEventList = new List<Event>();
		coachingRelList = new List<SelectOption>();
		coachingRelList.add(new SelectOption(coachee.Id,coachee.Alias));
		//List<User> uList = getCoachingRel(u.Id);
		// coachingRelList = new List<SelectOption>();
		// for (User u : uList) {
		// 	coachingRelList.add(new SelectOption(u.Id,u.Alias));
		// }
		// coachingRelList.sort();
		getPlanByUser();
		IsAllowEditOwner();
		oldCompleted = session.isCompleted__c;

	}

	// 找被辅导人
	// private List<User> getCoachingRel(String uid)
	// {
	// 	String sql = 'select id,Name,Alias from User where (ManagerId =\''+u.Id+'\' or Coaching_Manager__c =\''+u.Id+'\')';
	// 	if(u.Ace_Role__c == 'SEM')
	// 	{
	// 		sql+= ' '+'and Ace_Role__c = \'SM\' ';  
	// 	}
	// 	if(u.Ace_Role__c == 'SM')
	// 	{
	// 		sql+= ' '+'and Ace_Role__c = \'SR\' ';  
	// 	}
	// 	if(u.isAceAdmin__c || u.Profile.Name == '系统管理员')
	// 	{
	// 		sql = 'select id,name,Alias from User where Ace_Role__c = \'SM\'';  
	// 	}
	// 	System.debug('sql==>'+sql);
	// 	List<User> coachingUserList = Database.query(sql);
	// 	return coachingUserList;
	// }

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
								Rep_SM_Country__c, Role_Id__c, User_Role__c FROM Plan__c where User_Id__c =:u.Id and Rep_Id__c =:userStr and Period_1__c=:pdate];
		if (pList.size() == 0) {
		    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '该被辅导人没有辅导计划不能创建辅导会谈!');
		    ApexPages.addMessage(msg);
		    return;
		}

		plan = pList[0];
		this.count = getSessionCountByUser();
		getPlanFocus();
		
		if (coachee.Ace_Role__c == 'SEM' || coachee.Ace_Role__c == 'SM') {
			getSessionByUser();
		    getAllEvent();
		    isSR = false;
		} else if(coachee.Ace_Role__c == 'SR'){
			getSessionByUser();
			getAllSessionList();
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
                ids.add(er.EventId) ;
            }
        }
        for(AssVisitComments__c AssVisitComm : [Select Id,EventId__c,IsAssVisit__c From AssVisitComments__c Where EventId__c IN:set_AccEvent And ReUser__c =: userStr]){
            ids.add(AssVisitComm.EventId__c);
        }
        coachingRelatedEventList = [select Id,Subject,StartDateTime,EndDateTime,GAExecuteResult__c,Owner.Name,GAPlan__c,Done__c,Comment1__c
         from Event WHERE id IN:ids];
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

	public void IsAllowEditOwner()
	{
		User login = [select id,isAceAdmin__c,Profile.Name from User where id=:UserInfo.getUserId()];
		System.debug('=========================>>>>'+u.Profile.Name);
		if(login.isAceAdmin__c || login.Profile.Name.contains('系统管理员') ||login.Profile.Name.contains('adminstrator'))
		{
			IsAllowEditOwner = true;
		}
		else{
			IsAllowEditOwner = false;
		}
	}

	public PageReference doSave(){
		if (session.startDate__c == NULL) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'开始日期不能为空!');
		    ApexPages.addMessage(msg);
		    return null;
		}
		
		update session;
		sendEmialAfterCompleted();
		return new PageReference('/'+session.Id);
	}

	public void sendEmialAfterCompleted()
	{
		if(session.isCompleted__c && oldCompleted != session.isCompleted__c )
		{
			string baseUrl = string.valueOf( System.URL.getSalesforceBaseUrl() );
        	baseUrl = baseUrl.substring( baseUrl.indexOf( '=' ) + 1, baseUrl.length() - 1 );
        	baseUrl = baseUrl + '/' + session.Id;
	
			User u =[select id,Email from User where id=:userStr];
			String body = '';
			 
	    	body +=	'您好！<br>';
			body += session.startDate__c.format() + '的辅导会谈报告已生成。<br>';
			body += '请点击以下链接，进入SEP系统查看辅导报告并跟进下一步行动计划。<br>';
			body += '<a href="'+baseUrl+'">'+ baseUrl+ '</a>' + '<br><br>';
	
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String [] {u.Email};
			mail.setToAddresses(toAddresses); //邮件地址
			mail.setHtmlBody( body ); //邮件内容
			mail.setSubject('CoachingSessionRemind'); //邮件主题
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
}
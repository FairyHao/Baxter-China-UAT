/*
Author:Dean
Date:2015-10-22
Function:WebAce 新建辅导计划
Change:Competency和Question根据被辅导人显示，SEM可以对SR辅导 2016-06-21
 */

public class acePageController
{
    public List<SelectOption> coachRelList{set;get;}
    public List<Question__c>  QuestionList{set;get;}
    public String selectedUser{set;get;}
    public List<compentencyAndQues>  compentencyAndQuesList{set;get;}//重点领域列表
    public List<selectQuestion>  selectedQuestionList{set;get;}//选中的重点领域
    public String coachTimes{set;get;}//辅导次数
    public String FocusAreaNote{set;get;} //重点领域说明
    public List<selectOption> options{set;get;} //能力模型Option
    public List<selectOption> timeOptions{set;get;}// 次数Option
    public User coachor{set;get;}
    public User coachee{set;get;}
    public Plan__c plan{set;get;}
    public String alertMsg{set;get;}
    public String checkInfoMsg{set;get;}
    public String peroidNow{set;get;}//计划所在周期
    private Map<String,List<Question__c>> queMap;
    private Map<String,List<planDetail>> detailMap;
    private Map<string,Competency__c> comMap;
    private Map<String,String> lastAnswerMap;
    private List<String> emailList = new List<String>();
    

    //初始化
    public acePageController()
    {
        coachor =[select id,Ace_Role__c,Name,isAceAdmin__c,Alias from User where id =: userinfo.getUserId()];
        getSelectOption();
        getCoachTimesOption();
        getCoachRelList();
        peroidNow = getcurrPeriod(system.now());  
    }

    //用户只可选择对应的被辅导人
    public void getCoachRelList()
    {
        //根据当前用户选择对应的被辅导人
        //被辅导人选择范围：
        // i.  用户上“经理”字段为当前用户的
        // ii. 用户上“Coaching Manager”字段为当前用户的
        
        List<User> userList;
        String sql='';

        if(coachor.Ace_Role__c == 'SEM' || coachor.Ace_Role__c == 'SM'){
            sql = 'select id,Name,Alias,Ace_Role__c from user where IsActive = true and (ManagerId =\'' + coachor.Id + '\'or Coaching_Manager__c =\'' + coachor.Id + '\')';
            if(coachor.Ace_Role__c == 'SEM'){
                sql += 'and (Ace_Role__c = \'SEM\' or Ace_Role__c = \'SM\' or Ace_Role__c = \'SR\')';// dean 2016-06-06
            }
            if(coachor.Ace_Role__c == 'SM'){
                sql += 'and Ace_Role__c = \'SR\' ';
            }
        }
        // iii. 如果是ACE Admin需要看到全部SM
        if(coachor.isAceAdmin__c == true){
            sql = 'select id,Name,Alias,Ace_Role__c from user where IsActive = true and Ace_Role__c =\'SM\'';
        }
        if(sql != ''){
          userList = Database.query(sql);
        }
        else{
            userList = new List<User>();
        }
        
        //被辅导人列表
        coachRelList = new List<SelectOption>();
        coachRelList.add(new SelectOption('none','--None--'));
        for(User u:userList){
            coachRelList.add(new SelectOption(u.Id,u.Alias));
        }
        if(coachRelList.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 
                '没有可选择的被辅导人');
            ApexPages.addMessage(myMsg);
        }
        
    }

    //将compentency和Question组合
    public void  getcompentencyAndQuesList()
    {
        compentencyAndQuesList =  new List<compentencyAndQues>();
        List<User> templist = [SELECT id,Ace_Role__c,Name,isAceAdmin__c,Alias 
                                FROM User  
                                WHERE IsActive = true and id =: selectedUser];
        if(templist.size() == 0){
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 
                '没有选择的被辅导人');
            ApexPages.addMessage(myMsg); 
        }else{
            coachee = templist[0];
        }
        //找到当前用户对应的Compentency
        List<Competency__c> compList = new List<Competency__c>();
        compList = [SELECT id,Name,Competency_Description__c 
                    FROM Competency__c 
                    WHERE OrgsRole_Mapper_Eqv__c =:coachee.Ace_Role__c ];
        if(coachor.isAceAdmin__c == true){
            compList.clear();
            compList = [SELECT id,Name,Competency_Description__c 
                        FROM Competency__c 
                        WHERE OrgsRole_Mapper_Eqv__c ='SM'];
        }
        
        if(compList.size() == 0){
            compentencyAndQuesList.clear();
            return;
        }

        comMap = new Map<string,Competency__c>();
        for(Competency__c c:compList){
            comMap.put(c.Id, c);
        }
        

        //queMap将Question和Competency关联
        List<Question__c> qList = [SELECT id,Details__c,Name,Competency_Id__c 
                                   FROM Question__c 
                                   WHERE Competency_Id__c IN:comMap.keySet()];
        queMap = new Map<String,List<Question__c>>();
        
        for(Question__c q:qList){
            
            if(!queMap.containsKey(q.Competency_Id__c)){
                queMap.put(q.Competency_Id__c, new List<Question__c>());
            }
            List<Question__c> temList = queMap.get(q.Competency_Id__c);
            temList.add(q);
            queMap.put(q.Competency_Id__c, temList);
        }

        //将Question的数据转入PlanDeatil
        detailMap = new Map<String,List<planDetail>>();
        for(String id:queMap.keySet()){
            List<planDetail> temPlanDetailList =  new List<planDetail>();
            List<Question__c> temList = queMap.get(id);
            for(Question__c que:temList){
                planDetail pd = new planDetail();
                pd.question = new Question__c();
                pd.question = que;
                pd.isFocusArea =false;              
                temPlanDetailList.add(pd);
            }
                detailMap.put(id,temPlanDetailList);
        }



        //打包成一个内部类
        for(String id:comMap.keySet()){
            compentencyAndQues obj = new compentencyAndQues();
            obj.com = comMap.get(id);
            obj.queList = queMap.get(id);
            obj.planDetailList = detailMap.get(id);
            compentencyAndQuesList.add(obj); 
        }

        getLastPeriodAnswer();
        
    }

    //获取上个周期对应的Question的阶段
    public  void getLastPeriodAnswer()
    {
        if(selectedUser == '' || selectedUser == null || selectedUser == 'none'){
            refreshcompentencyAndQuesList();
            return;
        }
        
        List<Plan__c> pList = [SELECT id 
                               FROM Plan__c 
                               WHERE Rep_Id__r.Id =:selectedUser and status__c ='通过' order by CreatedDate desc];
        if(pList.size() == 0){
            refreshcompentencyAndQuesList();
            return; 
        }
        Plan__c p = pList[0];
        List<Plan_Detail__c> detailList = [select id,Question_Id__r.Id,Answer__c from Plan_Detail__c 
                                                                                  where Plan__c =:p.Id];
        if(detailList.size() == 0){
            refreshcompentencyAndQuesList();
            return;
        }

        lastAnswerMap = new Map<String,String>();
        for(Plan_Detail__c pd:detailList){
            lastAnswerMap.put(pd.Question_Id__r.Id,pd.Answer__c);
        }

        
        for(String id:comMap.keySet()){
            List<PlanDetail> temList = detailMap.get(id);

            for(planDetail obj:temList){
                obj.lastPeriodAnswer = lastAnswerMap.get(obj.question.Id); 
            }    
            detailMap.put(id,temList);
        }
        
        compentencyAndQuesList = new List<compentencyAndQues>();
        for(String id:comMap.keySet()){
            compentencyAndQues obj = new compentencyAndQues();
            obj.com = comMap.get(id);
            obj.queList = queMap.get(id);
            obj.planDetailList = detailMap.get(id);
            compentencyAndQuesList.add(obj); 
        }
        
    }


    //清空上一周期阶段的记录
    public void refreshcompentencyAndQuesList()
    {
        for(String id:comMap.keySet()){
            List<PlanDetail> temList = detailMap.get(id);
            for(planDetail obj:temList){
                obj.lastPeriodAnswer = '';      
            }
            detailMap.put(id,temList);
        }
        
        compentencyAndQuesList = new List<compentencyAndQues>();
        for(String id:comMap.keySet()){
            compentencyAndQues obj = new compentencyAndQues();
            obj.com = comMap.get(id);           
            obj.queList = queMap.get(id);     
            obj.planDetailList = detailMap.get(id);
            compentencyAndQuesList.add(obj); 
        }

    }


    //获取关键领域
    public void getSelectQuestion()
    {
        alertMsg ='';
        selectedQuestionList = new List<selectQuestion>();
        Integer i = 1;
        if(compentencyAndQuesList == null){
            alertMsg = '请选择重点领域后再点击确认';
            return;
        }
        for(compentencyAndQues caq:compentencyAndQuesList)
        {
            for(planDetail obj:caq.planDetailList){
                if(obj.isFocusArea == true ){
                   selectQuestion temp = new selectQuestion();
                   temp.question = obj.question;
                   selectedQuestionList.add(temp);
                   i++;
                }
            }
        }

        //最多可选四个重点领域
        if(i > 5 || i < 2){
            selectedQuestionList.clear();
            alertMsg = '至少选一个，最多选四个重点领域';
        }
        
    }

    public PageReference save()
    {
        if(!checkInfo()){
            return null;
        }
        
        //插入Plan记录
        Plan__c p = new  Plan__c();
        List<User> uList = [select id,Name,Ace_Role__c from User where Id =:selectedUser];
        User coachee = uList[0];
        p.Rep_Id__c = coachee.id;
        p.User_Id__c = userinfo.getUserId();
        p.Session_Allocated_Goal_Update__c = integer.valueOf(coachTimes);
        p.Focus_Area_Note__c = FocusAreaNote; //重点领域说明
        p.status__c = '通过'; 
        insert p;
        

        //插入PlanDetail记录
        List<Plan_Detail__c> tempPlanDetailListtailList = new List<Plan_Detail__c>();
        for(String id:comMap.keySet()){
            List<planDetail> tempList = detailMap.get(id);
            for(planDetail obj:tempList){
                Plan_Detail__c pd =  new Plan_Detail__c();
                pd.Question_Id__c = obj.question.Id;
                pd.Competency_Id__c =id;
                pd.Answer__c = obj.answer;
                pd.isFocusArea_Selected__c = obj.isFocusArea;
                pd.Plan__c = p.id;
                tempPlanDetailListtailList.add(pd);
            }
        }
        insert tempPlanDetailListtailList;
        sendEmail(p);//计划保存后发送邮件给辅导人和被辅导人
        sharePlan(p);//计划共享给辅导人和被辅导人
        PageReference pageRef = new PageReference('/'+p.Id);
        return pageRef;
    }

    //清空进度及问题列表
    public void clearList()
    {
        if(compentencyAndQuesList == null){
            return;
        }
        for(compentencyAndQues caq:compentencyAndQuesList){
            for(planDetail obj:caq.planDetailList){
                obj.isFocusArea = false;
                obj.answer = null;
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

    public PageReference back()
    {
        String[] types = new String[]{'Plan__c'};
        Schema.DescribeSobjectResult[] results = schema.describeSObjects(types);
        String  str ='';
        for(Schema.DescribeSobjectResult res : results){
             str= res.getKeyPrefix();
        }
        PageReference pageRef = new PageReference('/'+str);
        return pageRef;
    }

    //获取阶段的选项值
    public void getSelectOption()
    {
        options = new List<SelectOption>();
        options.add(new SelectOption('收效甚微','收效甚微'));
        options.add(new SelectOption('有待提高','有待提高'));
        options.add(new SelectOption('卓越有效','卓越有效'));
        options.add(new SelectOption('堪称模范','堪称模范'));
        options.add(new SelectOption('不适用','不适用'));
    }

    //获取辅导次数列表
    public void getCoachTimesOption()
    {
        timeOptions = new List<SelectOption>();
        for(integer i = 1 ; i < 21 ;i++ ){
            timeOptions.add(new SelectOption(string.valueOf(i),string.valueOf(i)));
        }
    }

    //校验数据
    public boolean checkInfo()
    {
        checkInfoMsg = '';
        //被辅导人的值必填
        if(selectedUser == 'none' || selectedUser == '' || selectedUser == null){
            checkInfoMsg = '请选择被辅导人';
            return false;
        }

        //每个Question的阶段必填
        integer focusArea = 0;
        for(String id:comMap.keySet()){           
            for(planDetail pd: detailMap.get(id)){
                //累计关键领域的数量
                if(pd.isFocusArea == true){
                    focusArea++;
                }
                if(pd.answer == null || pd.answer == ''){
                    checkInfoMsg += '请填写每个技能的阶段的值';
                    return false;
                }
            }
        }

         // 最多选四个最少选一个重点领域
        if(focusArea < 1 || focusArea > 4){
            checkInfoMsg += '重点领域至少选一个最多选四个';
            return false;
        }

        if(FocusAreaNote == null || FocusAreaNote == ''){
            checkInfoMsg += '请填写重点领域说明';
            return false;
        }

        if(integer.valueOf(coachTimes) == null || integer.valueOf(coachTimes) == 0){
            checkInfoMsg += '请填写次数辅导';
            return false;
        }

        //验证该周期内是否有辅导计划，若有则不允许新建计划
        String str = getcurrPeriod(System.now());
        List<User> uList = [select id,Name,Ace_Role__c from User where Id =:selectedUser];
        User u = uList[0];
        List<Plan__c> planList = [SELECT id,Period_1__c,User_Id__c,Rep_Id__c 
                                  FROM Plan__c 
                                  WHERE User_Id__c =:UserInfo.getUserId() and Rep_Id__c =:u.Id order by CreatedDate desc];
        if(planList.size() == 0){
            return true;
        }
        else{
            Plan__c p = planList[0];
            if(p.Period_1__c == str){
                checkInfoMsg += '该周期内已有辅导计划，不允许新建计划';
                return false;
            }
        }
        return true;
    }

    //发送邮件
    public void sendEmail(Plan__c plan)
    {
        string baseUrl = string.valueOf( System.URL.getSalesforceBaseUrl() );
        baseUrl = baseUrl.substring( baseUrl.indexOf( '=' ) + 1, baseUrl.length() - 1 );
        baseUrl = baseUrl + '/' + plan.Id;

        //发送给辅导人
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        User coachee = [select id,Name,Email,Ace_Role__c from User where Id =:selectedUser Limit 1];
        User coachor = [select id,Name,Email,Ace_Role__c from User where Id =:UserInfo.getUserId() Limit 1];
        String body ='';
               body += '您好：<br>';
               body += '您制定的辅导计划已完成审批，请您及时安排时间实施辅导。<br>';
               body += '查看请点击:';
               body += '<a href="'+baseUrl+'">'+ baseUrl+ '</a>' + '<br><br>';
               body += '祝您工作愉快! <br>';
               body += '__________________________________________________<br>';
               body += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。 <br>';
        String[] toAddresses = new String [] {coachor.Email};
        mail.setToAddresses(toAddresses); //邮件地址
        mail.setHtmlBody( body ); //邮件内容
        mail.setSubject('CoachingPlan Remind'); //邮件主题
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //发送给被辅导人
        Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
        String body2 = '';
               body2 += '您好：<br>';
               body2 += '您好，您与经理共同制定的辅导计划已完成审批，请您及时安排时间实施辅导。<br>';
               body2 += '查看请点击:';
               body2 += '<a href="'+baseUrl+'">'+ baseUrl+ '</a>' + '<br><br>';
               body2 += '祝您工作愉快! <br>';
               body2 += '__________________________________________________<br>';
               body2 += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。 <br>';
        String[] toAddresses2 = new String [] {coachee.Email};
        mail2.setToAddresses(toAddresses2); //邮件地址
        mail2.setHtmlBody( body2 ); //邮件内容
        mail2.setSubject('CoachingPlan Remind'); //邮件主题
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail2 });

    }

    public void sharePlan(Plan__c p)
    {
        //共享给被辅导人
        User coachee = [select id,Name,Email,Ace_Role__c,ManagerId from User where IsActive =true and Id =:selectedUser Limit 1];
        Plan__Share share = new Plan__Share();
        share.ParentId = p.Id;
        share.UserOrGroupId = coachee.Id;
        share.AccessLevel = 'read';
        insert share;
        //共享给被辅导人的经理
        if(coachee.ManagerId == null){
             return;
        }
        User manager = [select id,Name from User where id =:coachee.ManagerId];
        if(manager.id == coachor.id){
            return;
        }
        
        Plan__Share share2 = new Plan__Share();
        share2.ParentId = p.Id;
        share2.UserOrGroupId = manager.Id;
        share2.AccessLevel = 'read';
        insert share2;
    }

/************************内部类，用于前端显示进度及问题******************************/
    public class compentencyAndQues
    {
        public Competency__c com{set;get;}
        public List<Question__c> queList{set;get;}
        public List<planDetail> planDetailList{set;get;}
    }

    public class planDetail
    {
        public Question__c question{set;get;}
        public boolean isFocusArea{set;get;}
        public String answer{set;get;}
        public String lastPeriodAnswer{set;get;}
    }

    public class selectQuestion
    {
        public Question__c question{set;get;}
    }
}
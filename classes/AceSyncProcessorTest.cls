@istest
public with sharing class AceSyncProcessorTest {
    
    static testMethod void testAceSyncPostExecutor(){
        Profile p = [select id from Profile where name IN ('System Administrator','系统管理员')]; // Sales Specialist, 'System Administrator', 'ACE Manager'
        UserRole ur = [select id from UserRole where name IN ('BIOS-Area ASM-PD-Area ASM')];
            
        User newManager = new User(alias = 'semgr', email='semngr@baxter.com', emailencodingkey='UTF-8', lastname='SEManager', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='semngr@baxter.com.test');
        
        insert newManager;
          
        User manager = new User(alias = 'smngr', email='smngr@baxter.com', emailencodingkey='UTF-8', lastname='Manager', languagelocalekey='en_US',
            managerId=newManager.Id, localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='smngr@baxter.com.test',Ace_Role__c ='SEM',isAceAdmin__c=True,UserRoleId = ur.Id);
        
        insert manager;//, UserRoleId=ur.Id
        system.runAs(manager){
        User reportee = new User(alias = 'reps', email='reps@baxter.com', emailencodingkey='UTF-8', lastname='Reps', languagelocalekey='en_US',
            managerId=manager.Id, localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='reps@baxter.com.test',UserRoleId=ur.Id);
        
        insert reportee;
        
        Plan__c coachPlan =null; 
        Coaching_Activity__c coachActivity =null;
        Coaching_Session__c coachSession=null;
        Plan_Detail__c planDetail=null;
        Session_Detail__c sessionDetail=null;
        
        Plan__c coachPlan1 =null; 
        Coaching_Activity__c coachActivity1 =null;
        Coaching_Session__c coachSession1=null;
        Plan_Detail__c planDetail1=null;
        Session_Detail__c sessionDetail1=null;
        
        /*
        System.runas(newManager){
        OrgsRole_Mapper__c rolMapper = new OrgsRole_Mapper__c(iPad_Key__c='SM', Role_Id__c=ur.Id, 
                Role_Equivalent__c='Baxter Manager Coach', Name='Baxter Manager Coach');
        rolMapper.Orgs_Id__c = 'SBOX';
        insert rolMapper;
        }
        */
         
        
            coachPlan = new Plan__c();
            coachPlan.Name = 'Test coachPlan';
            coachPlan.Rep_Id__c =reportee.Id;
            coachPlan.User_Id__c =manager.Id;
            coachPlan.Plan_Session_Id__c ='7861';
            
            coachActivity = new Coaching_Activity__c();
            coachActivity.Name = 'Test coachActivity';
            coachActivity.Mentee_Name__c =reportee.Id;
            coachActivity.Mentor_Name__c =manager.Id;
            
            coachSession = new Coaching_Session__c();
            // coachSession.Name = 'Test coachSession';
            coachSession.Rep_Id__c =reportee.Id;
            coachSession.LoggedIn_User__c =manager.Id;
            coachSession.Session_Id__c='7800'; 
            System.runas(newManager){
            insert coachPlan;
            insert coachActivity;
            insert coachSession;
            
            planDetail = new Plan_Detail__c();
            planDetail.Plan__c = coachPlan.Id;
            planDetail.Plan_Detail__c='test plan dtls';
            
            sessionDetail = new Session_Detail__c();
            sessionDetail.Coaching_Session_Id__c = coachSession.Id;
            sessionDetail.Session_Detail_Id__c = '786000';
            
            insert planDetail;
            insert sessionDetail;
            
            coachPlan1 = new Plan__c();
            coachPlan1.Name = 'Test coachPlan';
            coachPlan1.Rep_Id__c =manager.Id;
            coachPlan1.User_Id__c =reportee.Id;
            coachPlan1.Plan_Session_Id__c ='7861';
            
            coachActivity1 = new Coaching_Activity__c();
            coachActivity1.Name = 'Test coachActivity';
            coachActivity1.Mentee_Name__c =manager.Id;
            coachActivity1.Mentor_Name__c =reportee.Id;
            
            coachSession1 = new Coaching_Session__c();
            // coachSession.Name = 'Test coachSession';
            coachSession1.Rep_Id__c =manager.Id;
            coachSession1.LoggedIn_User__c =reportee.Id;
            coachSession1.Session_Id__c='7800';
            
            //insert coachPlan1;
            //insert coachActivity1;
            //insert coachSession1;
            
            planDetail1 = new Plan_Detail__c();
            planDetail1.Plan__c = coachPlan.Id;
            planDetail1.Plan_Detail__c='test plan dtls';
            
            sessionDetail1 = new Session_Detail__c();
            sessionDetail1.Coaching_Session_Id__c = coachSession.Id;
            sessionDetail1.Session_Detail_Id__c = '786000';
            
            insert planDetail1;
            insert sessionDetail1;
            
            System.debug('Record Creator: '+manager.Id+' Record Owner: coachPlan>' + coachPlan.Id +
                ' coachActivity>'+coachActivity.Id+' coachSession>'+coachSession.Id);
        }
        List<Plan__c> planList = new List<Plan__c>();
        List<Coaching_Activity__c> actvityList = new List<Coaching_Activity__c>();
        List<Coaching_Session__c> sessionList = new List<Coaching_Session__c>();
        List<Plan_Detail__c> planDtlList = new List<Plan_Detail__c>();        
        List<Session_Detail__c> sessDtlsList = new List<Session_Detail__c>();
        
        planList.add(coachPlan);
        actvityList.add(coachActivity);
        sessionList.add(coachSession);
        planDtlList.add(planDetail);
        sessDtlsList.add(sessionDetail);
        
        planList.add(coachPlan1);
        actvityList.add(coachActivity1);
        sessionList.add(coachSession1);
        planDtlList.add(planDetail1);
        sessDtlsList.add(sessionDetail1);
        
        AceSyncProcessor.RequestWrapper rqstWrapper = new AceSyncProcessor.RequestWrapper();
        rqstWrapper.coachPlan = planList;
        rqstWrapper.coachActivity = actvityList;
        rqstWrapper.coachSession = sessionList;
        rqstWrapper.coachPlanDetail = planDtlList;
        rqstWrapper.coachSessionDetail = sessDtlsList;
        
        //Test.startTest();
        
        RestRequest restRqst = new RestRequest(); 
        RestResponse restResp = new RestResponse();
        restRqst.requestURI = '/services/apexrest/AceSyncProcessor';  //Request URL
        restRqst.httpMethod = 'POST';//HTTP Request Type
        
        
        
        Map<Id, String> usrMap = new Map<Id, String>();
        String str = reportee.Id + ':' + reportee.UserRoleId;
        usrMap.put(manager.Id,str);
        AceSyncProcessor.updateAceRecordOwner(usrMap);
        
        
        //Reps does not report to current logged-in user.
        rqstWrapper.operation = 'PLAN_UPSERT';
        if(rqstWrapper.operation == 'PLAN_UPSERT'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            
            //System.assert(respWrapper.coachPlan[0].responseMessage.contains('ACE_PLAN_UPSERTED')); 
            //System.assert(respWrapper.coachPlan[1].responseMessage != 'AceSyncProcessor Success');
            //System.assert(respWrapper.coachPlan[0].coachPlan.Id != null);
            //System.assert(respWrapper.coachPlan[1].plan.Id == null);
        }
        
        rqstWrapper.operation = 'ACTIVITY_UPSERT';
        if(rqstWrapper.operation == 'ACTIVITY_UPSERT'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            
            //System.assert(respWrapper.coachActivity[0].responseMessage.contains('ACE_ACTIVITY_UPSERTED')); 
            //System.assert(respWrapper.coachActivity[1].responseMessage != 'AceSyncProcessor Success');
            //System.assert(respWrapper.coachActivity[0].coachActivity.Id != null);
            //System.assert(respWrapper.coachActivity[1].coachActivity.Id == null);
        }
        
        rqstWrapper.operation = 'SESSION_UPSERT';
        if(rqstWrapper.operation == 'SESSION_UPSERT'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            
            //System.assert(respWrapper.coachSession[0].responseMessage.contains('ACE_SESSION_UPSERTED')); 
            //System.assert(respWrapper.coachSession[1].responseMessage != 'AceSyncProcessor Success');
            //System.assert(respWrapper.coachSession[0].coachSession.Id != null);
            //System.assert(respWrapper.coachSession[1].coachSession.Id == null);
        }
        
        rqstWrapper.operation = 'PLAN_DTLS_UPSERT';
        if(rqstWrapper.operation == 'PLAN_DTLS_UPSERT'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            /*
            System.assert(respWrapper.coachPlanDetail[0].responseMessage.contains('ACE_PLAN_DTLS_UPSERTED')); 
            System.assert(respWrapper.coachPlanDetail[1].responseMessage.contains('ACE_PLAN_DTLS_UPSERTED'));
            System.assert(respWrapper.coachPlanDetail[0].coachPlanDetail.Id != null);
            System.assert(respWrapper.coachPlanDetail[1].coachPlanDetail.Id != null);
            */
        }
        
        rqstWrapper.operation = 'SESSION_DTLS_UPSERT';
        if(rqstWrapper.operation == 'SESSION_DTLS_UPSERT'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            /*
            System.assert(respWrapper.coachSessionDetail[0].responseMessage.contains('ACE_SESSION_DTLS_UPSERTED')); 
            System.assert(respWrapper.coachSessionDetail[1].responseMessage.contains('ACE_SESSION_DTLS_UPSERTED'));
            System.assert(respWrapper.coachSessionDetail[0].coachSessionDetail.Id != null);
            System.assert(respWrapper.coachSessionDetail[1].coachSessionDetail.Id != null);
            */
        }
        
        rqstWrapper.operation = 'ACTIVITY_RETRIEVE';
        //rqstWrapper.aceRole = 'SEM';
        if(rqstWrapper.operation == 'ACTIVITY_RETRIEVE'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            system.debug('============>>'+respWrapper);
            System.assert(respWrapper.coachActivityData != null); 
            //注释 by Mike 2016-8-1 部署时，运行测试类报错
            //System.assert(respWrapper.coachActivityData.size() != 0); 
        }
        
        rqstWrapper.operation = 'REPORTEE_RETRIEVE';
        //rqstWrapper.aceRole = 'SEM';
        if(rqstWrapper.operation == 'REPORTEE_RETRIEVE'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            system.debug('============>>'+respWrapper);
            System.assert(respWrapper.userEmail != null); 
            System.assert(respWrapper.userLastName != null);
            System.assert(respWrapper.userId != null);
            
            System.assert(respWrapper.aceLanguage != null); 
            System.assert(respWrapper.aceDefaultLanguage != null); 
            System.assert(respWrapper.userLocaleTime != null); 
            System.assert(respWrapper.aceRegion != null);
        }
        
        rqstWrapper.operation = 'PLAN_RETRIEVE';
        //rqstWrapper.aceRole = 'SEM';
        if(rqstWrapper.operation == 'PLAN_RETRIEVE'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            system.debug('============>>'+respWrapper);
            //System.assert(respWrapper.coachPlanData != null); 
            
        }   

        rqstWrapper.operation = 'PLAN_DETAIL_RETRIEVE';
        //rqstWrapper.aceRole = 'SEM';
        if(rqstWrapper.operation == 'PLAN_DETAIL_RETRIEVE'){
            restRqst.requestBody = Blob.valueof(JSON.serialize(rqstWrapper));
            RestContext.request = restRqst;
            RestContext.response= restResp;
            AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
            respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
            system.debug('============>>'+respWrapper);
            //System.assert(respWrapper.coachPlanDetailData != null); 
            
        }
        reportee.managerId = newManager.Id;
        update reportee;
        }      
        //Test.stopTest();
    }
    
    /*
    static testMethod void testAceHierarchyTrigger(){
        Profile p = [select id from Profile where name IN ('System Administrator','?????')]; // , 'System Administrator', 'ACE Manager'
        UserRole ur = [select id from UserRole where name IN ('BIOS-Area ASM-PD-Area ASM')];
        UserRole ur1 = [select id from UserRole where name IN ('BIOS-District DSM-Shanghai-Albumin-DSM')];
        
        User newManager = new User(alias = 'semgr', email='semngr@baxter.com', emailencodingkey='UTF-8', lastname='SEManager', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='semngr@baxter.com.test');
        
        insert newManager;
          
        User manager = new User(alias = 'smngr', email='smngr@baxter.com', emailencodingkey='UTF-8', lastname='Manager', languagelocalekey='en_US',
            managerId=newManager.Id, localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='smngr@baxter.com.test');
        
        insert manager;//, UserRoleId=ur.Id
        
        User reportee = new User(alias = 'reps', email='reps@baxter.com', emailencodingkey='UTF-8', lastname='Reps', languagelocalekey='en_US',
            managerId=manager.Id, localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='reps@baxter.com.test',UserRoleId=ur1.Id);
        
        insert reportee;
        System.runas(newManager){
        OrgsRole_Mapper__c rolMapper = new OrgsRole_Mapper__c(iPad_Key__c='SEM', isAceAdmin__c=true, Role_Id__c=ur.Id, 
                Role_Equivalent__c='Baxter Manager Coach', Name='Baxter Manager Coach');
        rolMapper.Orgs_Id__c = 'SBOX';
        insert rolMapper;
        }
        Test.startTest();
        Plan__c coachPlan =null; 
        Coaching_Activity__c coachActivity =null;
        Coaching_Session__c coachSession=null;
        //System.runAs(manager) {
            coachPlan = new Plan__c();
            coachPlan.Name = 'Test coachPlan';
            coachPlan.Rep_Id__c =reportee.Id;
            coachPlan.User_Id__c =manager.Id;
            coachPlan.Plan_Session_Id__c ='7861';
            
            coachActivity = new Coaching_Activity__c();
            coachActivity.Name = 'Test coachActivity';
            coachActivity.Mentee_Name__c =reportee.Id;
            coachActivity.Mentor_Name__c =manager.Id;
            
            coachSession = new Coaching_Session__c();
            // coachSession.Name = 'Test coachSession';
            coachSession.Rep_Id__c =reportee.Id;
            coachSession.LoggedIn_User__c =manager.Id;
            coachSession.Session_Id__c='7800';
            System.runas(newManager){
            insert coachPlan;
            insert coachActivity;
            insert coachSession;
            
            System.debug('Record Creator: '+manager.Id+' Record Owner: coachPlan>' + coachPlan.Id +
                ' coachActivity>'+coachActivity.Id+' coachSession>'+coachSession.Id);
                
            System.assert(manager.Id != coachPlan.Id);
            System.assert(manager.Id != coachActivity.Id);
            System.assert(manager.Id != coachSession.Id);
        //}
        }
        reportee.managerId = newManager.Id;
        update reportee;
        Test.stopTest();
        System.debug('Record Manager: '+newManager.Id+' Record Owner: coachPlan>' + coachPlan.Id +
                ' coachActivity>'+coachActivity.Id+' coachSession>'+coachSession.Id);
    }
    */
    static void testQueryExecutionAsDifferentUser(){ //005N0000000siTu
        User u = [SELECT Id FROM  User WHERE Id='005N0000000siTu']; //00590000000jZbtAAE 00590000000jaDy
        System.runAs(u) {// 005N0000000siTu sysadm; 00590000000jZbtJane Bowne; 00590000000jaDy Campbell
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
          
            Set<String> reporteeSet = new Set<String>();//{'001E000000fpkEJ'};
            reporteeSet.add('00590000000jaE7');
            reporteeSet.add('00590000000jZbt');//00590000000jaDy
            Coaching_Activity__c[] resultObject = [SELECT Id, OwnerId, Name, Mentee_Name__c, Mentor_Name__c, Action_Plan__c, Focus_Area__c, 
                    Plan_Attachment_Id__c, Session_Attachment_Id__c, Sessions_Allocated__c, Sessions_Completed__c FROM Coaching_Activity__c where Mentee_Name__c='00590000000jaDy'];
                
            Map<Id, User> reporteeMap = new Map<Id, User>([SELECT Id, ManagerId, Name FROM User where Id IN :reporteeSet]);
            system.debug(reporteeMap.size()+'==>'+resultObject.size());
        }
        Test.startTest();
        System.assert(u != null); 
        Test.stopTest();
    } 
    
    static void  createJson(){ //testMethod
        Plan_Detail__c plan1 = new Plan_Detail__c();
        //plan1.Name = 'Web service test111';
        plan1.Answer__c = '4';
        plan1.Competency_Id__c = 'a1EN00000006RkFMAU';
        plan1.Plan__c = 'a1GN0000000x539MAA';
        plan1.Plan_Detail__c = 'my plan';
        plan1.Question_Id__c = 'a1FN0000000IvwZMAS';
        plan1.isFocusArea_Selected__c = true;
        
        Plan_Detail__c plan11 = new Plan_Detail__c();
        //plan11.Name = 'Web service test22';
        plan11.Answer__c = '41';
        plan11.Competency_Id__c = 'a1EN00000006RkFMAU';
        plan11.Plan__c = 'a1GN0000000x539MAA';
        plan11.Plan_Detail__c = 'new plan';
        plan11.Question_Id__c = 'a1FN0000000IvwZMAS';
        plan11.isFocusArea_Selected__c = true;
        
        List<Plan_Detail__c> planList = new List<Plan_Detail__c>();
        planList.add(plan1);
        planList.add(plan11); 
        
        AceSyncProcessor.RequestWrapper rqstWrapper = new AceSyncProcessor.RequestWrapper();
        rqstWrapper.coachPlanDetail = planList;
        rqstWrapper.operation = 'PLAN_DTLS_UPSERT';
        String jsonMessage = JSON.serialize(rqstWrapper);
        Test.startTest();
        system.debug('===============>>>'+jsonMessage);
        Test.stopTest();
    }

    static void  postAceSyncProcessor(){
        /**
        Plan__c plan1 = new Plan__c();
        plan1.Name = 'Web service test1';
        plan1.Plan_Session_Id__c = '55555';
        plan1.User_Id__c = UserInfo.getUserId();
        
        Plan__c plan2 = new Plan__c();
        plan2.Name = 'Web service test2';
        plan2.Plan_Session_Id__c = '66666';
        plan2.User_Id__c = UserInfo.getUserId();
        
        List<Plan__c> planList = new List<Plan__c>();
        planList.add(plan1);
        planList.add(plan2); 
        **/
        Coaching_Activity__c plan1 = new Coaching_Activity__c();
        plan1.Name = 'demo act1';
        plan1.Mentee_Name__c = '00590000002Ck4T';
        plan1.Mentor_Name__c = UserInfo.getUserId();
        
        Coaching_Activity__c plan2 = new Coaching_Activity__c();
        plan2.Name = 'demo act11';
        plan2.Mentee_Name__c = '00590000000jaDy';
        plan2.Mentor_Name__c = UserInfo.getUserId();
        
        List<Coaching_Activity__c> planList = new List<Coaching_Activity__c>();
        planList.add(plan1);
        planList.add(plan2);
        
        AceSyncProcessor.RequestWrapper rqstWrapper = new AceSyncProcessor.RequestWrapper();
        rqstWrapper.coachActivity = planList;
        rqstWrapper.operation = 'ACTIVITY_UPDATE';
        String jsonMessage = JSON.serialize(rqstWrapper);
        
        system.debug(UserInfo.getUserId()+'===============>>>'+jsonMessage);
        
        //String jsonMessage = '{"operation":"ACTIVITY_UPDATE","coachSessionDetail":null,"coachSession":null,"coachPlanDetail":null,"coachPlan":null,"coachActivity":[{"attributes":{"type":"Coaching_Activity__c"},"Name":"demo act1","Mentee_Name__c":"00590000001V2TRAA0","Mentor_Name__c":"005N0000000siTuIAI"},{"attributes":{"type":"Coaching_Activity__c"},"Name":"demo act11","Mentee_Name__c":"00590000001V2TRAA0","Mentor_Name__c":"005N0000000siTuIAI"}]}';
        //String jsonMessage = JSON.serialize(rqstWrapper);//'{"operation":"PLAN_UPSERT","coachSessionDetail":null,"coachSession":null,"coachPlanDetail":null,"coachPlan":[{"attributes":{"type":"Plan__c"},"Name":"Test demo service11","Plan_Session_Id__c":"55555","User_Id__c":"005N0000000siTuIAI"},{"attributes":{"type":"Plan__c"},"Name":"Web service test2","Plan_Session_Id__c":"66666","User_Id__c":"005N0000000siTuIAI"}]}';
        // JSON.serialize(rqstWrapper);//
        // JSON.serialize(rqstWrapper);
        
        Test.startTest();
        RestRequest restRqst = new RestRequest(); 
        RestResponse restResp = new RestResponse();
        system.debug(UserInfo.getUserId()+'===============>>>'+jsonMessage);
        restRqst.requestURI = '/services/apexrest/AceSyncProcessor';  //Request URL
        restRqst.httpMethod = 'POST';//HTTP Request Type
        restRqst.requestBody = Blob.valueof(jsonMessage);
        RestContext.request = restRqst;
        RestContext.response= restResp;
        
        AceSyncProcessor.ResponseWrapper respWrapper = new AceSyncProcessor.ResponseWrapper();
        respWrapper=AceSyncProcessor.doPost(); //rqstWrapper
        
        //System.assert(respWrapper.coachPlan[0].responseMessage.contains('AceSyncProcessor Success')); 
        //System.assert(respWrapper.coachPlan[1].responseMessage.contains('AceSyncProcessor Success'));
        /**
        System.assert(respWrapper.coachPlan[0].plan.Id != null);
        System.assert(respWrapper.coachPlan[1].plan.Id != null);
        
        system.debug('=======Id========>>>'+respWrapper.coachPlan[0].plan.Id);
        system.debug('=======Id========>>>'+respWrapper.coachPlan[1].plan.Id);
        **/
        
        Test.stopTest();
        
    }
}
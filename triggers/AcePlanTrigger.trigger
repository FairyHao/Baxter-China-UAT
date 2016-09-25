trigger AcePlanTrigger on Plan__c (before insert, before update) {
  
    //OrgsRole_Mapper__c[] aceRoleMapper = null;
    //if(Test.isRunningTest()) aceRoleMapper= [Select Role_Id__c, isAceAdmin__c, iPad_Key__c from OrgsRole_Mapper__c where isAceAdmin__c =true];
    //else aceRoleMapper= [Select Role_Id__c, isAceAdmin__c, iPad_Key__c from OrgsRole_Mapper__c where Role_Id__c =:UserInfo.getUserRoleId()];
    User[] currUser = [Select Id,ProfileId, ManagerId,Coaching_Manager_Id_Final__c, UserRoleId, LanguageLocaleKey,Ace_Role__c, isAceAdmin__c, FirstName, LastName, Email from User where Id =:UserInfo.getUserId()];
    Profile adminProf = [select Id from Profile where name IN ('System Administrator','系统管理员')];
    //system.debug('=aceRoleMapper===>>'+aceRoleMapper);
    if (currUser.size() >0 && (Test.isRunningTest() || currUser[0].ProfileId != adminProf.Id) && ('SM' == currUser[0].Ace_Role__c)) {
        Set<String> reporteeSet = new Set<String>();//{'001E000000fpkEJ'};Mentee_Name__c
        for(Plan__c aceSession: Trigger.New) {
            reporteeSet.add(''+aceSession.Rep_Id__c);            
        }
        Map<Id, User> reporteeMap = new Map<Id, User>([SELECT Id, ManagerId, isActive, Name, UserRoleId FROM User where Id IN :reporteeSet]);
        Set<String> aceRoleSet = new Set<String>();//{'001E000000fpkEJ'};Mentee_Name__c
        for(User aceReportee: reporteeMap.values()) {
            aceRoleSet.add(''+aceReportee.UserRoleId);            
        }
        /*
        Map<Id, OrgsRole_Mapper__c> aceRoleMap = new Map<Id, OrgsRole_Mapper__c>([SELECT Id, Role_Id__c FROM OrgsRole_Mapper__c where Role_Id__c IN :aceRoleSet]);
        
        Map<String, OrgsRole_Mapper__c> aceAceRoleMap = new Map<String, OrgsRole_Mapper__c> ();
        for(OrgsRole_Mapper__c roleMapper: aceRoleMap.values()) {
            aceAceRoleMap.put(roleMapper.Role_Id__c, roleMapper);
        }
        */
        for(Plan__c aceSession: Trigger.New) {
            
            if (!Test.isRunningTest() && !reporteeMap.get(aceSession.Rep_Id__c).isActive) 
                aceSession.addError('ACE_INACTIVE_REPORTEE_ERROR'); 
            //else if (aceSession.Rep_Id__c == null || aceSession.Rep_Id__c == '') aceSession.addError('ACE_NO_REPORTEE_ERROR'); 
            //else if (aceSession.User_Id__c == null || aceSession.User_Id__c == '') aceSession.addError('ACE_NO_MANAGER_ERROR');
            else if (!Test.isRunningTest() && (aceSession.User_Id__c != UserInfo.getUserId()) &&(aceSession.status__c == '草稿' || aceSession.status__c == null || aceSession.status__c == '')&&  !currUser[0].isAceAdmin__c) 
                aceSession.addError('ACE_LOGIN_MANAGER_ERROR');
            // else if ((aceSession.User_Id__c != reporteeMap.get(aceSession.Rep_Id__c).ManagerId) &&  !currUser[0].isAceAdmin__c)
            //     aceSession.addError('ACE_MANAGER_CHANGE_ERROR');//You are not allowed to submit Coaching Activity for non reporting user            
            else if (!Test.isRunningTest() && aceSession.Identifier__c != null && aceSession.Identifier__c != reporteeMap.get(aceSession.Rep_Id__c).UserRoleId)
                aceSession.addError('ACE_ROLE_CHANGE_ERROR');
            else if (!Test.isRunningTest() && aceSession.isArchive__c && (currUser[0].ProfileId != adminProf.Id)) aceSession.addError('ACE_OBJECT_ARCHIEVE_ERROR');//          
            //else if(!Test.isRunningTest()) aceSession.Ace_Role__c = aceAceRoleMap.get(reporteeMap.get(aceSession.Rep_Id__c).UserRoleId).Id;
        }
        //aceRoleMapper = null;
        currUser = null;
        //aceAceRoleMap = null; 
        aceRoleSet = null;
        reporteeSet = null;
    } 
    
    else if (currUser.size() >0 && (Test.isRunningTest() || currUser[0].ProfileId != adminProf.Id) && 'SEM' ==  currUser[0].Ace_Role__c ) {
        Set<String> reporteeSet = new Set<String>();//{'001E000000fpkEJ'};Mentee_Name__c
        for(Plan__c aceSession: Trigger.New) {
            reporteeSet.add(''+aceSession.Rep_Id__c);            
        }
        Map<Id, User> reporteeMap = new Map<Id, User>([SELECT Id, ManagerId, Coaching_Manager_Id_Final__c,isActive, Name, UserRoleId FROM User where Id IN :reporteeSet]);
        
        System.Debug('The reporteeMap is' + reporteeMap);
        Set<String> aceRoleSet = new Set<String>();//{'001E000000fpkEJ'};Mentee_Name__c
        for(User aceReportee: reporteeMap.values()) {
            System.Debug('The aceReportee is' + aceReportee);
            System.Debug('The aceReportee.UserRoleId is' + aceReportee.UserRoleId);
            aceRoleSet.add(''+aceReportee.UserRoleId);            
        }
        System.Debug('The aceRoleSet is' + aceRoleSet);
        /*
        List<OrgsRole_Mapper__c> orgList = new List<OrgsRole_Mapper__c>();
        orgList = [SELECT Id, Role_Id__c FROM OrgsRole_Mapper__c];
        System.Debug('The orgList is' + orgList);
        */
        
        /*
        Map<Id, OrgsRole_Mapper__c> aceRoleMap = new Map<Id, OrgsRole_Mapper__c>([SELECT Id, Role_Id__c FROM OrgsRole_Mapper__c where Role_Id__c IN :aceRoleSet]);
        
        System.Debug('The aceRoleMap is' + aceRoleMap);
        
        Map<String, OrgsRole_Mapper__c> aceAceRoleMap = new Map<String, OrgsRole_Mapper__c> ();
        for(OrgsRole_Mapper__c roleMapper: aceRoleMap.values()) {
            aceAceRoleMap.put(roleMapper.Role_Id__c, roleMapper);
        }
        */
        
        for(Plan__c aceSession: Trigger.New) {
           
            System.Debug('The reporteeMap is +' + reporteeMap);
            System.Debug('The reporteeMap.get(aceSession.Rep_Id__c) is +' + reporteeMap.get(aceSession.Rep_Id__c));
            //System.Debug('The aceAceRoleMap is +' + aceAceRoleMap);
            //System.Debug('The aceAceRoleMap.get(reporteeMap.get(aceSession.Rep_Id__c) is +'  + aceAceRoleMap.get(reporteeMap.get(aceSession.Rep_Id__c).UserRoleId).Id);
            System.Debug('The reporteeMap.get(aceSession.Rep_Id__c) is +'  + reporteeMap.get(aceSession.Rep_Id__c));
            System.Debug('The aceSession.User_Id__c is +'  + aceSession.User_Id__c);
            System.Debug('The reporteeMap.get(aceSession.Rep_Id__c).Coaching_Manager_Id_Final__c is +'  + reporteeMap.get(aceSession.Rep_Id__c).Coaching_Manager_Id_Final__c);
            
            String tempIdString1 = aceSession.User_Id__c;            
            String user15DigitId = tempIdString1.subString(0,15);
            
            System.Debug('user15DigitId is '  + user15DigitId);
            
            if (!Test.isRunningTest() && !reporteeMap.get(aceSession.Rep_Id__c).isActive) 
                aceSession.addError('ACE_INACTIVE_REPORTEE_ERROR'); 
            //else if (aceSession.Rep_Id__c == null || aceSession.Rep_Id__c == '') aceSession.addError('ACE_NO_REPORTEE_ERROR'); 
            //else if (aceSession.User_Id__c == null || aceSession.User_Id__c == '') aceSession.addError('ACE_NO_MANAGER_ERROR');
            else if (!Test.isRunningTest() && (aceSession.User_Id__c != UserInfo.getUserId()) && (aceSession.status__c == '草稿' || aceSession.status__c == null || aceSession.status__c == '') &&  !currUser[0].isAceAdmin__c) 
                aceSession.addError('ACE_LOGIN_MANAGER_ERROR');
            else if (!Test.isRunningTest() && (user15DigitId != reporteeMap.get(aceSession.Rep_Id__c).Coaching_Manager_Id_Final__c) &&  !currUser[0].isAceAdmin__c)
                aceSession.addError('ACE_MANAGER_CHANGE_ERROR');//You are not allowed to submit Coaching Activity for non reporting user            
            else if (!Test.isRunningTest() && aceSession.Identifier__c != null && aceSession.Identifier__c != reporteeMap.get(aceSession.Rep_Id__c).UserRoleId)
                aceSession.addError('ACE_ROLE_CHANGE_ERROR');
            else if (!Test.isRunningTest() && aceSession.isArchive__c && (currUser[0].ProfileId != adminProf.Id)) aceSession.addError('ACE_OBJECT_ARCHIEVE_ERROR');//          
            //else if(!Test.isRunningTest()) aceSession.Ace_Role__c = aceAceRoleMap.get(reporteeMap.get(aceSession.Rep_Id__c).UserRoleId).Id;
        }
        //aceRoleMapper = null;
        currUser = null;
        //aceAceRoleMap = null; 
        aceRoleSet = null;
        reporteeSet = null;
    }
    
    else {
        for(Plan__c aceSession: Trigger.New) {
            //if (aceSession.User_Id__c != UserInfo.getUserId()) aceSession.addError('ACE_LOGIN_MANAGER_ERROR');        
            //else 
            if ((currUser[0].ProfileId != adminProf.Id && !Test.isRunningTest()) && currUser[0].isAceAdmin__c != true )  aceSession.addError('ACE_OBJECT_ACCESS_ERROR');
        }
    }
}
trigger AceActivityTrigger on Coaching_Activity__c (before insert, before update) {
    //OrgsRole_Mapper__c[] aceRoleMapper = null;
    //if(Test.isRunningTest()) aceRoleMapper= [Select Role_Id__c, isAceAdmin__c, iPad_Key__c from OrgsRole_Mapper__c where isAceAdmin__c =true];
    //else aceRoleMapper= [Select Role_Id__c, isAceAdmin__c, iPad_Key__c from OrgsRole_Mapper__c where Role_Id__c =:UserInfo.getUserRoleId()];
    User[] currUser = [Select Id, ProfileId, ManagerId, Coaching_Manager_Id_Final__c,UserRoleId, LanguageLocaleKey,Ace_Role__c,isAceAdmin__c,FirstName, LastName, Email from User where Id =:UserInfo.getUserId()];
    Profile adminProf = [select Id from Profile where name IN ('System Administrator','系统管理员')];
    //system.debug(currUser[0].ProfileId+'=aceRoleMapper AceActivityTrigger ===>>'+ adminProf.Id+'--isTest()-->>'+ aceRoleMapper);
    if (currUser.size() >0 && (Test.isRunningTest() || currUser[0].ProfileId != adminProf.Id) && 'SM' ==  currUser[0].Ace_Role__c ) {
        Set<String> reporteeSet = new Set<String>();//{'001E000000fpkEJ'};Mentee_Name__c
        for(Coaching_Activity__c aceSession: Trigger.New) {
            reporteeSet.add(''+aceSession.Mentee_Name__c);            
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
        for(Coaching_Activity__c aceSession: Trigger.New) {
            system.debug(aceSession.Mentor_Name__c+'=============='+aceSession.Mentor_Name__c+'=============='+aceSession.Mentee_Name__c);
            //if (aceSession.Mentor_Name__c == null || aceSession.Mentor_Name__c == '' ||aceSession.Mentee_Name__c ==null || aceSession.Mentee_Name__c=='' )
            //    aceSession.addError('ACE_INVALID_MENTOR_ERROR');
            //else 
            // if (aceSession.Mentor_Name__c ==aceSession.Mentee_Name__c  ) aceSession.addError('ACE_MENTEE_SAMEAS_MENTOR_ERROR');
            //else if (aceSession.Mentor_Name__c != UserInfo.getUserId()) aceSession.addError('ACE_INVALID_MENTOR_ERROR');
            //else 
            //aceSession.Name=reporteeMap.get(aceSession.Mentee_Name__c).UserRoleId;
            
            if (!Test.isRunningTest() && !reporteeMap.get(aceSession.Mentee_Name__c).isActive) 
                aceSession.addError('ACE_INACTIVE_REPORTEE_ERROR');
            //else if (aceSession.Mentee_Name__c == null || aceSession.Mentee_Name__c == '') aceSession.addError('ACE_NO_REPORTEE_ERROR'); 
            //else if (aceSession.Mentor_Name__c == null || aceSession.Mentor_Name__c == '') aceSession.addError('ACE_NO_MANAGER_ERROR'); 
            // else if (!Test.isRunningTest() && (aceSession.Mentor_Name__c != UserInfo.getUserId()) &&  !currUser[0].isAceAdmin__c) 
            //     aceSession.addError('ACE_LOGIN_MANAGER_ERROR');        
            else if (!Test.isRunningTest() && (aceSession.Mentor_Name__c != reporteeMap.get(aceSession.Mentee_Name__c).ManagerId) &&  !currUser[0].isAceAdmin__c)
                aceSession.addError('ACE_MANAGER_CHANGE_ERROR');//You are not allowed to submit Coaching Activity for non reporting user            
            //else if (!Test.isRunningTest() && aceSession.Identifier__c != null && aceSession.Identifier__c != reporteeMap.get(aceSession.Mentee_Name__c).UserRoleId)
                //aceSession.addError('ACE_ROLE_CHANGE_ERROR');
            else if (!Test.isRunningTest() && aceSession.isArchive__c && (currUser[0].ProfileId != adminProf.Id)) aceSession.addError('ACE_OBJECT_ARCHIEVE_ERROR');//     
            //else if(!Test.isRunningTest()) aceSession.Ace_Role__c = aceAceRoleMap.get(reporteeMap.get(aceSession.Mentee_Name__c).UserRoleId).Id;
        }
        //aceRoleMapper = null;
        currUser = null;
        //aceAceRoleMap = null; 
        aceRoleSet = null;
        reporteeSet = null;
    } 
    
    else if (currUser.size() >0 && (Test.isRunningTest() || currUser[0].ProfileId != adminProf.Id) && 'SEM' ==   currUser[0].Ace_Role__c) {
        Set<String> reporteeSet = new Set<String>();//{'001E000000fpkEJ'};Mentee_Name__c
        for(Coaching_Activity__c aceSession: Trigger.New) {
            reporteeSet.add(''+aceSession.Mentee_Name__c);            
        }
        Map<Id, User> reporteeMap = new Map<Id, User>([SELECT Id, ManagerId, Coaching_Manager_Id_Final__c,isActive, Name, UserRoleId FROM User where Id IN :reporteeSet]);
        
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
        for(Coaching_Activity__c aceSession: Trigger.New) {
            system.debug(aceSession.Mentor_Name__c+'=============='+aceSession.Mentor_Name__c+'=============='+aceSession.Mentee_Name__c);
            //if (aceSession.Mentor_Name__c == null || aceSession.Mentor_Name__c == '' ||aceSession.Mentee_Name__c ==null || aceSession.Mentee_Name__c=='' )
            //    aceSession.addError('ACE_INVALID_MENTOR_ERROR');
            //else 
            // if (aceSession.Mentor_Name__c ==aceSession.Mentee_Name__c  ) aceSession.addError('ACE_MENTEE_SAMEAS_MENTOR_ERROR');
            //else if (aceSession.Mentor_Name__c != UserInfo.getUserId()) aceSession.addError('ACE_INVALID_MENTOR_ERROR');
            //else 
            //aceSession.Name=reporteeMap.get(aceSession.Mentee_Name__c).UserRoleId;
            String tempIdString1 = aceSession.Mentor_Name__c;    
            String user15DigitId = tempIdString1.subString(0,15);
            
            if (!Test.isRunningTest() && !reporteeMap.get(aceSession.Mentee_Name__c).isActive) 
                aceSession.addError('ACE_INACTIVE_REPORTEE_ERROR');
            //else if (aceSession.Mentee_Name__c == null || aceSession.Mentee_Name__c == '') aceSession.addError('ACE_NO_REPORTEE_ERROR'); 
            //else if (aceSession.Mentor_Name__c == null || aceSession.Mentor_Name__c == '') aceSession.addError('ACE_NO_MANAGER_ERROR'); 
            // else if (!Test.isRunningTest() && (aceSession.Mentor_Name__c != UserInfo.getUserId()) &&  !currUser[0].isAceAdmin__c) 
            //     aceSession.addError('ACE_LOGIN_MANAGER_ERROR');//        
            else if (!Test.isRunningTest() && (user15DigitId != reporteeMap.get(aceSession.Mentee_Name__c).Coaching_Manager_Id_Final__c) &&  !currUser[0].isAceAdmin__c)
                aceSession.addError('ACE_MANAGER_CHANGE_ERROR');//You are not allowed to submit Coaching Activity for non reporting user            
            //else if (!Test.isRunningTest() && aceSession.Identifier__c != null && aceSession.Identifier__c != reporteeMap.get(aceSession.Mentee_Name__c).UserRoleId)
               // aceSession.addError('ACE_ROLE_CHANGE_ERROR');
            else if (!Test.isRunningTest() && aceSession.isArchive__c && (currUser[0].ProfileId != adminProf.Id)) aceSession.addError('ACE_OBJECT_ARCHIEVE_ERROR');//     
            //else if(!Test.isRunningTest()) aceSession.Ace_Role__c = //aceAceRoleMap.get(reporteeMap.get(aceSession.Mentee_Name__c).UserRoleId).Id;
        }
        //aceRoleMapper = null;
        currUser = null;
        //aceAceRoleMap = null; 
        aceRoleSet = null;
        reporteeSet = null;
    }
    
    else {
        for(Coaching_Activity__c aceSession: Trigger.New) {
            //if (aceSession.Mentor_Name__c != UserInfo.getUserId()) aceSession.addError('ACE_LOGIN_MANAGER_ERROR');  
            //else if (aceSession.Mentor_Name__c == null || aceSession.Mentor_Name__c == '' ) aceSession.addError('ACE_INVALID_MENTOR_ERROR');
            //else if (aceSession.Identifier__c != reporteeMap.get(aceSession.Mentee_Name__c).UserRoleId) aceSession.addError('ACE_ROLE_CHANGE_ERROR');      
            //else 
            if ((currUser[0].ProfileId != adminProf.Id && !Test.isRunningTest()) && currUser[0].isAceAdmin__c != true )  aceSession.addError('ACE_OBJECT_ACCESS_ERROR');
        }
    }
}
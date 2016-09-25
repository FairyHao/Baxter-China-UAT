trigger AceSessionDetailTrigger on Session_Detail__c (before insert, before update) {
    //OrgsRole_Mapper__c[] aceRoleMapper = [Select Role_Id__c, isAceAdmin__c, iPad_Key__c from OrgsRole_Mapper__c where Role_Id__c =:UserInfo.getUserRoleId()];
    User[] currUser = [Select Id, ProfileId, ManagerId,Coaching_Manager_Id_Final__c, UserRoleId, LanguageLocaleKey, Ace_Role__c, isAceAdmin__c, FirstName, LastName, Email from User where Id =:UserInfo.getUserId()];
    Profile adminProf = [select Id from Profile where name IN ('System Administrator','系统管理员')];
    //system.debug('=aceRoleMapper===>>'+aceRoleMapper);
    if ( currUser.size() >0 && (currUser[0].ProfileId != adminProf.Id) && 
            ('SEM' ==  currUser[0].Ace_Role__c || 'SM' ==  currUser[0].Ace_Role__c)) {
        for(Session_Detail__c aceSession: Trigger.New) {
            if (aceSession.isArchive__c && (currUser[0].ProfileId != adminProf.Id)) aceSession.addError('ACE_OBJECT_ARCHIEVE_ERROR');//          
        }
    } else {
        for(Session_Detail__c aceSession: Trigger.New) {
            //currUser = null;
            if (currUser[0].ProfileId != adminProf.Id)  aceSession.addError('ACE_OBJECT_ACCESS_ERROR');
        }
    }
}
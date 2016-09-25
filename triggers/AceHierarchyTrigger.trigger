/**
** Author Madhav.Shandilya@Cognizant.com
** Requirement- While updating Reps Manager, ACE record should be transferred to new Manager
** AceHierarchyTrigger will update the record ownership for ACE Coaching Plan, Activity & Session
** 
**/
trigger AceHierarchyTrigger on User (before update, after update) { 
    System.debug('AceHierarchyTrigger Trigger.isUpdate> ' +Trigger.isUpdate+ ' > User >'+Trigger.new);
    
    Map<String,String> userRoleIPadKeyMap = new Map<String,String>();
    for(OrgsRole_Mapper__c org1 : [Select id,Role_Id__c,iPad_Key__c from OrgsRole_Mapper__c]){
        userRoleIPadKeyMap.put(org1.Role_Id__c,org1.iPad_Key__c);
    }
    if(Trigger.isUpdate){
        Map<Id, String> userMap = new Map<Id, String>();
        for (User user : Trigger.new) {
            User previousUserData = Trigger.oldMap.get(user.Id);
            String usrDetails = null;
            //usrDetails = user.ManagerId;
            //usrDetails = usrDetails + ':' +user.UserRoleId;
            
            
            if(user.Coaching_Manager__c != null){
                usrDetails = user.Coaching_Manager__c;
            }
            else if(user.ManagerId != null && (previousUserData.ManagerId != user.ManagerId)) {//&& (previousUserData.ManagerId != user.ManagerId))
                usrDetails = user.ManagerId;
                // userMap.put(previousUserData.Id, user.ManagerId );//'\''+user.ManagerId+'\''
            } //\'' + + '\'' \+'String.escapeSingleQuotes(user.ManagerId)
            if(user.UserRoleId != null && previousUserData.UserRoleId != user.UserRoleId) {// && (previousUserData.UserRoleId != user.UserRoleId))
                if(userRoleIPadKeyMap.containsKey(user.UserRoleId)){
                    if(userRoleIPadKeyMap.containsKey(previousUserData.UserRoleId)){
                        String userIPadKey = userRoleIPadKeyMap.get(user.UserRoleId);
                        String previousUserIPadKey = userRoleIPadKeyMap.get(previousUserData.UserRoleId);
                        if(userIPadKey != previousUserIPadKey){
                            usrDetails = usrDetails + ':' +user.UserRoleId;
                        }
                    }
                }
                
            } else usrDetails = usrDetails + ':';
            if (usrDetails ==null) usrDetails =':';
            userMap.put(previousUserData.Id, usrDetails);//'\''+user.ManagerId+'\''
        }
        
        System.debug(userMap.size()+'> AceHierarchyTrigger coachActivity: size >' +userMap.keySet());
        AceSyncProcessor.updateAceRecordOwner(userMap);
    }
}
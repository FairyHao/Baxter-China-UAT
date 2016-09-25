/**
** Author Madhav.Shandilya@Cognizant.com
** Requirement- While updating Reps Manager, ACE record should be transferred to new Manager
** AceHierarchyTrigger will update the record ownership for ACE Coaching Plan, Activity & Session
** 
**/
trigger AceCoachingManagerUpdateTrigger on User (before update,before insert) { 
   
    for(User usr : Trigger.New){
            /*
            if(usr.coaching_manager__c != NULL){
                usr.Coaching_Manager_Id__c = usr.coaching_manager__c;
            }
            else{
                usr.Coaching_Manager_Id__c = usr.ManagerId;
            }
        */
        
    }
}
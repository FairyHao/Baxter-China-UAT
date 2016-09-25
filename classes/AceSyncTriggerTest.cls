@istest
public with sharing class AceSyncTriggerTest {
    
    
    static testMethod void testAceHierarchyTrigger(){
        Profile p = [select id from Profile where name IN ('System Administrator','系统管理员')]; // , 'System Administrator', 'ACE Manager'
        UserRole ur = [select id from UserRole where name IN ('BIOS-Area ASM-PD-Area ASM')];
            
        User newManager = new User(alias = 'semgr', email='semngr@baxter.com', emailencodingkey='UTF-8', lastname='SEManager', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='semngr@baxter.com.test');
        
        insert newManager;
          
        User manager = new User(alias = 'smngr', email='smngr@baxter.com', emailencodingkey='UTF-8', lastname='Manager', languagelocalekey='en_US',
            managerId=newManager.Id, localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='smngr@baxter.com.test',Ace_Role__c ='SEM',isAceAdmin__c=True,UserRoleId = ur.Id);
        
        insert manager;//, UserRoleId=ur.Id
        System.runAs(manager){
        User reportee = new User(alias = 'reps', email='reps@baxter.com', emailencodingkey='UTF-8', lastname='Reps', languagelocalekey='en_US',
            managerId=manager.Id, localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='reps@baxter.com.test',UserRoleId=ur.Id);
        
        insert reportee;
        /*
        System.runas(newManager){
        OrgsRole_Mapper__c rolMapper = new OrgsRole_Mapper__c(iPad_Key__c='SEM', isAceAdmin__c=true, Role_Id__c=ur.Id, 
                Role_Equivalent__c='Baxter Manager Coach', Name='Baxter Manager Coach');
        rolMapper.Orgs_Id__c = 'SBOX';
        insert rolMapper;
        }
        */
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
            
            Plan_Detail__c planDt = new Plan_Detail__c();
            planDt.Plan__c = coachPlan.Id;
            
            Session_Detail__c sessionDt = new Session_Detail__c();
            sessionDt.Coaching_Session_Id__c = coachSession.Id;
            
            insert planDt;
            insert sessionDt;
            }
        //}
        
        
        Test.stopTest();
       }
    }
    
    
    static testMethod void testAceHierarchyTrigger2(){
        Profile p = [select id from Profile where name IN ('System Administrator','系统管理员')]; // , 'System Administrator', 'ACE Manager'
        UserRole ur = [select id from UserRole where name IN ('BIOS-District DSM-Shanghai-Albumin-DSM')];
            
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
        
        
         /*System.runas(newManager){
        OrgsRole_Mapper__c rolMapper = new OrgsRole_Mapper__c(iPad_Key__c='SEM', isAceAdmin__c=true, Role_Id__c=ur.Id, 
                Role_Equivalent__c='Baxter Manager Coach', Name='Baxter Manager Coach');
        rolMapper.Orgs_Id__c = 'SBOX';
        insert rolMapper;
        }
       */
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
            
            Plan_Detail__c planDt = new Plan_Detail__c();
            planDt.Plan__c = coachPlan.Id;
            
            Session_Detail__c sessionDt = new Session_Detail__c();
            sessionDt.Coaching_Session_Id__c = coachSession.Id;
            
            insert planDt;
            insert sessionDt;
            
            }
        //}
        
        
        Test.stopTest();
       }
    }
    
}
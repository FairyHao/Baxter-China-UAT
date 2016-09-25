/*
Author:Dean
Date:2015-10-22
Function:WebAce 导航界面
 */
public with sharing class aceGuidePageController
{
    public User u{set;get;}
    public UserRole role{set;get;}
    public String str{set;get;}

    public aceGuidePageController()
    {
        u =[select id,Ace_Role__c,isAceAdmin__c,profile.Name from User where id =: userinfo.getUserId()];
        
    }

    public PageReference checkUserGoDifPage()
    {
        system.debug('######u.Profile.Name######'+u.Profile.Name);
        if(u.Profile.Name.contains('系统管理员') || 
         u.Profile.Name.contains('system administrator') || 
         u.Profile.Name.contains('Admin'))
        {
         PageReference pageRef = new PageReference('/apex/CoachingExcellencePage');
         return pageRef;
        }
        return null;
        
    }

    public PageReference goToCoachingPlan()
    {
       
            String[] types = new String[]{'Plan__c'};
            Schema.DescribeSobjectResult[] results = schema.describeSObjects(types);
            for(Schema.DescribeSobjectResult res : results)
            {
                 str = res.getKeyPrefix();
            }
            system.debug('-----------------STR-----------------'+str);
            PageReference pageRef = new PageReference('/'+str);
            return pageRef;

    }

    public PageReference goToCoachingSession()
    {
        
            String[] types = new String[]{'Coaching_Session__c'};
            Schema.DescribeSobjectResult[] results = schema.describeSObjects(types);
            for(Schema.DescribeSobjectResult res : results)
            {
                 str = res.getKeyPrefix();
            }
            system.debug('-----------------STR-----------------'+str);
            PageReference pageRef = new PageReference('/'+str);
            return pageRef;
    
    }

}
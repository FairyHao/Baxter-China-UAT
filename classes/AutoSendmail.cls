/**
 * 作者:Bill
 * 说明：发送邮件
**/
public class AutoSendmail {

    //加一个自动发送邮件的触发项，主管点击即可将评分评语发送邮件至被点评人，邮件需包含以下内容：
    //1，被分配人，拜访开始时间，联系人信息，被点评人，点评人，评分，评语
    //2，拜访链接 
    public void AutoSendmailEvent(ID eventId, ID assVisitCommentsId, string action)
    {
    	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	    //联系人
            Contact contact = new Contact();
            Event event = [Select ownerId, owner.Alias, owner.Email, whoId, who.Name, StartDateTime from Event where id=:eventId];
            List<Contact> List_contact = [Select Account.Name from Contact where id= : event.WhoId];
            if(List_contact!=null && List_contact.size()>0)
            {
            	contact = List_contact[0];
            }
            AssVisitComments__c avc = [Select a.ReUser__c, a.ReUser__r.Alias, a.Grade__c, a.Comment__c, a.BeReviewed__c,  BeReviewed__r.Alias From AssVisitComments__c a where id =:assVisitCommentsId];
            String repBody = '';
            if(event.Owner.Alias != null){
             repBody += '您好:'+event.Owner.Alias+' <br><br>';  
            }      
            repBody += '主管对您的拜访进行了'+ action +'。<br>';
            repBody += '详细信息如下：<br>';
            if(event.Owner.Alias != null){
            repBody += '被分配人：'+event.Owner.Alias + '<br>';
            }
            if(event.StartDateTime != null){
            repBody += '拜访开始时间：'+event.StartDateTime+ '<br>';
            }
            if(event.whoId != NULL)
            {
               repBody += '联系人名称：'+ event.who.Name+ '<br>';
               if(contact.Account.Name != null){
               	repBody += '客户名称：'+ contact.Account.Name+ '<br>';
               }
            }
            if(avc.BeReviewed__r.Alias != null){
            repBody += '被点评人：'+ avc.BeReviewed__r.Alias+ '<br>';
            }
            if(avc.ReUser__r.Alias != null){
            repBody += '点评人：' + avc.ReUser__r.Alias+ '<br>';
            }
            if(avc.Grade__c != null){
            repBody += '评分： '+avc.Grade__c+ '<br>';
            }
            if(avc.Comment__c != null){
            repBody += '评语： '+ avc.Comment__c+ '<br><br>';
            }
            repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。<br>'; 
            repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>';
            String emailAddress = event.Owner.Email;
            String[] repAddress =new string[]{emailAddress};
            mail.setToAddresses(repAddress);
            mail.setHtmlBody(repBody);
            mail.setSubject('主管对拜访评分已完成，请查看');
            mail.setSaveAsActivity(false);//存为活动
            mail.setSenderDisplayName('Salesforce');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
    }
    
    //加一个自动发送邮件的触发项，主管点击即可将评分评语发送邮件至被点评人，邮件需包含以下内容：
    //1，业务机会所有人，业务机会名称，阶段，点评月份，点评人，评分，评语
    //2，业务机会链接
    public void AutoSendmailOpportunity(ID oppId, ID OppEvaluationId, string action)
    {
    	
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            Opportunity opp = [Select o.StageName, o.OwnerId, owner.Alias, owner.Email, o.Name From Opportunity o where id=:oppId];
            OppEvaluation__c oppEva = [Select o.Score__c, o.Month__c, o.Comments__c, o.Commentator__c, o.Commentator__r.Alias, o.BeCommentUser__c, BeCommentUser__r.Alias From OppEvaluation__c o where id =:OppEvaluationId];
            String repBody = '';
            if(opp.Owner.Alias != null){
              repBody += '您好:'+opp.Owner.Alias+' <br><br>';  
            }      
            repBody += '主管对您的业务机会进行了'+ action +'。<br>';
            repBody += '详细信息如下：<br>';
            if(opp.Owner.Alias != null){
            repBody += '业务机会所有人：'+opp.Owner.Alias + '<br>';
            }
            if(opp.Name != null){
            repBody += '业务机会名称：'+opp.Name+ '<br>';
            }
            if(opp.StageName != null){
            repBody += '阶段：'+ opp.StageName+ '<br>';
            }
            if(oppEva.Month__c != null){
            repBody += '点评月份：'+ oppEva.Month__c+ '月<br>';
            }
            if(oppEva.BeCommentUser__r.Alias != null){
            repBody += '被点评人：'+ oppEva.BeCommentUser__r.Alias+ '<br>';
            }
            if(oppEva.Commentator__r.Alias != null){
            repBody += '点评人：'+ oppEva.Commentator__r.Alias+ '<br>';
            }
            if(oppEva.Score__c != null){
            repBody += '评分：' + oppEva.Score__c+ '<br>';
            }
            if(oppEva.Comments__c != null){
            repBody += '评语： '+oppEva.Comments__c+ '<br><br>';
            }
            repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。<br>'; 
            repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>';
            String emailAddress = opp.Owner.Email;
            String[] repAddress =new string[]{emailAddress};
            mail.setToAddresses(repAddress);
            mail.setHtmlBody(repBody);
            mail.setSubject('主管对业务机会评分已完成，请查看');
            mail.setSaveAsActivity(false);//存为活动
            mail.setSenderDisplayName('Salesforce');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
    }
    
    //加一个自动发送邮件的触发项，主管点击即可将评分评语发送邮件至被点评人，邮件需包含以下内容：
    //1，被点评主管，点评人，点评月份，评分，评语
    //2，业务机会策略评估链接
    public void AutoSendmailOpportunityTwo(ID OppEvaluationId, String action)
    {
    	
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OppEvaluation__c oppEva = [Select o.Score__c, o.Month__c, o.Comments__c, o.Commentator__c, o.Commentator__r.Alias, o.BeCommentUser__c, BeCommentUser__r.Alias, BeCommentUser__r.Email From OppEvaluation__c o where id =:OppEvaluationId];
            String repBody = '';
            if(oppEva.BeCommentUser__r.Alias != null){
            repBody += '您好:'+oppEva.BeCommentUser__r.Alias+' <br><br>';        
            }
            repBody += '主管对您的业务机会策略评估进行了点评'+ action +'。<br>';
            repBody += '详细信息如下：<br>';
            if(oppEva.Month__c != null){
            repBody += '点评月份：'+ oppEva.Month__c+ '月<br>';
            }
            if(oppEva.BeCommentUser__r.Alias != null){
            repBody += '被点评主管：'+ oppEva.BeCommentUser__r.Alias+ '<br>';
            }
            if(oppEva.Commentator__r.Alias != null){
            repBody += '点评人：'+ oppEva.Commentator__r.Alias+ '<br>';
            }
            if(oppEva.Score__c != null){
            repBody += '评分：' + oppEva.Score__c+ '<br>';
            }
            if(oppEva.Comments__c  != null){
            repBody += '评语： '+oppEva.Comments__c+ '<br><br>';
            }
            repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。<br>'; 
            repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>';
            String emailAddress = oppEva.BeCommentUser__r.Email;
            String[] repAddress =new string[]{emailAddress};
            mail.setToAddresses(repAddress);
            mail.setHtmlBody(repBody);
            mail.setSubject('业务机会策略评分已完成，请查看');
            mail.setSaveAsActivity(false);//存为活动
            mail.setSenderDisplayName('Salesforce');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        //user role
        List<UserRole> listur= new List<UserRole>();
        UserRole ur0 = new UserRole();
        ur0.Name = 'Renal-Supervisor-华南-PD-Supervisor(U0)';
        listur.add(ur0);
        UserRole ur1 = new UserRole();
        ur1.Name = 'Renal-Supervisor-华南-PD-Supervisor(U1)';
        listur.add(ur1);
        UserRole ur2 = new UserRole();
        ur2.Name = 'Renal-Rep-华南-PD-Rep(U2)';
        listur.add(ur2);
        insert listur;
        ur2.ParentRoleId=ur1.Id;
        update ur2;
        ur1.ParentRoleId = ur0.id;
        update ur1;
        //user 
        list<User> user=[Select TimeZoneSidKey,ProfileId,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey,CommunityNickname, Alias From User Where IsActive = true limit 1];
        List<User> list_user = new List<User>();
        User user0=new User();
        user0.username='user0r2@023.com';
        user0.LastName='user0r2';
        user0.Email='user0r2@023.com';
        user0.Alias=user[0].Alias;
        user0.TimeZoneSidKey=user[0].TimeZoneSidKey;
        user0.ProfileId=UserInfo.getProfileId();
        user0.LocaleSidKey=user[0].LocaleSidKey;
        user0.LanguageLocaleKey=user[0].LanguageLocaleKey;
        user0.EmailEncodingKey=user[0].EmailEncodingKey;
        user0.CommunityNickname='chequ23';
        user0.MobilePhone='02345678902';
        user0.IsActive = true;
        user0.UserRoleId=ur0.Id ;
        user0.Alias='zhangsan';
        list_user.add(user0);
        User user1=new User();
        user1.username='user1r2@123.com';
        user1.LastName='user1r2';
        user1.Email='user1r2@123.com';
        user1.Alias=user[0].Alias;
        user1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        user1.ProfileId=UserInfo.getProfileId();
        user1.LocaleSidKey=user[0].LocaleSidKey;
        user1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        user1.EmailEncodingKey=user[0].EmailEncodingKey;
        user1.CommunityNickname='chequ';
        user1.MobilePhone='12345678912';
        user1.Alias='aaaa';
        user1.IsActive = true;
        user1.UserRoleId=ur1.Id ;
        list_user.add(user1);
        User user2=new User();
        user2.username='user2r2@223.com';
        user2.LastName='user2r2';
        user2.Email='user2r2@223.com';
        user2.Alias=user[0].Alias;
        user2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        user2.ProfileId=UserInfo.getProfileId();
        user2.LocaleSidKey=user[0].LocaleSidKey;
        user2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        user2.EmailEncodingKey=user[0].EmailEncodingKey;
        user2.CommunityNickname='chequ1';
        user2.MobilePhone='22345678922';
        user2.IsActive = true;
        user2.UserRoleId=ur2.Id ;
        user2.Alias ='bbb';
        list_user.add(user2);
        insert list_user;
        
        //account
        Account acc = new Account();
        acc.Name = 'woyun';
        insert acc;
        
        //Contact
        Contact contact = new Contact();
        contact.FirstName = 'zhang';
        contact.AccountId = acc.Id;
        contact.LastName = 'san';
        insert contact;
        
        //event
        RecordType rt =[Select Id From RecordType Where DeveloperName = 'V2_Event' And SobjectType = 'Event'];
        Event objEvent = new Event();
        objEvent.OwnerId = user2.Id;
        objEvent.StartDateTime = datetime.now();
        objEvent.EndDateTime = datetime.now().addHours(1);
        objEvent.RecordTypeId = rt.Id;
        objEvent.Subject = '拜访';
        objEvent.WhoId = contact.Id;
        insert objEvent ;
        
        //Opportunity
        List<Opportunity> list_Opp = new List<Opportunity>();
        Opportunity objOpp1 = new Opportunity();
        objOpp1.Name = 'test opp';
        objOpp1.Type = '新业务' ;
        objOpp1.StageName = '发现/验证机会';
        objOpp1.ProductType__c = 'IVS' ;
        objOpp1.CloseDate = date.today().addMonths(1);
        objOpp1.OwnerId = user2.Id;
        list_Opp.add(objOpp1);
        insert list_Opp ;
        
        //AssVisitComments__c
        AssVisitComments__c avc = new AssVisitComments__c();
        avc.EventId__c = objEvent.Id;
        avc.BeReviewed__c = user2.Id;
        avc.ReUser__c = user1.Id;
        avc.Comment__c = 'sss';
        avc.Grade__c='4';
        avc.IsAssVisit__c = true;
        insert avc ;
        
        //OppEvaluation__c
        List<OppEvaluation__c> list_oppEva = new List<OppEvaluation__c>();
        OppEvaluation__c oppEva1 = new OppEvaluation__c();
        oppEva1.Year__c = String.valueOf(date.today().year());
        oppEva1.Month__c = String.valueOf(date.today().month());
        oppEva1.Commentator__c = user1.Id;
        oppEva1.Opportunity__c = objOpp1.Id;
        oppEva1.BeCommentUser__c = user2.Id ;
        oppEva1.Score__c = '4';
        list_oppEva.add(oppEva1);
        OppEvaluation__c oppEva2 = new OppEvaluation__c();
        oppEva2.Year__c = String.valueOf(date.today().year());
        oppEva2.Month__c = String.valueOf(date.today().addMonths(-1).month());
        oppEva2.Commentator__c = userinfo.getUserId();
        oppEva2.Commentator__c = user1.Id;
        oppEva2.Opportunity__c = objOpp1.Id;
        oppEva2.BeCommentUser__c = user2.Id ;
        oppEva2.Score__c = '4';
        list_oppEva.add(oppEva2);
        insert list_oppEva ;
        
        system.Test.startTest();
        AutoSendMail autoSendMail = new AutoSendMail();
        autoSendMail.AutoSendmailEvent(objEvent.Id, avc.Id, '123');
        autoSendMail.AutoSendmailOpportunity(objOpp1.Id, oppEva1.Id, '123');
        autoSendMail.AutoSendmailOpportunityTwo(oppEva1.id, '123');
        system.Test.stopTest();
    }
}
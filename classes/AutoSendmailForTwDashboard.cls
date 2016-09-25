/**
 *
 * 说明：发送邮件
**/
global class AutoSendmailForTwDashboard implements Schedulable{


         
     global void execute(SchedulableContext sc)
    {
           list <user> mailList = [Select Email from User where UserRoleId  in (select id from UserRole where Name Like 'TW%'  ) and IsActive = true];
            
            //角色
           String[] mailarray = new List <String> (); 
           for(Integer i=0;i<mailList.size(); i++) {
              String mailLists = mailList[i].Email;
              mailarray.add (mailLists );
          } 
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     
            if (mailList != null) {

                    String repBody = '';
                    String title = 'Reminder: Please submit your next monthly plan if it is not done yet';
                    repBody += 'Dear all,'+' <br><br>';  
                    repBody += 'Today is 25th of this month, please don’t forget to submit your monthly plan for your manager’s review today.<br>';
                    repBody += '今天已經是本月25日了，請記得送出下月的拜訪計畫予您的經理審核。<br><br><br>';
                    repBody += 'Best Regards<br>'; 
                    repBody += 'SFDC admin<br>'; 
          
              
                    mail.setToAddresses(mailarray);
                    mail.setHtmlBody(repBody);
                    mail.setSubject(title);
                    mail.setSenderDisplayName('Salesforce');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                  
                 
         }
         else
         {
              String repBody1 = '';
                    
                    repBody1 += 'Dear admin,'+' <br><br>';  
                   
                    repBody1 += 'Something wrong<br>';
                    
                   
                    repBody1 += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。<br>'; 
                    repBody1 += '如有任何疑问或者要求，请联系系统管理人员。<br>';
                    String emailAddress1 = 'liang.xiao@wipro.com';
                    String[] repAddress1 =new string[]{emailAddress1};
                    mail.setToAddresses(repAddress1);
                    mail.setHtmlBody(repBody1);
                    mail.setSubject('error');
                    mail.setSenderDisplayName('Salesforce');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }
    }
 }
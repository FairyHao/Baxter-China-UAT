/**
 *
 * 说明：发送邮件
**/
global class AutoSendmailForTw implements Schedulable{


         
     global void execute(SchedulableContext sc)
    {
           list <user> mailList = [Select Email from User where UserRoleId  in (select id from UserRole where Name Like 'TW%' ) and IsActive = true];
            
            //角色
           String[] mailarray = new List <String> (); 
           for(Integer i=0;i<mailList.size(); i++) {
              String mailLists = mailList[i].Email;
              mailarray.add (mailLists );
          } 
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     
            if (mailList != null) {

                    String repBody = '';
                    String title = 'Reminder: Please complete all visit records for this month and draft schedules for next week.';
                    repBody += 'Dear all,'+' <br><br>';  
                    repBody += 'Today is end of this month, please don’t forget to complete all visit records for this month and draft visit schedule for next week.<br>';
                    repBody += '今天已經是本月最後一天了，請記得完成本月的所有拜訪紀錄，並安排下週的拜訪行程。<br><br><br>';
                    repBody += 'Best Regards<br>'; 
                    repBody += 'SFDC Admin<br>'; 
          
              
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
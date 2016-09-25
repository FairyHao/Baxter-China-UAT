//spring 2015-6-11 增加IPAS 邮件通知 病人介入为“是” ，邮件发送给。。。
trigger emailSentToPV on IVT_ComplaintProductInfo__c  (after insert) {
    String IVTRid = '';
    String IPASRid = '';
    Set<String> TypeName = new Set<String>();
    TypeName.add('IVT_ComplaintProductInfo_rt');
    TypeName.add('IPAS_ComplaintProductInfo_rt');
    for(RecordType rr : [select id,DeveloperName from RecordType where DeveloperName IN : TypeName]){
        if(rr.DeveloperName == 'IVT_ComplaintProductInfo_rt'){
            IVTRid = rr.id;
        }
        if(rr.DeveloperName == 'IPAS_ComplaintProductInfo_rt'){
            IPASRid = rr.id;
        }
    }
    if(trigger.isAfter && trigger.isInsert) {
         IVT_ComplaintProductInfo__c productDetail;
         list  <IVT_ComplaintSetting__c> list_main = new list<IVT_ComplaintSetting__c>();
         for(IVT_ComplaintProductInfo__c c : trigger.New) {
                // IVT 投诉
               if(c.IVT_ComplaintType__c == '加药后产品质量问题' && c.RecordTypeId == IVTRid)
               {
                   productDetail = c;
                   list_main = [select IVT_ComplaintHappenedDate__c,IVT_ComplaintSubmitDate__c, IVT_Contact__c from IVT_ComplaintSetting__c where Id=: productDetail.IVT_ComplaintSetting__c ];
                   
                   if (c != null) {
                       for  ( IVT_ComplaintSetting__c m : list_main ) {
                       
                            list <Contact> list_contact = [select Name,AccountId from Contact where id =: m.IVT_Contact__c];
                            Contact contact = list_contact.get(0);
                            list <Account> list_account = [select name from Account where id =: contact.AccountId];
                            Account account = list_account.get(0);
                            list <User> list_user = [select name from User where id =: productDetail.CreatedById];
                            User user = list_user.get(0);
                            string baseUrl = string.valueOf(System.URL.getSalesforceBaseUrl());
                            baseUrl = baseUrl.substring(baseUrl.indexOf('=')+1,baseUrl.length()-1);
                            baseUrl = baseUrl+'/'+ m.Id;
                            System.debug('Email');
               
                            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                            String repBody1 = '';
                            repBody1 += '您有一个IVT不良产品投诉申请 。 <br><br>';
                            repBody1 += '<table class="tableClass" id="thePage:theTable" border="1" cellpadding="1" cellspacing="0">';

                            repBody1 += '<colgroup span="2"></colgroup>';

                                repBody1 += '<thead>';

                                    repBody1 += '<tr>';

                                        repBody1 += '<td scope="col">字段名称</td>';

                                        repBody1 += '<td scope="col">数值</td>';

                                    repBody1 += '</tr>';

                                repBody1 += '</thead>';
                                
                                repBody1 += '<tbody>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>发生时间</td>';

                                        repBody1 += '<td>'+ m.IVT_ComplaintHappenedDate__c + '</td>';

                                    repBody1 += ' </tr>';

                                    repBody1 += '<tr class="even">';

                                        repBody1 += '<td>获得投诉日期</td>';

                                        repBody1 += '<td>' +  m.IVT_ComplaintSubmitDate__c+ '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>联系人客户</td>';

                                        repBody1 += '<td>' + account.Name + '</td>';

                                    repBody1 += '</tr>';
                                    
                                    repBody1 += '<tr class="even">';

                                        repBody1 += '<td>产品名称</td>';

                                        repBody1 += '<td>' + productDetail.IVT_ProductName__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>产品货号</td>';

                                        repBody1 += '<td>' + productDetail.IVT_ProductCode__c + '</td>';

                                    repBody1 += '</tr>';
                                    
                                    repBody1 += '<tr class="even">';

                                        repBody1 += '<td>规格</td>';

                                        repBody1 += '<td>' + productDetail.IVT_Specifications__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>批号</td>';

                                        repBody1 += '<td>' + productDetail.IVT_TotalClaimAmount__c + '</td>';

                                    repBody1 += '</tr>';
                                    
                                    repBody1 += '<tr class="even">';

                                        repBody1 += '<td>投诉数量</td>';

                                        repBody1 += '<td>' + productDetail.IVT_ComplaintProductQuality__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>投诉类型细分</td>';

                                        repBody1 += '<td>' + productDetail.IVT_ComplaintTypeDetail__c + '</td>';

                                    repBody1 += '</tr>';
                                    
                                    repBody1 += '<tr class="even">';

                                        repBody1 += '<td>事件导致结果</td>';

                                        repBody1 += '<td>' + productDetail.IVT_EventResult__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>补充信息</td>';

                                        repBody1 += '<td>' + productDetail.IVT_SupplementaryInformation__c + '</td>';

                                    repBody1 += '</tr>';
                                    
                                    repBody1 += '<tr class="even">';

                                        repBody1 += '<td>发生环节</td>';

                                        repBody1 += '<td>' + productDetail.IVT_OccurrenceLink__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>所有人</td>';

                                        repBody1 += '<td>' + user.name + '</td>';

                                    repBody1 += '</tr>';

                                repBody1 += '</tbody>';

                            repBody1 += '</table>';
                            //repBody1 += '发生时间：' + m.IVT_ComplaintHappenedDate__c + '<br>';
                            //repBody1 += '获得投诉日期：' + m.IVT_ComplaintSubmitDate__c + '<br>';
                            //repBody1 += '联系人客户：' + account.Name + '<br>';
                            //repBody1 += '产品名称：' + productDetail.IVT_ProductName__c + '<br>';
                            //repBody1 += '产品货号：' + productDetail.IVT_ProductCode__c + '<br>';
                            //repBody1 += '规格：' + productDetail.IVT_Specifications__c + '<br>';
                            //repBody1 += '批号：' + productDetail.IVT_TotalClaimAmount__c + '<br>';
                            //repBody1 += '投诉数量：' + productDetail.IVT_ComplaintProductQuality__c + '<br>';
                           // repBody1 += '投诉类型细分：' + productDetail.IVT_ComplaintTypeDetail__c + '<br>';
                            //repBody1 += '事件导致结果：' + productDetail.IVT_EventResult__c + '<br>';
                            //repBody1 += '补充信息：' + productDetail.IVT_SupplementaryInformation__c + '<br>';
                            //repBody1 += '发生环节：' + productDetail.IVT_OccurrenceLink__c + '<br>';
                            //repBody1 += '所有人：' + user.name + '<br>';
                            repBody1 += '<br> 请点击以下链接进行查看。<br>'; 
                            repBody1 += baseUrl+'<br><br>'; 
                            String emailAddress1 = 'China_SHS_PV@baxter.com';
                            String[] Address =new string[]{emailAddress1};
                            mail1.setToAddresses(Address);
                            mail1.setHtmlBody(repBody1);
                            mail1.setSubject('IVT不良产品投诉');
                            mail1.setSenderDisplayName('Salesforce');
             
              
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });     
                       }
                   } 
               } 


                // IPAS   “病人介入”选择“是”，就要通知PV部门
               if(c.IPAS_PatientJoin__c == '是' && c.RecordTypeId == IPASRid)
               {
                   productDetail = c;
                   list_main = [select IVT_ComplaintHappenedDate__c,IVT_ComplaintSubmitDate__c, IVT_Contact__c,IVT_Contact__r.name,IPAS_AccountId__c,IPAS_AccountId__r.name from IVT_ComplaintSetting__c where Id=: productDetail.IVT_ComplaintSetting__c ];
                   
                   if (c != null) {
                       for  ( IVT_ComplaintSetting__c m : list_main ) {
                            list <User> list_user = [select name from User where id =: productDetail.CreatedById];
                            User user = list_user.get(0);
                            string baseUrl = string.valueOf(System.URL.getSalesforceBaseUrl());
                            baseUrl = baseUrl.substring(baseUrl.indexOf('=')+1,baseUrl.length()-1);
                            baseUrl = baseUrl+'/'+ m.Id;
                            System.debug('Email');
               
                            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                            String repBody1 = '';
                            repBody1 += '您有一个IPAS不良产品投诉申请 。 <br><br>';
                            repBody1 += '<table class="tableClass" id="thePage:theTable" border="1" cellpadding="1" cellspacing="0">';

                            repBody1 += '<colgroup span="2"></colgroup>';

                                repBody1 += '<thead>';

                                    repBody1 += '<tr>';

                                        repBody1 += '<td scope="col">字段名称</td>';

                                        repBody1 += '<td scope="col">数值</td>';

                                    repBody1 += '</tr>';

                                repBody1 += '</thead>';
                                
                                repBody1 += '<tbody>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>发生时间</td>';

                                        repBody1 += '<td>'+ m.IVT_ComplaintHappenedDate__c + '</td>';

                                    repBody1 += ' </tr>';

                                    repBody1 += '<tr class="even">';

                                        repBody1 += '<td>获得投诉日期</td>';

                                        repBody1 += '<td>' +  m.IVT_ComplaintSubmitDate__c+ '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>客户</td>';

                                        repBody1 += '<td>' + m.IPAS_AccountId__r.name + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>联系人</td>';

                                        repBody1 += '<td>' + m.IVT_Contact__r.Name + '</td>';

                                    repBody1 += '</tr>';
                                    
                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>投诉类型细分</td>';

                                        repBody1 += '<td>' + productDetail.IPAS_ComplaintTypeDetail__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>投诉数量</td>';

                                        repBody1 += '<td>' + productDetail.IVT_ComplaintProductQuality__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>病人介入</td>';

                                        repBody1 += '<td>' + productDetail.IPAS_PatientJoin__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>病人受到伤害</td>';

                                        repBody1 += '<td>' + productDetail.IPAS_Ishurt__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>死亡</td>';

                                        repBody1 += '<td>' +  productDetail.IPAS_Isdie__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>发生环节</td>';

                                        repBody1 += '<td>' + productDetail.IVT_OccurrenceLink__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>产品名称</td>';

                                        repBody1 += '<td>' + productDetail.IVT_ProductName__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>产品批号</td>';

                                        repBody1 += '<td>' + productDetail.IVT_TotalClaimAmount__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>产品货号</td>';

                                        repBody1 += '<td>' + productDetail.IVT_ProductCode__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>样品可寄回数量</td>';

                                        repBody1 += '<td>' + productDetail.IPAS_back_product__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>科室</td>';

                                        repBody1 += '<td>' + productDetail.IVT_DeskWork__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>补充信息</td>';

                                        repBody1 += '<td>' + productDetail.IVT_SupplementaryInformation__c + '</td>';

                                    repBody1 += '</tr>';

                                    repBody1 += '<tr class="odd">';

                                        repBody1 += '<td>所有人</td>';

                                        repBody1 += '<td>' + user.name + '</td>';

                                    repBody1 += '</tr>';

                                repBody1 += '</tbody>';

                            repBody1 += '</table>';
                            repBody1 += '<br> 请点击以下链接进行查看。<br>'; 
                            repBody1 += baseUrl+'<br><br>'; 
                            String emailAddress1 ='China_SHS_PV@baxter.com';
                            String[] Address =new string[]{emailAddress1};
                            mail1.setToAddresses(Address);
                            mail1.setHtmlBody(repBody1);
                            mail1.setSubject('IPAS不良产品投诉');
                            mail1.setSenderDisplayName('Salesforce');
             
              
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });     
                       }
                   } 
               }   
         }

         
    }
}
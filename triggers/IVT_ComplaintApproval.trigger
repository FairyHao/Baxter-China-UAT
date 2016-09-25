/**
    * Author：bill
    * description：审批通过后自动生成PDF发送给投诉申请人
    *2015-6-29 spring 增加IPAS
    
    *2016-03-11 Dean add
    *添加【QA Update】字段用户提交申请后，QA添加任何内容，都会更新该字段。若3天后该字段的内容仍然为空，系统会自动发送邮件给到QA Admin
    *设置经理／大区经理／销售总监的用户 和 财务／商务／销售助理 的邮箱地址
*/
trigger IVT_ComplaintApproval on IVT_ComplaintSetting__c (before insert,before update,after insert,after update) {
    //IVT_ComplaintSetting__c comp = Trigger.new;
    //查询记录类型id
    String ivtString,ipasString,hdString,acuteString;
    for(RecordType obj : [select id,DeveloperName from RecordType where RecordType.DeveloperName IN ('IVT_ComplaintSetting_rt','IPAS_ComplaintSetting_rt','Acute_ComplaintSetting_rt','HD_ComplaintSetting_rt')]){
        if(obj.DeveloperName =='IVT_ComplaintSetting_rt'){
            ivtString = obj.id;
        }
        if(obj.DeveloperName =='IPAS_ComplaintSetting_rt'){
            ipasString = obj.Id;
        }
        if(obj.DeveloperName == 'HD_ComplaintSetting_rt'){
            hdString = obj.id;
        }
        if(obj.DeveloperName == 'Acute_ComplaintSetting_rt'){
            acuteString = obj.Id;
        }
    }
    if(trigger.IsBefore && trigger.IsInsert)
    {
        

        map<String,ID> map_users = new map<String,ID>();
        for(User user :[Select u.UserRole.DeveloperName, u.UserRoleId, u.Id From User u
            Where u.UserRole.DeveloperName IN ('MD_ALL','MDNationalSalesDirector','MarketingProductManagerPremix')
            AND u.IsActive = true order by u.LastModifiedDate asc]) 
        {
            map_users.put(user.UserRole.DeveloperName,user.Id);
        }  
        //联系人集合SET
        set<ID> set_conIds = new set<ID>();    
        //list<User> list_approal = [Select Id,Username from User where Profile.Name = 'Standard User - IVT Admin' AND IsActive = true];
        for(IVT_ComplaintSetting__c Complaint : trigger.New)
        {
            //销售总监 MDNationalSalesDirector
            if(map_users.containsKey('MDNationalSalesDirector'))
            Complaint.IVT_DirectorOfSalesId__c = map_users.get('MDNationalSalesDirector');
            //财务分析经理 MarketingProductManagerPremix
            if(map_users.containsKey('MarketingProductManagerPremix'))
            Complaint.IVT_FinancialManagerId__c = map_users.get('MarketingProductManagerPremix');
            //业务总监 MD_ALL
            if(map_users.containsKey('MD_ALL'))
            Complaint.IVT_SalesDirectorId__c = map_users.get('MD_ALL');
            /**********************bill update 2014-11-7 start*********************/
            //BU Head 该字段不使用
            set_conIds.add(Complaint.IVT_Contact__c);
            /*for(User u:list_approal)
            {
                if(u.Username.Contains('chenzhi_xu@baxter.com'))
                Complaint.IVT_SpecialPermit__c = u.Id;
            }
            if(Complaint.IVT_SpecialPermit__c == null)
            Complaint.IVT_SpecialPermit__c = list_approal[0].Id;*/  
            /**********************bill update 2014-11-7 END *********************/          
        }
        
        if(set_conIds.size()>0)
        {
            map<ID,ID> map_AC = new map<ID,ID>();
            set<ID> set_accIds = new set<ID>(); 
            for(Contact c : [Select Id, AccountId from Contact where Id in: set_conIds])
            {
                set_accIds.add(c.AccountId);
                map_AC.put(c.Id, c.AccountId);
            }
            if(!map_AC.IsEmpty())
            {
                map<ID,User> map_sale = getHospitalSaler(set_accIds,'IVT');
                map<ID,User> map_sale_IPAS = getHospitalSaler(set_accIds,'IS');
                //System.debug('map_sale==>'+map_sale);
                //System.debug('map_sale_IPAS==>'+map_sale_IPAS);
                for(IVT_ComplaintSetting__c Complaint : trigger.New)
                {     
                    //System.debug('Complaint==>'+Complaint);
                    //System.debug('rt==>'+Complaint.RecordTypeId);
                    //System.debug('map_AC.ContainsKey==>'+map_AC.ContainsKey(Complaint.IVT_Contact__c));
                    //System.debug('map_sale_IPAS.ContainsKey==>'+map_sale_IPAS.ContainsKey(map_AC.get(Complaint.IVT_Contact__c)));
                    //ivt   
                    if(map_AC.ContainsKey(Complaint.IVT_Contact__c) && map_sale.ContainsKey(map_AC.get(Complaint.IVT_Contact__c)) && Complaint.RecordTypeId == ivtString)
                    {
                        //System.debug('==IVT=>'+map_sale.get(map_AC.get(Complaint.IVT_Contact__c)));
                        Complaint.IVT_SaleManager__c = map_sale.get(map_AC.get(Complaint.IVT_Contact__c)).ManagerId;
                        Complaint.IVT_RegionManager__c = map_sale.get(map_AC.get(Complaint.IVT_Contact__c)).Manager.ManagerId;
                        //Spring 2015-02-28 当CS创建时，这个医院的IVT销售也能看到这条件记录   把当前的医院负责的销售添加
                        Complaint.IVT_Sales__c = map_sale.get(map_AC.get(Complaint.IVT_Contact__c)).id;
                    }
                    //IPAS
                    if(map_AC.ContainsKey(Complaint.IVT_Contact__c) && map_sale_IPAS.ContainsKey(map_AC.get(Complaint.IVT_Contact__c)) && Complaint.RecordTypeId == ipasString)
                    {
                        //System.debug('=IPAS==>'+map_sale.get(map_AC.get(Complaint.IVT_Contact__c)));
                        Complaint.IVT_SaleManager__c = map_sale_IPAS.get(map_AC.get(Complaint.IVT_Contact__c)).ManagerId;
                        Complaint.IVT_RegionManager__c = map_sale_IPAS.get(map_AC.get(Complaint.IVT_Contact__c)).Manager.ManagerId;
                        //Spring 2015-02-28 当CS创建时，这个医院的IVT销售也能看到这条件记录   把当前的医院负责的销售添加
                        Complaint.IVT_Sales__c = map_sale_IPAS.get(map_AC.get(Complaint.IVT_Contact__c)).id;
                    }
                }   
            }
        }
    }  
    if(trigger.isAfter && trigger.isInsert)
    {
        list<IVT_ComplaintSetting__Share> list_share = new list<IVT_ComplaintSetting__Share>();
        for(IVT_ComplaintSetting__c c : trigger.New)
        {        
            if(c.IVT_SaleManager__c != null && c.OwnerId != c.IVT_SaleManager__c)
            {
                IVT_ComplaintSetting__Share s = new IVT_ComplaintSetting__Share();
                s.UserOrGroupId = c.IVT_SaleManager__c;
                s.ParentId = c.id;
                s.AccessLevel = 'Edit';
                list_share.add(s);              
            }
            if(c.IVT_RegionManager__c != null && c.OwnerId != c.IVT_SaleManager__c)
            {
                IVT_ComplaintSetting__Share s = new IVT_ComplaintSetting__Share();
                s.UserOrGroupId = c.IVT_RegionManager__c;
                s.ParentId = c.id;
                s.AccessLevel = 'Edit';
                list_share.add(s);              
            }
            //Spring 2015-02-28 当CS创建时，这个医院的IVT销售也能看到这条件记录
            if(c.IVT_Sales__c != null && c.OwnerId != c.IVT_Sales__c)
            {
                IVT_ComplaintSetting__Share s = new IVT_ComplaintSetting__Share();
                s.UserOrGroupId = c.IVT_Sales__c;
                s.ParentId = c.id;
                s.AccessLevel = 'Edit';
                list_share.add(s);              
            }           
        }        
        if(list_share.size()>0)
        {
            insert list_share;
        }    
    }
    //获取对应的部门负责的销售
    private map<ID,User> getHospitalSaler(set<ID> set_INids,String department)
    {
        Map<ID,ID> map_sale = NEW Map<ID,ID>();
        //获取负责销售
        for(V2_Account_Team__c team : [Select v.V2_User__c , v.V2_Account__c,v.V2_Effective_Year__c,
            v.V2_Effective_Month__c,v.V2_Delete_Year__c,v.V2_Delete_Month__c  
            From V2_Account_Team__c v where UserProduct__c =: department 
                                       AND V2_Account__c IN : set_INids])
        {
          Date effectiveDate;
          Date deleteDate;
          integer effectiveYear = integer.valueOf(team.V2_Effective_Year__c);
          integer effectiveMonth = integer.valueOf(team.V2_Effective_Month__c);
          effectiveDate = Date.newInstance(effectiveYear, effectiveMonth, 1);
          if(team.V2_Delete_Year__c != null)
          {
            integer deleteYear = integer.valueOf(team.V2_Delete_Year__c);
            integer deleteMonth = integer.valueOf(team.V2_Delete_Month__c);
            deleteDate = Date.newInstance(deleteYear, deleteMonth, 1);
          }
          else
          {
            deleteDate = Date.newInstance(Date.Today().addMonths(1).year(),Date.Today().addMonths(1).Month(),1);
          }
          if(effectiveDate <= Date.Today() && Date.Today() < deleteDate)
          {
            map_sale.put(team.V2_User__c,team.V2_Account__c);
          }
        }   
        map<ID,User> map_saler = new map<ID,User>();
        if(!map_sale.IsEmpty())
        {
            for(User sale : [Select u.ManagerId, u.Manager.ManagerId, u.Id From User u where Id IN: map_sale.keyset() and IsActive = true])
            {
                if(map_sale.containsKey(sale.Id))
                {
                    map_saler.put(map_sale.get(sale.Id),sale);
                }
            }
        }
        return map_saler;
    }   
    
    if(trigger.IsBefore && trigger.IsUpdate)
    {
         for(IVT_ComplaintSetting__c Complaint : trigger.New)
        {
            if(Complaint.IVT_FactoryFeedBack__c == '已接受投诉' &&
                Complaint.IVT_ProcessCompleteDate__c == null)
            {
                Complaint.IVT_ReceiveComplaintDate__c = system.today();
            }
            if(Complaint.IVT_FactoryFeedBack__c == '处理完毕' &&
                Complaint.IVT_ProcessCompleteDate__c == null) 
            {
                Complaint.IVT_ProcessCompleteDate__c = system.today();
            }            
        }       
    }    
    
    IVT_ComplaintSetting__c compl;
    //业务总监，财务分析经理，销售总监
    if(trigger.IsAfter && trigger.IsUpdate)
    {
        for(IVT_ComplaintSetting__c Complaint : trigger.New)
        {
            if(Complaint.IVT_Status__c == '通过' && Complaint.IVT_Status__c != trigger.OldMap.get(Complaint.Id).IVT_Status__c)
            {
                compl = Complaint;
            }
        }
    }
    
    if(compl != null && (compl.RecordTypeId == ivtString || compl.RecordTypeId == ipasString))
    {
        string baseUrl = string.valueOf(System.URL.getSalesforceBaseUrl());
        baseUrl = baseUrl.substring(baseUrl.indexOf('=')+1,baseUrl.length()-1);
        baseUrl = baseUrl+'/'+ compl.Id;
        Messaging.EmailFileAttachment[] list_efa = new Messaging.EmailFileAttachment[]{};
        String emailAddress;
        String SaleName  = '';
        for(Attachment att : [Select Owner.Email,Name,Body,Owner.Alias from Attachment Where ParentId =: compl.Id 
            order by CreatedDate desc limit 1])
        {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(att.Name);
            efa.setBody(att.Body);
            list_efa.add(efa);
            emailAddress = att.Owner.Email;
            SaleName = att.Owner.Alias;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String repBody = '';
        
        repBody += '您好，'+SaleName+'<br>';
        if(compl.RecordTypeId == ivtString){
            mail.setSubject(SaleName+'您提交的IVT不良产品投诉申请被审批'+compl.IVT_Status__c);
            repBody += '您提交的IVT不良产品投诉申请已审批 。 <br>';
            repBody += '审批结果：'+compl.IVT_Status__c+'<br><br>';    
            repBody += '厂家： '+compl.IVT_Supply__c+'<br>'; 
        }
        if(compl.RecordTypeId == ipasString){
            mail.setSubject(SaleName+'您提交的IPAS不良产品投诉申请被审批'+compl.IVT_Status__c);
            repBody += '您提交的IPAS不良产品投诉申请已审批 。 <br>';
            repBody += '审批结果：'+compl.IVT_Status__c+'<br><br>';    
            repBody += '客户： '+compl.IPAS_AccountId__c+'<br>'; 
        }
        
        repBody += '联系人：'+compl.IVT_Contact__c+'<br>'; 
        repBody += '主题：'+compl.IVT_Subject__c+'<br>'; 
        repBody += '联系电话：'+compl.IVT_ContactPhone__c+'<br>'; 
        repBody += '获得投诉日期：'+compl.IVT_ComplaintSubmitDate__c+'<br>'; 
        repBody += '事件发生日期：'+compl.IVT_ComplaintHappenedDate__c+'<br>'; 
        repBody += '请点击以下链接进行查看。<br><br>'; 
        
        repBody += baseUrl+'<br><br>'; 
        
        repBody += '祝您工作愉快! <br>';
        repBody += '__________________________________________________<br>'; 
        repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。 <br>';
        repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>';     

        //String emailAddress = map_parEmail.get(map_par.get(event.OwnerId));
        String[] repAddress =new string[]{emailAddress};
        mail.setToAddresses(repAddress);
        mail.setHtmlBody(repBody);
        mail.setSenderDisplayName('Salesforce');
        if(list_efa.size()>0)
        {
            mail.setFileAttachments(list_efa);
        }
        if(emailAddress != null)
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }       
    }

    /**************Dean add 2016-03-11*****************/

    if(trigger.isUpdate && trigger.isBefore)
    {
        User currentUser = [SELECT id,Profile.Name FROM user WHERE id=:UserInfo.getUserId() limit 1];
        for(IVT_ComplaintSetting__c obj:trigger.new)
        {
            IVT_ComplaintSetting__c oldObj = trigger.oldMap.get(obj.Id);
            if( (obj.RecordTypeId == acuteString  || obj.RecordTypeId == hdString ) && currentUser.Profile.Name =='Standard User - IVT Factory')
            {
                if((obj.IVT_FactoryFeedBack__c != oldObj.IVT_FactoryFeedBack__c ||
                obj.IVT_Note__c != oldObj.IVT_Note__c ||
                obj.Trackwise_ID__c != oldObj.Trackwise_ID__c ||
                obj.PMDANumber__c != oldObj.PMDANumber__c ||
                obj.IVT_ReceiveComplaintDate__c != oldObj.IVT_ReceiveComplaintDate__c))
                {
                    obj.QAUpdate__c = true;
                }
            }
        }
    }

    //找到医院对应的销售及上级
    private Map<id,User> hdSaleMap = new Map<id,User>();
    private Map<id,User> acuteSaleMap = new Map<id,User>();
    private Set<id> accountIdSet =  new Set<id>();
    private Map<String,Id> nationalDirectorMap = new Map<String,Id>();
    private User hdNational = new User();
    private User acuteNational = new User();

    if((trigger.isBefore && trigger.isInsert)||(trigger.isBefore && trigger.isUpdate))
    {
        
        //通过userRole找到对应的销售总监 
        List<User> hdNationalList = [Select u.UserRole.DeveloperName, u.UserRoleId, u.Id From User u
                                    Where u.UserRole.DeveloperName = 'RenalMarketingDirector'
                                    AND u.IsActive = true order by u.LastModifiedDate asc ];
        if(hdNationalList.size()>0)
        {
            hdNational = hdNationalList[0];
        }

        List<User> acuteNationalList = [Select u.UserRole.DeveloperName, u.UserRoleId, u.Id From User u
                                        Where u.UserRole.DeveloperName = 'RenalSalesMarketingDir603349'
                                        AND u.IsActive = true order by u.LastModifiedDate asc ];
       
        if(acuteNationalList.size()>0)
        {

            acuteNational = acuteNationalList[0];
        }

        for(IVT_ComplaintSetting__c obj:trigger.new)
        {
            accountIdSet.add(obj.IPAS_AccountId__c);
        }

        if(accountIdSet.size() > 0)
        {
            hdSaleMap = getHospitalSaler(accountIdSet,'HD');
            acuteSaleMap = getHospitalSaler(accountIdSet,'ACUTE');
            for(IVT_ComplaintSetting__c obj:trigger.new)
            {
                if(obj.RecordTypeId == hdString || obj.RecordTypeId == acuteString)
                {
                    obj.IVT_Sales__c = null;
                    obj.IVT_SaleManager__c = null;
                    obj.IVT_RegionManager__c = null;
                    obj.HDAcuteNationalDirector__c = null;
                }
                
                if(obj.RecordTypeId == hdString && hdSaleMap.containsKey(obj.IPAS_AccountId__c))
                {
                    obj.HDAcuteNationalDirector__c = hdNational.Id;
                    obj.IVT_Sales__c = hdSaleMap.get(obj.IPAS_AccountId__c).id;
                    obj.IVT_SaleManager__c = hdSaleMap.get(obj.IPAS_AccountId__c).ManagerId;
                    obj.IVT_RegionManager__c = hdSaleMap.get(obj.IPAS_AccountId__c).Manager.ManagerId;
    
                    
                }
                
                if(obj.RecordTypeId == acuteString && acuteSaleMap.containsKey(obj.IPAS_AccountId__c))
                {
                    
                    obj.HDAcuteNationalDirector__c = acuteNational.Id;
                    obj.IVT_Sales__c = acuteSaleMap.get(obj.IPAS_AccountId__c).id;
                    obj.IVT_SaleManager__c = acuteSaleMap.get(obj.IPAS_AccountId__c).ManagerId;
                    obj.IVT_RegionManager__c = acuteSaleMap.get(obj.IPAS_AccountId__c).Manager.ManagerId;
                  
                }
            }
        }
    }

    //审批通过后将PDf邮件发送给销售助理／商务／财务 并将PDF添加至附件和备注
    if(trigger.isAfter && trigger.isUpdate)
    {
        List<Messaging.SingleEmailMessage> mlist = new List<Messaging.SingleEmailMessage>();
        List<String> hdEmailAdressList = new List<String>(); 
        List<String> acuteEmailAdressList = new List<String>(); 
        Map<id,IVT_ComplaintSetting__c> complainMap = new Map<id,IVT_ComplaintSetting__c>();
        Map<id,IVT_ComplaintProductInfo__c> productMap = new Map<id,IVT_ComplaintProductInfo__c>();
        Set<id> complainIdSet = new Set<id>();

        //获取自定义设置里的邮箱地址
        Map<String, HDAcuteEmailAdress__c>   hdEmailMap = HDAcuteEmailAdress__c.getAll();
        for ( String s : hdEmailMap.keySet() )
        {
            HDAcuteEmailAdress__c Setting = hdEmailMap.get( s );
            if(Setting.Name == 'HDEmail')
            {
                if(Setting.saleAssistantEmail__c != null ){hdEmailAdressList.add(Setting.saleAssistantEmail__c);}
                if(Setting.commercialEmail__c != null ){hdEmailAdressList.add(Setting.commercialEmail__c);}
                if(Setting.financialEmail__c != null ){hdEmailAdressList.add(Setting.financialEmail__c);}
                if(Setting.CSREmail__c != null ){hdEmailAdressList.add(Setting.CSREmail__c);}

                break;
            }
            
        }
        Map<String, HDAcuteEmailAdress__c>   acuteEmailMap = HDAcuteEmailAdress__c.getAll();
        for ( String s : acuteEmailMap.keySet() )
        {
            HDAcuteEmailAdress__c Setting = acuteEmailMap.get( s );
            if(Setting.Name == 'AcuteEmail')
            {
                if(Setting.saleAssistantEmail__c != null ){acuteEmailAdressList.add(Setting.saleAssistantEmail__c);}
                if(Setting.commercialEmail__c != null ){acuteEmailAdressList.add(Setting.commercialEmail__c);}
                if(Setting.financialEmail__c != null ){acuteEmailAdressList.add(Setting.financialEmail__c);}
                if(Setting.CSREmail__c != null ){acuteEmailAdressList.add(Setting.CSREmail__c);}
                
                
                break;
            }
            
        }

        for(IVT_ComplaintSetting__c obj:trigger.new)
        {
            complainIdSet.add(obj.id);
        }

        List<IVT_ComplaintSetting__c> tempList = [SELECT Id,PMDANumber__c,Trackwise_ID__c,IVT_Note__c,HD_Acute_City__r.Name,Name,IVT_Sales__c,IVT_RegionManager__c,IVT_SaleManager__c,
                                                  IVT_FactoryFeedBack__c,theFirstPerson__c,IVT_ComplaintSubmitDate__c,
                                                  IVT_ReceiveComplaintDate__c,IVT_IPAS_Distributor__r.Name,IPAS_AccountId__r.Name,
                                                  IVT_ContactPhone__c,IVT_Contact__r.Name,HD_Acute_Province__r.Name,IVT_ComplaintHappenedDate__c,
                                                  IVT_Subject__c,IVT_Status__c,IsNeedPaperReply__c,customerPhone__c,staffPhone__c,
                                                  RecordType.Name,Owner.Alias
                                                  FROM IVT_ComplaintSetting__c
                                                  WHERE id IN:complainIdSet];

        for(IVT_ComplaintSetting__c obj:tempList)
        {
            complainMap.put(obj.id,obj);
        }

        List<IVT_ComplaintProductInfo__c> productInfoList = [SELECT id,IVT_ComplaintSetting__c,productType__c,productModel__c,productNumber__c,IVT_TotalClaimAmount__c,Name,
                                                            IVT_ComplaintProductQuality__c,IPAS_back_product__c,totalMoney__c,InvolvedPeopleNumber__c,
                                                            initialName__c,patientGender__c,PatientAge__c,IVT_OccurrenceLink__c,replyOnPaper__c,complainDetailType__c,
                                                            complainDescribe__c,IPAS_PatientJoin__c,IPAS_Ishurt__c,IPAS_Isdie__c,additionalRemarks__c
                                                            FROM IVT_ComplaintProductInfo__c
                                                            WHERE IVT_ComplaintSetting__c =:complainIdSet];
        for(IVT_ComplaintProductInfo__c obj:productInfoList)
        {
            productMap.put(obj.IVT_ComplaintSetting__c,obj);
        }

        //发送邮件
        for(IVT_ComplaintSetting__c obj:trigger.new)
        {
            system.debug('----->>>'+obj.RecordTypeId +'####'+ hdString);
            system.debug('----->>>'+obj.RecordTypeId +'####'+ acuteString);
            system.debug('----->>>'+obj.IVT_Status__c +'####'+ trigger.oldMap.get(obj.id).IVT_Status__c);
            if((obj.RecordTypeId == hdString || obj.RecordTypeId == acuteString) && obj.IVT_Status__c == '通过' && obj.IVT_Status__c != trigger.oldMap.get(obj.id).IVT_Status__c)
            {
                system.debug('----->>>');
                // for(Attachment att : [Select Owner.Email,Name,Body,Owner.Alias from Attachment Where ParentId =: obj.Id 
                // order by CreatedDate desc limit 1])
                // {
                //     Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                //     efa.setFileName(att.Name);
                //     efa.setBody(att.Body);
                //     list_efa.add(efa);
                //     ownerEmail = String.valueOf(att.Owner.Email);
                //     saleName = att.Owner.Alias;
                //     break;
                // }

                //邮件正文
                // string baseUrl = string.valueOf(System.URL.getSalesforceBaseUrl());
                // baseUrl = baseUrl.substring(baseUrl.indexOf('=')+1,baseUrl.length()-1);
                // baseUrl = baseUrl+'/'+ obj.Id;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String repBody = '';
                repBody += '您好：<br>'
                + '赔付申请结果通知：<br>'

                + '<table width="700" height="248" border="1" align="center" cellpadding="0" cellspacing="0" class="theTablecontentFont" style="font-size: 12px;">'
                + '<tr>'
                +     '<td class="theRedFont" style="color: red;font-size: 18px;font-weight: bold;">基本赔付信息</td>'
                + '</tr>'
                + '<tr>'
                +     '<td >'
                +         '<table width="700"  cellpadding="0" cellspacing="0"   border="0">'
                +             '<tr>'
                +                 '<td width="20%">获得投诉日期：</td>'
                +                 '<td width="30%">'+complainMap.get(obj.Id).IVT_ComplaintSubmitDate__c+'</td>'
                +                 '<td width="20%">获知投诉的第一位员工:</td>'
                +                 '<td width="30%">'+complainMap.get(obj.Id).theFirstPerson__c+'</td>'
                +             '</tr>'
                +              '<tr>'
                +                 '<td>员工电话：</td>'
                +                 '<td>'+complainMap.get(obj.Id).staffPhone__c+'</td>'
                +                 '<td>省份:</td>'
                +                 '<td>'+complainMap.get(obj.Id).HD_Acute_Province__r.Name+'</td>'
                +             '</tr>'
                +             '<tr>'
                +                 '<td>事件发生日期：</td>'
                +                 '<td>'+complainMap.get(obj.Id).IVT_ComplaintHappenedDate__c+'</td>'
                +                 '<td>城市:</td>'
                +                 '<td>'+complainMap.get(obj.Id).HD_Acute_City__r.Name+'</td>'
                +             '</tr>'
                +             '<tr>'
                +                 '<td>客户：</td>'
                +                 '<td>'+complainMap.get(obj.Id).IPAS_AccountId__r.Name+'</td>'
                +                 '<td>顾客电话:</td>'
                +                 '<td>'+complainMap.get(obj.Id).customerPhone__c+'</td>'
                +             '</tr>'
                +             '<tr>'
                +                 '<td>涉及的经销商：</td>'
                +                 '<td>'+complainMap.get(obj.Id).IVT_IPAS_Distributor__r.Name+'</td>'
                +                 '<td>联系人:</td>'
                +                 '<td>'+complainMap.get(obj.Id).IVT_Contact__r.Name+'</td>'
                +             '</tr>'
                +             '<tr>'
                +                 '<td>赔付单号：</td>'
                +                 '<td>'+complainMap.get(obj.Id).Name+'</td>'
                +                 '<td>联系人电话:</td>'
                +                 '<td>'+complainMap.get(obj.Id).IVT_ContactPhone__c+'</td>'
                +             '</tr>'
                +             '<tr>'
                +                 '<td>状态：</td>'
                +                 '<td>'+complainMap.get(obj.Id).IVT_Status__c+'</td>'
                +                 '<td>所有人:</td>'
                +                 '<td>'+complainMap.get(obj.Id).Owner.Alias+'</td>'
                +             '</tr>'
                +             '<tr>'
                +                 '<td>记录类型：</td>'
                +                 '<td>'+complainMap.get(obj.Id).RecordType.Name+'</td>'
                +             '</tr>'
                +         '</table>'
                +       '</td>'
                +      '</tr>'
                +    '<tr>'
                +    '<td class="theRedFont" style="color: red;font-size: 18px;font-weight: bold;">QA反馈信息</td>'
                +    '</tr>'
                +    '<tr>'
                +        '<td height="50">'
                +            '<table width="700"  cellpadding="0" cellspacing="0"   border="0" style="border-bottom-color:#ffffff;">'
                +                '<tr>'
                +                    '<td width="20%">处理反馈：</td>'
                +                    '<td width="30%">'+complainMap.get(obj.Id).IVT_FactoryFeedBack__c+'</td>'
                +                    '<td width="20%">备注:</td>'
                +                    '<td width="30%">'+complainMap.get(obj.Id).IVT_Note__c+'</td>'
                +                '</tr>  '
                +                '<tr>'
                +                    '<td>Trackwise投诉ID号:</td>'
                +                    '<td>'+complainMap.get(obj.Id).Trackwise_ID__c+'</td>'
                +                    '<td>PMDA编号:</td>'
                +                    '<td>'+complainMap.get(obj.Id).PMDANumber__c+'</td>'
                +                '</tr>  '
                +                '<tr>'
                +                    '<td>接受投诉登记时间:</td>'
                +                    '<td>'+complainMap.get(obj.Id).IVT_ReceiveComplaintDate__c+'</td>'
                +                '</tr>'
                +            '</table>'
                +        '</td>'
                +    '</tr>'
                + '</table>'

                +     '<br/>'
                +    '<table style="font-size: 12px;" width="700" border="1" cellpadding="0" cellspacing="0" align="center">'
                +        '<tr>'
                +            '<td class="theRedFont" colspan="4" style="color: red;font-size: 18px;font-weight: bold;">赔付产品详细信息</td>'
                +        '</tr> '
                +        '<tr>'
                +            '<td width="20%">产品类别:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).productType__c+'</td>'
                +            '<td width="20%">产品规格型号:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).productModel__c+'</td>'
                +        '</tr> '
                +        '<tr>'
                +            '<td width="20%">正式产品编号:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).productNumber__c+'</td>'
                +            '<td width="20%">产品批号:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).IVT_TotalClaimAmount__c+'</td>'
                +        '</tr>  '
                +        '<tr>'
                +            '<td width="20%">投诉数量:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).IVT_ComplaintProductQuality__c+'</td>'
                +            '<td width="20%">样品可寄回数量:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).IPAS_back_product__c+'</td>'
                +        '</tr>  '
                +        '<tr>'
                +            '<td width="20%">总赔付金额:</td>'
                +            '<td width="30%" colspan="3">'+productMap.get(obj.Id).totalMoney__c+'</td>'
                +        '</tr>'
                +        '<tr>'
                +            '<td width="20%" colspan="4">对于不良器械事件（如适用）:</td>'
                +        '</tr>'
                +        '<tr>'
                +            '<td width="20%">涉及人数:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).InvolvedPeopleNumber__c+'</td>'
                +            '<td width="20%">病人姓名缩写:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).initialName__c+'</td>'
                +        '</tr> '
                +        '<tr>'
                +            '<td width="20%">病人性别:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).patientGender__c+'</td>'
                +            '<td width="20%">病人年龄:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).PatientAge__c+'</td>'
                +        '</tr> '
                +        '<tr>'
                +            '<td class="theRedFont" colspan="4" style="color: red;font-size: 18px;font-weight: bold;">事件描述</td>'
                +        '</tr>  '
                +        '<tr>'
                +            '<td width="20%">发生环节:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).IVT_OccurrenceLink__c+'</td>'
                +            '<td width="20%">是否需要书面回复:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).replyOnPaper__c+'</td>'
                +        '</tr> '
                +        '<tr>'
                +            '<td width="20%">投诉类型细分:</td>'
                +            '<td width="30%" style="word-break:break-all">'+productMap.get(obj.Id).complainDetailType__c+'</td>'
                +            '<td width="20%">事件描述:</td>'
                +            '<td width="30%" style="word-break:break-all">'+productMap.get(obj.Id).complainDescribe__c+'</td>'
                +        '</tr> '
                +        '<tr>'
                +            '<td width="20%">病人介入:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).IPAS_PatientJoin__c+'</td>'
                +            '<td width="20%">病人受到伤害:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).IPAS_Ishurt__c+'</td>'
                +        '</tr> '
                +        '<tr>'
                +            '<td width="20%">死亡:</td>'
                +            '<td width="30%">'+productMap.get(obj.Id).IPAS_Isdie__c+'</td>'
                +            '<td width="20%">补充信息:</td>'
                +            '<td width="30%" style="word-break:break-all">'+productMap.get(obj.Id).additionalRemarks__c+'</td>'
                +        '</tr>'
                +    '</table>'; 

              
                repBody += '__________________________________________________<br>'; 
                repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。 <br>';
                repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>'; 
                
                if(obj.RecordTypeId == hdString)
                {
                    mail.setSubject('HD/Acute产品赔付申请审批结果通知');
                    mail.setToAddresses(hdEmailAdressList);
                    mail.setHtmlBody(repBody);
                    mail.setSenderDisplayName('Salesforce');
                    if(hdEmailAdressList.size() > 0)
                    {
                        mlist.add(mail);
                    }
                }

                if(obj.RecordTypeId == acuteString)
                {
                    mail.setSubject('HD/Acute产品赔付申请审批结果通知');
                    mail.setToAddresses(acuteEmailAdressList);
                    mail.setHtmlBody(repBody);
                    mail.setSenderDisplayName('Salesforce');
                    if(acuteEmailAdressList.size() > 0)
                    {
                        mlist.add(mail);
                    }
                }
            }  
        }

        //发送
        if(mlist.size() != 0 )
        {
            system.debug('----->>>'+mlist);
            try{
                Messaging.sendEmail(mlist);
            }catch(Exception e){

            }
            
        }
    }  
    /************************/
    
}
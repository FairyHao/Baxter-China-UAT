/*
 *Author：Scott
 *Created on：2010-10-15
 *Description: 
 *参考大陆功能
 * Tommy 修改在2013-10-29 ：去掉对TW_RateHospGrade字段更新，此字段类型被修改为公式字段由客户自动带出
*/
public without sharing class BQ_CtrAddContact {
    //Account Id
    public String AccountId;
    //Page 1
    public Boolean IsPage1{get;set;}
    //Page 2
    public Boolean IsPage2{get;set;}
    //RecordTypeDeveloperName
    public String RtDevName{get;set;}
    public Boolean IsLock{get;set;}
    public Boolean IsEdit{get;set;}
    public Contact_Mod__c curContact{get;set;}
    public String CurrentContactId{get;set;}//联系人Id
    //记录类型
    public list<SelectOption> getRecordTypelist()
    {
        List<String>RecordTypelist = new List<String>();
        list<SelectOption> options=new list<SelectOption>();
        options.add(new SelectOption('BQ_New','新增'));
        options.add(new SelectOption('BQ_Update','修改'));
        return options;
    }
    //如果是编辑选择联系人
    public List<SelectOption> ContactOption {get;set;}
    //联系人Id
    public Id contactId {get;set;}
    public BQ_CtrAddContact(ApexPages.StandardController controller)
    {
        IsPage1 = true;
        IsPage2 = false;
        IsLock = false;
        IsEdit = false;
        
        curContact = (Contact_Mod__c)controller.getRecord();
        //修改申请上编辑按钮操作（ 联系人修改申请编辑按钮传参）
        String curContactId = ApexPages.currentPage().getParameters().get('conid');
        if( curContactId!= null)
        {
            curContact=[select  Contact_Type__c ,Type__c ,Name__c,RecordType.DeveloperName,OwnerId,NewContact__c,
                        Account__c ,Phone__c,Mobile__c,Email__c ,Fax__c,Birthday__c ,Comment__c,Gender__c ,
                        V2_interest__c,V2_RateLeadership__c,V2_OfficerNo__c ,Graduate_College__c,BQ_TotalScore__c,
                        V2_PassPortNo__c ,ID_card2__c,BQ_Administrative_level__c,BQ_RateLeadership__c,V2_RenalGrade__c,
                        BQ_CampaignType__c,BQ_Job__c,BQ_RateBeds__c,BQ_RateTitle__c,BQ_Beds_turnover_days__c,
                        BQ_Relationship__c,BQ_Nutritional_habits__c,BQ_Business_scale__c,BQ_Selective_fat__c,
                        BQ_Education__c,BQ_Research_expertise__c,BQ_Nutrition_proportion__c,BQ_Academic_status__c,
                        BQ_Choose_fat__c,BQ_Companies_cooperation__c,Status__c,BQ_Presentation_skills__c
                        from Contact_Mod__c c where Id=:curContactId];
            if(curContact.Status__c!='新建'&&curContact.Status__c!='拒绝')
            {
                    IsPage1 = false;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error , '记录锁定，记录正在审批中或已审批通过不能编辑！');            
                    ApexPages.addMessage(msg);
                    IsLock =true;
                    return;
            }
            IsPage2 = true;
            IsPage1 = false;
            return;
        }
        else
        {
            AccountId = ApexPages.currentPage().getParameters().get('accid');
            curContact.Account__c= AccountId;
            curContact.Status__c = '新建';
            /*==============14-4-9修改 新建按钮加入联系人Id传参：在联系人下新建时传入联系人Id===================*/
            CurrentContactId = ApexPages.currentPage().getParameters().get('CurrentContactId');
            /*==============14-4-9修改 新建按钮加入联系人Id传参===================*/
        }
        
        if(AccountId ==null || AccountId=='')
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning , '无法生成编辑页面，请重新操作。');            
            ApexPages.addMessage(msg);
            return;
        }
        
        
    }
    public boolean IsTalkIsLock{get;set;}//2014/11/11 Amy 讲者字段是否可编辑
    //点击继续按钮
    public void PageContinue()
    {
        IsPage2 = true;
        IsPage1 = false;
      BQContactFieldEditSet__c temp=[select BQ_EditLock__c,BQ_NewLock__c from BQContactFieldEditSet__c where name='讲者'][0];//从自定义设置表中取出讲者字段是否可编辑信息。
     
        try
        {
            if(RtDevName =='BQ_New')
            {
                //联系人上新增
                curContact.Type__c = '新增';
                curContact.RecordTypeId = getRecordTypeById(RtDevName);
                IsTalkIsLock=temp.BQ_NewLock__c;//2014/11/11 Amy 讲者字段是否可编辑
            }
            else if(RtDevName =='BQ_Update')
            {
                IsTalkIsLock=temp.BQ_EditLock__c;//2014/11/11 Amy 讲者字段是否可编辑
                curContact.Type__c='修改';
                curContact.RecordTypeId = getRecordTypeById(RtDevName);
                IsEdit = true;
                //客户上新建编辑记录类型
                if(curContact.Name__c ==null)
                {
                    ContactOption = new List<SelectOption>();
                    List<Contact> conlist = [select Id,Name from Contact where AccountId =:AccountId];
                    if(conlist !=null && conlist.size()>0)
                    {
                        for(Contact con: conlist)
                        {
                            ContactOption.add(new SelectOption(con.Id,con.Name));
                        }
                        //默认显示第一个联系人信息
                        /*==============14-4-9修改：如果CurrentContactId不为空默认显示当前联系人信息===================*/
                        if(CurrentContactId != null &&  CurrentContactId!='')
                        {
                            contactId = CurrentContactId;
                            Contact con = getContact(CurrentContactId);
                            SetContactPage(con,curContact);
                        }
                        else
                        {
                            Contact con = getContact(conlist[0].Id);
                            SetContactPage(con,curContact);
                        }
                        /*==============14-4-9修改===============*/
                    }
                    else
                    {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning , '当前客户下沒有联系人信息！');            
                        ApexPages.addMessage(msg);
                        IsLock =true;
                        return;
                    }
                }
            }
            else
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning , '无法生存编辑页面，记录类型选择错误。');            
                ApexPages.addMessage(msg);
                IsLock =true;
                return;
            }
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , String.valueOf(e)+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
        
        
    }
    /*
    *获取联系人信息
    */
     public Contact getContact(Id id)
        
     {
        if(id == null)
        {
            return null;
        }  
        Contact contact = [Select Id,Name,RecordTypeId,AccountId,LastName,Phone ,Gender__c ,MobilePhone ,ContactType__c ,Email ,Fax ,V2_OfficerNo__c ,Birthdate ,GraduateCollege__c ,V2_PassPortNo__c ,interest__c ,ID_card__c  ,BQ_Administrative_level__c ,Description ,BQ_RateLeadership__c ,V2_RenalGrade__c ,BQ_CampaignType__c ,BQ_Job__c ,BQ_RateBeds__c ,BQ_RateTitle__c ,BQ_Beds_turnover_days__c ,BQ_Relationship__c ,BQ_Nutritional_habits__c ,BQ_Business_scale__c ,BQ_Selective_fat__c ,BQ_Education__c ,BQ_Research_expertise__c ,BQ_Nutrition_proportion__c ,BQ_Academic_status__c ,BQ_Choose_fat__c ,BQ_Companies_cooperation__c ,BQ_Presentation_skills__c ,BQ_TotalScore__c
        ,V2_DepartmentType__c,IsTalker__c,BQ_Beds__c,ParenteralNutrition__c,BQ_BQ__c
          From Contact c where Id =: id];
        return contact;
     }
     /*
      *获取客户下的联系人列表信息
     */ 
    public void getContactInfo() 
    {
        System.debug(contactId+'contactId*****************');
        Contact con = getContact(contactId);
        System.debug(con.V2_DepartmentType__c+'V2_DepartmentType__c****************');
        SetContactPage(con,curContact);
    }
     /*
     *设置页面联系人信息
     */
     public void SetContactPage(Contact contact,Contact_Mod__c curContact){
        try
        {
            if(contact==null)return;
            /******************联系人信息********************/
            //Name
            curContact.Name__c = contact.Id;
            //客户
            curContact.Account__c = contact.AccountId;
            //姓名
            curContact.NewContact__c = contact.Name;
            //电话
            curContact.Phone__c = contact.Phone;
            //性别
            //Gender
            curContact.Gender__c = contact.Gender__c;
            //手机
            curContact.Mobile__c = contact.MobilePhone;
            //联系人类别
            curContact.Contact_Type__c = contact.ContactType__c;
            //电子邮件
            curContact.Email__c = contact.Email;
            //传真
            curContact.Fax__c = contact.Fax;
            //军管号   
            curContact.V2_OfficerNo__c = contact.V2_OfficerNo__c;
            //出生日期
            curContact.Birthday__c = contact.Birthdate;
            //毕业院校
            curContact.Graduate_College__c = contact.GraduateCollege__c;
            //护照号
            curContact.V2_PassPortNo__c = contact.V2_PassPortNo__c;
            //兴趣爱好
            curContact.V2_interest__c = contact.interest__c;
            //身份证号
            curContact.ID_card2__c =  contact.ID_card__c;
            //行政级别
            curContact.BQ_Administrative_level__c = contact.BQ_Administrative_level__c;
            //备注
            curContact.Comment__c = contact.Description;
            /*********************其他信息************************/
            //影响力(BQ)
            curContact.BQ_RateLeadership__c = contact.BQ_RateLeadership__c;
            //级别
            curContact.V2_RenalGrade__c = contact.V2_RenalGrade__c;
            //市场细分类型
            curContact.BQ_CampaignType__c = contact.BQ_CampaignType__c;
            //职务(BQ)
            curContact.BQ_Job__c = contact.BQ_Job__c;
            //负责床位数比例(BQ)
            curContact.BQ_RateBeds__c = contact.BQ_RateBeds__c;
            //职称(BQ)
            curContact.BQ_RateTitle__c = contact.BQ_RateTitle__c;
            //床位周转天数
            curContact.BQ_Beds_turnover_days__c = contact.BQ_Beds_turnover_days__c;
            //与BQ的关系
            curContact.BQ_Relationship__c = contact.BQ_Relationship__c;
            //肠外营养处方习惯
            curContact.BQ_Nutritional_habits__c = contact.BQ_Nutritional_habits__c; 
            //BQ业务规模
            curContact.BQ_Business_scale__c = contact.BQ_Business_scale__c;
            //脂肪乳的选择影响因素
            curContact.BQ_Selective_fat__c = contact.BQ_Selective_fat__c;
            //学术程度(BQ)
            curContact.BQ_Education__c = contact.BQ_Education__c;
            //在脂肪乳的多腔袋中的研究专长
            curContact.BQ_Research_expertise__c = contact.BQ_Research_expertise__c;
            //使用肠外营养的比例
            curContact.BQ_Nutrition_proportion__c = contact.BQ_Nutrition_proportion__c;
            //学术地位
            curContact.BQ_Academic_status__c = contact.BQ_Academic_status__c;
            //脂肪乳的选择
            curContact.BQ_Choose_fat__c = contact.BQ_Choose_fat__c;
            //喜好合作的公司
            curContact.BQ_Companies_cooperation__c = contact.BQ_Companies_cooperation__c;
            //演讲技巧
            curContact.BQ_Presentation_skills__c = contact.BQ_Presentation_skills__c;
            //科室
            curContact.V2_DepartmentType__c = contact.V2_DepartmentType__c;
            //讲者
            curContact.IsTalker__c = contact.IsTalker__c;
            //负责床位数
            curContact.BQ_Beds__c = contact.BQ_Beds__c;
            curContact.ParenteralNutrition__c = contact.ParenteralNutrition__c;
            curContact.BQ_BQ__c = contact.BQ_BQ__c;
            System.debug(curContact.V2_DepartmentType__c+'V2_DepartmentType__c&&&&&&&&&&&&&&&&&&');
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning , e.getMessage());            
            ApexPages.addMessage(msg);
            return;
        }
    } 
     /*
     *保存
    */
    public PageReference SaveContactMod() 
    {
        Try{
            //检查姓名是否符合要求
            if(curContact.NewContact__c != null && (curContact.NewContact__c.contains('院长') || curContact.NewContact__c.contains('医生') || curContact.NewContact__c.contains('护士')
              || curContact.NewContact__c.contains('科长') || curContact.NewContact__c.contains('主任') || curContact.NewContact__c.contains('老师')
              || curContact.NewContact__c.contains('护士长') || curContact.NewContact__c.contains('先生') || curContact.NewContact__c.contains('小姐')
              || curContact.NewContact__c.contains('大夫') || curContact.NewContact__c.contains('护长') || curContact.NewContact__c.contains('药师')))
            {
                curContact.NewContact__c.addError('您填写的姓名不符合要求，姓名中不能包含：院长、医生、护士、科长、主任、老师、护士长、先生、小姐、大夫、护长、药师，这类称谓词');
                return null;
            }
            //检查是否重名
            Integer flag = 0;
            for(Contact con: [select Id,Name from Contact where AccountId =: AccountId])
            {
                if(curContact.Name__c != null && con.Id == curContact.Name__c)
                {
                    continue;
                }
                if(curContact.NewContact__c == con.Name)
                {
                    flag++;
                }
            }
            if(flag >0)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning , '当前客户下已经存在联系人：'+curContact.NewContact__c+'，请核实后再操作！');            
                ApexPages.addMessage(msg);
                return null;
            }
            //curContact.BQ_TotalScore__c = ComputeDoctorScore(curContact);
            if(curContact.Id == null)
            {
                insert curContact;
            }
            else
            {
                update curContact;
            }
            
            //自动提交审批
            //提交审批
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(curContact.id);//客户联系人或自定义对象
            Approval.ProcessResult result = Approval.process(req);
        
        }Catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Warning , ex.getMessage());            
            ApexPages.addMessage(msg);
            return null;
            
        }
            PageReference pageRef = new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+curContact.Id);
            return pageRef;
    }
    /*
     *返回
    */
    public PageReference Cancel()
    {
        PageReference pageRef = new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+AccountId);
        return pageRef;
    }
    //职称分数映射
    public map<string,double> map_BQ_RateTitle_Score
    {
        get
        {
            map<string,double> temp = new map<string,integer>();
            temp.put('进修',1);
            temp.put('住院医师',3);
            temp.put('主治',5);
            temp.put('副主任医师、副教授',7);
            temp.put('主任医师、教授',10);
            return temp;
        }
        set;
    }
    //学术程度分数映射
    public map<string,double> map_BQ_Education_Score
    {
        get
        {
            map<string,double> temp = new map<string,integer>();
            temp.put('国家级',10);
            temp.put('省级',7);
            temp.put('地级',5);
            return temp;
        }
        set;
    }
    //床位周转天数分数映射
    public map<string,double> map_BQ_Beds_turnover_days_Score
    {
        get
        {
            map<string,double> temp = new map<string,integer>();
            temp.put('5-10天',10);
            temp.put('11-15天',8);
            temp.put('16-20天',6);
            temp.put('21-25天',4);
            temp.put('26-30天',2);
            return temp;
        }
        set;
    }
    //百分比分数映射
    public map<string,double> map_Percent_Score
    {
        get
        {
            map<string,double> temp = new map<string,double>();
            temp.put('10%',0.1);
            temp.put('20%',0.2);
            temp.put('30%',0.3);
            temp.put('40%',0.4);
            temp.put('50%',0.5);
            temp.put('60%',0.6);
            temp.put('70%',0.7);
            temp.put('80%',0.8);
            temp.put('90%',0.9);
            temp.put('100%',1.0);
            return temp;
        }
        set;
    }
    /*
    * 医生总分计算
    */
    public double ComputeDoctorScore(Contact_Mod__c curContact)
    {
        double TotalScore = 0;
        //职称
        if(curContact.BQ_RateTitle__c != null 
        && curContact.BQ_RateTitle__c != '' 
        && map_BQ_RateTitle_Score.containsKey(curContact.BQ_RateTitle__c))
        {
            TotalScore += map_BQ_RateTitle_Score.get(curContact.BQ_RateTitle__c);
        }
        //学术程度
        if(curContact.BQ_Education__c != null 
        && curContact.BQ_Education__c != '' 
        && map_BQ_Education_Score.containsKey(curContact.BQ_Education__c))
        {
            TotalScore += map_BQ_Education_Score.get(curContact.BQ_Education__c);
        }
        //影响力
        if(curContact.BQ_RateLeadership__c != null 
        && curContact.BQ_RateLeadership__c != '' )
        {
            TotalScore += integer.valueOf(curContact.BQ_RateLeadership__c);
        }
        //与BQ的关系
        if(curContact.BQ_Relationship__c != null 
        && curContact.BQ_Relationship__c != '' )
        {
            TotalScore += integer.valueOf(curContact.BQ_Relationship__c);
        }
        //BQ业务规模
        if(curContact.BQ_Business_scale__c != null 
        && curContact.BQ_Business_scale__c != '' )
        {
            TotalScore += integer.valueOf(curContact.BQ_Business_scale__c);
        }
        //负责床位数比例
        if(curContact.BQ_RateBeds__c != null 
        && curContact.BQ_RateBeds__c != '' 
        && map_Percent_Score.containsKey(curContact.BQ_RateBeds__c))
        {
            TotalScore += map_Percent_Score.get(curContact.BQ_RateBeds__c)*15.0;
        }
        //床位周转天数比例
        if(curContact.BQ_Beds_turnover_days__c != null 
        && curContact.BQ_Beds_turnover_days__c != '' 
        && map_BQ_Beds_turnover_days_Score.containsKey(curContact.BQ_Beds_turnover_days__c))
        {
            TotalScore += map_BQ_Beds_turnover_days_Score.get(curContact.BQ_Beds_turnover_days__c);
        }
        //使用肠外营养比例
        if(curContact.BQ_Nutrition_proportion__c != null 
        && curContact.BQ_Nutrition_proportion__c != '' 
        && map_Percent_Score.containsKey(curContact.BQ_Nutrition_proportion__c))
        {
            TotalScore += map_Percent_Score.get(curContact.BQ_Nutrition_proportion__c)*15.0;
            system.debug('*********xiaoshu***************'+map_Percent_Score.get(curContact.BQ_Nutrition_proportion__c)*15.0);
        }
        return TotalScore;
    }
    /*
    *根据记录类型developername找到id
    */
    public Id getRecordTypeById(String DevName){
        Id ret=null;
        List<RecordType> rts = [SELECT Id,DeveloperName  FROM RecordType WHERE SObjectType = 'Contact_Mod__c' and IsActive=true and DeveloperName=:DevName];
        if ( rts != null && rts.size() > 0 ) 
        {
             ret = rts[0].Id;
        }
        return ret;
    }
    /****************************************************Test*********************************/
    static testMethod void BQ_CtrAddContact()
    {
        /*客户*/
        RecordType accrecordtype = [select Id from RecordType where DeveloperName='RecordType' and SobjectType='Account' limit 1];
        Account acc = new Account();
        acc.RecordTypeId = accrecordtype.Id;
        acc.Name = 'AccTest';
        insert acc;
        /*联系人*/
        RecordType conrecordtype = [select Id from RecordType where DeveloperName = 'BQ_Contact' and SobjectType='Contact' and IsActive = true limit 1 ];
        Contact con1 = new Contact();
        con1.RecordTypeId = conrecordtype.Id;
        con1.LastName = 'AccTestContact1';
        con1.AccountId=acc.Id;
        insert con1;
        
        //自定义设置 2014/11/12ByAmy
        BQContactFieldEditSet__c BQContactFieldEditSet=new BQContactFieldEditSet__c();
        BQContactFieldEditSet.Name='讲者';
        Insert BQContactFieldEditSet;
        
        //联系人修改申请记录类型
        List<RecordType> rtlist = [select Id,DeveloperName from RecordType where SObjectType = 'Contact_Mod__c' 
                                    and (DeveloperName='BQ_New' or DeveloperName='BQ_Update') and IsActive=true ];
        //联系人修改申请
        Contact_Mod__c cminsertCon = new Contact_Mod__c();
        cminsertCon.RecordTypeId = rtlist[0].Id;
        insert cminsertCon;
        
        system.Test.startTest();
        ApexPages.currentPage().getParameters().put('conid',cminsertCon.Id);
        ApexPages.StandardController STconSPCon1 = new ApexPages.StandardController( new Contact_Mod__c());
        BQ_CtrAddContact cacSPCon1 = new BQ_CtrAddContact(STconSPCon1);
        cacSPCon1.getRecordTypelist();
        cminsertCon.Status__c='新建';
        update cminsertCon;
        BQ_CtrAddContact cacSPCon11 = new BQ_CtrAddContact(STconSPCon1);
        
        ApexPages.currentPage().getParameters().put('conid',null);
        ApexPages.currentPage().getParameters().put('accid',null);
        BQ_CtrAddContact cacSPCon21 = new BQ_CtrAddContact(STconSPCon1);
        
        ApexPages.currentPage().getParameters().put('accid',acc.Id);
        BQ_CtrAddContact cacSPCon2 = new BQ_CtrAddContact(STconSPCon1);
        cacSPCon2.RtDevName ='BQ_New';
        cacSPCon2.PageContinue();
        cacSPCon2.SaveContactMod();
        cacSPCon2.curContact.NewContact__c = 'AccTestContact1';
        cacSPCon2.SaveContactMod();
        cminsertCon.BQ_RateTitle__c='进修';
        cminsertCon.BQ_Education__c = '国家级';
        cminsertCon.BQ_RateLeadership__c = '1';
        cminsertCon.BQ_Relationship__c = '1';
        cminsertCon.BQ_Business_scale__c = '1';
        cminsertCon.BQ_RateBeds__c ='10%';
        cminsertCon.BQ_Beds_turnover_days__c ='5-10天';
        cminsertCon.BQ_Nutrition_proportion__c ='10%';
        cacSPCon2.ComputeDoctorScore(cminsertCon);
        
        BQ_CtrAddContact cacSPCon3 = new BQ_CtrAddContact(STconSPCon1);
        cacSPCon2.curContact.NewContact__c = '222';
        cacSPCon3.RtDevName ='BQ_Update';
        cacSPCon3.PageContinue();
        cacSPCon3.SaveContactMod();
        cacSPCon3.RtDevName ='BQ_Update';
        cacSPCon3.PageContinue();
        system.Test.stopTest();
        
        
    }
}
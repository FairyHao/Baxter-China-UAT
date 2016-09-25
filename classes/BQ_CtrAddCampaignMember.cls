/*
Author：Tobe
Created on：2014-01-13
Description: 
*/
public with sharing class BQ_CtrAddCampaignMember {
    public String CampaignIds{get;set;}
    public List<SobjCampaignMember> ListSobjCam = new List<SobjCampaignMember>();
    public Map<Id,String> contactmap = new Map<Id,String>();
    //public Boolean disabled{get;set;}
    public Boolean IsClose{get;set;}
    //当前用户角色Id
    public Id CurrentRoleId{get;set;}
    //当前用户角色名称
    public String CurrentRoleName{get;set;}
    //当前用户Id
    public Id CurrentUserId{get;set;}
    public String CurrentProfileName{get;set;}
    //所有提交人Ids
    public Set<Id> SubmitUserIds = new Set<Id>();
    //大区角色IDs
    public Set<Id> RegionalIds = new Set<Id>();
    //角色及其上级角色
    public Map<Id,Id> RoleIdMap = new Map<Id,Id>();
    //提交人主管角色ids
    public Set<Id> ManagerRoleId = new Set<Id>();
    //大区角色用户及其邮箱 key:大区角色Id value：邮箱
    public Map<Id,String> RoleIdUserEmailMap = new Map<Id,String>();
    //用户及其大区经理email
    public Map<Id,String> UserRegionalMap = new Map<Id,String>();
    //用户对应其上级主管角色Id
    public Map<Id,List<Id>> UserManagerMap = new Map<Id,List<Id>>();
    //主管Id及其email
    public Map<Id,String> ManagerEmailMap = new Map<Id,String>();
    //判断是否是市场部
    public Boolean IsMarketing{get;set;}
    //市场部邮箱
    public String MarketOwnerEmail{get;set;}
    //不需要逐级审批
    private Boolean IsNotapprovalBylevel{get;set;}
    
    //判断是否是SP销售
    public String SpSuper{get;set;}
    public String SpRegion{get;set;}
    
    public List<SobjCampaignMember> getListSobjCam()
    {
        return ListSobjCam;
    }
    public BQ_CtrAddCampaignMember()
    {
        
        IsClose=false;
        //disabled = false;
        //当前用户信息
        User u = [select UserRole.Name,Id,UserRoleId,Profile.Name from User where Id=:UserInfo.getUserId()];
        CurrentRoleName = u.UserRole.Name;
        CurrentUserId = u.Id;
        CurrentRoleId = u.UserRoleId;
        CurrentProfileName = u.Profile.Name;
        //判读是否是市场部如果是
        if((CurrentRoleName !=null && CurrentRoleName.contains('Marketing')) || CurrentProfileName=='BQ Admin')
        {
            IsMarketing = true;
        }
        else
        {
            IsMarketing = false;
        }
        //市场活动Id
        CampaignIds = ApexPages.currentPage().getParameters().get('camid');
        /*********************bill add 2013-8-5 start*********************************/
        //判断是否存在该市场活动
        Campaign CurrentCampaign = new Campaign();
        List<Campaign> list_CurrentCampaign = [select Owner.Email,IsNotapprovalBylevel__c,Registration_Starts_approval__c from Campaign where Id=:CampaignIds];
        if(list_CurrentCampaign != null && list_CurrentCampaign.size()>0)
        {
        	CurrentCampaign = list_CurrentCampaign[0];
        }else{
        	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '您所添加的市场活动不存在，请检查');            
            ApexPages.addMessage(msg);
            return;
        }
        /*********************bill add 2013-8-5 end*********************************/
       	MarketOwnerEmail = CurrentCampaign.Owner.Email;
        IsNotapprovalBylevel = CurrentCampaign.Registration_Starts_approval__c;
        for(CampaignMember cam: [select Campaign.Owner.Email,ContactId,Contact.Name,ID_card__c,MobilePhone__c from CampaignMember where CampaignId =: CampaignIds])
        {
            cam.MarketOwnerEmail__c = MarketOwnerEmail;
            
            contactmap.put(cam.ContactId,cam.Contact.Name);
        }
        
        CampaignMember cam = new CampaignMember();
        cam.MarketOwnerEmail__c = MarketOwnerEmail;
        SobjCampaignMember sc = new SobjCampaignMember();
        sc.IsDelete = false;
        sc.cm = cam;
        ListSobjCam.add(sc);
        
    }
    //添加
    public void AddCampaignMember()
    {
        CampaignMember cam = new CampaignMember();
        SobjCampaignMember sc = new SobjCampaignMember();
        sc.IsDelete = false;
        sc.cm = cam;
        ListSobjCam.add(sc);
    }
    //删除
    public void DeleteCampaignMember()
    {
        //新加联系人是否已经是市场活动成员
        for(Integer i=ListSobjCam.size()-1;i>=0;i-- )
        {
            if(ListSobjCam[i].IsDelete)
            {
                ListSobjCam.remove(i);
            }
        }
    }
    //保存
    public void SaveCampaignMember()
    {
        try
        {
            //如果当期用户是市场部的则将联系人Id存入set
            Set<Id> contactids = new Set<Id>();
            List<CampaignMember> insertCampaignMember = new List<CampaignMember>();
            List<CampaignMember> insertCM = new List<CampaignMember>();
            for(SobjCampaignMember scm:ListSobjCam)
            {
                CampaignMember cam = scm.cm;
                if(cam.ContactId ==null)
                {
                    continue;   
                }
                //如果是市场部
                if(IsMarketing && cam.User__c != null)
                {
                    cam.CampaignId = CampaignIds; 
                    if(scm.ArriveDate != null && scm.ArriveDate !='')
                    {
                        cam.V2_ArriveDate__c = Date.valueOf(scm.ArriveDate);
                    }
                    if(scm.DepartDate != null && scm.DepartDate != '')
                    {
                        cam.V2_DepartDate__c = Date.valueOf(scm.DepartDate);
                    }
                    cam.V2_Participated__c = true;
                    cam.V2_MarketingApprove__c = '通过';
                    insertCampaignMember.add(cam);
                    //提交人Id
                    SubmitUserIds.add(cam.User__c);
                    //提交人
                }
                else
                {
                    cam.CampaignId = CampaignIds; 
                    cam.User__c = CurrentUserId;
                    if(scm.ArriveDate != null && scm.ArriveDate !='')
                    {
                        cam.V2_ArriveDate__c = Date.valueOf(scm.ArriveDate);
                    }
                    if(scm.DepartDate != null && scm.DepartDate != '')
                    {
                        cam.V2_DepartDate__c = Date.valueOf(scm.DepartDate);
                    }
                    insertCampaignMember.add(cam);
                    //提交人Id
                    SubmitUserIds.add(CurrentUserId);
                    //提交人
                }
            }
            if(insertCampaignMember !=null && insertCampaignMember.size()>0)
            {
                //市场部角色信息、大区角色信息、角色层级关系
                this.getRoleInfo();
                //当前市场活动成员信息
                this.getSubmitUserInfo();
                //获取提交人主管信息
                this.getManagerEmail();
            }
            //遍历所有新加市场活动成员
            for(CampaignMember cm:insertCampaignMember)
            {
            	//2013-6-3Sunny 添加此if判断，用于判断如果此市场活动不需要逐级审批，则不要设置主管和大区审批内容
            	if(this.IsNotapprovalBylevel == false)
            	{
            		
                    //大区经理邮件地址
                    if(UserRegionalMap.containsKey(cm.User__c))
                    {
                        cm.V2_RegionalUserEmail__c = UserRegionalMap.get(cm.User__c);
                    }
                    //提交人及对应主管
                    if(UserManagerMap.containsKey(cm.User__c))
                    {
                        List<Id> managerIds = UserManagerMap.get(cm.User__c);
                        //各主管邮件地址
                        for(Integer i=0;i<managerIds.size();i++)
                        {
                            if(i==0 && ManagerEmailMap.containsKey(managerIds[0]))
                            {
                                cm.V2_ManagerEmail1__c = ManagerEmailMap.get(managerIds[0]);
                            }
                            else if(i==1 && ManagerEmailMap.containsKey(managerIds[1]))
                            {
                                cm.V2_ManagerEmail2__c = ManagerEmailMap.get(managerIds[1]);
                            }
                            else if(i==2 && ManagerEmailMap.containsKey(managerIds[2]))
                            {
                                cm.V2_ManagerEmail3__c = ManagerEmailMap.get(managerIds[2]);
                            }
                            else if(i==3 && ManagerEmailMap.containsKey(managerIds[3]))
                            {
                                cm.V2_ManagerEmali4__c = ManagerEmailMap.get(managerIds[3]);
                            }
                            else if(i==4 && ManagerEmailMap.containsKey(managerIds[4]))
                            {
                                cm.V2_ManagerEmail5__c = ManagerEmailMap.get(managerIds[4]);
                            }
                            else if(i==5 && ManagerEmailMap.containsKey(managerIds[5]))
                            {
                                cm.V2_ManagerEmail6__c = ManagerEmailMap.get(managerIds[5]);
                            }
                            else if(i==6 && ManagerEmailMap.containsKey(managerIds[6]))
                            {
                                cm.V2_ManagerEmail7__c = ManagerEmailMap.get(managerIds[6]);
                            }
                            else if(i==7 && ManagerEmailMap.containsKey(managerIds[7]))
                            {
                                cm.V2_ManagerEmail8__c = ManagerEmailMap.get(managerIds[7]);
                            }
                        }
                    }
            	}
                insertCM.add(cm);
            }
            if(insertCM != null && insertCM.size()>0)
            {
                insert insertCM;
            }
            IsClose = true;
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , String.valueOf(e)+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
    }
    //判断是否已经存在此联系人信息
    public void CheckContact()
    {
        system.debug(contactmap+'Herere1'+ListSobjCam);
        //判断新加联系人是否已经是市场活动成员
        if(contactmap != null && contactmap.size()>0)
        {
            for(SobjCampaignMember scm:ListSobjCam)
            {
                if(scm.cm.ContactId == null)
                {
                    continue;
                }
                if(contactmap.containsKey(scm.cm.ContactId))
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '已经将联系人  ’'+contactmap.get(scm.cm.ContactId)+'‘ 添加为市场活动成员，不允许重复添加为市场活动成员,已将新加重复联系人清空！');            
                    ApexPages.addMessage(msg);
                    scm.cm.ContactId = null;
                    return;
                }
            }
        }
        system.debug('Herere1'+ListSobjCam);
        //判断同一联系人是否为多次添加
        if(ListSobjCam != null && ListSobjCam.size()>1)
        {
            for(Integer i=ListSobjCam.size()-1;i>=0;i--)   
            {
                Integer flag=0;
                for(SobjCampaignMember scm2 : ListSobjCam)
                {
                    if(scm2.cm.ContactId == ListSobjCam[i].cm.ContactId)
                    {
                        flag++;
                    }
                }
                if(flag >=2)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '同一联系人，不允许重复添加为市场活动成员,已将新加重复联系人清空。 ');            
                    ApexPages.addMessage(msg);
                    ListSobjCam[i].cm.ContactId = null;
                    return;
                }
            }
        }
        //显示联系人客户名称
        Set<Id> contactids = new Set<Id>();
        for(SobjCampaignMember scm:ListSobjCam)
        {
            if(scm.cm.ContactId != null )
            {
                contactids.add(scm.cm.ContactId);
            }
        }
        system.debug('HERERER:'+contactids);
        for(Contact co:[select AccountId,Id,ID_card__c,MobilePhone from Contact where id in:contactids])
        {
            for(SobjCampaignMember scm:ListSobjCam)
            {
                if(scm.cm.ContactId == co.Id)
                {
                    scm.cm.V2_Account__c = co.AccountId;
                    scm.cm.ID_card__c = co.ID_card__c;
					scm.cm.MobilePhone__c = co.MobilePhone;
                }
            }
        }
        // 如果是市场部的则要根据联系人显示 其所属客户下 的客户小组
        if(IsMarketing)
        {
            getUserlist();
        }
    }
    //通过客户得出其下的客户小组成员
    public void getUserlist()
    {
        try
        {
            //客户Ids
            Set<Id> AccIds = new Set<Id>();
            for(SobjCampaignMember scm:ListSobjCam)
            {
                if(scm.cm.V2_Account__c ==null)
                {
                    continue;
                }
                AccIds.add(scm.cm.V2_Account__c);
            }
            for(SobjCampaignMember scm:ListSobjCam)
            {
                list<SelectOption> AccMembers=new list<SelectOption>();
                for(AccountTeamMember atm:[Select User.Name,UserId,AccountId From AccountTeamMember where AccountId in:AccIds])
                {
                    if(atm.AccountId != scm.cm.V2_Account__c)
                    {
                        continue;
                    }
                    AccMembers.add(new SelectOption(atm.UserId,atm.User.Name));
                }
                scm.UserList = AccMembers;
            }
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , String.valueOf(e)+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
        
    }
    //市场部角色信息、大区角色信息、角色层级关系,大区角色及用户Id
    public void getRoleInfo()
    {
        try
        {
            for(UserRole ur:[select ParentRoleId,Id,Name from UserRole])
            {
                //角色是大区的 角色Id
                if(ur.Name.contains('Regional'))
                {
                    RegionalIds.add(ur.Id);
                }
                //每个角色及其上级角色装入Map
                RoleIdMap.put(ur.Id,ur.ParentRoleId);
            }
            //大区角色及此角色拥有邮箱
            for(User u:[select Email,UserRoleId from User where UserRoleId in: RegionalIds and IsActive= true])
            {
                RoleIdUserEmailMap.put(u.UserRoleId,u.Email);
            }
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , String.valueOf(e)+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
    }
    //当前市场活动成员信息
    public void getSubmitUserInfo()
    {
        try
        {   
            for(User us:[select UserRoleId,Id from User where Id in:SubmitUserIds])
            {
                if(us.UserRoleId == null)
                {
                    continue;
                }
                getSuperiorRoleId(us.UserRoleId,us.Id);
            }
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , String.valueOf(e)+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
    }
    //向上追溯提交的角色信息
    public void getSuperiorRoleId(Id roleId,Id userid)
    {
        try
        {
            if(RoleIdMap.containsKey(roleId))
            {
                //得到上级Id
                Id srid = RoleIdMap.get(roleId);
                //判断是否有上级
                if(srid==null)
                {
                    return;
                }
                //如果已经向上追溯到 大区 则停止向上追溯
                if(RoleIdUserEmailMap.containsKey(srid))
                {
                    String managerEmail = RoleIdUserEmailMap.get(srid);
                    UserRegionalMap.put(userid,managerEmail);
                    return;
                }
                //将其上级角色Id放入set中， 即为提交人的所有主管
                else
                {
                    ManagerRoleId.add(srid);
                    if(UserManagerMap.containsKey(userid))
                    {
                        List<Id> ManagerRoleIds = UserManagerMap.get(userid);
                        ManagerRoleIds.add(srid);
                        UserManagerMap.put(userid,ManagerRoleIds);
                    }
                    else
                    {
                        List<Id> ManagerRoleIds = new List<Id>();
                        ManagerRoleIds.add(srid);
                        UserManagerMap.put(userid,ManagerRoleIds);
                    }
                    getSuperiorRoleId(srid,userid);
                }
            }
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , String.valueOf(e)+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
        
    }
    //Manager邮件地址
    public void getManagerEmail()
    {
        try
        {
            for(User manager:[select Email,UserRoleId from User where UserRoleId in:ManagerRoleId and IsActive = true])
            {
                if(manager.Email != null && manager.Email != '')
                {
                    ManagerEmailMap.put(manager.UserRoleId,manager.Email);
                }
            }
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , String.valueOf(e)+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
    }
    //封装类
    public class SobjCampaignMember
    {
        public Id UserId{get;set;}
        public List<SelectOption>UserList{get;set;}
        public CampaignMember cm {get;set;}
        public Boolean IsDelete{get;set;}
        public String DepartDate{get;set;}
        public String ArriveDate{get;set;}
    }
    static testMethod void V2_CtrlAddCampaignMember()
    {
        /*客户*/
        RecordType accrecordtype = [select Id from RecordType where Name='医院' and SobjectType='Account' limit 1];
        Account acc = new Account();
        acc.RecordTypeId = accrecordtype.Id;
        acc.Name = 'AccTest';
        insert acc;
        /*客户小组*/
        User repuser = [select UserRole.Name,Id,Renal_valid_super__c,Department from User 
                        //已启用用户
                        Where IsActive = true 
                        //未休假用户
                        and IsOnHoliday__c =false
                        //未离职用户
                        and IsLeave__c = false
                        //角色不能为空
                        and UserRoleId !=null
                        and UserRole.Name != null 
                        and ManagerId != null limit 1];
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = acc.Id;
        atm.UserId = repuser.Id;
        insert atm;
        /*联系人*/
        RecordType conrecordtype = [select Id from RecordType where Name = 'Renal' and SobjectType='Contact' and IsActive = true limit 1 ];
        Contact con1 = new Contact();
        con1.LastName = 'AccTestContact1';
        con1.AccountId=acc.Id;
        insert con1;
        
        Contact con2 = new Contact();
        con2.LastName = 'AccTestContact2';
        con2.AccountId=acc.Id;
        insert con2;
        
        /*市场活动*/
        Campaign cam = new Campaign();
        cam.Name = 'CamTest';
        cam.StartDate = date.today().addMonths(1);
        cam.EndDate = date.today().addMonths(2);
        cam.IsActive = true;
        insert cam;
        
        Campaign cam2 = new Campaign();
        cam2.Name = 'CamTest2';
        cam2.StartDate = date.today().addMonths(1);
        cam2.EndDate = date.today().addMonths(2);
        cam2.IsActive = true;
        insert cam2;
        /*市场活动成员*/
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cam.Id;
        cm.ContactId = con2.Id;
        insert cm;
        
        Test.startTest();
        //当前用户Id
        Id CurrentUserId = UserInfo.getUserId();
        
        
        ApexPages.currentPage().getParameters().put('camid',cam.Id);
        BQ_CtrAddCampaignMember cacm = new BQ_CtrAddCampaignMember();
        //添加
        cacm.AddCampaignMember();
        //删除
        cacm.AddCampaignMember();
        SobjCampaignMember scm = cacm.getListSobjCam()[cacm.getListSobjCam().size()-1];
        scm.IsDelete = true;
        cacm.DeleteCampaignMember();
        //检查联系人
        cacm.AddCampaignMember();
        SobjCampaignMember scm1 = cacm.getListSobjCam()[cacm.getListSobjCam().size()-1];
        scm1.cm.ContactId = con1.Id;
        scm1.DepartDate = String.valueOf(Date.today());
        scm1.ArriveDate = String.valueOf(Date.today().addDays(5));
        cacm.CheckContact();
        //相同联系人报错
        cacm.AddCampaignMember();
        SobjCampaignMember scm2 = cacm.getListSobjCam()[cacm.getListSobjCam().size()-1];
        scm2.cm.ContactId = con1.Id;
        try
        {
            cacm.CheckContact();
        }catch(Exception e)
        {
            System.debug('相同联系人报错'+String.valueOf(e));
        }
        //保存
        cacm.SaveCampaignMember();
        /**市场部添加**/
        User MarketUser ;
        for(User u:[select UserRole.Name,Id,UserRoleId,Renal_valid_super__c,Department from User 
                    //已启用用户
                    Where IsActive = true 
                    //未休假用户
                    and IsOnHoliday__c =false
                    //未离职用户
                    and IsLeave__c = false
                    //角色不能为空
                    and UserRoleId !=null
                    and UserRole.Name != null])
        {
            if(MarketUser != null)
            {
            break;
            }
            if(u.UserRole.Name.contains('Marketing'))
            {
                MarketUser = u;
            }
        }
        System.runAs(MarketUser)
        {
        	 Contact con3 = new Contact();
        	con3.LastName = 'AccTestContact3';
        	con3.AccountId=acc.Id;
        	insert con3;
        	
        	Campaign cam3 = new Campaign();
        	cam3.Name = 'CamTest3';
        	cam3.StartDate = date.today().addMonths(1);
        	cam3.EndDate = date.today().addMonths(2);
        	cam3.IsActive = true;
        	insert cam3;
        
            ApexPages.currentPage().getParameters().put('camid',cam3.Id);
            BQ_CtrAddCampaignMember cacm3 = new BQ_CtrAddCampaignMember();
            
            //cacm3.CurrentRoleName = MarketUser.UserRole.Name;
            //cacm3.CurrentRoleId = MarketUser.UserRoleId;
            //添加
            cacm3.AddCampaignMember();
            SobjCampaignMember scm3 = cacm3.getListSobjCam()[cacm3.getListSobjCam().size()-1];
            scm3.ArriveDate  = String.valueOf(date.today());
            scm3.DepartDate = String.valueOf(date.today().addDays(-2));
            scm3.cm.ContactId = con1.Id;
            scm3.cm.User__c = repuser.Id;
            scm3.cm.V2_Account__c = acc.Id;
            cacm3.CheckContact();
            //客户小组成员
            cacm3.getUserlist();
            //角色信息
            cacm3.getRoleInfo();
            //市场活动成员信息
            cacm3.getSubmitUserInfo();
            
            //邮件地址
            cacm3.getManagerEmail();
            cacm3.SaveCampaignMember();
            
            cacm3.CurrentRoleName = 'SP';
      
            cacm3.SaveCampaignMember();
            
        }
        Test.stopTest();
    }
}
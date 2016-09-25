/*
Author：Tobe
Created on：2014-01-13
Description: 
1.批量审批市场活动成员 
2市场部审批通过即为参加,
新增功能：管理活动成员开放给到销售，销售通过此逻辑来勾选其添加的活动成员是否为已参加。
*/
public without sharing class BQ_CtrlManageCampaignMembers {
	public List<CampaignMember> camlist{get;set;}
	public Boolean IsSupervisor{get;set;}
	public Boolean IsRegionalManager{get;set;} 
	public Boolean IsMarketing{get;set;}
	public Boolean IsClose{get;set;}
	public String CamId{get;set;}
	//用户角色Id
	public Id userRoleId{get;set;} 
	//用户角色名称
	public String userRoleName{get;set;}
	public String userEmail{get;set;}
	public BQ_CtrlManageCampaignMembers() 
	{
		IsClose = false;
		IsSupervisor =false;
		IsRegionalManager = false;
		IsMarketing = false;
		//市场活动Id
		CamId = ApexPages.currentPage().getParameters().get('id');
		//当前登录用户信息
		User CurrentUser=[select Profile.Name,UserRole.Name,UserRoleId,Email from User Where Id=:UserInfo.getUserId()];
		userRoleId = CurrentUser.UserRoleId; 
		userRoleName = CurrentUser.UserRole.Name;
		userEmail =  CurrentUser.Email;
		//判断是否是系统管理员
    	if(CurrentUser.Profile.Name =='系统管理员' || CurrentUser.Profile.Name =='System Administrator')
		{
			//bill update 2013/7/9  
			// 1.添加拒绝原因
			// 2.修改提交人显示为提交人别名  
			// 3.对页面显示顺序按照提交人排序
			camlist = [select SpCurrentUserLevel__c,V2_SupervisoApprove__c,V2_AreaManagerApprove__c,V2_MarketingApprove__c,V2_Participated__c,V2_ContactType__c, 
				       ContactId,V2_Hospital__c,V2_Comment__c,User__c,V2_DepartDate__c,V2_DepartFlight__c,V2_ArriveDate__c,V2_ArriveFlight__c,V2_RejectReason__c,UserFullName__c from CampaignMember where CampaignId=:CamId order by User__c asc];
			IsSupervisor =true;
			IsRegionalManager = true;
			IsMarketing = true;
		}
		//是否有角色
		else if(userRoleId == null)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING , '您的角色Id为空，无法通过您的角色来确定您可编辑的活动成员信息，如有疑问请联系您的系统管理员。');            
            ApexPages.addMessage(msg);
            return;
		}
		//市场部
		else if(userRoleName.contains('Marketing'))
		{
			//bill update 2013/7/9  
			// 1.添加拒绝原因
			// 2.修改提交人显示为提交人别名  
			// 3.对页面显示顺序按照提交人排序
			//2013-6-25修改：显示的记录为 （大区审批通过） 或 （大区审批为空 并且  大区经理邮箱为空） 或者 报名开始不需要逐级审批为勾选
			camlist = [select SpCurrentUserLevel__c,V2_SupervisoApprove__c,V2_AreaManagerApprove__c,V2_MarketingApprove__c,V2_Participated__c,V2_ContactType__c, 
				    	ContactId,V2_Hospital__c,V2_Comment__c,User__c,V2_DepartDate__c,V2_DepartFlight__c,V2_ArriveDate__c,V2_ArriveFlight__c,V2_RejectReason__c,UserFullName__c 
				    	from CampaignMember where CampaignId=:CamId 
				    	and (V2_AreaManagerApprove__c ='通过' Or (V2_AreaManagerApprove__c=null and V2_RegionalUserEmail__c =null) or  Campaign.Registration_Starts_approval__c=true) 
				    	and V2_MarketingApprove__c=null order by User__c asc ];
				    	//and V2_MarketingApprove__c=null order by V2_AreaManagerApprove__c asc ];
			IsMarketing = true;
			/*2012-2-15修改 :默认为审批”通过“*/
			if(camlist != null && camlist.size()>0)
			{
				for(CampaignMember cm:camlist)
				{
					if(cm.V2_MarketingApprove__c != '拒绝')
					{
						cm.V2_MarketingApprove__c = '通过';
					}
					
				}
			}
		}
		//大区经理
		else if(userRoleName.contains('Regional'))
		{
			
			//bill update 2013/7/9  
			// 1.添加拒绝原因字段
			// 2.修改提交人显示为提交人别名  
			// 3.对页面显示顺序按照提交人排序
			//公共类:通过当前用户roleId来确定其下属成员
			V2_UtilClass UtilCla = new V2_UtilClass();
			List<Id> List_Userids = UtilCla.getSubordinateIds(userRoleId);
			//2013-6-26修改：显示的记录为 （主管审批通过） 或 （主管审批为空 并且  主管经理邮箱为空 V2_ManagerEmail1__c） 
			camlist = [select SpCurrentUserLevel__c,V2_SupervisoApprove__c,V2_AreaManagerApprove__c,V2_MarketingApprove__c,V2_Participated__c,V2_ContactType__c, 
				      ContactId,V2_Hospital__c,V2_Comment__c,User__c,V2_DepartDate__c,V2_DepartFlight__c,V2_ArriveDate__c,V2_ArriveFlight__c,V2_RejectReason__c,UserFullName__c 
				      from CampaignMember where User__c in:List_Userids 
				      and (V2_SupervisoApprove__c ='通过' or (V2_SupervisoApprove__c =null and V2_ManagerEmail1__c =null))
				      and CampaignId=:CamId 
				      and V2_AreaManagerApprove__c = null 
				      and V2_MarketingApprove__c!='通过' 
				      order by User__c asc ];
				      //order by V2_SupervisoApprove__c asc];
			IsRegionalManager = true;
			/*2012-2-15修改 :默认为审批”通过“*/
			if(camlist != null && camlist.size()>0)
			{
				for(CampaignMember cm:camlist)
				{
					if(cm.V2_MarketingApprove__c != '拒绝')
					{
						cm.V2_AreaManagerApprove__c = '通过';
					}
				}
			}
		}
		//主管
		else 
		{
			//bill update 2013/7/9  
			// 1.添加拒绝原因字段
			// 2.修改提交人显示为提交人别名  
			// 3.对页面显示顺序按照提交人排序
			/*2013-3-15修改：*/
			//公共类:通过当前用户roleId来确定其下属成员
			V2_UtilClass UtilCla = new V2_UtilClass();
			List<Id> List_Userids = UtilCla.getSubordinateIds(userRoleId);
			camlist = [select V2_ManagerEmail1__c,V2_RegionalUserEmail__c,SpCurrentUserLevel__c,V2_SupervisoApprove__c,V2_AreaManagerApprove__c,V2_MarketingApprove__c,V2_Participated__c,V2_ContactType__c, 
				    ContactId,V2_Hospital__c,V2_Comment__c,User__c,V2_DepartDate__c,V2_DepartFlight__c,V2_ArriveDate__c,V2_ArriveFlight__c,V2_RejectReason__c,UserFullName__c 
				    from CampaignMember where User__c in:List_Userids 
				    and CampaignId=:CamId 
				    and V2_AreaManagerApprove__c=null 
				    and V2_MarketingApprove__c= null 
				    order by User__c asc];
				    //order by V2_SupervisoApprove__c asc];
			
			/*2012-2-15修改 :默认为审批”通过“*/
			if(camlist != null && camlist.size()>0)
			{
				for(CampaignMember cm:camlist)
				{
					if(cm.V2_SupervisoApprove__c != '拒绝')
					{
						cm.V2_SupervisoApprove__c = '通过';
					}
				}
			}
			IsSupervisor = true;
		}
		if(camlist == null || camlist.size()==0 )
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO , '您只能查看您下属提交的成员，或当前市场活动没有可供显示的市场活动成员。');            
            ApexPages.addMessage(msg);
            return;
		}
	}
	//保存 
	public PageReference SaveCampaignMember()
	{
		try
		{
			if(userRoleName != null && userRoleName.contains('Marketing'))
			{
				for(CampaignMember cam:camlist)
				{
					if(cam.V2_MarketingApprove__c == '通过')
					{
						cam.V2_Participated__c = true;
					}
					else
					{
						cam.V2_Participated__c = false;
					}
				}
			}
			update camlist;
			PageReference pageRef = new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+CamId);
            return pageRef;
		}catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , String.valueOf(e));            
            ApexPages.addMessage(msg);
            return null;
		}
	}
	public PageReference Cancel()
	{
		PageReference pageRef = new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+CamId);
        return pageRef;
	}
	
	/****************************************************Test*********************************/
    static testMethod void BQ_CtrlManageCampaignMembers()
    {
    	/*客户*/
		RecordType accrecordtype = [select Id from RecordType where Name='医院' and SobjectType='Account' limit 1];
		Account acc = new Account();
		acc.RecordTypeId = accrecordtype.Id;
		acc.Name = 'AccTest';
		insert acc;
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
		
		Contact con3 = new Contact();
		con3.LastName = 'AccTestContact2';
		con3.AccountId=acc.Id;
		insert con3;
		
		/*用户角色*/
		//市场
		UserRole MarketingUserRole = new UserRole() ;
	    MarketingUserRole.Name = 'Renal-Manager-Marketing-PD-Manager' ;
	    insert MarketingUserRole ;
		//大区
		 UserRole RegionalUserRole = new UserRole() ;
	     RegionalUserRole.Name = 'Renal-Regional-Shanghai-PD-Regional' ;
	     RegionalUserRole.ParentRoleId = MarketingUserRole.Id ;
	     insert RegionalUserRole ;
	     //经理
	     UserRole SupervisorUserRole = new UserRole() ;
	     SupervisorUserRole.Name = 'Renal-Supervisor-Shanghai-PD-Supervisor';
	     SupervisorUserRole.ParentRoleId = RegionalUserRole.Id ;
	     insert SupervisorUserRole ;
	     //销售
	     UserRole RepUserRole = new UserRole() ;
	     RepUserRole.Name = 'Renal-Rep-Shanghai-HD-Rep';
	     RepUserRole.ParentRoleId = SupervisorUserRole.Id ;
	     insert RepUserRole ;
	     
		/*用户简档*/
		//rep简档
	    Profile RepProRenal = [select Id from Profile where Name  = 'Standard User - Renal Sales Rep' limit 1];
	    //Supr简档renal
	    Profile SupProRenal = [select Id from Profile where Name='Standard User - Renal Sales Supervisor' limit 1];
		
		/************User************/
		List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
        
		/*市场部
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
		}*/
		/*市场部*/
		 User MarketUser = new User();
	     MarketUser.Username='MarketUser@123.com';
	     MarketUser.LastName='MarketUser';
	     MarketUser.Email='MarketUser@123.com';
	     MarketUser.Alias=user[0].Alias;
	     MarketUser.TimeZoneSidKey=user[0].TimeZoneSidKey;
	     MarketUser.ProfileId=SupProRenal.Id;
	     MarketUser.LocaleSidKey=user[0].LocaleSidKey;
	     MarketUser.LanguageLocaleKey=user[0].LanguageLocaleKey;
	     MarketUser.EmailEncodingKey=user[0].EmailEncodingKey;
	     MarketUser.CommunityNickname='MarketUser';
	     MarketUser.MobilePhone='123456789112';
	     MarketUser.UserRoleId = MarketingUserRole.Id ;
	     MarketUser.IsActive = true;
	     insert MarketUser;
		/*大区*/
		 User RegionalSu = new User();
	     RegionalSu.Username='RegionalSu@123.com';
	     RegionalSu.LastName='RegionalSu';
	     RegionalSu.Email='RegionalSu@123.com';
	     RegionalSu.Alias=user[0].Alias;
	     RegionalSu.TimeZoneSidKey=user[0].TimeZoneSidKey;
	     RegionalSu.ProfileId=SupProRenal.Id;
	     RegionalSu.LocaleSidKey=user[0].LocaleSidKey;
	     RegionalSu.LanguageLocaleKey=user[0].LanguageLocaleKey;
	     RegionalSu.EmailEncodingKey=user[0].EmailEncodingKey;
	     RegionalSu.CommunityNickname='RegionalSu';
	     RegionalSu.MobilePhone='12345678912';
	     RegionalSu.UserRoleId = RegionalUserRole.Id ;
	     RegionalSu.IsActive = true;
	     insert RegionalSu;
	     
	    /*经理*/
	     User SupervisorSu = new User();
	     SupervisorSu.Username='SupervisorSu@123.com';
	     SupervisorSu.LastName='SupervisorSu';
	     SupervisorSu.Email='SupervisorSu@123.com';
	     SupervisorSu.Alias=user[0].Alias;
	     SupervisorSu.TimeZoneSidKey=user[0].TimeZoneSidKey;
	     SupervisorSu.ProfileId=SupProRenal.Id;
	     SupervisorSu.LocaleSidKey=user[0].LocaleSidKey;
	     SupervisorSu.LanguageLocaleKey=user[0].LanguageLocaleKey;
	     SupervisorSu.EmailEncodingKey=user[0].EmailEncodingKey;
	     SupervisorSu.CommunityNickname='SupervisorSu';
	     SupervisorSu.MobilePhone='12345678912';
	     SupervisorSu.UserRoleId = SupervisorUserRole.Id ;
	     SupervisorSu.IsActive = true;
	     insert SupervisorSu;
	     
	    /*销售*/
	     User RepSu = new User();
	     RepSu.Username='RepSu@123.com';
	     RepSu.LastName='RepSu';
	     RepSu.Email='RepSu@123.com';
	     RepSu.Alias=user[0].Alias;
	     RepSu.TimeZoneSidKey=user[0].TimeZoneSidKey;
	     RepSu.ProfileId=RepProRenal.Id;
	     RepSu.LocaleSidKey=user[0].LocaleSidKey;
	     RepSu.LanguageLocaleKey=user[0].LanguageLocaleKey;
	     RepSu.EmailEncodingKey=user[0].EmailEncodingKey;
	     RepSu.CommunityNickname='RepSu';
	     RepSu.MobilePhone='12345678912';
	     RepSu.UserRoleId = RepUserRole.Id ;
	     RepSu.IsActive = true;
	     insert RepSu;
		
    	/*市场活动*/
		Campaign cam = new Campaign();
		cam.Name = 'CamTest';
		cam.StartDate = date.today().addMonths(1);
		cam.EndDate = date.today().addMonths(2);
		cam.IsActive = true;
		cam.OwnerId = MarketUser.Id;
		insert cam;
		
		/*市场活动成员*/
		CampaignMember cm = new CampaignMember();
		cm.CampaignId = cam.Id;
		cm.ContactId = con1.Id;
		cm.User__c = RepSu.Id;
		
		insert cm;
		//大区通过
		CampaignMember cm1 = new CampaignMember();
		cm1.CampaignId = cam.Id;
		cm1.ContactId = con2.Id;
		cm1.User__c = RepSu.Id;
		cm1.V2_AreaManagerApprove__c = '通过';
		insert cm1;
		
		CampaignMember cm2 = new CampaignMember();
		cm2.CampaignId = cam.Id;
		cm2.ContactId = con3.Id;
		cm2.User__c = RepSu.Id;
		cm2.V2_SupervisoApprove__c = '通过';
		cm2.V2_AreaManagerApprove__c = null;
		insert cm2;
		
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('id',cam.Id);
		BQ_CtrlManageCampaignMembers ccm = new BQ_CtrlManageCampaignMembers();
		ccm.SaveCampaignMember();
		ccm.Cancel();
		//经理
		System.runAs(SupervisorSu)
		{
			BQ_CtrlManageCampaignMembers Succm = new BQ_CtrlManageCampaignMembers();
			Succm.SaveCampaignMember();
		}
		//大区
		System.runAs(RegionalSu)
		{
			BQ_CtrlManageCampaignMembers Reccm = new BQ_CtrlManageCampaignMembers();
			Reccm.SaveCampaignMember();
		}
		
		//市场部
		System.runAs(MarketUser)
		{
			BQ_CtrlManageCampaignMembers Maccm = new BQ_CtrlManageCampaignMembers();
			Maccm.SaveCampaignMember();
		}
		Test.stopTest();
    }
}
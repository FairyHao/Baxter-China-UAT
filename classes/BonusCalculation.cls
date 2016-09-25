/**
 * 作者:Bill
 * 说明：奖金计算页面控制类
**/
public class BonusCalculation {
	
	public String Year{get;set;}
    public String Month{get;set;}
    public String Department{get;set;}
    public String ids;
    public List<SelectOption> ListYears{get;set;}
    public V2_UserBonusInFo__c UbIf{get;set;}
    //部门是否可选
    public Boolean Isreadonly{get;set;}
    //按钮
    public Boolean ButtonDisabled{get;set;}
    //当前用户所属部门
    public String UserDepartment;
    //系统管理员
    public Boolean IsSystemAdmin = false;
    //月
    public List<SelectOption> getListMonths()
    {
        list<SelectOption> options=new list<SelectOption>();
        options.add(new SelectOption('1','1'));options.add(new SelectOption('2','2'));
        options.add(new SelectOption('3','3'));options.add(new SelectOption('4','4'));
        options.add(new SelectOption('5','5'));options.add(new SelectOption('6','6'));
        options.add(new SelectOption('7','7'));options.add(new SelectOption('8','8'));
        options.add(new SelectOption('9','9'));options.add(new SelectOption('10','10'));
        options.add(new SelectOption('11','11'));options.add(new SelectOption('12','12'));
        return options;
    }
    //部门
    public List<SelectOption> getListDepartment()
    {
        list<SelectOption> options=new list<SelectOption>();
        options.add(new SelectOption('RENAL','RENAL'));
        options.add(new SelectOption('MD','MD'));
        options.add(new SelectOption('BIOS','BIOS'));
        /*==================2014-2-19BQ添加====================*/
        options.add(new SelectOption('BQ','BQ'));
        return options;
    }
    public BonusCalculation()
    {
        UbIf = new V2_UserBonusInFo__c();//[select Id from User where IsActive =: false  ];
        //年
        ListYears = new  List<SelectOption>();
        ListYears.add(new SelectOption(String.valueOf(date.today().addYears(-1).year()),String.valueOf(date.today().addYears(-1).year())));
        ListYears.add(new SelectOption(String.valueOf(date.today().year()),String.valueOf(date.today().year())));
        ListYears.add(new SelectOption(String.valueOf(date.today().addYears(1).year()),String.valueOf(date.today().addYears(1).year())));
        //默认当前年当前月
        Year = String.valueOf(date.today().year());
        Month = String.valueOf(date.today().Month());
        CheckCurrentUser();
        ButtonDisabled = false;
    }
    //当前用户信息
    public void CheckCurrentUser()
    {
        //当前用户信息
        User CurrentUser = [select UserRole.Name,Profile.Name from User where Id =: UserInfo.getUserId()];
        if(CurrentUser.Profile.Name == '系统管理员' || CurrentUser.Profile.Name =='System Administrator')
        {
            IsSystemAdmin = true;
            Isreadonly = false;
        }
        else
        {
            Isreadonly = true;
            if(CurrentUser.Profile.Name == 'Standard User - Renal Admin')
            {
                Department = 'RENAL';
            }
            else if(CurrentUser.Profile.Name == 'Standard User - IVT Admin')
            {
                Department = 'MD';
            }
            else if(CurrentUser.Profile.Name == 'Standard User - BIOS Admin')
            {
                Department = 'BIOS';
            }
            /*==================2014-2-19BQ添加====================*/
          	else if(CurrentUser.Profile.Name == 'BQ Admin')
          	{
            	Department = 'BQ';
            }
            else
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING , '无法通过您的简档判断所属部门，请您联系管理员。');            
                ApexPages.addMessage(msg);
                ButtonDisabled = true;
                return;
            }
        }
        
        
    }
    //计算奖金数据
    public void BeginComputationBonus()
    {
        //Md & Bios
        Set<Id> Set_RepIds = new Set<Id>();
        Set<Id> Set_SupervisorIds = new Set<Id>();
        //Renal
        Set<Id> RenalRepIds = new Set<Id>();
        Set<Id> RenalSsIds = new Set<Id>();
        try
        {
            ButtonDisabled = true;
            //if(Department != UserDepartment && !IsSystemAdmin)
            //{
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING , '请选择您所属部门进行计算！');            
               // ApexPages.addMessage(msg);
               // return NULL;
            //}
            //选择单个用户
            if(UbIf.V2_SalesUser__c != null)
            {
            	/*==================2014-2-19BQ添加====================*/
            	if(Department == 'BQ')
            	{
            		List<V2_RoleHistory__c> list_RoleHistory = [Select v.Role__c, v.Manager__c, v.Renal_valid_super__c,GBU__c, v.Name__c, v.IsOnHoliday__c, v.IsLeave__c, v.Department__c, v.PG__c, v.Level__c
		                From V2_RoleHistory__c v 
		                Where Month__c =: Month And Year__c =: Year And IsOnHoliday__c = false And IsLeave__c = false And Name__c =: UbIf.V2_SalesUser__c];
	                if(list_RoleHistory==null || list_RoleHistory.size() == 0){
	                	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error ,'未能找到所选择用户的角色历史信息，请检查所选用户是否正确，如有疑问请联系系统管理员。' );            
		                ApexPages.addMessage(msg);
		                return;
	                }
	                else
	                {
	                	if(list_RoleHistory[0].GBU__c == null){
	                		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error ,'不能确认所选用户部门信息，请检查所选用户是否正确，如有疑问请联系系统管理员。' );            
		                    ApexPages.addMessage(msg);
		                    return;
	                	}
	                	else if(!list_RoleHistory[0].GBU__c.toUpperCase().contains('BQ'))
	                	{
	                		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error ,'您只能选择BQ部门用户，请检查所选用户是否正确，如有疑问请联系系统管理员。' );            
		                	ApexPages.addMessage(msg);
		                	return;
	                	}
	                	else 
	                	{
	                		BQ_BatchComputationBonus BonusBatch = new BQ_BatchComputationBonus();
							BonusBatch.singleUserId = UbIf.V2_SalesUser__c;
							BonusBatch.year = Integer.valueOf(Year);
							BonusBatch.month = Integer.valueOf(Month);
							Database.executeBatch(BonusBatch,1);
							
							ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM ,'奖金计算已经开始，请您稍等一段时间再去查看！' );            
			                ApexPages.addMessage(msg);
			                return;
	                	}
	                }
            	}
            	/*==================2014-2-19BQ添加====================*/
            	else 
            	{
            		//判断单个用户角色历史是否符合条件
	            	List<V2_RoleHistory__c> list_RoleHistory = [Select v.Role__c, v.Manager__c, v.Renal_valid_super__c,GBU__c, v.Name__c, v.IsOnHoliday__c, v.IsLeave__c, v.Department__c, v.PG__c, v.Level__c
		                From V2_RoleHistory__c v 
		                Where Month__c =: Month And Year__c =: Year And IsOnHoliday__c = false And IsLeave__c = false And Name__c =: UbIf.V2_SalesUser__c];
	                if(list_RoleHistory==null || list_RoleHistory.size() == 0){
	                	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error ,'未能找到所选择用户的角色历史信息，请检查所选用户是否正确，如有疑问请联系系统管理员。' );            
		                ApexPages.addMessage(msg);
		                return;
	                }else{
	                	if(list_RoleHistory[0].GBU__c == null){
	                		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error ,'不能确认所选用户部门信息，请检查所选用户是否正确，如有疑问请联系系统管理员。' );            
		                    ApexPages.addMessage(msg);
		                    return;
	                	}else{
	                		if(list_RoleHistory[0].GBU__c.toUpperCase().contains('RENAL') || list_RoleHistory[0].GBU__c.toUpperCase().contains('MD')){
	                			ClsBonusRowDataCalculationBatch bonusBatch = new ClsBonusRowDataCalculationBatch();
	                			bonusBatch.intMonth = Integer.valueOf(Month) ;
	                			bonusBatch.intYear = Integer.valueOf(Year);
	                			bonusBatch.singleUserId = UbIf.V2_SalesUser__c ;
	                			Database.executeBatch(bonusBatch,1);
	                		}else if(list_RoleHistory[0].GBU__c.toUpperCase().contains('BIOS')){
	                			V2_BatchComputationBonus BonusBatch = new V2_BatchComputationBonus();
				                BonusBatch.userids = UbIf.V2_SalesUser__c+',';  
				                BonusBatch.year = Integer.valueOf(Year);
				                BonusBatch.month = Integer.valueOf(Month);
				                Database.executeBatch(BonusBatch,1);
	                		}
	                		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM ,'奖金计算已经开始，请您稍等一段时间再去查看！' );            
			                ApexPages.addMessage(msg);
			                return;
	                	}
	                }
            	}
            }
            else
            {
            	//按照部门进行计算
            	if(Department == 'RENAL' || Department == 'MD'){
            		ClsBonusRowDataCalculationBatch bonusBatch = new ClsBonusRowDataCalculationBatch();
	                bonusBatch.intMonth = Integer.valueOf(Month) ;
	                bonusBatch.intYear = Integer.valueOf(Year);
	                bonusBatch.strGBU = Department;
	                Database.executeBatch(bonusBatch,1);
            	}else if(Department == 'BIOS'){
            		for(User u:[select UserRole.Name,Id,Renal_valid_super__c,Department from User 
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
	                    List<String> RoleNameInfos = String.valueOf(u.UserRole.Name).split('-');
	                    if(RoleNameInfos == null)
	                    {
	                        continue;
	                    }
	                    if(RoleNameInfos.size()<4)
	                    {
	                        continue;
	                    }
	                    if(RoleNameInfos[0].trim().toUpperCase()!= Department)
	                    {
	                        continue;
	                    }
	                    if(ids == null)
	                    {
	                        ids = u.id+',';
	                    }
	                    else 
	                    {
	                        ids +=u.id+',';
	                    }
	                }
	                //调用batch
	                if(ids !=null && ids.length()>0)
	                {
	                    DeleteUserBonus(Year,Month,Department);
	                    V2_BatchComputationBonus BonusBatch = new V2_BatchComputationBonus();
	                    BonusBatch.userids = ids;  
	                    BonusBatch.year = Integer.valueOf(Year);
	                    BonusBatch.month = Integer.valueOf(Month);
	                    Database.executeBatch(BonusBatch,1);
	                }
            	}
            	/*==================2014-2-19BQ添加====================*/
	        	else if(Department == 'BQ')
	        	{
	        		BQ_BatchComputationBonus BonusBatch = new BQ_BatchComputationBonus();
					BonusBatch.year = Integer.valueOf(Year);
					BonusBatch.month = Integer.valueOf(Month);
					Database.executeBatch(BonusBatch,1);
	        	}
	        	/*==================2014-2-19BQ添加====================*/
                
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM ,'奖金计算已经开始，请您稍等一段时间再去查看！' );            
                ApexPages.addMessage(msg);
                return;
            }
            
        }
        catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , e.getmessage()+' 第'+e.getLineNumber()+'行' );            
            ApexPages.addMessage(msg);
            return;
        }
        
        
    }
    //判断所选用户是否是当前用户所在部门
    public void CheckSelectUser()
    {
        ButtonDisabled = false;
        try
        {
            if(UbIf.V2_SalesUser__c == null)
            {
                return;
            }
            
            User SelectUser = [select UserRole.Name,IsActive,IsOnHoliday__c,IsLeave__c,UserRoleId from User Where Id =:UbIf.V2_SalesUser__c]; 
            if(SelectUser.IsActive ==false || SelectUser.IsOnHoliday__c || SelectUser.IsLeave__c || SelectUser.UserRoleId==null || SelectUser.UserRole.Name == null || SelectUser.UserRoleId == null)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING , '请检查所选用户是否为:禁用用户、离职用户、休假用户、用户角色为空，上述用户不能计算其奖金，如有疑问请联系系统管理员。');            
                ApexPages.addMessage(msg);
                ButtonDisabled = true;
                return;
            }
            else
            {
                List<String> RoleInfo = String.valueOf(SelectUser.UserRole.Name).trim().split('-'); 
                if(RoleInfo !=null && RoleInfo.size()>=4)
                {
                    //所选用户部门
                    String SelectUserBU = RoleInfo[0].toUpperCase();
                    //所选用户级别
                    String UserLeve = RoleInfo[1].toUpperCase();
                    /*==================2014-2-19BQ添加====================*/
                    if(SelectUserBU != 'RENAL' && SelectUserBU != 'MD' && SelectUserBU != 'BIOS' && SelectUserBU != 'BQ')
                    {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING , '无法通过所选用户的角色名称判断其所属部门，请您联系管理员。');            
                        ApexPages.addMessage(msg);
                        ButtonDisabled = true;
                        return;
                    }
                    else if(SelectUserBU != Department)
                    {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '所选用户与您不是同一部门，请检查后再操作！');            
                        ApexPages.addMessage(msg);
                        ButtonDisabled = true;
                        return;
                    }
                    /*else if(UserLeve != 'REP' && UserLeve !='SUPERVISOR')
                    {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '所选用户既不是代表也不是主管，请检查后再操作！');            
                        ApexPages.addMessage(msg);
                        ButtonDisabled = true;
                        return;
                    }*/
                }
                else
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '所选用户角色信息不正确，请联系系统管理员！');            
                    ApexPages.addMessage(msg);
                    return;
                }
            }
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getmessage()+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
    }
    //删除用户奖金数据
    public void DeleteUserBonus(String year,String Month,String Department)
    {
        try
        {
            List<V2_UserBonusInFo__c> UserBonus = [select Id from V2_UserBonusInFo__c where V2_Department__c =: Department and  V2_Year__c =: year and V2_Month__c =:Month];
            if(UserBonus != null && UserBonus.size()>0)
            {
                delete UserBonus;
            }
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getmessage()+' 第'+e.getLineNumber()+'行');            
            ApexPages.addMessage(msg);
            return;
        }
    }
     /****************************************************Test*********************************/
    static testMethod void testBonusCalculation()
    {
        //----------------New Role ------------------
         UserRole objUserRole = new UserRole() ;
         objUserRole.Name = 'Renal-Supervisor-华北-PD-Supervisor(杨洪玲)' ;
         insert objUserRole ;
         
         UserRole objUserRole2 = new UserRole() ;
         objUserRole2.Name = 'BIOS-Supervisor-北京-Albumin-Supervisor(郭新秀)' ;
         insert objUserRole2 ;
         
         UserRole objUserRole3 = new UserRole() ;
         objUserRole3.Name = 'MD-Supervisor-陕西-IVT-Supervisor(王乐)' ;
         insert objUserRole3 ;
         
         UserRole objUserRole4 = new UserRole() ;
         objUserRole4.Name = 'Null-Supervisor-陕西-IVT-Supervisor(王乐)' ;
         insert objUserRole4 ;
         
         UserRole objUserRole5 = new UserRole() ;
         objUserRole5.Name = 'Renal-Rep-华北-PD-Rep(张寰宇)';
         objUserRole5.ParentRoleId = objUserRole.Id ;
         insert objUserRole5 ;
         
         UserRole objUserRole6 = new UserRole() ;
         objUserRole6.Name = 'Renal Rep';
         objUserRole6.ParentRoleId = objUserRole.Id ;
         insert objUserRole6 ;
         
        //rep简档
        Profile RepProRenal = [select Id from Profile where Name  = 'Standard User - Renal Sales Rep' limit 1];
        //Supr简档renal
        Profile SupProRenal = [select Id from Profile where Name='Standard User - Renal Admin' limit 1];
       //md
        Profile SupProMd = [select Id from Profile where Name='Standard User - IVT Admin' limit 1];
        //bios
        Profile SupProBios = [select Id from Profile where Name='Standard User - BIOS Admin' limit 1];
    //----------------Create User-------------
         List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
         //Renal
         User RenalSu = new User();
         RenalSu.Username='RenalSu@123.com';
         RenalSu.LastName='RenalSu';
         RenalSu.Email='RenalSu@123.com';
         RenalSu.Alias=user[0].Alias;
         RenalSu.TimeZoneSidKey=user[0].TimeZoneSidKey;
         RenalSu.ProfileId=SupProMd.Id;
         RenalSu.LocaleSidKey=user[0].LocaleSidKey;
         RenalSu.LanguageLocaleKey=user[0].LanguageLocaleKey;
         RenalSu.EmailEncodingKey=user[0].EmailEncodingKey;
         RenalSu.CommunityNickname='RenalSu';
         RenalSu.MobilePhone='12345678912';
         RenalSu.UserRoleId = objUserRole.Id ;
         RenalSu.IsActive = true;
         insert RenalSu;
         //Md
         User MdSu = new User();
         MdSu.Username='MdSu@123.com';
         MdSu.LastName='MdSu';
         MdSu.Email='MdSu@123.com';
         MdSu.Alias=user[0].Alias;
         MdSu.TimeZoneSidKey=user[0].TimeZoneSidKey;
         MdSu.ProfileId=SupProMd.Id;
         MdSu.LocaleSidKey=user[0].LocaleSidKey;
         MdSu.LanguageLocaleKey=user[0].LanguageLocaleKey;
         MdSu.EmailEncodingKey=user[0].EmailEncodingKey;
         MdSu.CommunityNickname='MdSu';
         MdSu.MobilePhone='12345678912';
         MdSu.UserRoleId = objUserRole3.Id ;
         MdSu.IsActive = true;
         insert MdSu;
         //Bios
         User BiosSu = new User();
         BiosSu.Username='BiosSu@123.com';
         BiosSu.LastName='BiosSu';
         BiosSu.Email='BiosSu@123.com';
         BiosSu.Alias=user[0].Alias;
         BiosSu.TimeZoneSidKey=user[0].TimeZoneSidKey;
         BiosSu.ProfileId=SupProBios.Id;
         BiosSu.LocaleSidKey=user[0].LocaleSidKey;
         BiosSu.LanguageLocaleKey=user[0].LanguageLocaleKey;
         BiosSu.EmailEncodingKey=user[0].EmailEncodingKey;
         BiosSu.CommunityNickname='BiosSu';
         BiosSu.MobilePhone='12345678912';
         BiosSu.UserRoleId = objUserRole2.Id ;
         BiosSu.IsActive = true;
         insert BiosSu;
         
         //null部门
         User NullSu = new User();
         NullSu.Username='NullSu@123.com';
         NullSu.LastName='NullSu';
         NullSu.Email='NullSu@123.com';
         NullSu.Alias=user[0].Alias;
         NullSu.TimeZoneSidKey=user[0].TimeZoneSidKey;
         NullSu.ProfileId=SupProBios.Id;
         NullSu.LocaleSidKey=user[0].LocaleSidKey;
         NullSu.LanguageLocaleKey=user[0].LanguageLocaleKey;
         NullSu.EmailEncodingKey=user[0].EmailEncodingKey;
         NullSu.CommunityNickname='NullSu';
         NullSu.MobilePhone='12345678912';
         NullSu.UserRoleId = objUserRole4.Id ;
         NullSu.IsActive = true;
         insert NullSu;
         
         // Renal  rep
         User RenalRepSu = new User();
         RenalRepSu.Username='RenalRepSu@123.com';
         RenalRepSu.LastName='RenalRepSu';
         RenalRepSu.Email='RenalRepSu@123.com';
         RenalRepSu.Alias=user[0].Alias;
         RenalRepSu.TimeZoneSidKey=user[0].TimeZoneSidKey;
         RenalRepSu.ProfileId=RepProRenal.Id;
         RenalRepSu.LocaleSidKey=user[0].LocaleSidKey;
         RenalRepSu.LanguageLocaleKey=user[0].LanguageLocaleKey;
         RenalRepSu.EmailEncodingKey=user[0].EmailEncodingKey;
         RenalRepSu.CommunityNickname='RenalRepSu';
         RenalRepSu.MobilePhone='12345678912';
         RenalRepSu.UserRoleId = objUserRole5.Id ;
         RenalRepSu.IsOnHoliday__c =false;
         RenalRepSu.IsLeave__c = false;
         RenalRepSu.IsActive = true;
         insert RenalRepSu;
         
         //角色名称格式错误用户
         User ErrorRole = new User();
         ErrorRole.Username='ErrorRole@123.com';
         ErrorRole.LastName='ErrorRole';
         ErrorRole.Email='ErrorRole@123.com';
         ErrorRole.Alias=user[0].Alias;
         ErrorRole.TimeZoneSidKey=user[0].TimeZoneSidKey;
         ErrorRole.ProfileId=RepProRenal.Id;
         ErrorRole.LocaleSidKey=user[0].LocaleSidKey;
         ErrorRole.LanguageLocaleKey=user[0].LanguageLocaleKey;
         ErrorRole.EmailEncodingKey=user[0].EmailEncodingKey;
         ErrorRole.CommunityNickname='ErrorRole';
         ErrorRole.MobilePhone='12345678912';
        // ErrorRole.UserRoleId = objUserRole6.Id ;
         ErrorRole.IsActive = true;
         insert ErrorRole;
         
         //角色名称拆分错误
         User ErrorRole2 = new User();
         ErrorRole2.Username='ErrorRole2@123.com';
         ErrorRole2.LastName='ErrorRole2';
         ErrorRole2.Email='ErrorRole2@123.com';
         ErrorRole2.Alias=user[0].Alias;
         ErrorRole2.TimeZoneSidKey=user[0].TimeZoneSidKey;
         ErrorRole2.ProfileId=RepProRenal.Id;
         ErrorRole2.LocaleSidKey=user[0].LocaleSidKey;
         ErrorRole2.LanguageLocaleKey=user[0].LanguageLocaleKey;
         ErrorRole2.EmailEncodingKey=user[0].EmailEncodingKey;
         ErrorRole2.CommunityNickname='ErrorRole2';
         ErrorRole2.MobilePhone='12345678912';
         ErrorRole2.UserRoleId = objUserRole6.Id ;
         ErrorRole2.IsActive = true;
         insert ErrorRole2;
         
         
         List<V2_RoleHistory__c> list_rh = new List<V2_RoleHistory__c>();
         V2_RoleHistory__c rh1 = new V2_RoleHistory__c();
         rh1.Name__c = RenalRepSu.Id;
         rh1.GBU__c = 'Renal';
         rh1.Department__c='renal';
         rh1.Year__c = String.valueOf(date.today().year());
         rh1.Month__c = String.valueOf(date.today().month());
         list_rh.add(rh1);
         V2_RoleHistory__c rh2 = new V2_RoleHistory__c();
         rh2.Name__c = RenalSu.Id;
         rh2.GBU__c = 'Renal';
         rh2.Department__c='renal';
         rh2.Year__c = String.valueOf(date.today().year());
         rh2.Month__c = String.valueOf(date.today().month());
         list_rh.add(rh2);
         V2_RoleHistory__c rh3 = new V2_RoleHistory__c();
         rh3.Name__c = BiosSu.Id;
         rh3.GBU__c = 'Renal';
         rh3.Department__c='bios';
         rh3.Year__c = String.valueOf(date.today().year());
         rh3.Month__c = String.valueOf(date.today().month());
         list_rh.add(rh3);
         V2_RoleHistory__c rh4 = new V2_RoleHistory__c();
         rh4.Name__c = MdSu.Id ;
         rh4.Department__c='MD';
         rh4.GBU__c = 'Renal';
         rh4.Year__c = String.valueOf(date.today().year());
         rh4.Month__c = String.valueOf(date.today().month());
         list_rh.add(rh4);
         insert list_rh ;
         
         
        //Test.startTest();
        BonusCalculation cacsb = new BonusCalculation();
        cacsb.Department = 'RENAL';
        cacsb.getListMonths();
        cacsb.getListDepartment();
        cacsb.BeginComputationBonus();
        
        
        //Renal
        System.runAs(RenalSu)
        {
            BonusCalculation cacsbRenal = new BonusCalculation();
            cacsbRenal.getListMonths();
            cacsbRenal.getListDepartment();
            cacsbRenal.UbIf.V2_SalesUser__c = RenalRepSu.Id;
            cacsbRenal.CheckSelectUser();
            cacsbRenal.BeginComputationBonus();
            
            
            
            
            //下属不属于任何部门
            BonusCalculation cacsbRenal3 = new BonusCalculation();
            cacsbRenal3.getListMonths();
            cacsbRenal3.getListDepartment();
            cacsbRenal3.UbIf.V2_SalesUser__c = ErrorRole.Id;
            try
            {
                cacsbRenal3.CheckSelectUser();
            }catch(Exception e)
            {
                System.debug('不属于任何部门'+String.valueOf(e));
            }
            //下属
        }
        //Md
        System.runAs(MdSu)
        {
            BonusCalculation cacsbMd = new BonusCalculation();
            cacsbMd.Department = 'MD';
            cacsbMd.getListMonths();
            cacsbMd.getListDepartment();
            cacsbMd.BeginComputationBonus();
            
        }
        //Bios
        System.runAs(BiosSu)
        {
            BonusCalculation cacsbBios = new BonusCalculation();
            cacsbBios.Department = 'BIOS';
            cacsbBios.getListMonths();
            cacsbBios.getListDepartment();
            cacsbBios.BeginComputationBonus();
            
        }
        //无法通过角色判断部门
        System.runAs(NullSu)
        {
            try
            {
                BonusCalculation cacsbBios = new BonusCalculation();
            }catch(Exception e)
            {
                System.debug('无法通过角色判断部门'+String.valueOf(e));
            }
        }
        //当前用户角色名称 格式不正确的
        System.runAs(ErrorRole)
        {
            try
            {
                BonusCalculation cacsbBios = new BonusCalculation();
            }catch(Exception e)
            {
                System.debug('角色名称格式错误'+String.valueOf(e));
            }
        }
        //角色名称拆分错误
        System.runAs(ErrorRole2)
        {
            try
            {
                BonusCalculation cacsbBios = new BonusCalculation();
            }catch(Exception e)
            {
                System.debug('角色名称格式拆分错误'+String.valueOf(e));
            }
        }
        //Test.stopTest();
    }
}
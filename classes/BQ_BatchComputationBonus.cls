/*
Author：Scott
Created on：2014-1-24
Description: 
1.批量计算BQ部门不同团队各用户奖金
2.一次计算一个代表奖金数据。
*/
global with sharing class BQ_BatchComputationBonus implements Database.Batchable<sObject>{
	global Id singleUserId;//BQ单个用户
	global Integer year;//年
    global Integer month;//月
    global V2_RoleHistory__c CurrentUserRoleHistory;//当前用户角色历史
    String ExternalID; //外键
     //奖金参数封装类
    BQ_KpiService BqKpi;
    //记录类型Id
    Id BQRep;
    Id BQSupervisor;
    Id BQRegional;
    
	global List<V2_RoleHistory__c> start(Database.BatchableContext bc) 
	{
		//代表
        List<V2_RoleHistory__c> List_RepUser = new List<V2_RoleHistory__c>();
        //销售经理
        List<V2_RoleHistory__c> List_SuperUser = new List<V2_RoleHistory__c>();
        //大区经理
        List<V2_RoleHistory__c> List_RegionalUser = new List<V2_RoleHistory__c>();
        
        //查询需计算奖金月份的角色历史，直接去掉该月份在休假、已离职的。
    	List<V2_RoleHistory__c> list_RoleHis ;
    	if(singleUserId != null)
    	{
    		list_RoleHis = [Select v.Role__c, v.Manager__c, v.Renal_valid_super__c, v.Name__c, v.IsOnHoliday__c, v.IsLeave__c, v.Department__c, v.PG__c, v.Level__c, v.GBU__c
		        			From V2_RoleHistory__c v Where Month__c =: String.valueOf(month) And Year__c =: String.valueOf(year) 
		        			And IsOnHoliday__c = false And IsLeave__c = false And Status__c != '停用' And Name__c =: singleUserId and GBU__c='BQ'];
    	}
    	else
    	{
    		list_RoleHis = [Select v.Role__c, v.Manager__c, v.Renal_valid_super__c, v.Name__c, v.IsOnHoliday__c, v.IsLeave__c, v.Department__c, v.PG__c, v.Level__c, v.GBU__c
							From V2_RoleHistory__c v Where Month__c =: String.valueOf(month) And Year__c =: String.valueOf(year) 
							And IsOnHoliday__c = false And IsLeave__c = false And Status__c != '停用' and GBU__c='BQ'];
    	}
        for(V2_RoleHistory__c RoleHistory : list_RoleHis)
        {
        	//角色
            String UserRoleName = RoleHistory.Role__c.toUpperCase();
        	//代表
            if(UserRoleName.contains('REP'))
            {
            	List_RepUser.add(RoleHistory);
            }
            //销售经理
            else if(UserRoleName.contains('SUPERVISOR') || UserRoleName.contains('DISTRICT DSM') || UserRoleName.contains('AREA ASM') )
            {
            	List_SuperUser.add(RoleHistory);
            }
            //大区经理
            else if(UserRoleName.contains('REGIONAL'))
            {
            	List_RegionalUser.add(RoleHistory);
            }
        }
        List_RepUser.addAll(List_SuperUser);
        List_RepUser.addAll(List_RegionalUser);
        return List_RepUser;
	}
	global void execute(Database.BatchableContext BC, list<V2_RoleHistory__c> sob)
	{
		 /*奖金数据记录类型*/
         getBonusRecordTypeids();
		for(V2_RoleHistory__c u : sob)
        {
        	CurrentUserRoleHistory = u;
        	//角色
            String UserRoleName = u.Role__c.toUpperCase();
        	//奖金类型
            String BonusType;
            /*奖金数据外键*/
            ExternalID = String.valueOf(year)+String.valueOf(month)+u.Name__c;
            //奖金参数封装类
            BqKpi = new BQ_KpiService(u.Name__c,year,month);
            //奖金明细
            List<V2_BonusParameterDetails__c> List_BonusDetails ;
            
            //代表
            if(UserRoleName.contains('REP'))
            {
            	BonusType='BQ销售';
            	List_BonusDetails = BqKpi.getBonusParameterInfo(BonusType);
	            if(List_BonusDetails != null && List_BonusDetails.size()>0)
	            {
	            	BQRepBonus(List_BonusDetails);
	            }
            }
            //销售经理
            else if(UserRoleName.contains('SUPERVISOR') || UserRoleName.contains('DISTRICT DSM') || UserRoleName.contains('AREA ASM') )
            {
            	BonusType='BQ主管';
            	List_BonusDetails = BqKpi.getBonusParameterInfo(BonusType);
	            if(List_BonusDetails != null && List_BonusDetails.size()>0)
	            {
	            	BQSupervisorBonus(List_BonusDetails);
	            }
            }
            //大区经理
            else if(UserRoleName.contains('REGIONAL'))
            {
            	BonusType='BQ大区经理';
            	List_BonusDetails = BqKpi.getBonusParameterInfo(BonusType);
	            if(List_BonusDetails != null && List_BonusDetails.size()>0)
	            {
	            	BQRegionalBonus(List_BonusDetails);
	            }
            }
            
        }
	}
	/*
     *BQ代表奖金
    */
    public Void BQRepBonus(List<V2_BonusParameterDetails__c> BQRepBonus)
    {
    	/*奖金数据*/
        Bonus_data__c UserBonus = new Bonus_data__c();
        UserBonus.OwnerId = CurrentUserRoleHistory.Name__c;
        UserBonus.The_User__c = CurrentUserRoleHistory.Name__c;
        UserBonus.Year__c = String.valueOf(year);
        UserBonus.Month__c = String.valueOf(month);
        UserBonus.RecordTypeId = BQRep;
        UserBonus.ExternalID__c = ExternalID;
        UserBonus.BQ_Score_K1__c = 0;
        UserBonus.BQ_Score_K2__c = 0;
        UserBonus.BQ_Score_K3__c = 0;
        UserBonus.BQ_Score_K4__c = 0;
        
        
        
        Double sum = 0;
        for(V2_BonusParameterDetails__c bpd : BQRepBonus)
        {
        	if(bpd.Name=='K1每日拜访次数')
        	{
        		BqKpi.getK1(UserBonus);
        		//完成次数  ，计划次数
        		BqKpi.getK1Aid(UserBonus);
        		if(UserBonus.BQ_Daily_Visit__c >=bpd.V2_BonusStandard__c)
        		{
        			UserBonus.BQ_Score_K1__c = bpd.V2_Weight__c;
        			sum+=UserBonus.BQ_Score_K1__c;
        		}
        		//当不满足每天拜访12次的标准时，需看拜访完成率是否为80%以上 ，如果是 则1分
        		else if(UserBonus.BQ_TotalCallRecords__c >0 && UserBonus.BQ_FinishedCallRecords__c/ UserBonus.BQ_TotalCallRecords__c>=0.8)
        		{
        			UserBonus.BQ_Score_K1__c = 1;
        			sum+=UserBonus.BQ_Score_K1__c;
        		}
        	}
        	else if(bpd.Name=='K2每月覆盖客户人数') 
        	{
        		BqKpi.getK2(UserBonus);
        		if(UserBonus.BQ_Cover_Customer_Number__c>=bpd.V2_BonusStandard__c)
        		{
        			UserBonus.BQ_Score_K2__c = bpd.V2_Weight__c;
        			sum+=UserBonus.BQ_Score_K2__c;
        		}
        	}
        	else if(bpd.Name=='K3每月E-detailing使用')
        	{
        		BqKpi.getK3(UserBonus);
        		if(UserBonus.BQ_ED_UseNumber__c>=bpd.V2_BonusStandard__c)
        		{
        			UserBonus.BQ_Score_K3__c = bpd.V2_Weight__c;
        			sum+=UserBonus.BQ_Score_K3__c;
        			UserBonus.BQ_ED_UseNumber__c=UserBonus.BQ_ED_UseNumber__c*100;
        		}
        	}
        	else if(bpd.Name=='K4每月会议举行频率')
        	{
        		BqKpi.getK4(UserBonus);//本月会议举行频率
        		BqKpi.getK4Total(UserBonus);//本季会议总举行频率
        		if(UserBonus.BQ_Meeting_Total__c>=bpd.V2_BonusStandard__c)
        		{
        			UserBonus.BQ_Score_K4__c = bpd.V2_Weight__c;
        			sum+=UserBonus.BQ_Score_K4__c;
        		}
        	}
        }
        UserBonus.Total_Score__c = sum;
        //计算季度得分
        BqKpi.getQuarterScores(UserBonus);
        Upsert UserBonus ExternalID__c;
    }
    /*
     *BQ主管奖金
    */
    public Void BQSupervisorBonus(List<V2_BonusParameterDetails__c> BQSupervisorBonus)
    {
    	/*奖金数据*/
        Bonus_data__c UserBonus = new Bonus_data__c();
        UserBonus.OwnerId = CurrentUserRoleHistory.Name__c;
        UserBonus.The_User__c = CurrentUserRoleHistory.Name__c;
        UserBonus.Year__c = String.valueOf(year);
        UserBonus.Month__c = String.valueOf(month);
        UserBonus.RecordTypeId = BQSupervisor;
        UserBonus.ExternalID__c = ExternalID;
        UserBonus.BQ_Score_K5__c = 0;
        UserBonus.BQ_Score_K6__c = 0;
        Double sum = 0;
        for(V2_BonusParameterDetails__c bpd : BQSupervisorBonus)
        {
        	if(bpd.Name=='K5团队拜访执行')
        	{
        		BqKpi.getK5(UserBonus);
        		if(UserBonus.BQ_Rep_Visit__c>=bpd.V2_BonusStandard__c)
        		{
        			UserBonus.BQ_Score_K5__c = bpd.V2_Weight__c;
        			sum+=UserBonus.BQ_Score_K5__c;
        		}
        	}
        	else if(bpd.Name=='K6协访的执行')
        	{
        		BqKpi.getK6(UserBonus);
        		if(UserBonus.BQ_Director_Personal_Visit__c>=bpd.V2_BonusStandard__c)
        		{
        			UserBonus.BQ_Score_K6__c = bpd.V2_Weight__c;
        			sum+=UserBonus.BQ_Score_K6__c;
        		}
        	}
        }
        UserBonus.Total_Score__c = sum;
        Upsert UserBonus ExternalID__c;
    }
    /*
     *BQ大区奖金
    */
    public Void BQRegionalBonus(List<V2_BonusParameterDetails__c> BQRegionalBonus)
    {
    	/*奖金数据*/
        Bonus_data__c UserBonus = new Bonus_data__c();
        UserBonus.OwnerId = CurrentUserRoleHistory.Name__c;
        UserBonus.The_User__c = CurrentUserRoleHistory.Name__c;
        UserBonus.Year__c = String.valueOf(year);
        UserBonus.Month__c = String.valueOf(month);
        UserBonus.RecordTypeId = BQRegional;
        UserBonus.ExternalID__c = ExternalID;
        UserBonus.BQ_Score_K7__c = 0;
        UserBonus.BQ_Score_K8__c = 0;
        Double sum = 0;
        for(V2_BonusParameterDetails__c bpd : BQRegionalBonus)
        {
        	if(bpd.Name=='K7团队协访执行')
        	{
        		BqKpi.getK7(UserBonus);
        		if(UserBonus.BQ_Directors_Visit__c>=bpd.V2_BonusStandard__c)
        		{
        			UserBonus.BQ_Score_K7__c = bpd.V2_Weight__c;
        			sum+=UserBonus.BQ_Score_K7__c;
        		}
        	}
        	else if(bpd.Name=='K8个人协访的执行')
        	{
        		BqKpi.getK8(UserBonus);
        		if(UserBonus.BQ_Regional_Visit__c>=bpd.V2_BonusStandard__c)
        		{
        			UserBonus.BQ_Score_K8__c = bpd.V2_Weight__c;
        			sum+=UserBonus.BQ_Score_K8__c;
        		}
        	}
        }
        UserBonus.Total_Score__c = sum;
        Upsert UserBonus ExternalID__c;
    }
    /*
     *奖金数据记录类型
    */
    global void getBonusRecordTypeids()
    {
        for(RecordType rt:[select Id,DeveloperName from RecordType where SobjectType = 'Bonus_data__c'])
        {
            if(rt.DeveloperName == 'BQ_Sales_Rep')
            {
                BQRep = rt.Id;
            }
            else if(rt.DeveloperName =='BQ_Sales_Supervisor')
            {
                BQSupervisor = rt.Id;
            }
            else if(rt.DeveloperName =='BQ_Regional_Manager')
            {
                BQRegional = rt.Id;
            }
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String repBody = '您好: <br><br>';
                    
            repBody += '系统已经为您完成奖金计算。请及时登录Baxter Salesforce.com CRM系统查看。<br>'; 

            repBody += '祝您工作愉快! <br>';
            repBody += '__________________________________________________ <br>';
            repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。<br>'; 
            repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>'; 
            User rep = [select Email from User where id =:UserInfo.getUserId()];
            String emailAddress = String.ValueOf(rep.Email);
            String[] repAddress =new string[]{emailAddress};
            mail.setToAddresses(repAddress);
            mail.setHtmlBody(repBody);
            mail.setSubject('奖金计算已完成，请查看');
            mail.setSaveAsActivity(false);//存为活动
            mail.setSenderDisplayName('Salesforce');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
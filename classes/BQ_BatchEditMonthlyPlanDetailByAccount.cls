/*
Author：Scott
Created on：2011-12-19
Description: 
1.批量编辑月计划明细按医院
2.如果月计划状态为审批通过则拜访目标为只读
*/
public  class BQ_BatchEditMonthlyPlanDetailByAccount {
	public List<MonthlyPlanDetailByAccount__c> mpdAcclist{get;set;}
	public String MonthlyPlanId{get;set;}
	public Boolean IsClose{get;set;}
	public Boolean Isdisable{get;set;}
	public BQ_BatchEditMonthlyPlanDetailByAccount()
	{
		 try
		{
			 IsClose=false;
			 MonthlyPlanId = ApexPages.currentPage().getParameters().get('mpid');
			 List<MonthlyPlan__c> mplist = [select Status__c from MonthlyPlan__c where Id=:MonthlyPlanId];
			 if(mplist != null && mplist.size()>0)
			 {
			 	if(mplist[0].Status__c =='审批通过')
				 {
				 	Isdisable= true;
				 }
				 else
				 {
				 	Isdisable= false;
				 }
				 SearchMpDetailAcc();	
			 }
			 else
			 {
			 	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , '您不能进行此操作，请联系系统管理员。');            
           		ApexPages.addMessage(msg);
            	return;
			 }
			 
		}catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , e.getmessage());            
            ApexPages.addMessage(msg);
            return;
		}						  
	}
	//查找
	public void SearchMpDetailAcc()
	{
		 mpdAcclist=[select Account__c,CallTarget__c,MonthlyBrief__c,
					 PlannedTimes__c,ActualTimes__c,MonthlyPlan__c
					 from MonthlyPlanDetailByAccount__c
					 where MonthlyPlan__c =: MonthlyPlanId];
       if(mpdAcclist == null || mpdAcclist.size()==0)
       {
       		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , '当前月计划没有月计划明细(按医院)，请您核实后再进行操作！');            
            ApexPages.addMessage(msg);
            return;
       }
	}
	//保存
	public void SaveMpDetailAcc()
	{
		try
		{
			if(mpdAcclist != null && mpdAcclist.size()>0)
			{
				update mpdAcclist;
				IsClose=true;
				//ReferenceMp();
			}
		}catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , e.getMessage());            
            ApexPages.addMessage(msg);
            return;
		}
	}
	//返回月计划
	public PageReference ReferenceMp()
	{
		PageReference pageRef = new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+MonthlyPlanId);
	    return pageRef;
	}
	/*******************************************************测试类****************************************************/
	static testMethod void BQ_BatchEditMonthlyPlanDetailByAccount()
	{
		/*月计划*/
		MonthlyPlan__c mp = new MonthlyPlan__c();
		mp.Year__c = '2014';
		mp.Month__c = '1';
		insert mp;
		
		MonthlyPlan__c mp1 = new MonthlyPlan__c();
		mp1.Year__c = '2014';
		mp1.Month__c = '1';
		insert mp1;
		/*客户*/
		RecordType accrecordtype = [select Id from RecordType where Name='医院' and SobjectType='Account' limit 1];
		Account acc = new Account();
		acc.RecordTypeId = accrecordtype.Id;
		acc.Name = 'AccTest';
		insert acc;
		/*明细按医院*/
		MonthlyPlanDetailByAccount__c mpdacc = new MonthlyPlanDetailByAccount__c();
		mpdacc.MonthlyPlan__c = mp.Id;
		mpdacc.Account__c = acc.Id;
		insert mpdacc;
		
		MonthlyPlan__c mp3 = new MonthlyPlan__c();
		mp3.Year__c = '2014';
		mp3.Month__c = '1';
		mp3.Status__c = '审批通过';
		insert mp3;
		MonthlyPlanDetailByAccount__c mpdacc3 = new MonthlyPlanDetailByAccount__c();
		mpdacc3.MonthlyPlan__c = mp3.Id;
		mpdacc3.Account__c = acc.Id;
		insert mpdacc3;
		Test.startTest();  
			try
			{
				ApexPages.currentPage().getParameters().put('mpid', '2323242424');
				BQ_BatchEditMonthlyPlanDetailByAccount bmpba4 = new BQ_BatchEditMonthlyPlanDetailByAccount();
				bmpba4.SearchMpDetailAcc();
			}catch(Exception e)
			{
				System.debug('您不能进行此操作，请联系系统管理员。'+String.valueOf(e));
			}
			ApexPages.currentPage().getParameters().put('mpid', mp3.Id);
			BQ_BatchEditMonthlyPlanDetailByAccount bmpba3 = new BQ_BatchEditMonthlyPlanDetailByAccount();
			bmpba3.SearchMpDetailAcc();
			 
			ApexPages.currentPage().getParameters().put('mpid', mp.Id);
			BQ_BatchEditMonthlyPlanDetailByAccount bmpba = new BQ_BatchEditMonthlyPlanDetailByAccount();
			bmpba.SearchMpDetailAcc();
			
			try
			{
				ApexPages.currentPage().getParameters().put('mpid', mp1.Id);
				BQ_BatchEditMonthlyPlanDetailByAccount bmpba2 = new BQ_BatchEditMonthlyPlanDetailByAccount();
				bmpba2.SearchMpDetailAcc();
			}catch(Exception e)
			{
				System.debug('与计划没有月计划明细按医院信息'+String.valueOf(e));
			}
			//保存
			bmpba.SaveMpDetailAcc();
			//返回月计划
			bmpba.ReferenceMp();
		Test.stopTest();
	}
}
/*
Author：Scott
Created on：2011-12-13
Description: 
1.批量编辑月计划明细计划次数
2.批量插入月计划明细计划次数
3.批量删除月计划明细计划次数
4.当插入联系人时自动将次联系人客户名称列出
*/
public with sharing class BQ_CtrlBatchEditMonthlyPlanDetail {
	public String MonthlyPlanId {get;set;}
	public List<MonthlyPlanDetail> ListMPD = new List<MonthlyPlanDetail>();
	public List<MonthlyPlanDetail> ListSearchMPD = new List<MonthlyPlanDetail>();
	public Boolean IsClose{get;set;}
	public List<MonthlyPlanDetail> getListMPD()
	{ 
		return ListMPD;
	} 
	public BQ_CtrlBatchEditMonthlyPlanDetail()
	{
		 IsClose= false;
		 MonthlyPlanId = ApexPages.currentPage().getParameters().get('mpid');
		 SearchMpDetail();							  
	}
	//查找
	public void SearchMpDetail()
	{
		List<MonthlyPlanDetail__c> mpdlist = [select Contact__c,Account__c,AdjustedTimes__c,ArrangedTimes__c,Planned_Finished_Calls__c
											  from MonthlyPlanDetail__c where MonthlyPlan__c =: MonthlyPlanId];
		if(mpdlist != null && mpdlist.size()>0)
		{ 
			for(MonthlyPlanDetail__c mpd:mpdlist)
			{
				MonthlyPlanDetail mpdsobj = new MonthlyPlanDetail();
				mpdsobj.IsDelete = false; 
				mpdsobj.IsNew = false;
				mpdsobj.MpDetail = mpd;
				ListSearchMPD.add(mpdsobj); 
				ListMPD = ListSearchMPD;
			}
		}	
		else 
		{	
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , '当前月计划没有月计划明细，请您核实后再进行操作！');            
            ApexPages.addMessage(msg);
            return;
		}	
	} 
	//添加
	public void AddMpDetail()
	{
		try
		{
			MonthlyPlanDetail mpdsobj = new MonthlyPlanDetail();
			MonthlyPlanDetail__c  mpd = new MonthlyPlanDetail__c();
			mpd.AdjustedTimes__c = 0;
			mpd.ArrangedTimes__c = 0;
			mpd.Planned_Finished_Calls__c = 0;
			mpdsobj.IsDelete = false;
			mpdsobj.IsNew = true;
			mpdsobj.MpDetail = mpd;
			ListMPD.add(mpdsobj);
		}
		catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , e.getmessage());            
            ApexPages.addMessage(msg);
            return;
		}  
	}
	//删除 
	public void DeleteMpDetail()
	{
		try
		{	
			List<MonthlyPlanDetail__c> deletempd = new List<MonthlyPlanDetail__c>();
			for(Integer i=ListMPD.size()-1;i>=0;i-- )
			{
				if(ListMPD[i].IsDelete)
				{
					if(!ListMPD[i].IsNew)
					{
						deletempd.add(ListMPD[i].MpDetail);
					}
					ListMPD.remove(i);
				}
			}
			delete deletempd;
		}catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , e.getmessage());            
            ApexPages.addMessage(msg);
            return;
		}
	}
	//保存
	public void SaveMpDetail()
	{
		try
		{
			List<MonthlyPlanDetail__c> updatempd = new List<MonthlyPlanDetail__c>();
			List<MonthlyPlanDetail__c> insertmpd = new List<MonthlyPlanDetail__c>();
			for(MonthlyPlanDetail mpd:ListMPD)
			{
				if( mpd.MpDetail.Account__c != null && mpd.MpDetail.Contact__c != null)
				{
					if(mpd.IsNew)
					{
						mpd.MpDetail.MonthlyPlan__c = MonthlyPlanId;
						insertmpd.add(mpd.MpDetail);
					}
					else 
					{
						updatempd.add(mpd.MpDetail);
					}
				}
			}
			update updatempd;
			if(insertmpd != null && insertmpd.size()>0)
			{
				insert insertmpd;
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM  , '成功插入'+insertmpd.Size()+'条数据。');            
           		ApexPages.addMessage(msg);
			}
			ListMPD.clear(); 
			SearchMpDetail();	
			IsClose = true;	
		}catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , e.getmessage());            
            ApexPages.addMessage(msg);
            return;
		}
	}
	//根据联系人查找客户
	public void SearchAcc()
	{
		try
		{
			Set<Id> ContactIds = new Set<Id>();
			for(MonthlyPlanDetail mpd:ListMPD)
			{
				if(mpd.IsNew)
				{
					Boolean flag = false;
					for(MonthlyPlanDetail searchmpd:ListMPD)
					{
						if(searchmpd.IsNew)
						{
							continue;
						}
						if(mpd.MpDetail.Contact__c == searchmpd.MpDetail.Contact__c)
						{
							flag = true;
						}
					}
					if(flag)
					{
						ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR  , '系统中已经存新加联系人的信息不能再次添加，此添加已清空，如有变动请修改已有记录！');            
		            	ApexPages.addMessage(msg);
		            	mpd.MpDetail.Contact__c = null;
		            	return;
					}
					else
					{
						ContactIds.add(mpd.MpDetail.Contact__c);
					}
				}
			}
			Map<ID, Contact> ContactMap = new Map<ID, Contact>([select id,AccountId  from Contact where Id in:ContactIds]);
			for(MonthlyPlanDetail mpd:ListMPD)
			{
				for(Id conid:ContactMap.keySet())
				{
					if(conid != mpd.MpDetail.Contact__c)
					{
						continue;
					}
					mpd.MpDetail.Account__c = ContactMap.get(conid).AccountId;
				}
			}
		}catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING  , e.getmessage());            
            ApexPages.addMessage(msg);
            return;	
		}
		
	}
	public class MonthlyPlanDetail
	{
		public Boolean IsDelete{get;set;}
		public Boolean IsNew{get;set;}
		public MonthlyPlanDetail__c MpDetail{get;set;}
	}
	/*******************************************************测试类****************************************************/
	static testMethod void BQ_CtrlBatchEditMonthlyPlanDetail()
	{
		/*月计划*/
		MonthlyPlan__c mp = new MonthlyPlan__c();
		mp.Year__c = '2014';
		mp.Month__c = '1';
		insert mp;
		
		MonthlyPlan__c mp1 = new MonthlyPlan__c();
		mp1.Year__c = '2013';
		mp1.Month__c = '12';
		insert mp1;
		/*客户*/
		RecordType accrecordtype = [select Id from RecordType where Name='医院' and SobjectType='Account' limit 1];
		Account acc = new Account();
		acc.RecordTypeId = accrecordtype.Id;
		acc.Name = 'AccTest';
		insert acc;
		/*联系人*/
		RecordType conrecordtype = [select Id from RecordType where Name = 'BQ_Contact' and SobjectType='Contact' and IsActive = true limit 1 ];
		Contact con1 = new Contact();
		con1.LastName = 'AccTestContact1';
		con1.AccountId=acc.Id;
		insert con1;
		
		Contact con2 = new Contact();
		con2.LastName = 'AccTestContact2';
		con2.AccountId=acc.Id;
		insert con2;
		/*月计划明细*/
		MonthlyPlanDetail__c mpd1 = new MonthlyPlanDetail__c();
		mpd1.Contact__c = con1.Id;
		mpd1.Account__c = acc.Id;
		mpd1.MonthlyPlan__c = mp.Id;
		mpd1.ArrangedTimes__c = 5;
		mpd1.AdjustedTimes__c = 6;
		mpd1.Planned_Finished_Calls__c = 5;
		insert mpd1;
		
		Test.startTest();   
		ApexPages.currentPage().getParameters().put('mpid', mp.Id);
		BQ_CtrlBatchEditMonthlyPlanDetail bempd = new BQ_CtrlBatchEditMonthlyPlanDetail();
		
		//添加
		bempd.AddMpDetail();
		//删除
		bempd.AddMpDetail();
		MonthlyPlanDetail mpd = bempd.getListMPD()[bempd.getListMPD().size()-1];
		mpd.IsDelete = true;
		
		bempd.DeleteMpDetail();
		//查找客户&check联系人
		bempd.AddMpDetail();
		MonthlyPlanDetail checkmpd1 = bempd.getListMPD()[bempd.getListMPD().size()-1];
		checkmpd1.MpDetail.Contact__c = con2.Id;
		bempd.SearchAcc();
		try
		{
			bempd.AddMpDetail();
			MonthlyPlanDetail checkmpd2 = bempd.getListMPD()[bempd.getListMPD().size()-1];
			checkmpd2.MpDetail.Contact__c = con1.Id;
			bempd.SearchAcc();
		}catch(Exception e)
		{
			System.debug('重复联系人提示信息'+String.valueOf(e));
		}
		
		//保存
		bempd.SaveMpDetail();
		try
		{
			ApexPages.currentPage().getParameters().put('mpid', mp1.Id);
			BQ_CtrlBatchEditMonthlyPlanDetail bempd1 = new BQ_CtrlBatchEditMonthlyPlanDetail();
			bempd.getListMPD();
		}	
		catch(Exception e)
		{
			System.debug('次月计划没有月计划明细提示信息'+String.valueOf(e));
		}
		Test.stopTest();
	}
}
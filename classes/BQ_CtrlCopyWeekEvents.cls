public with sharing class BQ_CtrlCopyWeekEvents {
	public String LastDate{get;set;}
	public String ThisDate{get;set;}
	public List<SobjEvent> Listsobjev = new List<SobjEvent>();
	public Id UserId;
	public List<SobjEvent> getListsobjev()
	{
		return Listsobjev;
	}
	public BQ_CtrlCopyWeekEvents ()
	{
		Listsobjev.clear();
		UserId = UserInfo.getUserId();
		LastDate = String.valueOf(date.today().addDays(-7));
		ThisDate = String.valueOf(date.today());
		SearchEvents();
	}
	//查询
	public void SearchEvents()
	{
    	try
    	{
    		Listsobjev.clear();
	    	if(LastDate == null)
	    	{
	    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '您还没有选择查询时间！');    		
	    		ApexPages.addMessage(msg);
	    	    return;
	    	}
	    	List<DateTime> listdatetimes = getDateTime(Date.valueOf(LastDate));
	    	List<Event> evlist = [select Id,whoId,StartDateTime,EndDateTime,GAPlan__c,GAExecuteResult__c,Done__c,SubjectType__c,Subject,V2_CampaignCallType__c,WhatId  
	    						  from Event where  whoId != null and OwnerId =: UserId and IsRecurrence != true
	    						  and StartDateTime>=:listdatetimes[0] and StartDateTime <=:listdatetimes[1] and RecordType.DeveloperName = 'V2_Event' and SubjectType__c='拜访' order by StartDateTime asc];
	    	if(evlist==null || evlist.Size()==0)
	    	{
	    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, '所选周没有拜访事件！');    		
	    		ApexPages.addMessage(msg);
	    	    return;
	    	}
	    	else
	    	{
	    		for(Event ev:evlist)
		    	{
		    		SobjEvent sobjev = new SobjEvent();
		    		sobjev.IsChoice = true;
		    		sobjev.ev = ev;
		    		Listsobjev.add(sobjev);
		    	}
	    	}
    	}catch(Exception e)
    	{
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getmessage());    		
    		ApexPages.addMessage(msg);
    	    return;
    	}
	}
	//copy
	public void CopyEvents()
	{
		try
		{
			List<Event> InsertEvents = new List<Event>();
			Date startdate = date.valueOf(LastDate).toStartOfWeek().addDays(1);
			Date enddate = startdate.addDays(6);
			if(date.valueOf(LastDate) == null || ThisDate ==null || date.valueOf(ThisDate)< date.valueOf(LastDate))
			{
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,'您输入的日期不正确请检查后再操作！');
	    		ApexPages.addMessage(msg);
	    	    return;
			}
			else if(date.valueOf(ThisDate)>= startdate && date.valueOf(ThisDate) <= enddate )
			{
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,'您所选的复制日期在查询日期  '+LastDate+'所在周范围内！');
	    		ApexPages.addMessage(msg);
	    	    return;
			}
			else
			{
				Integer days = date.valueOf(LastDate).toStartOfWeek().daysBetween(date.valueOf(ThisDate).toStartOfWeek());
				RecordType callRt = [Select Id from RecordType where DeveloperName = 'V2_Event' Limit 1];
				//System.debug('##################################间隔时间为'+ days);
				for(SobjEvent se:Listsobjev)
				{
					if(se.IsChoice)
					{
						Event evens = new Event();
						/********2012-2-9修改*********/
						evens.RecordTypeId = callRt.Id;
						/********2012-2-9修改*********/
						evens.WhoId = se.ev.WhoId;
						evens.WhatId =se.ev.WhatId;
						evens.StartDateTime =se.ev.StartDateTime.addDays(days);
						evens.EndDateTime = se.ev.EndDateTime.addDays(days);
						evens.SubjectType__c = se.ev.SubjectType__c;
						evens.Subject =se.ev.Subject;
						//evens.V2_CampaignCallType__c = se.ev.V2_CampaignCallType__c;
						if(se.ev.GAExecuteResult__c != null )
						{
							evens.GAPlan__c = se.ev.GAExecuteResult__c;
						}
						InsertEvents.add(evens);
					}
				}
				insert InsertEvents;
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'您成功复制了'+InsertEvents.size()+'条事件。');
	    		ApexPages.addMessage(msg);
				Listsobjev.clear();
				LastDate = ThisDate;
				ThisDate = null;
				SearchEvents();
			}
		}
		catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING ,e.getmessage());
    		ApexPages.addMessage(msg);
    		return;
		}
	}
	//获得所有时间
	public List<DateTime> getDateTime(Date selectdate)
	{
		List<DateTime> listdatetimes = new List<DateTime>();
		try
		{
			//周一至 周日
			
			DateTime startDateOfWeek = DateTime.newInstance(selectdate.toStartOfWeek(),Time.newInstance(23, 59, 59, 59));
			DateTime endDateOfWeek =startDateOfWeek.addDays(7);
	    	listdatetimes.add(startDateOfWeek);
	    	listdatetimes.add(endDateOfWeek);
	    	
		}
		catch(Exception e)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING ,e.getmessage());
    		ApexPages.addMessage(msg);
		}
		return listdatetimes;
		
	}
	public class SobjEvent
	{
		public boolean IsChoice{get;set;}
		public Event ev{get;set;}
	}
	
	/***************************测试类*********************************/
	
	static testMethod void BQ_CtrlCopyWeekEvents()
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
		con1.LastName = 'AccTestContact1';
		con1.AccountId=acc.Id;
		insert con1;
		
		Contact con2 = new Contact();
		con2.LastName = 'AccTestContact2';
		con2.AccountId=acc.Id;
		insert con2;
		/*业务机会*/
		Opportunity opp = new Opportunity();
		opp.Name = 'OppTest';
		opp.AccountId = acc.Id;
		opp.StageName = '发现/验证机会';
		opp.Type = '其他';
		opp.CloseDate = date.today().addmonths(1);
		insert opp;
		
		Opportunity opp1 = new Opportunity();
		opp1.Name = 'OppTest1';
		opp1.AccountId = acc.Id;
		opp1.StageName = '发现/验证机会';
		opp1.Type = '其他';
		opp1.CloseDate = date.today().addmonths(1);
		insert opp1;
		/*市场活动*/
		Campaign cam = new Campaign();
		cam.Name = 'CamTest';
		cam.StartDate = date.today().addMonths(1);
		cam.EndDate = date.today().addMonths(2);
		cam.IsActive = true;
		insert cam;
		/*拜访事件*/
		RecordType callRt = [Select Id from RecordType where DeveloperName = 'V2_Event' Limit 1];
		
		Event CallEv = new Event();
		CallEv.RecordTypeId = callRt.Id;
		CallEv.WhoId = con1.Id;
		CallEv.StartDateTime = datetime.now();
		CallEv.EndDateTime = datetime.now().addMinutes(1);
		CallEv.SubjectType__c = '拜访';
		insert CallEv;
		
		Event CallEv2 = new Event();
		CallEv2.RecordTypeId = callRt.Id;
		CallEv2.WhoId = con1.Id;
		CallEv2.StartDateTime = datetime.now();
		CallEv2.EndDateTime = datetime.now().addMinutes(1);
		CallEv2.WhatId = opp1.Id;
		CallEv2.SubjectType__c = '拜访';
		insert CallEv2;
		Event CallEv3 = new Event();
		CallEv3.RecordTypeId = callRt.Id;
		CallEv3.WhoId = con1.Id;
		CallEv3.StartDateTime = datetime.now();
		CallEv3.EndDateTime = datetime.now().addMinutes(1);
		CallEv3.WhatId = cam.Id;
		CallEv3.V2_FollowEventFlag__c = true;
		CallEv3.SubjectType__c = '拜访';
		insert CallEv3;
		
		Test.startTest();
		BQ_CtrlCopyWeekEvents ccwe = new BQ_CtrlCopyWeekEvents();
		//选择时间为空
		ccwe.LastDate = null;
		try
		{
			ccwe.SearchEvents();
		}catch(Exception e)
		{
			System.debug('时间为空报错'+String.valueOf(e));
		}
		//所选周没有事件
		ccwe.LastDate = String.valueOf(date.today().addYears(-10));
		try
		{
			ccwe.SearchEvents();
		}catch(Exception e)
		{
			System.debug('所选周没有事件'+String.valueOf(e));
		}
		//查询
		ccwe.LastDate = String.valueOf(Date.today());
		ccwe.SearchEvents();
		//目标周为空
		ccwe.ThisDate = null;
		try
		{
			ccwe.CopyEvents();
		}catch(Exception e)
		{
			System.debug('目标周为空报错'+String.valueOf(e));
		}
		//目标周
		ccwe.ThisDate = String.valueOf(date.today().addDays(8));
		ccwe.CopyEvents();
		Test.stopTest();
	}
}
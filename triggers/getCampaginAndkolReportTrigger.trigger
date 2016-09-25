/*
Author:Dean
Date:2016-1-18
Function:将MA的市场活动成员的KOL信息和市场活动的基本信息汇总到报表对象上。
 */
trigger getCampaginAndkolReportTrigger on CampaignMember(after insert,after update,after delete) {
	
	private Set<id> contactIdSet = new Set<id>();
	private Map<String,Campaign> campaignMap = new Map<String,Campaign>();
	private Map<String,List<KOLScore__c>> kolScoreMap;
	private Map<String,List<KOLReport__c>> kolReportMap;
	private List<KOLReport__c> insertList;
	private List<KOLReport__c> updateList;
	private List<KOLReport__c> deleteList;

	//公共
	if(trigger.isInsert || trigger.isUpdate)
	{
		for(CampaignMember obj:trigger.new)
		{
			contactIdSet.add(obj.ContactId);
		}
	
		List<Campaign> tempList = [select id,StartDate from Campaign where RecordType.DeveloperName = 'MA_Campaign'];
		for(Campaign obj:tempList)
		{
			campaignMap.put(obj.id, obj);
		}
	}
	

	if(trigger.isInsert)
	{		
		kolScoreMap = new Map<String,List<KOLScore__c>>();
		insertList = new List<KOLReport__c>();
		List<KOLScore__c> kolList =[select id,KOL__c,MA_Academic__c,PD_scientificResearch__c,PD_Teaching__c,PDscale__c,PD_brandAccept__c,
                  isCOE__c,PDspeaker__c,PD_updateYear__c,PDLastModifier__c,PDLastModifyDate__c,PD_KOL__c,PDTotal__c,
                  HD_scientificResearch__c,HD_Teaching__c,HDscale__c,HD_brandAccept__c,HDMachineRatio__c,HDdialyzerRatio__c,
                  HD_updateYear__c,HDspeaker__c,HDLastModifier__c,HDLastModifyDate__c,HD_KOL__c,HDTotal__c,
                  Acute_scientificResearch__c,Acute_Teaching__c,Acute_brandAccept__c,AcuteMachineRatio__c,AcuteCRRTTimes__c,
                  AcuteSpeaker__c,Acute_updateYear__c,AcuteLastModifier__c,AcuteLastModifyDate__c,Acute_KOL__c,AcuteTotal__c  
                  from KOLScore__c where  KOL__c IN:contactIdSet];

		for(KOLScore__c kol:kolList)
		{
			if(!kolScoreMap.containsKey(kol.KOL__c))
			{
				kolScoreMap.put(kol.KOL__c,new List<KOLScore__c>());
			}
			List<KOLScore__c> slist = kolScoreMap.get(kol.KOL__c);
			slist.add(kol);
			kolScoreMap.put(kol.KOL__c,slist);
		}

		

		for(CampaignMember obj:trigger.new)
		{
			if(!campaignMap.containsKey(obj.CampaignId))
			{
				continue;
			}
			Date da = campaignMap.get(obj.CampaignId).StartDate;
			if(da == null)
			{
				continue;
			}
			String currentyear = da.month()>7?da.year()+'下半年' : da.year()+'上半年';
			if(!kolScoreMap.containsKey(obj.ContactId))
			{
				continue;
			}
			for(KOLScore__c score:kolScoreMap.get(obj.ContactId))
			{

				if(score.PD_updateYear__c != null && score.PD_updateYear__c == currentyear)
				{
					KOLReport__c pd = new KOLReport__c();
					pd.KOLName__c = score.KOL__c; //联系人
					pd.BU__c = 'PD'; 
					pd.Academic__c = string.valueOf(score.MA_Academic__c);
					pd.scientificResearch__c = score.PD_scientificResearch__c;//科研能力
					pd.Teaching__c = score.PD_Teaching__c;//讲课能力
					pd.brandAccept__c = score.PD_brandAccept__c;//品牌认可度
					pd.isCOE__c = score.isCOE__c;
					pd.PDscale__c = score.PDscale__c;
					pd.iskol__c = score.PD_KOL__c;
					pd.IsSpeaker__c = score.PDspeaker__c;
					pd.Total__c = score.PDTotal__c;
					pd.updateYear__c = score.PD_updateYear__c;
					pd.campaignStartDate__c = da;
					pd.campagin__c = obj.CampaignId;
					pd.topic__c = obj.MA_SpeechTitle__c;
					pd.speaker__c =obj.MA_Speaker__c;
					pd.isChief__c = obj.MA_Chief__c;
					pd.dataType__c = '市场活动';
					insertList.add(pd);
				}

				if(score.HD_updateYear__c != null && score.HD_updateYear__c == currentyear)
				{
					KOLReport__c hd = new KOLReport__c();
					hd.KOLName__c = score.KOL__c; //联系人
					hd.BU__c = 'HD'; 
					hd.Academic__c = string.valueOf(score.MA_Academic__c);
					hd.scientificResearch__c = score.HD_scientificResearch__c;//科研能力
					hd.Teaching__c = score.HD_Teaching__c;//讲课能力
					hd.brandAccept__c = score.HD_brandAccept__c;//品牌认可度
					hd.iskol__c = score.HD_KOL__c;
					hd.IsSpeaker__c = score.HDspeaker__c;
					hd.Total__c = score.HDTotal__c;
					hd.HDscale__c = score.HDscale__c;
					hd.MachineRatio__c = score.HDMachineRatio__c;
					hd.dialyzerRatio__c = score.HDdialyzerRatio__c;
					hd.updateYear__c = score.HD_updateYear__c;
					hd.campaignStartDate__c = da;
					hd.campagin__c = obj.CampaignId;
					hd.topic__c = obj.MA_SpeechTitle__c;
					hd.speaker__c =obj.MA_Speaker__c;
					hd.isChief__c = obj.MA_Chief__c;
					hd.dataType__c= '市场活动';
					insertList.add(hd);
				}

				if(score.Acute_updateYear__c != null && score.Acute_updateYear__c == currentyear)
				{
					KOLReport__c acute= new KOLReport__c();
					acute.KOLName__c = score.KOL__c; //联系人
					acute.BU__c = 'Acute'; 
					acute.Academic__c = string.valueOf(score.MA_Academic__c);
					acute.scientificResearch__c = score.Acute_scientificResearch__c;//科研能力
					acute.Teaching__c = score.Acute_Teaching__c;//讲课能力
					acute.brandAccept__c = score.Acute_brandAccept__c;//品牌认可度
					acute.iskol__c = score.Acute_KOL__c;
					acute.IsSpeaker__c = score.Acutespeaker__c;
					acute.Total__c = score.AcuteTotal__c;
					acute.AcuteCRRTTimes__c = score.AcuteCRRTTimes__c;
					acute.AcuteMachineRatio__c = score.AcuteMachineRatio__c;
					acute.updateYear__c = score.Acute_updateYear__c;
					acute.campaignStartDate__c = da;
					acute.topic__c = obj.MA_SpeechTitle__c;
					acute.speaker__c =obj.MA_Speaker__c;
					acute.isChief__c = obj.MA_Chief__c;
					acute.campagin__c = obj.CampaignId;
					acute.dataType__c= '市场活动';
					insertList.add(acute);
				}
			}

		}

		if(insertList.size() > 0)
		{
			insert insertList;
		}
		

	}

	if(trigger.isUpdate)
	{
		//找出联系人对应的所有市场活动的报表
		kolReportMap = new Map<String,List<KOLReport__c>>();
		updateList = new List<KOLReport__c>();
		List<KOLReport__c> reportList = [select id,KOLName__c,BU__c,dataType__c,updateYear__c,campaignStartDate__c,
											topic__c,speaker__c,isChief__c,campagin__c  from KOLReport__c where KOLName__c IN:contactIdSet and dataType__c = '市场活动'];
		for(KOLReport__c obj:reportList)
		{
			if(!kolReportMap.containsKey(obj.KOLName__c))
			{
				kolReportMap.put(obj.KOLName__c, new List<KOLReport__c>());
			}
			List<KOLReport__c> objlist = kolReportMap.get(obj.KOLName__c);
			objlist.add(obj);
			kolReportMap.put(obj.KOLName__c,objlist);
		}

		for(CampaignMember member:trigger.new)
		{
			if(!campaignMap.containsKey(member.CampaignId))
			{
				continue;
			}
			Date da = campaignMap.get(member.CampaignId).StartDate;
			if(da == null)
			{
				continue;
			}
			String currentyear = da.month()>7?da.year()+'下半年' : da.year()+'上半年';
			if(!kolReportMap.containsKey(member.ContactId))
			{
				continue;
			}
			for(KOLReport__c re:kolReportMap.get(member.ContactId))
			{
				if(re.BU__c == 'PD' && re.dataType__c == '市场活动' && re.campagin__c == member.CampaignId  && re.updateYear__c == currentyear)
				{					
					re.campaignStartDate__c = da;
					re.topic__c = member.MA_SpeechTitle__c;
					re.speaker__c =member.MA_Speaker__c;
					re.isChief__c = member.MA_Chief__c;
					updateList.add(re);
				}

				if(re.BU__c == 'HD' && re.dataType__c == '市场活动' && re.campagin__c == member.CampaignId && re.updateYear__c == currentyear)
				{
					re.campaignStartDate__c = da;
					re.topic__c = member.MA_SpeechTitle__c;
					re.speaker__c =member.MA_Speaker__c;
					re.isChief__c = member.MA_Chief__c;
					updateList.add(re);
				}

				if(re.BU__c == 'Acute' && re.dataType__c == '市场活动' && re.campagin__c == member.CampaignId  && re.updateYear__c == currentyear)
				{
					re.campaignStartDate__c = da;
					re.topic__c = member.MA_SpeechTitle__c;
					re.speaker__c =member.MA_Speaker__c;
					re.isChief__c = member.MA_Chief__c;
					updateList.add(re);
				}
			}

			if(updateList.size() > 0)
			{
				update updateList;
			}
			
		}
	}

	if(trigger.isDelete)
	{

		for(CampaignMember obj:trigger.old)
		{
			contactIdSet.add(obj.ContactId);
		}
	
		List<Campaign> camList = [select id,StartDate from Campaign where RecordType.DeveloperName = 'MA_Campaign'];
		for(Campaign obj:camList)
		{
			campaignMap.put(obj.id, obj);
		}

		kolReportMap = new Map<String,List<KOLReport__c>>();
		deleteList = new List<KOLReport__c>();
		List<KOLReport__c> reportList = [select id,KOLName__c,BU__c,dataType__c,updateYear__c,campaignStartDate__c,
											topic__c,speaker__c,isChief__c,campagin__c  from KOLReport__c where KOLName__c IN:contactIdSet and dataType__c = '市场活动'];
		for(KOLReport__c obj:reportList)
		{
			if(!kolReportMap.containsKey(obj.KOLName__c))
			{
				kolReportMap.put(obj.KOLName__c, new List<KOLReport__c>());
			}
			List<KOLReport__c> objlist = kolReportMap.get(obj.KOLName__c);
			objlist.add(obj);
			kolReportMap.put(obj.KOLName__c,objlist);
		}

		for(CampaignMember member:trigger.old)
		{
			if(!campaignMap.containsKey(member.CampaignId))
			{
				continue;
			}
			Date da = campaignMap.get(member.CampaignId).StartDate;
			if(da == null)
			{
				continue;
			}
			String currentyear = da.month()>7?da.year()+'下半年' : da.year()+'上半年';
			if(!kolReportMap.containsKey(member.ContactId))
			{
				continue;
			}
			for(KOLReport__c re:kolReportMap.get(member.ContactId))
			{
				if(re.BU__c == 'PD' && re.dataType__c == '市场活动' && re.campagin__c == member.CampaignId  && re.updateYear__c == currentyear)
				{					
					deleteList.add(re);
				}

				if(re.BU__c == 'HD' && re.dataType__c == '市场活动' && re.campagin__c == member.CampaignId  && re.updateYear__c == currentyear)
				{
					deleteList.add(re);
				}

				if(re.BU__c == 'Acute' && re.dataType__c == '市场活动' && re.campagin__c == member.CampaignId  && re.updateYear__c == currentyear)
				{
					deleteList.add(re);
				}
			}
			
			if(deleteList.size() > 0)
			{
				delete deleteList;
			}
			
		}
	}
}
/*
Author:Dean
Date:2016-1-14
Function:新建KOL评分时，将医生大数据和联系人的数据与KOL评分组合，赋值到KOL报表对象上
 */
trigger getKolScoreReportData on KOLScore__c (after insert,after update) {
	private Map<String,List<String>> chineseMap = new Map<String,List<String>>();//中文文献
	private Map<String,List<String>> englishMap = new Map<String,List<String>>();//英文文献
	private Map<String,List<String>> meettingMap = new Map<String,List<String>>();//会议信息
	private Map<String,List<String>> scienceMap = new Map<String,List<String>>();//临床试验
	private Map<String,List<String>> nsfcMap = new Map<String,List<String>>();//自然科学基金
	private Map<String,List<KOLReport__c>> reportMap =  new Map<String,List<KOLReport__c>>();
	private List<KOLReport__c> insertList = new List<KOLReport__c>();
	private List<KOLReport__c> updateList = new List<KOLReport__c>();

	if(trigger.isInsert)
	{	
		//取联系人ID，和医生大数据ID组合Map
		List<DoctorInfoBigData__c> chinesePaperList = new List<DoctorInfoBigData__c>();
		chinesePaperList = [select id,ContactId__c from DoctorInfoBigData__c 
							where datesource__c = '丁香园' and dateType__c = '中文文献' ];
    	if(chinesePaperList.size() != 0)
    	{
    		getMap(chinesePaperList,chineseMap);
    	}
    	
    	List<DoctorInfoBigData__c> englishPaperList = new List<DoctorInfoBigData__c>();
    	englishPaperList = [select id,ContactId__c from DoctorInfoBigData__c 
    						where datesource__c = '丁香园' and dateType__c = '英文文献'];
    	if(englishPaperList.size() != 0)
    	{
    		getMap(englishPaperList,englishMap);
    	}
    	
    	List<DoctorInfoBigData__c> nsfcList = new List<DoctorInfoBigData__c>();
    	nsfcList = [select id,ContactId__c from DoctorInfoBigData__c 
    				where datesource__c = '丁香园' and dateType__c = '自然科学基金'];
    	if(nsfcList.size() != 0)
    	{
    		getMap(nsfcList,nsfcMap);
    	}

    	List<DoctorInfoBigData__c> clinicList = new List<DoctorInfoBigData__c>();
    	clinicList = [select id,ContactId__c from DoctorInfoBigData__c 
    				 where datesource__c = '丁香园' and dateType__c = '临床试验'];
    	if(clinicList.size() != 0)
    	{
    		getMap(clinicList,scienceMap);
    	}


    	List<DoctorInfoBigData__c> meetingList = new List<DoctorInfoBigData__c>();
    	meetingList = [select id,ContactId__c from DoctorInfoBigData__c 
    				  where datesource__c = '丁香园'  and dateType__c = '会议'];
    	if(meetingList.size() != 0)
    	{
    		getMap(meetingList,meettingMap);
    	}	



		for(KOLScore__c obj:trigger.new)
		{
			//PD的KOL评分
			if(obj.PD_updateYear__c != null)
			{
				//新建一个评分对应建立一条评分与联系人的记录
				KOLReport__c pdContact = new KOLReport__c();
				pdContact.KOLName__c = obj.KOL__c; //联系人
				pdContact.BU__c = 'PD'; 
				pdContact.Academic__c = string.valueOf(obj.MA_Academic__c);
				pdContact.scientificResearch__c = obj.PD_scientificResearch__c;//科研能力
				pdContact.Teaching__c = obj.PD_Teaching__c;//讲课能力
				pdContact.brandAccept__c = obj.PD_brandAccept__c;//品牌认可度
				pdContact.isCOE__c = obj.isCOE__c;
				pdContact.PDscale__c = obj.PDscale__c;
				pdContact.iskol__c = obj.PD_KOL__c;
				pdContact.IsSpeaker__c = obj.PDspeaker__c;
				pdContact.Total__c = obj.PDTotal__c;
				pdContact.updateYear__c = obj.PD_updateYear__c;
				pdContact.dataType__c = '联系人';
				insertList.add(pdContact);

				//中文文献
				if(chineseMap.containsKey(obj.KOL__c))
				{
					for(String dataId:chineseMap.get(obj.KOL__c))
					{
						KOLReport__c pd = new KOLReport__c();
						pd.KOLName__c = obj.KOL__c; //联系人
						pd.BU__c = 'PD'; 
						pd.Academic__c = string.valueOf(obj.MA_Academic__c);
						pd.scientificResearch__c = obj.PD_scientificResearch__c;//科研能力
						pd.Teaching__c = obj.PD_Teaching__c;//讲课能力
						pd.brandAccept__c = obj.PD_brandAccept__c;//品牌认可度
						pd.isCOE__c = obj.isCOE__c;
						pd.PDscale__c = obj.PDscale__c;
						pd.iskol__c = obj.PD_KOL__c;
						pd.IsSpeaker__c = obj.PDspeaker__c;
						pd.Total__c = obj.PDTotal__c;
						pd.updateYear__c = obj.PD_updateYear__c;
						pd.kolData__c = dataId; //丁香园数据
						pd.dataType__c = '中文文献';
						insertList.add(pd);					
					}
				}
				

				//英文文献
				if(englishMap.containsKey(obj.KOL__c))
				{
					for(String dataId:englishMap.get(obj.KOL__c))
					{
						KOLReport__c pd = new KOLReport__c();
						pd.KOLName__c = obj.KOL__c; //联系人
						pd.BU__c = 'PD'; 
						pd.Academic__c = string.valueOf(obj.MA_Academic__c);
						pd.scientificResearch__c = obj.PD_scientificResearch__c;//科研能力
						pd.Teaching__c = obj.PD_Teaching__c;//讲课能力
						pd.brandAccept__c = obj.PD_brandAccept__c;//品牌认可度
						pd.isCOE__c = obj.isCOE__c;
						pd.PDscale__c = obj.PDscale__c;
						pd.iskol__c = obj.PD_KOL__c;
						pd.IsSpeaker__c = obj.PDspeaker__c;
						pd.Total__c = obj.PDTotal__c;
						pd.updateYear__c = obj.PD_updateYear__c;
						pd.kolData__c = dataId;//丁香园数据
						pd.dataType__c = '英文文献';
						insertList.add(pd);
					}
				}

				//自然科学基金
				if(nsfcMap.containsKey(obj.KOL__c))
				{
					for(String dataId:nsfcMap.get(obj.KOL__c))
					{
						KOLReport__c pd = new KOLReport__c();
						pd.KOLName__c = obj.KOL__c; //联系人
						pd.BU__c = 'PD'; 
						pd.Academic__c = string.valueOf(obj.MA_Academic__c);
						pd.scientificResearch__c = obj.PD_scientificResearch__c;//科研能力
						pd.Teaching__c = obj.PD_Teaching__c;//讲课能力
						pd.brandAccept__c = obj.PD_brandAccept__c;//品牌认可度
						pd.isCOE__c = obj.isCOE__c;
						pd.PDscale__c = obj.PDscale__c;
						pd.iskol__c = obj.PD_KOL__c;
						pd.IsSpeaker__c = obj.PDspeaker__c;
						pd.Total__c = obj.PDTotal__c;
						pd.updateYear__c = obj.PD_updateYear__c;
						pd.kolData__c = dataId;//丁香园数据
						pd.dataType__c= '自然科学基金';
						insertList.add(pd);
					}
				}

				//临床试验
				if(scienceMap.containsKey(obj.KOL__c))
				{
					for(String dataId:scienceMap.get(obj.KOL__c))
					{
						KOLReport__c pd = new KOLReport__c();
						pd.KOLName__c = obj.KOL__c; //联系人
						pd.BU__c = 'PD'; 
						pd.Academic__c = string.valueOf(obj.MA_Academic__c);
						pd.scientificResearch__c = obj.PD_scientificResearch__c;//科研能力
						pd.Teaching__c = obj.PD_Teaching__c;//讲课能力
						pd.brandAccept__c = obj.PD_brandAccept__c;//品牌认可度
						pd.isCOE__c = obj.isCOE__c;
						pd.PDscale__c = obj.PDscale__c;
						pd.iskol__c = obj.PD_KOL__c;
						pd.IsSpeaker__c = obj.PDspeaker__c;
						pd.Total__c = obj.PDTotal__c;
						pd.updateYear__c = obj.PD_updateYear__c;
						pd.kolData__c = dataId;//丁香园数据
						pd.dataType__c= '临床试验';
						insertList.add(pd);
					}
				}
				
				//会议信息
				if(meettingMap.containsKey(obj.KOL__c))
				{
					for(String dataId:meettingMap.get(obj.KOL__c))
					{
						KOLReport__c pd = new KOLReport__c();
						pd.KOLName__c = obj.KOL__c; //联系人
						pd.BU__c = 'PD'; 
						pd.Academic__c = string.valueOf(obj.MA_Academic__c);
						pd.scientificResearch__c = obj.PD_scientificResearch__c;//科研能力
						pd.Teaching__c = obj.PD_Teaching__c;//讲课能力
						pd.brandAccept__c = obj.PD_brandAccept__c;//品牌认可度
						pd.isCOE__c = obj.isCOE__c;
						pd.PDscale__c = obj.PDscale__c;
						pd.iskol__c = obj.PD_KOL__c;
						pd.IsSpeaker__c = obj.PDspeaker__c;
						pd.Total__c = obj.PDTotal__c;
						pd.updateYear__c = obj.PD_updateYear__c;
						pd.kolData__c = dataId;//丁香园数据
						pd.dataType__c= '会议信息';
						insertList.add(pd);
					}
				}
				
			}

			//HD的KOL评分
			if(obj.HD_updateYear__c != null)
			{
				//HD的联系人与评分信息
				KOLReport__c hdContact = new KOLReport__c();
				hdContact.KOLName__c = obj.KOL__c; //联系人
				hdContact.BU__c = 'HD'; 
				hdContact.Academic__c = string.valueOf(obj.MA_Academic__c);
				hdContact.scientificResearch__c = obj.HD_scientificResearch__c;//科研能力
				hdContact.Teaching__c = obj.HD_Teaching__c;//讲课能力
				hdContact.brandAccept__c = obj.HD_brandAccept__c;//品牌认可度
				hdContact.iskol__c = obj.HD_KOL__c;
				hdContact.IsSpeaker__c = obj.HDspeaker__c;
				hdContact.Total__c = obj.HDTotal__c;
				hdContact.HDscale__c = obj.HDscale__c;
				hdContact.MachineRatio__c = obj.HDMachineRatio__c;
				hdContact.dialyzerRatio__c = obj.HDdialyzerRatio__c;
				hdContact.updateYear__c = obj.HD_updateYear__c;
				hdContact.dataType__c= '联系人';
				insertList.add(hdContact);

				//中文文献
				if(chineseMap.containsKey(obj.KOL__c))
				{
					for(String dataId:chineseMap.get(obj.KOL__c))
					{
						KOLReport__c hd = new KOLReport__c();
						hd.KOLName__c = obj.KOL__c; //联系人
						hd.BU__c = 'HD'; 
						hd.Academic__c = string.valueOf(obj.MA_Academic__c);
						hd.scientificResearch__c = obj.HD_scientificResearch__c;//科研能力
						hd.Teaching__c = obj.HD_Teaching__c;//讲课能力
						hd.brandAccept__c = obj.HD_brandAccept__c;//品牌认可度
						hd.iskol__c = obj.HD_KOL__c;
						hd.IsSpeaker__c = obj.HDspeaker__c;
						hd.Total__c = obj.HDTotal__c;
						hd.HDscale__c = obj.HDscale__c;
						hd.MachineRatio__c = obj.HDMachineRatio__c;
						hd.dialyzerRatio__c = obj.HDdialyzerRatio__c;
						hd.updateYear__c = obj.HD_updateYear__c;
						hd.kolData__c = dataId; //丁香园数据
						hd.dataType__c = '中文文献';
						insertList.add(hd);
					}
				}
				

				//英文文献
				if(englishMap.containsKey(obj.KOL__c))
				{
					for(String dataId:englishMap.get(obj.KOL__c))
					{
						KOLReport__c hd = new KOLReport__c();
						hd.KOLName__c = obj.KOL__c; //联系人
						hd.BU__c = 'HD'; 
						hd.Academic__c = string.valueOf(obj.MA_Academic__c);
						hd.scientificResearch__c = obj.HD_scientificResearch__c;//科研能力
						hd.Teaching__c = obj.HD_Teaching__c;//讲课能力
						hd.brandAccept__c = obj.HD_brandAccept__c;//品牌认可度
						hd.iskol__c = obj.HD_KOL__c;
						hd.IsSpeaker__c = obj.HDspeaker__c;
						hd.Total__c = obj.HDTotal__c;
						hd.HDscale__c = obj.HDscale__c;
						hd.MachineRatio__c = obj.HDMachineRatio__c;
						hd.dialyzerRatio__c = obj.HDdialyzerRatio__c;
						hd.updateYear__c = obj.HD_updateYear__c;
						hd.kolData__c = dataId; //丁香园数据
						hd.dataType__c = '英文文献';
						insertList.add(hd);
					}
				}
				

				//自然科学基金
				if(nsfcMap.containsKey(obj.KOL__c))
				{
					for(String dataId:nsfcMap.get(obj.KOL__c))
					{
						KOLReport__c hd = new KOLReport__c();
						hd.KOLName__c = obj.KOL__c; //联系人
						hd.BU__c = 'HD'; 
						hd.Academic__c = string.valueOf(obj.MA_Academic__c);
						hd.scientificResearch__c = obj.HD_scientificResearch__c;//科研能力
						hd.Teaching__c = obj.HD_Teaching__c;//讲课能力
						hd.brandAccept__c = obj.HD_brandAccept__c;//品牌认可度
						hd.iskol__c = obj.HD_KOL__c;
						hd.IsSpeaker__c = obj.HDspeaker__c;
						hd.Total__c = obj.HDTotal__c;
						hd.HDscale__c = obj.HDscale__c;
						hd.MachineRatio__c = obj.HDMachineRatio__c;
						hd.dialyzerRatio__c = obj.HDdialyzerRatio__c;
						hd.updateYear__c = obj.HD_updateYear__c;
						hd.kolData__c = dataId; //丁香园数据
						hd.dataType__c= '自然科学基金';
						insertList.add(hd);
					}
				}
				

				//临床试验
				if(scienceMap.containsKey(obj.KOL__c))
				{
					for(String dataId:scienceMap.get(obj.KOL__c))
					{
						KOLReport__c hd = new KOLReport__c();
						hd.KOLName__c = obj.KOL__c; //联系人
						hd.BU__c = 'HD'; 
						hd.Academic__c = string.valueOf(obj.MA_Academic__c);
						hd.scientificResearch__c = obj.HD_scientificResearch__c;//科研能力
						hd.Teaching__c = obj.HD_Teaching__c;//讲课能力
						hd.brandAccept__c = obj.HD_brandAccept__c;//品牌认可度
						hd.iskol__c = obj.HD_KOL__c;
						hd.IsSpeaker__c = obj.HDspeaker__c;
						hd.Total__c = obj.HDTotal__c;
						hd.HDscale__c = obj.HDscale__c;
						hd.MachineRatio__c = obj.HDMachineRatio__c;
						hd.dialyzerRatio__c = obj.HDdialyzerRatio__c;
						hd.updateYear__c = obj.HD_updateYear__c;
						hd.kolData__c = dataId; //丁香园数据
						hd.dataType__c= '临床试验';
						insertList.add(hd);
					}
				}
				

				//会议信息
				if(meettingMap.containsKey(obj.KOL__c))
				{
					for(String dataId:meettingMap.get(obj.KOL__c))
					{
						KOLReport__c hd = new KOLReport__c();
						hd.KOLName__c = obj.KOL__c; //联系人
						hd.BU__c = 'HD'; 
						hd.Academic__c = string.valueOf(obj.MA_Academic__c);
						hd.scientificResearch__c = obj.HD_scientificResearch__c;//科研能力
						hd.Teaching__c = obj.HD_Teaching__c;//讲课能力
						hd.brandAccept__c = obj.HD_brandAccept__c;//品牌认可度
						hd.iskol__c = obj.HD_KOL__c;
						hd.IsSpeaker__c = obj.HDspeaker__c;
						hd.Total__c = obj.HDTotal__c;
						hd.HDscale__c = obj.HDscale__c;
						hd.MachineRatio__c = obj.HDMachineRatio__c;
						hd.dialyzerRatio__c = obj.HDdialyzerRatio__c;
						hd.updateYear__c = obj.HD_updateYear__c;
						hd.kolData__c = dataId; //丁香园数据
						hd.dataType__c= '会议信息';
						insertList.add(hd);
					}
				}
			}

			//Acute的KOL评分
			if(obj.Acute_updateYear__c != null)
			{
				//Acute的联系人与评分信息
				KOLReport__c acuteContact= new KOLReport__c();
				acuteContact.KOLName__c = obj.KOL__c; //联系人
				acuteContact.BU__c = 'Acute'; 
				acuteContact.Academic__c = string.valueOf(obj.MA_Academic__c);
				acuteContact.scientificResearch__c = obj.Acute_scientificResearch__c;//科研能力
				acuteContact.Teaching__c = obj.Acute_Teaching__c;//讲课能力
				acuteContact.brandAccept__c = obj.Acute_brandAccept__c;//品牌认可度
				acuteContact.iskol__c = obj.Acute_KOL__c;
				acuteContact.IsSpeaker__c = obj.Acutespeaker__c;
				acuteContact.Total__c = obj.AcuteTotal__c;
				acuteContact.AcuteCRRTTimes__c = obj.AcuteCRRTTimes__c;
				acuteContact.AcuteMachineRatio__c = obj.AcuteMachineRatio__c;
				acuteContact.updateYear__c = obj.Acute_updateYear__c;
				acuteContact.dataType__c= '联系人';
				insertList.add(acuteContact);

				//中文文献
				if(chineseMap.containsKey(obj.KOL__c))
				{
					for(String dataId:chineseMap.get(obj.KOL__c))
					{
						KOLReport__c acute= new KOLReport__c();
						acute.KOLName__c = obj.KOL__c; //联系人
						acute.BU__c = 'Acute'; 
						acute.Academic__c = string.valueOf(obj.MA_Academic__c);
						acute.scientificResearch__c = obj.Acute_scientificResearch__c;//科研能力
						acute.Teaching__c = obj.Acute_Teaching__c;//讲课能力
						acute.brandAccept__c = obj.Acute_brandAccept__c;//品牌认可度
						acute.iskol__c = obj.Acute_KOL__c;
						acute.IsSpeaker__c = obj.Acutespeaker__c;
						acute.Total__c = obj.AcuteTotal__c;
						acute.AcuteCRRTTimes__c = obj.AcuteCRRTTimes__c;
						acute.AcuteMachineRatio__c = obj.AcuteMachineRatio__c;
						acute.updateYear__c = obj.Acute_updateYear__c;
						acute.kolData__c = dataId; //丁香园数据
						acute.dataType__c = '中文文献';
						insertList.add(acute);
					}
				}
				

				//英文文献
				if(englishMap.containsKey(obj.KOL__c))
				{
					for(String dataId:englishMap.get(obj.KOL__c))
					{
						KOLReport__c acute= new KOLReport__c();
						acute.KOLName__c = obj.KOL__c; //联系人
						acute.BU__c = 'Acute'; 
						acute.Academic__c = string.valueOf(obj.MA_Academic__c);
						acute.scientificResearch__c = obj.Acute_scientificResearch__c;//科研能力
						acute.Teaching__c = obj.Acute_Teaching__c;//讲课能力
						acute.brandAccept__c = obj.Acute_brandAccept__c;//品牌认可度
						acute.iskol__c = obj.Acute_KOL__c;
						acute.IsSpeaker__c = obj.Acutespeaker__c;
						acute.Total__c = obj.AcuteTotal__c;
						acute.AcuteCRRTTimes__c = obj.AcuteCRRTTimes__c;
						acute.AcuteMachineRatio__c = obj.AcuteMachineRatio__c;
						acute.updateYear__c = obj.Acute_updateYear__c;
						acute.kolData__c = dataId; //丁香园数据
						acute.dataType__c = '英文文献';
						insertList.add(acute);
					}
				}
				

				//自然科学基金
				if(nsfcMap.containsKey(obj.KOL__c))
				{
					for(String dataId:nsfcMap.get(obj.KOL__c))
					{
						KOLReport__c acute= new KOLReport__c();
						acute.KOLName__c = obj.KOL__c; //联系人
						acute.BU__c = 'Acute'; 
						acute.Academic__c = string.valueOf(obj.MA_Academic__c);
						acute.scientificResearch__c = obj.Acute_scientificResearch__c;//科研能力
						acute.Teaching__c = obj.Acute_Teaching__c;//讲课能力
						acute.brandAccept__c = obj.Acute_brandAccept__c;//品牌认可度
						acute.iskol__c = obj.Acute_KOL__c;
						acute.IsSpeaker__c = obj.Acutespeaker__c;
						acute.Total__c = obj.AcuteTotal__c;
						acute.AcuteCRRTTimes__c = obj.AcuteCRRTTimes__c;
						acute.AcuteMachineRatio__c = obj.AcuteMachineRatio__c;
						acute.updateYear__c = obj.Acute_updateYear__c;
						acute.kolData__c = dataId; //丁香园数据
						acute.dataType__c= '自然科学基金';
						insertList.add(acute);
					}
				}
				

				//临床试验
				if(scienceMap.containsKey(obj.KOL__c))
				{
					for(String dataId:scienceMap.get(obj.KOL__c))
					{
						KOLReport__c acute= new KOLReport__c();
						acute.KOLName__c = obj.KOL__c; //联系人
						acute.BU__c = 'Acute'; 
						acute.Academic__c = string.valueOf(obj.MA_Academic__c);
						acute.scientificResearch__c = obj.Acute_scientificResearch__c;//科研能力
						acute.Teaching__c = obj.Acute_Teaching__c;//讲课能力
						acute.brandAccept__c = obj.Acute_brandAccept__c;//品牌认可度
						acute.iskol__c = obj.Acute_KOL__c;
						acute.IsSpeaker__c = obj.Acutespeaker__c;
						acute.Total__c = obj.AcuteTotal__c;
						acute.AcuteCRRTTimes__c = obj.AcuteCRRTTimes__c;
						acute.AcuteMachineRatio__c = obj.AcuteMachineRatio__c;
						acute.updateYear__c = obj.Acute_updateYear__c;
						acute.kolData__c = dataId; //丁香园数据
						acute.dataType__c= '临床试验';
						insertList.add(acute);
					}
				}
				

				//会议信息
				if(meettingMap.containsKey(obj.KOL__c))
				{
					for(String dataId:meettingMap.get(obj.KOL__c))
					{
						KOLReport__c acute= new KOLReport__c();
						acute.KOLName__c = obj.KOL__c; //联系人
						acute.BU__c = 'Acute'; 
						acute.Academic__c = string.valueOf(obj.MA_Academic__c);
						acute.scientificResearch__c = obj.Acute_scientificResearch__c;//科研能力
						acute.Teaching__c = obj.Acute_Teaching__c;//讲课能力
						acute.brandAccept__c = obj.Acute_brandAccept__c;//品牌认可度
						acute.iskol__c = obj.Acute_KOL__c;
						acute.IsSpeaker__c = obj.Acutespeaker__c;
						acute.Total__c = obj.AcuteTotal__c;
						acute.AcuteCRRTTimes__c = obj.AcuteCRRTTimes__c;
						acute.AcuteMachineRatio__c = obj.AcuteMachineRatio__c;
						acute.updateYear__c = obj.Acute_updateYear__c;
						acute.kolData__c = dataId; //丁香园数据
						acute.dataType__c= '会议信息';
						insertList.add(acute);
					}
				}			
			}
		}
		insert insertList;
	}

/*******************************************************************/
	if(trigger.isUpdate)
	{
		String currentyear = System.today().month()>7?System.today().year()+'下半年' : System.today().year()+'上半年';
		List<KOLReport__c> tempList = [select id,updateYear__c,BU__c,dataType__c,KOLName__c from KOLReport__c where updateYear__c =:currentyear];
		if(tempList.size() == 0)
		{
			return;
		}
		for(KOLReport__c temp:tempList)
		{
			if(!reportMap.containsKey(temp.KOLName__c))
			{
				reportMap.put(temp.KOLName__c, new List<KOLReport__c>());
			}
			List<KOLReport__c> reportList = reportMap.get(temp.KOLName__c);
			reportList.add(temp);
			reportMap.put(temp.KOLName__c, reportList);
		}

		for(KOLScore__c obj:trigger.new)
		{
			if(!reportMap.containsKey(obj.KOL__c))
			{
				continue;
			}
			if(obj.PD_updateYear__c != null)
			{

				for(KOLReport__c report:reportMap.get(obj.KOL__c))
				{
					if(report.BU__c != 'PD' && report.dataType__c != '市场活动')
					{
						continue;
					}
					report.Academic__c = string.valueOf(obj.MA_Academic__c);
					report.scientificResearch__c = obj.PD_scientificResearch__c;//科研能力
					report.Teaching__c = obj.PD_Teaching__c;//讲课能力
					report.brandAccept__c = obj.PD_brandAccept__c;//品牌认可度
					report.isCOE__c = obj.isCOE__c;
					report.PDscale__c = obj.PDscale__c;
					report.iskol__c = obj.PD_KOL__c;
					report.IsSpeaker__c = obj.PDspeaker__c;
					report.Total__c = obj.PDTotal__c;
					updateList.add(report);
				}
			}

			if(obj.HD_updateYear__c != null)
			{
				for(KOLReport__c report:reportMap.get(obj.KOL__c))
				{
					if(report.BU__c != 'HD' && report.dataType__c != '市场活动')
					{
						continue;
					}
					report.Academic__c = string.valueOf(obj.MA_Academic__c);
					report.scientificResearch__c = obj.HD_scientificResearch__c;//科研能力
					report.Teaching__c = obj.HD_Teaching__c;//讲课能力
					report.brandAccept__c = obj.HD_brandAccept__c;//品牌认可度
					report.iskol__c = obj.HD_KOL__c;
					report.IsSpeaker__c = obj.HDspeaker__c;
					report.Total__c = obj.HDTotal__c;
					report.HDscale__c = obj.HDscale__c;
					report.MachineRatio__c = obj.HDMachineRatio__c;
					report.dialyzerRatio__c = obj.HDdialyzerRatio__c;
					updateList.add(report);
				}
			}

			if(obj.Acute_updateYear__c != null)
			{
				for(KOLReport__c report:reportMap.get(obj.KOL__c))
				{
					if(report.BU__c != 'Acute' && report.dataType__c != '市场活动')
					{
						continue;
					}
					report.Academic__c = string.valueOf(obj.MA_Academic__c);
					report.scientificResearch__c = obj.Acute_scientificResearch__c;//科研能力
					report.Teaching__c = obj.Acute_Teaching__c;//讲课能力
					report.brandAccept__c = obj.Acute_brandAccept__c;//品牌认可度
					report.iskol__c = obj.Acute_KOL__c;
					report.IsSpeaker__c = obj.Acutespeaker__c;
					report.Total__c = obj.AcuteTotal__c;
					report.AcuteCRRTTimes__c = obj.AcuteCRRTTimes__c;
					report.AcuteMachineRatio__c = obj.AcuteMachineRatio__c;
					updateList.add(report);
				}
			}
		}

		update updateList;
	}

    




    //将联系人与各类型大数据打包Map 
	private void getMap(List<DoctorInfoBigData__c> dateList,Map<String,List<String>> dataMap)
	{
		for(DoctorInfoBigData__c obj:dateList)
    		{
    			if(!dataMap.containsKey(obj.ContactId__c))
    			{
    				dataMap.put(obj.ContactId__c, new List<String>());
    			}
    				
    				List<String> tempList = dataMap.get(obj.ContactId__c);
    				tempList.add(obj.Id);
    				dataMap.put(obj.ContactId__c,tempList);
    		}
	}
}
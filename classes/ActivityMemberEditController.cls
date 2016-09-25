public with sharing class ActivityMemberEditController {
	public List<ItemWrapper> menberList{set;get;}
	public String campaignID{set;get;}
	public Integer Index{get;set;}
    public Map<String,Integer> actScoreMap{set;get;}
    public String pageMsg{set;get;}
	public class ItemWrapper
	{
		public Boolean IsEdit{get;set;}
    	public Integer Index {get;set;}
    	public CampaignMember item{get;set;}
	}
    public Set<ID> contactIdSet{set;get;}
    public Map<String,CampaignMember> contactMap{set;get;}
    public Map<String,String> levelMap{set;get;}
    public Boolean isAllowActScore{set;get;}

    public ActivityMemberEditController(ApexPages.StandardController con) {
		 campaignID = con.getId();
         //判断是否可以打表现分
         Campaign cam = [select id,Status from Campaign where id =:campaignID];
         if(cam.Status == 'Begin Feedback Call' || cam.Status == 'Feedback Call Closed')
         {
            isAllowActScore = true;
         }
         else{
            isAllowActScore = false;
         }
		 
		 initList();
    }

    private void initList()
    {
    	menberList  = new List<ItemWrapper>();
        List<CampaignMember> camList = [select id,MA_Chief__c,MA_Speaker__c,ContactId,MA_SpeechTitle__c,
    									MA_ParticipateScore__c,MA_ActScore__c,MA_involved__c from CampaignMember where CampaignId =:campaignID];
    	if(camList.size() == 0)
    	{
    		pageMsg = '尚无活动成员，请先添加！';
    		return;
    	}

    	for(CampaignMember campMember :camList)
    	{
    		ItemWrapper itemW = new ItemWrapper();
    		itemW.IsEdit = false;
    		itemW.Index = menberList.size();
    		itemW.item = campMember;
    		menberList.add(itemW);
    	}
    }

    public PageReference save()
    {
        pageMsg ='';
        getActScore();
    	List<CampaignMember> camList = new List<CampaignMember>();
    	for(ItemWrapper itemW : menberList)
    	{
    		if(itemW.IsEdit)
    		{
                itemW.item.MA_ParticipateScore__c = actScoreMap.get(itemW.item.ContactId);
                if(isAllowActScore && (itemW.item.MA_ActScore__c > 10 || itemW.item.MA_ActScore__c < 0))
                {
                    pageMsg = '表现分为0-10分';
                    return null;
                }
    			camList.add(itemW.item);
    		}
    	}
        update camList;	
        PageReference pageRef = new PageReference('/'+campaignID);
        return pageRef;
    }



    public void Upd()
    {
        pageMsg ='';
        
           if(Index>=0)
            {
                for(Integer i = 0 ; i<  menberList.size() ; i ++)
                {
                    if(menberList[i].Index == Index)
                    {
                        if(menberList[i].item.id != null)
                        {
                            menberList[i].IsEdit = true;
                        }
                        return;
                    }
                }
            } 

        
    }

    public void del()
    {
        pageMsg ='';
        try
        {
    	if(Index>=0)
        {
            for(Integer i = 0 ; i<  menberList.size() ; i ++)
            {
                if(menberList[i].Index == Index)
                {
                    if(menberList[i].item.id != null)
                    {
                        delete menberList[i].item;
                    }
                    menberList.remove(i);
                    return;
                }
            }
        }
        }catch(Exception e){
          pageMsg = '无法删除成员，请联系管理员';  
        }
    }

    public void getActScore()
    {
        contactMap = new Map<String,CampaignMember>();
        levelMap = new Map<String,String>();
        actScoreMap = new Map<String,Integer>();

        for(ItemWrapper itemW : menberList)
        {
            if(itemW.IsEdit)
            {
                if(itemW.item.ContactId != null)
                {
                    contactMap.put(itemW.item.ContactId,itemW.item);
                }
            }
        }

        for(Contact obj:[select id,MA_level__c from Contact where id IN:contactMap.keySet()])
        {
            levelMap.put(obj.id, obj.MA_level__c);
        }

        for(String id:levelMap.keySet())
        {
            if(levelMap.get(id) == '国家' || levelMap.get(id) == '国际')
            {
                if(contactMap.get(id).MA_Chief__c)
                {
                    actScoreMap.put(id,10);
                    
                }else if(contactMap.get(id).MA_Speaker__c)
                {
                     actScoreMap.put(id,8);
                }else
                {
                     actScoreMap.put(id,5);
                }
            }else if(levelMap.get(id) == '省市')
            {
                if(contactMap.get(id).MA_Chief__c)
                {
                     actScoreMap.put(id,6);
                }else if(contactMap.get(id).MA_Speaker__c)
                {
                     actScoreMap.put(id,4);
                }else
                {
                     actScoreMap.put(id,2);
                }
            }else if(levelMap.get(id) == '地市')
            {
                if(contactMap.get(id).MA_Chief__c)
                {
                     actScoreMap.put(id,5);
                }else if(contactMap.get(id).MA_Speaker__c)
                {
                     actScoreMap.put(id,2);
                }else
                {
                     actScoreMap.put(id,1);
                }
            }else{
                 actScoreMap.put(id,0);
            }
        }
    }


}
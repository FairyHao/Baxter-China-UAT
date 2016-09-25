public with sharing class ActivityMemberController {
	public List<ItemWrapper> menberList{set;get;}
	public String campaignID{set;get;}
	public Integer Index{get;set;}
    public Map<String,Integer> actScoreMap{set;get;}
    public String pageMsg{set;get;}
	public class ItemWrapper{
		public Boolean IsEdit{get;set;}
    	public Integer Index {get;set;}
    	public CampaignMember item{get;set;}
	}
    public Set<ID> contactIdSet{set;get;}
    public Map<String,CampaignMember> contactMap{set;get;}
    public Map<String,String> levelMap{set;get;}

    public ActivityMemberController(ApexPages.StandardController con) {
		 campaignID = con.getId();
		 initList();
    }

    private void initList()
    {
    	menberList  = new List<ItemWrapper>();
        contactIdSet = new Set<ID>();
    	for(CampaignMember campMember :[select id,MA_Chief__c,MA_Speaker__c,ContactId,MA_SpeechTitle__c,
    									MA_ParticipateScore__c,MA_ActScore__c,MA_involved__c from CampaignMember where CampaignId =:campaignID])
    	{
            contactIdSet.add(campMember.ContactId);
    	}

			ItemWrapper itemW = new ItemWrapper();
	    	itemW.IsEdit = true;
	    	itemW.Index = menberList.size();
	    	CampaignMember cam = new CampaignMember();
	    	itemW.item = cam;
            itemW.item.CampaignId = CampaignId;
	    	menberList.add(itemW);
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
                if(itemW.item.ContactId == null )
                {
                    pageMsg ='未添加活动成员';
                    return null;
                }
                if(contactIdSet.contains(itemW.item.ContactId))
                {
                    pageMsg ='活动成员不允许重复添加';
                    return null;
                }
                itemW.item.MA_ParticipateScore__c = actScoreMap.get(itemW.item.ContactId);
                //MA 用户新建的记录默认审批通过
                itemW.item.V2_SupervisoApprove__c = '通过';
                itemW.item.V2_AreaManagerApprove__c = '通过';
                itemW.item.V2_MarketingApprove__c = '通过';
    			camList.add(itemW.item);
                
    		}
            
    	}
            upsert camList;

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

    public void add(){
        pageMsg ='';
    	ItemWrapper itemW = new ItemWrapper();
	    itemW.IsEdit = true;
	    itemW.Index = menberList.size();
	    CampaignMember cam = new CampaignMember();
	    itemW.item = cam;
        itemW.item.CampaignId = CampaignId;
	    menberList.add(itemW);
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
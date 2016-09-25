public with sharing class ActivitySurveyController {
	public SurveyHistory__c history{set;get;}
	public List<CampaignMember> menberList{set;get;}
	public String campaignId{set;get;}
	public List<String> emailAdress{set;get;}
	public String Msg{set;get;}
    private Map<String,String> contactNameMap;

    public ActivitySurveyController(ApexPages.StandardController con) {
		campaignId = con.getId();
		history = new SurveyHistory__c();
    }

    public Boolean getEmailAdress()
    {
        Msg ='';
    	emailAdress = new List<String>();
    	menberList = [select id,contactEmail__c,MA_Chief__c,ContactId,campaignID from CampaignMember where campaignID =:campaignId];
    	getContactName();
        for(CampaignMember obj:menberList)
    	{
            if(obj.contactEmail__c == null)
            {
                Msg = '活动成员\''+ contactNameMap.get(obj.ContactId) + '\'没有邮箱地址,请完善邮件地址';
                return false;
            }
    		emailAdress.add(obj.contactEmail__c);
    	}
        return true;
    }

    //获取联系人id Name 的Map
    private void getContactName()
    {
        Set<ID> idSet = new  Set<ID>();
        contactNameMap = new Map<String,String>();
        for(CampaignMember obj:menberList)
        {
            idSet.add(obj.ContactId);
        }
        List<Contact> tempList = [select id,Name from Contact where id IN:idSet];
        for(Contact contactObj:tempList)
        {
            contactNameMap.put(contactObj.id,contactObj.Name);
        }

    }

    public void sendEmail()
    {
    	
    	if(!getEmailAdress())
        {
            return;
        }
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(emailAdress); //邮件地址
		mail.setHtmlBody(history.EmailTxt__c); //邮件内容
        if(history.emailSubject__c == null)
        {
            Msg ='请填写邮件主题';
            return;
        }
		mail.setSubject(history.emailSubject__c); //邮件主题
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		Msg ='邮件发送成功！';		
		getHistory();
        back();
    }

    public void getHistory()
    {
        List<SurveyHistory__c> surveyList = new List<SurveyHistory__c>();
    	for(CampaignMember obj:menberList)
    	{
            SurveyHistory__c temp = new SurveyHistory__c();
            temp.SendDate__c = System.today();
            temp.campaign__c = campaignId;
    		temp.Survey_Contact__c = obj.ContactId;
            temp.EmailTxt__c = history.EmailTxt__c;
            surveyList.add(temp);
    	}
        insert surveyList;
    }

    public PageReference back()
    {
    	PageReference pageRef = new PageReference('/'+campaignId);
    	return pageRef;
    }
}
/**
*   winter 2014-5-8
*/
trigger AddedAttachmentTrigger on Attachment (after insert , after delete) {
    //业务机会集合
    list<Opportunity> listOpportunity =new list<Opportunity>();
    //附件id集合
    set<ID> attIdSet = new set<ID>();
    //业务机会ID前三位
    String oppKeyPrefix = Opportunity.SObjectType.getDescribe().getKeyPrefix();
    //每添加一个附件获取其附件id
    if(trigger.isInsert){
    	for(Attachment att : trigger.new)
	    {
	    	String sParentId = String.valueOf(att.ParentId);
	    	if(sParentId.startsWith(oppKeyPrefix)){
	    		attIdSet.add(att.ParentId);
	    	}
	    }
    }else if(trigger.isDelete){
    	for(Attachment att : trigger.old)
	    {
	    	String sParentId = String.valueOf(att.ParentId);
	    	if(sParentId.startsWith(oppKeyPrefix)){
	    		attIdSet.add(att.ParentId);
	    	}
	    }
    }
    
	if(attIdSet.size() > 0){
		//通过附件id获取业务机会的id、AddedAccessory__c的值
	    listOpportunity = [select ID,AddedAccessory__c,(Select Id From Attachments) from Opportunity where ID in: attIdSet];
	
	    //将添加过附件的业务机会的AddedAccessory__c值赋值为true
	    for(Opportunity opp : listOpportunity)
	    {
	    	if(opp.Attachments.size() > 0){
	    		opp.AddedAccessory__c = true;
	    	}else{
	    		opp.AddedAccessory__c = false;
	    	}
	        
	    }
	    //执行
	    update listOpportunity;
	}
}
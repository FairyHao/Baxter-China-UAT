/*
Function:查重
TestClass:Test_getNegotiateReportBatch
*/
trigger canNotAddSameAccount on negotiateCustomer__c(before insert,before update) {
	Set<id> oppIdSet = new Set<id>();
	Map<id,Set<id>> accountIdToOppIdMap = new Map<id,Set<id>>();
    for(negotiateCustomer__c obj:trigger.new){
		oppIdSet.add(obj.negotiateOpportunity__c);
    }
    List<negotiateCustomer__c> accountList = [SELECT id,negotiateOpportunity__c,negotiateCustomer__c FROM negotiateCustomer__c WHERE negotiateOpportunity__c IN:oppIdSet];
    for(negotiateCustomer__c obj:accountList){
		if(accountIdToOppIdMap.containsKey(obj.negotiateOpportunity__c)){
			Set<id> idSet = accountIdToOppIdMap.get(obj.negotiateOpportunity__c);
			idSet.add(obj.negotiateCustomer__c);
			accountIdToOppIdMap.put(obj.negotiateOpportunity__c,idSet);
		}else{
			Set<id> idSet = new Set<id>();
			idSet.add(obj.negotiateCustomer__c);
			accountIdToOppIdMap.put(obj.negotiateOpportunity__c, idSet);
		}
    }
    if(accountList.size() > 0){
    	for(negotiateCustomer__c obj:trigger.new){
    		Set<id> idSet = accountIdToOppIdMap.get(obj.negotiateOpportunity__c);
    		if(trigger.isInsert ){
    			if(idSet.contains(obj.negotiateCustomer__c)){
    					obj.negotiateCustomer__c.addError('不允许重复添加医院');
 						return;		
    			}
    		}
    		if(trigger.isUpdate ){
    			negotiateCustomer__c oldobj = trigger.oldMap.get(obj.Id);
    			if(idSet.contains(obj.negotiateCustomer__c) && obj.negotiateCustomer__c != oldobj.negotiateCustomer__c){
    					obj.negotiateCustomer__c.addError('不允许重复添加医院');
 						return;
    			}
    		}
    		
    	}
    }
    
}
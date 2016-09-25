trigger getOpportunityItemDetail on OpportunityLineItem (before insert) {
    private Set<String> oppIdSet = new Set<String>();
    private Set<String> productIdSet = new Set<String>();
    //private List<Opportunity> opportunityList = new List<Opportunity>();
    //private List<Product2> productList = new List<Product2>();
    Map<String,List<String>> oppIdToProductListMap = new Map<String,List<String>>();
    Map<String,Opportunity> OpportunityMap = new Map<String,Opportunity>();
    Map<String,Product2> Product2Map = new Map<String,Product2>();
    system.debug('----出发这个--');
    for(OpportunityLineItem obj:trigger.new){
        oppIdSet.add(obj.Opportunityid);
        productIdSet.add(obj.Product2id);
        if(!oppIdToProductListMap.containsKey(obj.Opportunityid))
        {
            List<String> tempList = new List<String>();
            oppIdToProductListMap.put(obj.Opportunityid,tempList);
        }
        List<String> proList = oppIdToProductListMap.get(obj.Opportunityid);
        proList.add(obj.Product2id);
        oppIdToProductListMap.put(obj.Opportunityid, proList);
    }
    for(Opportunity opp:[SELECT id,recordType.developerName FROM Opportunity WHERE id IN:oppIdSet]){
        OpportunityMap.put(opp.id,opp);
    }
    for(Product2 pro:[SELECT id,competitorBrand__c,isCompetitor__c FROM Product2 WHERE id IN:productIdSet]){
        system.debug('---pro-----'+pro.isCompetitor__c);
        system.debug('---pro-----'+pro.id);
        Product2Map.put(pro.id,pro);
    }
    for(OpportunityLineItem oppItem:trigger.new){
        system.debug('-----Dean----'+oppItem);
        system.debug('------------'+OpportunityMap.get(oppItem.OpportunityId).recordType.developerName);
        if(OpportunityMap.get(oppItem.OpportunityId).recordType.developerName == 'secondNegotiation'){
            oppItem.isCompetitor__c = Product2Map.get(oppItem.Product2Id).isCompetitor__c;
            oppItem.competitorBrand__c = Product2Map.get(oppItem.Product2Id).competitorBrand__c;
        }
        system.debug('-----Dean222----'+oppItem);
    }
}
trigger AutoRelationAccountByOpportunity on Opportunity(after insert,after Update) 
{
	System.debug('************');
    Set<ID> OppIdSet=new Set<ID>();
    if(trigger.isInsert)
    {
        for (Opportunity Opp:trigger.new) 
        {
            if(Opp.AccountId!=null)
            {
                OppIdSet.add(Opp.Id);
            }
        }
    }
    if(trigger.isUpdate)
    {
        for (Opportunity opp:trigger.new) 
        {
            if(opp.AccountId!=trigger.oldMap.get(opp.Id).AccountId)
            {
            	System.debug('fdada');
                OppIdSet.add(opp.Id);
            }
        }
    }
    List<OpportunityEvaluation__c> EvaList=[select id,Opptunity__r.AccountId from OpportunityEvaluation__c where Opptunity__c in:OppIdSet];
    for(OpportunityEvaluation__c Eva:EvaList)
    {   
        Eva.Account__c=Eva.Opptunity__r.AccountId;
    }
    if(EvaList.size()>0)
    {
        update EvaList;
    }
    
    List<PIVAS_Info__c> InfoList=[select id,Opptunity__r.AccountId from PIVAS_Info__c where Opptunity__c in:OppIdSet];
    for(PIVAS_Info__c Info:InfoList)
    {   
        Info.PIVAS_Account__c=Info.Opptunity__r.AccountId;
    }
    if(InfoList.size()>0)
    {
        update InfoList;
    }
}
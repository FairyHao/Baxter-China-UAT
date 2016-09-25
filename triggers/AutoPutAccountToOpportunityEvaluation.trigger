trigger AutoPutAccountToOpportunityEvaluation on OpportunityEvaluation__c(before insert,before update) {
	Set<Id> OppIdSet=new Set<ID>();
	if(trigger.isInsert)
	{
		for(OpportunityEvaluation__c Eva:trigger.new)
		{
			if(Eva.Opptunity__c!=null)
			{
				System.debug(Eva.Opptunity__r.AccountId+'********');
				OppIdSet.add(Eva.Opptunity__c);
			}
			Eva.SumScore__c=((Eva.Score1__c==null?0:Eva.Score1__c)+(Eva.Score2__c==null?0:Eva.Score2__c)+(Eva.Score3__c==null?0:Eva.Score3__c)+(Eva.Score4__c==null?0:Eva.Score4__c)+(Eva.Score5__c==null?0:Eva.Score5__c)+(Eva.Score6__c==null?0:Eva.Score6__c)+(Eva.Score7__c==null?0:Eva.Score7__c)+(Eva.Score8__c==null?0:Eva.Score8__c)
				+(Eva.Score9__c==null?0:Eva.Score9__c)+(Eva.Score10__c==null?0:Eva.Score10__c)+
			(Eva.Score11__c==null?0:Eva.Score11__c)+(Eva.Score12__c==null?0:Eva.Score12__c)+(Eva.Score13__c==null?0:Eva.Score13__c)+(Eva.Score14__c==null?0:Eva.Score14__c)+(Eva.Score15__c==null?0:Eva.Score15__c)+(Eva.Score16__c==null?0:Eva.Score16__c)+(Eva.Score17__c==null?0:Eva.Score17__c)+(Eva.Score18__c==null?0:Eva.Score18__c)+(Eva.Score19__c==null?0:Eva.Score19__c))*0.5*100;		
		}
		List<Opportunity> OppList=[select id,AccountID from Opportunity where id in:OppIdSet];
		Map<Id,Id> Opp_Account_Map=new Map<Id,Id>();
		for(Opportunity Opp:OppList)
		{
			Opp_Account_Map.put(Opp.id,Opp.AccountId);
		}
		for(OpportunityEvaluation__c Eva:trigger.new)
		{	
			if(Eva.Opptunity__c!=null)
			{
				Eva.Account__c=Opp_Account_Map.get(Eva.Opptunity__c);
			}
		}
	}
	if(trigger.isUpdate)
	{
		for(OpportunityEvaluation__c Eva:trigger.new)
		{
			Eva.SumScore__c=((Eva.Score1__c==null?0:Eva.Score1__c)+(Eva.Score2__c==null?0:Eva.Score2__c)+(Eva.Score3__c==null?0:Eva.Score3__c)+(Eva.Score4__c==null?0:Eva.Score4__c)+(Eva.Score5__c==null?0:Eva.Score5__c)+(Eva.Score6__c==null?0:Eva.Score6__c)+(Eva.Score7__c==null?0:Eva.Score7__c)+(Eva.Score8__c==null?0:Eva.Score8__c)
				+(Eva.Score9__c==null?0:Eva.Score9__c)+(Eva.Score10__c==null?0:Eva.Score10__c)+
			(Eva.Score11__c==null?0:Eva.Score11__c)+(Eva.Score12__c==null?0:Eva.Score12__c)+(Eva.Score13__c==null?0:Eva.Score13__c)+(Eva.Score14__c==null?0:Eva.Score14__c)+(Eva.Score15__c==null?0:Eva.Score15__c)+(Eva.Score16__c==null?0:Eva.Score16__c)+(Eva.Score17__c==null?0:Eva.Score17__c)+(Eva.Score18__c==null?0:Eva.Score18__c)+(Eva.Score19__c==null?0:Eva.Score19__c))*0.5*100;	
		}
	}
}
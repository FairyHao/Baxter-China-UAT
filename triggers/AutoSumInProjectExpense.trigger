/**
 * Author : Sunny
 * 自动汇总业务机会下的目前项目花销累计
**/
trigger AutoSumInProjectExpense on InProject_Expense__c (after insert , after update , after delete) {
	List<ID> list_OppIds = new List<ID>();
    if(trigger.isInsert){
    	for(InProject_Expense__c InProjectExp : trigger.new){
    		if(InProjectExp.Opportunity__c != null){
    			list_OppIds.add(InProjectExp.Opportunity__c);
    		}
    	}
    }else if(trigger.isUpdate){
    	for(InProject_Expense__c InProjectExp : trigger.new){
            if(InProjectExp.Opportunity__c != trigger.oldMap.get(InProjectExp.Id).Opportunity__c){
                list_OppIds.add(InProjectExp.Opportunity__c);
                list_OppIds.add(trigger.oldMap.get(InProjectExp.Id).Opportunity__c);
            }
            if(InProjectExp.Project_Expense__c != trigger.oldMap.get(InProjectExp.Id).Project_Expense__c){
            	list_OppIds.add(InProjectExp.Opportunity__c);
            }
        }
    }else if(trigger.isDelete){
    	for(InProject_Expense__c InProjectExp : trigger.old){
            if(InProjectExp.Opportunity__c != null){
                list_OppIds.add(InProjectExp.Opportunity__c);
            }
        }
    }
    if(list_OppIds.size() > 0){
    	List<Opportunity> list_OppUp = new List<Opportunity>();
    	for(AggregateResult aggSumExpense : [Select Opportunity__c op,SUM(Project_Expense__c)pe From InProject_Expense__c Where Opportunity__c in: list_OppIds And Project_Expense__c != null group by Opportunity__c]){
    		Opportunity opp=new Opportunity();
    		opp.Id = String.valueOf(aggSumExpense.get('op'));
    		opp.Project_cost_till_now__c = Decimal.valueOf(string.valueOf(aggSumExpense.get('pe')));
    		list_OppUp.add(Opp);
    	}
    	/*
    	for(Opportunity Opp : [Select Id,Project_cost_till_now__c,(Select AVG(Project_Expense__c)pe From OpportunityExp__r Where Project_Expense__c != null) From Opportunity Where Id in: list_OppIds]){
    		AggregateResult[] SunExpense = Opp.OpportunityExp__r;
    		if(SunExpense.size() > 0){
    			Opp.Project_cost_till_now__c = SunExpense[0].s;
    		}else{
    			Opp.Project_cost_till_now__c = null;
    		}
    		list_OppUp.add(Opp);
    	}
    	*/
    	if(list_OppUp.size() > 0){
    		update list_OppUp;
    	}
    }
}
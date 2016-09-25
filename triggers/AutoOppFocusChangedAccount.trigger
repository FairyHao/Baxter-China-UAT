/**
 * Author:Bill
 * date : 2013-8-1
 * project ： 焦点业务机会
 * 1.当业务机会的焦点业务机会变为true时，对应的客户也变为焦点业务机会医院
 * 2.当业务机会变为非焦点时，查看对应的客户是否还有焦点业务机会，若没有取消焦点业务机会医院标示
 **/
trigger AutoOppFocusChangedAccount on Opportunity (after update) {
	//变为焦点的业务机会
	Set<ID> set_Focus = new Set<ID>();
	//变为非焦点的业务机会
	Set<ID> set_NotFocus = new Set<ID>();
	//焦点业务机会ID
	Map<ID,ID> map_FocusOpp = new Map<ID,ID>();
	/********************Add By Dean 2014-06-17**********************************/
	Map<ID,String> map_OppAndRe = new Map<ID,String>();
	Set<ID> Set_OppId = new Set<ID>();
	Set<ID> set_SPNotFocus = new Set<ID>();
	
	for(Opportunity opp : trigger.new)
	{
		Set_OppId.add(opp.Id);
	}
	for(Opportunity Oppo:[Select Id , RecordType.DeveloperName from Opportunity where Id IN:Set_OppId])
	{
		map_OppAndRe.put(Oppo.Id,Oppo.RecordType.DeveloperName);
	}
	/********************Add By Dean 2014-06-17**********************************/
	for(Opportunity opp : trigger.new)
	{
		if(opp.IsFocusOpportunity__c == '是')
		{
			set_Focus.add(opp.AccountId);
			map_FocusOpp.put(opp.AccountId, opp.Id);
			
    	}
    	/********************Add By Dean 2014-06-17**********************************/
    	if(opp.IsFocusOpportunity__c != '是' && !set_Focus.contains(opp.AccountId) && map_OppAndRe.get(opp.Id) == 'RENAL')
		{
			set_NotFocus.add(opp.AccountId);
    	}
    	else if(opp.IsFocusOpportunity__c != '是' && !set_Focus.contains(opp.AccountId) && map_OppAndRe.get(opp.Id) != 'RENAL')
    	{
    		set_SPNotFocus.add(opp.AccountId);
    	}
    	/********************Add By Dean 2014-06-17**********************************/
	}
	
	
	//把有焦点业务机会的医院设置为焦点业务机会医院标示
	if(set_Focus != null && set_Focus.size() > 0)
	{
		List<Account> list_acc = [Select a.FocusOpportunitiesHospital__c From Account a where Id in : set_Focus];
		for(Account acc : list_acc)
		{
			/********************Add By Dean 2014-06-17**********************************/
			if(map_OppAndRe.get(map_FocusOpp.get(acc.Id)) == 'RENAL')
			{
				acc.FocusOpportunitiesHospital__c = true;
				acc.FocusOpportunitie__c = map_FocusOpp.get(acc.Id);
			}
			else
			{
				acc.SP_FocusOpportunitiesHospital__c = true;
				acc.SP_FocusOpportunities__c = map_FocusOpp.get(acc.Id);
			}
			/********************Add By Dean 2014-06-17**********************************/
		}
		update list_acc;
	}
	
	//取消业务机会的客户是否还有其他业务机会，若没有则取消焦点业务机会医院标示
	if(set_NotFocus != null && set_NotFocus.size() > 0)
	{
		List<Opportunity> list_opp = [Select o.IsFocusOpportunity__c, o.AccountId From Opportunity o where AccountId in : set_NotFocus and IsFocusOpportunity__c = '是'];
		if(list_opp != null && list_opp.size() > 0)
		{
			for(Opportunity opp : list_opp)
			{
				set_NotFocus.remove(opp.AccountId);
			}
		}
	}
	if(set_NotFocus != null && set_NotFocus.size() > 0)
	{
		List<Account> list_accNot = [Select a.FocusOpportunitiesHospital__c From Account a where Id in : set_NotFocus];
		for(Account acc : list_accNot)
		{
			acc.FocusOpportunitiesHospital__c = false;
			acc.FocusOpportunitie__c = NULL;
		}
		update list_accNot;
	}
	
	//取消业务机会的客户是否还有其他业务机会，若没有则取消焦点业务机会医院标示
	/********************Add By Dean 2014-06-17**********************************/
	if(set_SPNotFocus != null && set_SPNotFocus.size() > 0)
	{
		List<Opportunity> list_opps = [Select o.IsFocusOpportunity__c, o.AccountId From Opportunity o where AccountId in : set_SPNotFocus and IsFocusOpportunity__c = '是'];
		if(list_opps != null && list_opps.size() > 0)
		{
			for(Opportunity opp : list_opps)
			{
				set_SPNotFocus.remove(opp.AccountId);
			}
		}
	}
	if(set_SPNotFocus != null && set_SPNotFocus.size() > 0)
	{
		List<Account> list_accNots = [Select a.FocusOpportunitiesHospital__c From Account a where Id in : set_SPNotFocus];
		for(Account acc : list_accNots)
		{
			acc.SP_FocusOpportunitiesHospital__c = false;
			acc.SP_FocusOpportunities__c = NULL;
		}
		update list_accNots;
	}
	/********************Add By Dean 2014-06-17**********************************/
	
}
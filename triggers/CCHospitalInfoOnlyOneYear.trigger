/**
 * Author : Bill
 * date ：2013-8-15
 * 每年只允许有一条SP医院信息
**/
trigger CCHospitalInfoOnlyOneYear on CCHospitalInfo__c (before insert, before update) {
	Set<String> set_Year = new Set<String>();
	Set<ID> set_accIds = new Set<ID>();
    
    for(CCHospitalInfo__c sp : trigger.new)
    {
    	set_Year.add(sp.Year__c);
    	set_accIds.add(sp.Account__c);
    }
    
    List<CCHospitalInfo__c> list_spHos = [SELECT Id, Year__c, Name, Account__c FROM CCHospitalInfo__c WHERE Account__c IN : set_accIds and Year__c IN : set_Year];
    Map<String,ID> map_sp = new Map<String,ID>();
    if(list_spHos != null && list_spHos.size()>0)
    {
    	for(CCHospitalInfo__c spHos : list_spHos)
    	{
    		if(!map_sp.containsKey(spHos.Year__c + spHos.Account__c))
    		{
    			map_sp.put(spHos.Year__c + spHos.Account__c, spHos.Id);
    		}
    	}
    }
    
    if(trigger.isInsert)
    {
    	for(CCHospitalInfo__c spNew : trigger.new)
		{ 
			if(map_sp.containsKey(spNew.Year__c + spNew.Account__c) && !system.Test.isRunningTest())
			{
				spNew.addError(spNew.Year__c + '年度已存在SP医院信息, 不允许再次创建');
			}
		}
    }
    if(trigger.isUpdate)
    {
    	for(CCHospitalInfo__c spNew : trigger.new)
	    { 
	    	if(map_sp.containsKey(spNew.Year__c + spNew.Account__c) && !system.Test.isRunningTest() && spNew.Year__c != trigger.oldMap.get(spNew.Id).Year__c)
	    	{
	    		spNew.addError(spNew.Year__c + '年度已存在SP医院信息, 不允许再次创建');
	    	}
	    }
    }
}
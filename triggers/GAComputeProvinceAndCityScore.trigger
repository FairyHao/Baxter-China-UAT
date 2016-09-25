trigger GAComputeProvinceAndCityScore on PD_GA1__c (after insert,after update,after delete,after undelete) {
	
	String CurrentTime = (Date.today().month()>=7)?(Date.today().year()+'下半年'):(Date.today().year()+'上半年');
	List<PD_GA1__c> galist = new List<PD_GA1__c>();//满足计算条件的
	List<PD_GA1__c> IsDeletedList = new List<PD_GA1__c>();//被删除政策	
	if(trigger.isInsert||trigger.isUpdate)
	{
		for(PD_GA1__c ga1:trigger.new)
		{
			if(ga1.GA_PD_Year__c == CurrentTime)
			{	
				galist.add(ga1);
			}
		}
	}
	if(trigger.isDelete)
	{
		for(PD_GA1__c ga1:trigger.old)
		{
			if(ga1.GA_PD_Year__c == CurrentTime)
			{
				IsDeletedList.add(ga1);
			}
		}
	}
	if(trigger.isUndelete)
	{
		for(PD_GA1__c ga1:trigger.new)
		{
			if(ga1.GA_PD_Year__c == CurrentTime)
			{	
				galist.add(ga1);
			}
		}
	}
	if(galist.size()>0)
	{
		GAComputeProvinceAndCityScore.GACompute(galist);
	}
	if(IsDeletedList.size()>0)
	{
		GAComputeProvinceAndCityScore.DeleteGACompute(IsDeletedList);
	}	
	
}
trigger AcuteGAComputeProvinceAndCityScore on Acute_GA__c (after insert,after update,after delete,after undelete) {

	String CurrentTime = (Date.today().month()>=7)?(Date.today().year()+'下半年'):(Date.today().year()+'上半年');
	List<Acute_GA__c> galist = new List<Acute_GA__c>();//满足计算条件的
	List<Acute_GA__c> IsDeletedList = new List<Acute_GA__c>();//被删除政策

	if(trigger.isInsert || trigger.isUpdate)
	{
		for(Acute_GA__c obj:trigger.new)
		{
			if(obj.GA_Acute_Year__c == CurrentTime)
			{
				galist.add(obj);
			}
		}
	}

	if(trigger.isDelete)
	{
		for(Acute_GA__c obj:trigger.old)
		{
			if(obj.GA_Acute_Year__c == CurrentTime)
			{
				IsDeletedList.add(obj);
			}
		}
	}

	if(trigger.isUndelete)
	{
		for(Acute_GA__c obj:trigger.new)
		{
			if(obj.GA_Acute_Year__c == CurrentTime)
			{	
				galist.add(obj);
			}
		}
	}
  /*****************更新城市及省份上的得分字段*******************/

  if(galist.size() > 0)
  {
  	GAComputeProvinceAndCityScore.AcuteGACompute(galist);
  }

  if(IsDeletedList.size() > 0)
  {
  	GAComputeProvinceAndCityScore.DeleteAcuteGACompute(IsDeletedList);
  }

}
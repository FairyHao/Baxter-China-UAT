/*
**Author:Dean
**Function:确保季度唯一
**Date：2015-9-28
*/
trigger CheckQuarterOnlyTrigger on RenalHospESRD__c (before insert,before update) 
{
	if(trigger.isInsert)
	{
    for(RenalHospESRD__c r:trigger.new)
        {
    	  
    	  String quarter = r.Quarter__c;
    	  Id accountId = r.Account__c;
    	  
          String sql = 'select count() from RenalHospESRD__c where Quarter__c =:quarter and Account__c =:accountId';
          Integer i =Database.countQuery(sql);
          if( i != 0)
          {
       	  	r.Quarter__c.adderror('该季度已存在！');
          }
       
        }  
    }

    if(trigger.isUpdate)
    {
    	for(RenalHospESRD__c newR:trigger.new)
        {
        	RenalHospESRD__c oldR = trigger.oldMap.get(newR.id);
        	if(newR.Quarter__c == oldR.Quarter__c)
        	{
        		continue;
        	}else{

        		String quarter = newR.Quarter__c;
    	  		Id accountId = newR.Account__c;
    	  
          		String sql = 'select count() from RenalHospESRD__c where Quarter__c =:quarter and Account__c =:accountId';
          		Integer i =Database.countQuery(sql);
          		if( i != 0)
         		 {
       	  			newR.Quarter__c.adderror('该季度已存在！');
         		 }
        			
        }
    }

    }
}
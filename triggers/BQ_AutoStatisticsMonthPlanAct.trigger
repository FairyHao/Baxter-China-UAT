/* Tobe
 * 2014.1.14
 * 月计划事件统计
 */
trigger BQ_AutoStatisticsMonthPlanAct on Event (after insert,after update) 
{
	RecordType recordType = [select Id From RecordType Where DeveloperName='V2_Event' and SobjectType = 'Event'];
	set<string> set_YearMonthOwner = new set<string>();
	set<Id> set_OwnerId = new set<Id>();
	for(Event ev : trigger.new)
	{
		if(ev.RecordTypeId != recordType.Id)
		{
			continue;
		}
		if(ev.SubjectType__c != '科室会'
		&& ev.SubjectType__c != '幻灯点评会'
		&& ev.SubjectType__c != '院内会'
		&& ev.SubjectType__c != '小型病案讨论会')
		{
			continue;
		}
		String flag = String.valueOf(ev.StartDateTime.year())+String.valueOf(ev.StartDateTime.month())+String.valueOf(ev.OwnerId).trim();
        set_YearMonthOwner.add(flag.Substring(0,flag.Length()-3));
        set_OwnerId.add(ev.OwnerId);
	}
	map<string,map<string,integer>> map_YearMonthOwner_Sub = new map<string,map<string,integer>>();
	for(Event ev : [Select OwnerId,Id,StartDateTime,SubjectType__c From Event 
							  Where OwnerId IN:set_OwnerId
							  and RecordTypeId =:recordType.Id
							  and (SubjectType__c ='科室会'
							  	Or SubjectType__c ='幻灯点评会'
							  	Or SubjectType__c ='院内会'
							  	Or SubjectType__c ='小型病案讨论会')])
	{
		String flag = String.valueOf(ev.StartDateTime.year())+String.valueOf(ev.StartDateTime.month())+String.valueOf(ev.OwnerId).trim();
        flag = flag.Substring(0,flag.Length()-3);
        
        if(map_YearMonthOwner_Sub.containsKey(flag))
        {
        	map<string,integer> temp = map_YearMonthOwner_Sub.get(flag);
        	if(temp.containsKey(ev.SubjectType__c))
        	{
        		integer eventCount =  temp.get(ev.SubjectType__c)+1;
        		temp.put(ev.SubjectType__c,eventCount);
        	}
        	else
        	{
        		temp.put(ev.SubjectType__c,1);
        	}
        	map_YearMonthOwner_Sub.put(flag,temp);
        }
        else
        {
        	map<string,integer> temp = new map<string,integer>();
    		temp.put(ev.SubjectType__c,1);
        	map_YearMonthOwner_Sub.put(flag,temp);
        }
	}
	list<MonthlyPlan__c> list_UpdateMonthlyPlan = new list<MonthlyPlan__c>();
	for(MonthlyPlan__c monthlyPlan : [select id,OwnerId,Year__c,Month__c,V2_MpYearMonthUserId__c,
											 BQ_Comments_will_actual__c,BQ_Departments_will_actual__c,
											 BQ_Small_medical_actual__c,BQ_Hospital_will_actual__c 
											 From MonthlyPlan__c 
											 Where V2_MpYearMonthUserId__c IN: set_YearMonthOwner])
	{
		if(map_YearMonthOwner_Sub.containsKey(monthlyPlan.V2_MpYearMonthUserId__c))
		{
			map<string,integer> temp = map_YearMonthOwner_Sub.get(monthlyPlan.V2_MpYearMonthUserId__c);
			if(temp.containsKey('科室会'))
			{
				monthlyPlan.BQ_Departments_will_actual__c = temp.get('科室会');
			}
			if(temp.containsKey('幻灯点评会'))
			{
				monthlyPlan.BQ_Comments_will_actual__c = temp.get('幻灯点评会');
			}
			if(temp.containsKey('院内会'))
			{
				monthlyPlan.BQ_Hospital_will_actual__c = temp.get('院内会');
			}
			if(temp.containsKey('小型病案讨论会'))
			{
				monthlyPlan.BQ_Small_medical_actual__c = temp.get('小型病案讨论会');
			}
			list_UpdateMonthlyPlan.add(monthlyPlan);
		}
	}
	update list_UpdateMonthlyPlan;
}
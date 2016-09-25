/**
 * Author : Bill
 * date : 2013-9-3
 * deacription : 业务机会活动历史数据处理
 * 使用以后再也没有用----不牵连任何项目
 * 2013-12-12 Tobe : 事件字段清除，去掉有关点评相关的4、5的字段的引用
 **/
global class ActivityFieldProcessingBatch implements Database.Batchable<sObject>
{
 	global Database.QueryLocator start(Database.BatchableContext BC)
 	{
 	   /* 2013-12-12 commented by Tobe
	  	return Database.getQueryLocator([Select Owner.Alias,Owner.UserRole.ParentRoleId, e.V2_Score__c, e.ReUser5__c, e.ReUser4__c,
			 e.ReUser3__c, e.ReUser2__c, e.ReUser1__c, WhatId,
			 e.Grade5__c, e.Grade4__c, e.Grade3__c, e.Grade2__c, e.Grade1__c, e.CommentsBySupervisor__c, 
			 e.Comment5__c, e.Comment4__c, e.Comment3__c, e.Comment2__c, e.Comment1__c, e.BeReviewed5__c, 
			 e.BeReviewed4__c, e.BeReviewed3__c, e.BeReviewed2__c, e.BeReviewed1__c From Event e 
			 where e.ReUser1__c != null and e.WhatId != null 
			 //and e.CommentsBySupervisor__c = null 
			 and e.Owner.IsActive = true
			 //and e.IsGroupEvent = false	
			 and e.IsChild = false]); */
		
		return Database.getQueryLocator([Select Owner.Alias,Owner.UserRole.ParentRoleId, e.V2_Score__c, 
			 e.ReUser3__c, e.ReUser2__c, e.ReUser1__c, WhatId,
			 e.Grade3__c, e.Grade2__c, e.Grade1__c, e.CommentsBySupervisor__c, 
			 e.Comment3__c, e.Comment2__c, e.Comment1__c, 
			 e.BeReviewed3__c, e.BeReviewed2__c, e.BeReviewed1__c From Event e 
			 where e.ReUser1__c != null and e.WhatId != null 
			 //and e.CommentsBySupervisor__c = null 
			 and e.Owner.IsActive = true
			 //and e.IsGroupEvent = false	
			 and e.IsChild = false]);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	/*
		//拜访事件的所有人的上级主管角色Id
		Set<ID> set_parIds = new Set<ID>();
		List<Event> list_events = new List<Event>();
		for(sObject sObj : scope)
		{
			Event ev = (Event)sObj;
			if(string.ValueOf(ev.WhatId).startsWith('006'))
			{
				set_parIds.add(ev.Owner.UserRole.ParentRoleId);
				list_events.add(ev);
			}
		}
		List<User> list_parUser=[Select Id,Name,Alias,UserRoleId From User Where UserRoleId IN : set_parIds And IsActive = true and Alias != null];
		//每个主管的别名
		Map<ID,string> map_parRoIds = new Map<ID,string>();
		if(list_parUser != null && list_parUser.size() > 0)
		{
			for(User user : list_parUser)
			{
				if(!map_parRoIds.containsKey(user.UserRoleId))
				{
					map_parRoIds.put(user.UserRoleId, User.Alias);
				}
			}
		}
		
		for(Event event : list_events)
		{
			if(!map_parRoIds.containsKey(event.Owner.UserRole.ParentRoleId))
			{
				continue;
			}
			String parAlisa = map_parRoIds.get(event.Owner.UserRole.ParentRoleId);
			
			if(parAlisa == event.ReUser1__c && event.BeReviewed1__c == event.Owner.Alias)
			{
				event.V2_Score__c = event.Grade1__c;
		      	event.CommentsBySupervisor__c = event.Comment1__c;
			}
			else if(parAlisa == event.ReUser2__c && event.ReUser2__c != null && event.BeReviewed2__c == event.Owner.Alias)
			{
				event.V2_Score__c = event.Grade2__c;
		      	event.CommentsBySupervisor__c = event.Comment2__c;
			}
			else if(parAlisa == event.ReUser3__c && event.ReUser3__c != null && event.BeReviewed3__c == event.Owner.Alias)
			{
				event.V2_Score__c = event.Grade3__c;
		      	event.CommentsBySupervisor__c = event.Comment3__c;
			}
			else if(parAlisa == event.ReUser4__c && event.ReUser4__c != null && event.BeReviewed4__c == event.Owner.Alias)
			{
				event.V2_Score__c = event.Grade4__c;
		      	event.CommentsBySupervisor__c = event.Comment4__c;
			}
			else if(parAlisa == event.ReUser5__c && event.ReUser5__c != null && event.BeReviewed5__c == event.Owner.Alias)
			{
				event.V2_Score__c = event.Grade5__c;
		      	event.CommentsBySupervisor__c = event.Comment5__c;
			}
		}
		update list_events;
		*/
    }
    global void finish(Database.BatchableContext BC){
    	
    }
}
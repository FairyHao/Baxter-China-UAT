/**
 * Author : Bill
 * date : 2013-7-31
 * deacription : 每日代表销售拜访会上传附件签收单，该方法每日晚上执行
 * 把代表上传的附件更新到活动自定义字段  1.附件ID 2.签收单名称  3.给附件所有人的上级发邮件告知他 
 **/
global class AttachmentUpLoadBatch implements Database.Batchable<sObject>
{
   global Database.QueryLocator start(Database.BatchableContext BC){
    	    	//获取发生修改的拜访事件BIOS部门
    	Set<ID> blosIds = new Set<ID>();
    	for(UserRole role : [Select Id from UserRole where Name like '%BIOS%'])  
    	{ 
    		blosIds.add(role.Id); 
    	}
    	return Database.getQueryLocator([Select e.Id, e.Subject, e.Owner.Alias, e.Who.Name, e.AttNumber__c, e.LastModifiedDate From Event e Where e.Owner.UserRoleId in : blosIds and e.RecordType.Name = '拜访' AND LastModifiedDate = TODAY]);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	//事件ID
    	Set<ID> set_eventids = new Set<ID>();
    	//附件添加人ID
    	Set<ID> set_owner = new Set<ID>();
		//上传附件的拜访事件
		Map<ID,Event> map_event = new Map<ID,Event>();
    	//拜访事件附件
    	Map<ID,List<Attachment>> map_eventAtt = new Map<ID,List<Attachment>>();
    	//拜访联系人
    	Map<ID,String> map_eventCon = new Map<ID,String>();
    	//上传附件数量
    	Map<ID,double> map_attNum = new Map<ID,double>();
    	
		for(sObject sObj : scope)
		{
    		Event vat = (Event)sObj;
    		set_eventids.add(vat.Id);
    		map_eventCon.put(vat.Id, vat.Who.Name);
    		map_attNum.put(vat.Id,vat.AttNumber__c);
		}
		List<Attachment> list_att = [Select a.OwnerId, a.Owner.Alias, a.Body, a.Name, a.Id, a.CreatedDate, a.ParentId From Attachment a where ParentId in:set_eventids and CreatedDate = TODAY];
		
		if(list_att != null && list_att.size()>0)
		{
			for(Attachment att : list_att)
			{
				if(!map_event.containsKey(att.ParentId))
				{
					List<Attachment> list_eAtt = new List<Attachment>();
					list_eAtt.add(att);
					map_eventAtt.put(att.ParentId, list_eAtt);
					Event event = new Event();
					event.Id = att.ParentId;
					event.AttachmentId__c = att.Id;
					event.UpLoaded__c = true;
					double attNum = map_attNum.get(att.ParentId)==null?0:map_attNum.get(att.ParentId);
					event.AttNumber__c = attNum + 1;
					set_owner.add(att.OwnerId);
					map_event.put(att.ParentId,event);
				}else{
					map_eventAtt.get(att.ParentId).add(att);
					Event event = map_event.get(att.ParentId);
					event.AttNumber__c = event.AttNumber__c + 1;
				}
			}
			List<Event> list_event = map_event.values();
			if(list_event != null && list_event.size()>0)
			{
				update list_event;
			}
		}
		if(set_owner != null && set_owner.size()>0)
		{
			//上级Id
			Map<ID,ID> map_par = new Map<ID,ID>();
			//上级邮箱
			Map<ID,String> map_parEmail = new Map<ID,String>();
			for(User user : [Select u.UserRole.ParentRoleId, u.Id From User u where u.Id in : set_owner and u.IsActive = true])
			{
				map_par.put( user.Id , user.UserRole.ParentRoleId);
			}
			//BIOS-National-全国-All-Manager(许红雨)的角色ID————XuId 只允许许红雨以下的主管收到邮件
			//2015-2-6 Sunny：许红雨角色已经不再，修改为查询“BIOS-National-全国-All-Manager(BUD)”
			//ID XuId = [Select u.Id, u.Name From UserRole u where u.Name like '%许红雨%'].Id;
			List<UserRole> list_ur = [Select u.Id, u.Name From UserRole u where u.Name like 'BIOS-National-全国-All-Manager(BUD)%'];
			ID XuId = (list_ur.size()>0?list_ur[0].Id:null);
			V2_UtilClass util = new V2_UtilClass();
			List<ID> list_UserIds =util.getSubordinateIds(XuId);
			for(User user : [Select u.UserRoleId, u.Email From User u where UserRoleId in : map_par.values() and u.Id in : list_UserIds and u.IsActive = true])
			{
				map_parEmail.put(user.UserRoleId , user.Email);
			}
			for(Event event : map_event.values())
			{
			 	string baseUrl = string.valueOf(System.URL.getSalesforceBaseUrl());
			 	baseUrl = baseUrl.substring(baseUrl.indexOf('=')+1,baseUrl.length()-1);
			 	baseUrl = baseUrl+'/'+ event.Id;
			 	Messaging.EmailFileAttachment[] list_efa = new Messaging.EmailFileAttachment[]{};
			 	String emailAddress;
			 	String UpSaleName  = '';
			 	String UpTime  = '';
			 	for(Attachment att : map_eventAtt.get(event.Id))
			 	{
					Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
				    efa.setFileName(att.Name);
				    efa.setBody(att.Body);
				    list_efa.add(efa);
				    if(map_par.get(att.OwnerId) != null)
				    {
				    	emailAddress = map_parEmail.get(map_par.get(att.OwnerId));
				    }
				    UpSaleName = att.Owner.Alias;
				    UpTime = string.valueOf(att.CreatedDate);
			 	}
			 	system.debug('klmzgxm'+emailAddress);
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String repBody = '';
				repBody += '您好: <br><br>';     
       		 	repBody += '您所负责的代表今天上传新的附件,请及时查收<br>';
       		 	repBody += '代表别名：'+UpSaleName+'<br>';
       		 	repBody += '附件上传时间：'+UpTime+'<br>';
       		 	repBody += '拜访查看链接：<a href="' + baseUrl + '">' + baseUrl + '</a><br><br>';
	            repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。<br>'; 
	            repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>';
	            //String emailAddress = map_parEmail.get(map_par.get(event.OwnerId));
	            String[] repAddress =new string[]{emailAddress};
	            mail.setToAddresses(repAddress);
	            mail.setHtmlBody(repBody);
	            mail.setSubject(UpSaleName+'对'+map_eventCon.get(event.Id)+'的拜访上传了附件，请查看');
	            mail.setSenderDisplayName('Salesforce');
	            mail.setFileAttachments(list_efa);
	            if(emailAddress != null)
	            {
	            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	            }
			}
		}
    }
    global void finish(Database.BatchableContext BC){
    	
    }
}
/**
 * Author:Storm
 * 当挥发罐使用申请选择(或更换)联系人后，自动获取到该联系人对应的医院并赋值到医院字段
 * 当挥发罐申请数量不为空时，增加后挥发罐数量=增加前挥发罐数量+挥发罐申请数量
 * 2013-6-4Sunny : 添加
**/
trigger AutoGetInfoForApplication on Vaporizer_Application__c (before update , before insert) {
    if(trigger.isBefore){
            Set<Id> contactIds = new Set<Id>();
            for(Vaporizer_Application__c vapApp : trigger.new){
                if(vapApp.Contact__c != null){
                    contactIds.add(vapApp.Contact__c);
                }
                if(vapApp.Vaporizer_Apply_Quantity__c != null && vapApp.BeforeApply_VaporAmount__c != null)
                {
                    vapApp.AfterApply_VaporAmount__c=vapApp.Vaporizer_Apply_Quantity__c+vapApp.BeforeApply_VaporAmount__c; 
                }
             }
             if(contactIds.size()>0){
                List<Contact> contactList = [select Id,AccountId,Phone,MobilePhone from contact where Id in:contactIds limit 1000];
                Map<Id,Contact> contactAccountMap = new Map<Id,Contact>();
                for(Contact con:contactList)
                 {
                    contactAccountMap.put(con.Id,con);
                }
                 for(Vaporizer_Application__c vapApp : trigger.new){
                    if(vapApp.Contact__c != null){
                        vapApp.Hospital__c = contactAccountMap.get(vapApp.Contact__c).AccountId;
                        if(vapApp.HospitalContactPhone__c == null)
                            if(contactAccountMap.get(vapApp.Contact__c).Phone != null)
                                vapApp.HospitalContactPhone__c = contactAccountMap.get(vapApp.Contact__c).Phone;
                            else
                                vapApp.HospitalContactPhone__c = contactAccountMap.get(vapApp.Contact__c).MobilePhone;
                    }
                 }
             }
    }
    if(trigger.isBefore){
    	Set<ID> set_OwnerId = new Set<ID>();
    	Map<ID,String> map_UserPhone = new Map<ID,String>();
    	for(Vaporizer_Application__c vapApp : trigger.new){
    		if(trigger.isUpdate && vapApp.OwnerId != trigger.oldMap.get(vapApp.Id).OwnerId){
    			set_OwnerId.add(vapApp.OwnerId);
    		}else if(trigger.isInsert && vapApp.OwnerId!=null){
    			set_OwnerId.add(vapApp.OwnerId);
    		}
    	}
    	if(set_OwnerId.size() >0){
    		for(User objU:[select Id,MobilePhone From User Where Id in: set_OwnerId]){
    			map_UserPhone.put(objU.Id,objU.MobilePhone);
    		}
    	}
    	if(map_UserPhone.size() > 0){
    		for(Vaporizer_Application__c vapApp : trigger.new){
    			if(map_UserPhone.containsKey(vapApp.OwnerId)){
    				vapApp.SalesContactPhone__c = map_UserPhone.get(vapApp.OwnerId);
    			}
    		}
    	}
    }
}
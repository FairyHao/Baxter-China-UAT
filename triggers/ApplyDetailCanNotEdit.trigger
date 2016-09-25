/**
 * Author : Sunny
 * 功能：当挥发罐使用申请处于“审批中”的时候，不允许新建、修改、删除申请明细
 * 2013-6-9 Bill添加功能，
 * 当挥发使用申请在"通过"时，不允许插入、修改、删除申请明细
 * 2013-6-26 Bill添加功能，
 * 当挥发罐使用申请处于“全部完成”的时候，不允许新建、修改、删除申请明细
**/
trigger ApplyDetailCanNotEdit on Vaporizer_Apply_Detail__c (before delete, before insert, before update) {
	List<ID> list_VapAppIds = new List<ID>();
	Set<ID> set_VapAppIds = new Set<ID>();
    if(trigger.isInsert || trigger.isUpdate){
    	for(Vaporizer_Apply_Detail__c VapApplyDetail : trigger.new){
    		if(VapApplyDetail.Vaporizer_Application__c != null){
    			list_VapAppIds.add(VapApplyDetail.Vaporizer_Application__c);
    		}
    	}
    }else if(trigger.isDelete){
    	for(Vaporizer_Apply_Detail__c VapApplyDetail : trigger.old){
            if(VapApplyDetail.Vaporizer_Application__c != null){
                list_VapAppIds.add(VapApplyDetail.Vaporizer_Application__c);
            }
        }
    }
    if(list_VapAppIds.size() > 0){
    	/******************Bill Update 2013/6/9 start**********************/
    	for(Vaporizer_Application__c va:[Select Id From Vaporizer_Application__c Where id in:list_VapAppIds And Approve_Result__c in ('审批中','通过','全部完成')]){
    		set_VapAppIds.add(va.Id);
    	}
    }
    
    if(set_VapAppIds.size() > 0){
    	if(trigger.isInsert){
        for(Vaporizer_Apply_Detail__c VapApplyDetail : trigger.new){
            if(set_VapAppIds.contains(VapApplyDetail.Vaporizer_Application__c)){
                VapApplyDetail.addError('申请状态为“审批中”、“通过”或“全部完成”时,不允许操作。');
            }
        }
    }else if(trigger.isUpdate){
    	for(Vaporizer_Apply_Detail__c VapApplyDetail : trigger.new){
            if(set_VapAppIds.contains(VapApplyDetail.Vaporizer_Application__c)){
                if(VapApplyDetail.DeliveredAmount__c != trigger.oldMap.get(VapApplyDetail.Id).DeliveredAmount__c)
	            {}else{
	              VapApplyDetail.addError('申请状态为“审批中”、“通过”或“全部完成”时,不允许操作。');
	            }
            }
        }
    }else if(trigger.isDelete){
        for(Vaporizer_Apply_Detail__c VapApplyDetail : trigger.old){
            if(set_VapAppIds.contains(VapApplyDetail.Vaporizer_Application__c)){
                VapApplyDetail.addError('申请状态为“审批中”、“通过”或“全部完成”时,不允许操作。');
            }
        }
    }
    /******************Bill Update 2013/6/9 end**********************/
   }
}
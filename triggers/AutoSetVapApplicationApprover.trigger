/**
 * Author ： Sunny
 * 当挥发罐使用申请创建/更新所有人的时候根据申请所有人设置申请的审批人
 * 2013-5-29 Sunny添加功能，
 * 2.当挥发使用申请在审批中时，不允许修改
 * 3.当挥发使用申请在审批中时，不允许删除
 * 2013-6-9 Bill添加功能，
 * 当挥发使用申请在"通过"时，不允许修改、删除
 * 2013-6-26 Bill添加功能，
 * 当挥发使用申请全部完成时，不允许修改、删除
 **/
trigger AutoSetVapApplicationApprover on Vaporizer_Application__c (before insert, before update, before delete) {
    List<ID> listownerid = new List<ID>();
    SetApprovoerHelper Helper = new SetApprovoerHelper();
    if(trigger.isInsert || trigger.isUpdate){
        for(Vaporizer_Application__c VapApplication : trigger.new){
            if(trigger.isUpdate && VapApplication.OwnerId == trigger.oldMap.get(VapApplication.Id).OwnerId){
                continue;
            }
            VapApplication.VapAdmin__c = Helper.getVaporizerAdmin();
            VapApplication.DesProductManager__c = Helper.getVapProductManagerDes();
            VapApplication.SevoProductManager__c = Helper.getVapProductManagerSevo();
            VapApplication.NationalDirector__c = Helper.getNationalDirector();
            VapApplication.Financial_Analyst__c= Helper.getFinancial();
            Map<String , Id> map_Managers = Helper.getHierarchy(VapApplication.OwnerId) ;
            if(map_Managers.containsKey('REGIONAL')){
                VapApplication.RegionalManager__c = map_Managers.get('REGIONAL');
            }
            if(map_Managers.containsKey('AREA')){
                VapApplication.AreaManager__c = map_Managers.get('AREA');
            }
            if(map_Managers.containsKey('DISTRICT')){
                VapApplication.DistrictManager__c = map_Managers.get('DISTRICT');
            }
            if(map_Managers.containsKey('SUPERVISOR')){
                VapApplication.SalesSupervisor__c = map_Managers.get('SUPERVISOR');
            }
        }
    }
    /******************Bill Update 2013/6/9 start**********************/
    if(trigger.isUpdate){
        for(Vaporizer_Application__c VapApplication : trigger.new){
            if((VapApplication.Approve_Result__c == '审批中' || VapApplication.Approve_Result__c == '通过' || VapApplication.Approve_Result__c == '全部通过')&& VapApplication.Approve_Result__c == trigger.oldMap.get(VapApplication.Id).Approve_Result__c){
                if(VapApplication.CurrentApprover__c == trigger.oldMap.get(VapApplication.Id).CurrentApprover__c){
                    VapApplication.addError('申请状态为“审批中”、“通过”或“全部完成”时,不允许操作。');
                }
            }
        }
    }
    if(trigger.isDelete){
        for(Vaporizer_Application__c VapApplication : trigger.old){
            if(VapApplication.Approve_Result__c == '审批中' || VapApplication.Approve_Result__c == '通过' || VapApplication.Approve_Result__c == '全部通过'){
                VapApplication.addError('申请状态为“审批中”、“通过”或“全部完成”时,不允许操作。');
            }
        }
    }
    /******************Bill Update 2013/6/9 end**********************/
}
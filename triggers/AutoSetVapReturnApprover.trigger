/**
 * Author ： Sunny
 * 1.当挥发罐维修/退回申请创建/更新所有人的时候根据申请所有人设置申请的审批人
 * 2013-5-29 Sunny添加功能，
 * 2.当挥发罐维修/退回申请在审批中时，不允许修改
 * 3.插入时，根据所选择联系人自动带出联系人所属客户
 * 4.自动带出所有人的手机
 * 2013-6-5 Sunny 添加功能
 * 当挥发罐维修退回申请在审批中时，不允许删除
 * 2013-6-9 Bill添加功能，
 * 当挥发使用申请在"通过"时，不允许修改、删除
 * 2013-6-26 Bill添加功能，
 * 当挥发使用申请在"全部完成"时，不允许修改、删除
 **/
trigger AutoSetVapReturnApprover on Vaporizer_ReturnAndMainten__c (before insert, before update , before delete) {
    List<ID> listownerid = new List<ID>();
    SetApprovoerHelper Helper = new SetApprovoerHelper();
    //#1
    if(trigger.isInsert || trigger.isUpdate){
        for(Vaporizer_ReturnAndMainten__c VapReturn : trigger.new){
            if(trigger.isUpdate && VapReturn.OwnerId == trigger.oldMap.get(VapReturn.Id).OwnerId){
                continue;
            }
            VapReturn.VapAdmin__c = Helper.getVaporizerAdmin();
            VapReturn.DesProductManager__c = Helper.getVapProductManagerDes();
            VapReturn.SevoProductManager__c = Helper.getVapProductManagerSevo();
            VapReturn.NationalDirector__c = Helper.getNationalDirector();
            VapReturn.Financial_Analyst__c= Helper.getFinancial();
            Map<String , Id> map_Managers = Helper.getHierarchy(VapReturn.OwnerId) ;
            if(map_Managers.containsKey('REGIONAL')){
                VapReturn.RegionalManager__c = map_Managers.get('REGIONAL');
            }
            if(map_Managers.containsKey('AREA')){
                VapReturn.AreaManager__c = map_Managers.get('AREA');
            }
            if(map_Managers.containsKey('DISTRICT')){
                VapReturn.DistrictManager__c = map_Managers.get('DISTRICT');
            }
            if(map_Managers.containsKey('SUPERVISOR')){
                VapReturn.SalesSupervisor__c = map_Managers.get('SUPERVISOR');
            }
        }
    }
    //#2
    if(trigger.isUpdate){
        for(Vaporizer_ReturnAndMainten__c VapReturn : trigger.new){
            if((VapReturn.Approve_Result__c == '审批中' || VapReturn.Approve_Result__c == '通过' || VapReturn.Approve_Result__c == '全部完成') && VapReturn.Approve_Result__c == trigger.oldMap.get(VapReturn.Id).Approve_Result__c){
                if(VapReturn.CurrentApprover__c == trigger.oldMap.get(VapReturn.Id).CurrentApprover__c){
                    VapReturn.addError('申请状态为“审批中”、“通过”或 “全部完成”时,不允许操作。');
                }
            }
        }
    }
    //#3
    if(trigger.isInsert || trigger.isUpdate){
        List<ID> list_ContactId = new List<ID>();
        for(Vaporizer_ReturnAndMainten__c VapReturn : trigger.new){
            if(trigger.isUpdate && VapReturn.StockContact__c == trigger.oldMap.get(VapReturn.Id).StockContact__c){
                continue;
            }
            if(VapReturn.StockContact__c != null){
                list_ContactId.add(VapReturn.StockContact__c);
            }
        }
        Map<ID,ID> map_conAccId = new Map<ID,ID>();
        if(list_ContactId.size() > 0){
            for(Contact Con : [Select Id,AccountId From Contact Where Id in: list_ContactId]){
                map_conAccId.put(Con.Id,Con.AccountId);
            }
        }
        if(map_conAccId.size() > 0){
            for(Vaporizer_ReturnAndMainten__c VapReturn : trigger.new){
                if(VapReturn.StockContact__c != null && map_conAccId.containsKey(VapReturn.StockContact__c)){
                    VapReturn.Hospital__c = map_conAccId.get(VapReturn.StockContact__c);
                }
            }
        }
    }
    //#4
    if(trigger.isInsert || trigger.isUpdate){
        Set<ID> set_OwnerId = new Set<ID>();
        Map<ID,String> map_UserPhone = new Map<ID,String>();
        for(Vaporizer_ReturnAndMainten__c VapReturn : trigger.new){
            if(trigger.isUpdate && VapReturn.OwnerId != trigger.oldMap.get(VapReturn.Id).OwnerId){
                set_OwnerId.add(VapReturn.OwnerId);
            }else if(trigger.isInsert && VapReturn.OwnerId!=null){
                set_OwnerId.add(VapReturn.OwnerId);
            }
        }
        if(set_OwnerId.size() >0){
            for(User objU:[select Id,MobilePhone From User Where Id in: set_OwnerId]){
                map_UserPhone.put(objU.Id,objU.MobilePhone);
            }
        }
        if(map_UserPhone.size() > 0){
            for(Vaporizer_ReturnAndMainten__c VapReturn : trigger.new){
                if(map_UserPhone.containsKey(VapReturn.OwnerId)){
                    VapReturn.SalesContactPhone__c = map_UserPhone.get(VapReturn.OwnerId);
                }
            }
        }
    }
    //#
    if(trigger.isDelete){
        for(Vaporizer_ReturnAndMainten__c VapReturn : trigger.old){
            if(VapReturn.Approve_Result__c == '审批中' || VapReturn.Approve_Result__c == '通过' || VapReturn.Approve_Result__c == '全部完成'){
                VapReturn.addError('申请状态为“审批中”、“通过”或“全部完成”时,不允许操作。');
            }
        }
    }
}
/**
*author john
*create:2015-4-1
*当新建或者删除策略医院时，是否是策略医院字段自动的复选框会自动更新。
*去除原本“每半年根据HD医院信息下的是否HD策略医院刷新客户下的是否HD策略医院”的逻辑，并删除“是否HD策略医院”字段
*/
trigger HD_JudgingIsHDtactics on HDHospitalInfo__c (after insert,after update,after delete) 
{
    // Map<ID,boolean> map_AccountHdhos = new Map<ID,Boolean>();
    // if(trigger.isInsert||trigger.isUpdate)
    // {
    //     for(HDHospitalInfo__c hdInfo:trigger.new)   
    //     {
    //         Date startDate = hdInfo.HD_Year_temp__c;
    //         Date endDate = startDate.addMonths(6);
    //         if(!(Date.today() >= startDate && Date.today() < endDate))
    //         {
    //             continue;
    //         }
    //         if(trigger.isInsert)
    //         {
    //             map_AccountHdhos.put(hdInfo.HD_AccountID__c,hdInfo.HD_IsHDtactics__c);
    //         }
    //         else if(trigger.isUpdate && hdInfo.HD_IsHDtactics__c != trigger.oldMap.get(hdInfo.Id).HD_IsHDtactics__c)
    //         {
    //             map_AccountHdhos.put(hdInfo.HD_AccountID__c,hdInfo.HD_IsHDtactics__c);  
    //         }
    //     }
    // }
    // else if(trigger.isDelete)
    // {
    //     for(HDHospitalInfo__c hdInfo:trigger.old)
    //     {
    //         Date startDate = hdInfo.HD_Year_temp__c;
    //         Date endDate = startDate.addMonths(6);
    //         if(Date.today() >= startDate && Date.today() < endDate)
    //         {
    //             map_AccountHdhos.put(hdInfo.HD_AccountID__c,false);  
    //         }
    //     }
    // }
    // if(map_AccountHdhos.size() > 0)
    // {
    //     list<Account> list_AccUp = new list<Account>();
    //     for(ID accId : map_AccountHdhos.keySet())
    //     {
    //         Account acc = new Account();
    //         acc.ID = accId;
    //         acc.HD_IsHDtactics__c = map_AccountHdhos.get(accId);
    //         list_AccUp.add(acc);
    //     }
    //     update list_AccUp;
    // }
}
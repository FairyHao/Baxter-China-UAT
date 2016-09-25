/**
 * Author:Sunny
 * Modified By Storm 05-28:修改为删除数据时报告错误，不允许删除审批数据
 */
trigger AutoUpdateApproveStatus on Vaporizer_Approve__c (before delete) {
   if(Trigger.isDelete)
   {
       for(Vaporizer_Approve__c vapApprove:trigger.old)
       {
           vapApprove.addError('不允许删除审批数据。');
       }
   }
}
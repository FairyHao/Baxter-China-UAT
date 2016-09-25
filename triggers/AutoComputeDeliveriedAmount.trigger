/*
 *开发人:Storm
 *时间：2013-5-27
 *模块:挥发罐发货明细
 *功能:当删除挥发罐发货明细时, 自动更新其相关的申请明细(维修/退回申请明细)中的已发货数量字段的值
 *bill  添加 2013/6/18
 * 每次更新发货明细时，都会判断对应的申请的挥发罐申请数量和已确认收货的发货明细的数量是否相等，若想等则更审批状态为全部完成
 * BILL 添加2013/6/19
 * 已发货的发货明细是不允许的编辑和删除
 */
trigger AutoComputeDeliveriedAmount on Vaporizer_Application_Detail__c (before delete, before update, after update) {
    if(trigger.isDelete)
   {
      Set<Id> newApplyDetailIds = new Set<Id>();
      Set<Id> returnApplyDetailIds = new Set<Id>();
      for(Vaporizer_Application_Detail__c vapApp:trigger.old)
      {
      	/********************bill update 2013/6/19 START********************************/
      	if(vapApp.IsDelivered__c == true)
      	{
      		vapApp.addError('已经确认发货的发货明细不允许删除');
      	}
      	/********************bill update 2013/6/19 END********************************/
        //判断发货明细中的“Vaporizer_Apply_Detail__c”-使用申请明细字段是否为空
        if(vapApp.Vaporizer_Apply_Detail__c<>null)
        {
            newApplyDetailIds.add(vapApp.Vaporizer_Apply_Detail__c);
        }
        if(vapApp.Vaporizer_ReturnAndMainten_Detail__c<>null)
        {
            returnApplyDetailIds.add(vapApp.Vaporizer_ReturnAndMainten_Detail__c);
        }
      }
      //查找所有相关的使用申请明细，并更新其中的"已发货数量"
      List<Vaporizer_Apply_Detail__c> newApplyDetails = [select Id,DeliveredAmount__c from Vaporizer_Apply_Detail__c where Id in:newApplyDetailIds];
      if(newApplyDetails<>null)
      {
          for(Vaporizer_Apply_Detail__c newApplyDetail:newApplyDetails){
                newApplyDetail.DeliveredAmount__c = newApplyDetail.DeliveredAmount__c-1;
          }
          update newApplyDetails;
      }
      //查找所有相关的
      List<Vaporizer_ReturnAndMainten_Detail__c> returnApplyDetails = [select Id,DeliveredAmount__c from Vaporizer_ReturnAndMainten_Detail__c where Id in:returnApplyDetailIds];
     if(returnApplyDetails<>null)
      {
          for(Vaporizer_ReturnAndMainten_Detail__c returnApplyDetail:returnApplyDetails){
                returnApplyDetail.DeliveredAmount__c = returnApplyDetail.DeliveredAmount__c-1;
          }
          update returnApplyDetails;
      }
   }
   
   if(trigger.isBefore && trigger.isUpdate)
   {
	   	for(Vaporizer_Application_Detail__c vapApp:trigger.new)
	      {
	   		//判断该发货明细是否已发货
	      	if(trigger.oldMap.get(vapApp.Id).IsDelivered__c == true && (trigger.oldMap.get(vapApp.Id).IsReceived__c == vapApp.IsReceived__c))
	      	{
	      		   vapApp.addError('已经确认发货的发货明细不允许编辑');
	      	}
	      }
   }
   
   if(trigger.isAfter && trigger.isUpdate)
   {
   	  Set<Id> newApplyIds = new Set<Id>();
      Set<Id> returnApplyIds = new Set<Id>();
      
      //全部完成的使用申请和退回申请
      List<Vaporizer_Application__c> list_CompletedApply = new List<Vaporizer_Application__c>();
      
      for(Vaporizer_Application_Detail__c vapApp:trigger.new)
      {
      	if(vapApp.IsReceived__c == false)
      	{
      		continue;
      	}
        //判断发货明细中的“Vaporizer_Apply_Detail__c”-使用申请明细字段是否为空
        if(vapApp.Vaporizer_Apply_Detail__c<>null)
        {
            newApplyIds.add(vapApp.Vaporizer_Application__c);
        }
        if(vapApp.Vaporizer_ReturnAndMainten_Detail__c<>null)
        {
            returnApplyIds.add(vapApp.Vaporizer_ReturnAndMainten__c);
        }
      }
      
      List<Vaporizer_Application_Detail__c> list_apply = [select v.Id, v.Vaporizer_Application__c from Vaporizer_Application_Detail__c v where v.Vaporizer_Application__c in : newApplyIds and v.IsReceived__c = true];
      List<Vaporizer_Application__c> list_app = [Select v.Id, v.Vaporizer_Apply_Quantity__c, v.Approve_Result__c From Vaporizer_Application__c v where v.Id in:newApplyIds];
      
      for(Vaporizer_Application__c app : list_app){
      	double sumRece =0;
      	for(Vaporizer_Application_Detail__c apply : list_apply)
        {
        	if(app.Id == apply.Vaporizer_Application__c)
        	{
        		sumRece++;
        	}
        }
        if(sumRece == app.Vaporizer_Apply_Quantity__c)
        {
        	app.Approve_Result__c = '全部完成';
        	list_CompletedApply.add(app);
        }
      }
      
      //退回明细牵连退回明细，所以使用公共类ReturnCompleted.cls
      //确认收货后判断该退回申请是否全部完成
      ReturnCompleted complete = new ReturnCompleted();
      complete.IsReturnCompleted(returnApplyIds);
      if(list_CompletedApply != null && list_CompletedApply.size()>0){
        update list_CompletedApply;
      }
   }
}
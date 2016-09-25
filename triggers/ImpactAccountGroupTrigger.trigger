//////////////////////////////////////////////
///Spring Mon Now 23
//////////////////////////////////////////////
trigger ImpactAccountGroupTrigger on ImpactAccountGroup__c(after update, after insert,before insert) {
    ImpactAccountTriggerHandler handler = new ImpactAccountTriggerHandler();
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.doPass(Trigger.oldMap, Trigger.newMap);
    }


    if (Trigger.isAfter && Trigger.isInsert) {
    		handler.doSave(Trigger.new);
    }

    if(trigger.isBefore && trigger.isInsert)
    {
        ImpactAccountGroup__c temp = handler.checkNumberOfTeam(Trigger.new);
    	if( temp!= null)
        {
            temp.addError('已经存在业务机会合作者，请先删除再执行添加操作');
        }

        for (ImpactAccountGroup__c mb : Trigger.new){
            mb.status__c = '新建';
        }
    }
}
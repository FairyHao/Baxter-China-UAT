/*
 *开发人:Scott
 *时间：2013-3-19
 *模块:Event
 *功能描述：
 *在新建事件或更新开始或结束时间时，自动将开始和结束时间赋值给自定义字段，因为标准的开始和结束时间无法在自定义报表类型中拉出来
*/
trigger EventBfInAutoRecordTime on Event (before insert, before update) {

    /*if(trigger.isInsert)
    {
        for(Event ev : trigger.new)
        {
            ev.StartDateTime__c = ev.StartDateTime;
            ev.EndDateTime__c = ev.EndDateTime;
        }
    }
    if(trigger.isUpdate)
    {
        for(Event newev : trigger.new)
        {
            Event oldev = trigger.oldMap.get(newev.Id);
            if(newev.StartDateTime != oldev.StartDateTime || newev.EndDateTime != oldev.EndDateTime)
            {
                newev.StartDateTime__c = newev.StartDateTime;
                newev.EndDateTime__c = newev.EndDateTime;
            }
        }
    }*/
}
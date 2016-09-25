/*
*author:mark
*date:2015-07-07
*function:删除Wechat Action的同时删除Outbound Message
**/
trigger DeleteOutboundMessage on Wechat_Action__c (after Delete) 
{
    List<string> fullNames = new List<string>();
    for(Wechat_Action__c wa : trigger.old)
    {
        //拼接删除当前Action对应的Outbound message所需的fullName
        string fullName = wa.Related_Object__c + '.' + 'Wlink__Wechat_Action_' + wa.No__c;
        fullNames .add(fullName);
    }
    if(!fullNames.isempty())
    {
        WechatActionExtension.DeleteOutboundMessage(fullNames, UserInfo.getSessionId());
    }
}
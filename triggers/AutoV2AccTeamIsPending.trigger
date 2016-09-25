/**
 * Author : Bill
 * date : 2013-7-25
 * 功能：当销售医院关系由审批中变为审批通过时，待处理复选框选中，
 * 此字段方便ClsV2AccountTeamChangeBatch同步 IVT医院信息所有人、 SP医院信息所有人、  共享IN Project业务机会、
 * 挥发罐所有人时判断使用。 
**/

trigger AutoV2AccTeamIsPending on V2_Account_Team__c (before update, after insert) 
{
    if(trigger.isBefore || trigger.IsUpdate)
    {
        //获取系统管理员的简档Id
        /*============Scott 2013-12-5修改=================*/
        /*修复当繁体系统时，因查不到名Name为‘系统管理员’的简档报错问题*/
        /*原逻辑ID userProID = [Select ID from Profile where Name = '系统管理员'][0].Id;*/
        
        ID userProID;
        List<Profile> List_Profile = [Select ID from Profile where Name = '系统管理员'];
        if(List_Profile!=null && List_Profile.size()>0)
        {
            userProID = List_Profile[0].Id;
        }
        else
        {
            return;//如果查不到系统管理员简档则退出程序
        }
        
        /*============Scott 2013-12-5修改=================*/
        for(V2_Account_Team__c team : trigger.new)
        {
            if(UserInfo.getProfileId() != userProID && team.V2_ApprovalStatus__c == '审批通过')
            {
                team.IsPending__c = true;
            }
        }
    }
}
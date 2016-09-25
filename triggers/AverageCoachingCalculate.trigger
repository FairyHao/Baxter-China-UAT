/*
Amy
2014/11/4
汇总Session的总数和SE/SEM的总人数，算出平均每月的session数。
2014-11-7 Sunny修改汇总人数按照做了session的人数，而不是全部人数。
11-Mar-2016 Changed by Weldon  根据辅导日期来统计每个月的辅导次数；根据辅导课程来统计辅导人数
*/

trigger AverageCoachingCalculate on Coaching_Session__c(after insert,after Delete,after update) 
{

	Date startDate = date.today().toStartOfMonth();
	Date endDate = date.today().addMonths(1).toStartOfMonth().addDays(-1);
    //get all the completed session list in current month
    List<Coaching_Session__c>  CoachingList=[select LoggedIn_User__r.Ace_Role__c,LoggedIn_User__c from Coaching_Session__c where startDate__c>=:startDate and 
    startDate__c<=:endDate and isCompleted__c=true];//汇总当月的session数。


    Integer SMNum=0; // SM session number
    Integer SEMNum=0;// SEM session number
    
    Set<String> set_SMRole = new Set<String>(); // used for SM people number counting
    Set<String> set_SEMRole = new Set<String>(); // used for SEM people number counting
    for(Coaching_Session__c coaching:CoachingList)
    {
        if(coaching.LoggedIn_User__r.Ace_Role__c == 'SM')
        {
            system.debug('SM');
            SMNum++;    //记录次数
            set_SMRole.add(coaching.LoggedIn_User__c);  //记录人数
        }else if(coaching.LoggedIn_User__r.Ace_Role__c == 'SEM')
        {
            system.debug('SEM');
            SEMNum++;   //记录次数
            set_SEMRole.add(coaching.LoggedIn_User__c);//记录人数
        }
    }

    String month;
    if(Date.today().month()<10)
    {
        month='0'+Date.today().month();
    }else
    {
        month=Date.today().month()+'';
    }
    
    //define the AverageCoaching object list
    List<AverageCoaching__c> tempList=new List<AverageCoaching__c>();
    
    //count SM Average coaching    
    AverageCoaching__c ac=new AverageCoaching__c();
    ac.PeopleNum__c=set_SMRole.size();
    ac.SEOrSEM__c='SM';
    ac.SessionNum__c=SMNum;
    ac.MonthAndYear__c=String.valueof(date.today().year())+month;
    ac.UniqueKey__c=ac.MonthAndYear__c+ac.SEOrSEM__c;
    
    tempList.add(ac);
    
    //acount SEM Average coaching
    ac=new AverageCoaching__c();
    ac.PeopleNum__c=set_SEMRole.size();
    ac.SEOrSEM__c='SEM';
    ac.SessionNum__c=SEMNum;
    ac.MonthAndYear__c=String.valueof(Date.today().year())+month;
    ac.UniqueKey__c=ac.MonthAndYear__c+ac.SEOrSEM__c;
    tempList.add(ac);
    upsert tempList UniqueKey__c;


    /*

    List<Coaching_Session__c>  CoachingList=[select LoggedIn_User__r.UserRoleId from Coaching_Session__c where createddate>=:date.today().toStartOfMonth() and 
    createddate<=:date.today().addMonths(1).toStartOfMonth().addDays(-1)];//汇总当月的session数。

    Map<String,String> rolekeyMap=new Map<String,String>();
    Integer SEPeopleNum=0;
    Integer SEMPeopleNum=0;

    for (OrgsRole_Mapper__c rm:[select Role_Id__c,iPad_Key__c from OrgsRole_Mapper__c where iPad_Key__c='SM' or iPad_Key__c='SEM']) {
        rolekeyMap.put(rm.Role_Id__c,rm.iPad_Key__c);
        if(rm.iPad_Key__c=='SM')
        {
            SEPeopleNum++;
        }else if(rm.iPad_Key__c=='SEM')
        {
            SEMPeopleNum++;
        }
    }

    Integer SENum=0;
    Integer SEMNum=0;
    Set<String> set_SMRole = new Set<String>();
    Set<String> set_SEMRole = new Set<String>();
    for(Coaching_Session__c coaching:CoachingList)
    {
        if(rolekeyMap.get(coaching.LoggedIn_User__r.UserRoleId)=='SM')
        {
            SENum++;    
            set_SMRole.add(coaching.LoggedIn_User__r.UserRoleId);
        }else if(rolekeyMap.get(coaching.LoggedIn_User__r.UserRoleId)=='SEM')
        {
            SEMNum++;
            set_SMRole.add(coaching.LoggedIn_User__r.UserRoleId);
        }
    }

    String month;
    if(Date.today().month()<10)
    {
        month='0'+Date.today().month();
    }else
    {
        month=Date.today().month()+'';
    }
    List<AverageCoaching__c> tempList=new List<AverageCoaching__c>();
    AverageCoaching__c ac=new AverageCoaching__c();
    //ac.PeopleNum__c=SEPeopleNum;
    ac.PeopleNum__c=set_SMRole.size();
    ac.SEOrSEM__c='SM';
    ac.SessionNum__c=SENum;
    ac.MonthAndYear__c=String.valueof(date.today().year())+month;
    ac.UniqueKey__c=ac.MonthAndYear__c+ac.SEOrSEM__c;
    
    tempList.add(ac);
    ac=new AverageCoaching__c();
    //ac.PeopleNum__c=SEMPeopleNum;
    ac.PeopleNum__c=set_SEMRole.size();
    ac.SEOrSEM__c='SEM';
    ac.SessionNum__c=SEMNum;
    ac.MonthAndYear__c=String.valueof(Date.today().year())+month;
    ac.UniqueKey__c=ac.MonthAndYear__c+ac.SEOrSEM__c;
    tempList.add(ac);
    upsert tempList UniqueKey__c;
    */
}
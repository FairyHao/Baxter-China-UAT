/*
Amy
2014/11/4
汇总Session的总数和SE/SEM的总人数，算出平均每月的session数。
*/
trigger AverageCoachingCalculate1 on OrgsRole_Mapper__c(after insert,after Delete) {
List<Coaching_Session__c>  CoachingList=[select LoggedIn_User__r.UserRoleId from Coaching_Session__c where startDate__c>=:date.today().toStartOfMonth() and 
    startDate__c<=:date.today().addMonths(1).toStartOfMonth().addDays(-1)];//汇总当月的session数。
System.debug(date.today().addMonths(1).toStartOfMonth().addDays(-1)+'8************');
System.debug(date.today().toStartOfMonth()+'&&&&&&&&&&');
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
    for(Coaching_Session__c coaching:CoachingList)
    {
        if(rolekeyMap.get(coaching.LoggedIn_User__r.UserRoleId)=='SE')
        {
            SENum++;    
        }else if(rolekeyMap.get(coaching.LoggedIn_User__r.UserRoleId)=='SEM')
        {
            SEMNum++;
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
    ac.PeopleNum__c=SEPeopleNum;
    ac.SEOrSEM__c='SM';
    ac.SessionNum__c=SENum;
    ac.MonthAndYear__c=String.valueof(Date.today().year())+month;
    ac.UniqueKey__c=ac.MonthAndYear__c+ac.SEOrSEM__c;
    tempList.add(ac);
     ac=new AverageCoaching__c();
    ac.PeopleNum__c=SEMPeopleNum;
    ac.SEOrSEM__c='SEM';
    ac.SessionNum__c=SEMNum;
    ac.MonthAndYear__c=String.valueof(Date.today().year())+month;
    ac.UniqueKey__c=ac.MonthAndYear__c+ac.SEOrSEM__c;
    tempList.add(ac);
    upsert tempList UniqueKey__c;


//List<Coaching_Session__c>  CoachingList=[select LoggedIn_User__r.UserRoleId from Coaching_Session__c where createddate>=:date.today().toStartOfMonth() and 
//    createddate<=:date.today().addMonths(1).toStartOfMonth().addDays(-1)];//汇总当月的session数。
//System.debug(date.today().addMonths(1).toStartOfMonth().addDays(-1)+'8************');
//System.debug(date.today().toStartOfMonth()+'&&&&&&&&&&');
//    Map<String,String> rolekeyMap=new Map<String,String>();
//    Integer SEPeopleNum=0;
//    Integer SEMPeopleNum=0;

//    for (OrgsRole_Mapper__c rm:[select Role_Id__c,iPad_Key__c from OrgsRole_Mapper__c where iPad_Key__c='SM' or iPad_Key__c='SEM']) {
//        rolekeyMap.put(rm.Role_Id__c,rm.iPad_Key__c);
//        if(rm.iPad_Key__c=='SM')
//        {
//            SEPeopleNum++;
//        }else if(rm.iPad_Key__c=='SEM')
//        {
//            SEMPeopleNum++;
//        }
//    }

//    Integer SENum=0;
//    Integer SEMNum=0;
//    for(Coaching_Session__c coaching:CoachingList)
//    {
//        if(rolekeyMap.get(coaching.LoggedIn_User__r.UserRoleId)=='SE')
//        {
//            SENum++;    
//        }else if(rolekeyMap.get(coaching.LoggedIn_User__r.UserRoleId)=='SEM')
//        {
//            SEMNum++;
//        }
//    }
//    String month;
//    if(Date.today().month()<10)
//    {
//        month='0'+Date.today().month();
//    }else
//    {
//        month=Date.today().month()+'';
//    }
//    List<AverageCoaching__c> tempList=new List<AverageCoaching__c>();
//    AverageCoaching__c ac=new AverageCoaching__c();
//    ac.PeopleNum__c=SEPeopleNum;
//    ac.SEOrSEM__c='SM';
//    ac.SessionNum__c=SENum;
//    ac.MonthAndYear__c=String.valueof(Date.today().year())+month;
//    ac.UniqueKey__c=ac.MonthAndYear__c+ac.SEOrSEM__c;
//    tempList.add(ac);
//     ac=new AverageCoaching__c();
//    ac.PeopleNum__c=SEMPeopleNum;
//    ac.SEOrSEM__c='SEM';
//    ac.SessionNum__c=SEMNum;
//    ac.MonthAndYear__c=String.valueof(Date.today().year())+month;
//    ac.UniqueKey__c=ac.MonthAndYear__c+ac.SEOrSEM__c;
//    tempList.add(ac);
//    upsert tempList UniqueKey__c;
}
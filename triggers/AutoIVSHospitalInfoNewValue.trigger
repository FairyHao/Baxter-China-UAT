/**
 * Author : Bill
 * date ：2013-8-5
 * 功能：当新建IVT医院信息时,自动取值IVT医院总销量,对象名：IVT_salesAmount的存储值
 * 目前百特季度销量（袋）和  上年度末医院百特总销量(袋)
 * BIll add 2013-8-15
 * 每年只允许有一条IVT医院信息
**/
trigger AutoIVSHospitalInfoNewValue on IVSHospitalInfo__c (before insert, before update) {
    Set<ID> set_ivt = new Set<ID>();
    Set<ID> set_accIds = new Set<ID>();
    Set<String> set_Year = new Set<String>();
    
    for(IVSHospitalInfo__c ivt : trigger.new)
    {
        set_Year.add(ivt.Year__c);
        set_accIds.add(ivt.Account__c);
        set_ivt.add(ivt.Account__c);
    }
    
    List<IVSHospitalInfo__c> list_ivtHos = [SELECT Id, Year__c, Name, Account__c FROM IVSHospitalInfo__c WHERE Account__c IN : set_accIds AND Year__c IN : set_Year];
    Map<String,ID> map_ivt = new Map<String,ID>();
    if(list_ivtHos != null && list_ivtHos.size()>0)
    {
        for(IVSHospitalInfo__c ivtHos : list_ivtHos)
        {
            if(!map_ivt.containsKey(ivtHos.Year__c + ivtHos.Account__c))
            {
                map_ivt.put(ivtHos.Year__c + ivtHos.Account__c,ivtHos.Id);
            }
        }
    }
    if(trigger.isInsert)
    {
        for(IVSHospitalInfo__c ivt : trigger.new)
        {
            if(map_ivt.containsKey(ivt.Year__c + ivt.Account__c) && !system.Test.isRunningTest())
            {
                ivt.addError(ivt.Year__c + '年度已存在IVT医院信息, 不允许再次创建');
            }
        }
    }
    if(trigger.isUpdate)
    {
        for(IVSHospitalInfo__c ivt : trigger.new)
        {
            if(map_ivt.containsKey(ivt.Year__c + ivt.Account__c) && !system.Test.isRunningTest() && trigger.oldMap.get(ivt.Id).Year__c != ivt.Year__c)
            {
                ivt.addError(ivt.Year__c + '年度已存在IVT医院信息, 不允许再次创建');
            }
        }
    }
    
    //上年度末医院百特总销量(袋)
   /* Map<ID,double> ivt_last = new Map<ID,double>();
    //目前百特季度销量（袋）
    Map<ID,double> ivt_now = new Map<ID,double>();
    
    if(set_ivt != null && set_ivt.size()>0)
    {
        //IVT医院总销量销量值
        List<IVT_salesAmount__c> list_sales = [Select i.totalsales__c, i.Q1TotalSales__c, i.Account__c 
                                                From IVT_salesAmount__c i where i.Account__c in : set_ivt 
                                                and time__c = THIS_YEAR];
        if(list_sales != null && list_sales.size()>0)
        {
            for(IVT_salesAmount__c ivt : list_sales)
            {
                ivt_now.put(ivt.Account__c, ivt.Q1TotalSales__c);
                ivt_last.put(ivt.Account__c, ivt.totalsales__c);
            }
        }
    }
    
    if(trigger.isInsert)
    {
        for(IVSHospitalInfo__c ivt : trigger.new)
        {
            //若是销售填写了
            if(ivt.NowQuarterBaxterTotalSalesBags__c == null )
            {
                ivt.NowQuarterBaxterTotalSalesBags__c = ivt_now.get(ivt.Account__c);
            }
            if(ivt.LYHosBaxterTotalSalesBags__c == null)
            {
                ivt.LYHosBaxterTotalSalesBags__c = ivt_last.get(ivt.Account__c);
            }
        }
    } */
}
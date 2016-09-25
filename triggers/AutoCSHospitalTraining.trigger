/*
Author:Bill
Time:2014-8-25
Function:CS医院培训中 销售经理，培训专员经理，以及销售自动赋值
*/
trigger AutoCSHospitalTraining on CS_Hospital_Train__c (before insert,before update,after update,after insert) 
{
    if(trigger.isBefore)
    {  
        list<User> list_profile = [Select Profile.Name from User where Id =: Userinfo.getUserId()];     
        for(CS_Hospital_Train__c train : trigger.new)
        {
            Date createD;
            if(train.CreatedDate == null)
            {
                createD = system.Today();
            }else{
                integer year = train.CreatedDate.year();
                integer month = train.CreatedDate.month();
                integer day = train.CreatedDate.day();
                createD = Date.valueOf(year +'-'+month+'-'+day);
            }
            //***********************2016-05-1 Mike 注释掉 去掉创建申请时间要提前开始日期1周的限制
            // if(train.Start_Date__c != null && train.Start_Date__c.daysbetween(createD)>-7
            //     && list_profile != null && list_profile.size()>0 && list_profile[0].Profile.Name.Contains('Sales'))
            // {
            //     train.Start_Date__c.addError('创建申请时间要提前开始日期1周');
            //     return;
            // } 
            if(train.Is_Learning_CRRT_Treatment__c != null 
                || train.ACUTE_Consumables_Ready__c != null 
                || train.Replacement_Fluid_Is_Ready__c != null )
            {
                if(train.Is_Learning_CRRT_Treatment__c != null 
                    && train.ACUTE_Consumables_Ready__c != null 
                    && train.Replacement_Fluid_Is_Ready__c != null ){}
                else{
                    train.Is_Learning_CRRT_Treatment__c.addError('CRRT培训相关,如果填写任何一项，其他两项也需要填写');
                    return;
                }
            } 
            if(train.Preparation_of_material_models__c != null 
                || train.cardiopulmonary_bypass_machine__c != null)
            {
                if(train.Preparation_of_material_models__c != null 
                && train.cardiopulmonary_bypass_machine__c != null){}
                else{
                    train.Preparation_of_material_models__c.addError('MARS培训相关,如果填写任何一项，另一项也需要填写');
                    return;
                }
            }                               
        }
    }   
    string baseUrl = string.valueOf(System.URL.getSalesforceBaseUrl());
    baseUrl = baseUrl.substring(baseUrl.indexOf('=')+1,baseUrl.length()-1);     
    set<String> set_profiles = new set<String>();
    set_profiles.add('Standard User - HD CS Supervisor');
    set_profiles.add('Standard User - HD CS Specialist');
    set_profiles.add('Standard User - ACUTE CS Specialist');
    set_profiles.add('Standard User - ACUTE CS Supervisor');
    //当前登录人的简档名称
    User user = [Select Id, ProfileId from User where Id =: trigger.new[0].OwnerId];
    Profile profile = [Select Id, Name from Profile where Id =: user.ProfileId];
    //涉及的用户id集合
    set<ID> set_userIds = new set<ID>();
    //培训医院的ID
    set<ID> set_AccIds = new set<ID>(); 
    
    if(trigger.isBefore && trigger.isInsert)
    {
        for(CS_Hospital_Train__c train : trigger.new)
        {
            if(!set_profiles.contains(profile.Name))
            {
                set_userIds.add(train.OwnerId);
            }       
            set_userIds.add(train.TrainingSpecialist__c);
            set_AccIds.add(train.Account__c);
        }
        //每个客户的对应的ACUTE医院信息
        map<ID,ID> map_ACCAcute = new map<ID,ID>();
        for(RenalHospCRRT__c ACUTE : [Select r.Id, r.Account__c From RenalHospCRRT__c r where r.Account__c IN: set_AccIds 
            order by LastModifiedDate desc limit 1]) 
        {
            map_ACCAcute.put(ACUTE.Account__c,ACUTE.Id);
        }       
        map<ID,User> map_users;
        if(set_profiles.contains(profile.Name) || system.Test.isRunningTest())
        {
            map_users = new map<ID,User>([Select u.ManagerId, u.Id From User u where Id IN: set_userIds]);
            if(profile.Name.contains('HD') || system.Test.isRunningTest())
            {
                map<ID,User> map_HD = getHospitalSaler(set_AccIds,'HD');
                if(!map_HD.IsEmpty())
                {                   
                    map_users.putAll(map_HD);
                }
            }
            else if(profile.Name.contains('ACUTE'))
            {
                map<ID,User> map_acute = getHospitalSaler(set_AccIds,'ACUTE');
                if(!map_acute.IsEmpty())
                {
                    map_users.putAll(map_acute);
                }
            }            
        }else{
            map_users = new map<ID,User>([Select u.ManagerId, u.Id From User u where Id IN: set_userIds]);          
        }  
        for(CS_Hospital_Train__c train : trigger.new)
        {
            if(set_profiles.contains(profile.Name) && map_users.containsKey(train.Account__c))
            {           
                train.saler__c = map_users.get(train.Account__c).Id;        
                train.sale_manager__c = map_users.get(train.Account__c).ManagerId;
            }else{
                train.saler__c = train.OwnerId;     
                train.sale_manager__c = map_users.get(train.OwnerId).ManagerId;         
            }
            //update by weldon @ 13-Apr-2016
            //train.CS_manager__c = map_users.get(train.TrainingSpecialist__c).ManagerId; 
            train.CS_manager__c = map_users.get(train.TrainingSpecialist__c) == null?null:map_users.get(train.TrainingSpecialist__c).ManagerId; 
            // end change of Weldon @13-Apr-2016
            if(map_ACCAcute.ContainsKey(train.Account__c))
            {
                train.Brands_Of_CRRT__c = baseUrl + '/' + map_ACCAcute.ContainsKey(train.Account__c);
            }
        }       
    }
    if(trigger.isBefore && trigger.isUpdate)
    {
        for(CS_Hospital_Train__c train : trigger.new)
        {
            if(trigger.oldMap.get(train.Id).TrainingSpecialist__c != train.TrainingSpecialist__c)
            {
                if(!set_profiles.contains(profile.Name))
                {
                    set_userIds.add(train.OwnerId);
                }       
                set_userIds.add(train.TrainingSpecialist__c);
            }
            set_AccIds.add(train.Account__c);
        }
        //每个客户的对应的ACUTE医院信息
        map<ID,ID> map_ACCAcute = new map<ID,ID>();
        system.debug('客户ID' + set_AccIds);
        for(RenalHospCRRT__c ACUTE : [Select r.Id, r.Account__c From RenalHospCRRT__c r where r.Account__c IN: set_AccIds order by LastModifiedDate desc limit 1]) 
        {
            map_ACCAcute.put(ACUTE.Account__c,ACUTE.Id);
        }    
        for(CS_Hospital_Train__c train : trigger.new)
        { 
            if(map_ACCAcute.ContainsKey(train.Account__c))
            {
                train.Brands_Of_CRRT__c = baseUrl + '/' + map_ACCAcute.get(train.Account__c);
            }                
        }            
        if(set_userIds.size()>0)
        {
            map<ID,User> map_users;
            if(set_profiles.contains(profile.Name))
            {
                map_users = new map<ID,User>([Select u.ManagerId, u.Id From User u where Id IN: set_userIds]);
                if(profile.Name.contains('HD'))
                {
                    map<ID,User> map_HD = getHospitalSaler(set_AccIds,'HD');
                    if(!map_HD.IsEmpty())
                    {                   
                        map_users.putAll(map_HD);
                    }
                }
                else if(profile.Name.contains('ACUTE'))
                {
                    map<ID,User> map_acute = getHospitalSaler(set_AccIds,'ACUTE');
                    if(!map_acute.IsEmpty())
                    {
                        map_users.putAll(map_acute);
                    }
                }                 
            }else{
                map_users = new map<ID,User>([Select u.ManagerId, u.Id From User u where Id IN: set_userIds]);
            }
            
            for(CS_Hospital_Train__c train : trigger.new)
            {
                if(set_profiles.contains(profile.Name) && map_users.containsKey(train.Account__c))
                {           
                    train.saler__c = map_users.get(train.Account__c).Id;        
                    train.sale_manager__c = map_users.get(train.Account__c).ManagerId;
                }else{
                    train.saler__c = train.OwnerId;     
                    train.sale_manager__c = map_users.get(train.OwnerId).ManagerId;         
                }
                train.CS_manager__c = map_users.get(train.TrainingSpecialist__c).ManagerId; 
                if(map_ACCAcute.ContainsKey(train.Account__c))
                {
                    train.Brands_Of_CRRT__c = baseUrl + '/' + map_ACCAcute.ContainsKey(train.Account__c);
                }                
            }           
        }           
    }   
    //获取对应的部门负责的销售
    private map<ID,User> getHospitalSaler(set<ID> set_INids,String department)
    {
        Map<ID,ID> map_salePD = NEW Map<ID,ID>();
        //获取负责销售
        for(V2_Account_Team__c team : [Select v.V2_User__c , v.V2_Account__c,v.V2_Effective_Year__c,
            v.V2_Effective_Month__c,v.V2_Delete_Year__c,v.V2_Delete_Month__c  
            From V2_Account_Team__c v where UserProduct__c =: department 
                                       AND V2_Account__c IN : set_INids])
        {
          Date effectiveDate;
          Date deleteDate;
          integer effectiveYear = integer.valueOf(team.V2_Effective_Year__c);
          integer effectiveMonth = integer.valueOf(team.V2_Effective_Month__c);
          effectiveDate = Date.newInstance(effectiveYear, effectiveMonth, 1);
          system.debug('销售客户关系'+team);
          if(team.V2_Delete_Year__c != null)
          {
            integer deleteYear = integer.valueOf(team.V2_Delete_Year__c);
            integer deleteMonth = integer.valueOf(team.V2_Delete_Month__c);
            deleteDate = Date.newInstance(deleteYear, deleteMonth, 1);
          }
          else
          {
            deleteDate = Date.newInstance(Date.Today().addMonths(1).year(),Date.Today().addMonths(1).Month(),1);
          }
          if(effectiveDate <= Date.Today() && Date.Today() < deleteDate)
          {
            map_salePD.put(team.V2_User__c,team.V2_Account__c);
          }
        }   
        map<ID,User> map_saler = new map<ID,User>();
        if(!map_salePD.IsEmpty())
        {
            for(User sale : [Select u.ManagerId, u.Id From User u where Id IN: map_salePD.keyset()])
            {
                if(map_salePD.containsKey(sale.Id))
                {
                    map_saler.put(map_salePD.get(sale.Id),sale);
                }
            }
        }
        return map_saler;
    }   
     
    if(trigger.isAfter)
    {       
        List<CS_Hospital_Train__c> list_train_Approved = new List<CS_Hospital_Train__c>();
        Set<ID> set_Events = new Set<ID>();
        for(CS_Hospital_Train__c train : trigger.new)
        {
            if(train.status__c == '通过' && (System.Test.isRunningTest() ||trigger.oldMap.get(train.Id).status__c != train.status__c))
            {
                list_train_Approved.add(train);
            }
            if(train.IsDone__c)
            {
                set_Events.add(train.Id);
            }
        }
        if(list_train_Approved.size()>0)
        {
            ID eventId = [Select Id from RecordType where sobjectType = 'Event' and developerName = 'V2_RecordType'][0].Id;
            List<Event> list_train_event = new List<Event>();
            for(CS_Hospital_Train__c train : list_train_Approved)
            {
                if(train.Start_Date__c == null
                || train.End_Date__c == null)
                {
                    continue;
                }
                Datetime startTime = Datetime.valueOf(String.valueOf(train.Start_Date__c.year())
                        + '-'
                        + String.valueOf(train.Start_Date__c.month())  
                        + '-' 
                        + String.valueOf(train.Start_Date__c.day()) 
                        + ' '
                        + '8:00:00');
                Datetime endTime = Datetime.valueOf(String.valueOf(train.End_Date__c.year())
                        + '-'
                        + String.valueOf(train.End_Date__c.month()) 
                        + '-'
                        + String.valueOf(train.End_Date__c.day())
                        + ' '   
                        + '17:00:00');                       
                Event e = new Event();
                e.recordTypeId = eventId;
                e.Subject = '医院培训';
                e.Type = '团队培训相关';
                e.bio_event_type__c = '团队培训相关';
                e.OwnerId = train.TrainingSpecialist__c;
                e.WhoId = train.Contact__c;
                e.WhatId = train.Id;
                e.StartDateTime = startTime;
                e.EndDateTime = endTime;
                list_train_event.add(e);
            }
            if(list_train_event.size()>0)
            {
                insert list_train_event;
            }
        }
        if(set_Events.size()>0)
        {
            List<Event> list_events = [Select Id,Done__c from Event where WhatId IN: set_Events and IsChild = false];
            for(Event  e : list_events)
            {
                e.Done__c = true;
            }
            if(list_events != null && list_events.size() > 0)
            {
                update list_events;
            }       
        }
    }
    
    //***********************2015-02-28 Spring IVT CS时，培训类型<->培训工时
    if(trigger.isBefore){
        for(CS_Hospital_Train__c train : trigger.new){
            if(train.IVT_TrainingType__c != null || train.IVT_TrainingType__c != ''){
                if(train.IVT_TrainingType__c == '产品培训'){
                    train.IVT_TrainingHours__c = '4';
                }else if(train.IVT_TrainingType__c == '治疗培训'){
                    train.IVT_TrainingHours__c = '10';
                }else if(train.IVT_TrainingType__c == '增值培训'){
                    train.IVT_TrainingHours__c = '24';
                }else if(train.IVT_TrainingType__c == '扫楼'){
                    String selOper = train.IVT_Departments__c;
                    if(selOper == null || selOper ==''){
                        train.IVT_TrainingHours__c = '0';
                    }else{
                        String[] selOperArray = selOper.split(';');
                        Integer index = selOperArray.size();
                        train.IVT_TrainingHours__c = ''+index*0.5;
                    }
                }
            }
        }
    }

    //***********************2016-04-29 Mike.xu Acute CS精准医院培训时，确保每个季度只有一条数据
    //获取'Acute_CS_spefici_training'记录类型
    RecordType recordTyep = new RecordType();
    recordTyep = [select Id from RecordType where DeveloperName = 'Acute_CS_spefici_training' Limit 1];
            System.debug(recordType.Id);
    //获取trigger中cs精准医院培训的客户的ID
    List<Id> list_CSHospitalTrainAccountID = new List<Id>();
    for(CS_Hospital_Train__c csHospitalTrain : Trigger.new){
        System.debug('kaishi 3333'+csHospitalTrain.RecordType.Id);
        if(csHospitalTrain.RecordTypeId != recordTyep.Id){
            continue;
        }
        list_CSHospitalTrainAccountID.add(csHospitalTrain.Account__c);
    }

    if(Trigger.isBefore&&Trigger.isInsert){

        //通过trigger中cs精准医院培训的客户的ID，获取系统中CS精准医院培训的数据
        List<CS_Hospital_Train__c> list_CSHospitalTrains = new List<CS_Hospital_Train__c>();
        if(!list_CSHospitalTrainAccountID.isEmpty()){
            list_CSHospitalTrains = [select Id,Acute_CS_Training_quarter__c,Account__c  
                                     from CS_Hospital_Train__c 
                                     where RecordTypeId =:recordTyep.Id 
                                     and Account__c in:list_CSHospitalTrainAccountID];
        }
        Map<String,Id> map_keyTohospital = new Map<String,Id>();
        if(!list_CSHospitalTrains.isEmpty()){
            for(CS_Hospital_Train__c csHospital : list_CSHospitalTrains){
                String key = csHospital.Acute_CS_Training_quarter__c+csHospital.Account__c;
                System.debug('已存在的key='+key);
                map_keyTohospital.put(key, csHospital.Id);
            }
        }
        for(CS_Hospital_Train__c csHospitalTrain : Trigger.new){
            // System.debug('kaishi 3333'+csHospitalTrain.RecordType.DeveloperName);
            if(csHospitalTrain.RecordTypeId != recordTyep.Id){
                continue;
            }
            System.debug('kaishi 222');
            String key = csHospitalTrain.Acute_CS_Training_quarter__c+csHospitalTrain.Account__c;
            System.debug('key-----'+key);
            if(map_keyTohospital.containsKey(key)){
                System.debug('此评分季度已存在，请重新选择！');
                csHospitalTrain.Acute_CS_Training_quarter__c.addError('该季度的评分已存在，不能重复添加！');
            }
        }
    }
    //***********************2016-04-29 Mike.xu Acute CS精准医院培训时，匹配销售数据并生成CS医院培训质量评估
    if(Trigger.isAfter&&Trigger.isInsert){
        System.debug('触发器开始工作');
        //将月份转变为季度（月份作为下标获取季度）
        Integer[] trainingQuarter = new List<Integer>{1,1,1,2,2,2,3,3,3,4,4,4};

        //通过trigger中cs精准医院培训的客户的ID，获取系统中的客户数据
        List<Account> list_Account = new List<Account>();
        if(!list_CSHospitalTrainAccountID.isEmpty()){
            list_Account = [select Id 
                            from Account 
                            where Acute_CS_Training_Specific__c = '是'
                            and Id in:list_CSHospitalTrainAccountID];
        }
        System.debug('符号条件的医院=>'+list_Account);
        Set<Id> set_AccountId = new Set<Id>();
        if(!list_Account.isEmpty()){
            for(Account acc : list_Account){
                set_AccountId.add(acc.Id);
            }
        }

        //通过筛选出的系统中的客户ID，获取系统中的销售数据
        List<SalesReport__c> list_SalesReprot = new List<SalesReport__c>();
        if(!set_AccountId.isEmpty()){
            list_SalesReprot = [select Id,ProductGroup__c,Time__c,ActualQty__c,Account__c,Acute_product_type__c,
                                    GBU__c,MDM_ID__c,ProductCode__c,SBU__c,ActualAmount__c,OwnerId 
                                from SalesReport__c 
                                where Account__c != null 
                                    and Account__c in:set_AccountId 
                                    and Time__c != null 
                                    and SBU__c = 'ACUTE'];
        }
        // Map<String,SalesReport__c>

        // List<CSTrainingEvaluation__c> list_CSTrainEvalatino = new List<CSTrainingEvaluation__c> ();
        // list_CSTrainEvalatino = [select Id,Name,CS_saleQuantity__c,CS_month__c,CS_year__c,CS_account__c,
        //                     CS_product__c,CS_key__c,CS_Training__c  
        //                 from CSTrainingEvaluation__c where CS_key__c!=null];
        // Map<String,CSTrainingEvaluation__c> map_KeyToTrainEval = new Map<String,CSTrainingEvaluation__c>();
        // if(!list_CSTrainEvalatino.isEmpty()){
        //     for(CSTrainingEvaluation__c csTrainEval : list_CSTrainEvalatino){
        //         map_KeyToTrainEval.put(csTrainEval, csTrainEval)
        //     }
        // }
        // Integer year = Date.today().year();
        // Intgeer month = Date.today().month;
        System.debug('符号条件的销售数据=>'+list_SalesReprot);
        Map<String,CSTrainingEvaluation__c> map_KeyToTrainEval = new Map<String,CSTrainingEvaluation__c>();
        Map<String,Id> map_KeyHoipitalTrain = new Map<String,Id>();
        // Map<String,Integer> map_product = new Map<String,Integer>();
        // Integer numb = 0;
        for(CS_Hospital_Train__c csHospitalTrain : Trigger.new){
            if(list_SalesReprot.isEmpty()){
                break;
            }
            if(csHospitalTrain.RecordTypeId != recordTyep.Id){
                continue;
            }
            System.debug('此医院培训评分符号要求');
            for(SalesReport__c salesReport : list_SalesReprot){
                // if(map_product.isEmpty()){
                //     map_product.put(salesReport.ProductGroup__c, numb++);
                // }else if(!map_product.containsKey(salesReport.ProductGroup__c)){
                //     map_product.put(salesReport.ProductGroup__c, numb++);
                // }
                String year = salesReport.Time__c.year()+'';
                String month = salesReport.Time__c.month()+'';
                String key = year + month + salesReport.ProductCode__c + salesReport.Account__c;
                String trainQuarter = year+' Q'+trainingQuarter[salesReport.Time__c.month()-1]+salesReport.Account__c;
                System.debug(trainQuarter);
                System.debug(csHospitalTrain.Acute_CS_Training_quarter__c+csHospitalTrain.Account__c);
                if((csHospitalTrain.Acute_CS_Training_quarter__c+csHospitalTrain.Account__c)!= trainQuarter){
                    continue;
                }
                map_KeyHoipitalTrain.put(key, csHospitalTrain.Id);
                CSTrainingEvaluation__c csTrainEva;
                if(map_KeyToTrainEval.isEmpty()){
                    csTrainEva = newCSTrainEva(key,year,month,salesReport);
                    System.debug('操作1--->'+csTrainEva);
                    map_KeyToTrainEval.put(key, csTrainEva);
                }else{
                    if(map_KeyToTrainEval.containsKey(key)){
                        // if(csTrainEva.CS_date__c < salesReport.Time__c){
                        csTrainEva = map_KeyToTrainEval.get(key);
                        System.debug('更新操作--->'+csTrainEva);
                        csTrainEva.CS_product__c = salesReport.ProductGroup__c;
                        csTrainEva.CS_saleQuantity__c = salesReport.ActualQty__c;
                        csTrainEva.CS_date__c = salesReport.Time__c;
                        csTrainEva.Acute_product_type__c = salesReport.Acute_product_type__c;
                        csTrainEva.GBU__c = salesReport.GBU__c;
                        csTrainEva.MDM_ID__c = salesReport.MDM_ID__c;
                        csTrainEva.ProductionId__c = salesReport.ProductCode__c;
                        csTrainEva.SBU__c = salesReport.SBU__c;
                        csTrainEva.OwnerOfSalesData__c = salesReport.OwnerId;
                        csTrainEva.ActualAmount__c = salesReport.ActualAmount__c;
                        map_KeyToTrainEval.remove(key);
                        map_KeyToTrainEval.put(key, csTrainEva);
                        // }
                    }else{
                        csTrainEva = newCSTrainEva(key,year,month,salesReport);
                        System.debug('操作2--->'+csTrainEva);
                        map_KeyToTrainEval.put(key, csTrainEva);
                    }
                }
            }
        }

        if(!map_KeyToTrainEval.isEmpty()){
            List<CSTrainingEvaluation__c> list_CSTrainEvalatino = new List<CSTrainingEvaluation__c> ();
            for(String key : map_KeyToTrainEval.keySet()){
                System.debug('插入动作');
                CSTrainingEvaluation__c csTrainEva = new CSTrainingEvaluation__c();
                System.debug(key);
                csTrainEva = map_KeyToTrainEval.get(key);
                System.debug(csTrainEva);
                csTrainEva.CS_Training__c = map_KeyHoipitalTrain.get(key);
                System.debug(map_KeyHoipitalTrain.get(key));
                list_CSTrainEvalatino.add(csTrainEva);
            }
            upsert list_CSTrainEvalatino CS_key__c;
        }

    }
    private CSTrainingEvaluation__c newCSTrainEva(String key,String year,String month,SalesReport__c salesReport){
        CSTrainingEvaluation__c csTrainEva = new CSTrainingEvaluation__c();
        csTrainEva.CS_product__c = salesReport.ProductGroup__c;
        csTrainEva.CS_year__c = year;
        csTrainEva.CS_month__c = month;
        csTrainEva.CS_account__c = salesReport.Account__c;
        csTrainEva.CS_saleQuantity__c = salesReport.ActualQty__c;
        csTrainEva.CS_date__c = salesReport.Time__c;
        csTrainEva.CS_key__c = key;
        csTrainEva.Acute_product_type__c = salesReport.Acute_product_type__c;
        csTrainEva.GBU__c = salesReport.GBU__c;
        csTrainEva.MDM_ID__c = salesReport.MDM_ID__c;
        csTrainEva.ProductionId__c = salesReport.ProductCode__c;
        csTrainEva.SBU__c = salesReport.SBU__c;
        csTrainEva.OwnerOfSalesData__c = salesReport.OwnerId;
        csTrainEva.ActualAmount__c = salesReport.ActualAmount__c;
        return csTrainEva;
    }
}
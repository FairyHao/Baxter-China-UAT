/******************************************************
 *Spring
 *2015-5-21
 *统计客户拜访情况，每个BU每个月只会产生一条记录
 ******************************************************/
public class AcuteReportCount implements Database.Batchable<sObject> {
    //key=>saccountId,key=>alesId,部门
    Map<String,Map<String,String>> salesByAccount = new Map<String,Map<String,String>>();
    Set<String> accountIds = new  Set<String>();
    DateTime CheckStartDateTime ;
    DateTime CheckEndDateTime ;
    Integer IntYear;
    Integer IntMonth;

    public AcuteReportCount(Integer y,Integer m) {
    	IntYear = y;
    	IntMonth = m;

    	CheckStartDateTime = datetime.newInstance(IntYear, IntMonth, 1, 0, 0, 0) ;
        if(IntMonth == 12){
        	CheckEndDateTime = datetime.newInstance(IntYear+1, 1, 1, 0, 0, 0) ;
        }else{
        	CheckEndDateTime = datetime.newInstance(IntYear, IntMonth+1, 1, 0, 0, 0) ;
        }

        //查询ACUTE负责的医院
        Set<String> deptSet = new Set<String>();
        deptSet.add('ACUTE');
        deptSet.add('PD');
        deptSet.add('HD');
        deptSet.add('IVT');
        deptSet.add('SP');
        deptSet.add('IS');
        accountIds = getHospitalSaler(deptSet);
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
    	System.debug('accountIds:'+accountIds.size());
        //System.debug('salesByAccount:'+salesByAccount);
        return Database.getQueryLocator([select id,MID__c,Acute_Level__c from Account where id =:accountIds]);
    }
    
    public void execute(Database.BatchableContext BC, list<Sobject> scope) {
        Set<String> accIds = new Set<String>();
        for(Sobject obj : scope){
            Account acc = (Account)obj;
            accIds.add(acc.id);
        }
        //客户所有的联系人
        Map<String,Set<String>> contactByAccount = new Map<String,Set<String>>();
        for(Contact con: [select id,AccountId from Contact where AccountId IN : accIds]){
            if(!contactByAccount.containsKey(con.AccountId)){
                contactByAccount.put(con.AccountId,new Set<String>());
            }
            Set<String> conIds_temp = contactByAccount.get(con.AccountId);
            conIds_temp.add(con.id);
            contactByAccount.put(con.AccountId,conIds_temp);
        }
        //客户所有的业务机会
        Map<String,Set<String>> oppByAccount = new Map<String,Set<String>>();
        for(Opportunity opp : [select id,AccountId from Opportunity where AccountId IN :accIds]){
            if(!oppByAccount.containsKey(opp.AccountId)){
                oppByAccount.put(opp.AccountId,new Set<String>());
            }
            Set<String> oppId_temp = oppByAccount.get(opp.AccountId);
            oppId_temp.add(opp.Id);
            oppByAccount.put(opp.AccountId,oppId_temp);
        }
        //每个BU 的拜访次数
    	Map<String,Integer> countMap = new Map<String,Integer>();
    	List<AccountVisitLog__c> logList = new List<AccountVisitLog__c>();

        Set<String> whoId = new Set<String>();
        Set<String> whatId = new Set<String>();
    	for(Sobject obj : scope){
    		Account acc = (Account)obj;
            whoId = contactByAccount.get(acc.id) == null ? new Set<String>() : contactByAccount.get(acc.id);
            whatId = oppByAccount.get(acc.id) == null ? new Set<String>() : oppByAccount.get(acc.id);
            
    		Map<String,String> BuByAccount = salesByAccount.get(acc.id);
    		Set<String> ow = BuByAccount.keySet();
    		for(Event e : [Select OwnerId,WhoId,WhatId From Event Where IsChild = false And RecordType.DeveloperName = 'V2_Event' And Done__c = true And V2_IsExpire__c = false And StartDateTime >: CheckStartDateTime And StartDateTime <: CheckEndDateTime And OwnerId =: ow]){
				if(!whoId.contains(e.WhoId) && !whatId.contains(e.WhatId)){
                    continue;
                }
                if(countMap.containsKey(e.OwnerId)){
					countMap.put(e.OwnerId,(countMap.get(e.OwnerId)+1));
				}else{
					countMap.put(e.OwnerId,1);
				}
    		}

    		for(String str : ow){
    			AccountVisitLog__c entity = new AccountVisitLog__c();
    			entity.SBU__c = BuByAccount.get(str);
    			entity.Total__c = countMap.get(str) == null ? 0:countMap.get(str);
    			//entity.Level__c = acc.Acute_Level__c;
    			entity.AccountId__c = acc.id;
    			entity.date__c = Date.newInstance(IntYear,IntMonth,1); 
    			//entity.MID__c = acc.MID__c;
                entity.OwnerId = str;
    			entity.uniqueKey__c = acc.id+''+entity.SBU__c+String.valueOf(IntYear)+(IntMonth<10?('0'+String.valueOf(IntMonth)) : String.valueOf(IntMonth));
    			logList.add(entity);
    		}

    		countMap.clear();
            whoId.clear();
            whatId.clear();

    	}
        //Integer i = 0;
    	if(logList.size()>0){
            //try{
                upsert logList uniqueKey__c;
            //}catch(Exception e){
               // i++;
                //System.debug(e.getMessage());
            //}
            //System.debug('失败:'+i);
        } 
    
    }

    public void finish(Database.BatchableContext BC) {}


    //获取销售负责的医院
    private Set<String> getHospitalSaler(Set<String> deptSet)
    {
        //2016-6-7 排除不启用的用户
        Set<String> activityUserSet = new Set<String>();
        for(User u : [select id from User where IsActive = true]){
            activityUserSet.add(u.Id);
        }

        Set<String> accSet = new Set<String>();
        //获取负责销售
        for(V2_Account_Team__c team : [Select v.V2_User__c , v.V2_Account__c,v.V2_Effective_Year__c,
            v.V2_Effective_Month__c,v.V2_Delete_Year__c,v.V2_Delete_Month__c,v.UserProduct__c  
            From V2_Account_Team__c v where UserProduct__c  IN : deptSet])
        {
          Date effectiveDate;
          Date deleteDate;
          integer effectiveYear = integer.valueOf(team.V2_Effective_Year__c);
          integer effectiveMonth = integer.valueOf(team.V2_Effective_Month__c);
          effectiveDate = Date.newInstance(effectiveYear, effectiveMonth, 1);
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
            //如果用户不是启用则跳过，否则会引起分配人Exception
            if(!activityUserSet.contains(team.V2_User__c)){
                continue;
            }
          	//部门负责的医院
            accSet.add(team.V2_Account__c);
            //分类出salesByAccount
            if(!salesByAccount.containsKey(team.V2_Account__c)){
            	//插入
            	salesByAccount.put(team.V2_Account__c,new Map<String,String>());
            }
            Map<String,String> BUBAccountMap = salesByAccount.get(team.V2_Account__c);
            BUBAccountMap.put(team.V2_User__c,team.UserProduct__c);
            salesByAccount.put(team.V2_Account__c,BUBAccountMap);
          }
        }   
        return accSet;
    } 
}
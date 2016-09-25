/*************************************************
 *Spring 20141202
 *CS医院培训前后 医院销量趋势
 *************************************************/
global class AcuteAndHDSalesBatch implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC){
		//返回 ACUTE & HD 部门 审核 通过 且培训时间距当前1年的客户
		Date day = System.today().toStartOfMonth().addMonths(-12);
    	return Database.getQueryLocator([select Account__c from CS_Hospital_Train__c where status__c = '通过' and End_Date__c !=null and End_Date__c >=:day  order by End_Date__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	//客户id,结束时间
    	Map<Id,Date> map_account = new Map<Id,Date>();
    	//客户id
    	Set<Id> set_account = new Set<Id>();
    	//更新的
    	List<SalesReport__c>  list_up_sales =new List<SalesReport__c>();
    	//清除的
    	List<SalesReport__c>  list_clear_sales =new List<SalesReport__c>();
    	
    	for(sObject obj : scope){
    		CS_Hospital_Train__c cs=(CS_Hospital_Train__c)obj;
    		set_account.add(cs.Account__c);
    	}
    	//查找每个客户最后一次培训的CS培训记录
    	for(Account obj : [Select (Select End_Date__c From CS__r where status__c = '通过' and End_Date__c !=null  order by End_Date__c desc limit 1) From Account  where id IN: set_account]){
    		CS_Hospital_Train__c cs=obj.CS__r;
    		map_account.put(obj.id,cs.End_Date__c);
    	}
    	//销售数据
    	for(SalesReport__c c : [Select Id,Time__c,CSTraining__c,Account__c From SalesReport__c where  (SBU__c='ACUTE' or SBU__c='HD') and Account__c IN: set_account ]){
    		Date createDate = c.Time__c;
			if(createDate == null){
				continue;
			}
			Date trainDate = map_account.get(c.Account__c);
			Integer sub = trainDate.monthsBetween(createDate);
			//在范围之外的
			if(sub<-2 || sub >6){
				if(c.CSTraining__c != null){
					c.CSTraining__c = null;
					list_clear_sales.add(c);
				}
			}
			//在范围之内的
			if(sub == -2){
				if(c.CSTraining__c != '前2月'){
					c.CSTraining__c = '前2月';
					list_up_sales.add(c);
				}
			}else if(sub == -1){
				if(c.CSTraining__c != '前1月'){
					c.CSTraining__c = '前1月';
					list_up_sales.add(c);
				}
			}else if(sub == 0){
				if(c.CSTraining__c != '当前月'){
					c.CSTraining__c = '当前月';
					list_up_sales.add(c);
				}
			}else if(sub == 1){
				if(c.CSTraining__c != '后1月'){
					c.CSTraining__c = '后1月';
					list_up_sales.add(c);
				}
			}else if(sub == 2){
				if(c.CSTraining__c != '后2月'){
					c.CSTraining__c = '后2月';
					list_up_sales.add(c);
				}
			}else if(sub == 3){
				if(c.CSTraining__c != '后3月'){
					c.CSTraining__c = '后3月';
					list_up_sales.add(c);
				}
			}else if(sub == 4){
				if(c.CSTraining__c != '后4月'){
					c.CSTraining__c = '后4月';
					list_up_sales.add(c);
				}
			}else if(sub == 5){
				if(c.CSTraining__c != '后5月'){
					c.CSTraining__c = '后5月';
					list_up_sales.add(c);
				}
			}else if(sub == 6){
				if(c.CSTraining__c != '后6月'){
					c.CSTraining__c = '后6月';
					list_up_sales.add(c);
				}
			}
		}
    	upsert list_clear_sales;
    	upsert list_up_sales;
    }
    
    global void finish(Database.BatchableContext BC){
    	
    }
}
/*************************************************
 *Spring 2015-5-7
 *acute上客户记录上客户等级根据ACUTE医院信息上的等级来
 *取最新的ACUTE等级，同时，勾选为最新，消除旧的。
 **************************************************/
global class AcuteAccountLevelBatch implements Database.Batchable<sObject> {
    public String query;

    
    global AcuteAccountLevelBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	Set<String> accoutIdSet = getHospitalSaler();
        return Database.getQueryLocator([select Acute_Level__c from Account where id IN: accoutIdSet]);
    }
    
    //有分析要控制dml条数，为了取最新的acute机器
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
    	List<RenalHospCRRT__c> finalResultCRRTList = new List<RenalHospCRRT__c>();
    	List<Account> finalResultAccountList = new List<Account>();
    	for(Sobject obj :scope){
    		Account acc = (Account)obj;
    		//这里的集合应该都是按照 年份，季度，创建时间从大到小
    		List<RenalHospCRRT__c> temp = [select Acute_Level__c,Acute_IsNew__c,CreatedDate from RenalHospCRRT__c where Account__c =:acc.id  order by YearNum__c DESC,QuarterNum__c DESC, CreatedDate DESC];
    		//勾选上的记录（正常情况只有2条）
    		List<RenalHospCRRT__c> tempHaveNewList = new List<RenalHospCRRT__c>();
    		for(RenalHospCRRT__c o : temp){
    			if(o.Acute_IsNew__c){
    				tempHaveNewList.add(o);
    			}
    		}
    		//如果从来都没有取最新的一条件记录
    		if(tempHaveNewList.size() ==0 && temp.size() >0){
    			RenalHospCRRT__c crrt = temp.get(0);
    			crrt.Acute_IsNew__c = true;
    			finalResultCRRTList.add(crrt);
    			acc.Acute_Level__c = crrt.Acute_Level__c;
    			finalResultAccountList.add(acc);
    		}else if(tempHaveNewList.size() >0){
    			for(Integer i = 0;i<tempHaveNewList.size();i++){
    				if(i ==0){
    					//是不是最新一条勾上了，不是则取第一条
    					if(tempHaveNewList.get(0).CreatedDate != temp.get(0).CreatedDate){
    						tempHaveNewList.get(0).Acute_IsNew__c = false;
    						finalResultCRRTList.add(tempHaveNewList.get(0));
    						temp.get(0).Acute_IsNew__c = true;
    						finalResultCRRTList.add(temp.get(0));
    						acc.Acute_Level__c = temp.get(0).Acute_Level__c;
    						finalResultAccountList.add(acc);
    					}else{
    						acc.Acute_Level__c = tempHaveNewList.get(0).Acute_Level__c;
    						finalResultAccountList.add(acc);
    					}
    				}else{
    					//取消其它记录上的勾
    					tempHaveNewList.get(i).Acute_IsNew__c = false;
    					finalResultCRRTList.add(tempHaveNewList.get(i));
    				}
    			}
    		}
    	}


    	update finalResultAccountList;
    	update finalResultCRRTList;
    }

    global void finish(Database.BatchableContext BC) {}


    /**
     *获得IVT在当月销售负责的医院
     */
     private Set<String> getHospitalSaler()
    {
        Set<String> accuntByIVTSet = new Set<String>();
        //获取负责销售
        for(V2_Account_Team__c team : [Select v.V2_User__c , v.V2_Account__c,v.V2_Effective_Year__c,
            v.V2_Effective_Month__c,v.V2_Delete_Year__c,v.V2_Delete_Month__c  
            From V2_Account_Team__c v where UserProduct__c ='ACUTE' AND V2_Effective_Year__c != null
            AND V2_Effective_Month__c != null])
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
            accuntByIVTSet.add(team.V2_Account__c);
          }
        }   
        return accuntByIVTSet;
    }
}
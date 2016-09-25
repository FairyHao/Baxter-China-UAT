/**
 * Author:Sunny
 * 创建数据时，
 * 1.设置owner
 * 2.自动赋值唯一键
 **/
trigger BQ_AutoSKUNumber on BQ_StatisticalTable__c(before insert , before update) {
	ID SalesDataRecordTypeId = Schema.SObjectType.BQ_StatisticalTable__c.getRecordTypeInfosByName().get('销售数据').getRecordTypeId();
	List<ID> list_accId = new List<ID>();
	for(BQ_StatisticalTable__c st : trigger.new){
		//当记录类型为销售数据、医院不为空时，需要设置owner为BQ销售
		if(st.RecordTypeId == SalesDataRecordTypeId && st.BQ_Hospital__c != null){
			list_accId.add(st.BQ_Hospital__c);
		}
	}
	if(list_accId.size() > 0){
		map<ID,User> map_AccBQSales = BQ_Utility.getCurrentBQSalesByAccountId(list_accId, 'Nutrition');
		Map<Id,Account > map_acc = new Map<Id,Account>([Select id from Account where id in: list_accId]);
		for(BQ_StatisticalTable__c st : trigger.new){
			if(st.RecordTypeId == SalesDataRecordTypeId && st.BQ_Hospital__c != null){
				if(map_AccBQSales.containsKey(st.BQ_Hospital__c)){
					st.OwnerId = map_AccBQSales.get(st.BQ_Hospital__c).id;
				}

				//当日期、产品也不为空时，且唯一键为空时，需要设置唯一键。
				if(st.BQ_SKUNumber__c ==null && st.BQ_Date__c != null && st.BQ_ProductDesId__c != null && st.BQ_SourceFrom__c != null){
					for(ID Accid : map_acc.keySet()){
						if(Accid == st.BQ_Hospital__c){
							st.BQ_SKUNumber__c = Accid + st.BQ_SourceFrom__c + st.BQ_ProductDesId__c + st.BQ_Date__c.year() +''+ (st.BQ_Date__c.month()>9?''+st.BQ_Date__c.month():'0'+st.BQ_Date__c.month());
						}
					}
					
				}
			}
		}
	}
}
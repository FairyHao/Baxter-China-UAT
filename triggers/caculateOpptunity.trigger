/*
Author:Dean
Date:2015-11-27
Function:将业务机会数和业务机会完成数累计汇总到CKDReport__c对象
 */

trigger caculateOpptunity on Opportunity (after insert,after update) {
	Integer ClinOleicNum = 0;
	Integer ClinomelNum = 0;
	Integer CernevitNum = 0;
	Integer SevoNum = 0;
	Integer SupNum = 0;
	Integer Num = 0;
	List<CKDReport__c> updateList{set;get;}
	//List<CKDReport__c> insertList{set;get;}
	//List<CKDReport__c> newCKDList{set;get;}

	// if(trigger.isinsert)
	// {
	// 	insertList = new List<CKDReport__c>();
	// 	newCKDList = new List<CKDReport__c>();
	// 	for(Opportunity opp:trigger.new)
	// 	{
	// 		RecordType rt = [select id,DeveloperName from RecordType where id =:opp.RecordTypeId limit 1];
	// 		if(rt == null)
	// 		{
	// 			continue;
	// 		}

	// 		if(rt.DeveloperName != 'cross_opportunity')
	// 		{
	// 			continue;
	// 		}

	// 			if(opp.ProductType__c == 'ClinOleic')
	// 			{
	// 				ClinOleicNum++;
	// 				Num = ClinOleicNum;
	// 			}
	// 			if(opp.ProductType__c == 'Clinomel')
	// 			{
	// 				ClinomelNum++;
	// 				Num = ClinomelNum;
	// 			}
	// 			if(opp.ProductType__c == 'Cernevit')
	// 			{
	// 				CernevitNum++;
	// 				Num = CernevitNum;
	// 			}
	// 			if(opp.ProductType__c == 'Sevo' )
	// 			{
	// 				SevoNum++;
	// 				Num = SevoNum;
	// 			}
	// 			if(opp.ProductType__c == 'Des' )
	// 			{
	// 				SupNum++;
	// 				Num = SupNum;
	// 			}

	// 		String key = String.valueOf(opp.AccountId) + String.valueOf(opp.ProductType__c) + String.valueOf(opp.CreatedDate.year()) + String.valueOf(opp.CreatedDate.Month());
		
	// 		List<CKDReport__c> tempList = [select id,opptunityQuantity__c,OpptunityCompleted__c from CKDReport__c where key__c =:key];
	// 		if(tempList.size() == 0)
	// 		{
	// 			CKDReport__c ckd = new  CKDReport__c();
	// 			ckd.key__c = key;
	// 			ckd.opptunityQuantity__c = 1;
	// 			newCKDList.add(ckd);
	// 			continue;
	// 		}

	// 		CKDReport__c temp = tempList[0];
	// 		if(temp.opptunityQuantity__c == null)
	// 		{
	// 			temp.opptunityQuantity__c = 0;
	// 		}
	// 		temp.opptunityQuantity__c += Num;
	// 		insertList.add(temp);
	// 		}
	// 		update insertList;
	// 		insert newCKDList;
	// }
	  

	if(trigger.isUpdate)
	{
		updateList = new List<CKDReport__c>();
		for(Opportunity opp:trigger.new)
		{
			RecordType rt = [select id,DeveloperName from RecordType where id =:opp.RecordTypeId limit 1];
			if(rt == null)
			{
				continue;
			}
			if(rt.DeveloperName != 'cross_opportunity' || opp.StageName !='药品采购（缔结)' || trigger.oldMap.get(opp.Id).StageName == '药品采购（缔结)' )
			{
				continue;
			}
			if(opp.ProductType__c == 'ClinOleic')
			{
				ClinOleicNum++;
				Num = ClinOleicNum;
			}
			if(opp.ProductType__c == 'Clinomel')
			{
				ClinomelNum++;
				Num = ClinomelNum;
			}
			if(opp.ProductType__c == 'Cernevit')
			{
				CernevitNum++;
				Num = CernevitNum;
			}
			if(opp.ProductType__c == 'Sevo')
			{
				SevoNum++;
				Num = SevoNum;
			}
			if(opp.ProductType__c == 'Des')
			{
				SupNum++;
				Num = SupNum;
			}

			String key = String.valueOf(opp.AccountId) + String.valueOf(opp.ProductType__c) + String.valueOf(opp.CreatedDate.year()) + String.valueOf(opp.CreatedDate.Month());
		
			List<CKDReport__c> tempList = [select id,opptunityQuantity__c,OpptunityCompleted__c from CKDReport__c where key__c =:key limit 1];
			if(tempList.size() == 0)
			{
				continue;
			}
			CKDReport__c temp = tempList[0];
			if(temp.OpptunityCompleted__c == null)
			{
				temp.OpptunityCompleted__c = 0;
			}	
			temp.OpptunityCompleted__c += Num;
			updateList.add(temp);

		}
		update updateList;
	}
}
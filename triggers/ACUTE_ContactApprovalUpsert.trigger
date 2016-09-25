/*
 *Author：Bill
 *Created on：2014-6-30
 *Description: 
 *ACUTE部门的联系人申请转化为联系人
*/
trigger ACUTE_ContactApprovalUpsert on Contact_Mod__c (before update, after update) 
{
	if(trigger.isAfter)
	{
		ID ACUTEId = [Select Id from RecordType where sobjectType='Contact' and DeveloperName='ACUTE'][0].id;
	    //联系人修改申请
	    Map<ID,Contact_Mod__c> map_conMod = new Map<ID,Contact_Mod__c>();
	    //新增联系人
	    List<Contact> list_Cons = new List<Contact>();
	    for(Contact_Mod__c newcm:trigger.new)
	    {
	        if(newcm.TW_DevName__c!='acute_Insert' && newcm.TW_DevName__c!='acute_Update')
	        {
	            continue;
	        }
	        if(newcm.Status__c != trigger.oldMap.get(newcm.id).Status__c && newcm.Status__c == '通过')
	        {
	            if(newcm.Name__c != null)
	            {
	                map_conMod.put(newcm.Name__c, newcm);
	            }else{
	               Contact con = new Contact();
			       con.LastName = newcm.NewContact__c;
			       con.ACUTE_Department__c = newcm.ACUTE_Department__c;
				   con.ContactType__c = newcm.Contact_Type__c;
			 	   con.ACUTE_job__c = newcm.ACUTE_job__c;
				   con.Gender__c = newcm.Gender__c;
				   con.Phone = newcm.Phone__c;
				   con.ID_card__c = newcm.ID_card2__c;
				   con.Email = newcm.Email__c;
			       con.ACUTE_Affect__c = newcm.ACUTE_Affect__c;
			       con.ACUTE_DepartmentBeds__c = newcm.ACUTE_DepartmentBeds__c;
				   con.ACUTE_TreatmentTime__c = newcm.ACUTE_TreatmentTime__c;
			 	   con.ACUTE_TreatPeyients__c = newcm.ACUTE_TreatPeyients__c;
				   con.ACUTE_CRRT_Prescription__c = newcm.ACUTE_CRRT_Prescription__c;
				   con.ACUTE_Flex_Prescription__c = newcm.ACUTE_Flex_Prescription__c;
				   con.ACUTE_KidneyRate__c = newcm.ACUTE_KidneyRate__c;
				   con.ACUTE_DuctBrand__c = newcm.ACUTE_DuctBrand__c;
				   con.ACUTE_DuctNumbers__c = newcm.ACUTE_DuctNumbers__c;
				   con.recordTypeId = ACUTEId; 
				   con.AccountId = newcm.Account__c;
				   con.OwnerId = newcm.OwnerId;
				   list_Cons.add(con);
	            }
	        }
	    }
	    
	    //插入信联系人
	    if(list_Cons != null && list_Cons.size()>0)
	    {
	    	insert list_Cons;
	    }  
	    
	    List<Contact> list_ConMods = new List<Contact>();
	    //修改联系人信息
		if(!map_conMod.isEmpty())
	    {
	        for(Contact contact : [Select c.Id, c.LastName, c.ACUTE_Department__c,ACUTE_Flex_Prescription__c,
	        		ContactType__c,ACUTE_job__c,Gender__c,Phone,ID_card__c,Email,ACUTE_Affect__c,ACUTE_KidneyRate__c,
	        		ACUTE_DepartmentBeds__c,ACUTE_TreatmentTime__c,ACUTE_TreatPeyients__c,ACUTE_CRRT_Prescription__c,
	        		ACUTE_DuctBrand__c,ACUTE_DuctNumbers__c
	        		From Contact c where Id in : map_conMod.keySet()])
	        {
	        	if(map_conMod.containsKey(contact.Id))
	            {        	
	               contact.recordTypeId = ACUTEId; 
	               contact.OwnerId = map_conMod.get(contact.Id).OwnerId;
	               //contact.AccountId = newcm.Account__c;
			       contact.LastName = map_conMod.get(contact.Id).NewContact__c;
			       contact.ACUTE_Department__c = map_conMod.get(contact.Id).ACUTE_Department__c;
				   contact.ContactType__c = map_conMod.get(contact.Id).Contact_Type__c;
			 	   contact.ACUTE_job__c = map_conMod.get(contact.Id).ACUTE_job__c;
				   contact.Gender__c = map_conMod.get(contact.Id).Gender__c;
				   contact.Phone = map_conMod.get(contact.Id).Phone__c;
				   contact.ID_card__c = map_conMod.get(contact.Id).ID_card2__c;
				   contact.Email = map_conMod.get(contact.Id).Email__c;
			       contact.ACUTE_Affect__c = map_conMod.get(contact.Id).ACUTE_Affect__c;
			       contact.ACUTE_DepartmentBeds__c = map_conMod.get(contact.Id).ACUTE_DepartmentBeds__c;
				   contact.ACUTE_TreatmentTime__c = map_conMod.get(contact.Id).ACUTE_TreatmentTime__c;
			 	   contact.ACUTE_TreatPeyients__c = map_conMod.get(contact.Id).ACUTE_TreatPeyients__c;
				   contact.ACUTE_CRRT_Prescription__c = map_conMod.get(contact.Id).ACUTE_CRRT_Prescription__c;
				   contact.ACUTE_Flex_Prescription__c = map_conMod.get(contact.Id).ACUTE_Flex_Prescription__c;
				   contact.ACUTE_KidneyRate__c = map_conMod.get(contact.Id).ACUTE_KidneyRate__c;
				   contact.ACUTE_DuctBrand__c = map_conMod.get(contact.Id).ACUTE_DuctBrand__c;
				   contact.ACUTE_DuctNumbers__c = map_conMod.get(contact.Id).ACUTE_DuctNumbers__c;
				   list_ConMods.add(contact);
	            }
	        }
	        
		    //修改联系人
		    if(list_ConMods != null && list_ConMods.size()>0)
		    {
		    	update list_ConMods;
		    }         
	    }  
	}else{
	    //联系人修改申请
	    set<ID> set_conIds = new set<ID>();
	    //新增联系人
	    List<Contact> list_Cons = new List<Contact>();
	    for(Contact_Mod__c newcm:trigger.new)
	    {
	        if(newcm.TW_DevName__c!='acute_Update')
	        {
	            continue;
	        }
            if(newcm.Name__c != null)
            {
                set_conIds.add(newcm.Name__c);
            }      
	    }	
	    
	    //联系人修改申请
	    Map<ID,Contact> map_con = new Map<ID,Contact>();
	    //获取联系人原信息
        for(Contact contact : [Select c.Id, c.LastName, c.ACUTE_Department__c,ACUTE_Flex_Prescription__c,
        		ContactType__c,ACUTE_job__c,Gender__c,Phone,ID_card__c,Email,ACUTE_Affect__c,ACUTE_KidneyRate__c,
        		ACUTE_DepartmentBeds__c,ACUTE_TreatmentTime__c,ACUTE_TreatPeyients__c,ACUTE_CRRT_Prescription__c,
        		ACUTE_DuctBrand__c,ACUTE_DuctNumbers__c
        		From Contact c where Id in : set_conIds])
        {    
        	map_con.put(contact.Id,contact);
        } 
	    for(Contact_Mod__c newcm:trigger.new)
	    {
	        if(newcm.TW_DevName__c!='acute_Update')
	        {
	            continue;
	        }
            if(newcm.Name__c != null && map_con.containsKey(newcm.Name__c))
            {
 				   newcm.ACUTE_OldDepartment__c = map_con.get(newcm.Name__c).ACUTE_Department__c;
				   newcm.SP_OldContactType__c = map_con.get(newcm.Name__c).ContactType__c;
				   newcm.ACUTE_Oldjob__c = map_con.get(newcm.Name__c).ACUTE_job__c;
				   newcm.SP_OldGender__c = map_con.get(newcm.Name__c).Gender__c;
				   newcm.SP_OldPhone__c = map_con.get(newcm.Name__c).Phone;
				   newcm.SP_OldIdcard2__c = map_con.get(newcm.Name__c).ID_card__c;
				   newcm.SP_OldEmail__c = map_con.get(newcm.Name__c).Email;
				   newcm.ACUTE_OldAffect__c = map_con.get(newcm.Name__c).ACUTE_Affect__c;
				   newcm.ACUTE_OldDepartmentBeds__c = map_con.get(newcm.Name__c).ACUTE_DepartmentBeds__c;
				   newcm.ACUTE_OldTreatmentTime__c = map_con.get(newcm.Name__c).ACUTE_TreatmentTime__c;
				   newcm.ACUTE_OldTreatPeyients__c = map_con.get(newcm.Name__c).ACUTE_TreatPeyients__c;
				   newcm.ACUTE_OldCRRT_Prescription__c = map_con.get(newcm.Name__c).ACUTE_CRRT_Prescription__c;
				   newcm.ACUTE_OldFlex_Prescription__c = map_con.get(newcm.Name__c).ACUTE_Flex_Prescription__c;
				   newcm.ACUTE_OldKidneyRate__c = map_con.get(newcm.Name__c).ACUTE_KidneyRate__c;
				   newcm.ACUTE_OldDuctBrand__c = map_con.get(newcm.Name__c).ACUTE_DuctBrand__c;
				   newcm.ACUTE_OldDuctNumbers__c = map_con.get(newcm.Name__c).ACUTE_DuctNumbers__c;               
            }      
	    }         	    
	}  
}
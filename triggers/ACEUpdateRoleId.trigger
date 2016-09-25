trigger ACEUpdateRoleId on OrgsRole_Mapper__c (before insert,before update) {
    
    List<String> roleList = new List<String>();
    List<OrgsRole_Mapper__c> updateList = new List<OrgsRole_Mapper__c>();
    for(OrgsRole_Mapper__c org : Trigger.New){
        roleList.add(org.Role_Id__c);
    }
    
    List<UserRole> userRoleList = new List<UserRole>();
    
    userRoleList = [Select Id from UserRole where id IN : roleList];
    Map<String,String> role1518DigitMap = new Map<String,String>();
    List<String> tempRoleString = new List<String>();
    for(UserRole usrRole : userRoleList){
        String tempIdString = usrRole.Id;
        String tempString = tempIdString.subString(0,15);
        role1518DigitMap.put(tempString,tempIdString);
    }
    for(OrgsRole_Mapper__c org1 : Trigger.New){
        if(role1518DigitMap.ContainsKey(org1.Role_Id__c)){
            org1.Role_Id__c = role1518DigitMap.get(org1.Role_Id__c);
            updateList.add(org1);
        }
    }
    //update updateList;
}
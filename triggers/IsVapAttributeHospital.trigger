/**
 * Author : Bill
 * 当创建挥发罐维修退回明细时，选择需要退回的挥发罐需要满足以下几点条件：
 * 1、挥发罐的状态必须是“使用”，当前位置是“医院”
 * 2、挥发罐必须属于维修退回申请的当前客户（医院）
 * 3. 判断该挥发罐是否已经存在维修退回明细
**/
trigger IsVapAttributeHospital on Vaporizer_ReturnAndMainten_Detail__c (before insert) {
	//插入罐子的Id
    List<ID> list_VapIds = new List<ID>();
    //维修退回申请ID
    List<ID> List_ReturnIds = new List<ID>();
    Map<ID,ID> vap_Hosptail = new Map<ID,ID>();
    
    if(trigger.isInsert){
    	for(Vaporizer_ReturnAndMainten_Detail__c VapReturn : trigger.new){
    		if(VapReturn.VaporizerInfo__c != null){
    			list_VapIds.add(VapReturn.VaporizerInfo__c);
    			List_ReturnIds.add(VapReturn.Vaporizer_ReturnAndMainten__c);
    			vap_Hosptail.put(VapReturn.VaporizerInfo__c,VapReturn.Vaporizer_ReturnAndMainten__c);
    		}
    	}
    }
    
    //挥发罐
    List<VaporizerInfo__c> List_vap = [Select v.location__c, v.Status__c, v.Id, v.Hospital__c From VaporizerInfo__c v where v.Id in : list_VapIds];
    //维修退回申请
    List<Vaporizer_ReturnAndMainten__c> List_ApplyReturn = [Select v.Id, v.Hospital__c From Vaporizer_ReturnAndMainten__c v where v.Id in:List_ReturnIds];
    
    Map<ID,VaporizerInfo__c> vapor_Hosptail = new Map<ID,VaporizerInfo__c>();
    for(VaporizerInfo__c vapor : List_vap)
    {
    	vapor_Hosptail.put(vapor.Id,vapor);
    }
    
    //维修退回对应的医院（客户）
    Map<ID,ID> Rerern_Hosptail = new Map<ID,ID>();
    for(Vaporizer_ReturnAndMainten__c ApplyReturn : List_ApplyReturn)
    {
    	Rerern_Hosptail.put(ApplyReturn.Id,ApplyReturn.Hospital__c);
    }
    
    //符合条件的挥发罐Id
    Set<ID> accordVapIds = new Set<ID>();
    
    if(trigger.isInsert){
    	for(Vaporizer_ReturnAndMainten_Detail__c VapReturn : trigger.new){
    		if(VapReturn.VaporizerInfo__c != null){
    			VaporizerInfo__c vaporizer =vapor_Hosptail.get(VapReturn.VaporizerInfo__c);
    			if(vaporizer.Status__c != '使用' || vaporizer.location__c != '医院')
    			{
    				VapReturn.addError('挥发罐的状态和当前位置不正确，不允许操作');
    				continue;
    			}
    			if(vaporizer.Hospital__c != Rerern_Hosptail.get(VapReturn.Vaporizer_ReturnAndMainten__c))
    			{
    				VapReturn.addError('该挥发罐不属于该医院(客户)，不允许操作');
    				continue;
    			}else{
    				accordVapIds.add(VapReturn.VaporizerInfo__c);
    			}
    		}
    	}
    }
    
    system.debug(accordVapIds+'kkkkkkkkkkkkk');
    if(accordVapIds.size()>0)
    {
      List<Vaporizer_ReturnAndMainten_Detail__c> list_vapReturns = [Select v.Id From Vaporizer_ReturnAndMainten_Detail__c v where v.VaporizerInfo__c in : accordVapIds and v.IsReceived__c = false];
      if(list_vapReturns != null && list_vapReturns.size() > 0)
      {
      	  trigger.new[0].addError('该挥发罐已经存在维修退回明细，不允许操作');
      }
    }
}
/**
 * Author : Sunny
 * 退回旧罐时，如果需要新罐，则将旧罐的信息带到新罐下
 */
trigger AutoVapRetDetailInfo on Vaporizer_ReturnAndMainten_Detail__c (before insert) {
    if(trigger.isInsert){
    	List<ID> list_VapId = new List<ID>();
    	for(Vaporizer_ReturnAndMainten_Detail__c VapRetDetail : trigger.new){
    		if(VapRetDetail.VaporizerInfo__c == null){
    			continue;
    		}
    		VapRetDetail.VapProduct__c = VapRetDetail.AppProduct__c;
    		if(VapRetDetail.NewAppProduct__c == null || VapRetDetail.NewVaporType__c == null || VapRetDetail.NewVaporBrand__c == null || VapRetDetail.NewVaporInterface__c == null){
    			list_VapId.add(VapRetDetail.VaporizerInfo__c);
    		}
    	}
    	if(list_VapId.size() > 0){
    		Map<ID,VaporizerInfo__c> map_VapInfo = new Map<ID,VaporizerInfo__c>();
    		for(VaporizerInfo__c VapInfo:[Select v.Id, v.VaporType__c, v.VaporInterface__c, v.VaporBrand__c, v.AppProduct__c From VaporizerInfo__c v Where Id in: list_VapId]){
    			map_VapInfo.put(VapInfo.Id , VapInfo);
    		}
    		for(Vaporizer_ReturnAndMainten_Detail__c VapRetDetail : trigger.new){
    			if(map_VapInfo.containsKey(VapRetDetail.VaporizerInfo__c)){
    				VaporizerInfo__c VapInfo = map_VapInfo.get(VapRetDetail.VaporizerInfo__c) ;
    				VapRetDetail.VapProduct__c = VapInfo.AppProduct__c;
    				if(!VapRetDetail.ReqireNewOne__c){
	                    continue;
	                }
    				if(VapRetDetail.NewAppProduct__c == null){
    					VapRetDetail.NewAppProduct__c = VapInfo.AppProduct__c;
    				}
    				if(VapRetDetail.NewVaporBrand__c == null){
    					VapRetDetail.NewVaporBrand__c = VapInfo.VaporBrand__c;
    				}
    				if(VapRetDetail.NewVaporInterface__c == null){
                        VapRetDetail.NewVaporInterface__c = VapInfo.VaporInterface__c;
                    }
                    if(VapRetDetail.NewVaporType__c == null){
                        VapRetDetail.NewVaporType__c = VapInfo.VaporType__c;
                    }
    			}
    		}
    	}
    }
}
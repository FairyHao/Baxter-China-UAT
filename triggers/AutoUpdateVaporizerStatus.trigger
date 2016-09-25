/**
 * Author : Sunny
 * 当挥发罐发货信息创建之后，说明已经确认发货，需要根据是挥发罐申请重新维护挥发罐位置、状态等信息。
 * 增加功能：BIll 2013-7-22
 * 当挥发罐被工程师确认发货后，修改挥发罐的所有人为申请的代表，
 * 挥发罐的销售大区赋值
 * 当挥发罐被退回后，挥发罐的所有人修改为系统管理员Baxter China，销售大区清空
**/
trigger AutoUpdateVaporizerStatus on Vaporizer_Shipping__c (after insert) {
	
    if(trigger.isInsert){
        List<ID> list_SalesDeliverRet = new List<ID>();
        List<ID> list_EngineerDeliverApp = new List<ID>();
        List<ID> list_SalesReceive = new List<ID>();
        
        List<VaporizerInfo__c> list_VapInfo = new List<VaporizerInfo__c>();
        for(Vaporizer_Shipping__c VapShipping : trigger.new){
            if(VapShipping.RecordTypeDevName__c == 'DeliverInfo'){//记录类型是发货的
            	if(VapShipping.Type__c == '销售发货'){//销售发货时，只有退回申请
            		if(VapShipping.Vaporizer_ReturnAndMainten_Detail__c != null){
            			list_SalesDeliverRet.add(VapShipping.Vaporizer_ReturnAndMainten_Detail__c);
            		}
            	}else if(VapShipping.Type__c == '工程师发货'){//工程师发货时，可能是使用申请，也可能是需要新罐的退回申请
            		if(VapShipping.Vaporizer_Application_Detail__c != null){
            			list_EngineerDeliverApp.add(VapShipping.Vaporizer_Application_Detail__c);
            		}
            	}
            }else if(VapShipping.RecordTypeDevName__c == 'ReceiveInfo'){
                if(VapShipping.Type__c == '销售收货'){
                    if(VapShipping.Vaporizer_Application_Detail__c != null){
                        list_SalesReceive.add(VapShipping.Vaporizer_Application_Detail__c);
                    }
                }
            }
        }
        system.debug(list_SalesReceive);
        if(list_SalesReceive.size() > 0){
            for(Vaporizer_Application_Detail__c VapAppDetail : [Select Id,VaporizerInfo__c,VaporizerInfo__r.InitUsedDate__c From Vaporizer_Application_Detail__c Where Id in: list_SalesReceive]){
                VaporizerInfo__c VapInfo = VapAppDetail.VaporizerInfo__r;
                VapInfo.InitUsedDate__c = date.today();
                list_VapInfo.add(VapInfo);
            }
        }
        system.debug('klm'+list_EngineerDeliverApp);
        //工程师使用申请发货
        if(list_EngineerDeliverApp.size() > 0){
        	for(Vaporizer_Application_Detail__c VapAppDetail : [Select v.Vaporizer_Apply_Detail__r.OperationRoom_No__c, v.Vaporizer_Apply_Detail__c, 
        	           v.Vaporizer_Application__r.VapOpportunity__c, v.Vaporizer_Application__r.Hospital__c, v.Vaporizer_Application__r.OwnerId, v.Vaporizer_Application__r.Contact__c,
        	           //billl add 使用申请的销售大区
        	           v.Vaporizer_Application__r.SalesRegion__c, 
        	           v.Vaporizer_Application__c, v.VaporizerInfo__r.OperationRoom_No__c, v.VaporizerInfo__r.location__c, v.VaporizerInfo__r.Status__c, 
        	           v.VaporizerInfo__r.Opportunity__c, v.VaporizerInfo__r.Hospital__c, v.VaporizerInfo__r.Contact__c, v.VaporizerInfo__c,v.VaporizerInfo__r.CurrentSales__c, 
        	           //billl add 退回申请的销售大区
        	           v.Vaporizer_ReturnAndMainten__r.SalesRegion__c, 
        	           v.Vaporizer_ReturnAndMainten__r.StockContact__c, v.Vaporizer_ReturnAndMainten__r.Hospital__c, v.Vaporizer_ReturnAndMainten__r.OwnerId, v.Vaporizer_ReturnAndMainten__c, 
        	           v.Vaporizer_ReturnAndMainten_Detail__r.OperationRoom_No__c, v.Vaporizer_ReturnAndMainten_Detail__c
        	           From Vaporizer_Application_Detail__c v
        	           Where Id in: list_EngineerDeliverApp]){
        		VaporizerInfo__c VapInfo = VapAppDetail.VaporizerInfo__r;
        		if(VapAppDetail.Vaporizer_Application__c != null || VapAppDetail.Vaporizer_Apply_Detail__c != null){
        			VapInfo.Hospital__c = VapAppDetail.Vaporizer_Application__r.Hospital__c;
	                VapInfo.Opportunity__c = VapAppDetail.Vaporizer_Application__r.VapOpportunity__c;
	                VapInfo.Contact__c = VapAppDetail.Vaporizer_Application__r.Contact__c;
	                VapInfo.OperationRoom_No__c = VapAppDetail.Vaporizer_Apply_Detail__r.OperationRoom_No__c;
	                VapInfo.Status__c ='使用';
	                VapInfo.location__c = '医院';
	                /************************bill add 2013-7-22 start************************/
	                VapInfo.OwnerId = VapAppDetail.Vaporizer_Application__r.OwnerId;
	                /************************bill add 2013-7-22 end  ************************/
	                VapInfo.CurrentSales__c = VapAppDetail.Vaporizer_Application__r.OwnerId ;
	                list_VapInfo.add(VapInfo);
        		}else if(VapAppDetail.Vaporizer_ReturnAndMainten__c != null || VapAppDetail.Vaporizer_ReturnAndMainten_Detail__c!=null){
        			VapInfo.Hospital__c = VapAppDetail.Vaporizer_ReturnAndMainten__r.Hospital__c;
	                VapInfo.Opportunity__c = null;
	                VapInfo.OperationRoom_No__c = VapAppDetail.Vaporizer_ReturnAndMainten_Detail__r.OperationRoom_No__c;
	                VapInfo.Contact__c = VapAppDetail.Vaporizer_ReturnAndMainten__r.StockContact__c;
	                VapInfo.Status__c = '使用';
	                VapInfo.location__c = '医院';
	                /************************bill add 2013-7-22 start************************/
	                VapInfo.OwnerId = VapAppDetail.Vaporizer_ReturnAndMainten__r.OwnerId;
	                /************************bill add 2013-7-22 end  ************************/
	                VapInfo.CurrentSales__c = VapAppDetail.Vaporizer_ReturnAndMainten__r.OwnerId ;
	                list_VapInfo.add(VapInfo);
        		}
        	}
        }
        system.debug(list_SalesDeliverRet);
        //销售维修申请发货
        if(list_SalesDeliverRet.size() > 0){
        	for(Vaporizer_ReturnAndMainten_Detail__c VapRetDetail : [Select v.Vaporizer_ReturnAndMainten__c, v.VaporizerInfo__r.OperationRoom_No__c, 
        	           v.VaporizerInfo__r.location__c, v.VaporizerInfo__r.Status__c, v.Operate__c, v.VaporizerInfo__r.CurrentSales__c,
        	           v.VaporizerInfo__r.Opportunity__c, v.VaporizerInfo__r.Hospital__c, v.VaporizerInfo__r.Contact__c, v.VaporizerInfo__c 
        	           From Vaporizer_ReturnAndMainten_Detail__c v
        	           Where Id in: list_SalesDeliverRet]){
        		VaporizerInfo__c VapInfo = VapRetDetail.VaporizerInfo__r ;
        		VapInfo.Hospital__c = null;
        		VapInfo.Opportunity__c = null;
        		VapInfo.Contact__c = null;
        		VapInfo.OperationRoom_No__c = null;
        		if(VapRetDetail.Operate__c == '维修'){
        			VapInfo.Status__c = '维修';
        		}else if(VapRetDetail.Operate__c == '退回'){
        			VapInfo.Status__c = '库存';
        		}
        		VapInfo.location__c = '上海仓库' ;
        		/************************bill add 2013-7-22 start************************/
                VapInfo.OwnerId = [Select u.ProfileId, u.Id From User u where u.Name = 'Baxter China' and IsActive = true][0].Id;
                /************************bill add 2013-7-22 end  ************************/
        		VapInfo.CurrentSales__c = null;
        		list_VapInfo.add(VapInfo);
        	}
        }
        system.debug('huifag xinxi:'+list_VapInfo);
        if(list_VapInfo.size() > 0){
        	update list_VapInfo;
        }
    }
    
}
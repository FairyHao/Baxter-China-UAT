/*
 *Hank
 *2013-12-31
 *客户小组审批后，同步数据到真正的客户小组。
 *仅供侨光地区使用
*/
trigger BQ_AccountTeamSync on V2_Account_Team__c ( before update) {
    /*====================判断当前用户是否为侨光========================*/
    Profile CurrentProfile = [select Id,Name from Profile where Id =:UserInfo.getProfileId()];
    if(!CurrentProfile.Name.startsWith('BQ'))
    {
        return;
    }
    /*====================判断当前用户是否为侨光========================*/
   List<V2_Account_Team__c> addAccList = new List<V2_Account_Team__c>();
    //List<V2_Account_Team__c> uptList = new List<V2_Account_Team__c>();
    List<AccountTeamMember> addList = new List<AccountTeamMember >();
        
        List<ID> list_DelUserId = new List<ID>() ;
        List<ID> list_DelAccId = new List<ID>() ;
    
    for(V2_Account_Team__c atc : trigger.new){
        //历史记录为真，则不做任何操作。
        if(atc.V2_History__c==true){
            continue;
        }
        //判断状态改变，查找旧的值
        V2_Account_Team__c oldAtc = trigger.oldMap.get(atc.id);
        
        if(atc.V2_ApprovalStatus__c=='待审批'){
            atc.V2_DSApproved__c = false;
            atc.V2_ASApproved__c=false;
            atc.V2_RegionalApproved__c=false;
            atc.V2_NationalApproved__c=false;
        }else if(atc.V2_ApprovalStatus__c=='审批拒绝'){
            if(atc.V2_BatchOperate__c=='新增'){
                
            } else if(atc.V2_BatchOperate__c=='删除'){
                atc.V2_Is_Delete__c = false;
                atc.V2_Delete_Month__c=null;
                atc.V2_Delete_Year__c=null;
                atc.DeleteDate__c = null;
                //uptList.add(atc);
            } else if(atc.V2_BatchOperate__c=='替换'){
                atc.V2_NewAccUser__c = null;
                atc.V2_Effective_NewYear__c=null;
                atc.V2_Effective_NewMonth__c=null;
                atc.NewEffDate__c = null ;
                atc.DeleteDate__c=null;
                atc.V2_Delete_Year__c=null;
                atc.V2_Delete_Month__c=null;
                //uptList.add(atc);
            }
            
        } else if(atc.V2_ApprovalStatus__c=='审批通过' && oldAtc.V2_ApprovalStatus__c!='审批通过'){
            if(atc.V2_BatchOperate__c=='新增'){
                //增加一个小组成员
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = atc.V2_Account__c;
                atm.UserId  =atc.V2_User__c;
                addList.add(atm);
                
                atc.V2_IsSyn__c =true;
                //uptList.add(atc);
                
            } else if(atc.V2_BatchOperate__c=='删除'){
                //只有立即删除的需要删除；
                if(atc.V2_ImmediateDelete__c){
                    atc.V2_History__c=true;
                    //uptList.add(atc);
                    
                    list_DelUserId.add(atc.V2_User__c) ;
                    list_DelAccId.add(atc.V2_Account__c) ;
    
                }
            } else if(atc.V2_BatchOperate__c=='替换'){
                /**
                if(atc.V2_Effective_NewMonth__c == '1')
                {
                        atc.V2_Delete_Month__c = '12' ;
                        atc.V2_Delete_Year__c = String.valueOf(Integer.valueOf( atc.V2_Effective_NewYear__c) - 1) ;
                }else
                {
                        atc.V2_Delete_Month__c = String.valueOf(Integer.valueOf(atc.V2_Effective_NewMonth__c) - 1) ;
                        atc.V2_Delete_Year__c =atc.V2_Effective_NewYear__c ;
                }
                **/
                //atc.V2_Delete_Month__c = atc.V2_Effective_NewMonth__c ;
                //atc.V2_Delete_Year__c =atc.V2_Effective_NewYear__c ;
                
                atc.V2_Is_Delete__c=true;
                //uptList.add(atc);
                
                V2_Account_Team__c accTeam = new V2_Account_Team__c();
                accTeam.V2_User__c=atc.V2_NewAccUser__c;
                accTeam.EffectiveDate__c = atc.NewEffDate__c;
                accTeam.V2_Effective_Year__c = atc.V2_Effective_NewYear__c;
                accTeam.V2_Effective_Month__c = atc.V2_Effective_NewMonth__c;
                //****设置Account字段***
                accTeam.V2_Account__c = atc.V2_Account__c ;
                accTeam.V2_IsSyn__c =true;
                accTeam.V2_BatchOperate__c='新增';
                accTeam.V2_ApprovalStatus__c='审批通过';
                accTeam.ownerid=atc.V2_NewAccUser__c;
                addAccList.add(accTeam);
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = atc.V2_Account__c;
                atm.UserId  =atc.V2_NewAccUser__c;
                addList.add(atm);
                
                
            }
        }
        
        
    }
    
    
        System.debug('8888888888');
        //插入临时客户小组
        if(addAccList.size()>0){
            System.debug('9999999');
            insert addAccList;
        }
        //插入客户小组
        if(addList.size()>0){
            system.debug(addList) ;
            insert addList;
            
        }
        
        //删除客户小组
        if(list_DelUserId.size() != 0 && list_DelAccId.size() != 0)
        {
            List<AccountTeamMember> list_ATMDel = [Select id From AccountTeamMember Where UserId in: list_DelUserId And AccountId in: list_DelAccId] ;
            if(list_ATMDel != null)
            {
                delete list_ATMDel ;
            }
        }
}
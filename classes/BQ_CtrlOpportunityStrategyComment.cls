/**
 * 作者：Sunny
 * 
 * 
**/
public class BQ_CtrlOpportunityStrategyComment {
	private Integer intDay = 10 ;//标记几号之前可以进行评价操作
    public List<OppEvaWrapper> list_OppEva{get;set;}
    public List<OppEvaWrapperByYear> list_OppEvaYear{get;set;}
    public List<List<OppEvaWrapper>> list_oppEvaByYear{get;set;}
    public String strNewMonth{get;set;}
    public String strNewYear{get;set;}
    public List<SelectOption> getNewMonths(){
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('--无--','--无--'));
        if(Date.today().day() > 8){
            strNewMonth = String.valueOf(date.today().month());
        }else{
            strNewMonth = String.valueOf(date.today().addMonths(-1).month());
        }
        options.add(new SelectOption(String.valueOf(date.today().month()),String.valueOf(date.today().month())));
        if(date.today().day() <= intDay){
            options.add(new SelectOption(String.valueOf(date.today().addMonths(-1).month()),String.valueOf(date.today().addMonths(-1).month())));
        }
        
        return options;
    }
    public List<SelectOption> getNewYears(){
        List<SelectOption> options = new List<SelectOption>();
        strNewYear=String.valueOf(date.today().Year());
        options.add(new SelectOption(String.valueOf(date.today().Year()),String.valueOf(date.today().Year())));
        if(date.today().month() == 1){
            options.add(new SelectOption(String.valueOf(date.today().addMonths(-1).Year()),String.valueOf(date.today().addMonths(-1).Year())));
        }
        return options;
    }
    public String strEditId{get;set;}
    public ID OppId{get;set;}
    public ID UserId{get;set;}
    public Boolean blnHaveNew{get;set;}
    private ID OppOwnerId ;
    private string strUrole;
    public boolean ismanager{get;set;}
    public BQ_CtrlOpportunityStrategyComment(Apexpages.Standardcontroller controller){
        //strNewMonth = String.valueOf(date.today().month());
        if(Date.today().day() > 8){
        	strNewMonth = String.valueOf(date.today().month());
        }else{
        	strNewMonth = String.valueOf(date.today().addMonths(-1).month());
        }
        UserId=UserInfo.getUserId();
        OppId = controller.getId();
        list_OppEva = new List<OppEvaWrapper>();
        list_OppEvaYear = new List<OppEvaWrapperByYear>();
        list_oppEvaByYear = new List<List<OppEvaWrapper>>();
        
        getOppEvaluations();
        
        List<UserRole> listur = [Select Id,Name From UserRole Where Id =: Userinfo.getUserRoleId()];
        if(listur.size() > 0 ){
            String strRolName = listur[0].Name; 
            
            if(strRolName.toUpperCase().contains('REP')){
                ismanager=false;
            }else {
                ismanager=true;
            }
            
            if(strRolName.contains('-')){
                List<String> list_s = strRolName.split('-');
                if(list_s.size() == 5){
                    strUrole=list_s[1];
                }else{
                    strUrole=strRolName;
                }
            }else{
                strUrole=strRolName;
            }
        }
    }
    public String strYear{get{return String.valueOf(date.today().Year());}}
    public String strMonth{get{return String.valueOf(date.today().Month());}}
    private Set<String> set_haveComment = new Set<String>();
    private Map<String , List<OppEvaWrapper>> map_oew = new Map<String , List<OppEvaWrapper>>();
    private void getOppEvaluations(){
        if(OppId != null){
            //list_oppEvaByYear.clear();
            map_oew.clear();
            list_OppEva.clear();
            set_haveComment.clear();
            for(OppEvaluation__c oppEva : [Select Id,BeCommentUser__c,Commentator__c,CommentDate__c,
                                           Year__c,Score__c,Comments__c,Opportunity__c,Opportunity__r.OwnerId,Month__c,IsQualityEva__c 
                                           From OppEvaluation__c Where Opportunity__c =: OppId Order By Month__c desc]){
                //封装
                OppEvaWrapper oppEvaWra = new OppEvaWrapper();
                set_haveComment.add(oppEva.Commentator__c+oppEva.Month__c+oppEva.Year__c);
                oppEvaWra.blnOld = true;
                if(OppOwnerId==null){
                    OppOwnerId = oppEva.Opportunity__r.OwnerId;
                }
                oppEvaWra.OppEva = oppEva ;
                if(date.today().day() <= intDay && 
                   oppEva.Year__c == String.valueOf(date.today().addMonths(-1).Year()) && 
                   oppEva.Month__c == String.valueOf(date.today().addMonths(-1).Month()) &&
                   oppEva.Commentator__c == UserInfo.getUserId()){
                    oppEvaWra.blnCanEdit = true;
                }else if(oppEva.Year__c == String.valueOf(date.today().Year()) && oppEva.Month__c == String.valueOf(date.today().Month()) && oppEva.Commentator__c == UserInfo.getUserId()){
                    oppEvaWra.blnCanEdit = true;
                }
                //按年构建
                if(map_oew.containsKey(oppEva.Year__c)){
                    List<OppEvaWrapper> list_oew = map_oew.get(oppEva.Year__c);
                    list_oew.add(oppEvaWra);
                    map_oew.put(oppEva.Year__c , list_oew);
                }else{
                    List<OppEvaWrapper> list_oew = new List<OppEvaWrapper>();
                    list_oew.add(oppEvaWra);
                    map_oew.put(oppEva.Year__c , list_oew);
                }
                list_OppEva.add(oppEvaWra);
            }
            buildTable(map_oew);
            
            
        }
    }
    private void buildTable(Map<String , List<OppEvaWrapper>> map_oewr){
        list_oppEvaByYear.clear();
        list_OppEvaYear.clear();
        if(map_oewr.size() > 0){
            List<String> list_year = new List<String>();
            list_year.addAll(map_oewr.keySet());
            list_year.sort();
            for(String stryear : list_year){
                List<OppEvaWrapper> listoew = map_oewr.get(stryear);
                OppEvaWrapperByYear oewby = new OppEvaWrapperByYear();
                oewby.strYear = stryear;
                oewby.listOppEvaw=listoew;
                if(list_OppEvaYear.size() > 0){
                    list_OppEvaYear.add(0,oewby);
                }else{
                    list_OppEvaYear.add(oewby);
                }
                
                
                if(list_oppEvaByYear.size() > 0){
                    list_oppEvaByYear.add(0 , listoew);
                }else{
                    list_oppEvaByYear.add(listoew);
                }
            }
        }
        system.debug('year list:'+list_oppEvaByYear);
        system.debug('year listsssss:'+list_OppEvaYear);
    }
    
    public void addComment(){
        
        OppEvaWrapper oppEvaWra = new OppEvaWrapper();
        oppEvaWra.OppEva = new OppEvaluation__c();
        oppEvaWra.OppEva.Commentator__c = UserInfo.getUserId();
        oppEvaWra.OppEva.Opportunity__c = OppId;
        oppEvaWra.strMonth = strNewMonth;
        if(oppEvaWra.strMonth == String.valueOf(date.today().month())){
            oppEvaWra.OppEva.Year__c = String.valueOf(date.today().year());
        }else if(oppEvaWra.strMonth == String.valueOf(date.today().addMonths(-1).month())){
            oppEvaWra.OppEva.Year__c = String.valueOf(date.today().addMonths(-1).year());
        }
        if(OppOwnerId!=null){
            oppEvaWra.OppEva.BeCommentUser__c = OppOwnerId;
        }else{
            List<Opportunity> list_opp = [Select Id,OwnerId From Opportunity Where Id =: OppId];
            if(list_opp.size() > 0){
                oppEvaWra.OppEva.BeCommentUser__c = list_opp[0].OwnerId;
            }
        }
        oppEvaWra.blnNew=true;
        
        if(map_oew.containsKey(oppEvaWra.OppEva.Year__c)){
            List<OppEvaWrapper> list_oew=map_oew.get(oppEvaWra.OppEva.Year__c);
            list_oew.add(0,oppEvaWra);
            map_oew.put(oppEvaWra.OppEva.Year__c , list_oew);
        }else{
            List<OppEvaWrapper> list_oew=new List<OppEvaWrapper>();
            list_oew.add(oppEvaWra);
            map_oew.put(oppEvaWra.OppEva.Year__c , list_oew);
        }
        buildTable(map_oew);
        /*
        if(list_OppEva.size() > 0){
            list_OppEva.add(0 , oppEvaWra);
        }else{
            list_OppEva.add( oppEvaWra);
        }
        */
        blnHaveNew = true;
        system.debug('have new ???'+blnHaveNew);
    }
    public void saveComment(){
        List<OppEvaluation__c> list_oppEvaIns = new List<OppEvaluation__c>();
        List<OppEvaluation__c> list_oppEvaUp = new List<OppEvaluation__c>();
        for(OppEvaWrapperByYear oewby : list_OppEvaYear){
           for(OppEvaWrapper oew : oewby.listOppEvaw){
                system.debug(oew);
                if(strEditId == 'new'){
                    if(oew.blnNew == true && oew.OppEva.Id == null){
                        
                        oew.OppEva.Month__c=oew.strMonth;
                        oew.OppEva.CommentatorRole__c=strUrole;
                        oew.OppEva.CommentDate__c = date.today();
                        if(oew.strMonth == String.valueOf(date.today().month())){
                            oew.OppEva.Year__c = String.valueOf(date.today().year());
                        }else if(oew.strMonth == String.valueOf(date.today().addMonths(-1).month())){
                            oew.OppEva.Year__c = String.valueOf(date.today().addMonths(-1).year());
                        }else{
                            //error
                        }
                        if(set_haveComment.contains(oew.OppEva.Commentator__c+oew.OppEva.Month__c+oew.OppEva.Year__c)){
                            continue;
                        }
                        system.debug(oew);
                        list_oppEvaIns.add(oew.OppEva);
                        blnHaveNew = false;
                    }
                }else if(strEditId == oew.OppEva.Id){
                    if(oew.blnEdit == true && oew.OppEva.Id != null){
                        list_oppEvaUp.add(oew.OppEva);
                    }
                }
            }
        }
        
        system.debug('Heee'+list_oppEvaIns);
        /*************bill  add 2013/4/26 begin*********************/
        //sunny 2013-5-14注释掉自动发邮件
        //AutoSendmail autoSendmail = NEW AutoSendmail();
        if(list_oppEvaIns.size() > 0){
            insert list_oppEvaIns;
            //autoSendmail.AutoSendmailOpportunity(oppId, list_oppEvaIns[0].Id, '评分');
        }
        if(list_oppEvaUp.size()>0){
            update list_oppEvaUp;
            //autoSendmail.AutoSendmailOpportunity(oppId, list_oppEvaUp[0].Id, '评分修改');
        }
        /*************bill  add 2013/4/26 END*********************/
        getOppEvaluations();
    }
    public void editComment(){
        system.debug('edit record:'+strEditId);
        for(OppEvaWrapper oew : list_OppEva){
            if(oew.OppEva.Id == strEditId){
                oew.blnEdit=true;
                oew.blnCanEdit=false;
                oew.blnOld=false;
            }
        }
    }
    public void cannelEdit(){
        getOppEvaluations();
        /*
        for(OppEvaWrapper oew : list_OppEva){
            if(oew.OppEva.Id == strEditId){
                oew.blnEdit=false;
                oew.blnCanEdit=true;
                oew.blnOld=true;
            }
        }
        */
    }
    public void SendEmail(){
    	AutoSendmail autoSendmail = new AutoSendmail();
    	for(OppEvaWrapperByYear oewby : list_OppEvaYear){
    		for(OppEvaWrapper oew : oewby.listOppEvaw){
	            if(strEditId == oew.OppEva.Id){
	                autoSendmail.AutoSendmailOpportunity(OppId, oew.OppEva.Id, '评分');
	                return;
	            }
	        }
    	}
    }
    public class OppEvaWrapperByYear{
        public String strYear{get;set;}
        public list<OppEvaWrapper> listOppEvaw{get;set;}
    }
    public class OppEvaWrapper{
        public OppEvaluation__c OppEva{get;set;}
        public String strMonth{get;set;}
        public Boolean blnNew{get;set;}
        public Boolean blnOld{get;set;}
        public Boolean blnEdit{get;set;}
        public Boolean blnCanEdit{get;set;}
    }
    
    static testMethod void myUnitTest() {
    	// TO DO: implement unit test
        //user role
        List<UserRole> listur= new List<UserRole>();
        UserRole ur1 = new UserRole();
        ur1.Name = 'BQ Supervisor 上海 Sales Manager';
        listur.add(ur1);
        UserRole ur2 = new UserRole();
        ur2.Name = 'BQ Rep 上海 Sales Rep';
        listur.add(ur2);
        insert listur;
        //user 
        list<User> user=[Select TimeZoneSidKey,ProfileId,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey,CommunityNickname, Alias From User Where IsActive = true limit 1];
        List<User> list_user = new List<User>();
        User user1=new User();
        user1.username='user1r2@123.com';
        user1.LastName='user1r2';
        user1.Email='user1r2@123.com';
        user1.Alias=user[0].Alias;
        user1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        user1.ProfileId=UserInfo.getProfileId();
        user1.LocaleSidKey=user[0].LocaleSidKey;
        user1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        user1.EmailEncodingKey=user[0].EmailEncodingKey;
        user1.CommunityNickname='chequ';
        user1.MobilePhone='12345678912';
        user1.IsActive = true;
        user1.UserRoleId=ur1.Id ;
        list_user.add(user1);
        User user2=new User();
        user2.username='user2r2@223.com';
        user2.LastName='user2r2';
        user2.Email='user2r2@223.com';
        user2.Alias=user[0].Alias;
        user2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        user2.ProfileId=UserInfo.getProfileId();
        user2.LocaleSidKey=user[0].LocaleSidKey;
        user2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        user2.EmailEncodingKey=user[0].EmailEncodingKey;
        user2.CommunityNickname='chequ1';
        user2.MobilePhone='22345678922';
        user2.IsActive = true;
        user2.UserRoleId=ur2.Id ;
        list_user.add(user2);
        insert list_user;
    	//Opportunity
    	List<Opportunity> list_Opp = new List<Opportunity>();
    	Opportunity objOpp1 = new Opportunity();
    	objOpp1.Name = 'test opp';
    	objOpp1.Type = '新业务' ;
    	objOpp1.StageName = '发现/验证机会';
    	objOpp1.ProductType__c = 'IVS' ;
    	objOpp1.CloseDate = date.today().addMonths(1);
    	objOpp1.OwnerId = user2.Id;
    	list_Opp.add(objOpp1);
    	insert list_Opp ;
    	
        //OppEvaluation__c
        List<OppEvaluation__c> list_oppEva = new List<OppEvaluation__c>();
        OppEvaluation__c oppEva1 = new OppEvaluation__c();
        oppEva1.Year__c = String.valueOf(date.today().year());
        oppEva1.Month__c = String.valueOf(date.today().month());
        oppEva1.Commentator__c = user1.Id;
        oppEva1.Opportunity__c = objOpp1.Id;
        oppEva1.BeCommentUser__c = user2.Id ;
        oppEva1.Score__c = '4';
        list_oppEva.add(oppEva1);
        OppEvaluation__c oppEva2 = new OppEvaluation__c();
        oppEva2.Year__c = String.valueOf(date.today().year());
        oppEva2.Month__c = String.valueOf(date.today().addMonths(-1).month());
        oppEva2.Commentator__c = userinfo.getUserId();
        oppEva2.Commentator__c = user1.Id;
        oppEva2.Opportunity__c = objOpp1.Id;
        oppEva2.BeCommentUser__c = user2.Id ;
        oppEva2.Score__c = '4';
        list_oppEva.add(oppEva2);
        insert list_oppEva ;
        
        system.Test.startTest();
        Apexpages.Standardcontroller controll = new Apexpages.Standardcontroller(objOpp1);
        BQ_CtrlOpportunityStrategyComment oppEva = new BQ_CtrlOpportunityStrategyComment(controll);
        oppEva.getNewYears();
        oppEva.getNewMonths();
        oppEva.addComment();
        oppEva.strEditId = oppEva1.Id;
        oppEva.editComment();
        oppEva.saveComment();
        oppEva.cannelEdit();
        system.Test.stopTest();
    }
    
}
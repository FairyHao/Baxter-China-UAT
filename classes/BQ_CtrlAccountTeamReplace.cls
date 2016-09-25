/**
批量替换或者删除客户小组成员；
Tobe
*/
public class BQ_CtrlAccountTeamReplace 
{
	public V2_Account_Team__c vAccTeamDate{get;set;} //新成员，日期，调整原因
	public V2_Account_Team__c vAccTeamUser{get;set;} //选择成员
	public Boolean blnIsDelete{get;set;} //是否选择了删除操作
	public Boolean blnIsReplace{get;set;} //是否选择了替换操作
	public Boolean blnIsSearch{get;set;} //是否选择成员页面
	public Boolean blnIsAdmin{get;set;} //是否为管理员
	List<id> list_AccIds = new List<id>();
	public List<AccTeamWrappar> list_AccountTeamW{get;set;} //所选择成员的销售医院关系
	private Set<ID> set_SubUserIds ;//若当前用户为主管，其下属用户id集合
	private String strBu ;
	//取当前用户简档名称
	public string userProfileName = '';
	public string getUserProfileName()
	{
		Profile pro = [select Name From Profile Where Id =: Userinfo.getProfileId()];
		return pro.Name;
	}
	public BQ_CtrlAccountTeamReplace()
	{
		//初始化各项参数
		this.initParameters();
		this.initCurrentUser();
		this.initSubUser();
	}
	//初始化参数
	private void initParameters()
	{
		this.blnIsDelete = false;
        this.blnIsReplace = false;
        this.blnIsSearch = true;
        this.vAccTeamDate = new V2_Account_Team__c();
        this.vAccTeamUser = new V2_Account_Team__c();
        this.list_AccountTeamW = new List<AccTeamWrappar>();
	}
	//初始化当前登陆用户信息
	private void initCurrentUser()
	{
	    User objuser = [SELECT ID,Profile.Name,UserRole.Name from User WHERE Id =: UserInfo.getUserId()] ;
	    if(objuser.Profile.Name.toUpperCase().contains('ADMIN') || objuser.Profile.Name=='系统管理员')
	    {
	        blnIsAdmin = true;
	        //return;
	    }else{
	        blnIsAdmin = false ;
	    }
	    if(objuser.UserRole.Name == null && !blnIsAdmin)
	    {
	        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '无法确定您的角色。');            
	        ApexPages.addMessage(msg);
	        blnIsSearch = false;
	    }
	    if(objuser.UserRole.Name != null && objuser.UserRole.Name.toUpperCase().contains('REP'))
	    {
	        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '您没有权限进行此操作。');            
	        ApexPages.addMessage(msg);
	        blnIsSearch = false;
	    }
	}
	//初始化当前登陆人的下属
	private void initSubUser()
	{
		if(blnIsAdmin)
		{
			return ;
		}
		V2_UtilClass cls = new V2_UtilClass();
        //主管下属，包含下属的下属
        set_SubUserIds = cls.GetUserSubIds();
        //包含自己
        set_SubUserIds.add(UserInfo.getUserId());
	}
	//根据所选择成员，找到其有效的销售医院关系
	public void searchAccountByUser(){
		this.list_AccountTeamW.clear();
		//是否选择成员
		if(vAccTeamUser.V2_User__c == null)
		{
			return ;
		}
		//所选择成员是否为自己的下属
		if(!blnIsAdmin && !set_SubUserIds.contains(vAccTeamUser.V2_User__c))
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '您只能调整您自己的下属');            
            ApexPages.addMessage(msg);
            return;
		}
		
		//判断要替换的人的部门
        User objuser = [SELECT ID,Profile.Name,UserRole.Name from User WHERE Id =: vAccTeamUser.V2_User__c] ;
		if(objuser.UserRole.Name != null && objuser.UserRole.Name.toUpperCase().contains('SP'))
        {
            strBu = 'SP';
        }else if(objuser.UserRole.Name != null && objuser.UserRole.Name.toUpperCase().contains('IVT'))
        {
            strBu = 'IVT';
        }else if(objuser.UserRole.Name != null && objuser.UserRole.Name.toUpperCase().contains('PD'))
        {
            strBu = 'PD';
        }else if(objuser.UserRole.Name != null && objuser.UserRole.Name.toUpperCase().contains('HD'))
        {
            strBu = 'HD';
        }
        else if(objuser.UserRole.Name != null && objuser.UserRole.Name.toUpperCase().contains('BQ'))
        {
            strBu = 'BQ';
        }
        
		//查找该下属所有的销售医院关系
		for(V2_Account_Team__c vat:[Select V2_Account__c,V2_Account__r.Name,V2_Account__r.RecordType.Name,V2_Account__r.Provinces__r.Name,V2_Account__r.Cities__r.Name
		      ,EffectiveDate__c,V2_Effective_Year__c,V2_Effective_Month__c,V2_Delete_Year__c,DeleteDate__c,V2_Delete_Month__c,V2_User__c,V2_NewAccUser__c,V2_Effective_NewYear__c,
		      NewEffDate__c,V2_Effective_NewMonth__c,V2_BatchOperate__c,V2_AdjustReson__c
		      From V2_Account_Team__c 
		      Where V2_User__c =: vAccTeamUser.V2_User__c And V2_Is_Delete__c = false And V2_ApprovalStatus__c != '审批中' And V2_Delete_Year__c = NULL])
		{
            AccTeamWrappar atw = new AccTeamWrappar();
            atw.blnSelected = false;
            atw.vAccTeam = vat ;
            list_AccountTeamW.add(atw);
        }
	}
	//替换按钮
	public void doReplace()
	{
		//是否选择了要替换的医院
		List<V2_Account_Team__c> list_SeletedAT = new List<V2_Account_Team__c>();
		for(AccTeamWrappar atw : list_AccountTeamW)
		{
			if(atw.blnSelected == true)
			{
				list_SeletedAT.add(atw.vAccTeam);
			}
		}
		//若没有选择要替换的医院
		if(list_SeletedAT.size() == 0)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请选择医院');            
            ApexPages.addMessage(msg);
            return;
		}
		this.blnIsSearch = false;
		this.blnIsReplace = true;
		
		list_AccIds.clear();
        for(V2_Account_Team__c vat : list_SeletedAT){
            list_AccIds.add(vat.V2_Account__c);
        }
        String strMSG = '';
        if(this.strBu == 'PD')
        {
            String strPDTarget = this.checkHaveSurvivingPPD(list_AccIds);
            if(strPDTarget != ''){strMSG=strMSG+strPDTarget+'<br/>';}
            String strPDNewP = this.checkHaveNewP(list_AccIds);
            if(strPDNewP != ''){strMSG=strMSG+strPDNewP+'<br/>';}
            String strPDSurviving = this.checkHaveSurvivingPD(list_AccIds);
            if(strPDSurviving != ''){strMSG=strMSG+strPDSurviving+'<br/>';}
            String strPDNewPT = this.checkHaveNewPatientTargetPD(list_AccIds);
            if(strPDNewPT != ''){strMSG=strMSG+strPDNewPT+'<br/>';}
        }else if(this.strBu == 'IVT')
        {
            String strIVTTarget = this.checkHaveTargetIVT(list_AccIds);
            if(strIVTTarget != ''){strMSG=strMSG+strIVTTarget+'<br/>';}
        }else if(this.strBu == 'SP')
        {
            String strSPTarget = this.checkHaveTargetSP(list_AccIds);
            if(strSPTarget != ''){strMSG=strMSG+strSPTarget+'<br/>';}
        }else if(this.strBu == 'BQ')
        {
            String strSPTarget = this.checkHaveTargetSP(list_AccIds);
            if(strSPTarget != ''){strMSG=strMSG+strSPTarget+'<br/>';}
        }
        if(strMSG != '')
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO , strMSG);            
            ApexPages.addMessage(msg);
            return;
        }
		
	}
	//替换保存
	public PageReference replaceSave()
	{
		if(this.vAccTeamDate.V2_NewAccUser__c == null)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请填写新小组成员');            
            ApexPages.addMessage(msg);
            return null;
		}
		if(this.vAccTeamDate.EffectiveDate__c == null)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请填写生效日期');            
            ApexPages.addMessage(msg);
            return null;
		}
		if(this.vAccTeamDate.V2_AdjustReson__c == null)
		{
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请填写调整原因');            
            ApexPages.addMessage(msg);
            return null;
        }
        //检查所填写生效日期
        String strErrorMsg = this.checkEffectiveDate(this.vAccTeamDate.EffectiveDate__c , '替换');
        if(strErrorMsg != null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, strErrorMsg);            
            ApexPages.addMessage(msg);
            return null;
        }
        //检查新成员
        //若填写的新成员不是当前用户的下属
        if(!this.blnIsAdmin && !set_SubUserIds.contains(vAccTeamDate.V2_NewAccUser__c)){
            vAccTeamDate.V2_NewAccUser__c.addError('只能添加您自己的下属。') ;
            return null ;
        }
        //若填写的新成员已经在该医院下了
        //if(this.Map_SalesAccTeam.containsKey(vAccTeamDate.V2_User__c)){
        //    vAccTeamDate.V2_NewAccUser__c.addError('您选择用户已在该医院下了。') ;
        //    return null ;
        //}
        //检查同一产品是否有多人负责
        if(checkProduct()){
            //vAccTeamDate.V2_NewAccUser__c.addError('同一个产品不能有多人负责。') ;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '同一个产品不能有多人负责');            
            ApexPages.addMessage(msg);
            return null;
        }
        
        //替换销售医院关系，更新记录
        List<V2_Account_Team__c> list_vAccTeamUp = new List<V2_Account_Team__c>();
        List<ID> list_ApprovalIds = new List<ID>();
        for(AccTeamWrappar atw : list_AccountTeamW)
        {
            if(atw.blnSelected == true)
            {
                //list_SeletedAT.add(atw.vAccTeam);
                V2_Account_Team__c vat = atw.vAccTeam;
                if(vat.EffectiveDate__c >= vAccTeamDate.EffectiveDate__c){
	                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '新的生效日期必须大于原销售医院关系的生效日期。');            
	                ApexPages.addMessage(msg);
	                return null;
	            }
	            vat.V2_BatchOperate__c='替换';
	            vat.V2_ApprovalStatus__c='待审批';
	            vat.V2_NewAccUser__c=vAccTeamDate.V2_NewAccUser__c;
	            vat.NewEffDate__c = vAccTeamDate.EffectiveDate__c;
	            vat.V2_Effective_NewYear__c = String.valueOf(vAccTeamDate.EffectiveDate__c.year());
	            vat.V2_Effective_NewMonth__c = String.valueOf(vAccTeamDate.EffectiveDate__c.month());
	            vat.DeleteDate__c = vAccTeamDate.EffectiveDate__c.addDays(-1);
	            vat.V2_Delete_Year__c = String.valueOf(vat.DeleteDate__c.addMonths(1).year());
	            vat.V2_Delete_Month__c = String.valueOf(vat.DeleteDate__c.addMonths(1).month());
	            vat.V2_AdjustReson__c=vAccTeamDate.V2_AdjustReson__c;
	            //ApprovalId = objAccTeamDel.id;
	            //update objAccTeamDel;
	            list_vAccTeamUp.add(vat);
	            list_ApprovalIds.add(vat.Id);
            }
        }
        update list_vAccTeamUp;
        
        //提交审批
        if(list_ApprovalIds.size() > 0)
        {
        	List<Approval.ProcessSubmitRequest> listReq = new List<Approval.ProcessSubmitRequest>();
        	for(id accTemid : list_ApprovalIds){
        		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(accTemid);
                listReq.add(req);
        	}
            List<Approval.ProcessResult> result = Approval.process(listReq);
        }
        
        return doFinish() ;
	}
	
	//检查产品
	private boolean checkProduct(){
        if(vAccTeamDate.V2_NewAccUser__c == null){
            return false;
        }
        User u =[select V2_UserProduct__c from User where id=:vAccTeamDate.V2_NewAccUser__c];
        V2_Account_Team__c[] teams =[select v2_User__c,Id,
            V2_Account__c,V2_History__c,V2_UserProduct__c,UserProduct__c from V2_Account_Team__c 
            where V2_Account__c in: list_AccIds  and V2_History__c = false and V2_Is_Delete__c=false
            and UserProduct__c=: u.V2_UserProduct__c and V2_Delete_Month__c = null AND v2_User__c !=: vAccTeamUser.V2_User__c]; 
            system.debug(teams);
        if(teams.size() > 0){
            return true;
        }else{
            return false;
        }
    }
    //检查日期
	private String checkEffectiveDate(Date effDate , String strSelectedOperate)
	{
		if(strSelectedOperate == '替换'){
            if(effDate.day() != 1){
                return '替换操作，所填写的生效日期必须为自然月的第一天。' ;
            }
        }else if(strSelectedOperate == '删除'){
            if(effDate.day() != effDate.toStartOfMonth().addMonths(1).addDays(-1).day()){
                return '删除操作，失效日期必须为自然月的最后一天。';
            }
        }
        if(!this.blnIsAdmin){
            //判断所填写日期是否为当前月之前的月份
            if(effDate.year() < date.today().year() || (effDate < date.today() && effDate.month() != date.today().month())){//为当月之前的月份
                if(effDate.month() == date.today().addMonths(-1).month()){//当前月的前一月
                    if(date.today().day() > 15){//当前日期是否大于15
                        return '由于您需要调整上月销售医院关系，且本月已过15日，所以您不能在此进行操作，请线下通过BUD批准，并交由admin进行转代表操作。';
                    }else{
                        return null;
                    }
                }else{//历史月份
                    return '销售医院关系历史数据不可修改。';
                }
            }else{//为当月或者当月之后的月份
                if(date.today().day() > 25 && date.today().month() == effDate.month() && date.today().year() == effDate.year()){
                    return '每月25日之后若需要调整本月销售医院关系，需要线下通过BUD审批，并交由admin进行转代表操作。';
                }else{
                    return null;
                }
            }
        }else{
            return null;
        }
	}
	//删除保存
	public PageReference deleteSave()
	{
		
        if(this.vAccTeamDate.DeleteDate__c == null)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请填写失效日期');            
            ApexPages.addMessage(msg);
            return null;
        }
        if(this.vAccTeamDate.V2_AdjustReson__c == null)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请填写调整原因');            
            ApexPages.addMessage(msg);
            return null;
        }
        //检查所填写失效日期
        String strErrorMsg = this.checkEffectiveDate(this.vAccTeamDate.DeleteDate__c , '删除');
        if(strErrorMsg != null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, strErrorMsg);            
            ApexPages.addMessage(msg);
            return null;
        }
		//替换销售医院关系，更新记录
        List<V2_Account_Team__c> list_vAccTeamUp = new List<V2_Account_Team__c>();
        List<ID> list_ApprovalIds = new List<ID>();
        for(AccTeamWrappar atw : list_AccountTeamW)
        {
            if(atw.blnSelected == true)
            {
                //list_SeletedAT.add(atw.vAccTeam);
                V2_Account_Team__c vat = atw.vAccTeam;
                if(vat.EffectiveDate__c >= vAccTeamDate.DeleteDate__c){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '所填写的失效日期必须大于原销售医院关系的生效日期。');            
                    ApexPages.addMessage(msg);
                    return null;
                }
                vat.V2_BatchOperate__c='删除';
                vat.V2_ApprovalStatus__c='待审批';
                vat.DeleteDate__c = vAccTeamDate.DeleteDate__c;
	            vat.V2_Delete_Year__c = String.valueOf(vat.DeleteDate__c.addMonths(1).year());
	            vat.V2_Delete_Month__c = String.valueOf(vat.DeleteDate__c.addMonths(1).month());
	            vat.V2_AdjustReson__c=vAccTeamDate.V2_AdjustReson__c;
	            
                //ApprovalId = objAccTeamDel.id;
                //update objAccTeamDel;
                list_vAccTeamUp.add(vat);
                list_ApprovalIds.add(vat.Id);
            }
        }
        update list_vAccTeamUp;
        
        //提交审批
        if(list_ApprovalIds.size() > 0)
        {
            List<Approval.ProcessSubmitRequest> listReq = new List<Approval.ProcessSubmitRequest>();
            for(id accTemid : list_ApprovalIds){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(accTemid);
                listReq.add(req);
            }
            List<Approval.ProcessResult> result = Approval.process(listReq);
        }
		
		return doFinish() ;
	}
	public Pagereference doFinish()
    {
    	//Pagereference page = new Pagereference(Apexpages.currentPage().getUrl()) ;
    	//return page;
        Pagereference p =Page.V2_AccountTeamReplace;
        p.setRedirect(true);
        return p;       
    }
	//删除按钮
	public void doDelete()
	{
		//是否选择了要删除的医院
        List<V2_Account_Team__c> list_SeletedAT = new List<V2_Account_Team__c>();
        for(AccTeamWrappar atw : list_AccountTeamW)
        {
            if(atw.blnSelected == true)
            {
                list_SeletedAT.add(atw.vAccTeam);
            }
        }
        //若没有选择要替换的医院
        if(list_SeletedAT.size() == 0)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, '请选择医院');            
            ApexPages.addMessage(msg);
            return;
        }
        list_AccIds.clear();
        for(V2_Account_Team__c vat : list_SeletedAT){
            list_AccIds.add(vat.V2_Account__c);
        }
        String strMSG = '';
        if(this.strBu == 'PD')
        {
        	String strPDTarget = this.checkHaveSurvivingPPD(list_AccIds);
        	if(strPDTarget != ''){strMSG=strMSG+strPDTarget+'<br/>';}
        	String strPDNewP = this.checkHaveNewP(list_AccIds);
        	if(strPDNewP != ''){strMSG=strMSG+strPDNewP+'<br/>';}
        	String strPDSurviving = this.checkHaveSurvivingPD(list_AccIds);
        	if(strPDSurviving != ''){strMSG=strMSG+strPDSurviving+'<br/>';}
        	String strPDNewPT = this.checkHaveNewPatientTargetPD(list_AccIds);
        	if(strPDNewPT != ''){strMSG=strMSG+strPDNewPT+'<br/>';}
        }else if(this.strBu == 'IVT')
        {
        	String strIVTTarget = this.checkHaveTargetIVT(list_AccIds);
        	if(strIVTTarget != ''){strMSG=strMSG+strIVTTarget+'<br/>';}
        }else if(this.strBu == 'SP')
        {
            String strSPTarget = this.checkHaveTargetSP(list_AccIds);
            if(strSPTarget != ''){strMSG=strMSG+strSPTarget+'<br/>';}
        }
        if(strMSG != '')
        {
        	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, strMSG+'<br/>因此该销售医院关系不允许删除');            
            ApexPages.addMessage(msg);
            return;
        }
        this.blnIsSearch = false;
        this.blnIsDelete = true;
	}
	
	//IVT，医院是否有目标销量
    public String checkHaveTargetIVT(List<ID> list_HospitalId)
    {
    	List<SalesReport__c> list_IVTTargetHospital = [Select s.Id From SalesReport__c s Where s.Account__c in: list_HospitalId And GBU__c = 'MD' and SBU__c = 'IVT' and Time__c = THIS_YEAR and s.TargetQty__c > 0];
        if(list_IVTTargetHospital.size() > 0){
            return '所选医院有IVT医院指标存在';
        }else{
            return '';
        }
    }
    //SP,医院是否有目标销量
    public String checkHaveTargetSP(List<ID> list_HospitalId)
    {
        List<SalesReport__c> list_SPTargetHospital = [Select s.Id From SalesReport__c s Where s.Account__c in: list_HospitalId And GBU__c = 'MD' and SBU__c = 'SP' and Time__c = THIS_YEAR and s.TargetAmount__c > 0];
        if(list_SPTargetHospital.size() > 0){
            return '所选医院有SP医院指标存在';
        }else{
            return '';
        }
    }
    //PD,医院是否有指标、新病人、存活病人
    public String checkHaveSurvivingPPD(List<ID> list_HospitalId)
    {
        Date startDate = date.today().toStartOfMonth();
		Date endDate = startDate.addMonths(1).addDays(-1);
		List<PatientCaring__c> list_patientCaring = [Select Id From PatientCaring__c Where Account__c in: list_HospitalId And Surviving_This_Year__c > 0 And Time__c >=: startDate And Time__c <=: endDate];
		if(list_patientCaring.size() > 0){
		    return '所选医院PD当月有存活病人';
		}else{
		    return '';
		}
    }
    public String checkHaveNewPatientTargetPD(List<ID> list_HospitalId)
    {
        List<PatientCaring__c> list_PDTargetHospital = [Select Id From PatientCaring__c Where Account__c  in: list_HospitalId And Time__c = THIS_YEAR AND New_Patient_Target__c >0] ;
        if(list_PDTargetHospital.size() > 0){
            return '所选医院有PD新病人指标存在';
        }else{
            return '';
        }
    }
    public String checkHaveSurvivingPD(List<ID> list_HospitalId)
    {
        List<PatientCaring__c> list_PDTargetHospital = [Select Id From PatientCaring__c Where Account__c  in: list_HospitalId And Time__c = THIS_YEAR AND Surviving_Target__c > 0] ;
        if(list_PDTargetHospital.size() > 0){
            return '所选医院有PD存活病人指标存在';
        }else{
            return '';
        }
    }
    public String checkHaveNewP(List<ID> list_HospitalId)
    {
    	Date startDate = date.today().toStartOfMonth();
        Date endDate = startDate.addMonths(1).addDays(-1);
        List<PatientApply__c> list_PatientApply = [Select Id From PatientApply__c Where IntubationHospital__c in: list_HospitalId And CreatedDate >=: startDate And CreatedDate <=: endDate] ;
        if(list_PatientApply.size() > 0){
            return '该医院PD当月有新报病人';
        }else{
            return '';
        }
    }
    //返回按钮
    public void doCancel()
    {
        this.blnIsDelete = false ;
        this.blnIsReplace = false ;
        this.blnIsSearch = true ;
    }
	
	public class AccTeamWrappar{
		public Boolean blnSelected{get;set;}
		public V2_Account_Team__c vAccTeam{get;set;}
	}
	
	
	static testMethod void TestReplaceAccTeam()
	{
		//----------------New UserRole ------------------
        //List<UserRole> list_userRole = new List<UserRole >() ;
        UserRole objUserRole = new UserRole() ;
        objUserRole.Name = 'Renal-Rep-大上海-PD-Rep(陈喆令)' ;
        insert objUserRole ;
        UserRole objUserRole2 = new UserRole() ;
        objUserRole2.Name = 'Renal-Rep-大上海-PB-Rep(陈喆令)' ;
        objUserRole2.ParentRoleId = objUserRole.Id ;
        insert objUserRole2 ;
        //----------------Create User-------------
        List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
        List<User> list_User = new List<User>() ;
        User use1=new User();
        use1.Username='user2@123.com';
        use1.LastName='user2';
        use1.Email='user2@123.com';
        use1.Alias=user[0].Alias;
        use1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use1.ProfileId=user[0].ProfileId;
        use1.LocaleSidKey=user[0].LocaleSidKey;
        use1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use1.EmailEncodingKey=user[0].EmailEncodingKey;
        use1.CommunityNickname='chequ1';
        use1.MobilePhone='12345678912';
        use1.UserRoleId = objUserRole2.Id ;
        use1.IsActive = true;
        list_User.add(use1) ;
        User use2=new User();
        use2.Username='user2@223.com';
        use2.LastName='user2';
        use2.Email='user2@223.com';
        use2.Alias=user[0].Alias;
        use2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use2.ProfileId=user[0].ProfileId;
        use2.LocaleSidKey=user[0].LocaleSidKey;
        use2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use2.EmailEncodingKey=user[0].EmailEncodingKey;
        use2.CommunityNickname='chequ2';
        use2.UserRoleId = objUserRole2.Id ;
        use2.MobilePhone='22345678922';
        use2.IsActive = true;
        list_User.add(use2) ;
        User use3=new User();
        use3.Username='user2@323.com';
        use3.LastName='user2';
        use3.Email='user2@323.com';
        use3.Alias=user[0].Alias;
        use3.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use3.ProfileId=user[0].ProfileId;
        use3.LocaleSidKey=user[0].LocaleSidKey;
        use3.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use3.EmailEncodingKey=user[0].EmailEncodingKey;
        use3.CommunityNickname='chequ3';
        use3.MobilePhone='32345678932';
        use3.UserRoleId = objUserRole.Id ;
        use3.IsActive = true;
        list_User.add(use3) ;
        insert list_User ;
        use2.ManagerId = use3.Id ;
        update use2 ;
        //-----------------New Account----------------------
        List<Account> list_Account = new List<Account>() ;
        Account objAcc1 = new Account() ;
        objAcc1.Name = 'Acc1' ;
        objAcc1.MID__c = 'wefnlkn' ;
        list_Account.add(objAcc1) ;
        insert list_Account ;
        //-----------------New AccountTeamM---------------------
        List<AccountTeamMember> list_AccTM = new List<AccountTeamMember>() ;
        AccountTeamMember objATM1 = new AccountTeamMember() ;
        objATM1.UserId = use1.Id ;
        objATM1.AccountId = objAcc1.Id ;
        list_AccTM.add(objATM1) ;
        AccountTeamMember objATM2 = new AccountTeamMember() ;
        objATM2.UserId = use2.Id ;
        objATM2.AccountId = objAcc1.Id ;
        //list_AccTM.add(objATM2) ;
        insert list_AccTM ;
        //-----------------New Account Team-----------------
        List<V2_Account_Team__c> list_AT = New List<V2_Account_Team__c>() ;
        V2_Account_Team__c objAT1 = new V2_Account_Team__c() ;
        objAT1.V2_User__c = use1.Id ;
        objAT1.V2_Account__c = objAcc1.Id ;
        list_AT.add(objAT1) ;
        V2_Account_Team__c objAT2 = new V2_Account_Team__c() ;
        objAT2.V2_User__c = use2.Id ;
        objAT2.V2_Account__c = objAcc1.Id ;
        //list_AT.add(objAT2) ;
        insert list_AT ;
        
        system.test.startTest() ;
        system.runAs(use3)
        {
            BQ_CtrlAccountTeamReplace AccTRep = new BQ_CtrlAccountTeamReplace() ;
            AccTRep.searchAccountByUser();
            AccTRep.vAccTeamUser.V2_User__c = use1.Id;
            AccTRep.searchAccountByUser();
            AccTRep.doReplace();
            AccTRep.list_AccountTeamW[0].blnSelected = true;
            AccTRep.doReplace();
            AccTRep.replaceSave();
            AccTRep.vAccTeamDate.V2_NewAccUser__c = use2.Id;
            AccTRep.replaceSave();
            AccTRep.vAccTeamDate.EffectiveDate__c = date.today();
            AccTRep.replaceSave();
            AccTRep.vAccTeamDate.EffectiveDate__c = date.today().toStartOfMonth().addMonths(1);
            AccTRep.replaceSave();
            AccTRep.vAccTeamDate.V2_AdjustReson__c = 'ssss';
            AccTRep.replaceSave();
            AccTRep.doCancel();
            String s = AccTRep.checkHaveTargetIVT(new List<ID>());
            AccTRep.checkHaveTargetSP(new List<ID>());
            AccTRep.checkHaveSurvivingPPD(new List<ID>());
            AccTRep.checkHaveNewPatientTargetPD(new List<ID>());
            AccTRep.checkHaveSurvivingPD(new List<ID>());
            AccTRep.checkHaveNewP(new List<ID>());
            /*
            AccTRep.objV2AccTeam.V2_User__c = use1.Id ;
            AccTRep.screenAccount() ;
            AccTRep.list_AccWra[0].blnSelect = true ;
            AccTRep.doReplace() ;
            AccTRep.objV2AccTeamNew.V2_NewAccUser__c = use2.Id ;
            //AccTRep.objV2AccTeamNew. = use2.Id ;
            //AccTRep.objV2AccTeamNew.V2_User__c = use2.Id ;
            AccTRep.saveRepChange() ;
            AccTRep.doCancel();
            */
        }
        system.test.stopTest() ;
	}
	static testMethod void TestDeleteAccTeam()
    {
        //----------------New UserRole ------------------
        //List<UserRole> list_userRole = new List<UserRole >() ;
        UserRole objUserRole = new UserRole() ;
        objUserRole.Name = 'Renal-Rep-大上海-PD-Rep(陈喆令)' ;
        insert objUserRole ;
        UserRole objUserRole2 = new UserRole() ;
        objUserRole2.Name = 'Renal-Rep-大上海-PD-Rep(陈喆令)' ;
        objUserRole2.ParentRoleId = objUserRole.Id ;
        insert objUserRole2 ;
        //----------------Create User-------------
        List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
        List<User> list_User = new List<User>() ;
        User use1=new User();
        use1.Username='user2@123.com';
        use1.LastName='user2';
        use1.Email='user2@123.com';
        use1.Alias=user[0].Alias;
        use1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use1.ProfileId=user[0].ProfileId;
        use1.LocaleSidKey=user[0].LocaleSidKey;
        use1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use1.EmailEncodingKey=user[0].EmailEncodingKey;
        use1.CommunityNickname='chequ1';
        use1.MobilePhone='12345678912';
        use1.UserRoleId = objUserRole2.Id ;
        use1.IsActive = true;
        list_User.add(use1) ;
        User use2=new User();
        use2.Username='user2@223.com';
        use2.LastName='user2';
        use2.Email='user2@223.com';
        use2.Alias=user[0].Alias;
        use2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use2.ProfileId=user[0].ProfileId;
        use2.LocaleSidKey=user[0].LocaleSidKey;
        use2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use2.EmailEncodingKey=user[0].EmailEncodingKey;
        use2.CommunityNickname='chequ2';
        use2.UserRoleId = objUserRole2.Id ;
        use2.MobilePhone='22345678922';
        use2.IsActive = true;
        list_User.add(use2) ;
        User use3=new User();
        use3.Username='user2@323.com';
        use3.LastName='user2';
        use3.Email='user2@323.com';
        use3.Alias=user[0].Alias;
        use3.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use3.ProfileId=user[0].ProfileId;
        use3.LocaleSidKey=user[0].LocaleSidKey;
        use3.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use3.EmailEncodingKey=user[0].EmailEncodingKey;
        use3.CommunityNickname='chequ3';
        use3.MobilePhone='32345678932';
        use3.UserRoleId = objUserRole.Id ;
        use3.IsActive = true;
        list_User.add(use3) ;
        insert list_User ;
        use2.ManagerId = use3.Id ;
        update use2 ;
        //-----------------New Account----------------------
        List<Account> list_Account = new List<Account>() ;
        Account objAcc1 = new Account() ;
        objAcc1.Name = 'Acc1' ;
        objAcc1.MID__c = 'wefnlkn' ;
        list_Account.add(objAcc1) ;
        insert list_Account ;
        //-----------------New AccountTeamM---------------------
        List<AccountTeamMember> list_AccTM = new List<AccountTeamMember>() ;
        AccountTeamMember objATM1 = new AccountTeamMember() ;
        objATM1.UserId = use1.Id ;
        objATM1.AccountId = objAcc1.Id ;
        list_AccTM.add(objATM1) ;
        AccountTeamMember objATM2 = new AccountTeamMember() ;
        objATM2.UserId = use2.Id ;
        objATM2.AccountId = objAcc1.Id ;
        //list_AccTM.add(objATM2) ;
        insert list_AccTM ;
        //-----------------New Account Team-----------------
        List<V2_Account_Team__c> list_AT = New List<V2_Account_Team__c>() ;
        V2_Account_Team__c objAT1 = new V2_Account_Team__c() ;
        objAT1.V2_User__c = use1.Id ;
        objAT1.V2_Account__c = objAcc1.Id ;
        list_AT.add(objAT1) ;
        V2_Account_Team__c objAT2 = new V2_Account_Team__c() ;
        objAT2.V2_User__c = use2.Id ;
        objAT2.V2_Account__c = objAcc1.Id ;
        //list_AT.add(objAT2) ;
        insert list_AT ;
        
        system.test.startTest() ;
        system.runAs(use3)
        {
            BQ_CtrlAccountTeamReplace AccTRep = new BQ_CtrlAccountTeamReplace() ;
            AccTRep.searchAccountByUser();
            AccTRep.vAccTeamUser.V2_User__c = use1.Id;
            AccTRep.searchAccountByUser();
            AccTRep.doDelete();
            AccTRep.list_AccountTeamW[0].blnSelected = true;
            AccTRep.doDelete();
            //AccTRep.vAccTeamDate.V2_NewAccUser__c = use2.Id;
            AccTRep.deleteSave();
            AccTRep.vAccTeamDate.DeleteDate__c = date.today();
            AccTRep.deleteSave();
            AccTRep.vAccTeamDate.DeleteDate__c = date.today().toStartOfMonth().addMonths(1).addDays(-1);
            AccTRep.deleteSave();
            AccTRep.vAccTeamDate.V2_AdjustReson__c = 'ssss';
            AccTRep.deleteSave();
            AccTRep.doCancel();
            String s = AccTRep.checkHaveTargetIVT(new List<ID>());
            AccTRep.checkHaveTargetSP(new List<ID>());
            AccTRep.checkHaveSurvivingPPD(new List<ID>());
            AccTRep.checkHaveNewPatientTargetPD(new List<ID>());
            AccTRep.checkHaveSurvivingPD(new List<ID>());
            AccTRep.checkHaveNewP(new List<ID>());
            /*
            AccTRep.objV2AccTeam.V2_User__c = use1.Id ;
            AccTRep.screenAccount() ;
            AccTRep.list_AccWra[0].blnSelect = true ;
            AccTRep.doReplace() ;
            AccTRep.objV2AccTeamNew.V2_NewAccUser__c = use2.Id ;
            //AccTRep.objV2AccTeamNew. = use2.Id ;
            //AccTRep.objV2AccTeamNew.V2_User__c = use2.Id ;
            AccTRep.saveRepChange() ;
            AccTRep.doCancel();
            */
        }
        system.test.stopTest() ;
    }
	static testMethod void TestDeleteAccTeam2()
    {
        //----------------New UserRole ------------------
        //List<UserRole> list_userRole = new List<UserRole >() ;
        UserRole objUserRole = new UserRole() ;
        objUserRole.Name = 'Renal-Rep-大上海-PD-Supervier(陈喆令)' ;
        insert objUserRole ;
        UserRole objUserRole2 = new UserRole() ;
        objUserRole2.Name = 'Renal-Rep-大上海-PD-Rep(陈喆令)' ;
        objUserRole2.ParentRoleId = objUserRole.Id ;
        insert objUserRole2 ;
        //----------------Create User-------------
        List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
        Profile p = [Select id from Profile where Name like: '%Renal%' limit 1] ;
        List<User> list_User = new List<User>() ;
        User use1=new User();
        use1.Username='user2@123.com';
        use1.LastName='user2';
        use1.Email='user2@123.com';
        use1.Alias=user[0].Alias;
        use1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use1.ProfileId=user[0].ProfileId;
        use1.LocaleSidKey=user[0].LocaleSidKey;
        use1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use1.EmailEncodingKey=user[0].EmailEncodingKey;
        use1.CommunityNickname='chequ1';
        use1.MobilePhone='12345678912';
        use1.UserRoleId = objUserRole2.Id ;
        use1.IsActive = true;
        list_User.add(use1) ;
        User use2=new User();
        use2.Username='user2@223.com';
        use2.LastName='user2';
        use2.Email='user2@223.com';
        use2.Alias=user[0].Alias;
        use2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        //use2.ProfileId=user[0].ProfileId;
        use2.ProfileId=p.Id;
        use2.LocaleSidKey=user[0].LocaleSidKey;
        use2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use2.EmailEncodingKey=user[0].EmailEncodingKey;
        use2.CommunityNickname='chequ2';
        use2.UserRoleId = objUserRole2.Id ;
        use2.MobilePhone='22345678922';
        use2.IsActive = true;
        list_User.add(use2) ;
        User use3=new User();
        use3.Username='user2@323.com';
        use3.LastName='user2';
        use3.Email='user2@323.com';
        use3.Alias=user[0].Alias;
        use3.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use3.ProfileId=user[0].ProfileId;
        use3.LocaleSidKey=user[0].LocaleSidKey;
        use3.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use3.EmailEncodingKey=user[0].EmailEncodingKey;
        use3.CommunityNickname='chequ3';
        use3.MobilePhone='32345678932';
        use3.UserRoleId = objUserRole.Id ;
        use3.IsActive = true;
        list_User.add(use3) ;
        insert list_User ;
        use2.ManagerId = use3.Id ;
        update use2 ;
        //-----------------New Account----------------------
        List<Account> list_Account = new List<Account>() ;
        Account objAcc1 = new Account() ;
        objAcc1.Name = 'Acc1' ;
        objAcc1.MID__c = 'wefnlkn' ;
        list_Account.add(objAcc1) ;
        insert list_Account ;
        //-----------------New AccountTeamM---------------------
        List<AccountTeamMember> list_AccTM = new List<AccountTeamMember>() ;
        AccountTeamMember objATM1 = new AccountTeamMember() ;
        objATM1.UserId = use1.Id ;
        objATM1.AccountId = objAcc1.Id ;
        list_AccTM.add(objATM1) ;
        AccountTeamMember objATM2 = new AccountTeamMember() ;
        objATM2.UserId = use2.Id ;
        objATM2.AccountId = objAcc1.Id ;
        //list_AccTM.add(objATM2) ;
        insert list_AccTM ;
        //-----------------New Account Team-----------------
        List<V2_Account_Team__c> list_AT = New List<V2_Account_Team__c>() ;
        V2_Account_Team__c objAT1 = new V2_Account_Team__c() ;
        objAT1.V2_User__c = use1.Id ;
        objAT1.V2_Account__c = objAcc1.Id ;
        list_AT.add(objAT1) ;
        V2_Account_Team__c objAT2 = new V2_Account_Team__c() ;
        objAT2.V2_User__c = use2.Id ;
        objAT2.V2_Account__c = objAcc1.Id ;
        //list_AT.add(objAT2) ;
        insert list_AT ;
        
        system.test.startTest() ;
        system.runAs(use2)
        {
            BQ_CtrlAccountTeamReplace AccTRep = new BQ_CtrlAccountTeamReplace() ;
            AccTRep.searchAccountByUser();
            AccTRep.vAccTeamUser.V2_User__c = use1.Id;
            AccTRep.searchAccountByUser();
            AccTRep.doDelete();
           
            /*
            AccTRep.objV2AccTeam.V2_User__c = use1.Id ;
            AccTRep.screenAccount() ;
            AccTRep.list_AccWra[0].blnSelect = true ;
            AccTRep.doReplace() ;
            AccTRep.objV2AccTeamNew.V2_NewAccUser__c = use2.Id ;
            //AccTRep.objV2AccTeamNew. = use2.Id ;
            //AccTRep.objV2AccTeamNew.V2_User__c = use2.Id ;
            AccTRep.saveRepChange() ;
            AccTRep.doCancel();
            */
        }
        system.test.stopTest() ;
    }
	
	
	
	
	
}
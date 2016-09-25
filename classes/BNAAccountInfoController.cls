public with sharing class BNAAccountInfoController{
   public BNAHospitalInfo__c Info{get;set;}
    public String accountId;
    public BNAAccountInfoController(ApexPages.StandardController controller){
      Info=(BNAHospitalInfo__c )controller.getRecord();
      //判断是否新建还是编辑
      if(Info.id == null){
          if(Info.BNA_AccountId__c !=null){  
              Account acc = [select Grade__c,TotalBedsActual__c from Account where Id=:Info.BNA_AccountId__c];
              accountId=acc.Id;
              Info.BNA_AccountLevel__c = acc.Grade__c; 
              Info.BNA_BedNumber__c = acc.TotalBedsActual__c;
              List<IVSHospitalInfo__c> IVSList=[select id,LYHosSalesTotal__c from IVSHospitalInfo__c  where Account__c=:AccountId Order By Year__c Desc];
              if(IVSList.size()>0){
                 Info.BNA_TransfusionNumber__c = IVSList[0].LYHosSalesTotal__c;
              }
          } 
      }else{
        BNAHospitalInfo__c BNAEntity = [ Select b.Name, b.Id, b.BNA_UpdateTime__c, b.BNA_TransfusionNumber__c, b.BNA_SpecialHospital__c,
                                       b.BNA_PrimaryHospital__c, b.BNA_PIVASForm__c, BNA_ProductAndPrice__c,
                                       b.BNA_PIVASCoverage__c, b.BNA_NurseWork__c, b.BNA_IsPlan__c, b.BNA_IsPIVAS__c, 
                                       b.BNA_IsOfficeMobileSystem__c, b.BNA_IsMobileSystem__c, b.BNA_Hardware__c, 
                                       b.BNA_FromDep__c, b.BNA_Evaluate__c, b.BNA_EndemicNumber__c, 
                                       b.BNA_BuildMobileSystemForYear__c, b.BNA_Budget__c, b.BNA_BedNumber__c, 
                                       b.BNA_AllMobileSystem__c, b.BNA_AccountLevel__c, b.BNA_AccountId__c,
                                       b.OpportunityId__c ,BNA_OUVIAFromWhere__c,BNA_OUVIACoverage__c,
                                       BNA_ClinicTotleYear__c,BNA_ISOUVIA__c,BNA_Hardware_list__c,BNA_OUVAPlan__c From BNAHospitalInfo__c b where id =:Info.id];
        if(BNAEntity != null){
            Info=BNAEntity;
        }
      }
    }
    public Pagereference MySave()
    {
       if(Info!=null)
       {
          if(Info.BNA_SpecialHospital__c == null ){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'专科医院  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }
          if(Info.BNA_AccountLevel__c == null || Info.BNA_AccountLevel__c == ''){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'客户级别  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }
          if(Info.BNA_EndemicNumber__c == null){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'病区总数  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }
          if(Info.BNA_BedNumber__c == null ){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'床位数  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }
          if(Info.BNA_ClinicTotleYear__c == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'门急诊年输液总量  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }
          if(Info.BNA_TransfusionNumber__c == null ){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'住院部年输液总量  为必填字段');
              ApexPages.addMessage(msg);
              return null; 
          }
          if(Info.BNA_NurseWork__c == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'护士分工  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }

          if(Info.BNA_IsMobileSystem__c == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'是否有移动护理系统  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }

          if(Info.BNA_IsMobileSystem__c == '有' && Info.BNA_AllMobileSystem__c != NULL && Info.BNA_FromDep__c ==null){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'移动护理的预算出自哪个部门  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }else if(Info.BNA_IsMobileSystem__c == '有' && Info.BNA_AllMobileSystem__c == '否' && Info.BNA_Evaluate__c ==null){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'对目前系统评价  为必填字段');
              ApexPages.addMessage(msg);
              return null;
          }
          System.debug(Info.BNA_IsMobileSystem__c+'xx'+Info.BNA_AllMobileSystem__c+'xx:'+Info.BNA_Evaluate__c);
           upsert Info;
       }

       return new PageReference('/apex/BNA_AccountInfoView?id='+Info.id+'&sfdc.override=1' );
    }

    public void rfPagePIVAS(){
      if(Info.BNA_IsPIVAS__c == null)
       {
          Info.BNA_IsPlan__c=null;
          Info.BNA_PIVASCoverage__c=null;
          Info.BNA_PIVASForm__c=null;
       }
       else if(Info.BNA_IsPIVAS__c =='是')
       {
        Info.BNA_IsPlan__c=null;
       }else if(Info.BNA_IsPIVAS__c =='否'){
        Info.BNA_PIVASCoverage__c=null;
        Info.BNA_PIVASForm__c=null;
       }
    }
    public void rfPageOUVIA(){
      if(Info.BNA_ISOUVIA__c == '有'){
        Info.BNA_OUVAPlan__c = null;
      }else if(Info.BNA_ISOUVIA__c == '无'){
        Info.BNA_OUVIAFromWhere__c = NULL;
        Info.BNA_OUVIACoverage__c = NULL;
      }else{
        Info.BNA_OUVIAFromWhere__c = NULL;
        Info.BNA_OUVIACoverage__c = NULL;
        Info.BNA_OUVAPlan__c = null;
      }
    }
    public void IsMobile(){
      if(Info.BNA_IsMobileSystem__c=='有')
      {
        Info.BNA_BuildMobileSystemForYear__c =null;
      }else if(Info.BNA_IsMobileSystem__c=='无'){
        Info.BNA_AllMobileSystem__c = null;

        Info.BNA_FromDep__c = null;
        Info.BNA_Budget__c = null;

      }else{
        Info.BNA_BuildMobileSystemForYear__c =null;
        Info.BNA_AllMobileSystem__c = null;
        Info.BNA_FromDep__c = null;
        Info.BNA_Budget__c = null;
      }
    }
    public void AllMobile(){
      if(Info.BNA_AllMobileSystem__c == '是'){
        Info.BNA_IsOfficeMobileSystem__c = null;
        Info.BNA_Evaluate__c = null;
      }else if(Info.BNA_AllMobileSystem__c == '否'){
        Info.BNA_UpdateTime__c = null;
        Info.BNA_Hardware__c = null;
        Info.BNA_Hardware_list__c = null;
        Info.BNA_ProductAndPrice__c = null;

      }
    }
}
public with sharing class BNAAccountInfoViewController {
	public BNAHospitalInfo__c Info{get;set;}
    public BNAAccountInfoViewController(ApexPages.StandardController controller) {
    	Info=(BNAHospitalInfo__c )controller.getRecord();
    	if(Info.Id !=null){
    		BNAHospitalInfo__c BNAEntity = [ Select b.Name, b.Id, b.BNA_UpdateTime__c, b.BNA_TransfusionNumber__c, b.BNA_SpecialHospital__c,
                                       b.BNA_PrimaryHospital__c, b.BNA_PIVASForm__c, BNA_ProductAndPrice__c,
                                       b.BNA_PIVASCoverage__c, b.BNA_NurseWork__c, b.BNA_IsPlan__c, b.BNA_IsPIVAS__c, 
                                       b.BNA_IsOfficeMobileSystem__c, b.BNA_IsMobileSystem__c, b.BNA_Hardware__c, 
                                       b.BNA_FromDep__c, b.BNA_Evaluate__c, b.BNA_EndemicNumber__c, 
                                       b.BNA_BuildMobileSystemForYear__c, b.BNA_Budget__c, b.BNA_BedNumber__c, 
                                       b.BNA_AllMobileSystem__c, b.BNA_AccountLevel__c, b.BNA_AccountId__c,
                                       b.OpportunityId__c ,BNA_OUVIAFromWhere__c,BNA_OUVIACoverage__c,CreatedDate ,OwnerId,
                                       BNA_ClinicTotleYear__c,BNA_ISOUVIA__c,BNA_Hardware_list__c,BNA_OUVAPlan__c From BNAHospitalInfo__c b where id =:Info.id];
    		if(BNAEntity !=null){
    			Info = BNAEntity;
    		}
    	}
    }
}
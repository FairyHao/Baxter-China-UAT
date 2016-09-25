/*
Author:Dean
Date:2015-11-19
Function:急重症医疗保险政策查看界面控制类
 */
public with sharing class AcuteGAViewController {
	public Acute_GA__c acute{set;get;}
	public String acuteID{set;get;}
	public Boolean isAllowException{set;get;}

    public AcuteGAViewController(ApexPages.StandardController con) 
    {
        acuteID = con.getId(); 
    	acute = new Acute_GA__c();
    	acute = [select id,GA_Acute_City__c,GA_Acute_Exception__c,GA_Acute_ExpensePercent__c,
    	                GA_Acute_Price__c,GA_Acute_ProjectContect__c,GA_Acute_ProjectExpensePercent__c,
    	                GA_Acute_ProjectName__c,GA_Acute_SetBid__c,GA_Acute_Unit__c,
    	                GA_Acute_explain__c,Name,GA_Acute_StandardPrice__c,GA_Acute_Year__c from Acute_GA__c where id =:acuteID];  
    	getIsAllowException();  	
    }

   public void getIsAllowException()
    {
        if(acute.GA_Acute_Exception__c == null)
        {
            isAllowException = false;
            return ;
        }
    	if(	acute.GA_Acute_Exception__c.contains('管路')||
    		acute.GA_Acute_Exception__c.contains('滤器')||
    		acute.GA_Acute_Exception__c.contains('置换液')||
    		acute.GA_Acute_Exception__c.contains('透析液')||
    		acute.GA_Acute_Exception__c.contains('穿透针'))
    	{
    		isAllowException = true;
    	}
    	else{
    		isAllowException = false;
    	}
    }

    public PageReference back()
    {    	
		PageReference pageRef = new PageReference('/'+acute.GA_Acute_City__c);
		return pageRef;
    }


}
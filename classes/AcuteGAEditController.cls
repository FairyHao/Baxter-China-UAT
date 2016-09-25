/*
Author:Dean
Date:2015-11-19
Function:急重症医疗保险政策编辑界面控制类
 */
public with sharing class AcuteGAEditController {
	public Acute_GA__c acute{set;get;}
	
	public String acuteID{set;get;}
	public Boolean isAllowException{set;get;}

    public AcuteGAEditController(ApexPages.StandardController con) {
    	acuteID = con.getId();
        // acuteID = ApexPages.currentPage().getParameters().get('id');
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

    public PageReference save()
    {
    	calculate();
    	update acute;
    	PageReference page = new PageReference('/'+acute.id);
    	return page;
    }

      //计算得分
    public void calculate()
    {
    	//除外内容得分
        if(acute.GA_Acute_Exception__c == null)
        {
            acute.GA_Acute_ExceptionScore__c = null;
            return;
        }

    	if(acute.GA_Acute_Exception__c.contains('管路') || acute.GA_Acute_Exception__c.contains('滤器'))
    	{
    		acute.GA_Acute_ExceptionScore__c = 30;
    	}else{
    		acute.GA_Acute_ExceptionScore__c = 0;
    	}

    	//管路和滤器报销比例得分
    	if(acute.GA_Acute_ExpensePercent__c != null && acute.GA_Acute_ExpensePercent__c != 0.00)
    	{
    		acute.GA_Acute_ExpenseScore__c = 10;
    	}else{
    		acute.GA_Acute_ExpenseScore__c = 0;
    	}

    	//CRRT价格标准得分
    	if(acute.GA_Acute_Price__c != null && acute.GA_Acute_Price__c != 0.00)
    	{
    		acute.GA_Acute_CRRTPriceScore__c = 20;
    	}else{
    		acute.GA_Acute_CRRTPriceScore__c = 0;
    	}

    	//CRRT项目报销比例得分
    	if(acute.GA_Acute_ProjectExpensePercent__c != null && acute.GA_Acute_ProjectExpensePercent__c != 0.00)
    	{
    		acute.GA_Acute_CRRTProjectScore__c = 10;
    	}else{
    		acute.GA_Acute_CRRTProjectScore__c = 0;
    	}

    	//CRRT set招标得分
        if(acute.GA_Acute_SetBid__c == null)
        {
            acute.GA_Acute_BidScore__c = 0;
        }
    	if(acute.GA_Acute_SetBid__c == '中标')
    	{
    		acute.GA_Acute_BidScore__c = 30;
    	}
    	else if(acute.GA_Acute_SetBid__c == '备案')
    	{
			acute.GA_Acute_BidScore__c = 10;
    	}
    	else{
    		acute.GA_Acute_BidScore__c = 0;
    	}
        
    	
    }
}
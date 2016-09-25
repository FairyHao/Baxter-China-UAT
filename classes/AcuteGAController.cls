/*
Author:Dean
Date:2015-11-19
Function:急重症医疗保险政策新建界面控制类
 */
public with sharing class AcuteGAController {
	public Acute_GA__c acute{set;get;}
	public Acute_GA__c lastAcute{set;get;}
	public String cityID{set;get;}
	public Boolean isAllowException{set;get;}
    public String str{set;get;}//当前年份

    public AcuteGAController() {
    	cityID = ApexPages.currentPage().getParameters().get('id');
    	acute = new Acute_GA__c();
    	acute.GA_Acute_City__c = cityID;
    	getIsAllowException();
        getYear();
    }

    //点击复制，将上周期的数据复制至当前周期的页面中
    public void copyDate()
    {
    	lastAcute = new Acute_GA__c();
		List<Acute_GA__c> lastAcuteList = [select id,GA_Acute_City__c,GA_Acute_Exception__c,GA_Acute_ExpensePercent__c,
                                            GA_Acute_Price__c,GA_Acute_ProjectContect__c,GA_Acute_ProjectExpensePercent__c,
                                            GA_Acute_ProjectName__c,GA_Acute_SetBid__c,GA_Acute_Unit__c,
                                            GA_Acute_explain__c,Name,GA_Acute_StandardPrice__c,GA_Acute_Year__c
                                            from Acute_GA__c where GA_Acute_City__c =:cityID order by createdDate desc];
        if(lastAcuteList.size() == 0)
		{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, '未找到上周期数据' );
			ApexPages.addMessage(myMsg);
            Return;
		}

        lastAcute = lastAcuteList[0];
		acute = new Acute_GA__c();
		acute = lastAcute;
        acute.id = null;
    }

    public PageReference backToCity()
    {
    	PageReference page =new PageReference('/'+cityID);
    	return page;
    }

   
    public PageReference save()
    {
        if(!checkYear())
        {
            return null;
        }
    	calculate();
    	insert acute;
    	PageReference page = new PageReference('/'+acute.id);
    	return page;
    }

    public void getIsAllowException()
    {
        System.debug('--------acute.GA_Acute_Exception__c-----------'+acute);
        if(acute.GA_Acute_Exception__c == null)
        {
            isAllowException = false;
            return ;
        }
    	if(acute.GA_Acute_Exception__c.contains('管路')||
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

    public void getYear()
    {
        acute.GA_Acute_Year__c = (Date.today().month()>=7)?(Date.today().year()+'下半年'):(Date.today().year()+'上半年');
        str = acute.GA_Acute_Year__c;
    }

    public boolean checkYear()
    {
        List<Acute_GA__c> lastAcuteList = [select id,GA_Acute_Year__c from Acute_GA__c where GA_Acute_City__c =:cityID order by createdDate desc];
        if(lastAcuteList.size() == 0)
        {
            return true;
        }

        Acute_GA__c last = lastAcuteList[0];
        String CurrentTime = (Date.today().month()>=7)?(Date.today().year()+'下半年'):(Date.today().year()+'上半年');
        if(last.GA_Acute_Year__c == CurrentTime) 
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, '已存在当前时期的医疗保险政策了哦' );
            ApexPages.addMessage(myMsg);
            Return false;
        }
        return true;
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
    	if(acute.GA_Acute_ExpensePercent__c != null || acute.GA_Acute_ExpensePercent__c != 0.00)
    	{
    		acute.GA_Acute_ExpenseScore__c = 10;
    	}else{
    		acute.GA_Acute_ExpenseScore__c = 0;
    	}

    	//CRRT价格标准得分
    	if(acute.GA_Acute_Price__c != null || acute.GA_Acute_Price__c != 0.00)
    	{
    		acute.GA_Acute_CRRTPriceScore__c = 20;
    	}else{
    		acute.GA_Acute_CRRTPriceScore__c = 0;
    	}

    	//CRRT项目报销比例得分
    	if(acute.GA_Acute_ProjectExpensePercent__c != null || acute.GA_Acute_ProjectExpensePercent__c != 0.00)
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
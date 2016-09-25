public class BE_YearMonConmtController {
	public integer Year{get;set;}//获得要统计的年份
    public integer Month{get;set;}//获得要统计的年份
    public boolean IsView{get;set;}//页面布局设置
    public Boolean ButtonDisabled{get;set;}//‘开始汇总’按钮
    public BE_YearMonConmtController()//构造函数,初始化页面下拉列表
    {
    	IsView = true;
    	month = date.today().month();//默认当前月
    	Year = date.today().year();//默认当前年
    }
    public List<SelectOption> getListYears(){//分配‘年份’下拉列表
    list<SelectOption> options=new list<SelectOption>();
    	options.add(new SelectOption(String.valueOf(date.today().addYears(-3).year()),String.valueOf(date.today().addYears(-3).year())));
    	options.add(new SelectOption(String.valueOf(date.today().addYears(-2).year()),String.valueOf(date.today().addYears(-2).year())));
        options.add(new SelectOption(String.valueOf(date.today().addYears(-1).year()),String.valueOf(date.today().addYears(-1).year())));
        options.add(new SelectOption(String.valueOf(date.today().year()),String.valueOf(date.today().year())));
        options.add(new SelectOption(String.valueOf(date.today().addYears(1).year()),String.valueOf(date.today().addYears(1).year())));
        options.add(new SelectOption(String.valueOf(date.today().addYears(2).year()),String.valueOf(date.today().addYears(2).year())));
        options.add(new SelectOption(String.valueOf(date.today().addYears(3).year()),String.valueOf(date.today().addYears(3).year())));
        options.add(new SelectOption(String.valueOf(date.today().addYears(4).year()),String.valueOf(date.today().addYears(4).year())));
        options.add(new SelectOption(String.valueOf(date.today().addYears(5).year()),String.valueOf(date.today().addYears(5).year())));
        options.add(new SelectOption(String.valueOf(date.today().addYears(6).year()),String.valueOf(date.today().addYears(6).year())));
        options.add(new SelectOption(String.valueOf(date.today().addYears(7).year()),String.valueOf(date.today().addYears(7).year())));

        return options;
        }
    public List<SelectOption> getListMonths()//分配‘月份’下拉列表
    {
        list<SelectOption> options=new list<SelectOption>();
       // options.add(new SelectOption(String.valueOf(date.today().month()),String.valueOf(date.today().month()))); 
        //options.add(new SelectOption('1','1'));options.add(new SelectOption('2','2'));        
        options.add(new SelectOption('1','1'));options.add(new SelectOption('2','2'));
        options.add(new SelectOption('3','3'));options.add(new SelectOption('4','4'));
        options.add(new SelectOption('5','5'));options.add(new SelectOption('6','6'));
        options.add(new SelectOption('7','7'));options.add(new SelectOption('8','8'));
        options.add(new SelectOption('9','9'));options.add(new SelectOption('10','10'));
        options.add(new SelectOption('11','11'));options.add(new SelectOption('12','12'));
        return options;
    }

    public void BeginComputationBonus()//按钮出发函数,调用Batch开始统计
    {
    	BE_BiosStatisticsBatch attBatch = new BE_BiosStatisticsBatch();
    	attBatch.year = Year;
    	attBatch.month = Month;
    	IsView = false;
        database.executeBatch(attBatch,1);
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM , 'BIOS日程汇总开始执行，完成后邮件通知您') ;            
        ApexPages.addMessage(msg);
    }
/******************测试函数**********************/
   static testMethod void myUnitTest() {   
        system.Test.startTest();
		BE_YearMonConmtController bey = new BE_YearMonConmtController();
		bey.BeginComputationBonus();
		bey.getListMonths();
		bey.getListYears();
        system.Test.stopTest();
    }
 /******************测试函数**********************/    
}
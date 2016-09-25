/**
 * Author : Dean 
 * date : 2013-10-15 
 * 设计Batch每月执行 
 **/
public class BE_BiosStatisticsSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
    	BE_BiosStatisticsBatch attBatch = new BE_BiosStatisticsBatch();
        database.executeBatch(attBatch,1);
    }
    
	static testMethod void myUnitTest() {		
        system.test.startTest();
        string sch=DateTime.now().second()+' '+DateTime.now().minute()+' '+DateTime.now().hour()+' * * ?';
        BE_BiosStatisticsSchedule att = new BE_BiosStatisticsSchedule();
        System.schedule('test', sch , att);
        system.test.stopTest();
	}
}
/*********************************
 *Spring 20141202
 *********************************/
public  class AcuteAndHDSalesSchedule implements Schedulable{
	public void execute(SchedulableContext sc) {
    	AcuteAndHDSalesBatch attBatch = new AcuteAndHDSalesBatch();
        database.executeBatch(attBatch,50);
    }
}
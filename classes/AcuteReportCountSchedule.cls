/*******************************
 *Spring(张阳)
 *2015-6-1 儿童节
 *acute拜访汇总，
 ******************************/
public  class  AcuteReportCountSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
    	Integer year = System.today().year();
    	Integer month = System.today().month();
    	AcuteReportCount attBatch = new AcuteReportCount(year,month);
    	database.executeBatch(attBatch,180);
    }
}
public class AcuteAccountLevelSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
    	AcuteAccountLevelBatch c = new AcuteAccountLevelBatch ();
    	Database.executeBatch(c, 100);
    }
}
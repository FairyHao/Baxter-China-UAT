/**
 * Schedulable AttachmentUpLoadBatch
 * 
 */
public class AttachmentUpLoadSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
    	AttachmentUpLoadBatch attBatch = new AttachmentUpLoadBatch();
        database.executeBatch(attBatch);
    }
    
	static testMethod void myUnitTest() {		
        system.test.startTest();
        string sch=DateTime.now().second()+' '+DateTime.now().minute()+' '+DateTime.now().hour()+' * * ?';
        AttachmentUpLoadSchedule att = new AttachmentUpLoadSchedule();
        System.schedule('test', sch , att);
        system.test.stopTest();
	}
}
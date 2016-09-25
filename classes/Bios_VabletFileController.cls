public with sharing class Bios_VabletFileController {
    public List<vabletFileClass> vabletFileList{get;set;}
    public Integer index;
    public Bios_VabletFileController(ApexPages.StandardController controller) {
        index = 0;
        vabletFileList = new List<vabletFileClass>();
        String eventId = controller.getId();
        String userId = UserInfo.getProfileId();
        Profile p = [select name from Profile where id =:userId][0];
        List<Event> eventList = [select BiosContactLevel__c from Event where id=:eventId ];
        String biosContactLevel = '';
        String bName = '';
        //判断简档
        if(p.Name.toUpperCase().contains('BIOS')){
            bName = 'BIOS';
        }else if(p.Name.toUpperCase().contains('CRRT')){
            bName = 'CRRT';
        }else if(p.Name.toUpperCase().contains('HD')){
            bName = 'HD';
        }else if(p.Name.toUpperCase().contains('IVT')){
            bName = 'IVT';
        }else if(p.Name.toUpperCase().contains('MD')){
            bName = 'MD';
        }else if(p.Name.toUpperCase().contains('Renal')){
            bName = 'Renal';
        }else if(p.Name.toUpperCase().contains('系统管理员') || p.Name.toUpperCase().contains('ADMINISTRATOR') ){
            bName = '系统管理员';
        }else{
            bName = '';
        }
        System.debug('bName:'+bName);
        if(eventList.size() != 0){
            biosContactLevel = (eventList.get(0)).BiosContactLevel__c;
        }
        if(biosContactLevel == null || biosContactLevel == ''){
            return;
        }
        Map<String,Vab_ContactToVabletFile__c> vabletFileMap = Vab_ContactToVabletFile__c.getAll();
        List<Vab_ContactToVabletFile__c> vabletSet = vabletFileMap.values();
        integer i = 0;
        for(Vab_ContactToVabletFile__c obj : vabletSet){
            if(obj.Vab_ContactContactLevel__c != null && obj.Vab_ContactContactLevel__c != '' && obj.Vab_ContactContactLevel__c.toUpperCase() == biosContactLevel.toUpperCase() && (bName == '系统管理员' || bName == obj.Vab_BUType__c)){
                i++;
                vabletFileClass cc = new vabletFileClass();
                cc.index = i;
                cc.vab = obj;
                vabletFileList.add(cc);
            }
        }
    }

    public class vabletFileClass{
        public Integer index{get;set;}
        public Vab_ContactToVabletFile__c vab{get;set;}
    }
}
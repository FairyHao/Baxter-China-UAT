/*
*Amy
*2015/4/20
*功能：1.批量翻译不良事件的后台类
      2.批量删除不良事件的后台类
*/
public with sharing class AdverseEventTranslationController {
    public PMO_AdverseEvent__c event{get;set;}
    public Boolean IsDisable{get;set;}
    
    public String deleteType{get;set;}//删除类型。
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('CreatedDate','导入日期'));
        options.add(new SelectOption('Translation_InlandDate_zh__c','国内接收日期'));
        return options;
    }
    
    public AdverseEventTranslationController() {
        event=new PMO_AdverseEvent__c();
    }
    //翻译按钮调用
    public void Translation()
    {
        if(Event.PMO_Date_of_Birth_zh__c==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'请选择日期'));
            //event.PMO_Date_of_Birth_zh__c.adderror('fafds');
        }
        else if(Event.PMO_Date_of_Birth_zh__c>Date.today())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'请输入正确的导入日期'));
        }
        else
        {

            System.debug(Event.PMO_Date_of_Birth_zh__c+'******');
            System.debug(Event.PMO_Date_of_administration_zh__c+'&&&&&&&&&&&&&&');
            //将
            List<BaxterImportedDrugLibraryAndTranslation__c>  BaxterImportedDrugLibraryList=[select id,Translation_English__c,Translation_Name_zh__c,International_Tradename__c from BaxterImportedDrugLibraryAndTranslation__c where RecordType.developername='BaxterImportedDrugLibrary'];//百特药物库
            Set<String> International_Tradename_Set = new Set<String>();
            for(BaxterImportedDrugLibraryAndTranslation__c drug:BaxterImportedDrugLibraryList)
            {
                if(drug.International_Tradename__c!=null&&drug.International_Tradename__c!='')
                {
                    International_Tradename_Set.add(drug.International_Tradename__c);
                }
            }
            //---start----modify 2016-7-5 by Mike 用户做不良事件翻译时候，若是记录超过50000 可能会出错
            Integer num = 0;
            List<PMO_AdverseEvent__c> pmoAE_list = new List<PMO_AdverseEvent__c>();
            pmoAE_list = [select Id from PMO_AdverseEvent__c where DAY_ONLY(CreatedDate)=:Event.PMO_Date_of_Birth_zh__c and Translation_EventSerious__c = 'Serious' and Translation_CountryofDetection__c!='CHINA' and RecordType.DeveloperName='global' and Translation_InternationalTradename__c in:International_Tradename_Set limit 5000];
            if(!pmoAE_list.isEmpty()){
                num = pmoAE_list.size();
            }
            //Integer num=(Integer)[select count(id) countnum from PMO_AdverseEvent__c where DAY_ONLY(CreatedDate)=:Event.PMO_Date_of_Birth_zh__c and Translation_EventSerious__c = 'Serious' and Translation_CountryofDetection__c!='CHINA' and RecordType.DeveloperName='global' and Translation_InternationalTradename__c in:International_Tradename_Set].get(0).get('countnum');
            //---end-------------------
            System.debug(num+'num***');
            if(num<=0) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'所选日期没有需要翻译的不良事件，请确定导入日期是否正确'));
            }
            else if(0<num&&num<2000)
            {
                AdverseEventTranslationBatch batch=new AdverseEventTranslationBatch(Event.PMO_Date_of_Birth_zh__c,Event.PMO_Date_of_administration_zh__c,'Trans');
                List<PMO_AdverseEvent__c> tempList=batch.TransList([Select p.ranslation_CaseSerious__c,p.Translation_VersionNo__c, p.Translation_UsageAndDosage_zh__c, p.Translation_UnitDoseUnit__c,p.Translation_PtName__c,p.Translation_UnitDoseQty__c,p.Translation_Translated__c, p.Translation_StartTherapyDate_zh__c,p.Translation_StartTherapyDate__c, p.Translation_Sex__c, p.Translation_Set_zh__c,p.Translation_Seq__c, p.Translation_RouteAdministration__c, p.Translation_Remark_zh__c, p.Translation_ProductFlag__c, p.Translation_PrimarySOCName__c,p.Translation_PTIndication_zh__c, p.Translation_PTIndication__c,p.Translation_ManufacturerName__c, p.Translation_MadeBy__c,p.Translation_LLTName_zh__c, p.Translation_LLTName__c,p.Translation_InternationalTradename__c, p.Translation_InlandDate_zh__c, p.Translation_InitialOrTraceReport_zh__c, p.Translation_Frequency__c,p.Translation_FrequencyTime__c, p.Translation_FrequencyTimeUnit__c, p.Translation_Filtered__c, p.Translation_EventSerious__c,p.Translation_EventOutcome_zh__c, p.Translation_EventOutcome__c, p.Translation_EndTherapyDate_zh__c, p.Translation_EndTherapyDate__c,p.Translation_DetailType__c, p.Translation_CountryofDetection__c, p.Translation_CaseOutcome__c,p.Translation_CaseOnsetDate__c, p.Translation_CaseLevelExpectedness__c, p.Translation_AllSources_zh__c, p.Translation_Age_zh__c, p.Translation_Age__c, p.Translation_AgeUnit__c, p.Translation_AerNo_zh__c, p.Translation_AerNo__c, p.Translation_AeOnsetDate_zh__c, p.Translation_AeOnsetDate__c, p.Translation_AeCessationDate__c,p.CreatedDate,p.Translation_AllSources__c From PMO_AdverseEvent__c p
                where DAY_ONLY(CreatedDate)=:Event.PMO_Date_of_Birth_zh__c  and RecordType.DeveloperName='global' order by Translation_AerNo__c]);
                update tempList;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'您在'+Event.PMO_Date_of_Birth_zh__c.format()+'导入且需要翻译的'+num+'条不良事件已翻译完成，请进入系统查看！'));
                IsDisable=true;
            }else
            {
                System.debug(Event.PMO_Date_of_Birth_zh__c+'******');
                System.debug(Event.PMO_Date_of_administration_zh__c+'&&&&&&&&&&&&&&');
                AdverseEventTranslationBatch batch=new AdverseEventTranslationBatch(Event.PMO_Date_of_Birth_zh__c,Event.PMO_Date_of_administration_zh__c,'Trans');
                Database.executeBatch(batch,2000);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'因数据量较大，系统在后台执行翻译，结束后会给您发送邮件，请您稍等一段时间再去查看！'));
                IsDisable=true;
            }
        }
    }
    //删除按钮调用
    public void Del()
    {
        if(event.PMO_Date_of_Birth_zh__c==null||event.PMO_Date_of_administration_zh__c==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'请选择日期'));
        }
        else
        {
            System.debug('deleteType: '+deleteType);
            System.debug(Event.PMO_Date_of_Birth_zh__c+'******');
            System.debug(Event.PMO_Date_of_administration_zh__c+'&&&&&&&&&&&&&&');
            //---start----modify 2016-7-5 by Mike 用户做不良事件翻译删除时候，若是记录超过50000 可能会出错
            Integer num = 0;
            List<PMO_AdverseEvent__c> pmoAE_list = new List<PMO_AdverseEvent__c>();
            if(deleteType=='Translation_InlandDate_zh__c')
            {
                pmoAE_list = [select Id from PMO_AdverseEvent__c where Translation_InlandDate_zh__c>=:event.PMO_Date_of_Birth_zh__c and Translation_InlandDate_zh__c<=:event.PMO_Date_of_administration_zh__c and  RecordType.DeveloperName='global' limit 10000];
                //num=(Integer)[select count(id) countnum from PMO_AdverseEvent__c where Translation_InlandDate_zh__c>=:event.PMO_Date_of_Birth_zh__c and Translation_InlandDate_zh__c<=:event.PMO_Date_of_administration_zh__c and  RecordType.DeveloperName='global'].get(0).get('countnum');
                
            }else if(deleteType=='CreatedDate')
            {
                pmoAE_list = [select Id from PMO_AdverseEvent__c where DAY_ONLY(CreatedDate)>=:event.PMO_Date_of_Birth_zh__c and DAY_ONLY(CreatedDate)<=:event.PMO_Date_of_administration_zh__c and  RecordType.DeveloperName='global' limit 10000];
                //num=(Integer)[select count(id) countnum from PMO_AdverseEvent__c where DAY_ONLY(CreatedDate)>=:event.PMO_Date_of_Birth_zh__c and DAY_ONLY(CreatedDate)<=:event.PMO_Date_of_administration_zh__c and  RecordType.DeveloperName='global'].get(0).get('countnum');
            }
            if(!pmoAE_list.isEmpty()){
                num = pmoAE_list.size();
            }
            //---end-------------------
            
            if(num<=0)
            {   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'所选日期没有数据。'));
            }else if(num>0&&num<9000)
            {
                if(deleteType=='CreatedDate')
                {
                    delete [select id from PMO_AdverseEvent__c where DAY_ONLY(CreatedDate)>=:event.PMO_Date_of_Birth_zh__c and DAY_ONLY(CreatedDate)<=:event.PMO_Date_of_administration_zh__c and  RecordType.DeveloperName='global'];
                }else if(deleteType=='Translation_InlandDate_zh__c')
                {
                    delete [select id from PMO_AdverseEvent__c where Translation_InlandDate_zh__c>=:event.PMO_Date_of_Birth_zh__c and Translation_InlandDate_zh__c<=:event.PMO_Date_of_administration_zh__c and  RecordType.DeveloperName='global'];
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'共'+num+'条数据被删除。'));
                 IsDisable=true;
            }
            else
            {
                System.debug(deleteType+'Del'+'**********');
                AdverseEventTranslationBatch batch=new AdverseEventTranslationBatch(Event.PMO_Date_of_Birth_zh__c,Event.PMO_Date_of_administration_zh__c,deleteType+'Del');
                Database.executeBatch(batch,20);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'共'+num+'条数据需要删除，因数据量大，系统在后台运行，结束后会给您发送邮件，请您稍等一段时间再去查看！'));
                IsDisable=true;
            }
        }
    }
}
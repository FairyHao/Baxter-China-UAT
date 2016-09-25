/*
*Amy
*2015/4/20
*功能：1.批量翻译不良事件
        a.找到满足条件的不良事件
        b.同一个AerNo，处理冲突
      2.批量删除不良事件
*/
global class AdverseEventTranslationBatch implements Database.Batchable<sObject>,Database.Stateful {
    Private Date AcceptDate1;//删除的开始时间
    Private Date AcceptDate2;//删除的结束时间
    Private Map<String,String> TranslationMap=new Map<String,String>();//存放中英文对照。
    private String Type;//类型，有两种Trans和Del，Trans批量翻译，Del批量删除
    private List<PMO_AdverseEvent__c> SameAerNoList=new List<PMO_AdverseEvent__c>();//一个编号的不良事件list，为了处理冲突事件。
    private List<BaxterImportedDrugLibraryAndTranslation__c> BaxterImportedDrugLibraryList;//百特药物库。
    private Integer DelNum=0;//删除条数 
    private Integer AllNum=0;//筛选出的需要翻译的总数

    global AdverseEventTranslationBatch(Date AcceptDate1,Date AcceptDate2,String Type) {
        this.AcceptDate2=AcceptDate2;
        this.AcceptDate1=AcceptDate1;
        this.Type=Type;
        System.debug(AcceptDate1+'AcceptDate1');
        System.debug(AcceptDate2+'AcceptDate2');
        System.debug(Type+'Type*****');
        if(type=='Trans')
        {
            //翻译库翻译
            List<BaxterImportedDrugLibraryAndTranslation__c> TranslationList=[select id,Translation_English__c,Translation_Name_zh__c from BaxterImportedDrugLibraryAndTranslation__c where RecordType.developername='Translation_Dictionary'];//翻译库
            for(BaxterImportedDrugLibraryAndTranslation__c trans:TranslationList)
            {
               TranslationMap.put(trans.Translation_English__c.tolowercase(),trans.Translation_Name_zh__c);
            }
            BaxterImportedDrugLibraryList=[select id,Translation_English__c,Translation_Name_zh__c,International_Tradename__c from BaxterImportedDrugLibraryAndTranslation__c where RecordType.developername='BaxterImportedDrugLibrary'];//百特药物库
        } 
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(type=='Trans'&&AcceptDate1!=null)
        {
            System.debug('***************');
            return Database.getQueryLocator('Select p.ranslation_CaseSerious__c,p.Translation_VersionNo__c, p.Translation_UsageAndDosage_zh__c, p.Translation_UnitDoseUnit__c,p.Translation_PtName__c,p.Translation_UnitDoseQty__c,p.Translation_Translated__c, p.Translation_StartTherapyDate_zh__c,p.Translation_StartTherapyDate__c, p.Translation_Sex__c, p.Translation_Set_zh__c,p.Translation_Seq__c, p.Translation_RouteAdministration__c, p.Translation_Remark_zh__c, p.Translation_ProductFlag__c, p.Translation_PrimarySOCName__c,p.Translation_PTIndication_zh__c, p.Translation_PTIndication__c,p.Translation_ManufacturerName__c, p.Translation_MadeBy__c,p.Translation_LLTName_zh__c, p.Translation_LLTName__c,p.Translation_InternationalTradename__c, p.Translation_InlandDate_zh__c, p.Translation_InitialOrTraceReport_zh__c, p.Translation_Frequency__c,p.Translation_FrequencyTime__c, p.Translation_FrequencyTimeUnit__c, p.Translation_Filtered__c, p.Translation_EventSerious__c,p.Translation_EventOutcome_zh__c, p.Translation_EventOutcome__c, p.Translation_EndTherapyDate_zh__c, p.Translation_EndTherapyDate__c,p.Translation_DetailType__c, p.Translation_CountryofDetection__c, p.Translation_CaseOutcome__c,p.Translation_CaseOnsetDate__c, p.Translation_CaseLevelExpectedness__c, p.Translation_AllSources_zh__c, p.Translation_Age_zh__c, p.Translation_Age__c, p.Translation_AgeUnit__c, p.Translation_AerNo_zh__c, p.Translation_AerNo__c, p.Translation_AeOnsetDate_zh__c, p.Translation_AeOnsetDate__c, p.Translation_AeCessationDate__c,p.CreatedDate,p.Translation_AllSources__c,p.PMO_Frequency_en__c From PMO_AdverseEvent__c p'+
        ' where DAY_ONLY(CreatedDate)=:AcceptDate1 and RecordType.DeveloperName=\'global\' order by Translation_AerNo__c');
        }else if(type=='CreatedDateDel'&&AcceptDate1!=null&&AcceptDate2!=null)
        {
            return Database.getQueryLocator('select id from PMO_AdverseEvent__c where  DAY_ONLY(CreatedDate)>=:AcceptDate1 and DAY_ONLY(CreatedDate)<=:AcceptDate2 and  RecordType.DeveloperName=\'global\'');
        }else if(type=='Translation_InlandDate_zh__cDel'&&AcceptDate1!=null&&AcceptDate2!=null)
        {
            return Database.getQueryLocator('select id from PMO_AdverseEvent__c where Translation_InlandDate_zh__c>=:AcceptDate1 and Translation_InlandDate_zh__c<=:AcceptDate2 and  RecordType.DeveloperName=\'global\'');
        }
        else
        {
            System.debug('&&&&&&');
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        if(type=='Trans')
        {
            scope=TransList(scope);
            update scope;
           // TransNum+=TransEventList.size();
            AllNum+=scope.size();
          // System.debug(scope+'scope*****');
        }else if(type.contains('Del'))
        {
            delete scope;
            DelNum+=scope.size();
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        //发送邮件。
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String repBody = '';
        repBody += '您好: <br><br>';
        if(type=='Trans')
        {     
            repBody+=' 您在'+AcceptDate1.format()+'导入的不良事件共'+AllNum+'条，现已翻译完成，请进入系统查看。<br><br>';
            mail.setSubject('不良事件批量翻译完成');
        }else if(type=='CreatedDateDel')
        {
            repBody+='从'+AcceptDate1.format()+'至'+AcceptDate2.format()+'导入的不良事件已删除，请进入系统查看。此次删除共涉及'+DelNum+'条数据。<br><br>';
            mail.setSubject('不良事件批量删除完成');
        }else if(type=='Translation_InlandDate_zh__cDel')
        {
            repBody+='从'+AcceptDate1.format()+'至'+AcceptDate2.format()+'接收的不良事件已删除，请进入系统查看。此次删除共涉及'+DelNum+'条数据。<br><br>';
            mail.setSubject('不良事件批量删除完成');
        }
        repBody+='祝您工作愉快!<br><br>';
        repBody+='<div style="width:100%;border-bottom:1px solid #000"></div>';
        repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。<br>'; 
        repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>'; 
        mail.setToAddresses(new String[]{UserInfo.getUserEmail()});
        mail.setHtmlBody(repBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    //翻译逻辑封装。参数为需要处理的不良事件List，返回需要更新至系统的list数据，
    public List<PMO_AdverseEvent__c>  TransList(List<PMO_AdverseEvent__c> scope)
    {
        Map<Id,PMO_AdverseEvent__c> TempMap=new Map<Id,PMO_AdverseEvent__c>();
        List<PMO_AdverseEvent__c> TransEventList=new List<PMO_AdverseEvent__c>();//待翻译的AderseEvent
        List<PMO_AdverseEvent__c> ConflictList=new List<PMO_AdverseEvent__c>();//冲突list

        //找到待翻译的不良事件。
        for(PMO_AdverseEvent__c event:(list<PMO_AdverseEvent__c>)scope)
        {   
            TempMap.put(event.id,event);
            for(BaxterImportedDrugLibraryAndTranslation__c lib:BaxterImportedDrugLibraryList)
            {
                //比较剂型和规格，若是和产品品规匹配才翻译。这些条件不在start方法里写的原因：1.因为每条数据都需要处理国内接收日期和是否已筛选2.这样统计的数据也是所有今日导入的数据的总数
                if(Event.Translation_InternationalTradename__c==lib.International_Tradename__c &&  'Serious'.equalsIgnoreCase(Event.Translation_EventSerious__c) &&  (!'CHINA'.equalsIgnoreCase(Event.Translation_CountryofDetection__c)))
                {   
                    TransEventList.add(Event);
                    break;
                }
            }
                event.Translation_Filtered__c=true;
                event.Translation_InlandDate_zh__c=AcceptDate2;
            }

            //System.debug(SameAerNoList+'SameAerNoList*******');
            for(Integer i=0;i<TransEventList.size();i++)
            {
                //需要处理冲突的情况：1.i＝0，和上次batch里的list的最后一个比较不相等2.i>0，和i－1的编号不相等。
                if((SameAerNoList.size()>0&&TransEventList[i].Translation_AerNo__c!=SameAerNoList[SameAerNoList.size()-1].Translation_AerNo__c))
                {
                    //处理上一个AerNo的冲突标记
                    ConflictList.addAll(ConflictMark());//处理冲突标记
                    SameAerNoList.clear();
                } 
                SameAerNoList.add(TransEventList[i]);
                //翻译
                TransEventList[i]=Translation(TransEventList[i]);
            }
            //每次都处理下冲突数据。为了防止最后一批数据冲突未处理
            ConflictList.addAll(ConflictMark());

            for(PMO_AdverseEvent__c event:TransEventList)
            {
                TempMap.put(event.Id,event);//将event覆盖为翻译后的event，而没有翻译的event还是原来的event
            }
            //将冲突处理放至list中。
            for(PMO_AdverseEvent__c event:ConflictList)
            {
                if(TempMap.get(event.id)==null)
                {
                    TempMap.put(event.id,event);
                }else
                {
                   event= TempMap.get(Event.id);
                   event.IsConflictData__c=true;
                   TempMap.put(Event.id,event);
                }
            }
            
            List<PMO_AdverseEvent__c> tempList=new List<PMO_AdverseEvent__c>();
            for(ID id:TempMap.keySet())
            {
                tempList.add(TempMap.get(id));
            }
            return tempList;
    }

    //处理相同AerNo的冲突标记
    private List<PMO_AdverseEvent__c> ConflictMark()
    {
        List<PMO_AdverseEvent__c> ConflictList=new List<PMO_AdverseEvent__c>();//冲突List
        Boolean flag1=false;
        Boolean flag2=false;
        for(PMO_AdverseEvent__c event:SameAerNoList)
        {
            if(event.Translation_EventSerious__c=='Serious')
            {
                flag1=true;
            }
            if(event.ranslation_CaseSerious__c=='Non-Serious')
            {
                flag2=true;
            }
        }

        if(flag1&&flag2)
        {
            for(PMO_AdverseEvent__c event:SameAerNoList)
            {
                event.IsConflictData__c=true;
                ConflictList.add(event);
            }
        }
        return ConflictList;
    }

    PMO_AdverseEvent__c tempAE=new PMO_AdverseEvent__c();//中间变量，为了给是否未翻译赋值。
    //翻译逻辑
    private PMO_AdverseEvent__c Translation(PMO_AdverseEvent__c event)
    {
        tempAE=new PMO_AdverseEvent__c();
        Event.Translation_AerNo_zh__c=event.Translation_AerNo__c;
        Event.Translation_CountryofDetection_zh__c=EnglishToChineseTrans(Event.Translation_CountryofDetection__c);
        Event.Translation_Age_zh__c = this.translateQuantity(String.valueof(Integer.valueof(Event.Translation_Age__c)), Event.Translation_AgeUnit__c);
        Event.Translation_Set_zh__c=EnglishToChineseTrans(Event.Translation_Sex__c);
        Event.PMO_Frequency_zh__c = this.translateFrequency(Event);
        Event.Translation_UsageAndDosage_zh__c= this.translateQuantity(Event.Translation_UnitDoseQty__c, Event.Translation_UnitDoseUnit__c)  +'；'+Event.PMO_Frequency_zh__c+'；'+EnglishToChineseTrans(Event.Translation_RouteAdministration__c);
        Event.Translation_StartTherapyDate_zh__c=(Event.Translation_StartTherapyDate__c==null||Event.Translation_StartTherapyDate__c=='Unkown'?'1900-01-01':Event.Translation_StartTherapyDate__c);
        Event.Translation_EndTherapyDate_zh__c=(Event.Translation_EndTherapyDate__c==null||Event.Translation_EndTherapyDate__c=='Unkown'?'1900-01-01':Event.Translation_EndTherapyDate__c);
        Event.Translation_PTIndication_zh__c=EnglishToChineseTrans(Event.Translation_PTIndication__c);
        Event.Translation_LLTName_zh__c=EnglishToChineseTrans(Event.Translation_PtName__c);
        Event.Translation_AeOnsetDate_zh__c=(Event.Translation_AeOnsetDate__c==null||Event.Translation_AeOnsetDate__c=='Unkown'?'1900-01-01':Event.Translation_AeOnsetDate__c);
        Event.Translation_EventOutcome_zh__c=EnglishToChineseTrans(Event.Translation_EventOutcome__c);
        Event.Translation_AllSources_zh__c=EnglishToChineseTrans(Event.Translation_AllSources__c);
        if(Event.Translation_AllSources__c!=null&&Event.Translation_AllSources__c.contains('Health authority'))
        {
            Event.Translation_Remark_zh__c='本报告来源于监管机构';
        }
        Event.Translation_InitialOrTraceReport_zh__c=(Event.Translation_VersionNo__c==0?'初始报告':'跟踪报告');
        Event.Translation_Translated__c=true;
        Event.NotTranslation__c = tempAE.NotTranslation__c;
        return Event;
    }
    
    private String translateFrequency(PMO_AdverseEvent__c pae)
    {
        // Translation_FrequencyTime__c
        // Translation_FrequencyTimeUnit__c
        // Translation_Frequency__c
        // case 1 timeunit 为 'as required', 'bedtime', 'Cyclical' 三个值的任意一个值时，翻译为 timeunit + frequency
        // case 2 timeunit 为'Once'，翻译为'一次'
        // case 3 time, timeunit 不为空，Frequency 为空，翻译为 time+timeunit
        // case 4 time,timeunit,Frequency不为空，time+timeunit+Frequency
        // case 5 其他情况，翻译为 不详

        String FrequencyTimeUnit = EnglishToChineseTrans(pae.Translation_FrequencyTimeUnit__c);
       
        if('as required'.equalsIgnoreCase(pae.Translation_FrequencyTimeUnit__c) || 'bedtime'.equalsIgnoreCase(pae.Translation_FrequencyTimeUnit__c)|| 'Cyclical'.equalsIgnoreCase(pae.Translation_FrequencyTimeUnit__c )|| 'continuous'.equalsIgnoreCase(pae.Translation_FrequencyTimeUnit__c))
        { // case 2
            return FrequencyTimeUnit + (pae.Translation_Frequency__c==null?'':(pae.Translation_Frequency__c+'次'));
        }else if('Once'.equalsIgnoreCase(pae.Translation_FrequencyTimeUnit__c))
        {
            return '1次';
        }else if(pae.Translation_FrequencyTimeUnit__c!=null&&pae.Translation_FrequencyTime__c!=null)
        {
            return '每'+pae.Translation_FrequencyTime__c + FrequencyTimeUnit + (pae.Translation_Frequency__c==null?'':pae.Translation_Frequency__c+'次');
        }else if(pae.Translation_FrequencyTimeUnit__c==null&&pae.Translation_FrequencyTime__c==null&&pae.Translation_Frequency__c!=null)
        {
            return pae.Translation_Frequency__c+'次';
        }
        else
        {
            return '不详';
        }
    }
    
    private String translateQuantity(String quantityField, String unitField)
    {
        // 如果quantity为空，翻译为'不详'
        // 如果quantity不为空，unit为空，翻译为quantity + '(单位)'
        // 如果quantity不为空，unit不为空，翻译为quantity + unit

        if(quantityField == null || quantityField == '')
        {
            return '不详';
        }
        else if(unitField == null || unitField == '')
        {
            return quantityField + '(单位)';
        }
        else 
        {   
            return quantityField + EnglishToChineseTrans(unitField);
        }
    }

    private String EnglishToChineseTrans(String EnglishName)
    {
        String ChineseName='';
        if(EnglishName!=null&&EnglishName!='')
        {
            ChineseName=((TranslationMap.get(EnglishName.toLowerCase()))==null?EnglishName:(TranslationMap.get(EnglishName.toLowerCase())));
            if((TranslationMap.get(EnglishName.toLowerCase()))==null)
            {
               tempAE.NotTranslation__c = true; 
            }
        }else
        {
            ChineseName='不详';
        }
        return ChineseName;
    } 
}
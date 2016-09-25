/* 
 * Author: Sunny
 * Created on: 2012-1-6
 * Description: 
 * 2012-2-14 Sunny 添加奖金数据
 * 2013-4-11 Sunny 修改奖金数据，添加销售数据
 * 2013-12-18 Sunny 修改新病人筛选条件<CSR通过>--><通过>
 */
public class BQ_CtrlMonthlyPlanReport 
{
    private String strMonthlyId ;
    private ID ManagerId ;
    public boolean blnFirstShow{get;set;} 
    public boolean blnBiosShow{get;set;}
    public boolean blnRenalShow{get;set;}
    public boolean blnMDShow{get;set;}
    public boolean blnBonusShow{get;set;}
    public User objUser{get;set;}
    public Integer intExpireSum{get;set;}
    public V2_UserBonusInFo__c objUserBonus{get;set;}
    private List<Opportunity> baseOppList=null;
    public List<NewPatientCondition> newPatentConditionList{get;set;} //新病人情况
    public List<OpportunityState> oppStaList{get;set;}  //业务机会阶段情况
    private Map<ID,Contact> map_EvIdContact = new Map<ID,Contact>() ;
    private Map<ID,Event> map_EveId = new Map<ID,Event>() ;
    private Map<ID,Contact> map_conId = new Map<ID,Contact>() ;
    private Map<String,Integer> map_Grade = new Map<String,Integer>();
    private Map<String,Integer> map_CampaignCount = new Map<String,Integer>() ;
    private List<MonthlyPlanDetail__c> list_MonthlyDetail = new List<MonthlyPlanDetail__c>() ;
    private Map<String,String> map_BonusInfoField = new Map<String,String>() ;//字段map
    //2013-4-11 sunny add
    public List<SalesReport> list_salesReport{get;set;}
    public List<newBonusData> list_BonusData{get;set;}
    public List<newBonusData> list_HaveHospitalBonusData{get;set;}
    private String strPG ;
    private Boolean IsRep ;
    private Boolean IsPDASM = false;
    public Boolean HaveHospital {get;set;}
    public Boolean SPshow{get;set;}
    public String strDashboard{get;set;}
    public String strDashboardRate{get;set;}
    
    public String strErrorMessage{get;set;}
    public List<String> list_RenalField{
        get{
            list_RenalField = new List<String>() ;
            list_RenalField.add('V2_RenalTargetContact__c') ;
            list_RenalField.add('V2_RenalFinishedEvent__c') ;
            list_RenalField.add('V2_RenalVisitPlan__c') ;
            list_RenalField.add('V2_RenalExecuteResult__c') ;
            list_RenalField.add('V2_RenalOppQuantity__c') ;
            list_RenalField.add('V2_RenalEventFinished__c') ;
            list_RenalField.add('V2_RenalCallEventFinished__c') ;
            
            return list_RenalField ;
        }
        set;
    }
    public List<String> list_RenalField2{
        get{
            list_RenalField2 = new List<String>() ;
            
            list_RenalField2.add('V2_RenalSalesAverage__c') ;
            list_RenalField2.add('V2_RenalAssistanceCall__c') ;
            list_RenalField2.add('V2_RenalAssistanceComments__c') ;
            list_RenalField2.add('V2_RenalMPComments__c') ;
            list_RenalField2.add('V2_BonusScore__c') ;
            return list_RenalField2 ;
        }
        set;
    }
    public List<String> list_MDField{
        get{
            list_MDField = new List<String>() ;
            list_MDField.add('V2_MdKAFrequency__c') ;
            list_MDField.add('V2_MdCallFinished__c') ;
            list_MDField.add('V2_MdOppCall__c') ;
            list_MDField.add('V2_MdCallQuantity__c') ;
            list_MDField.add('V2_MdCallScore__c') ;
            list_MDField.add('V2_MdDepartmentVisit__c') ;
            list_MDField.add('V2_MdPotentialAnalysis__c') ;
            list_MDField.add('V2_MdTargetAccSet__c') ;
            return list_MDField ; 
        }
        set;
    }
    public List<String> list_MDField2{
        get{
            list_MDField2 = new List<String>() ;
            
            
            list_MDField2.add('V2_MdOpp__c') ;
            list_MDField2.add('V2_MdCampaignInvitation__c') ;
            list_MDField2.add('V2_MdCampaignFollowEvent__c') ;
            list_MDField2.add('V2_MdSalesAverage__c') ;
            list_MDField2.add('V2_MdAssistanceFrequency__c') ;
            list_MDField2.add('V2_MdAssistanceQuality__c') ;
            list_MDField2.add('V2_BonusScore__c') ;
            return list_MDField2 ; 
        }
        set;
    }
    public List<String> list_BiosField{
        get{
            list_BiosField = new List<String>() ;
            list_BiosField.add('V2_BiosTargetContactCoverage__c') ;
            list_BiosField.add('V2_BiosTargetContactCall__c') ;
            list_BiosField.add('V2_BiosCallOnTime__c') ;
            list_BiosField.add('V2_BiosCallFinished__c') ;
            list_BiosField.add('V2_BiosSubmitWeekplanOnTime__c') ;
            list_BiosField.add('V2_BiosDepartmentVisit__c') ;
            list_BiosField.add('V2_BiosGenTai__c') ;
            list_BiosField.add('V2_BiosTeamCallPlanExecution__c') ;
            
            return list_BiosField ;
        }
        set;
    }
    public List<String> list_BiosField2{
        get{
            list_BiosField2 = new List<String>() ;
            
            list_BiosField2.add('V2_BiosAssistanceExecution__c') ;
            list_BiosField2.add('V2_BiosDepartmentVisitDepartmentVisit__c') ;
            list_BiosField2.add('V2_BiosCampaignExecution__c') ;
            list_BiosField2.add('V2_BiosTargetContactCoverage__c') ;
            list_BiosField2.add('V2_BiosKOLCoverage__c') ;
            list_BiosField2.add('V2_BonusScore__c') ;
            return list_BiosField2 ;
        }
        set;
    }
    public Boolean blnErrorShow{get;set;}
    public MonthlyPlan__c objMonthlyPlan{get;set;}
    public Integer realPassNum {get;set;} //月计划中实际通过数
    private String[] renalStageList = new String[]{'(S0)尚未开始','(S1)列名文件准备和沟通过','(S2)临床主任递交申请','(S3)临时采购','(S4)药事委员会批准','(S5)正式采购','客户合作失败'};
    private String[] closeRenalStageList = new String[]{'(S5)正式采购','客户合作失败'};
    private String[] mdStageList = new String[]{'需求分析','发现机会','建立渠道','业务谈判','产品使用','基本量完成'};//,'关闭'
    private String[] closeBiosStageList = new String[]{'产品使用','关闭','基本量完成'};
    private String[] biosStageList = new String[]{'需求分析','发现/验证机会','建立沟通渠道'
        ,'提交合作方案/谈判','跟进合作方案','业务谈判'};//
    private String[] closeMDStageList = new String[]{'签约/缔结(成功)','客户合作失败','休眠'};
    static final String cs='4F82BE,C1504D,8EAB51,8164A3,33CC33,006699,996600,CCCC66,FF6633,99FF33,66BE45,TT33FF,33FF33,009900,FF00FF'
                +',333399,009999,9933FF,FFFF00,9999CC,CC0099,336633,0033FF,006666,669999,FFFF33,EE4566,DD2288,CC9900,33FFCC,0099CC'
                +',999933,0088cc,859400,C344F9,FF4433,CC33CC,4F5C00,99FFEE,FFFF44,CCCC11,9900FF,77FF77,88CFFC,00AB34,55FF12,44FC90';
    public static final List<String> colors=cs.split(',');
    public BQ_CtrlMonthlyPlanReport()
    {
        strDashboard='0';
        blnBiosShow = false ;
        blnRenalShow = false ;
        blnMDShow = false ;
        blnFirstShow = false ;
        SPshow=false;
        strMonthlyId = ApexPages.currentPage().getParameters().get('monId');
        system.debug('!!!~'+strMonthlyId) ;
        objMonthlyPlan = [select Id, Name,Year__c,Month__c,Summit__c,PatientTarget__c,V2_TotalCallRecords__c,V2_FinishedCallRecords__c,
                TotalCallRecords__c,FinishedPlannedCallRecords__c,Percent__c,Approval__c,
                FinishedUnPlannedCallRecords__c,FinishedCallRecords__c,Target__c,Owner.Name,Owner.UserRoleId,
                //2013-12-18 sunny 修改新病人提交的筛选条件由CSR通过 --> 通过
                (Select Id, Status__c From PatientApply__r where Status__c=:'CSR通过' or Status__c=:'通过'),
                (Select Id,Hospital__r.name,Subject__c,No_of_Participants__c,Problem_Resolved__c,Problems_not_Resolved__c,Next_Step__c From Department_Visit__r),
                execution_summary__c,supervisor_comment__c,ownerId from MonthlyPlan__c where Id =: strMonthlyId] ;
        //objUser = [Select id,CommunityNickname,(Select Renal_valid_super__c,PG__c From E2ik__r Where Year__c =: objMonthlyPlan.Year__c And Month__c =: objMonthlyPlan.Month__c) From User Where Id =: objMonthlyPlan.OwnerId] ;
        
        List<PatientApply__c> patientApList = objMonthlyPlan.PatientApply__r;  
        objUser = [Select u.ManagerId, u.UserRole.Name, u.CommunityNickname, u.V2_UserProduct__c, u.UserRoleId ,(Select Level__c,Renal_valid_super__c,PG__c From E2ik__r Where Year__c =: objMonthlyPlan.Year__c And Month__c =: objMonthlyPlan.Month__c) From User u Where Id =: objMonthlyPlan.OwnerId] ;
        if(objUser.UserRole.Name != null)
        {
            if(objUser.UserRole.Name.toUpperCase().contains('BQ') || objUser.UserRole.Name.contains('BQ'))
            {
                blnRenalShow = true ;
                blnFirstShow = true ;
                //2013-4-11 sunny add
                strPG = objUser.V2_UserProduct__c ;
                if(objUser.E2ik__r.size() > 0){
                    if(objUser.E2ik__r[0].Level__c.toUpperCase().contains('REP')){
                        IsRep=true;
                    }else{
                        IsRep =false;
                    }
                }else if(objUser.UserRole.Name.toUpperCase().contains('REP')){
                    IsRep=true;
                }else{
                    IsRep =false;
                }
                if(objUser.E2ik__r.size() > 0){
                    HaveHospital = objUser.E2ik__r[0].Renal_valid_super__c ;
                }
            }else if(objUser.UserRole.Name.toUpperCase().contains('BIOS') || objUser.UserRole.Name.contains('bios') || objUser.UserRole.Name.contains('bio') || objUser.UserRole.Name.contains('Bio') || objUser.UserRole.Name.contains('BIOS'))
            {
                blnBiosShow = true ;
                
            }else if(objUser.UserRole.Name.toUpperCase().contains('MD') || objUser.UserRole.Name.contains('md') || objUser.UserRole.Name.contains('Md'))
            {
                blnMDShow = true ;
                blnFirstShow = true ;
                strPG = objUser.V2_UserProduct__c ; 
                if(objUser.E2ik__r.size() > 0){
                    if(objUser.E2ik__r[0].Level__c.toUpperCase().contains('REP')){
                        IsRep=true;
                    }else{
                        IsRep =false;
                    }
                }else if(objUser.UserRole.Name.toUpperCase().contains('REP')){
                    IsRep=true;
                }else{
                    IsRep =false;
                }
                if(objUser.E2ik__r.size() > 0){
                    system.debug(' SSSSS PPPPP '+objUser.E2ik__r[0].PG__c);
                    if(objUser.E2ik__r[0].PG__c!=null && objUser.E2ik__r[0].PG__c.toUpperCase() == 'SP'){
                        system.debug('In SP');
                        SPshow=true;
                    }
                }
            }
        }
        
        ManagerId = objUser.ManagerId ;//当前用户经理的ID
        realPassNum = patientApList.size();  //取月计划中实际通过数 作为（新病人数）
        //初始化Event & Contact 
        this.InitMonthlyDetail() ;
        this.InitEventContact() ;
        this.getNewPatientCondition();
        this.getOpportunityState();//业务机会情况
        //2013-4-15 sunny renal和md部门将使用新的奖金数据，bios照旧
        if(blnBiosShow == true){
            this.userBonusInFo() ;
        }else{
            this.getBonusData();
            system.debug('{{{{{{{}}}}}'+list_HaveHospitalBonusData);
        }
        //2013-4-15 sunny SP部门展示销售数据
        if(SPshow == true){
            this.SalesReportByMonth();
        }
    }
    //-----------------------2013-4-11 sunny 添加--------------------------------------
    public class SalesReport{
        public Decimal dblTarget{get;set;}
        public Decimal dblActual{get;set;}
        public Decimal dblRate{get;set;}
        public String strRate{get;set;}
    }
    
    public void SalesReportByMonth(){
        list_salesReport = new List<SalesReport>() ;
        if(objMonthlyPlan != null && objMonthlyPlan.Year__c != null){
            Map<Integer , List<SalesReport__c>> map_salesReport = ClsStatisticsSalesReport.GetSalesReports(objMonthlyPlan.Year__c , objMonthlyPlan.Owner.UserRoleId , objMonthlyPlan.OwnerId);
            for(Integer i = 1 ; i<=12 ; i++){
                SalesReport sr = new SalesReport();
                if(map_salesReport.containsKey(i)){
                    sr.dblTarget = 0 ;
                    sr.dblActual = 0 ;
                    for(SalesReport__c objSR : map_salesReport.get(i)){
                        sr.dblTarget += (objSR.TargetAmount__c==null?0:objSR.TargetAmount__c);
                        sr.dblActual += (objSR.ActualAmount__c==null?0:objSR.ActualAmount__c);
                    }
                    sr.dblTarget = sr.dblTarget.setScale(2,system.RoundingMode.HALF_UP) ;
                    sr.dblActual = sr.dblActual.setScale(2,system.RoundingMode.HALF_UP) ;
                    if(sr.dblTarget != 0){
                        sr.dblRate = sr.dblActual/sr.dblTarget;
                    } 
                    if(sr.dblRate != null){
                        sr.dblRate = sr.dblRate*100;
                        sr.dblRate = sr.dblRate.setScale(2,system.RoundingMode.HALF_UP) ;
                        sr.strRate = sr.dblRate+'%';
                    }
                }
                list_salesReport.add(sr);
            }
        }
        this.SetTotalSalesReport();
    }
    private void SetTotalSalesReport(){
        //总计
        SalesReport srTotal = new SalesReport();
        srTotal.dblTarget = 0 ;
        srTotal.dblActual = 0 ;
        for(SalesReport sr : list_salesReport){
            srTotal.dblTarget = (srTotal.dblTarget==null?0:srTotal.dblTarget) + (sr.dblTarget==null?0:sr.dblTarget) ;
            srTotal.dblActual = (srTotal.dblActual==null?0:srTotal.dblActual) + (sr.dblActual==null?0:sr.dblActual) ;
        }
        srTotal.dblTarget = srTotal.dblTarget.setScale(2,system.RoundingMode.HALF_UP) ;
        srTotal.dblActual = srTotal.dblActual.setScale(2,system.RoundingMode.HALF_UP) ;
        if(srTotal.dblTarget != null && srTotal.dblTarget != 0){
            srTotal.dblRate = srTotal.dblActual / srTotal.dblTarget ;
        }
        if(srTotal.dblRate != null){
            srTotal.dblRate = srTotal.dblRate*100;
            srTotal.dblRate = srTotal.dblRate.setScale(2,system.RoundingMode.HALF_UP) ;
            srTotal.strRate = srTotal.dblRate+'%';
            strDashboardRate = srTotal.strRate;
        }
        list_salesReport.add(srTotal);
        //总计的仪表板
        if(srTotal.dblRate != null){
            Decimal d = srTotal.dblRate ;
            d = d/100;
            d = d.setScale(1,system.RoundingMode.HALF_UP) ;
            d = d * 100 ;
            d = d.setScale(0,system.RoundingMode.HALF_UP);
            
            strDashboard = string.valueOf(d);
            //strDashboard = '!URLFOR($Resource.Dashboard,\'Dashboard/'+strDashboard+'.jpg\')' ; 
        }
    }
    
    public class newBonusData{
        public String strKpiName{get{
            if(strKpiName != null){
                strKpiName = wrapLineinner(strKpiName , 6);
            }
            return strKpiName;
        }set;}
        /******************bill 2013/5/6 update begin*************************/
        public String decKpiValue{get{
            //if(decKpiValue != null){
            //  decKpiValue = decKpiValue.setScale(1,system.RoundingMode.HALF_UP) ;
            //}
            return decKpiValue;
        }set;}
        /******************bill 2013/5/6 update end*************************/
        public newBonusData(){}
        public newBonusData(String kpiname ){
            strKpiName = kpiname;
        }
        public String wrapLineinner(String oldStr, Integer chartNum)
        {
            if(oldStr!=null) //Brave add (If)
            {
                Integer flag = 0;
                String retStr = '';
                List<String> lineList = oldStr.split('\n');
                for(Integer i=0;i<lineList.size(); i++){
                        String lineStr = lineList[i];
                        while(lineStr.length() > chartNum){
                                 retStr += lineStr.substring(0,chartNum) + '<br/>';
                                 lineStr = lineStr.substring(chartNum);
                        }
                        if(lineStr.length() > 0){
                                 retStr += lineStr + '<br/>';
                        }
                }
                return retStr;
            }else
            {
                return '';
            }
        }
    }
    private void getBonusData(){
        list_BonusData = new List<newBonusData>();
        
        if(strPG != null){
            List<Bonus_data__c> list_bData = [Select b.Year__c, b.X3WhyRateValue__c, b.Visit_quantity__c, b.Visit_quantity_Target__c, b.Visit_quality_score__c, 
                 b.Visit_Visit_Total_Quantity__c, b.Visit_Visit_Quantity__c, b.VisitScoreValue__c, b.VisitScoreTotal__c, b.VisitScoreNum__c, b.VisitRateValue__c, 
                 b.VisitQuantityValue__c, b.VisitPlanRateValue__c, b.VisitNumRate__c, b.VisitNumRate_Per__c, b.Total_Score__c, b.The_User__c, b.Target_Contact_Rate__c, 
                 b.Target_Contact_Rate_Per__c, b.Target_Contact_Number__c, b.Target_Contact_Number_Target__c, b.TargetContactNumberValue__c, b.SystemModstamp, 
                 b.SuperValue__c, b.SP_Hospital_Number__c, b.SEP_average__c, b.SEPTotalValue__c, b.SEPTeamNum__c, b.SEPAverageValue__c, b.RecordTypeId, 
                 b.Rate_Before_Visit__c, b.Rate_Before_Visit_Per__c, b.Plan_Visit__c, b.Persons_Number__c, b.OwnerId, b.OpportunityNumberValue__c, 
                 b.OppVisitRateValue__c, b.OppNumRate__c, b.OppNumRate_Per__c, b.OppEventRateValue__c, b.OppETotalScore__c, b.OppENum__c, b.OppELevelTwoTotalScore__c, 
                 b.OppELevelTwoNum__c, b.Name, b.Monthly_Plan_Reviews_Rate__c, b.Monthly_Plan_Reviews_Rate_Per__c, b.Monthly_Plan_Reviews_Number__c, 
                 b.MonthlyPlanReviewsRateValue__c, b.Month__c, b.LastModifiedDate, b.LastModifiedById, b.Key_Transfer_Rate_3Why__c, b.Key_Transfer_Rate_3Why_Per__c, 
                 b.Key_Customer_Visit_Quantity__c, b.Key_3Why_Visit__c, b.Key_3Why_VisitNum__c, b.KeyCustomerVisitValue__c, b.KeyCustomerVisitTarget__c, 
                 b.KeyCustomerVisitRate__c, b.KeyCustomerVisitRate_Per__c, b.IsHaveHospital__c, b.IsDeleted, b.Id, b.Hospital_Target__c, b.H_analysis_rate__c, 
                 b.H_analysis_rate_Per__c, b.HAnalysisRateValue__c, b.ExternalID__c, b.Department_number__c, b.Department_Number_Target__c, b.DepartmentQuarterValue__c, 
                 b.DepartmentNumberValue__c, b.DepartmentNumberRate__c, b.DepartmentNumberRate_Per__c, b.DD_Pharmacy_Visit_Target__c, b.DD_Pharmacy_Visit_Rate__c, 
                 b.DD_Pharmacy_Visit_Rate_Per__c, b.DD_Pharmacy_Visit_Number__c, b.DDPharmacyVisitRateValue__c, b.CreatedDate, b.CreatedById, b.ComputeDate__c, 
                 b.Completed_Unexpired_Visit_Quantity__c, b.CampaignFollow__c, b.Call_Completion_Rate__c, b.Call_Completion_Rate_Per__c, b.Business_Visit_Rate_Achieved__c, 
                 b.Business_Visit_Rate_Achieved_Target__c, b.Business_Visit_Rate_Achieved_Per__c, b.Business_Visit_Rate_Achieved_Completed__c, b.Business_Strategy_Score__c, 
                 b.Business_Strategy_Quality_Two__c, b.Business_Score_Reviews_Total__c, b.Business_Score_Reviews_Rate__c, b.Business_Score_Reviews_Rate_Per__c, 
                 b.Business_Score_Reviews_Completed__c, b.Business_Opportunities__c, b.Business_Opportunities_Target__c, b.Business_Events_Target__c, 
                 b.Business_Events_Rate__c, b.Business_Events_Rate_Per__c, b.Business_Events_Number__c, b.BusinessStrategyScoreValue__c, 
                 b.BusinessStrategyQualityTwoValue__c, b.BusinessScoreReviewsRateValue__c, b.Before_Visit__c, b.Before_VisitSum__c, b.Assist_quality_two__c, 
                 b.AssVisitTotalScore__c, b.AssVisitNumberValue__c, b.AssVisitNum__c, b.AssVisitNumRate__c, b.AssVisitNumRate_Per__c, b.AssVisitLevelTwoValue__c, 
                 b.After_Visit__c, b.After_VisitSum__c, b.Actual_Visit_Number__c, b.Actual_Visit_Number_Target__c, b.ActualVisitRate__c, b.ActualVisitRate_Per__c, 
                 b.ActualVisitNumberValue__c, b.AT_visit_quantity__c, b.AT_Visit_Quantity_Target__c 
                 From Bonus_data__c b
                 Where Year__c =: objMonthlyPlan.Year__c 
                 And Month__c =: objMonthlyPlan.Month__c 
                 And The_User__c =: objMonthlyPlan.OwnerId];
        
            if(strPG.toUpperCase() == 'SP'){
                system.debug('Heeeereee!');
                if(IsRep == true){
                    system.debug('Heeeereee!1112');
                    newBonusData bonusData1 = new newBonusData();
                    bonusData1.strKpiName = '医院潜力分析完成率';
                    if(list_bData.size() > 0){
                        bonusData1.decKpiValue = list_bData[0].H_analysis_rate_Per__c;
                    }
                    list_BonusData.add(bonusData1);
                    
                    newBonusData bonusData2 = new newBonusData();
                    bonusData2.strKpiName = '业务机会数';
                    if(list_bData.size() > 0){
                        bonusData2.decKpiValue = String.valueOf(list_bData[0].Business_Opportunities__c);
                    }
                    list_BonusData.add(bonusData2);
                    
                    newBonusData bonusData3 = new newBonusData();
                    bonusData3.strKpiName = '拜访数量';
                    if(list_bData.size() > 0){
                        bonusData3.decKpiValue = String.valueOf(list_bData[0].Visit_quantity__c);
                    }
                    list_BonusData.add(bonusData3);
                    
                    newBonusData bonusData4 = new newBonusData();
                    bonusData4.strKpiName = '业务机会策略评分及建议';
                    if(list_bData.size() > 0){
                        bonusData4.decKpiValue = String.valueOf(list_bData[0].Business_Strategy_Score__c);
                    }
                    list_BonusData.add(bonusData4);
                    
                    newBonusData bonusData5 = new newBonusData();
                    bonusData5.strKpiName = '访前计划及访后分析完成率';
                    if(list_bData.size() > 0){
                        bonusData5.decKpiValue = list_bData[0].Rate_Before_Visit_Per__c;
                    }
                    list_BonusData.add(bonusData5);
                    
                    newBonusData bonusData6 = new newBonusData();
                    bonusData6.strKpiName = '拜访质量评分';
                    if(list_bData.size() > 0){
                        bonusData6.decKpiValue = String.valueOf(list_bData[0].Visit_quality_score__c);
                    }
                    list_BonusData.add(bonusData6);
                    
                    newBonusData bonusData7 = new newBonusData();
                    bonusData7.strKpiName = '奖金评分';
                    if(list_bData.size() > 0){
                        bonusData7.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                    }
                    list_BonusData.add(bonusData7);
                    
                }else if(IsRep == false){
                    newBonusData bonusData1 = new newBonusData();
                    bonusData1.strKpiName = '下属平均分';
                    if(list_bData.size() > 0){
                        bonusData1.decKpiValue = String.valueOf(list_bData[0].SEP_average__c);
                    }
                    list_BonusData.add(bonusData1);
                    
                    newBonusData bonusData2 = new newBonusData();
                    bonusData2.strKpiName = '协访数量';
                    if(list_bData.size() > 0){
                        bonusData2.decKpiValue = String.valueOf(list_bData[0].AT_visit_quantity__c);
                    }
                    list_BonusData.add(bonusData2);
                    
                    newBonusData bonusData3 = new newBonusData();
                    bonusData3.strKpiName = '协访质量(二级评分)';
                    if(list_bData.size() > 0){
                        bonusData3.decKpiValue = String.valueOf(list_bData[0].Assist_quality_two__c);
                    }
                    list_BonusData.add(bonusData3);
                    
                    newBonusData bonusData4 = new newBonusData();
                    bonusData4.strKpiName = '业务机会策略评分完成率';
                    if(list_bData.size() > 0){
                        bonusData4.decKpiValue = String.valueOf(list_bData[0].Business_Score_Reviews_Rate_Per__c);
                    }
                    list_BonusData.add(bonusData4);
                    
                    newBonusData bonusData7 = new newBonusData();
                    bonusData7.strKpiName = '奖金评分';
                    if(list_bData.size() > 0){
                        bonusData7.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                    }
                    list_BonusData.add(bonusData7);
                }
            }else if(strPG.toUpperCase() == 'IVT'){
                if(IsRep == true){
                    newBonusData bonusData1 = new newBonusData();
                    bonusData1.strKpiName = '业务机会策略评分及建议';
                    if(list_bData.size() > 0){
                        bonusData1.decKpiValue = String.valueOf(list_bData[0].Business_Strategy_Score__c);
                    }
                    list_BonusData.add(bonusData1);
                    
                    newBonusData bonusData2 = new newBonusData();
                    bonusData2.strKpiName = '拜访完成率';
                    if(list_bData.size() > 0){
                        bonusData2.decKpiValue = list_bData[0].Call_Completion_Rate_Per__c;
                    }
                    list_BonusData.add(bonusData2);
                    
                    newBonusData bonusData3 = new newBonusData();
                    bonusData3.strKpiName = '访前计划及访后分析完成率';
                    if(list_bData.size() > 0){
                        bonusData3.decKpiValue = list_bData[0].Rate_Before_Visit_Per__c;
                    }
                    list_BonusData.add(bonusData3);
                    
                    newBonusData bonusData4 = new newBonusData();
                    bonusData4.strKpiName = '拜访质量评分';
                    if(list_bData.size() > 0){
                        bonusData4.decKpiValue = String.valueOf(list_bData[0].Visit_quality_score__c);
                    }
                    list_BonusData.add(bonusData4);
                    
                    newBonusData bonusData5 = new newBonusData();
                    bonusData5.strKpiName = '关键信息传递率';
                    if(list_bData.size() > 0){
                        bonusData5.decKpiValue = list_bData[0].Key_Transfer_Rate_3Why_Per__c ;
                    }
                    list_BonusData.add(bonusData5);
                    
                    newBonusData bonusData6 = new newBonusData();
                    bonusData6.strKpiName = '业务机会相关拜访达成率';
                    if(list_bData.size() > 0){
                        bonusData6.decKpiValue = list_bData[0].Business_Visit_Rate_Achieved_Per__c;
                    }
                    list_BonusData.add(bonusData6);
                    
                    newBonusData bonusData7 = new newBonusData();
                    bonusData7.strKpiName = '市场活动拜访跟进(扣分项)';
                    if(list_bData.size() > 0){
                        bonusData7.decKpiValue = String.valueOf(list_bData[0].CampaignFollow__c);
                    }
                    list_BonusData.add(bonusData7);
                    
                    newBonusData bonusData8 = new newBonusData();
                    bonusData8.strKpiName = '奖金评分';
                    if(list_bData.size() > 0){
                        bonusData8.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                    }
                    list_BonusData.add(bonusData8);
                    
                }else{
                    newBonusData bonusData1 = new newBonusData();
                    bonusData1.strKpiName = '下属平均分';
                    if(list_bData.size() > 0){
                        bonusData1.decKpiValue = String.valueOf(list_bData[0].SEP_average__c);
                    }
                    list_BonusData.add(bonusData1);
                    
                    newBonusData bonusData2 = new newBonusData();
                    bonusData2.strKpiName = '协访数量';
                    if(list_bData.size() > 0){
                        bonusData2.decKpiValue = String.valueOf(list_bData[0].AT_visit_quantity__c);
                    }
                    list_BonusData.add(bonusData2);
                    
                    newBonusData bonusData3 = new newBonusData();
                    bonusData3.strKpiName = '业务机会策略评分及评语完成率';
                    if(list_bData.size() > 0){
                        bonusData3.decKpiValue = list_bData[0].Business_Score_Reviews_Rate_Per__c;
                    }
                    list_BonusData.add(bonusData3);
                    
                    newBonusData bonusData4 = new newBonusData();
                    bonusData4.strKpiName = '业务机会策略评估质量(二级评分)';
                    if(list_bData.size() > 0){
                        bonusData4.decKpiValue = String.valueOf(list_bData[0].Business_Strategy_Quality_Two__c);
                    }
                    list_BonusData.add(bonusData4);
                    
                    newBonusData bonusData8 = new newBonusData();
                    bonusData8.strKpiName = '奖金评分';
                    if(list_bData.size() > 0){
                        bonusData8.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                    }
                    list_BonusData.add(bonusData8);
                }
            }else if(strPG.toUpperCase() == 'IS' || strPG.toUpperCase() == 'GIS'){
                newBonusData bonusData1 = new newBonusData();
                bonusData1.strKpiName = '关键客户拜访量';
                if(list_bData.size() > 0){
                    bonusData1.decKpiValue = String.valueOf(list_bData[0].KeyCustomerVisitValue__c);
                }
                list_BonusData.add(bonusData1);
                
                newBonusData bonusData2 = new newBonusData();
                bonusData2.strKpiName = '普通客户拜访量';
                if(list_bData.size() > 0){
                    bonusData2.decKpiValue = String.valueOf(list_bData[0].VisitQuantityValue__c);
                }
                list_BonusData.add(bonusData2);
                
                newBonusData bonusData8 = new newBonusData();
                bonusData8.strKpiName = '奖金评分';
                if(list_bData.size() > 0){
                    bonusData8.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                }
                list_BonusData.add(bonusData8);
            }else if(strPG.toUpperCase() == 'PD'){
                if(IsRep == true){
                    newBonusData bonusData1 = new newBonusData();
                    bonusData1.strKpiName = '院长及药剂科拜访率';
                    if(list_bData.size() > 0){
                        bonusData1.decKpiValue = list_bData[0].DD_Pharmacy_Visit_Rate_Per__c;
                    }
                    list_BonusData.add(bonusData1);
                    
                    newBonusData bonusData2 = new newBonusData();
                    bonusData2.strKpiName = '业务机会数';
                    if(list_bData.size() > 0){
                        bonusData2.decKpiValue = String.valueOf(list_bData[0].Business_Opportunities__c);
                    }
                    list_BonusData.add(bonusData2);
                    
                    newBonusData bonusData3 = new newBonusData();
                    bonusData3.strKpiName = '相关拜访达标的业务机会数';
                    if(list_bData.size() > 0){
                        bonusData3.decKpiValue = String.valueOf(list_bData[0].Business_Visit_Rate_Achieved_Completed__c);
                    }
                    list_BonusData.add(bonusData3);
                    
                    newBonusData bonusData4 = new newBonusData();
                    bonusData4.strKpiName = '拜访完成率';
                    if(list_bData.size() > 0){
                        bonusData4.decKpiValue = list_bData[0].Call_Completion_Rate_Per__c ;
                    }
                    list_BonusData.add(bonusData4);
                    
                    newBonusData bonusData5 = new newBonusData();
                    bonusData5.strKpiName = '科室会数量';
                    if(list_bData.size() > 0){
                        bonusData5.decKpiValue = String.valueOf(list_bData[0].Department_number__c);
                    }
                    list_BonusData.add(bonusData5);
                    
                    newBonusData bonusData6 = new newBonusData();
                    bonusData6.strKpiName = '访前计划及访后分析完成率';
                    if(list_bData.size() > 0){
                        bonusData6.decKpiValue = list_bData[0].Rate_Before_Visit_Per__c;
                    }
                    list_BonusData.add(bonusData6);
                    
                    newBonusData bonusData7 = new newBonusData();
                    bonusData7.strKpiName = '拜访质量评分';
                    if(list_bData.size() > 0){
                        bonusData7.decKpiValue = String.valueOf(list_bData[0].Visit_quality_score__c);
                    }
                    list_BonusData.add(bonusData7);
                    
                    newBonusData bonusData8 = new newBonusData();
                    bonusData8.strKpiName = '奖金评分';
                    if(list_bData.size() > 0){
                        bonusData8.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                    }
                    list_BonusData.add(bonusData8);
                }else{
                    newBonusData bonusData1 = new newBonusData();
                    bonusData1.strKpiName = '下属平均分';
                    if(list_bData.size() > 0){
                        bonusData1.decKpiValue = String.valueOf(list_bData[0].SEP_average__c);
                    }
                    list_BonusData.add(bonusData1);
                    
                    newBonusData bonusData2 = new newBonusData();
                    bonusData2.strKpiName = '院长及药剂科拜访率';
                    if(list_bData.size() > 0){
                        bonusData2.decKpiValue = list_bData[0].DD_Pharmacy_Visit_Rate_Per__c ;
                    }
                    list_BonusData.add(bonusData2);
                    
                    newBonusData bonusData3 = new newBonusData();
                    bonusData3.strKpiName = '协访数量';
                    if(list_bData.size() > 0){
                        bonusData3.decKpiValue = String.valueOf(list_bData[0].AT_visit_quantity__c);
                    }
                    list_BonusData.add(bonusData3);
                    
                    if(!IsPDASM){
                        newBonusData bonusData4 = new newBonusData();
                        bonusData4.strKpiName = '协访质量(二级评分)';
                        if(list_bData.size() > 0){
                            bonusData4.decKpiValue = String.valueOf(list_bData[0].Assist_quality_two__c);
                        }
                        list_BonusData.add(bonusData4);
                    }                    
                    
                    newBonusData bonusData5 = new newBonusData();
                    bonusData5.strKpiName = '业务机会策略评分及评语完成率';
                    if(list_bData.size() > 0){
                        bonusData5.decKpiValue = list_bData[0].Business_Score_Reviews_Rate_Per__c ;
                    }
                    list_BonusData.add(bonusData5);
                    
                    newBonusData bonusData8 = new newBonusData();
                    bonusData8.strKpiName = '奖金评分';
                    if(list_bData.size() > 0){
                        bonusData8.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                    }
                    list_BonusData.add(bonusData8);
                    if(HaveHospital==true){
                        list_HaveHospitalBonusData = new List<newBonusData>();
                        newBonusData bonusDatah1 = new newBonusData();
                        bonusDatah1.strKpiName = '相关拜访达标的业务机会数';
                        if(list_bData.size() > 0){
                            bonusDatah1.decKpiValue = String.valueOf(list_bData[0].Business_Visit_Rate_Achieved_Completed__c);
                        }
                        list_HaveHospitalBonusData.add(bonusDatah1);
                        
                        newBonusData bonusDatah2 = new newBonusData();
                        bonusDatah2.strKpiName = '拜访完成率';
                        if(list_bData.size() > 0){
                            bonusDatah2.decKpiValue = list_bData[0].Call_Completion_Rate_Per__c ;
                        }
                        list_HaveHospitalBonusData.add(bonusDatah2);
                        
                        newBonusData bonusDatah3 = new newBonusData();
                        bonusDatah3.strKpiName = '访前计划及访后分析完成率';
                        if(list_bData.size() > 0){
                            bonusDatah3.decKpiValue = list_bData[0].Rate_Before_Visit_Per__c;
                        }
                        list_HaveHospitalBonusData.add(bonusDatah3);
                        
                        newBonusData bonusDatah4 = new newBonusData();
                        bonusDatah4.strKpiName = '拜访质量评分';
                        if(list_bData.size() > 0){
                            bonusDatah4.decKpiValue = String.valueOf(list_bData[0].Visit_quality_score__c);
                        }
                        list_HaveHospitalBonusData.add(bonusDatah4);
                        
                        newBonusData bonusDatah5 = new newBonusData();
                        bonusDatah5.strKpiName = '负责医院主管得分';
                        if(list_bData.size() > 0){
                            bonusDatah5.decKpiValue = String.valueOf(list_bData[0].SuperValue__c);
                        }
                        list_HaveHospitalBonusData.add(bonusDatah5);
                        
                        for(Integer i=0;i<3;i++){
                            list_HaveHospitalBonusData.add(new newBonusData(' '));
                        }
                    }
                }
                
            }else if(strPG.toUpperCase() == 'HD' || strPG.toUpperCase() == 'CRRT'){
                if(IsRep == true){
                    newBonusData bonusData1 = new newBonusData();
                    bonusData1.strKpiName = '实际拜访目标联系人人数';
                    if(list_bData.size() > 0){
                        bonusData1.decKpiValue = String.valueOf(list_bData[0].Actual_Visit_Number__c);
                    }
                    list_BonusData.add(bonusData1);
                    
                    newBonusData bonusData2 = new newBonusData();
                    bonusData2.strKpiName = '拜访完成率';
                    if(list_bData.size() > 0){
                        bonusData2.decKpiValue = list_bData[0].Call_Completion_Rate_Per__c;
                    }
                    list_BonusData.add(bonusData2);
                    
                    newBonusData bonusData3 = new newBonusData();
                    bonusData3.strKpiName = '访前计划及访后分析完成率';
                    if(list_bData.size() > 0){
                        bonusData3.decKpiValue = list_bData[0].Rate_Before_Visit_Per__c ;
                    }
                    list_BonusData.add(bonusData3);
                    
                    newBonusData bonusData4 = new newBonusData();
                    bonusData4.strKpiName = '业务机会数';
                    if(list_bData.size() > 0){
                        bonusData4.decKpiValue = String.valueOf(list_bData[0].Business_Opportunities__c);
                    }
                    list_BonusData.add(bonusData4);
                    /*
                    newBonusData bonusData5 = new newBonusData();
                    bonusData5.strKpiName = '业务机会相关事件数量';
                    if(list_bData.size() > 0){
                        bonusData5.decKpiValue = String.valueOf(list_bData[0].Business_Events_Number__c);
                    }
                    list_BonusData.add(bonusData5);
                    */
                    newBonusData bonusData6 = new newBonusData();
                    bonusData6.strKpiName = '相关拜访达标的业务机会数';
                    if(list_bData.size() > 0){
                        bonusData6.decKpiValue = String.valueOf(list_bData[0].Business_Visit_Rate_Achieved_Completed__c);
                    }
                    list_BonusData.add(bonusData6);
                    
                    newBonusData bonusData8 = new newBonusData();
                    bonusData8.strKpiName = '奖金评分';
                    if(list_bData.size() > 0){
                        bonusData8.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                    }
                    list_BonusData.add(bonusData8);
                }else{
                    newBonusData bonusData1 = new newBonusData();
                    bonusData1.strKpiName = '下属平均分';
                    if(list_bData.size() > 0){
                        bonusData1.decKpiValue = String.valueOf(list_bData[0].SEP_average__c);
                    }
                    list_BonusData.add(bonusData1);
                    
                    newBonusData bonusData2 = new newBonusData();
                    bonusData2.strKpiName = '协访数量';
                    if(list_bData.size() > 0){
                        bonusData2.decKpiValue = String.valueOf(list_bData[0].AT_visit_quantity__c);
                    }
                    list_BonusData.add(bonusData2);
                    
                    newBonusData bonusData3 = new newBonusData();
                    bonusData3.strKpiName = '主管月计划评语完成率';
                    if(list_bData.size() > 0){
                        bonusData3.decKpiValue = list_bData[0].Monthly_Plan_Reviews_Rate_Per__c;
                    }
                    list_BonusData.add(bonusData3);
                    
                    newBonusData bonusData8 = new newBonusData();
                    bonusData8.strKpiName = '奖金评分';
                    if(list_bData.size() > 0){
                        bonusData8.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                    }
                    
                    list_BonusData.add(bonusData8);
                    if(HaveHospital==true){
                        list_HaveHospitalBonusData = new List<newBonusData>();
                        newBonusData bonusDatah1 = new newBonusData();
                        bonusDatah1.strKpiName = '拜访完成率';
                        if(list_bData.size() > 0){
                            bonusDatah1.decKpiValue = list_bData[0].Call_Completion_Rate_Per__c ;
                        }
                        list_HaveHospitalBonusData.add(bonusDatah1);
                        
                        newBonusData bonusDatah2 = new newBonusData();
                        bonusDatah2.strKpiName = '访前计划及访后分析完成率';
                        if(list_bData.size() > 0){
                            bonusDatah2.decKpiValue = list_bData[0].Rate_Before_Visit_Per__c ;
                        }
                        list_HaveHospitalBonusData.add(bonusDatah2);
                        /*
                        newBonusData bonusDatah3 = new newBonusData();
                        bonusDatah3.strKpiName = '业务机会相关事件数量';
                        if(list_bData.size() > 0){
                            bonusDatah3.decKpiValue = String.valueOf(list_bData[0].Business_Events_Number__c);
                        }
                        list_HaveHospitalBonusData.add(bonusDatah3);
                        */
                        newBonusData bonusDatah4 = new newBonusData();
                        bonusDatah4.strKpiName = '相关拜访达标的业务机会数';
                        if(list_bData.size() > 0){
                            bonusDatah4.decKpiValue = String.valueOf(list_bData[0].Business_Visit_Rate_Achieved_Completed__c);
                        }
                        list_HaveHospitalBonusData.add(bonusDatah4);
                        
                        newBonusData bonusDatah5 = new newBonusData();
                        bonusDatah5.strKpiName = '负责医院主管得分';
                        if(list_bData.size() > 0){
                            bonusDatah5.decKpiValue = String.valueOf(list_bData[0].SuperValue__c);
                        }
                        list_HaveHospitalBonusData.add(bonusDatah5);
                        for(Integer i=0;i<3;i++){
                            list_HaveHospitalBonusData.add(new newBonusData(' '));
                        }
                    }
                }
            }else if(strPG.toUpperCase().contains('CS')){
                newBonusData bonusData1 = new newBonusData();
                bonusData1.strKpiName = '目标联系人人数';
                if(list_bData.size() > 0){
                    bonusData1.decKpiValue = String.valueOf(list_bData[0].ActualVisitNumberValue__c);
                }
                list_BonusData.add(bonusData1);
                
                newBonusData bonusData2 = new newBonusData();
                bonusData2.strKpiName = '拜访完成率';
                if(list_bData.size() > 0){
                    bonusData2.decKpiValue = String.valueOf(list_bData[0].VisitRateValue__c);
                }
                list_BonusData.add(bonusData2);
                
                newBonusData bonusData3 = new newBonusData();
                bonusData3.strKpiName = '访前计划及访后分析完成率';
                if(list_bData.size() > 0){
                    bonusData3.decKpiValue = String.valueOf(list_bData[0].VisitPlanRateValue__c);
                }
                list_BonusData.add(bonusData3);
                
                newBonusData bonusData8 = new newBonusData();
                bonusData8.strKpiName = '奖金评分';
                if(list_bData.size() > 0){
                    bonusData8.decKpiValue = String.valueOf(list_bData[0].Total_Score__c);
                }
                list_BonusData.add(bonusData8);
            }
            
        }
        if(list_BonusData.size() < 8){
            for(Integer i=0 ;i<8;i++){
                if(list_BonusData.size()<8){
                    list_BonusData.add(new newBonusData(' '));
                }else{
                    break;
                }
            }  
        }
        /*
        if(list_BonusData.size() < 8){
            for(Integer i=0 ;i<8;i++){
                if(list_BonusData.size()==0){
                    list_BonusData.add(new newBonusData(' '));
                }else if(list_BonusData.size() <= i){
                    list_BonusData.add(list_BonusData.size() -1 ,new newBonusData(' '));
                }
            }  
        }
        */
    }
    
    
    
    
    
    //月计划owner的奖金数据
    public void userBonusInFo()
    {
        Map<String, Schema.SobjectField> BonusInfofields = 
            Schema.SobjectType.V2_UserBonusInFo__c.fields.getMap();
        String strQuery = 'Select ' ;
        String strQ = '' ;
        for(String strApiName : BonusInfofields.keySet())
        {
            if(strQ == '')
            {
                strQ += strApiName ;
            }else
            {
                strQ += ',' + strApiName ;
            }
        }
        strQuery += strQ + ' From V2_UserBonusInFo__c Where V2_SalesUser__c =\''+ 
            objMonthlyPlan.OwnerId + '\' And V2_Month__c = \''+ objMonthlyPlan.Month__c+'\' And V2_Year__c = \''+objMonthlyPlan.Year__c + '\'' ;
        List<sObject> list_BonusInfo = Database.query(strQuery);
        system.debug('chaxunjieguo : '+list_BonusInfo.size());
        
        if(list_BonusInfo == null)
        {
            blnBonusShow = false ;
        }else if(list_BonusInfo.size() >= 1)
        {
            blnBonusShow = true ;
            objUserBonus = (V2_UserBonusInFo__c)list_BonusInfo[0] ;
        }else
        {
            blnBonusShow = false ;
        }
        
        
        
    }
    /*
    private void fieldCheck(V2_UserBonusInFo__c objBonus , List<List<BonusDetailInfo>> list_Bonus)
    {
        List<BonusDetailInfo> list_BonusDetail = new List<BonusDetailInfo>() ;
        if(objBonus.V2_BiosKOLCoverage__c != null)
            this.buildList('V2_BiosKOLCoverage__c' , String.valueOf(objBonus.V2_BiosKOLCoverage__c) , list_BonusDetail) ;
        
    }
    private void buildList(String strApiName , String strValue , List<BonusDetailInfo> list_BonusDetail)
    {
        if(list_BonusDetail.size() == 7)
            list_BonusDetail = new List<BonusDetailInfo>() ;
        BonusDetailInfo objBonusDI = new BonusDetailInfo() ;
        objBonusDI.strName=map_BonusInfoField.get(strApiName) ;
        objBonusDI.strValue = strValue ;
        list_BonusDetail.add(objBonusDI) ;
        return list_BonusDetail ;
    }
    //构建字段API名-字段label名的map
    private Map<String,String> fieldNameMap()
    {
        //Map<String,String> map_BonusInfoField = new Map<String,String>() ;
        Map<String, Schema.SobjectField> BonusInfofields = 
            Schema.SobjectType.V2_UserBonusInFo__c.fields.getMap();
        for(String strApiName : BonusInfofields.keySet())
        {
            Schema.SobjectField sField = BonusInfofields.get(strApiName) ;
            map_BonusInfoField.put(strApiName , sField.getDescribe().getLabel()) ;
        }
        BonusInfofields.clear() ;
        return map_BonusInfoField ;
        
    } 
    public class BonusDetailInfo
    {
        public String strName {get;set;}
        public String strValue {get;set;}
    }
    */
    
    //计划拜访联系人分布，按级别（金、银、铜）
    public String PlanContactDistributionByGrade
    {
        get
        {
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            map_Grade.clear() ;
            //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
            if(list_MonthlyDetail.size() != null)
            {
                for(MonthlyPlanDetail__c objMonDetail : list_MonthlyDetail)
                {
                    system.debug(blnBiosShow+'Herrre?!!'+objMonDetail+'==-=='+objMonDetail.Contact__r.V2_RenalGrade__c+'--=--'+objMonDetail.Contact__r.V2_Level__c) ;
                    if((blnRenalShow == true || blnMDShow == true) && objMonDetail.Contact__r.V2_RenalGrade__c == null)
                    {
                        continue ;
                    }
                    system.debug('11-11') ;
                    if(blnBiosShow == true && objMonDetail.Contact__r.V2_Level__c == null)
                    {
                        continue ;
                    }
                    system.debug('22-22') ;
                    if(objMonDetail.AdjustedTimes__c == 0 || objMonDetail.AdjustedTimes__c == null)
                    {
                        continue ;
                    }
                    system.debug('33-33') ;
                    if(blnBiosShow == true)
                    {
                        system.debug('Map Info :'+map_Grade+' Level info : '+objMonDetail.Contact__r.V2_Level__c) ;
                        if(map_Grade.containsKey(objMonDetail.Contact__r.V2_Level__c))
                        {
                            Integer intSum = map_Grade.get(objMonDetail.Contact__r.V2_Level__c) ;
                            intSum ++ ;
                            map_Grade.put(objMonDetail.Contact__r.V2_Level__c,intSum) ;
                        }else
                        {
                            map_Grade.put(objMonDetail.Contact__r.V2_Level__c, 1) ;
                        }
                    }else
                    {
                        system.debug('Map Info :'+map_Grade+' Level info : '+objMonDetail.Contact__r.V2_RenalGrade__c) ;
                        if(map_Grade.containsKey(objMonDetail.Contact__r.V2_RenalGrade__c))
                        {
                            Integer intSum = map_Grade.get(objMonDetail.Contact__r.V2_RenalGrade__c) ;
                            intSum ++ ;
                            map_Grade.put(objMonDetail.Contact__r.V2_RenalGrade__c,intSum) ;
                        }else
                        {
                            map_Grade.put(objMonDetail.Contact__r.V2_RenalGrade__c, 1) ;
                        }
                    }
                    
                }
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
            System.Debug('??????????????????????????????????titleStr'+theLatTitleStr);
            System.Debug('??????????????????????????????????dataStr'+theLatDataStr);
            return   'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C4C400,A8FF24,949449,00E3E3&chm=N*p0*,000000,0,-1,11';
        }
    }
    
    
    //实际拜访联系人分布，按级别（金、银、铜）
    public String ActualContactDistributionByGrade
    {
        get
        {
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            map_Grade.clear() ;
            //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
            system.debug('Contact Size:'+map_conId) ;
            if(map_conId.size() != 0) 
            {
                for(Contact objCon : map_conId.values())
                {
                    if((blnRenalShow == true || blnMDShow == true) && objCon.V2_RenalGrade__c == null)
                    {
                        continue ;
                    }
                    if(blnBiosShow == true && objCon.V2_Level__c == null)
                    {
                        continue ;
                    }
                    if(blnBiosShow == true)
                    {
                        if(map_Grade.containsKey(objCon.V2_Level__c))
                        {
                            Integer intSum = map_Grade.get(objCon.V2_Level__c) ;
                            intSum ++ ;
                            map_Grade.put(objCon.V2_Level__c,intSum) ;
                        }else
                        {
                            map_Grade.put(objCon.V2_Level__c, 1) ;
                        }
                    }else
                    {
                        if(map_Grade.containsKey(objCon.V2_RenalGrade__c))
                        {
                            Integer intSum = map_Grade.get(objCon.V2_RenalGrade__c) ;
                            intSum ++ ;
                            map_Grade.put(objCon.V2_RenalGrade__c,intSum) ;
                        }else
                        {
                            map_Grade.put(objCon.V2_RenalGrade__c, 1) ;
                        }
                    }
                    
                }
                system.debug(map_Grade) ;
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            system.debug('Actual titleStr:'+titleStr) ;
            system.debug('Actual dataStr:'+dataStr) ;
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
            return 'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C4C400,A8FF24,949449,00E3E3'; 
        }
    }
    //实际拜访（次数）分布，按级别（金、银、铜）
    public String ActualCallDistributionByGrade
    {
        get
        { 
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            List<Contact> list_Con = new List<Contact>() ;
            if(map_EveId.size() != 0)
            {
                for(Event objEve : map_EveId.values())
                {
                    if(objEve.Done__c)
                    {
                        list_Con.add(map_EvIdContact.get(objEve.Id)) ;
                    }
                }
            }
            if(list_Con.size() != 0)
            {
                map_Grade.clear() ;
                //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
                for(Contact objCon : list_Con)
                {
                    if(objCon == null)
                    {
                        continue;
                    }
                    if(blnBiosShow == true){
                        if(map_Grade.containsKey(objCon.V2_Level__c))
                        {
                            Integer intSum = map_Grade.get(objCon.V2_Level__c) ;
                            intSum ++ ;
                            map_Grade.put(objCon.V2_Level__c,intSum) ;
                        }else
                        {
                            map_Grade.put(objCon.V2_Level__c, 1) ;
                        }
                    }else{
                        if(map_Grade.containsKey(objCon.V2_RenalGrade__c))
                        {
                            Integer intSum = map_Grade.get(objCon.V2_RenalGrade__c) ;
                            intSum ++ ;
                            map_Grade.put(objCon.V2_RenalGrade__c,intSum) ;
                        }else
                        {
                            map_Grade.put(objCon.V2_RenalGrade__c, 1) ;
                        }
                    }
                    
                }
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            
            system.debug('ActualCall:'+titleStr+'---'+dataStr) ;
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
            return    'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C4C400,A8FF24,949449,00E3E3';
        }
    }
    //计划拜访联系人分布，按联系人类型（医生、护士、行政）
    public String PlanContactDistributionByType
    { 
        get
        {
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            map_Grade.clear() ;
            //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
            if(list_MonthlyDetail.size() != null)
            {
                for(MonthlyPlanDetail__c objMonDetail : list_MonthlyDetail)
                {
                    if(objMonDetail.AdjustedTimes__c == 0 || objMonDetail.AdjustedTimes__c == null)
                    {
                        continue ;
                    }
                    if(objMonDetail.Contact__r.ContactType__c == null)
                    {
                        continue ;
                    }
                    if(map_Grade.containsKey(objMonDetail.Contact__r.ContactType__c))
                    {
                        Integer intSum = map_Grade.get(objMonDetail.Contact__r.ContactType__c) ;
                        intSum ++ ;
                        map_Grade.put(objMonDetail.Contact__r.ContactType__c,intSum) ;
                    }else
                    {
                        map_Grade.put(objMonDetail.Contact__r.ContactType__c, 1) ;
                    }
                }
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
             
            System.Debug('??????????????????????????????????titleStr'+theLatTitleStr);
            System.Debug('??????????????????????????????????dataStr'+theLatDataStr);
            return  'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C0504D,9bbb59,0000ff';
        }
    }
    //计划拜访联系人分布，按联系人部门类型（肾科、移植科、医务科。。） for BIOS
    public String PlanContactDistributionByDepartmentType
    { 
        get
        {
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            map_Grade.clear() ;
            //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
            if(list_MonthlyDetail.size() != null)
            {
                for(MonthlyPlanDetail__c objMonDetail : list_MonthlyDetail)
                {
                    if(objMonDetail.Contact__r.DepartmentType__c == null)
                    {
                        continue ;
                    }
                    if(map_Grade.containsKey(objMonDetail.Contact__r.DepartmentType__c))
                    {
                        Integer intSum = map_Grade.get(objMonDetail.Contact__r.DepartmentType__c) ;
                        intSum ++ ;
                        map_Grade.put(objMonDetail.Contact__r.DepartmentType__c,intSum) ;
                    }else
                    {
                        map_Grade.put(objMonDetail.Contact__r.DepartmentType__c, 1) ;
                    }
                }
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
             
            System.Debug('??????????????????????????????????titleStr'+theLatTitleStr);
            System.Debug('??????????????????????????????????dataStr'+theLatDataStr);
            return  'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C0504D,9bbb59,0000ff';
        }
    }
    //实际拜访联系人分布，按联系人类型（医生、护士、行政）
    public String ActualContactDistributionByType
    {
        get
        {
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            map_Grade.clear() ;
            //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
            if(map_conId.size() != 0) 
            {
                for(Contact objCon : map_conId.values())
                {
                    if(map_Grade.containsKey(objCon.ContactType__c))
                    {
                        Integer intSum = map_Grade.get(objCon.ContactType__c) ;
                        intSum ++ ;
                        map_Grade.put(objCon.ContactType__c,intSum) ;
                    }else
                    {
                        map_Grade.put(objCon.ContactType__c, 1) ;
                    }
                }
                system.debug(map_Grade) ;
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
            return   'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C0504D,9bbb59,0000ff'; 
        }
    }
    //实际拜访联系人分布，按联系人部门类型（肾科、移植科、医务科。。） for BIOS
    public String ActualContactDistributionByDepartmentType
    {
        get
        {
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            map_Grade.clear() ;
            //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
            if(map_conId.size() != 0) 
            {
                for(Contact objCon : map_conId.values())
                {
                    if(objCon == null || objCon.DepartmentType__c == null)
                    {
                        continue ;
                    }
                    if(map_Grade.containsKey(objCon.DepartmentType__c))
                    {
                        Integer intSum = map_Grade.get(objCon.DepartmentType__c) ;
                        intSum ++ ;
                        map_Grade.put(objCon.DepartmentType__c,intSum) ;
                    }else
                    {
                        map_Grade.put(objCon.DepartmentType__c, 1) ;
                    }
                }
                system.debug(map_Grade) ;
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
            return   'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C0504D,9bbb59,0000ff'; 
        }
    }
    //实际拜访（次数）分布，按联系人类型（医生、护士、行政）
    public String ActualCallDistributionByType
    {
        get
        {
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            map_Grade.clear() ;
            
            List<Contact> list_Con = new List<Contact>() ;
            if(map_EveId.size() != 0)
            {
                for(Event objEve : map_EveId.values())
                {
                    if(objEve.Done__c)
                    {
                        list_Con.add(map_EvIdContact.get(objEve.Id)) ;
                    }
                }
            }
            if(list_Con.size() != 0)
            {
                map_Grade.clear() ;
                //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
                for(Contact objCon : list_Con)
                {
                    if(objCon == null || objCon.ContactType__c == null)
                    {
                        continue ;
                    }
                    if(map_Grade.containsKey(objCon.ContactType__c))
                    {
                        Integer intSum = map_Grade.get(objCon.ContactType__c) ;
                        intSum ++ ;
                        map_Grade.put(objCon.ContactType__c,intSum) ;
                    }else
                    {
                        map_Grade.put(objCon.ContactType__c, 1) ;
                    }
                }
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
            return   'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C0504D,9bbb59,0000ff';
        }
    }
    //实际拜访（次数）分布，按联系人部门类型（肾科、移植科、医务科。。） for BIOS
    public String ActualCallDistributionByDepartmentType
    {
        get
        {
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            map_Grade.clear() ;
            
            List<Contact> list_Con = new List<Contact>() ;
            if(map_EveId.size() != 0)
            {
                for(Event objEve : map_EveId.values())
                {
                    if(objEve.Done__c)
                    {
                        list_Con.add(map_EvIdContact.get(objEve.Id)) ;
                    }
                }
            }
            if(list_Con.size() != 0)
            {
                map_Grade.clear() ;
                //Map<String,Integer> map_Grade = new Map<String,Integer>() ;
                for(Contact objCon : list_Con)
                {
                    if(objCon == null || objCon.DepartmentType__c == null)
                    {
                        continue ;
                    }
                    
                    if(map_Grade.containsKey(objCon.DepartmentType__c))
                    {
                        Integer intSum = map_Grade.get(objCon.DepartmentType__c) ;
                        intSum ++ ;
                        map_Grade.put(objCon.DepartmentType__c,intSum) ;
                    }else
                    {
                        map_Grade.put(objCon.DepartmentType__c, 1) ;
                    }
                }
                if(map_Grade.size() != 0)
                {
                    for(String strGrade : map_Grade.keySet())
                    {
                        map_Grade.get(strGrade) ;
                        titleStr += strGrade+String.valueOf(map_Grade.get(strGrade))+'|';
                        dataStr += map_Grade.get(strGrade)+',';
                    }
                }
            }
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
            return   'cht=p&chd=t:'+theLatDataStr+'&chs=210x126&chl='+theLatTitleStr+'&chco=C0504D,9bbb59,0000ff';
        }
    }
    //拜访完成情况（次数） 1
    public String VisitCompleteCountCondition
    {
        get   
        {
            Integer plan = 0;
            Integer real = 0;
            Double chdsMax = 0;
            Double space ;
            
            if(list_MonthlyDetail.size() != 0)
            {
                for(MonthlyPlanDetail__c objMonthDetail : list_MonthlyDetail)
                {
                    if(objMonthDetail.AdjustedTimes__c != null)
                    {
                        plan += Integer.valueOf(objMonthDetail.AdjustedTimes__c) ;
                    }
                }
            }
            if(map_EveId.size() != 0)
            {
                for(Event objEv : map_EveId.values())
                {
                    if(objEv.Done__c)
                    {
                        real++ ;
                    }
                }
            }
            
            if(plan>real){chdsMax = plan;}else{chdsMax=real;}  //取得最大值 chdsMax
            space =(chdsMax/10)  ;
            return  'cht=bvs&chd=t:'+plan +','+real+'&chs=300x150&chco=FF5757|0579CC&chbh=42&chxt=x,y&chxr=1,0,'+chdsMax+','+space+'&chds=0,'+chdsMax+'&chl=计划次数|完成次数&chm=N,000000,0,,10|N,000000,1,,10';       
        }  
    }
    //拜访完成情况（比率）2
    public String VisitCompleteRatioCondition 
    {
        get
        {
            Double visitBeforePlan = 0;
            Double visitBeforeReal = 0;
            
            Double visitAfterAnalyse = 0;
            Double visitAfterComplete = 0;
            
            Double visitBeforePlanRatio = 0.0;
            Double visitAfterAnalyseRatio = 0.0;
            
            if(map_EveId.size() != 0)
            {
                for(Event objEv : map_EveId.values())
                {
                    if(!objEv.Done__c)
                    {
                        continue ;
                    }
                    if(objEv.GAPlan__c != null)
                    {
                        visitBeforePlan ++ ;
                    }
                    if(objEv.GAExecuteResult__c != null)
                    {
                        visitAfterAnalyse++ ;
                    }
                    visitBeforeReal++ ;
                    visitAfterComplete++ ;
                }
            }
            if(visitBeforeReal!=0&&visitBeforeReal!=null)
            {
                  visitBeforePlanRatio = (visitBeforePlan/visitBeforeReal);  //访前计划比率
            }
            if(visitAfterComplete!=0&&visitAfterComplete!=null)
            {
             visitAfterAnalyseRatio = (visitAfterAnalyse/visitAfterComplete);  //得到访后计划比率
             System.debug('bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb visitAfterAnalyseRatio  '+visitAfterAnalyseRatio);
            } 
            
            return  'cht=bvs&chd=t:'+visitBeforePlanRatio +','+visitAfterAnalyseRatio+'&chds=0,1.0&chs=300x150&chco=9CDC57|FFA405&chbh=42&chxt=x,y&chl=访前计划|访后分析&chm=N*p0*,000000,0,-1,11&chxr=1,0,100,20';     
        }
    }
    //拜访完成情况 计划/实际  按 金 银 铜  FOR BIOS
    public String VisitCompleteCountBios 
    {
        get
        {
            List<String> levelABC=new List<String>();
            levelABC.add('A');
            levelABC.add('B');
            levelABC.add('C');
            Double vAxisMax=0;//纵轴最大值=Max(访前计划汇总记录上,访后分析汇总记录数)
            Double visitBeforePlan = 0;
            
            Double visitAfterAnalyse = 0;
            Double visitAfterComplete = 0;
            //Planned_Finished_Calls__c, 完成数
            //AdjustedTimes__c, 计划数
            List<MonthlyPlanDetail__c> mps=this.list_MonthlyDetail ;
            Map<String,Integer> level_adjustTimesMap=new Map<String,Integer>();
            Map<String,Integer> level_completeMap=new Map<String,Integer>();
            if(mps!=null){
                for(MonthlyPlanDetail__c mp:mps){
                    String level=mp.Contact__r.V2_Level__c;
                    if(level==null)continue;
                    level=level.toUpperCase().trim();
                    Integer atv1=level_adjustTimesMap.get(level)==null?0:level_adjustTimesMap.get(level);
                    Integer v1=mp.AdjustedTimes__c==null?0:Integer.valueOf(mp.AdjustedTimes__c);
                    atv1+=v1;
                    level_adjustTimesMap.put(level,atv1);
                    
                    Integer atv2=level_completeMap.get(level)==null?0:level_completeMap.get(level);
                    Integer v2=mp.Planned_Finished_Calls__c==null?0:Integer.valueOf(mp.Planned_Finished_Calls__c);
                    atv2+=v2;
                    level_completeMap.put(level,atv2);
                }
            }
            ////////////////////combile                     
            String chco='';
            String chdl='';
            Integer colorIndex=0;
            Integer d1=0,d2=0;
            Double sum1=0, sum2=0;
            String ds='';
            for(String s:levelABC){
                //String color=colors[colorIndex];
                String color = this.getColor(colorIndex) ;
                d1=level_adjustTimesMap.containsKey(s)?level_adjustTimesMap.get(s):0;
                d2=level_completeMap.containsKey(s)?level_completeMap.get(s):0;
                if(colorIndex>0 && colorIndex<levelABC.size()){
                    chco+=',';
                    chdl+='|';
                    ds+='|';
                }
                sum1+=d1;
                sum2+=d2;
                chco+=color;
                chdl+=s;
                ds+=d1+','+d2;
                colorIndex++;
            }
            vAxisMax=sum1>sum2?sum1:sum2;
            vAxisMax+=1;
            if(vAxisMax<5)vAxisMax=5;
            Integer widht=240,height=180;
            Integer vInc=colorIndex<5?Integer.valueOf(vAxisMax/5):Integer.valueOf(vAxisMax/colorIndex);//Y轴递增量
            if(vInc<1)vInc=1; 
            //String lk='cht=bvs&chs=300x180&chd=t:20,35|30,55|5,25&chxr=1,0,120&chds=0,120&chco=0A8C8A,EBB671,DE091A&chbh=45,20,15&chxt=x,y&chxl=0:|计划|实际&chdl=A|B|C';
            String lk='cht=bvs&chs='+widht+'x'+height+'&chd=t:'+ds+'&chxr=1,0,'+vAxisMax+'&chds=0,'+vAxisMax+'&chco='+chco+'&chbh=45,20,15&chxt=x,y&chxl=0:|计划|实际&chdl=A|B|C';
            return lk;
        }
    }
    
    //拜访完成情况（次数） 2  FOR BIOS
    public String VisitCompleteCountBios2
    {
        get   
        {
            List<String> levelABC=new List<String>();
            levelABC.add('A');
            levelABC.add('B');
            levelABC.add('C');
            Double vAxisMax=0;//纵轴最大值=Max(访前计划汇总记录上,访后分析汇总记录数)
            Double visitBeforePlan = 0;
            
            Double visitAfterAnalyse = 0;
            Double visitAfterComplete = 0;
            //Planned_Finished_Calls__c, 完成数
            //AdjustedTimes__c, 计划数
            List<MonthlyPlanDetail__c> mps=this.list_MonthlyDetail ;
            Map<String,Integer> level_adjustTimesMap=new Map<String,Integer>();
            Map<String,Integer> level_completeMap=new Map<String,Integer>();
            Map<String,Integer> level_TypeNameMap  ;
            Map<String,Map<String,Integer>> map_Type_Level = new Map<String,Map<String,Integer>>() ;
            Map<String,Integer> map_TypeTimes = new Map<String,Integer>() ;
            if(mps!=null){
                for(MonthlyPlanDetail__c mp:mps){
                    String level=mp.Contact__r.V2_Level__c;
                    if(level==null)continue;
                    String strType = mp.Contact__r.DepartmentType__c ;
                    if(strType==null)continue ;
                    level=level.toUpperCase().trim();
                    strType=strType.trim() ;
                    
                    level_TypeNameMap = map_Type_Level.get(level)==null?new Map<String,Integer>():map_Type_Level.get(level);
                    
                    Integer inv = level_TypeNameMap.get(strType)==null?0:level_TypeNameMap.get(strType) ;
                    Integer inv1 = mp.AdjustedTimes__c==null?0:Integer.valueOf(mp.AdjustedTimes__c) ;
                    inv+=inv1;
                    level_TypeNameMap.put(strType,inv) ;
                    map_Type_Level.put(level,level_TypeNameMap) ;
                    
                    Integer intSum = map_TypeTimes.get(strType)==null?0:map_TypeTimes.get(strType);
                    intSum+=inv1 ;
                    map_TypeTimes.put(strType,intSum) ;
                }
            }
            ////////////////////combile                     
            String chco='';
            String chdl='';
            String chxl='' ;
            Boolean bln = true ;
            Integer colorIndex=0;
            Integer d1=0,d2=0;
            Double sum1=0, sum2=0;
            String ds='';
            for(String s:levelABC){
                //String color=colors[colorIndex];
                String color = this.getColor(colorIndex) ;
                level_TypeNameMap = map_Type_Level.get(s) ;
                system.debug(s+'HHHHHHEEEEEE'+level_TypeNameMap) ;
                if(level_TypeNameMap != null)
                {
                    for(String strType : level_TypeNameMap.keySet())
                    {
                        if(bln)chxl+='|' ;
                        if(bln)chxl+=strType ;
                        ds += level_TypeNameMap.get(strType) ;
                        ds += ',' ;
                        
                        
                    }
                }else
                {
                    for(Integer inS = 0; inS<map_TypeTimes.size(); inS++)
                    {
                        system.debug(ds) ;
                        ds+=0;
                        ds+=',' ;
                        system.debug('MMMENEN'+ds) ;
                    }
                }
                
                //d1=level_adjustTimesMap.containsKey(s)?level_adjustTimesMap.get(s):0;
                //d2=level_completeMap.containsKey(s)?level_completeMap.get(s):0;
                if(colorIndex>0 && colorIndex<levelABC.size()){
                    chco+=',';
                    //chdl+='|';
                    
                    
                    //chxl+='|' ;
                }
                if(ds.length() != 0)
                {
                    ds = ds.substring(0,ds.length()-1) ;
                }
                ds+='|';
                //sum1+=d1;
                //sum2+=d2;
                chco+=color;
                //chdl+=s;
                //ds+=d1+','+d2;
                colorIndex++;
                bln = false ;
            }
            if(map_TypeTimes.size() != 0)
            {
                for(Integer intS : map_TypeTimes.values())
                {
                    vAxisMax=vAxisMax>intS?vAxisMax:intS + 1 ;
                }
            }
            if(ds.length() != 0)
            {
                ds = ds.substring(0,ds.length()-1) ;
            }
            system.debug(chxl+'DDDDDDDDDDSSSSSSSSSS'+ds) ;
            //vAxisMax=sum1>sum2?sum1:sum2;
            if(vAxisMax<5)vAxisMax=5;
            Integer widht=600,height=180;
            Integer vInc=colorIndex<5?Integer.valueOf(vAxisMax/5):Integer.valueOf(vAxisMax/colorIndex);//Y轴递增量
            if(vInc<1)vInc=1; 
            //String lk='cht=bvs&chs=300x180&chd=t:20,35|30,55|5,25&chxr=1,0,120&chds=0,120&chco=0A8C8A,EBB671,DE091A&chbh=45,20,15&chxt=x,y&chxl=0:|计划|实际&chdl=A|B|C';
            String lk='cht=bvs&chs='+widht+'x'+height+'&chd=t:'+ds+'&chxr=1,0,'+vAxisMax+'&chds=0,'+vAxisMax+'&chco='+chco+'&chbh=45,20,15&chxt=x,y&chxl=0:'+chxl+'&chdl=A|B|C';
            system.debug('LK:'+lk);
            return lk;
        }  
    }
    //拜访完成情况（次数）3  FOR BIOS
    public String visitComplete3AccountNames{public get;private set;}
    public String visitComplete3{
        get{
            Double vAxisMax=0;//纵轴最大值=Max(访前计划汇总记录上,访后分析汇总记录数)
            List<String> standardSortAccountNameList=new List<String>();
            Set<String> standardSortAccountNameSet=new Set<String>(); 
            Map<String,String> accountName_color_map=new Map<String,String>();
            Map<String,Double> accountName_Num_PlanMap=new Map<String,Double>();
            Map<String,Double> accountName_Num_CompleteMap=new Map<String,Double>();
            
            //获取月计划中月计划明细的总计划次数
            AggregateResult[] rs = [SELECT Sum(AdjustedTimes__c) num,Account__r.name FROM MonthlyPlanDetail__c 
                where Account__r.name!=null and MonthlyPlan__c=:objMonthlyPlan.Id group by Account__r.name];
            for(AggregateResult r:rs)
            {
                if(r!=null && r.get('name')!=null)
                {
                    String accountName=String.valueOf(r.get('name'));
                    if(accountName!=null){
                    Double d=r.get('num')==null?0:Double.valueOf(r.get('num'));//当前客户计划记录数
                    if(!standardSortAccountNameSet.contains(accountName)){
                        standardSortAccountNameList.add(accountName);
                        standardSortAccountNameSet.add(accountName);
                    }
                    accountName_Num_PlanMap.put(accountName,d);
                    }
                }
            }
            //已完成,未过期
            for(Contact objCon : map_conId.values())
            {
                String accountName= objCon.Account.Name;
                if(accountName == null)
                {
                    continue ;
                }
                if(!standardSortAccountNameSet.contains(accountName)){
                    standardSortAccountNameList.add(accountName);
                    standardSortAccountNameSet.add(accountName);
                }
                if(accountName_Num_CompleteMap.containsKey(accountName))
                {
                    Double douCount = accountName_Num_CompleteMap.get(accountName) ;
                    douCount++ ;
                    accountName_Num_CompleteMap.put(accountName,douCount);
                }else
                {
                    accountName_Num_CompleteMap.put(accountName,1);
                }
                
            }
           
            ////////////////////////////combine
            String chco='';
            String chdl='';
            Integer colorIndex=0;
            Double d1=0,d2=0;
            String ds='';
            String ds1='';
            String ds2='';
            String chxl='';
            visitComplete3AccountNames='';
            for(String s:standardSortAccountNameList){
                //String color=colors[colorIndex];
                String ans='Acc'+colorIndex;
                chxl=chxl+'|'+ans;
                visitComplete3AccountNames=visitComplete3AccountNames+'    '+ans+':  '+s+'<br/>';
                d1=accountName_Num_PlanMap.containsKey(s)?accountName_Num_PlanMap.get(s):0;
                d2=accountName_Num_CompleteMap.containsKey(s)?accountName_Num_CompleteMap.get(s):0;
                
                vAxisMax=vAxisMax<d1?d1:vAxisMax;
                vAxisMax=vAxisMax<d2?d2:vAxisMax;
                vAxisMax+=1;
                
                ds1+=Integer.valueOf(d1)+',';
                ds2+=Integer.valueOf(d2)+',';
                
                colorIndex++;
            }
            chco=colors.get(0)+','+colors.get(1);
            if(ds1.length()>1)ds1=ds1.subString(0,ds1.length()-1);
            if(ds2.length()>1)ds2=ds2.subString(0,ds2.length()-1);
            ds=ds1+'|'+ds2;
            if(vAxisMax<5)vAxisMax=5;
            Integer widht=500;
            Integer height=180;
            if(height<100)height=100;
            Integer vInc=colorIndex<5?Integer.valueOf(vAxisMax/5):Integer.valueOf(vAxisMax/colorIndex);//Y轴递增量
            if(vInc<1)vInc=1;
            Integer iVmax=Integer.valueOf(vAxisMax);
            chdl='计划|实际';
            String lk='cht=bvg&chbh=25,0,18&chs='+widht+'x'+height+'&chd=t:'+ds+'&chxr=1,0,'+iVmax+','+vInc+'&chds=0,'+iVmax+',0,'+iVmax+'&chco='+chco+'&chxt=x,y&chxl=0:'+chxl+'&chdl='+chdl;
            return lk;
            //return 'chxl=1:|计划次数|完成次数&chxr=0,0,'+vAxisMax+'|1,10,100&chxt=y,x&chbh=a,40&chs='+widht+'x'+height+'&cht=bvs&chco='+chco+'&chds=0,'+vAxisMax+',0,'+vAxisMax+'&chd=t:'+ds+'&chdl='+chdl+'&chma=|190';
        }
    }
    //拜访完成情况（次数） 2 FOR MD
    public String VisitCompleteCountConditionMD
    {
        get   
        {
            Double vAxisMax=0;//纵轴最大值=Max(访前计划汇总记录上,访后分析汇总记录数)
            List<String> standardSortAccountNameList=new List<String>();
            Set<String> standardSortAccountNameSet=new Set<String>(); 
            Map<String,String> accountName_color_map=new Map<String,String>();
            Map<String,Double> accountName_Num_PlanMap=new Map<String,Double>();
            Map<String,Double> accountName_Num_CompleteMap=new Map<String,Double>();
            
            //获取月计划中月计划明细的总计划次数
            AggregateResult[] rs = [SELECT Sum(AdjustedTimes__c) num,Account__r.name FROM MonthlyPlanDetail__c 
                where Account__r.name!=null and MonthlyPlan__c=:objMonthlyPlan.Id group by Account__r.name];
            for(AggregateResult r:rs)
            {
                if(r!=null)
                {
                    String accountName=String.valueOf(r.get('name'));
                    if(accountName!=null){
                    Double d= Double.valueOf(r.get('num'));//当前客户计划记录数
                    if(!standardSortAccountNameSet.contains(accountName)){
                        standardSortAccountNameList.add(accountName);
                        standardSortAccountNameSet.add(accountName);
                    }
                    accountName_Num_PlanMap.put(accountName,d);
                    }
                }
            }
            //已完成,未过期
            for(Contact objCon : map_conId.values())
            {
                String accountName= objCon.Account.Name;
                system.debug('-----------'+accountName) ;
                if(accountName == null)
                {
                    continue ;
                }
                if(!standardSortAccountNameSet.contains(accountName)){
                    standardSortAccountNameList.add(accountName);
                    standardSortAccountNameSet.add(accountName);
                }
                if(accountName_Num_CompleteMap.containsKey(accountName))
                {
                    Double douCount = accountName_Num_CompleteMap.get(accountName) ;
                    douCount++ ;
                    accountName_Num_CompleteMap.put(accountName,douCount);
                }else
                {
                    accountName_Num_CompleteMap.put(accountName,1);
                }
                
            }
            ////////////////////////////combine
            String chco='';
            String chdl='';
            Integer colorIndex=0;
            Double d1=0,d2=0;
            Double sum1=0, sum2=0;
            String ds='';
            system.debug('I want to know size '+standardSortAccountNameList.size()) ;
            for(String s:standardSortAccountNameList){
                //String color=colors[colorIndex];
                String color = this.getColor(colorIndex) ;
                d1=accountName_Num_PlanMap.containsKey(s)?accountName_Num_PlanMap.get(s):0;
                d2=accountName_Num_CompleteMap.containsKey(s)?accountName_Num_CompleteMap.get(s):0;
                if(colorIndex>0 && standardSortAccountNameList!=null && colorIndex<standardSortAccountNameList.size()){
                    chco+=',';
                    chdl+='|';
                    ds+='|';
                }
                sum1+=d1;
                sum2+=d2;
                chco+=color;
                chdl+=s;
                ds+=d1+','+d2;
                colorIndex++;
            }
            system.debug('=========='+ds) ;
            vAxisMax=sum1>sum2?sum1:sum2;
            if(vAxisMax<5)vAxisMax=5;
            Integer widht=270;
            Integer height=standardSortAccountNameList==null?180:standardSortAccountNameList.size()*18;//180;
            if(height<180)height=180;
            Integer vInc=colorIndex<5?Integer.valueOf(vAxisMax/5):Integer.valueOf(vAxisMax/colorIndex);//Y轴递增量
            if(vInc<1)vInc=1;
            //return 'chxl=1:|计划次数|完成次数&chxr=0,0,'+vAxisMax+'|1,10,100&chxt=y,x&chbh=a,40&chs=340x180&cht=bvs&chco='+chco+'&chds=0,'+vAxisMax+',0,155&chd=t:'+ds+'&chdl='+chdl+'&chma=|190';
            system.debug('ASASASASASA:'+'chxl=1:|计划次数|完成次数&chxr=0,0,'+vAxisMax+'|1,10,100&chxt=y,x&chbh=a,40&chs='+widht+'x'+height+'&cht=bvs&chco='+chco+'&chds=0,'+vAxisMax+',0,'+vAxisMax+'&chd=t:'+ds+'&chdl='+chdl+'&chma=|190') ;
            return 'chxl=1:|计划次数|完成次数&chxr=0,0,'+vAxisMax+'|1,10,100&chxt=y,x&chbh=a,40&chs='+widht+'x'+height+'&cht=bvs&chco='+chco+'&chds=0,'+vAxisMax+',0,'+vAxisMax+'&chd=t:'+ds+'&chdl='+chdl+'&chma=|190';
        }  
    }
    private String getColor(Integer intIndex)
    {
        if(intIndex >= colors.size())
        {
            return this.getColor(intIndex - colors.size()) ;
        }else
        {
            return colors[intIndex] ;
        }
    }
    ///////////////
    //科内会 FOR BIOS
    public List<DepartmentVisit> getDepartmentVisits(){ 
        //List<Department_Visit__c> dvs=objMonthlyPlan.Department_Visit__r;
        //return dvs==null?new List<Department_Visit__c>():dvs;
        integer year = integer.valueOf(this.objMonthlyPlan.Year__c);
        integer month = integer.valueOf(this.objMonthlyPlan.Month__c);
        DateTime startMonthTime = DateTime.newInstanceGmt(year, month, 1);
        DateTime endMonthTime = startMonthTime;
        endMonthTime = endMonthTime.addMonths(1);
        List<DepartmentVisit> list_DepartmentVisit = new List<DepartmentVisit>();
        DepartmentVisit objDepartmentVisit ;
        List<Event> list_Ev = New List<Event>() ;
        List<ID> list_Ids = new List<ID>() ;
        Map<Id,String> map_AccName = new Map<Id,String>() ;
        for(Event objEv : [Select e.Subject, e.GAPlan__c, e.WhatId, e.GAExecuteResult__c From Event e Where StartDateTime >=: startMonthTime And StartDateTime <=: endMonthTime And SubjectType__c = '科室会' And OwnerId =: objMonthlyPlan.OwnerId])
        {
            if(objEv.WhatId != null)
            list_Ids.add(objEv.WhatId) ;
            list_Ev.add(objEv) ;
            //objDepartmentVisit=new DepartmentVisit() ;
        }
        if(list_Ids.size() != 0)
        {
            for(Account objAc : [Select Name From Account Where Id in: list_Ids])
            {
                map_AccName.put(objAc.Id,objAc.Name) ;
            }
        }
        if(list_Ev.size() != 0)
        {
            for(Event objEve : list_Ev)
            {
                objDepartmentVisit=new DepartmentVisit() ;
                objDepartmentVisit.strHospital = map_AccName.get(objEve.WhatId) ;
                objDepartmentVisit.strTitle = objEve.Subject ;
                objDepartmentVisit.strGAPlan = objEve.GAPlan__c ;
                objDepartmentVisit.strGAExecuteResult = objEve.GAExecuteResult__c ;
                list_DepartmentVisit.add(objDepartmentVisit) ;
            }
        }
        return list_DepartmentVisit ;
        
    }
    public class DepartmentVisit
    {
        public String strHospital{get;set;}
        public String strTitle{get;set;}
        public String strGAPlan{get;set;}//GAPlan__c
        public String strGAExecuteResult{get;set;}//GAExecuteResult__c
    }
    //时间分配情况 
    public String  TimeDistributeCondition
    {
        get
        { 
            String dataStr ='';
            String titleStr = '';
            String theLatTitleStr ='';
            String theLatDataStr ='';
            Double sumDur ;
            Map<String,Double> map_Dur = new Map<String,Double>() ;
            
            if(map_EveId.size() != 0)
            {
                for(Event objEvent : map_EveId.values())
                {
                    if(!objEvent.Done__c)
                    {
                        continue ;
                    }
                    if(objEvent.DurationInMinutes == null)
                    {
                        continue ;
                    }
                    if(map_Dur.containsKey(objEvent.SubjectType__c))
                    {
                        Double douDur = map_Dur.get(objEvent.SubjectType__c) ;
                        douDur += objEvent.DurationInMinutes ;
                        map_Dur.put(objEvent.SubjectType__c, douDur) ;
                    }else
                    {
                        map_Dur.put(objEvent.SubjectType__c, objEvent.DurationInMinutes) ;
                    }
                }
            }
            if(map_Dur.size() != 0)
            {
                for(String strType : map_Dur.keySet())
                {
                    Double douSunDur = map_Dur.get(strType) ;
                    //system.debug('bai fang shijian : '+ douSunDur) ;
                    titleStr += strType + '('+ String.valueOf((douSunDur/60).round()) +'H)'+'|'; //double类型数据取整形进行四舍五入来显示
                    dataStr += String.valueOf(douSunDur/600)+',';  //实际数据还是取double类型的（）
                }
            }
            if(titleStr.length()>0){theLatTitleStr = titleStr.subString(0,titleStr.length()-1);}
            if(dataStr.length()>0){theLatDataStr= dataStr.subString(0,dataStr.length()-1);}
            return   'cht=p&chd=t:'+theLatDataStr+'&chs=400x200&chl='+theLatTitleStr+'&chco=FF9821,FCFF00,A5E400,01DEFB,2084FE,AE20FF,FC20D8,7B1CDC';
        }
    }
    /////////////////业务机会拜访情况 MD
    public String oppNameOrderListNams{public get;private set;}
    
    public String OpportunityVisitMD{
        get{
            oppNameOrderListNams='';
            List<String> roles=new List<String>();//角色:用户(U)、教练(C)、关注成本型(E)、关注技术型(T)
            roles.add('用户(U)');
            roles.add('教练(C)');
            roles.add('关注成本型(E)');
            roles.add('关注技术型(T)');
            if(baseOppList==null)baseOppList=getBaseOppListMD();
            //分离业务机会当前阶段的开始时间
            Map<String,String> oppName_stage=new Map<String,String>();
            Map<String,Datetime> oppName_stageStartDate=new Map<String,Datetime>();
            Map<String,Opportunity> oppId_opp=new Map<String,Opportunity>();
            Set<String> oppIdSet=new Set<String>();
            integer thisYear = system.now().year();
            List<String> oppNameOrderList=new List<String>();
            Set<String> oppNameOrderSet=new Set<String>();
            Datetime earliestDate= null;
            Map<String,Map<String,Integer>> oppName_role_num=new Map<String,Map<String,Integer>>();
            if(baseOppList!=null){
                for(Opportunity opp: baseOppList){
                    oppIdSet.add(opp.id);
                    oppId_opp.put(opp.id,opp);
                    String oppName=opp.Name;
                    List<OpportunityHistory> oppHstyList = opp.OpportunityHistories;
                    DateTime stageStartDate=null;
                    String stage='';
                    if(oppHstyList.size()>0){//有阶段发生变化
                        stage=oppHstyList.get(0).StageName;
                        stageStartDate=oppHstyList.get(0).CreatedDate;
                    }else{//直接取业务机会数据
                        stage=opp.StageName;
                        stageStartDate=opp.createdDate;
                    }
                    if(earliestDate==null)earliestDate=stageStartDate;
                    oppName_stageStartDate.put(oppName,stageStartDate);
                    if(earliestDate>stageStartDate)earliestDate=stageStartDate;//取得查询访问记录时的最早的时间
                    oppName_stage.put(oppName,stage); 
                    
                    if(!oppNameOrderSet.contains(oppName)){
                        oppNameOrderSet.add(oppName);
                        oppNameOrderList.add(oppName);
                    }
                    //////////////////
                    //List<CallRecord__c> crs=opp.CallRecord__r;//该业务机会的拜访次数
                    List<Event> list_ev = opp.Events ;
                    //List<Contact_Rule__c> ctt_rules=opp.R00NR0000000I5oiMAC;//sandbox
                    List<Contact_Rule__c> ctt_rules=opp.R00NR0000000I5oiMAC__r;//production

                    Map<String,Integer> role_num=oppName_role_num.containsKey(oppName)?
                        oppName_role_num.get(oppName):new Map<String,Integer>();
                    for(Event cr:list_ev){
                        if(cr.CreatedDate<stageStartDate)continue;//如果该拜访记录的创建时间在opp该阶段之前,不用计算
                        //if(cr.WhoId==null)continue;
                        String crId=cr.WhoId;//拜访记录中的"目标联系人的联系人ID"
                        if(ctt_rules != null && ctt_rules.size() != 0){
                            system.debug('OMGGG=='+ctt_rules) ;
                            for(Contact_Rule__c crT:ctt_rules){ //该业务机会的联系人角色列表
                                system.debug('OMGGG'+crT) ;
                                string strl = 'er' ;
                                system.debug('crT.Contact__c ----------------' + crT.Contact__c) ;//if(crT == null)continue ;
                                String crTId=crT.Contact__c;//联系人角色中的"联系人ID"
                                system.debug('-----------------didnt run');
                                String role=crT.Role__c;
                                system.debug('-----------------didnt run2');
                                if(crTId == null)crTId = '' ;
                                if(crId == null)crTId = '' ;
                                system.debug('-----------------didnt run3');
                                if(crTId == crId){//检测联系人角色中是否存在该拜访记录的目标联系人
                                    system.debug('-----------------didnt run4');
                                    Integer num=role_num.containsKey(role)?role_num.get(role):0;
                                    system.debug('-----------------didnt run5');
                                    num++;
                                    role_num.put(role,num);
                                }
                            }
                        }
                        
                    }
                    system.debug('xxxx-xxxx') ;
                    oppName_role_num.put(oppName,role_num);
                    system.debug('xxxx--xxxx') ;
                }
            }
            String chdl_roles='';
            String chco_s='';
            Integer idx=0;
            system.debug('xxxx---xxxx') ;
            for(String s:roles){
                if(idx>0 && idx<roles.size()){
                    chdl_roles=chdl_roles+'|';
                    chco_s=chco_s+',';
                }
                chdl_roles=chdl_roles+s;
                chco_s=chco_s+colors[idx];
                idx++;
            }
            system.debug('xxxx----xxxx') ;
            String chxl_stage_oppNames='';
            String chxl_stage_oppNames_x='';
            String chxl_stage_oppNames_x_c='';
            idx=0;
            Integer cLen=0;
            Integer lineWordsNum=20;//words length of every line.
            system.debug('xxxx-----xxxx') ;
            for(String oppName:oppNameOrderList){
                String ss='s'+idx;
                String stage=oppName_stage.get(oppName);
                if(idx>0 && idx<oppNameOrderList.size()){ 
                    //chxl_stage_oppNames=chxl_stage_oppNames+'|';
                    chxl_stage_oppNames=chxl_stage_oppNames+'|';
                    oppNameOrderListNams=oppNameOrderListNams+'<br/>';
                    chxl_stage_oppNames_x=chxl_stage_oppNames_x+'|';
                    chxl_stage_oppNames_x_c=chxl_stage_oppNames_x_c+',';
                }
                String tpN=oppName.trim().replaceAll('\\s','');
                if(tpN.length()>20)tpN=tpN.substring(0,20);
                //if(tpN.length()>lineWordsNum)tpN=wrapLine2(tpN,lineWordsNum, 2);
                String son=ss+':'+stage+'('+tpN+')';
                if(cLen<tpN.length())cLen=tpN.length(); 
                //chxl_stage_oppNames=chxl_stage_oppNames+ss;
                chxl_stage_oppNames=chxl_stage_oppNames+stage+'('+tpN+')';
                oppNameOrderListNams=oppNameOrderListNams+son;
                chxl_stage_oppNames_x=chxl_stage_oppNames_x+son;
                //chxl_stage_oppNames_x=chxl_stage_oppNames_x.replaceAll('__的业务机会','').replaceAll('_的业务机会','');
                chxl_stage_oppNames_x_c=chxl_stage_oppNames_x_c+'FFFFFF';
                idx++;
            }
            system.debug('xxxx=xxxx') ;
            //chxl_stage_oppNames_x=chxl_stage_oppNames_x.replace('__的业务机会','').replace('_的业务机会','');
            idx=0;
            String chd_times=''; 
            Integer max001=0;
            for(String role:roles){ //组合各业务机会各角色次数.
                String chd_time='';
                if(idx>0 && idx<roles.size()){
                    chd_times=chd_times+'|';
                }
                Integer oppIdx=0;
                Integer m=0;
                for(String oppName:oppNameOrderList){
                    if(oppIdx>0 && oppIdx<oppNameOrderList.size()){
                        chd_time=chd_time+',';
                    }
                    Map<String,Integer> role_num=oppName_role_num.get(oppName);
                    Integer num=0;
                    if(role_num!=null && role_num.containsKey(role)){
                        num=role_num.get(role);
                        m=m+num;
                    }
                    System.debug(oppName+'['+role+':'+num+']');
                    chd_time=chd_time+num;
                    oppIdx++;
                }
                if(max001<m)max001=m;
                chd_times=chd_times+chd_time;
                idx++;
            }
            system.debug('xxxx==xxxx') ;
            max001=max001+5;
            
            //maximum size of 300000 pixels
            Integer width=0,height=0; 
            height=oppNameOrderList.size()*22+40;
            width=300000/height-30;
            if(width>560)width=550;
            if(width<360) width=360; 
            if(chxl_stage_oppNames_x!='')
                chxl_stage_oppNames_x='||'+chxl_stage_oppNames_x;
            if(chxl_stage_oppNames_x_c!='')
                chxl_stage_oppNames_x_c=',FFFFFF,'+chxl_stage_oppNames_x_c; 
            //chd_times='1,2,3,4|1,1,1,1|1,2,1,1|2,3,6,5';
            Integer vInc=5;//X轴递增量
            //String lk='https://chart.googleapis.com/chart?chs='+width+'x'+height+'&chxl=1:|'+chxl_stage_oppNames+'&chxr=0,0,'+max001+'&chxt=y,x'+'&chbh=a'+'&cht=bvs'+'&chco='+chco_s+chxl_stage_oppNames_x_c+'&chds=0,'+max001+',0,'+max001+'&chd=t:'+chd_times+'&chdlp=bv&chdl='+chdl_roles+chxl_stage_oppNames_x;
               // +'&chtt=业务机会拜访情况';
            String lk='https://chart.googleapis.com/chart?chs='+width+'x'+height+'&chxr=0,0,'+max001+','+vInc+'&chxt=x,y&chbh=a&cht=bhs&chco='+chco_s+'&chds=0,'+max001+',0,'+max001+'&chd=t:'+chd_times+'&chdlp=b&chdl='+chdl_roles+'&chxl=1:|'+chxl_stage_oppNames;
            //String lk='https://chart.googleapis.com/chart?chs='+width+'x'+height+'&chxl=1:|'+chxl_stage_oppNames+'&chxr=0,0,'+max001+','+vInc+'&chxt=y,x'+'&chbh=a'+'&cht=bvs'+'&chco='+chco_s+'&chds=0,'+max001+',0,'+max001+'&chd=t:'+chd_times+'&chdlp=b&chdl='+chdl_roles;
            return lk;
        }
    } 
    //业务机会拜访情况BIOS
    public String OpportunityVisitBios{
        get{
            oppNameOrderListNams='';
            List<String> roles=new List<String>();//角色:用户(U)、教练(C)、关注成本型(E)、关注技术型(T)
            roles.add('用户(U)');
            roles.add('教练(C)');
            roles.add('关注成本型(E)');
            roles.add('关注技术型(T)');
            if(baseOppList==null)baseOppList=getBaseOppListBios();
            //分离业务机会当前阶段的开始时间
            Map<String,String> oppName_stage=new Map<String,String>();
            Map<String,Datetime> oppName_stageStartDate=new Map<String,Datetime>();
            Map<String,Opportunity> oppId_opp=new Map<String,Opportunity>();
            Set<String> oppIdSet=new Set<String>();
            integer thisYear = system.now().year();
            List<String> oppNameOrderList=new List<String>();
            Set<String> oppNameOrderSet=new Set<String>();
            Datetime earliestDate= null;
            Map<String,Map<String,Integer>> oppName_role_num=new Map<String,Map<String,Integer>>();
            if(baseOppList!=null){
                for(Opportunity opp: baseOppList){
                    oppIdSet.add(opp.id);
                    oppId_opp.put(opp.id,opp);
                    String oppName=opp.Name;
                    List<OpportunityHistory> oppHstyList = opp.OpportunityHistories;
                    DateTime stageStartDate=null;
                    String stage='';
                    if(oppHstyList.size()>0){//有阶段发生变化
                        stage=oppHstyList.get(0).StageName;
                        stageStartDate=oppHstyList.get(0).CreatedDate;
                    }else{//直接取业务机会数据
                        stage=opp.StageName;
                        stageStartDate=opp.createdDate;
                    }
                    if(earliestDate==null)earliestDate=stageStartDate;
                    oppName_stageStartDate.put(oppName,stageStartDate);
                    if(earliestDate>stageStartDate)earliestDate=stageStartDate;//取得查询访问记录时的最早的时间
                    oppName_stage.put(oppName,stage); 
                    
                    if(!oppNameOrderSet.contains(oppName)){
                        oppNameOrderSet.add(oppName);
                        oppNameOrderList.add(oppName);
                    }
                    //////////////////
                    //List<CallRecord__c> crs=opp.CallRecord__r;//该业务机会的拜访次数
                    List<Event> list_ev = opp.Events ;
                    //List<Contact_Rule__c> ctt_rules=opp.R00NR0000000I5oiMAC;//sandbox
                    List<Contact_Rule__c> ctt_rules=opp.R00NR0000000I5oiMAC__r;//production

                    Map<String,Integer> role_num=oppName_role_num.containsKey(oppName)?
                        oppName_role_num.get(oppName):new Map<String,Integer>();
                    for(Event cr:list_ev){
                        if(cr.CreatedDate<stageStartDate)continue;//如果该拜访记录的创建时间在opp该阶段之前,不用计算
                        //if(cr.WhoId==null)continue;
                        String crId=cr.WhoId;//拜访记录中的"目标联系人的联系人ID"
                        for(Contact_Rule__c crT:ctt_rules){ //该业务机会的联系人角色列表
                            String crTId=crT.Contact__c;//联系人角色中的"联系人ID"
                            String role=crT.Role__c;
                            if(crTId == crId){//检测联系人角色中是否存在该拜访记录的目标联系人
                                Integer num=role_num.containsKey(role)?role_num.get(role):0;
                                num++;
                                role_num.put(role,num);
                            }
                        }
                    }
                    oppName_role_num.put(oppName,role_num);
                }
            }
            String chdl_roles='';
            String chco_s='';
            Integer idx=0;
            
            for(String s:roles){
                if(idx>0 && idx<roles.size()){
                    chdl_roles=chdl_roles+'|';
                    chco_s=chco_s+',';
                }
                chdl_roles=chdl_roles+s;
                chco_s=chco_s+colors[idx];
                idx++;
            }
            
            String chxl_stage_oppNames='';
            String chxl_stage_oppNames_x='';
            String chxl_stage_oppNames_x_c='';
            idx=0;
            Integer cLen=0;
            Integer lineWordsNum=20;//words length of every line.
            for(String oppName:oppNameOrderList){
                String ss='s'+idx;
                String stage=oppName_stage.get(oppName);
                if(idx>0 && idx<oppNameOrderList.size()){ 
                    //chxl_stage_oppNames=chxl_stage_oppNames+'|';
                    chxl_stage_oppNames=chxl_stage_oppNames+'|';
                    oppNameOrderListNams=oppNameOrderListNams+'<br/>';
                    chxl_stage_oppNames_x=chxl_stage_oppNames_x+'|';
                    chxl_stage_oppNames_x_c=chxl_stage_oppNames_x_c+',';
                }
                String tpN=oppName.trim().replaceAll('\\s','');
                if(tpN.length()>20)tpN=tpN.substring(0,20);
                //if(tpN.length()>lineWordsNum)tpN=wrapLine2(tpN,lineWordsNum, 2);
                String son=ss+':'+stage+'('+tpN+')';
                if(cLen<tpN.length())cLen=tpN.length(); 
                //chxl_stage_oppNames=chxl_stage_oppNames+ss;
                chxl_stage_oppNames=chxl_stage_oppNames+stage+'('+tpN+')';
                oppNameOrderListNams=oppNameOrderListNams+son;
                chxl_stage_oppNames_x=chxl_stage_oppNames_x+son;
                //chxl_stage_oppNames_x=chxl_stage_oppNames_x.replaceAll('__的业务机会','').replaceAll('_的业务机会','');
                chxl_stage_oppNames_x_c=chxl_stage_oppNames_x_c+'FFFFFF';
                idx++;
            }
            //chxl_stage_oppNames_x=chxl_stage_oppNames_x.replace('__的业务机会','').replace('_的业务机会','');
            idx=0;
            String chd_times=''; 
            Integer max001=0;
            for(String role:roles){ //组合各业务机会各角色次数.
                String chd_time='';
                if(idx>0 && idx<roles.size()){
                    chd_times=chd_times+'|';
                }
                Integer oppIdx=0;
                Integer m=0;
                for(String oppName:oppNameOrderList){
                    if(oppIdx>0 && oppIdx<oppNameOrderList.size()){
                        chd_time=chd_time+',';
                    }
                    Map<String,Integer> role_num=oppName_role_num.get(oppName);
                    Integer num=0;
                    if(role_num!=null && role_num.containsKey(role)){
                        num=role_num.get(role);
                        m=m+num;
                    }
                    System.debug(oppName+'['+role+':'+num+']');
                    chd_time=chd_time+num;
                    oppIdx++;
                }
                if(max001<m)max001=m;
                chd_times=chd_times+chd_time;
                idx++;
            }
            max001=max001+5;
            
            //maximum size of 300000 pixels
            Integer width=0,height=0; 
            height=oppNameOrderList.size()*22+40;
            width=300000/height-30;
            if(width>560)width=550;
            if(width<360) width=360; 
            if(chxl_stage_oppNames_x!='')
                chxl_stage_oppNames_x='||'+chxl_stage_oppNames_x;
            if(chxl_stage_oppNames_x_c!='')
                chxl_stage_oppNames_x_c=',FFFFFF,'+chxl_stage_oppNames_x_c; 
            //chd_times='1,2,3,4|1,1,1,1|1,2,1,1|2,3,6,5';
            Integer vInc=5;//X轴递增量
            //String lk='https://chart.googleapis.com/chart?chs='+width+'x'+height+'&chxl=1:|'+chxl_stage_oppNames+'&chxr=0,0,'+max001+'&chxt=y,x'+'&chbh=a'+'&cht=bvs'+'&chco='+chco_s+chxl_stage_oppNames_x_c+'&chds=0,'+max001+',0,'+max001+'&chd=t:'+chd_times+'&chdlp=bv&chdl='+chdl_roles+chxl_stage_oppNames_x;
               // +'&chtt=业务机会拜访情况';
            String lk='https://chart.googleapis.com/chart?chs='+width+'x'+height+'&chxr=0,0,'+max001+','+vInc+'&chxt=x,y&chbh=a&cht=bhs&chco='+chco_s+'&chds=0,'+max001+',0,'+max001+'&chd=t:'+chd_times+'&chdlp=b&chdl='+chdl_roles+'&chxl=1:|'+chxl_stage_oppNames;
            //String lk='https://chart.googleapis.com/chart?chs='+width+'x'+height+'&chxl=1:|'+chxl_stage_oppNames+'&chxr=0,0,'+max001+','+vInc+'&chxt=y,x'+'&chbh=a'+'&cht=bvs'+'&chco='+chco_s+'&chds=0,'+max001+',0,'+max001+'&chd=t:'+chd_times+'&chdlp=b&chdl='+chdl_roles;
            return lk;
        }
    } 
    //当前月计划Owner所负责的业务机会* XXX
    //仅包括MD的业务机会阶段：'发现机会','建立渠道','需求分析','业务谈判','产品使用','基本量完成'
    private List<Opportunity> getBaseOppListMD()
    {
        integer year = integer.valueOf(this.objMonthlyPlan.Year__c);
        integer month = integer.valueOf(this.objMonthlyPlan.Month__c);
        DateTime startMonthTime = DateTime.newInstanceGmt(year, month, 1);
        DateTime endMonthTime = startMonthTime;
        endMonthTime = endMonthTime.addMonths(1);
        List<Opportunity> oppList = [Select Id, Name,
            StageName, 
            Probability, 
            CloseDate, 
            AccountId,
            Account.Id,
            Account.Name, 
            CreatedDate,
            Strategy__c,
            (Select CreatedDate, StageName, CloseDate, Probability From OpportunityHistories Where StageName in: mdStageList Order By CreatedDate Desc), 
            (Select Id, StartDateTime , CreatedDate, WhoId
                From Events 
                Where StartDateTime >=: startMonthTime And StartDateTime <=: endMonthTime)
            //,(SELECT Id,Role__c,name,Contact__c From R00NR0000000I5oiMAC) //sandbox
            ,(SELECT Id,Role__c,name,Contact__c From R00NR0000000I5oiMAC__r) //production
            From Opportunity 
            Where OwnerId =: objMonthlyPlan.OwnerId
            And StageName in : mdStageList];
            return oppList;
    }
    //当前月计划Owner所负责的业务机会* XXX
    //仅包括MD的业务机会阶段：'发现机会','建立渠道','需求分析','业务谈判','产品使用','基本量完成'
    private List<Opportunity> getBaseOppListBios()
    {
        integer year = integer.valueOf(this.objMonthlyPlan.Year__c);
        integer month = integer.valueOf(this.objMonthlyPlan.Month__c);
        DateTime startMonthTime = DateTime.newInstanceGmt(year, month, 1);
        DateTime endMonthTime = startMonthTime;
        endMonthTime = endMonthTime.addMonths(1);
        List<Opportunity> oppList = [Select Id, Name,
            StageName, 
            Probability, 
            CloseDate, 
            AccountId,
            Account.Id,
            Account.Name, 
            CreatedDate,
            Strategy__c,
            (Select CreatedDate, StageName, CloseDate, Probability From OpportunityHistories Where StageName in: mdStageList Order By CreatedDate Desc), 
            (Select Id, StartDateTime , CreatedDate, WhoId
                From Events 
                Where StartDateTime >=: startMonthTime And StartDateTime <=: endMonthTime)
            //,(SELECT Id,Role__c,name,Contact__c From R00NR0000000I5oiMAC) //sandbox
            ,(SELECT Id,Role__c,name,Contact__c From R00NR0000000I5oiMAC__r) //production
            From Opportunity 
            Where OwnerId =: objMonthlyPlan.OwnerId
            And StageName in : biosStageList];
            return oppList;
    }
    //主管协访情况
    public List<ManHelpCondition> getManHelpConditionList()
    {  
        List<ManHelpCondition> ManHelpConditionList = new List<ManHelpCondition>();
        Map<ID,Double> map_EventComm = new Map<ID,Double>();
        Map<ID,Double> map_EventCommNum = new Map<ID,Double>();
        for(AssVisitComments__c avc : [Select Id,EventId__c,Grade__c From AssVisitComments__c Where EventId__c in: map_EveId.keySet() And BeReviewed__c =: objMonthlyPlan.OwnerId And Grade__c!=null]){
            if(map_EventComm.containsKey(avc.EventId__c)){
                Double d = map_EventComm.get(avc.EventId__c);
                d=d+double.valueOf(avc.Grade__c);
                map_EventComm.put(avc.EventId__c , d);
                
                Double dn = map_EventCommNum.get(avc.EventId__c);
                dn++;
                map_EventCommNum.put(avc.EventId__c , dn);
            }else{
                map_EventComm.put(avc.EventId__c , double.valueOf(avc.Grade__c));
                map_EventCommNum.put(avc.EventId__c , 1);
            }
        }
        
        for(Event objEve : map_EveId.values())
        {
            if(objEve.EventAttendees == null || objEve.EventAttendees.size() == 0)
            {
                continue ;
            }
            //判断是否其直接上级的协访
            //for(EventAttendee objEventAtt : objEve.EventAttendees)
            //{
            //  if(objEventAtt.AttendeeId == this.ManagerId)
            //  {
            //      
            //  }
            //}
            if(map_EvIdContact.containsKey(objEve.Id))
            {
                ManHelpCondition objMHC = new ManHelpCondition() ;
                Contact objCon = map_EvIdContact.get(objEve.Id) ;
                objMHC.account = objCon.Account.Name ;
                objMHC.startDate = objEve.StartDateTime ;
                objMHC.contact = objCon.Name ;
                objMHC.plan = wrapLine(objEve.GAPlan__c , 10) ;
                objMHC.analysis = wrapLine(objEve.GAExecuteResult__c , 10) ;
                objMHC.remark = wrapLine(objEve.CommentsBySupervisor__c,10) ;
                if(map_EventCommNum.containsKey(objEve.Id) && map_EventCommNum.size() != 0 && map_EventComm.size() != 0){
                    system.debug(objEve.Id+' '+map_EventCommNum+' -- '+map_EventComm);
                    objMHC.Grade = map_EventComm.get(objEve.Id) / map_EventCommNum.get(objEve.Id) ;
                }
                
                
                ManHelpConditionList.add(objMHC) ;
            }   
        }
        return ManHelpConditionList;
    } 
    //主管协访协助类
    public class ManHelpCondition {  
        public DateTime startDate{get;set;}  // 开始时间
        public String account{get;set;}  // 客户
        public String contact{get;set;} // 联系人
        public String plan{get;set;}    // 访前计划
        
        public String analysis{get;set;} //   访后分析
        public String remark{get;set;}   // 主管评语
        public Decimal Grade{get;set;}
    }
    //月计划明细（按医院）    
    public List<MonthlyPlanDetailByAccount> getMonthlyPlanDetailList()
    {
        //声明自定义的月计划明细（按医院）
        List<MonthlyPlanDetailByAccount>  monthPlanDetailByAccList = new List<MonthlyPlanDetailByAccount>();
        
        for(MonthlyPlanDetailByAccount__c objMonthlyDetailByAcc : [select Account__r.Name ,
                    CallTarget__c,MonthlyBrief__c,PlannedTimes__c, ActualTimes__c 
                    from MonthlyPlanDetailByAccount__c 
                    where MonthlyPlan__c =:objMonthlyPlan.Id order by PlannedTimes__c desc])
        {
            MonthlyPlanDetailByAccount objMonthlyDetByAcc = new MonthlyPlanDetailByAccount() ;
            objMonthlyDetByAcc.account = objMonthlyDetailByAcc.Account__r.Name ;
            objMonthlyDetByAcc.account = wrapLine(objMonthlyDetByAcc.account, 10);
            objMonthlyDetByAcc.visitTarget = objMonthlyDetailByAcc.CallTarget__c;   //拜访目标
            objMonthlyDetByAcc.visitTarget =wrapLine(objMonthlyDetByAcc.visitTarget,23);  
            objMonthlyDetByAcc.monthSummary = objMonthlyDetailByAcc.MonthlyBrief__c; //每月小结
            objMonthlyDetByAcc.monthSummary =wrapLine(objMonthlyDetByAcc.monthSummary,23);
            if(objMonthlyDetailByAcc.PlannedTimes__c != null)
            {
                objMonthlyDetByAcc.planCount = Integer.valueOf(objMonthlyDetailByAcc.PlannedTimes__c) ;
            }
            if(objMonthlyDetailByAcc.ActualTimes__c != null)
            {
                objMonthlyDetByAcc.realCount = Integer.valueOf(objMonthlyDetailByAcc.ActualTimes__c) ; 
            }
            monthPlanDetailByAccList.add(objMonthlyDetByAcc) ;
        }
        
        return monthPlanDetailByAccList;
    } 
    //月计划明细（按医院）
    public class MonthlyPlanDetailByAccount {  
        public MonthlyPlanDetailByAccount ()
        {
            planCount = 0;
            realCount = 0;
        }
        public String accountId {get;set;} // 客户Id
        public String account{get;set;}  //医院名称
        public String visitTarget{get;set;}  //拜访目标
        public String monthSummary{get;set;}    //月小结
        public Integer planCount{get;set;}  //计划次数
        public Integer realCount{get;set;}  //实际次数
    }
    //今年市场活动情况
    public List<YearMarketActivityCondition> getActiveSignUpList() 
    {
        integer year = integer.valueOf(objMonthlyPlan.Year__c);             //本月计划的年份
        Date startYearTime = Date.newinstance(year, 1, 1);       //本月计划的所在年份的第一天
        Date endYearTime = Date.newinstance(year, 12, 31);       //本月计划的所在年份的最后一天
        system.debug('Find '+startYearTime) ;
        List<YearMarketActivityCondition>  YearMarketActivityConditionList = new  List<YearMarketActivityCondition>();
        for(CampaignMember objCampaignMem : [Select c.V2_Participated__c, c.V2_Account__r.Name, c.V2_Account__c, c.User__c, 
                        c.Contact.V2_RenalGrade__c, c.Contact.Name, c.ContactId, c.Campaign.EndDate, c.Campaign.StartDate, 
                        c.Campaign.Status, c.Campaign.Name, c.Contact.ContactType__c, c.CampaignId 
                        From CampaignMember c 
                        Where c.User__c =: objMonthlyPlan.OwnerId And c.Campaign.StartDate >: startYearTime And c.Campaign.EndDate <: endYearTime ])
        {
            YearMarketActivityCondition objYearCompaign = new YearMarketActivityCondition() ;
            objYearCompaign.hosName = wrapLine(objCampaignMem.V2_Account__r.Name,15) ;
            objYearCompaign.conName = objCampaignMem.Contact.Name ;
            objYearCompaign.conType = objCampaignMem.Contact.ContactType__c ;
            objYearCompaign.level = objCampaignMem.Contact.V2_RenalGrade__c ;
            objYearCompaign.marActName = wrapLine(objCampaignMem.Campaign.Name,15) ;
            if(map_CampaignCount.containsKey(objCampaignMem.CampaignId + '' + objCampaignMem.ContactId))
            {
                objYearCompaign.flowCount = map_CampaignCount.get(objCampaignMem.CampaignId + '' + objCampaignMem.ContactId) ;
            }
            objYearCompaign.actStartDate = objCampaignMem.Campaign.StartDate ;
            objYearCompaign.state = objCampaignMem.Campaign.Status ;
            objYearCompaign.isAttend = objCampaignMem.V2_Participated__c ;
            YearMarketActivityConditionList.add(objYearCompaign) ;
        }
        return YearMarketActivityConditionList ;
    }
    public class YearMarketActivityCondition {  //今年市场活动情况
        public String hosName{get;set;}  //医院名称
        public String conName{get;set;}  //联系人名称
        public String conType{get;set;}  //联系人类型 
        public String level{get;set;}    //级别
        public Integer flowCount{get;set;} //跟进次数
        public String marActName{get;set;}
        public Date actStartDate{get;set;}
        public String state{get;set;}
        public Boolean isAttend {get;set;} //是否参加
    }
    
    //表格的新病人情况
    public List<NewPatientCondition> getTableNewPatientConditionList()
    {
        List<NewPatientCondition>   TableNewPatientConditionList = new List<NewPatientCondition>();
        if(newPatentConditionList == null)
        {
            return TableNewPatientConditionList ;
        }
        for(NewPatientCondition newPatientCon:newPatentConditionList) 
        {
            if(newPatientCon!=null)
            {
                NewPatientCondition newpatient = new  NewPatientCondition(integer.valueOf(this.objMonthlyPlan.month__c));
                newpatient.accountName = wrapLine(newPatientCon.accountName,10);
                
                newpatient.month1PNum = newPatientCon.month1PNum;
                newpatient.month2PNum = newPatientCon.month2PNum;
                newpatient.month3PNum = newPatientCon.month3PNum;
                newpatient.month4PNum = newPatientCon.month4PNum;
                newpatient.month5PNum = newPatientCon.month5PNum;
                newpatient.month6PNum = newPatientCon.month6PNum;
                newpatient.month7PNum = newPatientCon.month7PNum;
                newpatient.month8PNum = newPatientCon.month8PNum;
                newpatient.month9PNum = newPatientCon.month9PNum;
                newpatient.month10PNum = newPatientCon.month10PNum;
                newpatient.month11PNum = newPatientCon.month11PNum;
                newpatient.month12PNum = newPatientCon.month12PNum;
                newpatient.month12PNum = newPatientCon.month12PNum;
                        
                newpatient.pNum =newPatientCon.pNum;
                TableNewPatientConditionList.add(newpatient);
            }

       }
       return  TableNewPatientConditionList;
    }
    //新病人情况类
    public class NewPatientCondition 
    {  
        public NewPatientCondition(integer currMonth)
        {
            month1PNum = 0;
            month2PNum = 0;
            month3PNum = 0;
            month4PNum = 0;
            month5PNum = 0;
            month6PNum = 0;
            month7PNum = 0;
            month8PNum = 0;
            month9PNum = 0;
            month10PNum = 0;
            month11PNum = 0;
            month12PNum = 0;
            this.currentMonth = currMonth;
        }
        public String accountName{get;set;}
        public Id accountId{get;set;}
        public integer pNum {
            
            get
            {
                return 
                 month1PNum + month2PNum + 
                 month3PNum + month4PNum + 
                 month5PNum + month6PNum +
                 month7PNum + month8PNum + 
                 month9PNum + month10PNum + 
                 month11PNum + month12PNum ;     
            }
            set;
            }
        public integer month1PNum{get;set;}
        public integer month2PNum{get;set;}
        public integer month3PNum{get;set;}
        public integer month4PNum{get;set;}
        public integer month5PNum{get;set;}
        public integer month6PNum{get;set;}
        public integer month7PNum{get;set;}
        public integer month8PNum{get;set;}
        public integer month9PNum{get;set;}
        public integer month10PNum{get;set;}
        public integer month11PNum{get;set;}
        public integer month12PNum{get;set;}
        public integer currentMonth{get;set;}
    }
    //由当前月计划的所有人在当前年所拥有的月计划相关的新病人提交记录
    //按照插管医院和月份分组   
    public void getNewPatientCondition()  //新病人情况
    {
        String theYear = objMonthlyPlan.Year__c;
            //Integer theYear = Integer.valueOf(this.monthPlan.Year__c);            //本月计划的年份
            //Integer theMonth = Integer.valueOf(this.monthPlan.Month__c);          //本月计划的月份
            //DateTime startMonthTime = DateTime.newInstanceGmt(theYear, theMonth, 1); //本月计划的第一天
            //DateTime endMonthTime = startMonthTime.addMonths(1);          
        Map<Id, NewPatientCondition> accPatientMap = new Map<Id,NewPatientCondition>();
        AggregateResult[] rs=[Select count(Id) pCount,
            PatientApply__r.Month__c, 
            IntubationHospital__r.Name,
            IntubationHospital__r.Id  
            From PatientApply__c 
            //2013-12-18 sunny 修改新病人提交的筛选条件由CSR通过 --> 通过
            Where PatientApply__r.OwnerId= :objMonthlyPlan.Owner.Id and (Status__c=:'CSR通过' or Status__c=:'通过') 
            And PatientApply__r.Year__c=:theYear   
            Group by IntubationHospital__r.Id, 
            IntubationHospital__r.Name,
            PatientApply__r.Month__c]; 
            System.debug('新病人情况xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx '+rs.size());    
        for(AggregateResult r:rs) 
        {
            if(r!=null)
            {
                String accId = String.valueOf(r.get('Id'));
                Integer month = Integer.valueOf(r.get('Month__c'));
                Integer pCount = Integer.valueOf(r.get('pCount')); 
                NewPatientCondition accPatient;
                if(accPatientMap.containsKey(accId))
                {
                    accPatient = accPatientMap.get(accId);
                }
                else
                {   Integer theMonth =  Integer.valueOf(this.objMonthlyPlan.month__c);
                    if(theMonth!=null)
                    {
                        accPatient = new NewPatientCondition(theMonth);
                    }   
                }
                accPatient.accountId = accId;
                accPatient.accountName = String.valueOf(r.get('Name'));// wrapLine(String.valueOf(r.get('Name')),10) ;  
                
                if(month == 1)
                {
                    accPatient.month1PNum += pCount;
                }
                else if(month == 2)
                {
                    accPatient.month2PNum += pCount;
                }
                else if(month == 3)
                {
                    accPatient.month3PNum += pCount;
                }
                else if(month == 4)
                {
                    accPatient.month4PNum += pCount;
                }
                else if(month == 5)
                {
                    accPatient.month5PNum += pCount;
                }
                else if(month == 6)
                {
                    accPatient.month6PNum += pCount;
                }
                else if(month == 7)
                {
                    accPatient.month7PNum += pCount;
                }
                else if(month == 8)
                {
                    accPatient.month8PNum += pCount;
                }
                else if(month == 9)
                {
                    accPatient.month9PNum += pCount;
                }
                else if(month == 10)
                {
                    accPatient.month10PNum += pCount;
                }
                else if(month == 11)
                {
                    accPatient.month11PNum += pCount;
                }
                else if(month == 12)
                {
                    accPatient.month12PNum += pCount;
                }
                accPatientMap.put(accId, accPatient); //
            }
        }
        newPatentConditionList = new List<NewPatientCondition>();
        newPatentConditionList= accPatientMap.values();
        System.debug( 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx newPatentConditionList'+newPatentConditionList.size());
    }
    //新病人情况
    public String newPatientConditionStr 
    {
        get
        {   
                String theDataStr = '';
                String theTitleStr = '';
                String theLastDataStr = '';
                String theLastTitleStr = '';
                if(newPatentConditionList == null)
                {
                    return null ;
                }
                //System.debug('fffffffffffffffffffffffffff'+newPatentConditionList.size());
                for(Integer i=0;i<newPatentConditionList.size();i++)
                {
                    if(newPatentConditionList[i].month1PNum==null){newPatentConditionList[i].month1PNum=0;}
                    if(newPatentConditionList[i].month2PNum==null){newPatentConditionList[i].month2PNum=0;}
                    if(newPatentConditionList[i].month3PNum==null){newPatentConditionList[i].month3PNum=0;}
                    if(newPatentConditionList[i].month4PNum==null){newPatentConditionList[i].month4PNum=0;}
                    if(newPatentConditionList[i].month5PNum==null){newPatentConditionList[i].month5PNum=0;}
                    if(newPatentConditionList[i].month6PNum==null){newPatentConditionList[i].month6PNum=0;}
                    if(newPatentConditionList[i].month7PNum==null){newPatentConditionList[i].month7PNum=0;}
                    if(newPatentConditionList[i].month8PNum==null){newPatentConditionList[i].month8PNum=0;}
                    if(newPatentConditionList[i].month9PNum==null){newPatentConditionList[i].month9PNum=0;}
                    if(newPatentConditionList[i].month10PNum==null){newPatentConditionList[i].month10PNum=0;}
                    if(newPatentConditionList[i].month11PNum==null){newPatentConditionList[i].month11PNum=0;}
                    if(newPatentConditionList[i].month12PNum==null){newPatentConditionList[i].month12PNum=0;}
     
                    theDataStr +=newPatentConditionList[i].month1PNum 
                    +','+newPatentConditionList[i].month2PNum
                    +','+newPatentConditionList[i].month3PNum 
                    +','+newPatentConditionList[i].month4PNum
                    +','+newPatentConditionList[i].month5PNum
                    +','+newPatentConditionList[i].month6PNum
                    +','+newPatentConditionList[i].month7PNum
                    +','+newPatentConditionList[i].month8PNum
                    +','+newPatentConditionList[i].month9PNum
                    +','+newPatentConditionList[i].month10PNum
                    +','+newPatentConditionList[i].month11PNum
                    +','+newPatentConditionList[i].month12PNum
                    +'|';
                        
                    theTitleStr +=  newPatentConditionList[i].accountName +'|';
                }
                NewPatientCondition newPatientCon= this.getSumNewPatientCondition();
                Double tempMax = 0;
                Double space = (tempMax/10);
                
                List<Integer> monthPNumList = new List<Integer>();
                monthPNumList.add(newPatientCon.month1PNum);
                monthPNumList.add(newPatientCon.month2PNum);
                
                monthPNumList.add(newPatientCon.month3PNum);
                monthPNumList.add(newPatientCon.month4PNum);
                
                monthPNumList.add(newPatientCon.month5PNum);
                monthPNumList.add(newPatientCon.month6PNum);
                
                monthPNumList.add(newPatientCon.month7PNum);
                monthPNumList.add(newPatientCon.month8PNum);
                
                monthPNumList.add(newPatientCon.month9PNum);
                monthPNumList.add(newPatientCon.month10PNum);
                
                monthPNumList.add(newPatientCon.month11PNum);
                monthPNumList.add(newPatientCon.month12PNum);
                //取出新病人情况汇总行的最大值
                  for (Integer i = 0; i < monthPNumList.size(); i++) {
                       for (Integer j = i; j < monthPNumList.size(); j++) {
                            if (monthPNumList[j]>monthPNumList[i]) {
                                 Integer temp=monthPNumList[j];
                                 monthPNumList[j]=monthPNumList[i];
                                 monthPNumList[i]=temp;
                            }
                       }
                  }
                  tempMax = monthPNumList[0];
                if(theDataStr.length()>0&&theDataStr!=null){theLastDataStr =theDataStr.substring(0,theDataStr.length()-1);}
                if(theTitleStr.length()>0&&theTitleStr!=null){theLastTitleStr =theTitleStr.substring(0,theTitleStr.length()-1);}
                String x = 'cht=bvs&chs=610x200&chd=t:'+theLastDataStr+'&chco=FF9821,FCFF00,A5E400,01DEFB,2084FE,AE20FF,FC20D8,7B1CDC&chdl='+theLastTitleStr+'&chxt=x,y&chxr=1,0,'+tempMax+','+space+'&chds=0,'+tempMax+'&chxt=x,y&chl=1月|2月|3月|4月|5月|6月|7月|8月|9月|10月|11月|12月';
                x = x.replace(' ', '_');
                System.debug('ffffffffffffffffffffffffffffffffffff '+x);
                return x;
        }
    
    }    
    //新病人情况汇总行
    public NewPatientCondition getSumNewPatientCondition()
    {
        NewPatientCondition sumP = new NewPatientCondition(integer.valueOf(this.objMonthlyPlan.Month__c));
        if(newPatentConditionList == null)
        {
            return sumP ;
        }
        for(NewPatientCondition p :newPatentConditionList)
        {
            if(p.month1PNum != null)
            {
                sumP.month1PNum += p.month1PNum;
            }
            if(p.month2PNum != null)
            {
                sumP.month2PNum += p.month2PNum;
            }
            if(p.month3PNum != null)
            {
            sumP.month3PNum += p.month3PNum;
            }
            if(p.month4PNum != null)
            {
            sumP.month4PNum += p.month4PNum;
            }
            if(p.month5PNum != null)
            {
            sumP.month5PNum += p.month5PNum;
            }
            if(p.month6PNum != null)
            {
            sumP.month6PNum += p.month6PNum;
            }
            if(p.month7PNum != null)
            {
            sumP.month7PNum += p.month7PNum;
            }
            if(p.month8PNum != null)
            {
            sumP.month8PNum += p.month8PNum;
            }
            if(p.month9PNum != null)
            {
            sumP.month9PNum += p.month9PNum;
            }
            if(p.month10PNum != null)
            {
            sumP.month10PNum += p.month10PNum;
            }
            if(p.month11PNum != null)
            {
            sumP.month11PNum += p.month11PNum;
            }
            if(p.month12PNum != null)
            {
            sumP.month12PNum += p.month12PNum;
            }
        }
        return sumP;
    }
    
    //业务机会 情况列表
    public void getOpportunityState()  
    {
        integer year = integer.valueOf(this.objMonthlyPlan.Year__c);
        integer month = integer.valueOf(this.objMonthlyPlan.Month__c);
        oppStaList = new List<OpportunityState>();
         List<Opportunity> oppList = this.getOppListByMonth(year, month);
         for(Integer i=0;i<oppList.size();i++)
         {
            OpportunityState oppState = new OpportunityState();
            oppState.opportunityName = wrapLine(oppList[i].Name,15);            //业务机会名称  
            oppState.account = wrapLine(oppList[i].Account.Name,15);//客户名称
            oppState.state = oppList[i].StageName; //阶段
            oppState.possibility = Integer.valueOf(oppList[i].Probability);//可能性
            oppState.overDate = oppList[i].CloseDate;//结束日期
            //List<Event> eveList= oppList[i].Events;
            Integer intSum = 0 ;
            //List<CallRecord__c> callReList = oppList[i].CallRecord__r;
            if(oppList[i].Events != null && oppList[i].Events.size() != 0)
            {
                oppState.monthEventCount = oppList[i].Events.size();//当月事件数
                for(Event objEv : oppList[i].Events)
                {
                    if(objEv.Done__c && objEv.SubjectType__c == '拜访')
                    {
                        intSum++ ;
                    }
                }
            }  
            oppState.monthVisitCount = intSum ;//实际次数 
            
            //oppState.monthVisitCount = callReList.size();//实际次数 
            oppStaList.add(oppState);
         }
    }
    
    //当前月计划Owner所负责的业务机会* XXX
    //仅包括Renal的业务机会阶段：发现/验证机会、建立沟通渠道、需求分析、提交合作方案/谈判、跟进合作方案、签约/缔结、客户合作失败、产品培训和使用
    private List<Opportunity> getBaseOppList()
    {
        integer year = integer.valueOf(this.objMonthlyPlan.Year__c);
        integer month = integer.valueOf(this.objMonthlyPlan.Month__c);
        DateTime startMonthTime = DateTime.newInstanceGmt(year, month, 1);
        DateTime endMonthTime = startMonthTime;
        endMonthTime = endMonthTime.addMonths(1);
        List<Opportunity> oppList = [Select Id, Name,
            StageName, 
            Probability, 
            CloseDate, 
            AccountId,
            Account.Id,
            Account.Name, 
            CreatedDate,
            (Select CreatedDate, StageName, CloseDate, Probability From OpportunityHistories Where StageName in: renalStageList Order By CreatedDate Desc), 
              
            (Select Id, SubjectType__c, Done__c, StartDateTime From Events Where StartDateTime >=: startMonthTime And StartDateTime <=: endMonthTime)  
            From Opportunity 
            Where OwnerId =: objMonthlyPlan.OwnerId
            And StageName in : renalStageList];
            return oppList;
    }
    
    //指定月计划Owner所负责的业务机会
    //排除过期的业务机会阶段（CloseDate在当指定计划的月份开始之前）
    //有条件排除3个结束的阶段: 签约/缔结、客户合作失败、产品培训和使用
    //在指定月计划内刚刚跃迁到以上3个阶段的业务机会阶段也包括在内
    private List<Opportunity> getOppListByMonth(integer year, integer month)
    {
        //Current
        //integer year = integer.valueOf(this.monthPlan.Year__c);
        //integer month = integer.valueOf(this.monthPlan.Month__c);
        DateTime startMonthTime = DateTime.newInstanceGmt(year, month, 1);//当前月计划开始时间
        DateTime endMonthTime = startMonthTime;
        endMonthTime = endMonthTime.addMonths(1);//当前月计划结束时间
        //Datetime lastMonthNowTime = nowTime.addMonths(-1);
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> baseOppList = getBaseOppList();
        Map<String, OppStage> oppStageMap = new Map<String, OppStage>();
        for(Opportunity opp: baseOppList)
        {
            List<OpportunityHistory> oppHstyList = opp.OpportunityHistories;
            if(oppHstyList == null || oppHstyList.size() <= 0)
            {//业务机会没有历史
                if(opp.CreatedDate <= endMonthTime)
                {//在本月或本月之前创建的,算在内
                    oppList.add(opp);
                    continue;
                }
                continue;
            }
            
            //寻找在当前月计划的月份的结束时间之前，最后（新）的阶段历史
            OpportunityHistory currNewHis;
            for(OpportunityHistory his : oppHstyList)
            {
                if(his.CreatedDate <= endMonthTime)
                {
                    currNewHis = his;
                    break;
                }
            }
            if(currNewHis != null)
            {//找到
                if(currNewHis.CloseDate < startMonthTime)
                {//过期了，不包括
                    continue;
                }
                boolean isClose = false;//是否关闭
                for(String stage : closeRenalStageList)
                {
                    if(stage == currNewHis.stageName)
                    {
                        isClose = true;
                        break;
                    }
                }
                if(isClose)
                {//最新阶段历史的状态以经关闭了
                    if(currNewHis.CreatedDate >= startMonthTime)
                    {//是在本月内刚刚关闭的，也要包括在内
                        opp.StageName = currNewHis.stageName;//修改为当月状态
                        opp.Probability = currNewHis.Probability;//修改为当月状态
                        opp.CloseDate = currNewHis.CloseDate;//修改为当月状态
                        oppList.add(opp);
                    }
                }
                else
                {//非关闭的状态，包括在内
                    opp.StageName = currNewHis.stageName;//修改为当月状态
                    opp.Probability = currNewHis.Probability;//修改为当月状态
                    opp.CloseDate = currNewHis.CloseDate;//修改为当月状态
                    oppList.add(opp);
                }
            }
        }
        return oppList;
    }
    
    //本月业务机会阶段*
    public List<OppStage> getCurrentOppStage()
    {
        integer year = integer.valueOf(this.objMonthlyPlan.Year__c);
        integer month = integer.valueOf(this.objMonthlyPlan.Month__c);
        List<Opportunity> currentOppList =  getOppListByMonth(year, month);
        Map<String, OppStage> oppStageMap = new Map<String, OppStage>();
        for(Opportunity opp : currentOppList)
        {
            if(opp.stageName == null || opp.stageName == '')
            {
                continue;
            }
            OppStage oppStage;
            if(oppStageMap.containsKey(opp.stageName))
            {
                oppStage = oppStageMap.get(opp.stageName);
            }
            else
            {
                oppStage = new OppStage(opp.stageName);
                oppStageMap.put(opp.stageName, oppStage);
            }
            oppStage.oppCount ++;
        }
        return  shorOppStage(oppStageMap);
    }
    
    //前三个月业务机会阶段状态*
    public List<OppStage> getLastThreeMonthOppStage()
    {
        integer thisYear = integer.valueOf(this.objMonthlyPlan.Year__c);
        integer thisMonth = integer.valueOf(this.objMonthlyPlan.Month__c);
        DateTime thisMonthTime = DateTime.newInstanceGmt(thisYear, thisMonth, 15);
        DateTime lastThreeMonthTime = thisMonthTime.addMonths(-3);
        integer lastYear = lastThreeMonthTime.year();
        integer lastMonth =  lastThreeMonthTime.month();
        List<Opportunity> currentOppList =  getOppListByMonth(lastYear, lastMonth);
        Map<String, OppStage> oppStageMap = new Map<String, OppStage>();
        for(Opportunity opp : currentOppList)
        {
            if(opp.stageName == null || opp.stageName == '')
            {
                continue;
            }
            OppStage oppStage;
            if(oppStageMap.containsKey(opp.stageName))
            {
                oppStage = oppStageMap.get(opp.stageName);
            }
            else
            {
                oppStage = new OppStage(opp.stageName);
                oppStageMap.put(opp.stageName, oppStage);
            }
            oppStage.oppCount ++;
        }
        return  shorOppStage(oppStageMap);
    }
    //按照系统配置的业务机会阶段排序
    private List<OppStage> shorOppStage(Map<String, OppStage> oppStageMap)
    {
        Map<integer, String> orderToNameStageMap = new Map<integer, String>() ;
        Map<String, integer> nameToOrderStageMap = new Map<String, integer>() ;
        List<integer> oppStageOrderList = new List<integer>();
        List<OppStage> newOppStageList = new List<OppStage>();
        
        List<OpportunityStage> stageList = [Select SortOrder, MasterLabel From OpportunityStage Order by SortOrder];
        for(OpportunityStage stage : stageList)
        {
            if(stage.SortOrder == null || stage.MasterLabel == null)
            {
                continue;
            }
            orderToNameStageMap.put(stage.SortOrder, stage.MasterLabel);
            nameToOrderStageMap.put(stage.MasterLabel, stage.SortOrder);
        }
        
        List<OppStage> oppStageList = oppStageMap.values();
        for(integer i=0; i< oppStageList.size(); i ++)
        {
            OppStage oppStage = oppStageList[i];
            if(nameToOrderStageMap.containsKey(oppStage.StageName))
            {
                oppStageOrderList.add(nameToOrderStageMap.get(oppStage.StageName));
            }
            else
            {
                newOppStageList.add(oppStage);//未找到排序号，加到最前
            }
        }
        oppStageOrderList.sort();
        for(integer orde : oppStageOrderList)
        {
            string name = orderToNameStageMap.get(orde);
            newOppStageList.add(oppStageMap.get(name));
        }
        return newOppStageList;
    }
    
    //当月业务机会阶段   
    public String MonthCurrentOppStageStr
    {
         get
         {
                List<OppStage> oppSageList = new List<OppStage>();
                oppSageList = this.getCurrentOppStage();
                String dataStr = '';
                String lastDataStr = '';
                String stateStr = '';
                String lastStateStr = '';
                Double totalCountInteger =0.0;     //设定柱状图的总高度
                Double space = (totalCountInteger/10);               //设定柱状图刻度的单位量
                
                System.debug('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'+ oppSageList.size());
                for(Integer i= oppSageList.size()-1;i>=0;i--)
                {
                    
                    System.debug('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'+ oppSageList[i].stageName);
                    System.debug('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'+ oppSageList[i].oppCount);
                    dataStr += oppSageList[i].oppCount+ '|';
                    stateStr += oppSageList[i].stageName + '（'+ oppSageList[i].oppCount+'个）' +'|';
                    totalCountInteger  += Double.valueOf(oppSageList[i].oppCount);
             
                }                                                                            
                if(dataStr.length()>0&&dataStr!=null){lastDataStr=dataStr.substring(0,dataStr.length()-1);}
                if(stateStr.length()>0&&stateStr!=null){lastStateStr=stateStr.substring(0,stateStr.length()-1);}
                
                String y = 'https://chart.googleapis.com/chart?cht=bvs&chs=300x200&chd=t:'+lastDataStr+'&chdl='+lastStateStr+'&chxt=x,y&chxr=1,0,'+totalCountInteger+','+space+'&chds=0,'+totalCountInteger+'&chco=FF9821,FCFF00,A5E400,01DEFB,2084FE,AE20FF,FC20D8,7B1CDC&chbh=100&chl=记录数'; 
                System.debug('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq y '+ y);
                return y;
         } 
    }
    
     //三个月前业务机会阶段
    public String BeforeThreeMonthOppStageStr
    {
         get
         { 
                List<OppStage> oppSageList = new List<OppStage>();
                oppSageList = this.getLastThreeMonthOppStage();
                String dataStr = '';
                String lastDataStr = '';
                String stateStr = '';
                String lastStateStr = '';
                
                Integer dataSum = 0;  
                Integer space = (dataSum/10) ;
                System.debug('ppppppppppppppppppppppppppppppppppppppppppppppppp'+ oppSageList.size());
                for(Integer i= oppSageList.size()-1;i>=0;i--)
                {
                    System.debug('ppppppppppppppppppppppppppppppppppppppppppppppppp'+ oppSageList[i].stageName);
                    System.debug('ppppppppppppppppppppppppppppppppppppppppppppppppp'+ oppSageList[i].oppCount);
                    dataStr += oppSageList[i].oppCount+ '|';
                    stateStr += oppSageList[i].stageName + '（'+ oppSageList[i].oppCount+'个）' +'|';
                    dataSum += oppSageList[i].oppCount;
                }                                                                             
                if(dataStr.length()>0&&dataStr!=null){lastDataStr=dataStr.substring(0,dataStr.length()-1);}
                if(stateStr.length()>0&&stateStr!=null){lastStateStr=stateStr.substring(0,stateStr.length()-1);}
                return  'https://chart.googleapis.com/chart?cht=bvs&chs=300x200&chd=t:'+lastDataStr+'&chdl='+lastStateStr+'&chxt=x,y&chxr=1,0,'+dataSum+','+space+'&chds=0,'+dataSum+'&chco=FF9821,FCFF00,A5E400,01DEFB,2084FE,AE20FF,FC20D8,7B1CDC&chbh=100&chl=记录数'; 
         }
    }
    
    public class OppStage
    {
        public OppStage()
        {
            stageName = '';
            oppCount = 0;
        }
        public String stageName{get;set;}//业务机会阶段名称
        public integer oppCount{get;set;}//业务机会数量
        public OppStage(String stageName)
        {
            this.stageName = stageName;
            oppCount = 0;
        }
    }
    // 业务机会阶段情况
    public class OpportunityState {  
        public String opportunityName{get;set;}  //业务机会名称
        public String account{get;set;}  //客户名称
        public String state{get;set;}    //阶段
        public Integer possibility{get;set;}  //可能性
        public datetime overDate{get;set;}  //结束日期
        public Integer monthEventCount{get;set;}  //当月事件数
        public Integer monthVisitCount{get;set;}  //实际次数
 
    }
    
    
    
    //格式化字符来进行显示数据（鹏飞的代码）
    public String wrapLine(String oldStr, Integer chartNum)
    {
        if(oldStr!=null) //Brave add (If)
        {
            Integer flag = 0;
            String retStr = '';
            List<String> lineList = oldStr.split('\n');
            for(Integer i=0;i<lineList.size(); i++){
                    String lineStr = lineList[i];
                    while(lineStr.length() > chartNum){
                             retStr += lineStr.substring(0,chartNum) + '<br/>';
                             lineStr = lineStr.substring(chartNum);
                    }
                    if(lineStr.length() > 0){
                             retStr += lineStr + '<br/>';
                    }
            }
            return retStr;
        }else
        {
            return '';
        }
    }
    private void InitMonthlyDetail()
    {
        if(objMonthlyPlan == null)
        {
            return ;
        }
        this.list_MonthlyDetail = [Select m.AdjustedTimes__c, m.Planned_Finished_Calls__c, m.Contact__r.DepartmentType__c, m.Contact__r.V2_Level__c, m.Contact__r.V2_RenalGrade__c, m.Contact__r.ContactType__c, m.Contact__c From MonthlyPlanDetail__c m Where MonthlyPlan__c =: objMonthlyPlan.Id ] ;
    }
    private void InitEventContact()
    {
        if(objMonthlyPlan == null)
        {
            return ;
        }
        String strStartDate ;
        if(objMonthlyPlan.Year__c != null && objMonthlyPlan.Month__c != null)
        {
            strStartDate = objMonthlyPlan.Year__c + '-' +objMonthlyPlan.Month__c + '-1 00:00:00' ;
        }else
        {
            this.blnErrorShow = true ;
            this.strErrorMessage = '该月计划日期不完整' ;
            return ;
        }
        datetime startDate = datetime.valueOf(strStartDate) ;
        datetime endDate = startDate.addMonths(1) ;
        List<ID> list_ContactId = new List<ID>() ;
        //List<Contact> list_Contact = new List<Contact>() ;
        Map<ID,ID> map_ids = new Map<ID,ID>() ;
        //查找当月的Event
        for(Event objEvent : [Select e.Id, e.WhoId, e.WhatId, e.CommentsBySupervisor__c, e.StartDateTime, e.SubjectType__c , e.DurationInMinutes, e.GAPlan__c, e.GAExecuteResult__c, e.Done__c, e.OwnerId, (Select Status, AttendeeId From EventAttendees Where Status = 'Accepted') From Event e Where e.OwnerId =: objMonthlyPlan.OwnerId And e.StartDateTime >: startDate And e.StartDateTime <: endDate And SubjectType__c = '拜访'])
        { 
            list_ContactId.add(objEvent.WhoId) ;
            map_EveId.put(objEvent.Id , objEvent) ;
            map_ids.put(objEvent.Id, objEvent.WhoId) ;
            if(objEvent.WhoId != null && objEvent.WhatId != null)
            {
                if(map_CampaignCount.containsKey(objEvent.WhatId + '' + objEvent.WhoId))
                {
                    Integer intCou = map_CampaignCount.get(objEvent.WhatId + '' + objEvent.WhoId) ;
                    intCou++ ;
                    map_CampaignCount.put(objEvent.WhatId + '' + objEvent.WhoId, intCou) ;
                }else
                {
                    map_CampaignCount.put(objEvent.WhatId + '' + objEvent.WhoId , 1) ;
                } 
            }
        }
        //查找过期事件
        AggregateResult[] rs = [Select count(Id) From Event e Where e.OwnerId =: objMonthlyPlan.OwnerId And e.StartDateTime >: startDate And e.StartDateTime <: endDate And V2_IsExpire__c = true];
        if(rs != null && rs.size() != 0){
            intExpireSum = rs.size() ;
        }else
        {
            intExpireSum = 0 ;
        }
        
        system.debug(list_ContactId.size()+'Event Size:'+list_ContactId) ;
        if(list_ContactId.size() != 0)
        {
            //查找当月Event所拜访的Contact
            for(Contact objContact : [Select c.Id, c.Name, c.Account.Name, c.V2_Level__c, c.DepartmentType__c, c.AccountId, c.V2_RenalGrade__c, ContactType__c From Contact c Where c.Id in: list_ContactId])
            {
                //list_Contact.add(objContact) ;
                map_conId.put(objContact.Id , objContact) ;
            }
        }
        if(map_ids.size() != 0)
        {
            for(ID strId : map_ids.keySet())
            {
                if(map_conId.containsKey(map_ids.get(strId)))
                {
                    map_EvIdContact.put(strId, map_conId.get(map_ids.get(strId))) ;
                }
            }
            /*
            for(EventAttendee objEventAtt : [Select e.Status, e.Response, e.EventId From EventAttendee e Where e.EventId in: map_ids.keySet() And e.Status = 'Accepted'])
            {
                
            }
            */
        }
    }
    //测试
    static testMethod void TestPDFPage4(){
        //----------------New UserRole ------------------
        //List<UserRole> list_userRole = new List<UserRole >() ;
        UserRole objUserRole = new UserRole() ;
        objUserRole.Name = 'Renal-Superviler-大上海-PD-Superviler(陈喆令)' ;
        insert objUserRole ;
        UserRole objUserRole2 = new UserRole() ;
        objUserRole2.Name = 'Renal-Rep-大上海-PB-Rep(陈喆令)' ;
        objUserRole2.ParentRoleId = objUserRole.Id ;
        insert objUserRole2 ;
        //--------------New User-------------------
        List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
        List<User> list_User = new List<User>() ;
        User use1=new User();
        use1.Username='user2@123.com';
        use1.LastName='user2';
        use1.Email='user2@123.com';
        use1.Alias=user[0].Alias;
        use1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use1.ProfileId=user[0].ProfileId;
        use1.LocaleSidKey=user[0].LocaleSidKey;
        use1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use1.EmailEncodingKey=user[0].EmailEncodingKey;
        use1.CommunityNickname='chequ1';
        use1.MobilePhone='12345678912';
        use1.UserRoleId = objUserRole2.Id ;
        use1.IsActive = true;
        list_User.add(use1) ;
        User use2=new User();
        use2.Username='user2@223.com';
        use2.LastName='user2';
        use2.Email='user2@223.com';
        use2.Alias=user[0].Alias;
        use2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use2.ProfileId=user[0].ProfileId;
        use2.LocaleSidKey=user[0].LocaleSidKey;
        use2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use2.EmailEncodingKey=user[0].EmailEncodingKey;
        use2.CommunityNickname='chequ2';
        use2.UserRoleId = objUserRole2.Id ;
        use2.MobilePhone='22345678922';
        use2.IsActive = true;
        list_User.add(use2) ;
        User use3=new User();
        use3.Username='user2@323.com';
        use3.LastName='user2';
        use3.Email='user2@323.com';
        use3.Alias=user[0].Alias;
        use3.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use3.ProfileId=user[0].ProfileId;
        use3.LocaleSidKey=user[0].LocaleSidKey;
        use3.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use3.EmailEncodingKey=user[0].EmailEncodingKey;
        use3.CommunityNickname='chequ3';
        use3.MobilePhone='32345678932';
        use3.UserRoleId = objUserRole.Id ;
        use3.IsActive = true;
        list_User.add(use3) ;
        insert list_User ;
        //奖金数据
        List<Bonus_data__c> list_bonusdata = new List<Bonus_data__c>();
        Bonus_data__c bd1 = new Bonus_data__c();
        bd1.The_User__c = use3.id;
        bd1.Month__c=string.valueOf(date.today().month());
        bd1.Year__c=string.valueOf(date.today().year());
        list_bonusdata.add(bd1);
        Bonus_data__c bd2 = new Bonus_data__c();
        bd2.The_User__c = use1.id;
        bd2.Month__c=string.valueOf(date.today().month());
        bd2.Year__c=string.valueOf(date.today().year());
        list_bonusdata.add(bd2);
        System.runAs(use3){
        insert list_bonusdata;}
        //角色历史
        List<V2_RoleHistory__c> list_his = new List<V2_RoleHistory__c>();
        V2_RoleHistory__c rolehis1 = new V2_RoleHistory__c();
        rolehis1.Name__c = use3.Id;
        rolehis1.Month__c=string.valueOf(date.today().month());
        rolehis1.Year__c=string.valueOf(date.today().year());
        list_his.add(rolehis1);
        System.runAs(use3){
        insert list_his ;}
        //月计划
        MonthlyPlan__c objMonthlyPlan = new MonthlyPlan__c() ;
        objMonthlyPlan.Month__c = String.valueOf(date.today().month()) ;
        objMonthlyPlan.Year__c = String.valueOf(date.today().year()) ;
        objMonthlyPlan.OwnerId = use1.Id ;
        System.runAs(use3){
        insert objMonthlyPlan ;}
        
       /* //销售数据
        SalesReport__c sr1 = new SalesReport__c();
        sr1.OwnerId=use3.Id;
        sr1.Time__c = date.today();
        sr1.TargetAmount__c = 1000;
        sr1.ActualAmount__c = 800;
        System.runAs(use3){
        insert sr1;}
        
        system.Test.startTest();
        system.runAs(use3){
            ApexPages.currentPage().getParameters().put('monId', objMonthlyPlan.Id);
            BQ_CtrlMonthlyPlanReport clsMonthlyReport = new BQ_CtrlMonthlyPlanReport() ;
        }
        system.Test.stopTest();*/
        
    }
    static testMethod void TestPDFPage()
    {
        //----------------New UserRole ------------------
        //List<UserRole> list_userRole = new List<UserRole >() ;
        UserRole objUserRole = new UserRole() ;
        objUserRole.Name = 'Renal-Rep-大上海-PD-Rep(陈喆令)' ;
        insert objUserRole ;
        UserRole objUserRole2 = new UserRole() ;
        objUserRole2.Name = 'Renal-Rep-大上海-PB-Rep(陈喆令)' ;
        objUserRole2.ParentRoleId = objUserRole.Id ;
        insert objUserRole2 ;
        //--------------New User-------------------
        List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
        List<User> list_User = new List<User>() ;
        User use1=new User();
        use1.Username='user2@123.com';
        use1.LastName='user2';
        use1.Email='user2@123.com';
        use1.Alias=user[0].Alias;
        use1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use1.ProfileId=user[0].ProfileId;
        use1.LocaleSidKey=user[0].LocaleSidKey;
        use1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use1.EmailEncodingKey=user[0].EmailEncodingKey;
        use1.CommunityNickname='chequ1';
        use1.MobilePhone='12345678912';
        use1.UserRoleId = objUserRole2.Id ;
        use1.IsActive = true;
        list_User.add(use1) ;
        User use2=new User();
        use2.Username='user2@223.com';
        use2.LastName='user2';
        use2.Email='user2@223.com';
        use2.Alias=user[0].Alias;
        use2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use2.ProfileId=user[0].ProfileId;
        use2.LocaleSidKey=user[0].LocaleSidKey;
        use2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use2.EmailEncodingKey=user[0].EmailEncodingKey;
        use2.CommunityNickname='chequ2';
        use2.UserRoleId = objUserRole2.Id ;
        use2.MobilePhone='22345678922';
        use2.IsActive = true;
        list_User.add(use2) ;
        User use3=new User();
        use3.Username='user2@323.com';
        use3.LastName='user2';
        use3.Email='user2@323.com';
        use3.Alias=user[0].Alias;
        use3.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use3.ProfileId=user[0].ProfileId;
        use3.LocaleSidKey=user[0].LocaleSidKey;
        use3.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use3.EmailEncodingKey=user[0].EmailEncodingKey;
        use3.CommunityNickname='chequ3';
        use3.MobilePhone='32345678932';
        use3.UserRoleId = objUserRole.Id ;
        use3.IsActive = true;
        list_User.add(use3) ;
        insert list_User ;
        //--------------New Account-------------------
        RecordType objRT = [Select Id From RecordType Where DeveloperName =: 'RecordType_d_2' And SobjectType = 'Account'] ;
        RecordType objRT2 = [Select Id From RecordType Where DeveloperName =: 'RecordType' And SobjectType = 'Account'] ;
        List<Account> list_Account = new List<Account>() ;
        Account objAccount1 = new Account() ;
        objAccount1.Name = 'Acc1' ;
        list_Account.add(objAccount1) ;
        Account objAccount2 = new Account() ;
        objAccount2.Name = 'Acc2' ;
        list_Account.add(objAccount2) ;
        Account objAccount3 = new Account() ;
        objAccount3.Name = 'Acc3' ;
        objAccount3.RecordTypeId = objRT.Id ;
        list_Account.add(objAccount3) ;
        Account objAccount4 = new Account() ;
        objAccount4.Name = 'Acc4' ;
        objAccount4.RecordTypeId = objRT2.Id ;
        list_Account.add(objAccount4) ;
        System.runAs(use1){
        insert list_Account ;}
        //--------------New Contact-------------------
        List<Contact> list_Contact = new List<Contact>() ;
        Contact objContact1 = new Contact() ;
        objContact1.LastName = 'Soon' ;
        objContact1.AccountId = objAccount1.Id ;
        objContact1.DepartmentType__c = '药剂科' ;
        objContact1.ContactType__c = '行政' ;
        objContact1.V2_RenalGrade__c = '银' ;
        list_Contact.add(objContact1) ;
        Contact objContact2 = new Contact() ;
        objContact2.LastName = 'Soon' ;
        objContact2.AccountId = objAccount1.Id ;
        objContact2.DepartmentType__c = '护理部' ;
        objContact2.ContactType__c = '护士' ;
        objContact2.V2_RenalGrade__c = '金' ;
        list_Contact.add(objContact2) ;
        Contact objContact3 = new Contact() ;
        objContact3.LastName = 'Soon' ;
        objContact3.AccountId = objAccount1.Id ;
        objContact3.DepartmentType__c = '肾科' ;
        objContact3.ContactType__c = '医生' ;
        objContact3.V2_RenalGrade__c = '铜' ;
        list_Contact.add(objContact3) ;
        Contact objContact4 = new Contact() ;
        objContact4.LastName = 'Soon' ;
        objContact4.AccountId = objAccount1.Id ;
        objContact4.DepartmentType__c = '肾科' ;
        objContact4.ContactType__c = '医生' ;
        objContact4.V2_RenalGrade__c = '铜' ;
        objContact4.V2_Level__c = 'C' ;
        list_Contact.add(objContact4) ;
        System.runAs(use1){
        insert list_Contact ;}
        //---------------New Campaign-------------------
        List<Campaign> list_Campaign = new List<Campaign>() ;
        Campaign objCampaign1 = new Campaign() ;
        objCampaign1.Name = 'cam1' ;
        objCampaign1.StartDate = date.today() ;
        objCampaign1.EndDate = date.today().addDays(2) ;
        objCampaign1.OwnerId = use1.Id ;
        list_Campaign.add(objCampaign1) ;
        System.runAs(use1){
        insert list_Campaign ;}
        //--------------New CampaignMember---------------------
        List<CampaignMember> list_CampaignMember = new List<CampaignMember>() ;
        CampaignMember objCamMem1 = new CampaignMember() ;
        objCamMem1.User__c = use1.Id ;
        objCamMem1.CampaignId = objCampaign1.Id ;
        objCamMem1.ContactId = objContact1.Id ;
        objCamMem1.V2_Account__c = objAccount1.Id ;
        objCamMem1.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem1) ;
        CampaignMember objCamMem2 = new CampaignMember() ;
        objCamMem2.User__c = use1.Id ;
        objCamMem2.CampaignId = objCampaign1.Id ;
        objCamMem2.ContactId = objContact2.Id ;
        objCamMem2.V2_Account__c = objAccount1.Id ;
        objCamMem2.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem2) ;
        CampaignMember objCamMem3 = new CampaignMember() ;
        objCamMem3.User__c = use1.Id ;
        objCamMem3.CampaignId = objCampaign1.Id ;
        objCamMem3.ContactId = objContact3.Id ;
        objCamMem3.V2_Account__c = objAccount1.Id ;
        objCamMem3.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem3) ;
        system.runAs(use1){
            insert list_CampaignMember ;
        }
        //--------------New MonthlyPlan-------------------
        MonthlyPlan__c objMonthlyPlan = new MonthlyPlan__c() ;
        objMonthlyPlan.Month__c = String.valueOf(date.today().month()) ;
        objMonthlyPlan.Year__c = String.valueOf(date.today().year()) ;
        objMonthlyPlan.OwnerId = use1.Id ;
        System.runAs(use1){
        insert objMonthlyPlan ;}
        //---------------New V2_UserBonusInFo__c-------------------
        V2_UserBonusInFo__c objBonusInfo = new V2_UserBonusInFo__c() ;
        objBonusInfo.V2_Month__c = String.valueOf(date.today().month());
        objBonusInfo.V2_Year__c = String.valueOf(date.today().year());
        objBonusInfo.OwnerId = use1.Id ;
        System.runAs(use1){
        insert objBonusInfo ;}
        //---------------New PatientApply------------------
        List<PatientApply__c> list_NewPatient = new List<PatientApply__c>() ;
        PatientApply__c objNewPatient1 = new PatientApply__c() ;
        objNewPatient1.IntubationHospital__c = objAccount2.Id ;
        objNewPatient1.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient1.PatientName__c = 'Patie1' ;
        objNewPatient1.Distributor__c = objAccount3.Id ;
        objNewPatient1.PM_Patient_MPhone__c = '18611112222';
        objNewPatient1.IntubationHospital__c = objAccount4.Id ;
        list_NewPatient.add(objNewPatient1) ;
        PatientApply__c objNewPatient2 = new PatientApply__c() ;
        objNewPatient2.IntubationHospital__c = objAccount2.Id ;
        objNewPatient2.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient2.PatientName__c = 'Patie2' ;
        objNewPatient2.Distributor__c = objAccount3.Id ;
        objNewPatient2.PM_Patient_MPhone__c = '18611112222';
        objNewPatient2.IntubationHospital__c = objAccount4.Id ;
        list_NewPatient.add(objNewPatient2) ;
        PatientApply__c objNewPatient3 = new PatientApply__c() ;
        objNewPatient3.IntubationHospital__c = objAccount2.Id ;
        objNewPatient3.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient3.PatientName__c = 'Patie3' ;
        objNewPatient3.Distributor__c = objAccount3.Id ;
        objNewPatient3.PM_Patient_MPhone__c = '18611112222';
        objNewPatient3.IntubationHospital__c = objAccount4.Id;
        list_NewPatient.add(objNewPatient3) ;
        system.runAs(use1){
            insert list_NewPatient ;
        }
        //--------------New Event-------------------
        List<Event> list_Events = new List<Event>() ;
        Event objEvent1 = new Event() ;
        objEvent1.WhoId = objContact1.Id ;
        objEvent1.WhatId = objAccount1.Id ;
        objEvent1.StartDateTime = Datetime.now() ;
        objEvent1.EndDateTime = Datetime.now().addHours(1) ;
        objEvent1.OwnerId = use1.Id ;
        objEvent1.Done__c = true ;
        objEvent1.Subject = '拜访' ;
        list_Events.add(objEvent1) ;
        Event objEvent2 = new Event() ;
        objEvent2.WhoId = objContact1.Id ;
        objEvent2.WhatId = objAccount1.Id ;
        objEvent2.StartDateTime = Datetime.now() ;
        objEvent2.EndDateTime = Datetime.now().addHours(2) ;
        objEvent2.OwnerId = use1.Id ;
        objEvent2.Done__c = true ;
        objEvent2.Subject = '拜访' ;
        list_Events.add(objEvent2) ;
        Event objEvent3 = new Event() ;
        objEvent3.WhoId = objContact1.Id ;
        objEvent3.WhatId = objAccount1.Id ;
        objEvent3.StartDateTime = Datetime.now() ;
        objEvent3.EndDateTime = Datetime.now().addHours(1) ;
        objEvent3.OwnerId = use1.Id ;
        objEvent3.Done__c = true ;
        objEvent3.Subject = '拜访' ;
        list_Events.add(objEvent3) ;
        Event objEvent4 = new Event() ;
        objEvent4.WhoId = objContact2.Id ;
        objEvent4.WhatId = objAccount1.Id ;
        objEvent4.StartDateTime = Datetime.now() ;
        objEvent4.EndDateTime = Datetime.now().addHours(1) ;
        objEvent4.OwnerId = use1.Id ;
        objEvent4.Done__c = true ;
        objEvent4.Subject = '拜访' ;
        list_Events.add(objEvent4) ;
        Event objEvent5 = new Event() ;
        objEvent5.WhoId = objContact2.Id ;
        objEvent5.WhatId = objAccount1.Id ;
        objEvent5.StartDateTime = Datetime.now() ;
        objEvent5.EndDateTime = Datetime.now().addHours(1) ;
        objEvent5.OwnerId = use1.Id ;
        objEvent5.Done__c = true ;
        objEvent5.Subject = '拜访' ;
        list_Events.add(objEvent5) ;
        Event objEvent6 = new Event() ;
        objEvent6.WhoId = objContact2.Id ;
        objEvent6.WhatId = objAccount1.Id ;
        objEvent6.StartDateTime = Datetime.now() ;
        objEvent6.EndDateTime = Datetime.now().addHours(1) ;
        objEvent6.OwnerId = use1.Id ;
        objEvent6.Done__c = true ;
        objEvent6.Subject = '拜访' ;
        list_Events.add(objEvent6) ;
        Event objEvent7 = new Event() ;
        objEvent7.WhoId = objContact3.Id ;
        objEvent7.WhatId = objAccount1.Id ;
        objEvent7.StartDateTime = Datetime.now() ;
        objEvent7.EndDateTime = Datetime.now().addHours(1) ;
        objEvent7.OwnerId = use1.Id ;
        objEvent7.Done__c = true ;
        objEvent7.Subject = '拜访' ;
        list_Events.add(objEvent7) ;
        Event objEvent8 = new Event() ;
        objEvent8.WhoId = objContact3.Id ;
        objEvent8.WhatId = objAccount1.Id ;
        objEvent8.StartDateTime = Datetime.now() ;
        objEvent8.EndDateTime = Datetime.now().addHours(1) ;
        objEvent8.OwnerId = use1.Id ;
        objEvent8.Done__c = true ;
        objEvent8.Subject = '拜访' ;
        list_Events.add(objEvent8) ;
        Event objEvent9 = new Event() ;
        objEvent9.WhoId = objContact3.Id ;
        objEvent9.WhatId = objAccount1.Id ;
        objEvent9.StartDateTime = Datetime.now() ;
        objEvent9.EndDateTime = Datetime.now().addHours(1) ;
        objEvent9.OwnerId = use1.Id ;
        objEvent9.Done__c = true ;
        objEvent9.Subject = '拜访' ;
        list_Events.add(objEvent9) ;
        Event objEvent10 = new Event() ;
        objEvent10.WhoId = objContact3.Id ;
        objEvent10.StartDateTime = Datetime.now() ;
        objEvent10.EndDateTime = Datetime.now().addHours(1) ;
        objEvent10.OwnerId = use1.Id ;
        objEvent10.Done__c = true ;
        objEvent10.Subject = '拜访' ;
        list_Events.add(objEvent10) ;
        Event objEvent11 = new Event() ;
        objEvent11.WhoId = objContact3.Id ;
        objEvent11.StartDateTime = Datetime.now() ;
        objEvent11.EndDateTime = Datetime.now().addHours(1) ;
        objEvent11.OwnerId = use1.Id ;
        objEvent11.Done__c = true ;
        objEvent11.Subject = '拜访' ;
        list_Events.add(objEvent11) ;
        Event objEvent12 = new Event() ;
        objEvent12.WhoId = objContact4.Id ;
        objEvent12.WhatId = objAccount1.Id ;
        objEvent12.StartDateTime = Datetime.now() ;
        objEvent12.EndDateTime = Datetime.now().addHours(1) ;
        objEvent12.OwnerId = use1.Id ;
        objEvent12.Done__c = true ;
        objEvent12.Subject = '拜访' ;
        list_Events.add(objEvent12) ;
        System.runAs(use1){
        insert list_Events ;}
        
        //-------------------------------------
        List<MonthlyPlanDetail__c> list_MPDUp = new List<MonthlyPlanDetail__c>() ;
        for(MonthlyPlanDetail__c objMPD :[Select m.AdjustedTimes__c From MonthlyPlanDetail__c m Where MonthlyPlan__c =: objMonthlyPlan.Id ])
        {
            objMPD.AdjustedTimes__c = 10 ;
            list_MPDUp.add(objMPD) ;
        }
        System.runAs(use1){
        update list_MPDUp ;}
        
        
        system.test.startTest() ;
        system.runAs(use1) {
            ApexPages.currentPage().getParameters().put('monId', objMonthlyPlan.Id);
            BQ_CtrlMonthlyPlanReport clsMonthlyReport = new BQ_CtrlMonthlyPlanReport() ;
            //clsMonthlyReport.testMet() ;
            clsMonthlyReport.userBonusInFo() ;
            List<String> liststr = clsMonthlyReport.list_RenalField ;
            liststr = clsMonthlyReport.list_RenalField2 ;
            liststr = clsMonthlyReport.list_MDField ;
            liststr = clsMonthlyReport.list_MDField2 ;
            liststr = clsMonthlyReport.list_BiosField ;
            liststr = clsMonthlyReport.list_BiosField2 ;
            String strTime = clsMonthlyReport.TimeDistributeCondition ;
            //目标联系人统计分析&拜访情况统计 Renal
            String str1 = clsMonthlyReport.PlanContactDistributionByGrade ;
            String str2 = clsMonthlyReport.ActualContactDistributionByGrade ;
            String str3 = clsMonthlyReport.ActualCallDistributionByGrade ;
            String str4 = clsMonthlyReport.PlanContactDistributionByType ;
            String str5 = clsMonthlyReport.ActualContactDistributionByType ;
            String str6 = clsMonthlyReport.ActualCallDistributionByType; 
            //目标联系人统计分析&拜访情况统计BIOS
            String strBi1 = clsMonthlyReport.PlanContactDistributionByGrade ;
            String strBi2 = clsMonthlyReport.ActualContactDistributionByGrade ;
            String strBi3 = clsMonthlyReport.ActualCallDistributionByGrade ;
            String strBi4 = clsMonthlyReport.PlanContactDistributionByDepartmentType ;
            String strBi5 = clsMonthlyReport.ActualContactDistributionByDepartmentType ;
            String strBi6 = clsMonthlyReport.ActualCallDistributionByDepartmentType;
            //拜访完成情况Renal
            String strRe1 =  clsMonthlyReport.VisitCompleteRatioCondition ;
            String strRe2 =  clsMonthlyReport.VisitCompleteCountCondition ;
            //拜访完成情况Bios
            String strBio1 =  clsMonthlyReport.VisitCompleteCountBios ;
            String strBio2 =  clsMonthlyReport.VisitCompleteCountBios2 ;
            String strBio3 =  clsMonthlyReport.visitComplete3 ;
            //拜访完成情况MD
            String strMD1 =  clsMonthlyReport.VisitCompleteCountConditionMD ;
            //时间分配情况 
            String strTiem = clsMonthlyReport.TimeDistributeCondition ;
            //主管协防情况
            List<ManHelpCondition> list_manhelp = clsMonthlyReport.getManHelpConditionList() ;
            //月计划明细
            List<MonthlyPlanDetailByAccount> list_mpd =  clsMonthlyReport.getMonthlyPlanDetailList();
            //今年市场活动情况
            List<YearMarketActivityCondition> list_ymac =  clsMonthlyReport.getActiveSignUpList() ;
            //新病人情况 
            String strNew = clsMonthlyReport.newPatientConditionStr ;
            //科内会情况BIOS
            List<DepartmentVisit> list_DV = clsMonthlyReport.getDepartmentVisits() ;
            //业务机会拜访情况MD
            String strMDOpp = clsMonthlyReport.OpportunityVisitMD ;
            //业务机会拜访情况Bios
            String strBiosOpp = clsMonthlyReport.OpportunityVisitBios ;
            //业务机会阶段情况
            String strOpp = clsMonthlyReport.BeforeThreeMonthOppStageStr ;
            //业务机会阶段情况 ——表格
            List<OpportunityState> list_oppS = clsMonthlyReport.oppStaList ;
            String oppsta = clsMonthlyReport.MonthCurrentOppStageStr ;
            OpportunityState opps = new OpportunityState() ;
            opps.opportunityName = 'wef' ;
            opps.account = 'wef' ;
            opps.state = 'wef' ;
            opps.possibility = 23 ;
            opps.overDate = date.today() ;
            opps.monthEventCount = 2 ;
            opps.monthVisitCount = 5 ;
            
        }
        
        system.test.stopTest() ;
    } 
    
    static testMethod void TestPDFPage2()
    {
        //----------------New UserRole ------------------
        //List<UserRole> list_userRole = new List<UserRole >() ;
        UserRole objUserRole = new UserRole() ;
        objUserRole.Name = 'Bios-Rep-大上海-PD-Rep(陈喆令)' ;
        insert objUserRole ;
        UserRole objUserRole2 = new UserRole() ;
        objUserRole2.Name = 'Bios-Rep-大上海-PB-Rep(陈喆令)' ;
        objUserRole2.ParentRoleId = objUserRole.Id ;
        insert objUserRole2 ;
        //--------------New User-------------------
        List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
        List<User> list_User = new List<User>() ;
        User use1=new User();
        use1.Username='user2@123.com';
        use1.LastName='user2';
        use1.Email='user2@123.com';
        use1.Alias=user[0].Alias;
        use1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use1.ProfileId=user[0].ProfileId;
        use1.LocaleSidKey=user[0].LocaleSidKey;
        use1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use1.EmailEncodingKey=user[0].EmailEncodingKey;
        use1.CommunityNickname='chequ1';
        use1.MobilePhone='12345678912';
        use1.UserRoleId = objUserRole2.Id ;
        use1.IsActive = true;
        list_User.add(use1) ;
        User use2=new User();
        use2.Username='user2@223.com';
        use2.LastName='user2';
        use2.Email='user2@223.com';
        use2.Alias=user[0].Alias;
        use2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use2.ProfileId=user[0].ProfileId;
        use2.LocaleSidKey=user[0].LocaleSidKey;
        use2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use2.EmailEncodingKey=user[0].EmailEncodingKey;
        use2.CommunityNickname='chequ2';
        use2.UserRoleId = objUserRole2.Id ;
        use2.MobilePhone='22345678922';
        use2.IsActive = true;
        list_User.add(use2) ;
        User use3=new User();
        use3.Username='user2@323.com';
        use3.LastName='user2';
        use3.Email='user2@323.com';
        use3.Alias=user[0].Alias;
        use3.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use3.ProfileId=user[0].ProfileId;
        use3.LocaleSidKey=user[0].LocaleSidKey;
        use3.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use3.EmailEncodingKey=user[0].EmailEncodingKey;
        use3.CommunityNickname='chequ3';
        use3.MobilePhone='32345678932';
        use3.UserRoleId = objUserRole.Id ;
        use3.IsActive = true;
        list_User.add(use3) ;
        insert list_User ;
        //--------------New Account-------------------
        RecordType objRT = [Select Id From RecordType Where DeveloperName =: 'RecordType_d_2' And SobjectType = 'Account'] ;
        RecordType objRT2 = [Select Id From RecordType Where DeveloperName =: 'RecordType' And SobjectType = 'Account'] ;
        List<Account> list_Account = new List<Account>() ;
        Account objAccount1 = new Account() ;
        objAccount1.Name = 'Acc1' ;
        list_Account.add(objAccount1) ;
        Account objAccount2 = new Account() ;
        objAccount2.Name = 'Acc2' ;
        list_Account.add(objAccount2) ;
        Account objAccount3 = new Account() ;
        objAccount3.Name = 'Acc3' ;
        objAccount3.RecordTypeId = objRT.Id ;
        list_Account.add(objAccount3) ;
        Account objAccount4 = new Account() ;
        objAccount4.Name = 'Acc4' ;
        objAccount4.RecordTypeId = objRT2.Id ;
        list_Account.add(objAccount4) ;
        system.runAs(use1){
        insert list_Account ;}
        //--------------New Contact-------------------
        List<Contact> list_Contact = new List<Contact>() ;
        Contact objContact1 = new Contact() ;
        objContact1.LastName = 'Soon' ;
        objContact1.AccountId = objAccount1.Id ;
        objContact1.DepartmentType__c = '药剂科' ;
        objContact1.ContactType__c = '行政' ;
        objContact1.V2_RenalGrade__c = '银' ;
        objContact1.V2_Level__c = 'B' ;
        list_Contact.add(objContact1) ;
        Contact objContact2 = new Contact() ;
        objContact2.LastName = 'Soon' ;
        objContact2.AccountId = objAccount1.Id ;
        objContact2.DepartmentType__c = '护理部' ;
        objContact2.ContactType__c = '护士' ;
        objContact2.V2_RenalGrade__c = '金' ;
        objContact2.V2_Level__c = 'A' ;
        list_Contact.add(objContact2) ;
        Contact objContact3 = new Contact() ;
        objContact3.LastName = 'Soon' ;
        objContact3.AccountId = objAccount1.Id ;
        objContact3.DepartmentType__c = '肾科' ;
        objContact3.ContactType__c = '医生' ;
        objContact3.V2_RenalGrade__c = '铜' ;
        objContact3.V2_Level__c = 'C' ;
        list_Contact.add(objContact3) ;
        Contact objContact4 = new Contact() ;
        objContact4.LastName = 'Soon' ;
        objContact4.AccountId = objAccount1.Id ;
        objContact4.DepartmentType__c = '肾科' ;
        objContact4.ContactType__c = '医生' ;
        objContact4.V2_RenalGrade__c = '铜' ;
        objContact4.V2_Level__c = 'C' ;
        list_Contact.add(objContact4) ;
        system.runAs(use1){
        insert list_Contact ;}
        //---------------New Campaign-------------------
        List<Campaign> list_Campaign = new List<Campaign>() ;
        Campaign objCampaign1 = new Campaign() ;
        objCampaign1.Name = 'cam1' ;
        objCampaign1.StartDate = date.today() ;
        objCampaign1.EndDate = date.today().addDays(2) ;
        objCampaign1.OwnerId = use1.Id ;
        list_Campaign.add(objCampaign1) ;
        system.runAs(use1){
        insert list_Campaign ;}
        //--------------New CampaignMember---------------------
        List<CampaignMember> list_CampaignMember = new List<CampaignMember>() ;
        CampaignMember objCamMem1 = new CampaignMember() ;
        objCamMem1.User__c = use1.Id ;
        objCamMem1.CampaignId = objCampaign1.Id ;
        objCamMem1.ContactId = objContact1.Id ;
        objCamMem1.V2_Account__c = objAccount1.Id ;
        objCamMem1.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem1) ;
        CampaignMember objCamMem2 = new CampaignMember() ;
        objCamMem2.User__c = use1.Id ;
        objCamMem2.CampaignId = objCampaign1.Id ;
        objCamMem2.ContactId = objContact2.Id ;
        objCamMem2.V2_Account__c = objAccount1.Id ;
        objCamMem2.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem2) ;
        CampaignMember objCamMem3 = new CampaignMember() ;
        objCamMem3.User__c = use1.Id ;
        objCamMem3.CampaignId = objCampaign1.Id ;
        objCamMem3.ContactId = objContact3.Id ;
        objCamMem3.V2_Account__c = objAccount1.Id ;
        objCamMem3.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem3) ;
        system.runAs(use1){
            insert list_CampaignMember ;
        }
        //--------------New MonthlyPlan-------------------
        MonthlyPlan__c objMonthlyPlan = new MonthlyPlan__c() ;
        objMonthlyPlan.Month__c = String.valueOf(date.today().month()) ;
        objMonthlyPlan.Year__c = String.valueOf(date.today().year()) ;
        objMonthlyPlan.OwnerId = use1.Id ;
        system.runAs(use1){
        insert objMonthlyPlan ;}
        //---------------New V2_UserBonusInFo__c-------------------
        V2_UserBonusInFo__c objBonusInfo = new V2_UserBonusInFo__c() ;
        objBonusInfo.V2_Month__c = String.valueOf(date.today().month());
        objBonusInfo.V2_Year__c = String.valueOf(date.today().year());
        objBonusInfo.OwnerId = use1.Id ;
        system.runAs(use1){
        insert objBonusInfo ;}
        //---------------New PatientApply------------------
        List<PatientApply__c> list_NewPatient = new List<PatientApply__c>() ;
        PatientApply__c objNewPatient1 = new PatientApply__c() ;
        objNewPatient1.IntubationHospital__c = objAccount2.Id ;
        objNewPatient1.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient1.PatientName__c = 'Patie1' ;
        objNewPatient1.Distributor__c = objAccount3.Id ;
        objNewPatient1.PM_Patient_MPhone__c = '18611112222';
        objNewPatient1.IntubationHospital__c = objAccount4.Id ;
        list_NewPatient.add(objNewPatient1) ;
        PatientApply__c objNewPatient2 = new PatientApply__c() ;
        objNewPatient2.IntubationHospital__c = objAccount2.Id ;
        objNewPatient2.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient2.PatientName__c = 'Patie2' ;
        objNewPatient2.Distributor__c = objAccount3.Id ;
        objNewPatient2.PM_Patient_MPhone__c = '18611112222';
        objNewPatient2.IntubationHospital__c = objAccount4.Id ;
        list_NewPatient.add(objNewPatient2) ;
        PatientApply__c objNewPatient3 = new PatientApply__c() ;
        objNewPatient3.IntubationHospital__c = objAccount2.Id ;
        objNewPatient3.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient3.PatientName__c = 'Patie3' ;
        objNewPatient3.Distributor__c = objAccount3.Id ;
        objNewPatient3.PM_Patient_MPhone__c = '18611112222';
        objNewPatient3.IntubationHospital__c = objAccount4.Id;
        list_NewPatient.add(objNewPatient3) ;
        system.runAs(use1){
            insert list_NewPatient ;
        }
        //--------------New Event-------------------
        List<Event> list_Events = new List<Event>() ;
        Event objEvent1 = new Event() ;
        objEvent1.WhoId = objContact1.Id ;
        objEvent1.WhatId = objAccount1.Id ;
        objEvent1.StartDateTime = Datetime.now() ;
        objEvent1.EndDateTime = Datetime.now().addHours(1) ;
        objEvent1.OwnerId = use1.Id ;
        objEvent1.Done__c = true ;
        objEvent1.Subject = '拜访' ;
        list_Events.add(objEvent1) ;
        Event objEvent2 = new Event() ;
        objEvent2.WhoId = objContact1.Id ;
        objEvent2.WhatId = objAccount1.Id ;
        objEvent2.StartDateTime = Datetime.now() ;
        objEvent2.EndDateTime = Datetime.now().addHours(2) ;
        objEvent2.OwnerId = use1.Id ;
        objEvent2.Done__c = true ;
        objEvent2.Subject = '拜访' ;
        list_Events.add(objEvent2) ;
        Event objEvent3 = new Event() ;
        objEvent3.WhoId = objContact1.Id ;
        objEvent3.WhatId = objAccount1.Id ;
        objEvent3.StartDateTime = Datetime.now() ;
        objEvent3.EndDateTime = Datetime.now().addHours(1) ;
        objEvent3.OwnerId = use1.Id ;
        objEvent3.Done__c = true ;
        objEvent3.Subject = '拜访' ;
        list_Events.add(objEvent3) ;
        Event objEvent4 = new Event() ;
        objEvent4.WhoId = objContact2.Id ;
        objEvent4.WhatId = objAccount1.Id ;
        objEvent4.StartDateTime = Datetime.now() ;
        objEvent4.EndDateTime = Datetime.now().addHours(1) ;
        objEvent4.OwnerId = use1.Id ;
        objEvent4.Done__c = true ;
        objEvent4.Subject = '拜访' ;
        list_Events.add(objEvent4) ;
        Event objEvent5 = new Event() ;
        objEvent5.WhoId = objContact2.Id ;
        objEvent5.WhatId = objAccount1.Id ;
        objEvent5.StartDateTime = Datetime.now() ;
        objEvent5.EndDateTime = Datetime.now().addHours(1) ;
        objEvent5.OwnerId = use1.Id ;
        objEvent5.Done__c = true ;
        objEvent5.Subject = '拜访' ;
        list_Events.add(objEvent5) ;
        Event objEvent6 = new Event() ;
        objEvent6.WhoId = objContact2.Id ;
        objEvent6.WhatId = objAccount1.Id ;
        objEvent6.StartDateTime = Datetime.now() ;
        objEvent6.EndDateTime = Datetime.now().addHours(1) ;
        objEvent6.OwnerId = use1.Id ;
        objEvent6.Done__c = true ;
        objEvent6.Subject = '拜访' ;
        list_Events.add(objEvent6) ;
        Event objEvent7 = new Event() ;
        objEvent7.WhoId = objContact3.Id ;
        objEvent7.WhatId = objAccount1.Id ;
        objEvent7.StartDateTime = Datetime.now() ;
        objEvent7.EndDateTime = Datetime.now().addHours(1) ;
        objEvent7.OwnerId = use1.Id ;
        objEvent7.Done__c = true ;
        objEvent7.Subject = '拜访' ;
        list_Events.add(objEvent7) ;
        Event objEvent8 = new Event() ;
        objEvent8.WhoId = objContact3.Id ;
        objEvent8.WhatId = objAccount1.Id ;
        objEvent8.StartDateTime = Datetime.now() ;
        objEvent8.EndDateTime = Datetime.now().addHours(1) ;
        objEvent8.OwnerId = use1.Id ;
        objEvent8.Done__c = true ;
        objEvent8.Subject = '拜访' ;
        list_Events.add(objEvent8) ;
        Event objEvent9 = new Event() ;
        objEvent9.WhoId = objContact3.Id ;
        objEvent9.WhatId = objAccount1.Id ;
        objEvent9.StartDateTime = Datetime.now() ;
        objEvent9.EndDateTime = Datetime.now().addHours(1) ;
        objEvent9.OwnerId = use1.Id ;
        objEvent9.Done__c = true ;
        objEvent9.Subject = '拜访' ;
        list_Events.add(objEvent9) ;
        Event objEvent10 = new Event() ;
        objEvent10.WhoId = objContact3.Id ;
        objEvent10.StartDateTime = Datetime.now() ;
        objEvent10.EndDateTime = Datetime.now().addHours(1) ;
        objEvent10.OwnerId = use1.Id ;
        objEvent10.Done__c = true ;
        objEvent10.Subject = '拜访' ;
        list_Events.add(objEvent10) ;
        Event objEvent11 = new Event() ;
        objEvent11.WhoId = objContact3.Id ;
        objEvent11.StartDateTime = Datetime.now() ;
        objEvent11.EndDateTime = Datetime.now().addHours(1) ;
        objEvent11.OwnerId = use1.Id ;
        objEvent11.Done__c = true ;
        objEvent11.Subject = '拜访' ;
        list_Events.add(objEvent11) ;
        Event objEvent12 = new Event() ;
        objEvent12.WhoId = objContact4.Id ;
        objEvent12.WhatId = objAccount1.Id ;
        objEvent12.StartDateTime = Datetime.now() ;
        objEvent12.EndDateTime = Datetime.now().addHours(1) ;
        objEvent12.OwnerId = use1.Id ;
        objEvent12.Done__c = true ;
        objEvent12.Subject = '拜访' ;
        list_Events.add(objEvent12) ;
        system.runAs(use1){
        insert list_Events ;}
        
        //-------------------------------------
        List<MonthlyPlanDetail__c> list_MPDUp = new List<MonthlyPlanDetail__c>() ;
        for(MonthlyPlanDetail__c objMPD :[Select m.AdjustedTimes__c From MonthlyPlanDetail__c m Where MonthlyPlan__c =: objMonthlyPlan.Id ])
        {
            objMPD.AdjustedTimes__c = 10 ;
            list_MPDUp.add(objMPD) ;
        }
        system.runAs(use1){
        update list_MPDUp ;}
        
        system.test.startTest() ;
        system.runAs(use1) {
            ApexPages.currentPage().getParameters().put('monId', objMonthlyPlan.Id);
            BQ_CtrlMonthlyPlanReport clsMonthlyReport = new BQ_CtrlMonthlyPlanReport() ;
            //clsMonthlyReport.testMet() ;
            clsMonthlyReport.userBonusInFo() ;
            List<String> liststr = clsMonthlyReport.list_RenalField ;
            liststr = clsMonthlyReport.list_RenalField2 ;
            liststr = clsMonthlyReport.list_MDField ;
            liststr = clsMonthlyReport.list_MDField2 ;
            liststr = clsMonthlyReport.list_BiosField ;
            liststr = clsMonthlyReport.list_BiosField2 ;
            String strTime = clsMonthlyReport.TimeDistributeCondition ;
            //目标联系人统计分析&拜访情况统计 Renal
            String str1 = clsMonthlyReport.PlanContactDistributionByGrade ;
            String str2 = clsMonthlyReport.ActualContactDistributionByGrade ;
            String str3 = clsMonthlyReport.ActualCallDistributionByGrade ;
            String str4 = clsMonthlyReport.PlanContactDistributionByType ;
            String str5 = clsMonthlyReport.ActualContactDistributionByType ;
            String str6 = clsMonthlyReport.ActualCallDistributionByType; 
            //目标联系人统计分析&拜访情况统计BIOS
            String strBi1 = clsMonthlyReport.PlanContactDistributionByGrade ;
            String strBi2 = clsMonthlyReport.ActualContactDistributionByGrade ;
            String strBi3 = clsMonthlyReport.ActualCallDistributionByGrade ;
            String strBi4 = clsMonthlyReport.PlanContactDistributionByDepartmentType ;
            String strBi5 = clsMonthlyReport.ActualContactDistributionByDepartmentType ;
            String strBi6 = clsMonthlyReport.ActualCallDistributionByDepartmentType;
            //拜访完成情况Renal
            String strRe1 =  clsMonthlyReport.VisitCompleteRatioCondition ;
            String strRe2 =  clsMonthlyReport.VisitCompleteCountCondition ;
            //拜访完成情况Bios
            String strBio1 =  clsMonthlyReport.VisitCompleteCountBios ;
            String strBio2 =  clsMonthlyReport.VisitCompleteCountBios2 ;
            String strBio3 =  clsMonthlyReport.visitComplete3 ;
            //拜访完成情况MD
            String strMD1 =  clsMonthlyReport.VisitCompleteCountConditionMD ;
            //时间分配情况 
            String strTiem = clsMonthlyReport.TimeDistributeCondition ;
            //主管协防情况
            List<ManHelpCondition> list_manhelp = clsMonthlyReport.getManHelpConditionList() ;
            //月计划明细
            List<MonthlyPlanDetailByAccount> list_mpd =  clsMonthlyReport.getMonthlyPlanDetailList();
            //今年市场活动情况
            List<YearMarketActivityCondition> list_ymac =  clsMonthlyReport.getActiveSignUpList() ;
            //新病人情况 
            String strNew = clsMonthlyReport.newPatientConditionStr ;
            //科内会情况BIOS
            List<DepartmentVisit> list_DV = clsMonthlyReport.getDepartmentVisits() ;
            //业务机会拜访情况MD
            String strMDOpp = clsMonthlyReport.OpportunityVisitMD ;
            //业务机会拜访情况Bios
            String strBiosOpp = clsMonthlyReport.OpportunityVisitBios ;
            //业务机会阶段情况
            String strOpp = clsMonthlyReport.BeforeThreeMonthOppStageStr ;
            //业务机会阶段情况 ——表格
            List<OpportunityState> list_oppS = clsMonthlyReport.oppStaList ;
            String oppsta = clsMonthlyReport.MonthCurrentOppStageStr ;
            OpportunityState opps = new OpportunityState() ;
            opps.opportunityName = 'wef' ;
            opps.account = 'wef' ;
            opps.state = 'wef' ;
            opps.possibility = 23 ;
            opps.overDate = date.today() ;
            opps.monthEventCount = 2 ;
            opps.monthVisitCount = 5 ;
            
        }
        OppStage os = new OppStage() ;
        OppStage os2 = new OppStage('234') ;
        
        system.test.stopTest() ;
    } 
    
    static testMethod void TestPDFPage3()
    {
        //----------------New UserRole ------------------
        //List<UserRole> list_userRole = new List<UserRole >() ;
        UserRole objUserRole = new UserRole() ;
        objUserRole.Name = 'MD-Rep-大上海-PD-Rep(陈喆令)' ;
        insert objUserRole ;
        UserRole objUserRole2 = new UserRole() ;
        objUserRole2.Name = 'MD-Rep-大上海-PB-Rep(陈喆令)' ;
        objUserRole2.ParentRoleId = objUserRole.Id ;
        insert objUserRole2 ;
        //--------------New User-------------------
        List<User> user = [select id,ProfileId,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey from User where id =: UserInfo.getUserId()] ;
        List<User> list_User = new List<User>() ;
        User use1=new User();
        use1.Username='user2@123.com';
        use1.LastName='user2';
        use1.Email='user2@123.com';
        use1.Alias=user[0].Alias;
        use1.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use1.ProfileId=user[0].ProfileId;
        use1.LocaleSidKey=user[0].LocaleSidKey;
        use1.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use1.EmailEncodingKey=user[0].EmailEncodingKey;
        use1.CommunityNickname='chequ1';
        use1.MobilePhone='12345678912';
        use1.UserRoleId = objUserRole2.Id ;
        use1.IsActive = true;
        list_User.add(use1) ;
        User use2=new User();
        use2.Username='user2@223.com';
        use2.LastName='user2';
        use2.Email='user2@223.com';
        use2.Alias=user[0].Alias;
        use2.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use2.ProfileId=user[0].ProfileId;
        use2.LocaleSidKey=user[0].LocaleSidKey;
        use2.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use2.EmailEncodingKey=user[0].EmailEncodingKey;
        use2.CommunityNickname='chequ2';
        use2.UserRoleId = objUserRole2.Id ;
        use2.MobilePhone='22345678922';
        use2.IsActive = true;
        list_User.add(use2) ;
        User use3=new User();
        use3.Username='user2@323.com';
        use3.LastName='user2';
        use3.Email='user2@323.com';
        use3.Alias=user[0].Alias;
        use3.TimeZoneSidKey=user[0].TimeZoneSidKey;
        use3.ProfileId=user[0].ProfileId;
        use3.LocaleSidKey=user[0].LocaleSidKey;
        use3.LanguageLocaleKey=user[0].LanguageLocaleKey;
        use3.EmailEncodingKey=user[0].EmailEncodingKey;
        use3.CommunityNickname='chequ3';
        use3.MobilePhone='32345678932';
        use3.UserRoleId = objUserRole.Id ;
        use3.IsActive = true;
        list_User.add(use3) ;
        insert list_User ;
        //--------------New Account-------------------
        RecordType objRT = [Select Id From RecordType Where DeveloperName =: 'RecordType_d_2' And SobjectType = 'Account'] ;
        RecordType objRT2 = [Select Id From RecordType Where DeveloperName =: 'RecordType' And SobjectType = 'Account'] ;
        List<Account> list_Account = new List<Account>() ;
        Account objAccount1 = new Account() ;
        objAccount1.Name = 'Acc1' ;
        list_Account.add(objAccount1) ;
        Account objAccount2 = new Account() ;
        objAccount2.Name = 'Acc2' ;
        list_Account.add(objAccount2) ;
        Account objAccount3 = new Account() ;
        objAccount3.Name = 'Acc3' ;
        objAccount3.RecordTypeId = objRT.Id ;
        list_Account.add(objAccount3) ;
        Account objAccount4 = new Account() ;
        objAccount4.Name = 'Acc4' ;
        objAccount4.RecordTypeId = objRT2.Id ;
        list_Account.add(objAccount4) ;
        system.runAs(use1){
        insert list_Account ;}  
        //--------------New Contact-------------------
        List<Contact> list_Contact = new List<Contact>() ;
        Contact objContact1 = new Contact() ;
        objContact1.LastName = 'Soon' ;
        objContact1.AccountId = objAccount1.Id ;
        objContact1.DepartmentType__c = '药剂科' ;
        objContact1.ContactType__c = '行政' ;
        objContact1.V2_RenalGrade__c = '银' ;
        objContact1.V2_Level__c = 'B' ;
        list_Contact.add(objContact1) ;
        Contact objContact2 = new Contact() ;
        objContact2.LastName = 'Soon' ;
        objContact2.AccountId = objAccount1.Id ;
        objContact2.DepartmentType__c = '护理部' ;
        objContact2.ContactType__c = '护士' ;
        objContact2.V2_RenalGrade__c = '金' ;
        objContact2.V2_Level__c = 'A' ;
        list_Contact.add(objContact2) ;
        Contact objContact3 = new Contact() ;
        objContact3.LastName = 'Soon' ;
        objContact3.AccountId = objAccount1.Id ;
        objContact3.DepartmentType__c = '肾科' ;
        objContact3.ContactType__c = '医生' ;
        objContact3.V2_RenalGrade__c = '铜' ;
        objContact3.V2_Level__c = 'C' ;
        list_Contact.add(objContact3) ;
        system.runAs(use1){
        insert list_Contact ;}
        //---------------New Campaign-------------------
        List<Campaign> list_Campaign = new List<Campaign>() ;
        Campaign objCampaign1 = new Campaign() ;
        objCampaign1.Name = 'cam1' ;
        objCampaign1.StartDate = date.today() ;
        objCampaign1.EndDate = date.today().addDays(2) ;
        objCampaign1.OwnerId = use1.Id ;
        list_Campaign.add(objCampaign1) ;
        system.runAs(use1){
        insert list_Campaign ;}
        //--------------New CampaignMember---------------------
        List<CampaignMember> list_CampaignMember = new List<CampaignMember>() ;
        CampaignMember objCamMem1 = new CampaignMember() ;
        objCamMem1.User__c = use1.Id ;
        objCamMem1.CampaignId = objCampaign1.Id ;
        objCamMem1.ContactId = objContact1.Id ;
        objCamMem1.V2_Account__c = objAccount1.Id ;
        objCamMem1.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem1) ;
        CampaignMember objCamMem2 = new CampaignMember() ;
        objCamMem2.User__c = use1.Id ;
        objCamMem2.CampaignId = objCampaign1.Id ;
        objCamMem2.ContactId = objContact2.Id ;
        objCamMem2.V2_Account__c = objAccount1.Id ;
        objCamMem2.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem2) ;
        CampaignMember objCamMem3 = new CampaignMember() ;
        objCamMem3.User__c = use1.Id ;
        objCamMem3.CampaignId = objCampaign1.Id ;
        objCamMem3.ContactId = objContact3.Id ;
        objCamMem3.V2_Account__c = objAccount1.Id ;
        objCamMem3.V2_Participated__c = true ;
        list_CampaignMember.add(objCamMem3) ;
        system.runAs(use1){
            insert list_CampaignMember ;
        }
        //--------------New MonthlyPlan-------------------
        MonthlyPlan__c objMonthlyPlan = new MonthlyPlan__c() ;
        objMonthlyPlan.Month__c = String.valueOf(date.today().month()) ;
        objMonthlyPlan.Year__c = String.valueOf(date.today().year()) ;
        objMonthlyPlan.OwnerId = use1.Id ;
        system.runAs(use1){
        insert objMonthlyPlan ;}
        //---------------New V2_UserBonusInFo__c-------------------
        V2_UserBonusInFo__c objBonusInfo = new V2_UserBonusInFo__c() ;
        objBonusInfo.V2_Month__c = String.valueOf(date.today().month());
        objBonusInfo.V2_Year__c = String.valueOf(date.today().year());
        objBonusInfo.OwnerId = use1.Id ;
        system.runAs(use1){
        insert objBonusInfo ;}
        //---------------New PatientApply------------------
        List<PatientApply__c> list_NewPatient = new List<PatientApply__c>() ;
        PatientApply__c objNewPatient1 = new PatientApply__c() ;
        objNewPatient1.IntubationHospital__c = objAccount2.Id ;
        objNewPatient1.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient1.PatientName__c = 'Patie1' ;
        objNewPatient1.Distributor__c = objAccount3.Id ;
        objNewPatient1.PM_Patient_MPhone__c = '18611112222';
        objNewPatient1.IntubationHospital__c = objAccount4.Id ;
        list_NewPatient.add(objNewPatient1) ;
        PatientApply__c objNewPatient2 = new PatientApply__c() ;
        objNewPatient2.IntubationHospital__c = objAccount2.Id ;
        objNewPatient2.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient2.PatientName__c = 'Patie2' ;
        objNewPatient2.Distributor__c = objAccount3.Id ;
        objNewPatient2.PM_Patient_MPhone__c = '18611112222';
        objNewPatient2.IntubationHospital__c = objAccount4.Id ;
        list_NewPatient.add(objNewPatient2) ;
        PatientApply__c objNewPatient3 = new PatientApply__c() ;
        objNewPatient3.IntubationHospital__c = objAccount2.Id ;
        objNewPatient3.PatientApply__c = objMonthlyPlan.Id ;
        objNewPatient3.PatientName__c = 'Patie3' ;
        objNewPatient3.PM_Patient_MPhone__c = '18611112222';
        objNewPatient3.Distributor__c = objAccount3.Id ;
        objNewPatient3.IntubationHospital__c = objAccount4.Id;
        list_NewPatient.add(objNewPatient3) ;
        system.runAs(use1){
            insert list_NewPatient ;
        }
        //--------------New Event-------------------
        List<Event> list_Events = new List<Event>() ;
        Event objEvent1 = new Event() ;
        objEvent1.WhoId = objContact1.Id ;
        objEvent1.WhatId = objAccount1.Id ;
        objEvent1.StartDateTime = Datetime.now() ;
        objEvent1.EndDateTime = Datetime.now().addHours(1) ;
        objEvent1.OwnerId = use1.Id ;
        objEvent1.Done__c = true ;
        objEvent1.Subject = '拜访' ;
        list_Events.add(objEvent1) ;
        Event objEvent2 = new Event() ;
        objEvent2.WhoId = objContact1.Id ;
        objEvent2.WhatId = objAccount1.Id ;
        objEvent2.StartDateTime = Datetime.now() ;
        objEvent2.EndDateTime = Datetime.now().addHours(2) ;
        objEvent2.OwnerId = use1.Id ;
        objEvent2.Done__c = true ;
        objEvent2.Subject = '拜访' ;
        list_Events.add(objEvent2) ;
        Event objEvent3 = new Event() ;
        objEvent3.WhoId = objContact1.Id ;
        objEvent3.WhatId = objAccount1.Id ;
        objEvent3.StartDateTime = Datetime.now() ;
        objEvent3.EndDateTime = Datetime.now().addHours(1) ;
        objEvent3.OwnerId = use1.Id ;
        objEvent3.Done__c = true ;
        objEvent3.Subject = '拜访' ;
        list_Events.add(objEvent3) ;
        Event objEvent4 = new Event() ;
        objEvent4.WhoId = objContact2.Id ;
        objEvent4.WhatId = objAccount1.Id ;
        objEvent4.StartDateTime = Datetime.now() ;
        objEvent4.EndDateTime = Datetime.now().addHours(1) ;
        objEvent4.OwnerId = use1.Id ;
        objEvent4.Done__c = true ;
        objEvent4.Subject = '拜访' ;
        list_Events.add(objEvent4) ;
        Event objEvent5 = new Event() ;
        objEvent5.WhoId = objContact2.Id ;
        objEvent5.WhatId = objAccount1.Id ;
        objEvent5.StartDateTime = Datetime.now() ;
        objEvent5.EndDateTime = Datetime.now().addHours(1) ;
        objEvent5.OwnerId = use1.Id ;
        objEvent5.Done__c = true ;
        objEvent5.Subject = '拜访' ;
        list_Events.add(objEvent5) ;
        Event objEvent6 = new Event() ;
        objEvent6.WhoId = objContact2.Id ;
        objEvent6.WhatId = objAccount1.Id ;
        objEvent6.StartDateTime = Datetime.now() ;
        objEvent6.EndDateTime = Datetime.now().addHours(1) ;
        objEvent6.OwnerId = use1.Id ;
        objEvent6.Done__c = true ;
        objEvent6.Subject = '拜访' ;
        list_Events.add(objEvent6) ;
        Event objEvent7 = new Event() ;
        objEvent7.WhoId = objContact3.Id ;
        objEvent7.WhatId = objAccount1.Id ;
        objEvent7.StartDateTime = Datetime.now() ;
        objEvent7.EndDateTime = Datetime.now().addHours(1) ;
        objEvent7.OwnerId = use1.Id ;
        objEvent7.Done__c = true ;
        objEvent7.Subject = '拜访' ;
        list_Events.add(objEvent7) ;
        Event objEvent8 = new Event() ;
        objEvent8.WhoId = objContact3.Id ;
        objEvent8.WhatId = objAccount1.Id ;
        objEvent8.StartDateTime = Datetime.now() ;
        objEvent8.EndDateTime = Datetime.now().addHours(1) ;
        objEvent8.OwnerId = use1.Id ;
        objEvent8.Done__c = true ;
        objEvent8.Subject = '拜访' ;
        list_Events.add(objEvent8) ;
        Event objEvent9 = new Event() ;
        objEvent9.WhoId = objContact3.Id ;
        objEvent9.WhatId = objAccount1.Id ;
        objEvent9.StartDateTime = Datetime.now() ;
        objEvent9.EndDateTime = Datetime.now().addHours(1) ;
        objEvent9.OwnerId = use1.Id ;
        objEvent9.Done__c = true ;
        objEvent9.Subject = '拜访' ;
        list_Events.add(objEvent9) ;
        Event objEvent10 = new Event() ;
        objEvent10.WhoId = objContact3.Id ;
        objEvent10.StartDateTime = Datetime.now() ;
        objEvent10.EndDateTime = Datetime.now().addHours(1) ;
        objEvent10.OwnerId = use1.Id ;
        objEvent10.Done__c = true ;
        objEvent10.Subject = '拜访' ;
        list_Events.add(objEvent10) ;
        Event objEvent11 = new Event() ;
        objEvent11.WhoId = objContact3.Id ;
        objEvent11.StartDateTime = Datetime.now() ;
        objEvent11.EndDateTime = Datetime.now().addHours(1) ;
        objEvent11.OwnerId = use1.Id ;
        objEvent11.Done__c = true ;
        objEvent11.Subject = '拜访' ;
        list_Events.add(objEvent11) ;
        system.runAs(use1){
        insert list_Events ;}
        
        //-------------------------------------
        List<MonthlyPlanDetail__c> list_MPDUp = new List<MonthlyPlanDetail__c>() ;
        for(MonthlyPlanDetail__c objMPD :[Select m.AdjustedTimes__c From MonthlyPlanDetail__c m Where MonthlyPlan__c =: objMonthlyPlan.Id ])
        {
            objMPD.AdjustedTimes__c = 10 ;
            list_MPDUp.add(objMPD) ;
        }
        system.runAs(use1){
        update list_MPDUp ;}
        
        system.test.startTest() ;
        system.runAs(use1) {
            ApexPages.currentPage().getParameters().put('monId', objMonthlyPlan.Id);
            BQ_CtrlMonthlyPlanReport clsMonthlyReport = new BQ_CtrlMonthlyPlanReport() ;
            //clsMonthlyReport.testMet() ;
            clsMonthlyReport.userBonusInFo() ;
            List<String> liststr = clsMonthlyReport.list_RenalField ;
            liststr = clsMonthlyReport.list_RenalField2 ;
            liststr = clsMonthlyReport.list_MDField ;
            liststr = clsMonthlyReport.list_MDField2 ;
            liststr = clsMonthlyReport.list_BiosField ;
            liststr = clsMonthlyReport.list_BiosField2 ;
            String strTime = clsMonthlyReport.TimeDistributeCondition ;
            //目标联系人统计分析&拜访情况统计 Renal
            String str1 = clsMonthlyReport.PlanContactDistributionByGrade ;
            String str2 = clsMonthlyReport.ActualContactDistributionByGrade ;
            String str3 = clsMonthlyReport.ActualCallDistributionByGrade ;
            String str4 = clsMonthlyReport.PlanContactDistributionByType ;
            String str5 = clsMonthlyReport.ActualContactDistributionByType ;
            String str6 = clsMonthlyReport.ActualCallDistributionByType; 
            //目标联系人统计分析&拜访情况统计BIOS
            String strBi1 = clsMonthlyReport.PlanContactDistributionByGrade ;
            String strBi2 = clsMonthlyReport.ActualContactDistributionByGrade ;
            String strBi3 = clsMonthlyReport.ActualCallDistributionByGrade ;
            String strBi4 = clsMonthlyReport.PlanContactDistributionByDepartmentType ;
            String strBi5 = clsMonthlyReport.ActualContactDistributionByDepartmentType ;
            String strBi6 = clsMonthlyReport.ActualCallDistributionByDepartmentType;
            //拜访完成情况Renal
            String strRe1 =  clsMonthlyReport.VisitCompleteRatioCondition ;
            String strRe2 =  clsMonthlyReport.VisitCompleteCountCondition ;
            //拜访完成情况Bios
            String strBio1 =  clsMonthlyReport.VisitCompleteCountBios ;
            String strBio2 =  clsMonthlyReport.VisitCompleteCountBios2 ;
            String strBio3 =  clsMonthlyReport.visitComplete3 ;
            //拜访完成情况MD
            String strMD1 =  clsMonthlyReport.VisitCompleteCountConditionMD ;
            //时间分配情况 
            String strTiem = clsMonthlyReport.TimeDistributeCondition ;
            //主管协防情况
            List<ManHelpCondition> list_manhelp = clsMonthlyReport.getManHelpConditionList() ;
            //月计划明细
            List<MonthlyPlanDetailByAccount> list_mpd =  clsMonthlyReport.getMonthlyPlanDetailList();
            //今年市场活动情况
            List<YearMarketActivityCondition> list_ymac =  clsMonthlyReport.getActiveSignUpList() ;
            //新病人情况 
            String strNew = clsMonthlyReport.newPatientConditionStr ;
            //科内会情况BIOS
            List<DepartmentVisit> list_DV = clsMonthlyReport.getDepartmentVisits() ;
            //业务机会拜访情况MD
            String strMDOpp = clsMonthlyReport.OpportunityVisitMD ;
            //业务机会拜访情况Bios
            String strBiosOpp = clsMonthlyReport.OpportunityVisitBios ;
            //业务机会阶段情况
            String strOpp = clsMonthlyReport.BeforeThreeMonthOppStageStr ;
            //业务机会阶段情况 ——表格
            List<OpportunityState> list_oppS = clsMonthlyReport.oppStaList ;
            String oppsta = clsMonthlyReport.MonthCurrentOppStageStr ;
            OpportunityState opps = new OpportunityState() ;
            opps.opportunityName = 'wef' ;
            opps.account = 'wef' ;
            opps.state = 'wef' ;
            opps.possibility = 23 ;
            opps.overDate = date.today() ;
            opps.monthEventCount = 2 ;
            opps.monthVisitCount = 5 ;
            
        }
        
        system.test.stopTest() ;
    } 
    
}
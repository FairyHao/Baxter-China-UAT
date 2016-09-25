/*******************************************************************************
 * Copyright (c) celnet
 *@Author Spring
 *@Date 2016-01-12
 *@Description
 *ACUTE仪表盘需求
 *1.策略性和S1-3医院拜访统计
 *2.进行中机器业务机会统计、以及有效拜访统计
 *3.对一级经销商的业务研讨会统计
 *@Test <Test_DashBoardAction.TestACUTEDDashBoardAction()>
 *@See <>F
 *******************************************************************************/
public with sharing class ACUTEDashBoardAction {

    public Event selectUser{get;set;}
    private Set<Id> renalValidSuperSet = new Set<Id>();

    public String currUserId{get;set;}      // 当前选择用户Id
    public List<InnerEntity> entityList{get;private set;}

    private String yearStr;
    private String monthStr;

    private Map<String,Bonus_data__c> bonusByUserMap = new Map<String,Bonus_data__c>();

    private Set<Id> salesSet;               // 销售 & 主管带医院

    public String selectMonth{get;set;}     // 本月与上月

    private Boolean isBuAdmin = FALSE;

    public ACUTEDashBoardAction() {
      yearStr = String.valueOf(System.today().year());
      monthStr = String.valueOf(System.today().month());
      selectMonth = 'Y';
      selectUser = new Event();

      currUserId = UserInfo.getUserId();
      selectUser.OwnerId = currUserId;

      // 判断当前的登录者身份是否为admin
      User u = [SELECT UserRoleId,Profile.Name FROM User WHERE Id =:currUserId][0];
      if (  (u.Profile.Name).contains('admin')
          ||(u.Profile.Name).contains('Admin')
          || u.Profile.Name == '系统管理员'
          || u.Profile.Name == 'administrator') {
        isBuAdmin = TRUE;
      }

      this.reLoadData();
    }

    private void  reLoadData(){
      // 下属
      this.salesSet = this.getSales(currUserId);

      this.bonusByUserMap = this.getBonus(salesSet);
      System.debug('xs====>'+bonusByUserMap.size());

      // 数据展示
      this.entityList = this.doAction();
    }

    // 根据选择的用户重新加载数据
    public void doActionByUser(){
      if (selectUser.OwnerId == NULL) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'请选择一个用户!');
        ApexPages.addMessage(msg);
        entityList.clear();
        return;
      }

      currUserId = selectUser.OwnerId;
      this.salesSet = this.getSales(currUserId);
      if (!salesSet.contains(currUserId) && !isBuAdmin) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error,'该用户不是你的下属');
        ApexPages.addMessage(msg);
        entityList.clear();
        return;
      }

      // 判断时间
      if (this.selectMonth == NULL || this.selectMonth == 'Y') {
        yearStr = String.valueOf(System.today().year());
        monthStr = String.valueOf(System.today().month());
      } else {
        yearStr = String.valueOf(System.today().year());
        if (System.today().month() == 1) {
          yearStr = String.valueOf(System.today().year() - 1);
          monthStr = '12';
        } else {
          monthStr = String.valueOf(System.today().month() - 1);
        }
      }

      this.reLoadData();
    }

    // 获取该用户角色树下所有的用户的当月角色历史
    private Set<Id> getSales(Id uid){
      Map<Id,V2_RoleHistory__c> roleHistoryMap = new Map<Id,V2_RoleHistory__c>();
      for (V2_RoleHistory__c obj : [SELECT Id, Renal_valid_super__c, Level__c,Name__c
                                    FROM   V2_RoleHistory__c
                                    WHERE  (Manager__c =:uid Or Name__c =:uid)
                                    AND    Month__c =: monthStr
                                    AND    Year__c  =: yearStr
                                    AND    Name__r.Profile.Name IN ('Standard User - ACUTE Sales Rep','Standard User - ACUTE Sales Supervisor')
                                    AND    IsOnHoliday__c = FALSE
                                    AND    IsLeave__c = FALSE
                                    AND    Status__c != '停用'
      ]) {
        if(obj.Renal_valid_super__c){
          renalValidSuperSet.add(obj.Name__c);
        }
        roleHistoryMap.put(obj.Name__c, obj);
      }

      return roleHistoryMap.keySet();
    }

    // 获取该用户下属当月的奖金数据
    private Map<String,Bonus_data__c> getBonus(Set<Id> uid){
      Map<String,Bonus_data__c>  bonusByIdMap = new Map<String,Bonus_data__c>();
      for (Bonus_data__c obj : [SELECT A_ACUTE_P5_visit__c, A_ACUTE_machine_opp_count__c,
                                       A_ACUTE_machine_oppVisit_count__c,
                                       A_ACUTE_first_visit_count__c, Owner.Alias,
                                       A_Department_number__c, A_ACUTE_HaiCai_oppCount__c,
                                       A_ACUTE_HaoCai_visitCount__c
                                FROM   Bonus_data__c
                                WHERE  Year__c =:this.yearStr
                                AND    Month__c =:this.monthStr
                                AND    OwnerId IN:uid]) {
        bonusByIdMap.put(obj.OwnerId, obj);
      }
      return bonusByIdMap;
    }

    // 组装数据
    /**
     * [doAction description]
     * @param  uList [description]
     * @return       [description]
     */
    private List<InnerEntity> doAction(){
      
      List<InnerEntity> entityList = new List<InnerEntity>(bonusByUserMap.size());
     
      
      Integer listIndex = 1; // 非当前查询人，从第1位开始放,当前查询人，方第0位
      for (Bonus_data__c obj : bonusByUserMap.values()) {
        
        InnerEntity t1 = new InnerEntity();
        t1.userName = obj.Owner.Alias;
        t1.amount = this.salesSet.size();
        t1.userId = obj.Owner.Id;
        t1.managerIdSet = renalValidSuperSet;
        t1.hospitalCount = obj.A_ACUTE_P5_visit__c ;
        t1.machineOppCount = obj.A_ACUTE_machine_opp_count__c;
        t1.machineOppVisitCount = obj.A_ACUTE_machine_oppVisit_count__c;
        t1.distributorMeetingCount = obj.A_ACUTE_first_visit_count__c;
        t1.groupSellingCount = obj.A_Department_number__c;
        t1.setsOppCount = obj.A_ACUTE_HaiCai_oppCount__c;
        t1.callOfSetOppCount = obj.A_ACUTE_HaoCai_visitCount__c;
        if(obj.Owner.id == selectUser.OwnerId){
          entityList[0] = t1;
        }
        else if((obj.Owner.id != selectUser.OwnerId) && bonusByUserMap.size() == 1){
          entityList[0] = t1;
        }else {
          entityList[listIndex++] = t1;
        }
      }

      System.debug('entityList===>'+entityList.size());
      
      return entityList;
    }



    // Entity
    //

    public class InnerEntity{

      private final String GREEN  = 'GREEN';
      private final String RED    = 'RED';
      private final String YELLOW = 'YELLOW';

      private String userId;
      private Integer amount;
      private Set<Id> managerIdSet;
      public String  userName{get;private set;}
      // W1
      public Decimal hospitalCount{private set;get{
        return hospitalCount == NULL ? 0 : hospitalCount;
      }}
      public Decimal machineOppCount{private set;get{
        return machineOppCount == NULL ? 0 : machineOppCount;
      }}
      public Decimal machineOppVisitCount{private set;get{
        return machineOppVisitCount == NULL ? 0 : machineOppVisitCount;
      }}
      public Decimal distributorMeetingCount{private set;get{
        return distributorMeetingCount == NULL ? 0 : distributorMeetingCount;
      }}

      // W2
      public Decimal groupSellingCount{private set;get{
        return groupSellingCount == NULL ? 0 : groupSellingCount;
      }}
      public Decimal setsOppCount{private set;get{
        return setsOppCount == NULL ? 0 : setsOppCount;
      }}
      public Decimal callOfSetOppCount{private set;get{
        return callOfSetOppCount == NULL ? 0 : callOfSetOppCount;
      }}


      public String hospitalColor{private set;get{
        if (hospitalCount >= 4 ) {
           return this.GREEN;
        }
        if (hospitalCount >= 3 ) {
            return this.YELLOW;
        }
        return this.RED;
      }}
      public String machineOppColor{private set;get{
        if(managerIdSet.contains(userId))//主管带医院的指标 Dean 20160601
        {
          if (machineOppCount >= ((2.0+(amount-1.0)*4.0)/amount)) {
           return this.GREEN;
          }
          if (machineOppCount >= (0.9*(2.0+(amount-1.0)*4.0)/amount)) {
              return this.YELLOW;
          }
        }else{
          if (machineOppCount >= 4) {
           return this.GREEN;
          }
          if (machineOppCount >= 3 ) {
              return this.YELLOW;
          }
          
        }
        return this.RED;
       }}

      public String machineOppVisitColor{private set;get{
        if(managerIdSet.contains(userId))//主管带医院的指标
        {
          if (machineOppVisitCount >= (8.0+(amount-1.0)*16.0)/amount) {
           return this.GREEN;
          }
          if (machineOppVisitCount >= (0.9*(8.0+(amount-1.0)*16.0)/amount)) {
              return this.YELLOW;
          }
        }else{
          if (machineOppVisitCount >= 16) {
              return this.GREEN;
          }
          if (machineOppVisitCount >= 12) {
              return this.YELLOW;
          }
        }
        return this.RED;
      }}
      public String distributorMeetingColor{private set;get{
        if (distributorMeetingCount >=1 ) {
            return this.GREEN;
        }
        return this.RED;
      }}

      public String groupSellingColor{private set; get{
        if (groupSellingCount >= 1) {
            return this.GREEN;
        }
        return this.RED;
      }}

      public String setsOppColor{private set; get{
        if(managerIdSet.contains(userId))//主管带医院的指标
        {
          if (setsOppCount >= (2.0+(amount-1.0)*4.0)/amount) {
           return this.GREEN;
          }
          if (setsOppCount >= (0.9*(2.0+(amount-1.0)*4.0)/amount)) {
              return this.YELLOW;
          }
        }else{
          if (setsOppCount >= 4) {
              return this.GREEN;
          }
          if (setsOppCount >= 3) {
             return this.YELLOW;
          }
        }
        return this.RED;
      }}

      public String callOfSetOppColor{private set; get{
        if(managerIdSet.contains(userId))//主管带医院的指标
        {
          if (callOfSetOppCount >= (8.0+(amount-1.0)*16.0)/amount) {
           return this.GREEN;
          }
          if (callOfSetOppCount >= (0.9*(8.0+(amount-1.0)*16.0)/amount)) {
              return this.YELLOW;
          }
        }else{
          if (callOfSetOppCount >= 16) {
            return this.GREEN;
          }
          if (callOfSetOppCount >= 12) {
            return this.YELLOW;
          }
        }
        return this.RED;
      }}
    }
}
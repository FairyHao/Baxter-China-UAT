/*
Author:Dean
Date:2015-10-22
Function:WebAce 新建辅导计划
Change:Competency和Question根据被辅导人显示，SEM可以对SR辅导 2016-06-21
 */
public class acePlanEditPageController
{
    public List<compentencyAndQues>  compentencyAndQuesList{set;get;}//重点领域列表
    public String coachTimes{set;get;}//辅导次数
    public String FocusAreaNote{set;get;} //重点领域说明
    public List<selectOption> options{set;get;} //能力模型Option
    public List<selectOption> timeOptions{set;get;} //次数Option
    public String selectedUser{set;get;}//被辅导人
    public String alertMsg{set;get;}
    public String checkInfoMsg{set;get;}
    public String peroidNow{set;get;}//计划所在
    public boolean flag{set;get;}//是否有上一周期
    public Plan__c plan{set;get;}
    public boolean isAllowEdit{set;get;}//允许修改
    public boolean isAllowEditOwner{set;get;}//是否允许修改记录所有人
    private User coachor;//辅导人
    private User coachee;//被辅导人
    private String pid;//当前辅导计划的ID
    private Map<String,List<Question__c>> queMap;
    private Map<String,List<planDetail>> detailMap;
    private Map<string,Competency__c> comMap;
    private Map<String,String> lastAnswerMap;
    private List<Plan_Detail__c> PlanDetailList;

    //初始化
    public acePlanEditPageController(ApexPages.StandardController con) 
    {
        User checkUser =[select id,Ace_Role__c,isAceAdmin__c,profile.Name from User where id =: userinfo.getUserId()];
        
        String cid = con.getId();
        pid = cid;
        List<Plan__c> planList = [select id,Rep_Id__r.Alias,
                                            User_Id__r.Alias,Period_1__c,
                                            Session_Allocated_Goal_Update__c,
                                            Focus_Area_Note__c,status__c,OwnerId from Plan__c where id =:cid];
        if(planList.size() == 0){
            return;
        }         
        plan = planList[0];
        
        //验证数据是否可以修改
        if(checkUser.Profile.Name.contains('Admin') || 
           checkUser.Profile.Name.contains('系统管理员') || 
           checkUser.Profile.Name.contains('administrator')|| plan.status__c == '草稿'){
            isAllowEdit = true;
        }
        else{
            isAllowEdit = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'不允许修改数据');
            ApexPages.addMessage(myMsg);
        }

        if(checkUser.Profile.Name.contains('系统管理员') || checkUser.Profile.Name.contains('administrator')|| checkUser.isAceAdmin__c == true ){
            isAllowEditOwner = true;
        }

        PlanDetailList = [SELECT id,Competency_Id__c,
                                 Question_Id__c,Answer__c,
                                 isFocusArea_Selected__c,
                                 Question_Id__r.Details__c FROM Plan_Detail__c WHERE Plan__c =:plan.Id];
        
        coachor =[SELECT id,Ace_Role__c,Name,isAceAdmin__c,Alias FROM User where id =: plan.User_Id__c];
        coachee = [SELECT id,Ace_Role__c,Name,isAceAdmin__c,Alias FROM User where id =: plan.Rep_Id__c];  

        //页面所需数据
        getSelectOption();
        getTimesSelectOption();
        selectedUser = plan.Rep_Id__r.Alias;
        peroidNow = plan.Period_1__c;
        getLastPeriodAnswer(plan);
        getcompentencyAndQuesList();
        FocusAreaNote = plan.Focus_Area_Note__c;
        coachTimes = String.valueOf(plan.Session_Allocated_Goal_Update__c);     
    }

    //将compentency和Question组合
    public void  getcompentencyAndQuesList()
    {
        Set<ID> competencyIdSet = new Set<ID>();
        for(Plan_Detail__c obj:PlanDetailList)
        {
            if(obj.Competency_Id__c == null)
            {
                continue;
            }
            competencyIdSet.add(obj.Competency_Id__c);
        }
        //找到被辅导人对应的Compentency
        List<Competency__c> compList = new List<Competency__c>();
        compList = [SELECT id,Name,Competency_Description__c 
                    FROM Competency__c 
                    WHERE id IN:competencyIdSet];

        if(compList.size() == 0){
            return;
        }
        comMap = new Map<string,Competency__c>();
        for(Competency__c c:compList){
            comMap.put(c.Id, c);
        }
        
        //queMap将Question和Competency关联
        List<Question__c> qList = [SELECT id,Details__c,Name,Competency_Id__c 
                                   FROM Question__c 
                                   WHERE Competency_Id__c IN:comMap.keySet()];
        queMap = new Map<String,List<Question__c>>();
        for(Question__c q:qList){
            if(!queMap.containsKey(q.Competency_Id__c)){
                queMap.put(q.Competency_Id__c, new List<Question__c>());
            }
                List<Question__c> temList = queMap.get(q.Competency_Id__c);
                temList.add(q);
                queMap.put(q.Competency_Id__c, temList);
        }

        detailMap = new Map<String,List<planDetail>>();
        for(Plan_Detail__c pd: PlanDetailList){
            if(!detailMap.containsKey(pd.Competency_Id__c)){
                detailMap.put(pd.Competency_Id__c, new List<PlanDetail>());
            }
                List<PlanDetail> tempList = detailMap.get(pd.Competency_Id__c);
                PlanDetail tempPlanDetail = new PlanDetail();
                tempPlanDetail.question = new Question__c();
                tempPlanDetail.question.id = pd.Question_Id__c;
                tempPlanDetail.question.Details__c = pd.Question_Id__r.Details__c;
                tempPlanDetail.answer =pd.Answer__c;
                tempPlanDetail.planDetailId = pd.Id;
                tempPlanDetail.isFocusArea = pd.isFocusArea_Selected__c;
                if(flag){
                tempPlanDetail.lastPeriodAnswer = lastAnswerMap.get(pd.Question_Id__c);
                }
                tempList.add(tempPlanDetail);
                detailMap.put(pd.Competency_Id__c,tempList);
        }

        //打包成一个内部类
        compentencyAndQuesList =  new List<compentencyAndQues>();
        for(String id:comMap.keySet()){
            compentencyAndQues obj = new compentencyAndQues();
            obj.com = comMap.get(id);
            obj.queList = queMap.get(id);
            obj.planDetailList = detailMap.get(id);
            compentencyAndQuesList.add(obj); 
        }
        
    }

    //获取上个周期对应的Question的阶段
    public  void getLastPeriodAnswer(Plan__c p)
    {
        List<Plan__c> pList = [SELECT id FROM Plan__c WHERE Rep_Id__r.Id =:p.Rep_Id__c order by CreatedDate desc];
        if(pList.size() == 1){
            flag = false;
            return; 
        }
        Plan__c plan = pList[1];
        List<Plan_Detail__c> detailList = [SELECT id,Question_Id__r.Id,Answer__c FROM Plan_Detail__c WHERE Plan__c =:plan.Id];
        if(detailList.size() == 0){
            flag = false;
            return;
        }
        lastAnswerMap = new Map<String,String>();
        for(Plan_Detail__c pd:detailList){
            lastAnswerMap.put(pd.Question_Id__r.Id,pd.Answer__c);
        }
            flag = true;
    }

    public PageReference savePage()
    {
        if(!checkInfo()){
            return null;
        }
        Plan__c p = [SELECT id,Session_Allocated_Goal_Update__c FROM Plan__c WHERE Id =: pid Limit 1];
        p.Session_Allocated_Goal_Update__c =  Decimal.valueOf(coachTimes);
        p.Focus_Area_Note__c = FocusAreaNote;
        p.OwnerId = plan.OwnerId;
        update p;
        //更新PlanDetail记录
        List<Plan_Detail__c> tempPlanDetailListtailList = new List<Plan_Detail__c>();
        for(String id:detailMap.keySet()){
            List<planDetail> tempList = detailMap.get(id);
            for(planDetail obj:tempList){
                Plan_Detail__c pd =  new Plan_Detail__c();
                pd.Id = obj.planDetailId;
                pd.Question_Id__c = obj.question.Id;
                pd.Competency_Id__c =id;
                pd.Answer__c = obj.answer;
                pd.isFocusArea_Selected__c = obj.isFocusArea;
                tempPlanDetailListtailList.add(pd);
            }
        }
        update tempPlanDetailListtailList;
        PageReference pageRef = new PageReference('/'+pid);
        return pageRef;
    }

    public PageReference back()
    {
        String[] types = new String[]{'Plan__c'};
        Schema.DescribeSobjectResult[] results = schema.describeSObjects(types);
        String  str ='';
        for(Schema.DescribeSobjectResult res : results){
             str= res.getKeyPrefix();
        }
        PageReference pageRef = new PageReference('/'+str);
        return pageRef;
    }


    //获取阶段的选项值
    public void getSelectOption()
    {
        options = new List<SelectOption>();
        options.add(new SelectOption('收效甚微','收效甚微'));
        options.add(new SelectOption('有待提高','有待提高'));
        options.add(new SelectOption('卓越有效','卓越有效'));
        options.add(new SelectOption('堪称模范','堪称模范'));
        options.add(new SelectOption('不适用','不适用'));
    }

    //获取阶段的选项值
    public void getTimesSelectOption()
    {
        timeOptions = new List<selectOption>();
        for(integer i = 1;i < 21 ;i++){
            timeOptions.add(new selectOption(string.valueOf(i),string.valueOf(i)));
        }
    }

    //校验数据
    public boolean checkInfo()
    {
        checkInfoMsg = '';
        //每个Question的阶段必填
        integer focusArea = 0;
        for(String id:comMap.keySet()){           
            for(planDetail pd: detailMap.get(id)){
                //累计关键领域的数量
                if(pd.isFocusArea == true){
                    focusArea++;
                }
                if(pd.answer == null || pd.answer == ''){
                    checkInfoMsg += '请填写每个技能的阶段的值';
                    return false;
                }
            }
        }
        // 最多选四个最少选一个重点领域
        if(focusArea < 1 || focusArea > 4){
            checkInfoMsg += '重点领域至少选一个最多选四个';
            return false;
        }
        if(FocusAreaNote == null || FocusAreaNote == ''){
            checkInfoMsg += '请填写重点领域说明';
            return false;
        }
        if(integer.valueOf(coachTimes) == null || integer.valueOf(coachTimes) == 0){
            checkInfoMsg += '请填写次数辅导';
            return false;
        }
        return true;
    }
    

/************************内部类，用于前端显示进度及问题******************************/
    class compentencyAndQues
    {
        public Competency__c com{set;get;}
        public List<Question__c> queList{set;get;}
        public List<planDetail> planDetailList{set;get;}
    }

    class planDetail
    {
        public Question__c question{set;get;}
        public boolean isFocusArea{set;get;}
        public String answer{set;get;}
        public String lastPeriodAnswer{set;get;}
        public String planDetailId{set;get;}
    }

    class selectQuestion
    {
        public Question__c question{set;get;}
    }

}
/*
Author:Dean
Date:2015-10-22
Function:WebAce  查看辅导计划
Change:Competency和Question根据被辅导人显示，SEM可以对SR辅导 2016-06-21
*/
public class acePlanViewPageController
{
    public List<compentencyAndQues>  compentencyAndQuesList{set;get;}//重点领域列表

    public String coachTimes{set;get;}//辅导次数
    public String FocusAreaNote{set;get;} //重点领域说明

    public List<selectOption> options{set;get;} //能力模型Option
    public String selectedUser{set;get;}//被辅导人

    private User coachor;//辅导人
    private User coachee;//被辅导人

    public Map<String,List<Question__c>> queMap{set;get;}
    public Map<String,List<planDetail>> detailMap{set;get;}
    public Map<string,Competency__c> comMap{set;get;}
    public Map<String,String> lastAnswerMap{set;get;}
    public List<Plan_Detail__c> PlanDetailList{set;get;}
    //public Map<String,String> questionMap{set;get;}

    public String alertMsg{set;get;}
    public String checkInfoMsg{set;get;}
    public String peroidNow{set;get;}//计划所在

    public boolean flag{set;get;}//是否有上一周期
    public String planID{set;get;}//计划ID

    public Plan__c plan{set;get;}

    

    //初始化
    public acePlanViewPageController(ApexPages.StandardController con) 
    {
        String cid = con.getId();
        planID = cid;
        List<Plan__c> planList = [select id,Rep_Id__r.Alias,
                                            User_Id__r.Alias,Period_1__c,
                                            Session_Allocated_Goal_Update__c,
                                            Focus_Area_Note__c,OwnerId from Plan__c where id =:cid];
        if(planList.size() == 0)
        {
            return;
        }         

        plan = planList[0];
        PlanDetailList = [select id,Competency_Id__c,
                                 Question_Id__c,Answer__c,
                                 isFocusArea_Selected__c,Question_Id__r.Details__c from Plan_Detail__c where Plan__c =:plan.Id];
        
        coachor =[select id,Ace_Role__c,Name,isAceAdmin__c,Alias from User where IsActive = true and id =: plan.User_Id__c];
        coachee =[select id,Ace_Role__c,Name,isAceAdmin__c,Alias from User where IsActive = true and id =: plan.Rep_Id__c];


        //页面所需数据
        getSelectOption();
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
        //Set<ID> questionIdSet = new Set<ID>();
        for(Plan_Detail__c obj:PlanDetailList)
        {
            if(obj.Competency_Id__c == null)
            {
                continue;
            }
            competencyIdSet.add(obj.Competency_Id__c);
        }
        //找到当前用户对应的Compentency
        List<Competency__c> compList = new List<Competency__c>();
        compList = [select id,Name,Competency_Description__c from Competency__c where Id IN:competencyIdSet];
        
        if(compList.size() == 0)
        {
            return;
        }

        comMap = new Map<string,Competency__c>();
        for(Competency__c c:compList)
        {
            comMap.put(c.Id, c);
        }
        

        //queMap将Question和Competency关联
        List<Question__c> qList = [select id,Details__c,Name,Competency_Id__c from Question__c 
                                                                where Competency_Id__c IN:comMap.keySet()];
        queMap = new Map<String,List<Question__c>>();
        
        for(Question__c q:qList)
        {
            
            if(!queMap.containsKey(q.Competency_Id__c))
            {
                queMap.put(q.Competency_Id__c, new List<Question__c>());
                
            }

            List<Question__c> temList = queMap.get(q.Competency_Id__c);
            
            temList.add(q);
            queMap.put(q.Competency_Id__c, temList);

        }

        detailMap = new Map<String,List<planDetail>>();
        for(Plan_Detail__c pd: PlanDetailList)
        {
            if(!detailMap.containsKey(pd.Competency_Id__c))
            {
                detailMap.put(pd.Competency_Id__c, new List<PlanDetail>());
            }
            
            List<PlanDetail> tempList = detailMap.get(pd.Competency_Id__c);
            
            PlanDetail tempPlanDetail = new PlanDetail();
            tempPlanDetail.question = new Question__c();
            tempPlanDetail.question.id = pd.Question_Id__c;
            tempPlanDetail.question.Details__c = pd.Question_Id__r.Details__c;//questionMap.get(pd.Question_Id__c);
            tempPlanDetail.answer =pd.Answer__c;
            
            tempPlanDetail.isFocusArea = pd.isFocusArea_Selected__c;
            
            if(flag)
            {
            tempPlanDetail.lastPeriodAnswer = lastAnswerMap.get(pd.Question_Id__c);
            }
            
            tempList.add(tempPlanDetail);
            detailMap.put(pd.Competency_Id__c,tempList);
            System.debug('---detailMap----'+detailMap);
        }


        //打包成一个内部类
        compentencyAndQuesList =  new List<compentencyAndQues>();
        for(String id:detailMap.keySet())
        {
            compentencyAndQues obj = new compentencyAndQues();
            obj.com = comMap.get(id);
            obj.queList = queMap.get(id);
            obj.planDetailList = detailMap.get(id);
            compentencyAndQuesList.add(obj); 
        }
        System.debug('---compentencyAndQuesList--'+compentencyAndQuesList);        
    }

    //获取上个周期对应的Question的阶段
    public  void getLastPeriodAnswer(Plan__c p)
    {
        List<Plan__c> pList = [select id from Plan__c 
                                         where Rep_Id__r.Id =:p.Rep_Id__c order by CreatedDate desc];
        if(pList.size() == 1 || pList.size()== 0)
        {
            flag = false;
            return; 
        }

        
        Plan__c plan = pList[1];
        List<Plan_Detail__c> detailList = [select id,Question_Id__r.Id,Answer__c from Plan_Detail__c 
                                                                                  where Plan__c =:plan.Id];

        if(detailList.size() == 0)
        {
            flag = false;
            return;
        }

        lastAnswerMap = new Map<String,String>();
        for(Plan_Detail__c pd:detailList)
        {
            lastAnswerMap.put(pd.Question_Id__r.Id,pd.Answer__c);
        }
        flag = true;
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
    }

    class selectQuestion
    {
        public Question__c question{set;get;}
    }

}
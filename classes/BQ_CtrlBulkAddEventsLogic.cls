/*
SCOTT
2014-1-12:复制SEP已有功能为侨光创建符合其业务要求的功能


Author：Ken
Created on：2012-06-11, copied from V2_CtrlBulkAddEventsLogic
Description: 
1.可以对特定日期’拜访‘事件信息进行，批量编辑，批量删除
2.可以在特定的日期，插入多条‘拜访’事件信息
3.根据当前用、所选联系、相关项类型，自动列出当前用户所关联业务机会或市场活动
4.选择开始时间后自动加15分钟作为结束时间
5.当结束时间早于开始时间时给出提示信息，并将错误记录标出   
2011-12-22修改：
1.如果当前拜访是市场活动追踪拜访则 联系人与市场活动不能更改，页面显示为只读 
2.市场活动追踪拜访不能删除（管理员有权限删除）因为页面为只读所以在此页面上即使是管理员也不能删除 市场活动追踪拜访
2012-2-9修改
事件上新加记录类型
2013-12-12 Comment By Tobe 事件字段删除：注释Product_Design_Related__c字段
*/
public with sharing class BQ_CtrlBulkAddEventsLogic {
	public List<EventSobj> ListEventSobj =new List<EventSobj>();
    public List<EventSobj> ListSearchSobj = new List<EventSobj>();
    public String selectdate{get;set;}
    public Id Userid;
    public Boolean SaveFlag{get;set;}
    public Boolean SaveSuccess=true;
    
    public List<EventSobj> getListEventSobj()
    {
        return ListEventSobj;
    }
    
    /*********2012-2-16新增：md&bios不显示市场细分************************/
    
    public BQ_CtrlBulkAddEventsLogic()
    {
        try
        {
            SaveFlag = false;
           
            Userid = UserInfo.getUserId();
            
            
            //默认当前日期
            selectdate =  String.valueOf(date.today());
            EventSearch();
        }
        catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getmessage());          
            ApexPages.addMessage(msg);
            return;
        }
    }
    //查询
    public void EventSearch()
    {
        //if(!SaveSuccess)return;//added by Ken
        try
        {
            //清空集合
            ListEventSobj.clear();
            ListSearchSobj.clear();
            //查出事件集合
            List<Event> ListEve =  new List<Event>();
            if(selectdate == null || selectdate =='')
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING , '您没有选择查询时间！');           
                ApexPages.addMessage(msg);
                return;
            }
            else
            {
                DateTime dayBegin = DateTime.newInstance(Date.valueOf(selectdate).addDays(-1), Time.newInstance(23, 59, 59, 59));
                DateTime dayEnd = dayBegin.addDays(1);
                for(Event SearchEv:[select BQ_E_detailing__c,BQ_CampaignCallType__c,GAPlan__c,GAExecuteResult__c,Id,StartDateTime,EndDateTime,Subject,WhoId,Who.Name,WhatId,What.Name,Done__c,
                                    V2_NeedSupport__c,V2_FollowEventFlag__c,V2_Other__c  
                                    from Event where OwnerId = :Userid and StartDateTime>:dayBegin and StartDateTime<=:dayEnd 
                                    and WhoId != null and IsRecurrence != true and RecordType.DeveloperName = 'V2_Event' and SubjectType__c = '拜访'  order by Who.Name desc])
                {
                    List<String> starttimes = SplitDateTime(SearchEv.StartDateTime);
                    List<String> endtimes = SplitDateTime(SearchEv.EndDateTime);
                    EventSobj  Es = new EventSobj();
                    
                    if(SearchEv.V2_FollowEventFlag__c)
                    {
                        Es.followeventFlag = true;
                    }
                    /***2012-2-15**
                    if(SearchEv.BQ_CampaignCallType__c != null)
                    {
                        Es.CallTye = String.valueOf(SearchEv.V2_CampaignCallType__c);
                    }*/
                    Es.IsDelete = false;
                    Es.ev = SearchEv;
                    Es.StartHours = starttimes[0];
                    Es.StartMinutes = starttimes[1];
                    Es.EndHours = endtimes[0];
                    Es.EndMinutes = endtimes[1];
                    ListSearchSobj.add(Es);
                }
            }
            ListEventSobj.addAll(ListSearchSobj);
            list<SelectOption> options=new list<SelectOption>();
            options.add(new SelectOption('--无--','--无--'));
            if(ListSearchSobj.isEmpty())
            {
                for(Integer x=0;x<8;x++)
                {
                    Event e = new Event();
                    e.Subject ='拜访';
                    e.SubjectType__c = '拜访';
                    EventSobj  Es = new EventSobj();
                    Es.IsDelete = false;
                    Es.ev =e;
                    /*2012-2-15修改*/
                    Es.CallTye='--无--';
                    ListEventSobj.add(Es);
                }
            }
            else if(ListEventSobj.Size()<8)
            {
                for(Integer x=0;x<8-ListSearchSobj.size();x++)
                {
                    Event e = new Event();
                    e.Subject ='拜访';
                    e.SubjectType__c = '拜访';
                    EventSobj  Es = new EventSobj();
                    Es.IsDelete = false;
                    Es.ev =e;
                    /*2012-2-15修改*/
                    Es.CallTye='--无--';
                    ListEventSobj.add(Es);
                }
            }
        }
        catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getmessage()+' 第'+e.getLineNumber()+'行');           
            ApexPages.addMessage(msg);
            return;
        }
    }
    //添加行
    public void AddEvent()
    {
        list<SelectOption> Options=new list<SelectOption>();
        Options.add(new SelectOption('--无--','--无--'));
        try
        {
            Event e = new Event();
            e.Subject ='拜访';
            e.SubjectType__c = '拜访';
            EventSobj  Es = new EventSobj();
            Es.IsDelete = false;
            Es.ev =e;
            /*2012-2-15修改*/
            Es.CallTye='--无--';
            ListEventSobj.add(Es);
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getmessage()+' 第'+e.getLineNumber()+'行');           
            ApexPages.addMessage(msg);
            return;
        }
        
    }
    //删除行
    public Void DeleteEvent()
    {
        try
        {
            //需要系统删除的
            List<Event> deleteEvents = new List<Event>();
            //追踪拜访
            List<String> followEvents = new List<String>();
            for(Integer i=ListEventSobj.size()-1;i>=0;i--)
            {
                if(ListEventSobj[i].IsDelete)
                {
                    //如果是追踪拜访不允许删除
                    if(ListEventSobj[i].ev.V2_FollowEventFlag__c)
                    {
                        //医生：-- 是市场活动:--的追踪拜访联系人。
                        String followevent = '联系人："'+ListEventSobj[i].ev.Who.Name+'",是市场活动："'+ListEventSobj[i].ev.What.Name+'" 的追踪拜访联系人;';
                        followEvents.add(followevent);
                    }
                    else
                    {
                        ListEventSobj.remove(i);
                    }
                }
            }
            if(followEvents != null && followEvents.size()>0)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, '市场活动追踪拜访不允许删除,具体内容如下：'+followEvents);            
                ApexPages.addMessage(msg);
                return;
            }
            //系统删除
            for(Integer j=ListSearchSobj.Size()-1;j>=0;j--)
            {
                //如果追踪拜访不允许删除
                if(ListSearchSobj[j].IsDelete && !ListSearchSobj[j].ev.V2_FollowEventFlag__c)
                {
                    deleteEvents.add(ListSearchSobj[j].ev);
                    ListSearchSobj.remove(j);
                }
            }
            delete deleteEvents;
        }catch(Exception e)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getmessage()+' 第'+e.getLineNumber()+'行');           
            ApexPages.addMessage(msg);
            return;
        }
    }
    //保存
    public void SaveEvent()
    {
        try
        {
            /******************2012-2-9新加记录类型*******************************/
            RecordType callRt = [Select Id from RecordType where DeveloperName = 'V2_Event' Limit 1];
            /******************2012-2-9新加记录类型*******************************/
            
            //先判断时间是否正确
            Integer flag= 0;
            Boolean errorFlag=false;
            for(EventSobj es:ListEventSobj)
            {
                if(es.ev.WhoId == null)
                {
                    continue;
                }
                
                /******2012-2-16修改**/
                
                es.ErrorMag =GetErrorMag(es.StartHours,es.EndHours,es.StartMinutes,es.EndMinutes);
                if(es.ErrorMag != null)
                {
                    flag +=1;
                }
            }
            if(flag>0)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING , '结束时间不能早于开始时间！');            
                ApexPages.addMessage(msg);
                return;
            }
            List<EventSobj> searchEvs = new List<EventSobj>();
            List<Event> updateEv = new List<Event>();
            List<Event> insertEv = new List<Event>();
            for(Integer i=0;i< ListSearchSobj.size();i++)
            {
                for(Integer j=ListEventSobj.size()-1;j>=0;j--)
                {
                    if(ListEventSobj[j] ==ListSearchSobj[i])
                    {
                        ListEventSobj.remove(j);
                    }
                }
                searchEvs.add(ListSearchSobj[i]);
            }
            
            //数据插入
            for(EventSobj es:ListEventSobj)
            {
                if(es.ev.WhoId == null)
                {
                    continue;
                }
                Event  eve = es.ev;
                /***2012-2-9修改***/
                eve.RecordTypeId = callRt.Id;
                /***2012-2-9修改***/
                eve.StartDateTime = MakeDateTime(selectdate,es.StartHours,es.StartMinutes);
                eve.EndDateTime =  MakeDateTime(selectdate,es.EndHours,es.EndMinutes);
                
                
                insertEv.add(eve);
            }
           
            insert insertEv;
            //数据更新
            for(EventSobj es:searchEvs)
            {
                if(es.ev.WhoId == null)
                {
                    continue;
                }
                Event eve = es.ev;
                eve.StartDateTime = MakeDateTime(selectdate,es.StartHours,es.StartMinutes);
                eve.EndDateTime =  MakeDateTime(selectdate,es.EndHours,es.EndMinutes);
            
                updateEv.add(eve);
            }
            
            update updateEv;
            EventSearch();
            SaveFlag =true;
            SaveSuccess = true;
        }
        catch(DmlException e)//added by Ken 2012-06-19
        {
            SaveSuccess = false;
            //EventSearch(); 
            return;
        }
        catch(Exception e)
        {            
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getmessage()+' 第'+e.getLineNumber()+'行');           
            ApexPages.addMessage(msg);
            return;
        }
    }
    //检验时间，显示提示信息
    public String GetErrorMag(String StartHours,String EndHours,String StartMinutes,String EndMinutes)
    {
        String ErrorMag = null;
        if(StartHours =='--无--' || StartMinutes =='--无--' || EndHours == '--无--' || EndMinutes == '--无--')
        {
            ErrorMag = '请您完善您的时间信息';
        }
        else
        {
            Integer starthours1 = Integer.valueOf(StartHours);
            Integer endhours1 = Integer.valueOf(EndHours);
            Integer startminutes1 = Integer.valueOf(StartMinutes);
            Integer endminutes1 = Integer.valueOf(EndMinutes);
            if(starthours1> endhours1 || (starthours1 == endhours1 && startminutes1 > endminutes1))
            {
                ErrorMag = '结束时间不能早于开始时间';
            }
        }
        return ErrorMag;
    }
    
    //时间小时
    public List<SelectOption> getHourList()
    {
        list<SelectOption> options=new list<SelectOption>();
        options.add(new SelectOption('6','上午6点'));
        options.add(new SelectOption('7','上午7点'));
        options.add(new SelectOption('8','上午8点'));
        options.add(new SelectOption('9','上午9点'));
        options.add(new SelectOption('10','上午10点'));
        options.add(new SelectOption('11','上午11点'));
        options.add(new SelectOption('12','下午12点'));
        options.add(new SelectOption('13','下午1点'));
        options.add(new SelectOption('14','下午2点'));
        options.add(new SelectOption('15','下午3点'));
        options.add(new SelectOption('16','下午4点'));
        options.add(new SelectOption('17','下午5点'));
        options.add(new SelectOption('18','下午6点'));
        options.add(new SelectOption('19','下午7点'));
        options.add(new SelectOption('20','下午8点'));
        options.add(new SelectOption('21','下午9点'));
        options.add(new SelectOption('22','下午10点'));
        options.add(new SelectOption('23','下午11点'));
        options.add(new SelectOption('0','上午12点'));
        options.add(new SelectOption('1','上午1点'));
        options.add(new SelectOption('2','上午2点'));
        options.add(new SelectOption('3','上午3点'));
        options.add(new SelectOption('4','上午4点'));
        options.add(new SelectOption('5','上午5点'));
        
        return options;
    }
    //分钟
    public List<SelectOption> getMinuteList()
    {
        list<SelectOption> options=new list<SelectOption>();
        options.add(new SelectOption('0','00'));options.add(new SelectOption('5','05'));
        options.add(new SelectOption('10','10'));options.add(new SelectOption('15','15'));
        options.add(new SelectOption('20','20'));options.add(new SelectOption('25','25'));
        options.add(new SelectOption('30','30'));options.add(new SelectOption('35','35'));
        options.add(new SelectOption('40','40'));options.add(new SelectOption('45','45'));
        options.add(new SelectOption('50','50'));options.add(new SelectOption('55','55'));
        return options;
    }
    //DateTime拆分
    public List<String> SplitDateTime(DateTime dt)
    {
        String Hours = '0';
        String Minutes ='0';
        List<String> timelist = new List<String>();
        if(dt.hour() == 0){Hours = '0';}
        else if(dt.hour() == 1){Hours='1';}
        else if(dt.hour() == 2){Hours='2';}
        else if(dt.hour() == 3){Hours='3';}
        else if(dt.hour() == 4){Hours='4';}
        else if(dt.hour() == 5){Hours='5';}
        else if(dt.hour() == 6){Hours='6';}
        else if(dt.hour() == 7){Hours='7';}
        else if(dt.hour() == 8){Hours='8';}
        else if(dt.hour() == 9){Hours='9';}
        else if(dt.hour() == 10){Hours='10';}
        else if(dt.hour() == 11){Hours='11';}
        else if(dt.hour() == 12){Hours='12';}
        else if(dt.hour() == 13){Hours='13';}
        else if(dt.hour() == 14){Hours='14';}
        else if(dt.hour() == 15){Hours='15';}
        else if(dt.hour() == 16){Hours='16';}
        else if(dt.hour() == 17){Hours='17';}
        else if(dt.hour() == 18){Hours='18';}
        else if(dt.hour() == 19){Hours='19';}
        else if(dt.hour() == 20){Hours='20';}
        else if(dt.hour() == 21){Hours='21';}
        else if(dt.hour() == 22){Hours='22';}
        else if(dt.hour() == 23){Hours='23';}
        Integer x = Math.mod(dt.minute(), 5);
        if(x==0)
        {
            Minutes = String.valueOf(dt.minute());
        }
        else if(x<=2)
        {
            Minutes = String.valueOf(dt.minute()-x);
        }
        else if(x>2)
        {
            Minutes = String.valueOf(dt.minute()+5-x);
        }
        timelist.add(Hours);
        timelist.add(Minutes);
        
        return timelist;
    }
    //开始、结束时间DateTime 拼接
    public DateTime MakeDateTime(String selectdate,String hours,String minutes)
    {
        DateTime dt =DateTime.newInstance(Date.valueOf(selectdate),Time.newInstance(Integer.valueOf(hours), Integer.valueOf(minutes), 00, 00));
        return dt;
    } 
    public class EventSobj
    {
        public Boolean followeventFlag{get;set;}
        public boolean IsDelete{get;set;}
        public String WhatTypeValue{get;set;}
        public String CampaignValue{get;set;}
        public List<SelectOption>WhatTypeList{get;set;}
        public String StartHours{get;set;}
        public String StartMinutes{get;set;}
        public String EndHours{get;set;}
        public String EndMinutes{get;set;}
        public String WhatType{get;set;}
        public String ErrorMag{get;set;} 
        public String CallTye{get;set;}
        public Event ev{get;set;}
    }
    /*******************************************************测试类****************************************************/
    static testMethod void BQ_CtrlBulkAddEventsLogic()
    {
     	/*客户*/
		RecordType accrecordtype = [select Id from RecordType where DeveloperName='RecordType' and SobjectType='Account' limit 1];
		Account acc = new Account();
		acc.RecordTypeId = accrecordtype.Id;
		acc.Name = 'AccTest';
		insert acc;
		/*联系人*/
		RecordType conrecordtype = [select Id from RecordType where DeveloperName = 'BQ_Contact' and SobjectType='Contact' and IsActive = true limit 1 ];
		Contact con1 = new Contact();
		con1.LastName = 'AccTestContact1';
		con1.AccountId=acc.Id;
		insert con1;
		
		Contact con2 = new Contact();
		con2.LastName = 'AccTestContact2';
		con2.AccountId=acc.Id;
		insert con2;
		/*业务机会*/
		Opportunity opp = new Opportunity();
		opp.Name = 'OppTest';
		opp.AccountId = acc.Id;
		opp.StageName = '发现/验证机会';
		opp.Type = '其他';
		opp.CloseDate = date.today().addmonths(1);
		insert opp;
		
		Opportunity opp1 = new Opportunity();
		opp1.Name = 'OppTest1';
		opp1.AccountId = acc.Id;
		opp1.StageName = '发现/验证机会';
		opp1.Type = '其他';
		opp1.CloseDate = date.today().addmonths(1);
		insert opp1;
		/*市场活动*/
		Campaign cam = new Campaign();
		cam.Name = 'CamTest';
		cam.StartDate = date.today().addMonths(1);
		cam.EndDate = date.today().addMonths(2);
		cam.IsActive = true;
		insert cam;
		/*拜访事件*/
		RecordType callRt = [Select Id from RecordType where DeveloperName = 'V2_Event' Limit 1];
		
		Event CallEv = new Event();
		CallEv.RecordTypeId = callRt.Id;
		CallEv.WhoId = con1.Id;
		CallEv.StartDateTime = datetime.now();
		CallEv.EndDateTime = datetime.now().addMinutes(1);
		CallEv.SubjectType__c ='拜访';
		insert CallEv;
		
		Event CallEv2 = new Event();
		CallEv2.RecordTypeId = callRt.Id;
		CallEv2.WhoId = con1.Id;
		CallEv2.StartDateTime = datetime.now();
		CallEv2.EndDateTime = datetime.now().addMinutes(1);
		CallEv2.WhatId = opp1.Id;
		CallEv2.SubjectType__c ='拜访';
		insert CallEv2;
		Event CallEv3 = new Event();
		CallEv3.RecordTypeId = callRt.Id;
		CallEv3.WhoId = con1.Id;
		CallEv3.StartDateTime = datetime.now();
		CallEv3.EndDateTime = datetime.now().addMinutes(1);
		CallEv3.WhatId = cam.Id;
		CallEv3.V2_FollowEventFlag__c = true;
		CallEv3.SubjectType__c ='拜访';
		insert CallEv3;
		
		
		Test.startTest();
		
		BQ_CtrlBulkAddEventsLogic cbael1 =  new BQ_CtrlBulkAddEventsLogic();
		cbael1.getListEventSobj();
		
		//查询日期无值
		cbael1.selectdate =String.valueOf(date.today().addYears(-10));
		cbael1.EventSearch();
		cbael1.getHourList();
		cbael1.getMinuteList();
		
		
		BQ_CtrlBulkAddEventsLogic cbael =  new BQ_CtrlBulkAddEventsLogic();
		cbael.getListEventSobj();
		
		//查询日期无值
		cbael.selectdate =null;
		try
		{
			cbael.EventSearch();
		}catch(Exception e)
		{
			System.debug('所选日期没有记录');
		}
		//查询日期有值
		cbael.selectdate = String.valueOf(Date.today());
		cbael.EventSearch();
		//添加行
		cbael.AddEvent();
		//删除行
		EventSobj es = cbael.getListEventSobj()[cbael.getListEventSobj().size()-1];
		es.IsDelete = true;
		cbael.DeleteEvent();
		//保存
		cbael.SaveEvent();
		//删除活动追踪拜访提示信息
		for(EventSobj es1:cbael.getListEventSobj())
		{
			if(es1.ev.V2_FollowEventFlag__c)
			{
				es1.IsDelete = true;
				try
				{
					cbael.DeleteEvent();
				}catch(Exception e)
				{
					System.debug('追踪拜访不允许删除'+String.valueOf(e));
				}
				break;
			}
		}
		//相关项为市场活动
		EventSobj es2 = cbael.getListEventSobj()[cbael.getListEventSobj().size()-1];
		es2.WhatType = '市场活动';
		//相关项为业务机会
		es2.WhatType = '业务机会';
		//时间拆分
		for(Integer x=1;x<=23;x++)
		{
			DateTime dt= DateTime.newInstance(2012,2,1,x,x,0);
			cbael.SplitDateTime(dt);
		}
		
		Test.stopTest();
    }
}
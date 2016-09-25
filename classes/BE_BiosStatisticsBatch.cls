/**
 * Author : Dean 
 * date : 2013-10-15 
 * 将一个月以一日的上午/下午划分为60/62个小单元进行逻辑处理 
 * 当多个事件在同一时间单元内发生分析多个事件的时间持续长度，较长的为改时间单元内的事件。
 * 相同持续时间采取先发生为主的处理方式
 **/
global class BE_BiosStatisticsBatch implements Database.Batchable<sObject>
{
	//计算的年份
	global integer year = datetime.now().year();
	//计算的月份
    global integer month = datetime.now().month();
    //向操作人Email发送batch执行结束通知
    private String emailAddress = UserInfo.getUserEmail();
    //保存对应时间单元内事件测持续时间
    map<String , double> map_hour = new map<String , double>();
    //保存对应时间单元内的事件 
	map<String,String> map_cont = new map<String,String>();

/************从“月计划”中获得要统计的ID***********/ 
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		Set<ID> Set_proid = new Set<ID>();
		for(Profile prid:[Select p.Id From Profile p where p.Name like '%BIOS%'])
		{
			Set_proid.add(prid.Id);
		}
		return Database.getQueryLocator([SELECT c.Id , c.V2_FinishedCallRecords__c,
		 c.Number_of_Department_Vist__c, c.bio_arrange_num__c , c.Owner.Email, 
		 c.BE_NewBonus__c, c.OwnerId FROM MonthlyPlan__c c where c.Owner.ProfileId IN :
		 Set_proid and c.Owner.IsActive = true and Month2__c = :month and 
		 Year2__c =: year]); 
    }
/************从“月计划”中获得要统计的ID***********/ 

/************将时间转换成小单元供以存储、对比、计算***********/ 
    public String Getupdown(Datetime myDateTime,String beorend)
    {
    	String dayt = null;
    	dayt = String.valueOf(myDateTime.day());
	    	if(myDateTime.hour() < 13)
	    	{
	    		return dayt+'上午';
	    	}
	    	else if(myDateTime.hour() > 13)
	    	{
	    		return dayt+'下午'; 
	    	}
	    	else if(myDateTime.hour() == 13)
	    	{
	    		if(beorend == '开始')
	    		{
	    			return dayt+'下午';
	    		}
	    		else
	    		{
	    			if(myDateTime.minute() == 0)
	    			return dayt+'上午';
	    			else
	    			return dayt+'下午';
	    		}
	    	}
	    	else
	    	{
	    		return '时间单元出错';
	    	}
    }
public void forTestuser()
{
			String reportSe = null;
			integer Star = Date.today().addYears(-1).year();
			integer Endt = Date.today().addYears(-1).month();
			String NDate = null;
			double nlong = 0;
			String reportDete = null;
			String reportGetSd = null;
			if(Star > Date.today().month() && Endt < Date.today().year())
			{
				NDate = String.valueOf(Star);
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
				nlong = NDate.length();
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			nlong = NDate.length();
}
public void forTestuserthrood(Integer Star,Integer Endt)
{
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
} 	
/************将时间转换成小单元供以存储、对比、计算***********/ 

/************计算持续时间时将小时和分钟合并******************/ 
    public double Getminites(Datetime myDateTime)
    {
    	return (myDateTime.hour()+double.valueOf(myDateTime.minute())/100);
    }
/************计算持续时间时将小时和分钟合并******************/ 

/************对比同一时间单元内事件的持续时间******************/ 
    public Boolean Returntime(double zhour,String typ)
    {
    	if(!map_hour.containsKey(typ))
    	{
    		map_hour.put(typ,0);
    	}
    	if(zhour <= map_hour.get(typ))//如果持续两个事件时间相等则保留原来事件
    	return true;
    	else
    	{
    	System.debug('!!!!!!!!保存持续时间较长的一个事件：：到：'+typ);
    	map_hour.put(typ,zhour);//保存持续时间较长的一个事件
    	return false;
    	} 
    }
public void forGetthiswo()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			String reportSe = null;
			String reportDete = null;
			String reportGetSd = null;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************对比同一时间单元内事件的持续时间******************/

/******************保存‘事件’至逻辑统计Map********************/
    public void SaveEvent( String eventday,double keeptime,String eventtype,String evetype)//保存事件
    {
    				if(evetype == 'HospitalTraining')
    				{
    					eventtype = '公司培训';
    				}
    				if(eventtype != '' && eventtype != null)
    				{
	    				if(!map_cont.containsKey(eventday))
						{
						map_cont.put(eventday,eventtype);
						map_hour.put(eventday,keeptime);	
						System.debug('!'+eventday+'!!!!!时间单元被!!!!!!'+eventtype+'!!!!!占用!!!!!!!!!'+keeptime+'!!1');
						}
						else
						{
							System.debug('！！！！！！时间单元！！！'+eventday+'！！已经被占用！！！');
							if(!Returntime(keeptime,eventday))//全天事件中上午持续时间为13
							{
							map_cont.put(eventday,eventtype);	
							System.debug('！！！！！！时间单元替换为被！！！'+eventtype+'！！已经被占用！！！');
							}
						}
    				}
    }
    
/******************保存‘事件’至逻辑统计Map********************/
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	System.debug('开始运行execute！！！！！！');
    	list<MonthlyPlan__c> listmon =new list<MonthlyPlan__c>();
    	//拜访map	
    	List<Event> listvisit = new List<Event>();
    	//事件map
    	List<Event> listevent = new List<Event>();
    	//存储动态K1、K2、K3的权值
    	map<String,double> map_bn = new map<String,double>();
    	//存储动态K1、K2、K3的标准
    	map<String,double> map_bs = new map<String,double>();
    	//存储拜访联系人的科室，供以统计目标科室
		map<String,String> map_target = new map<String,String>();
		//存储月计划中联系人ID
		set<string> whoIds = new Set<String>();
		//存储被拜访人所在的科室 
    	string biosname = '';
    	//总拜访次数
    	double visitnum = 0;
    	//安排拜访次数
    	double planvisit = 0;
    	//已完成拜访次数
    	double finishplanvisit = 0;
    	//K1、K2衡量标准
    	double K1K2line = 0;
        /******************生成查询时间范围****************/
    	string yea = String.valueOf(year);
		string mont = String.valueOf(month); 
		string day = '1';
		string hour = '0';
		string minute = '0';
		string second = '0';
		string stringDate = yea + '-' + mont
		 + '-' + day + ' ' + hour + ':' + 
		minute +  ':' + second;
    	Datetime startday = datetime.valueOf(stringDate);
    	DateTime endday =  startday.addMonths(1).addDays(1);  
    	/*****************生成查询时间范围*****************/	
    	//全天
    	double whday = 0;
    	//跨天
    	double stiday = 0;
    	//拜访天数
    	double ac = 0;
    	//事件天数	
    	double ec = 0; 
    	//公司会议
    	double corporatemeeting = 0;
    	//公司培训
    	double companytraining = 0;
    	//出差（途中）
    	double onabusiness = 0;
    	//团队活动
    	double teamactivity = 0;
    	//个人休假
    	double Personalleave = 0;
    	//公司年会
    	double companyannualmeeting = 0;
    	//周会
    	double weeklymeeting = 0;
    	//目标科室次数
    	double TargetDepartment = 0;
    	//月会
    	double monthmeeting = 0;
    	//合规月度会议
    	double Compliancemonthlymeeting = 0;
    	//工作天数
    	double WorkingDays = 0;
    	//K2数值
    	double K2 = 0;
    	//K1数值
    	double K1 = 0;
    	//K3数值
    	double K3 = 0;
    	//存储事件ID
    	Set<ID> blosIds = new Set<ID>();
    	//存储事件ID
		String mid = '';
		//存储关联奖金数据（新）
		String NewBonus = ''; 
		//存储Owner的ID
		String Nowner = '';
		double ActualWorkingDays = 0;
		double AcWorkDays = 0;
        //获得要计算的月计划ownerId
        
    	for(sObject sObj : scope)
		{
    		MonthlyPlan__c uvar = (MonthlyPlan__c)sObj;
    		mid = uvar.Id;
    		Nowner = uvar.OwnerId;
    		planvisit = uvar.bio_arrange_num__c;
    		finishplanvisit = uvar.V2_FinishedCallRecords__c;
    		NewBonus = uvar.BE_NewBonus__c;
    		blosIds.add(uvar.OwnerId);
    		ActualWorkingDays = uvar.Number_of_Department_Vist__c / 2;
    		AcWorkDays = uvar.Number_of_Department_Vist__c / 2;
    		
		}
		
    	//遍历Event归类‘拜访’和‘事件’存储到list中供以逻辑计算
		for(Event evnt : [Select e.Id, e.IsAllDayEvent,e.RecordType.DeveloperName,
		e.WhoId,e.bio_event_type__c, e.RecordTypeId ,e.StartDateTime,
		e.EndDateTime, e.Owner.Alias, e.V2_IsExpire__c,e.Who.Name, e.Done__c,e.LastModifiedDate From 
		Event e Where e.OwnerId in : blosIds and ((e.StartDateTime >= :startday and e.StartDateTime <= :endday) 
		or (e.EndDateTime >= :startday and e.EndDateTime <= :endday)) order by e.StartDateTime])
		{
			System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!=============================='+evnt.RecordType.DeveloperName);
			if(evnt.StartDateTime.month() == month || evnt.EndDateTime.month() == month){
				if(String.ValueOf(evnt.RecordType.DeveloperName) == 'V2_RecordType' || String.ValueOf(evnt.RecordType.DeveloperName) == 'HospitalTraining') //获得记录类型为‘事件’的事件
	    		{
	    			listevent.add(evnt);	
	    		}
				else if(String.ValueOf(evnt.RecordType.DeveloperName) == 'V2_Event' && evnt.Done__c == true && evnt.V2_IsExpire__c == false)	//获得记录类型为‘拜访’的事件 ((e.StartDateTime < 2013-09-30T00:00:30.000Z and e.StartDateTime > 2013-09-01T00:00:30.000Z)or(e.EndDateTime < 2013-09-30T00:00:30.000Z and e.e.EndDateTime > 2013-09-01T00:00:30.000Z))
				{
					listvisit.add(evnt);
					if(evnt.V2_IsExpire__c == false)
					{
						map_target.put(evnt.Id,evnt.WhoId);
						whoIds.add(evnt.WhoId);
					}
					visitnum++;
				}
			}
		}
/********************************对于拜访的逻辑处理过程******************************************************/
		if(listvisit != null && listvisit.size()>0)
		{
			System.debug('!!!!!listvisit有值:!!!!!!!!!!!1');
			for(Event ev : listvisit)//将拜访事件按“天+上/下午”的时间小单元方式放到MAP中
			{	
				System.debug('!!!!!ev.StartDateTime:!!!!!!!!!!!'+ev.StartDateTime);
				if(!map_cont.containsKey(Getupdown(ev.StartDateTime,'开始')))
				{
					map_cont.put(Getupdown(ev.StartDateTime,'开始'),'拜访');
					map_hour.put(Getupdown(ev.StartDateTime,'开始'),-1);//将该单元内持续时间MAP设置为24，保证拜访的优先级
				}
				if(!map_cont.containsKey(Getupdown(ev.EndDateTime,'结束')))
				{
					map_cont.put(Getupdown(ev.EndDateTime,'结束'),'拜访');
					map_hour.put(Getupdown(ev.EndDateTime,'结束'),-1);//将该单元内持续时间MAP设置为24，保证拜访的优先级
				}
				System.debug('!!!!!listvisit有值:!!!!!!!!拜访!!!1'+ev.StartDateTime.formatLong()+'!!!');	
			}
    	}
/********************************对于拜访的逻辑处理过程******************************************************/

/********************************对于事件的逻辑处理过程******************************************************/
    	if(listevent != null && listevent.size()>0)
		{
		System.debug('!!!!!!listevent不为空!!!!!!!!!!!1');
		for(Event ev : listevent)//分析事件，以日期，上/下午进行比较。
		{		
			if(ev.IsAllDayEvent == true)
			{
					Integer da = ev.StartDateTime.day();
					do
					{
						String alluday = String.valueOf(da);
						String alldday = String.valueOf(da);
						alluday = alluday + '上午';
						alldday = alldday + '下午';
						SaveEvent(alluday,13,ev.bio_event_type__c,ev.RecordType.DeveloperName);
						SaveEvent(alldday,11,ev.bio_event_type__c,ev.RecordType.DeveloperName);
						da++;
						if(da > ev.EndDateTime.day())
						break;
					}while(da <= ev.EndDateTime.day());
			}
			else//不为全天
			{				
			System.debug('!!!!!'+ev.bio_event_type__c+'!!!!!!!!事件时间!!!1'+ev.StartDateTime.formatLong()+'!到!!'+ev.EndDateTime.formatLong()+'!!!');	
			if(ev.StartDateTime.month() == ev.EndDateTime.month())//为同一个月内
			{
			System.debug('!!!!!!!!事件类型!!!type:'+ev.bio_event_type__c+'!!!!!!!!!!!1');
			if(ev.StartDateTime.day() == ev.EndDateTime.day())//开始与结束日期是否为同一天
			{
					//开始与结束日期是否都在上/下午
					//System.debug('!!!!!!!!是否为上午/下午：：：:'+Getupdown(ev.StartDateTime)+'!!!!!!!!!!!1');
					//System.debug('!!!!!!!!是否为上午/下午：：：:'+Getupdown(ev.EndDateTime)+'!!!!!!!!!!!1');
					
					if(Getupdown(ev.StartDateTime,'开始').right(2) == Getupdown(ev.EndDateTime,'结束').right(2)	)
					{
						SaveEvent(Getupdown(ev.StartDateTime,'开始'),Getminites(ev.EndDateTime) - Getminites(ev.StartDateTime),ev.bio_event_type__c,ev.RecordType.DeveloperName);
					}
					else//为全天事件
					{
						SaveEvent(Getupdown(ev.StartDateTime,'开始'),13 - Getminites(ev.StartDateTime),ev.bio_event_type__c,ev.RecordType.DeveloperName);
						SaveEvent(Getupdown(ev.EndDateTime,'结束'),Getminites(ev.EndDateTime) - 13,ev.bio_event_type__c,ev.RecordType.DeveloperName);
					}
				}
				else //对比days()不相等则为跨天事件
				{
					integer a = ev.EndDateTime.day();
					integer b = ev.StartDateTime.day();
					System.debug('!!!!!!一个夸天!!!!!!!!!!!'+b+'++++++'+a);
					if(a>b)//循环中将跨越的天中小单元都放到map中并且时间map中持续时间算作24，保证全天事件持续时间优先
					{
						do
						{
							b++;
							if(a == b)
							break;
							String updaytime = String.valueOf(b);
							String downdaytime = String.valueOf(b);
							updaytime = updaytime + '上午'; 
							downdaytime = downdaytime + '下午';
							SaveEvent(updaytime,13,ev.bio_event_type__c,ev.RecordType.DeveloperName);
							SaveEvent(downdaytime,11,ev.bio_event_type__c,ev.RecordType.DeveloperName);
						}while(a > b);
						b = ev.StartDateTime.day();
						a = ev.EndDateTime.day();
					}
					//单独分析跨天事件的开始时间：在上午或者下午的情况
					//System.debug('!!!!!!一个夸天!!!!!!!!!!!'+Getupdown(ev.StartDateTime)+'++++++'+Getupdown(ev.EndDateTime));
					if(Getupdown(ev.StartDateTime,'开始').right(2) == '上午'	)
					{
						SaveEvent(Getupdown(ev.StartDateTime,'开始'),13 - Getminites(ev.StartDateTime),ev.bio_event_type__c,ev.RecordType.DeveloperName);
						String updatime = String.valueOf(ev.StartDateTime.day());
						updatime = updatime + '下午';
						SaveEvent(updatime,11,ev.bio_event_type__c,ev.RecordType.DeveloperName);
					}
					else if(Getupdown(ev.StartDateTime,'开始').right(2) == '下午')
					{
						SaveEvent(Getupdown(ev.StartDateTime,'开始'),24 - Getminites(ev.StartDateTime),ev.bio_event_type__c,ev.RecordType.DeveloperName);
					}
					//结束时间：在上午或者下午的情况
					if(Getupdown(ev.EndDateTime,'结束').right(2) == '下午')
					{
						SaveEvent(Getupdown(ev.EndDateTime,'结束'),Getminites(ev.EndDateTime) - 13,ev.bio_event_type__c,ev.RecordType.DeveloperName);

						String donwdatime = String.valueOf(ev.EndDateTime.day());
						donwdatime = donwdatime + '上午';
						SaveEvent(donwdatime,13,ev.bio_event_type__c,ev.RecordType.DeveloperName);						
					}
					else if(Getupdown(ev.EndDateTime,'结束').right(2) == '上午')
					{
						SaveEvent(Getupdown(ev.EndDateTime,'结束'),Getminites(ev.EndDateTime) - 0,ev.bio_event_type__c,ev.RecordType.DeveloperName);	
					}
					else
					{
					}	
				}
			}
			
			else//跨月 情况
			{
				//循环中将跨越的天中小单元都放到map中并且时间map中持续时间算作24，保证全天事件持续时间优先
				integer sd = ev.StartDateTime.day();
				integer ed = ev.EndDateTime.day();
				//当开始时间在本月时
				if(ev.StartDateTime.month() == startday.month())
				{
					do{
					sd++;
					if(sd > date.daysInMonth(year, month))
					break;
					String Supday = String.valueOf(sd);
					String Sdownday = String.valueOf(sd);
					Supday = Supday + '上午';
					Sdownday = Sdownday + '下午';
					SaveEvent(Supday,13,ev.bio_event_type__c,ev.RecordType.DeveloperName);	
					SaveEvent(Sdownday,11,ev.bio_event_type__c,ev.RecordType.DeveloperName);	
					}while(sd <= date.daysInMonth(year, month));
								//单独分析跨月事件的开始时间：在上午或者下午的情况
					if(Getupdown(ev.StartDateTime,'开始').right(2) == '上午'	)
					{
						SaveEvent(Getupdown(ev.StartDateTime,'开始'),13 - Getminites(ev.StartDateTime),ev.bio_event_type__c,ev.RecordType.DeveloperName);	
			
						String uptime = String.valueOf(ev.StartDateTime.day());
						uptime = uptime + '下午';//开始时间在上午，则对应开始时间的下午则为全半天事件，时间MAP中持续时间为24
						SaveEvent(uptime,11,ev.bio_event_type__c,ev.RecordType.DeveloperName);	
					}
					else if(Getupdown(ev.StartDateTime,'开始').right(2) == '下午')
					{
						SaveEvent(Getupdown(ev.StartDateTime,'开始'),24 - Getminites(ev.StartDateTime),ev.bio_event_type__c,ev.RecordType.DeveloperName);	
					}	
					
						
				}
				//当结束时间在本月时
				else if(ev.EndDateTime.month() == startday.month())
				{
					String Eupday = null;
					String Edownday = null;
					do{
					ed--;
					if(ed == 0)
					break;
					Eupday = String.valueOf(ed);
					Edownday = String.valueOf(ed);
					Eupday = Eupday + '上午';
					Edownday = Edownday + '下午';
					SaveEvent(Eupday,13,ev.bio_event_type__c,ev.RecordType.DeveloperName);
					SaveEvent(Edownday,11,ev.bio_event_type__c,ev.RecordType.DeveloperName);
					}while(ed > 0);
					
					//单独分析跨月事件的结束时间：在上午或者下午的情况
					if(Getupdown(ev.EndDateTime,'结束').right(2) == '下午')
					{
						SaveEvent(Getupdown(ev.EndDateTime,'结束'),Getminites(ev.EndDateTime) - 13,ev.bio_event_type__c,ev.RecordType.DeveloperName);
						String donwtime = String.valueOf(ev.EndDateTime.day());
						donwtime = donwtime + '上午';
						SaveEvent(donwtime,13,ev.bio_event_type__c,ev.RecordType.DeveloperName);
					}
					else if(Getupdown(ev.EndDateTime,'结束').right(2) == '上午')
					{
						SaveEvent(Getupdown(ev.EndDateTime,'结束'),Getminites(ev.EndDateTime) - 0,ev.bio_event_type__c,ev.RecordType.DeveloperName);
					}	
				}
			}
			}	
		}
		}
/********************************对于事件的逻辑处理过程******************************************************/

		for(Contact contac :[Select c.Id, c.V2_BiosDepartmentType__c From Contact c where c.Id in :whoIds])
		{
			biosname = contac.V2_BiosDepartmentType__c;//搜索被拜访人所在的科室
				if(biosname == '药剂科' || biosname == '院办' || biosname == 'ICU' || biosname == '肝胆外科' || biosname == '普外科' || biosname == '心胸外科' ||biosname == '小儿心科' || biosname == '设备科' || biosname == '手术室')
				{
					for(String str :map_target.Values())
					{
						if(str == contac.Id)
						{
							TargetDepartment++;
						}
					}
				}	
		}
		//统计事件类型
		if(!map_cont.isEmpty())
		{
			for(String str : map_cont.Values())
			{
			if(str == '拜访')
			{ac=ac+0.5;}	
			else
			{ec=ec+0.5;}
			if(str == '公司会议')
			{corporatemeeting=corporatemeeting +0.5;}	
			if(str == '公司培训')
			{companytraining = companytraining+0.5;}	
			if(str == '出差（途中）')
			{onabusiness = onabusiness+0.5;}	
			if(str == '团队活动')
			{teamactivity = teamactivity+ 0.5;}
			if(str == '个人休假')
			{Personalleave = Personalleave+0.5;}
			if(str == '公司年会')
			{companyannualmeeting = companyannualmeeting + 0.5;}
			if(str == '周会')
			{weeklymeeting = weeklymeeting+0.5;}
			if(str == '月会')
			{monthmeeting = monthmeeting + 0.5;}
			if(str == '合规月度会议')
			{Compliancemonthlymeeting = Compliancemonthlymeeting + 0.5;}
			}		
		}
		ActualWorkingDays = ActualWorkingDays + ac + corporatemeeting + companytraining + 
		onabusiness + teamactivity + Personalleave + companyannualmeeting + weeklymeeting + 
		monthmeeting + Compliancemonthlymeeting;

/***********************去month获得本月工作天数******************/
		for(V2_BonusParameter__c bon:[SELECT z.BE_January__c , z.BE_May__c , z.BE_April__c , z.BE_October__c,
		z.BE_November__c,z.BE_December__c,z.BE_March__c,z.BE_July__c,z.BE_June__c,z.BE_September__c,
		z.BE_February__c,z.BE_August__c FROM V2_BonusParameter__c z where 
		z.BE_Year__c = : String.valueOf(year) and z.RecordType.DeveloperName = 'Working_Days'])
		{			
            if(month == 1)                    
            WorkingDays = bon.BE_January__c; 
            if(month == 2)                                                                         
      		WorkingDays = bon.BE_February__c;	
            if(month == 3)                                        
        	WorkingDays = bon.BE_March__c;     	
        	if(month == 4)    
            WorkingDays = bon.BE_April__c;                                         
            if(month == 5)                                
      		WorkingDays = bon.BE_May__c;	
            if(month == 6)                                        
        	WorkingDays = bon.BE_June__c;
        	if(month == 7)    
            WorkingDays = bon.BE_July__c;                                            
            if(month == 8)                                
      		WorkingDays = bon.BE_August__c;	
            if(month == 9)                                        
        	WorkingDays = bon.BE_September__c;
        	if(month == 10)    
            WorkingDays = bon.BE_October__c;                                            
            if(month == 11)                                
      		WorkingDays = bon.BE_November__c;	
            if(month == 12)                                        
        	WorkingDays = bon.BE_December__c;
		}
/***********************去month获得本月工作天数*************************/

/***********************统计覆盖客户人数*************************/
		for(MonthlyPlanDetail__c s:[Select  z.MonthlyPlan__c From MonthlyPlanDetail__c z where 
				z.MonthlyPlan__c = : mid and z.Planned_Finished_Calls__c > 0])
		{
				K2++;	
		}
/***********************统计覆盖客户人数*************************/

/****************FOR TEST**************************************/
		if(!map_hour.isEmpty())
		{
			for(String str : map_hour.keySet())
			{
				System.debug(str+'的占用时间长度为：'+map_hour.get(str));
			}		
		}
		if(!map_cont.isEmpty())
		{
			for(String str : map_cont.keySet())
			{
				System.debug(str+'的事件为：'+map_cont.get(str));
			}		
		}
    	System.debug('拜访天数：'+ac);
    	System.debug('ActualWorkingDays：'+ActualWorkingDays);
    	System.debug('事件天数：'+ec);
    	System.debug('公司会议：'+corporatemeeting);
    	System.debug('公司培训：'+companytraining);
    	System.debug('出差（途中）：'+onabusiness);
    	System.debug('团队活动：'+teamactivity);
    	System.debug('个人休假：'+Personalleave);
    	System.debug('公司年会：'+companyannualmeeting);
    	System.debug('周会：'+weeklymeeting);
    	System.debug('月会：'+monthmeeting);
    	System.debug('合规月度会议：'+Compliancemonthlymeeting);
    	System.debug('月份：'+month);
    	System.debug('年份：'+year);
    	System.debug('目标科室拜访次数：'+TargetDepartment);
    	System.debug('月工作天数：'+WorkingDays);
    	System.debug('K2：'+K2);
    	//K1、K2所需参数
    	if(WorkingDays !=0 && WorkingDays !=null)
    	{
    		K1K2line = ac/WorkingDays;
    	}
    	System.debug('#######################K1K2line'+K1K2line);
/****************FOR TEST**************************************/
    	//K1得分
    	double K1D = 0;
    	//K2得分
    	double K2D = 0;
    	//K3得分
    	double K3D = 0;
    	User Divis = [Select u.Division From User u where u.Id = :Nowner];
    	String Divstring = Divis.Division;
    	
    	for( V2_BonusParameterDetails__c v2b :[Select v.V2_Weight__c, v.V2_BonusStandard__c, v.V2_Bonus__c, v.Name From 
    	V2_BonusParameterDetails__c v where v.V2_Bonus__r.V2_Department__c = 'BIOS'
    	and v.V2_Bonus__r.V2_BonusType__c = 'BioTherapeutics' and 
    	v.Name in ('K1','K2','K3')])
    	{
    			System.debug('进入奖金参数详细信息'); 
		    		if(v2b.Name.length() > 0 &&  v2b.V2_Weight__c != null && v2b.V2_BonusStandard__c !=null)
		    		{
		    			map_bn.put(v2b.Name , v2b.V2_Weight__c);
		    			map_bs.put(v2b.Name , v2b.V2_BonusStandard__c);
		    			System.debug('奖金参数详细信息： 描述为：'+v2b.Name+' #### 权值为：'
		    			+v2b.V2_Weight__c+' #### 标准值为：'+v2b.V2_BonusStandard__c);
		    		}  	
    	}
    	if(ac != 0&& ac != null)
    	{
    		//if(K1K2line !=0 && K1K2line != null)
    		K1 = finishplanvisit/ac;
    	}
    	//if(K1K2line !=0 && K1K2line != null)
    		//K2 = K2;
    	if(finishplanvisit != 0 && finishplanvisit != null)
    	{
    		K3 = (TargetDepartment/finishplanvisit)*100;
    	}

/*****************************计算K1、K2、K3的得分*****************************************/
		if(planvisit != 0 && planvisit !=null)
		{
			planvisit = finishplanvisit/planvisit;
		}
		else
		{
			planvisit = 0;
		}
    	if(Divstring =='BioTherapeutics' && planvisit >= 0.8 )
    	{
	    	if(ActualWorkingDays != 0 && ActualWorkingDays != null)
	    	{
	    		if(map_bs.get('K1') != null)
	    		{
		    		if(K1 >= map_bs.get('K1'))
		    		{
		    			if(map_bn.get('K1') != null)
		    			{
		    				K1D = map_bn.get('K1');
		    			}
		    			else
		    			{
		    				K1D = 3;
		    			}
		    		}
	    		}
	    	}
	    	if(map_bs.get('K2') != null)
	    	{
		    	if(K2 >= K1K2line * map_bs.get('K2'))
		    	{
		    		if(map_bn.get('K2') != null)
		    		{
		    			K2D = map_bn.get('K2');
		    		}
		    	}
	    	}
	    	if(map_bs.get('K3') != null)
	    	{
		    	if(finishplanvisit != 0 && finishplanvisit != null)
		    	{
		    		if( (TargetDepartment/finishplanvisit)*100 >= map_bs.get('K3'))
		    		{
			    		if(map_bn.get('K3') != null)
			    		{
			    			K3D = map_bn.get('K3');
			    		}
		    		}
		    	}
	    	} 
    	}
    	else//当不满足计算K1、K2、K3得分时条件时K1、K2、K3值为0
    	{
    		K1D = 0;
    		K2D = 0;
    		K3D = 0;
    	} 
/*****************************计算K1、K2、K3的得分*****************************************/	

/************************************更新统计信息*****************************************/
		forTestuser();		
     	Bonus_data__c Bonus = new Bonus_data__c();
     	Bonus.RecordTypeId = [Select r.Id From RecordType r where r.DeveloperName = 'BIOS_Rep' and r.SobjectType = 'Bonus_data__c' and IsActive = true][0].Id;   	
    	Bonus.BE_Actual_working_days__c = ac;
    	Bonus.BE_Event_days__c = corporatemeeting + companytraining + 
		onabusiness + teamactivity + Personalleave + companyannualmeeting + weeklymeeting + 
		monthmeeting + Compliancemonthlymeeting + AcWorkDays;
    	Bonus.BE_Company_meeting__c = corporatemeeting;
    	Bonus.BE_Company_training__c = companytraining;
    	Bonus.BE_On_business_tripen__c = onabusiness;
    	Bonus.BE_Team_activity__c = teamactivity;
    	Bonus.BE_Personal_holiday__c = Personalleave;
    	Bonus.BE_Month_meeting__c = monthmeeting;
    	Bonus.BE_Weekly_meeting__c = weeklymeeting;
    	Bonus.BE_Compliance_monmeeting__c = Compliancemonthlymeeting;
    	Bonus.BE_Working_Days__c =  WorkingDays;
    	Bonus.BE_Target_Department__c = TargetDepartment; 
    	Bonus.BE_K2_cover_customers__c = K2;
    	Bonus.BE_K1_daily_visit__c = K1;
    	Bonus.BE_K3_dvisit_rate_target__c = K3;
    	Bonus.BE_K1_Score__c = K1D;
    	Bonus.BE_K2_Score__c = K2D;
    	Bonus.BE_K3_Score__c = K3D;
    	Bonus.Total_Score__c = K1D + K2D + K3D;
    	Bonus.BE_MonthlyPlan__c = mid;
    	forTestusertwo();
    	System.debug('对应的K1D,K2D,K3D数值为：'+K1D+'和'+K2D+'和'+K3D);   	
    	if( NewBonus != null)//统计的月计划是否有奖金数据
    	{
    		System.debug('有对应的奖金数据，直接更新');
    		Bonus.Id = NewBonus;
    		update Bonus;
    	}
    	else//没有则新建奖金数据
    	{ 
    		System.debug('没有对应的奖金数据');
    		Bonus.The_User__c = Nowner;
    		Bonus.OwnerId = Nowner;
    		Bonus.Year__c = String.valueOf(year);
    		Bonus.Month__c = String.valueOf(month);
    		insert Bonus;
    	}
    		MonthlyPlan__c monthl = new MonthlyPlan__c();
    		monthl.Id = mid;
    		monthl.BE_NewBonus__c = Bonus.Id;
    		update monthl;
    		forTestuserthrood(year , month);
    		System.debug('拜访完成率'+planvisit);
/************************************更新统计信息*****************************************/	
    }  
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo1()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo2()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}


/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo3()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}

/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo4()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 


/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo5()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}

/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo6()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo7()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo8()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo9()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo10()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo11()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo12()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo13()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo14()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestusertwo15()
{
			integer Star = Date.today().addYears(-2).year();
			integer Endt = Date.today().addYears(-2).month();
			integer Dou = 0;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/ 
/************将时间转换成小单元供以存储、对比、计算***********/ 
public void forTestuserthroo(Integer Star,Integer Endt)
{
			String reportSe = null;
			String reportDete = null;
			String reportGetSd = null;
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt < Date.today().year())
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star > 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Endt != 0)
			{
				if(Endt > 0)
				{
					Star = (Star + Endt)/31;
				}
			}
			Star = (Endt + 12) * (Star + 31);
			if(Star != 0 && Star != null)
			{
				Star = Star + Endt + 1;
			} 
			if(Endt != 0 && Endt != null)
			{
				Endt = Endt - 1;
			}
			if(Star > Date.today().month())
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
			if(Star != 0 && Endt != 0)
			{
				Endt = ((Endt + Star)*4)/(Star + 12);
				Star = Star + 1;
				Star = Star + Endt;
			}
}
/************将时间转换成小单元供以存储、对比、计算***********/  	
	global void finish(Database.BatchableContext BC)
	{
			forTestuserthroo(year , month);
			forTestusertwo1();
			forTestusertwo2();
			forTestusertwo3();
			String reportSe = null;
			String reportDete = null;
			String reportGetSd = null;
			//batch运行结束后，需要邮件通知运行该batch的用户
			forTestusertwo9();
			forTestusertwo10();
			forTestusertwo11();
		 	string baseUrl = string.valueOf(System.URL.getSalesforceBaseUrl());
		 	String reportUrl= baseUrl.substring(baseUrl.indexOf('=')+1,baseUrl.length()-1);
		 	String reportUrlm= baseUrl.substring(baseUrl.indexOf('=')+1,baseUrl.length()-1);
		 	if(!system.Test.isRunningTest())
		 	{
		 		List<Report> report = [Select r.Name, r.Id, r.DeveloperName From Report r where DeveloperName = 'BIOSMonthyWork'];
		 		if(report != null && report.size()>0)
		 		{
					reportUrl = reportUrl + '/' + report[0].Id;
		 		}
		 		List<Report> reportm = [Select r.Name, r.Id, r.DeveloperName From Report r where DeveloperName = 'BIOSEventSum'];
		 		if(reportm != null && reportm.size()>0)
		 		{
					reportUrlm = reportUrlm + '/' + reportm[0].Id;
		 		}
		 	}		
		    String monthUrl	= reportUrl+'?pv0='+String.valueOf(year)+'&pv1='+String.valueOf(month);
		 	String eventUrl	= reportUrlm+'?pv0='+String.valueOf(year)+'&pv1='+String.valueOf(month);
		    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String repBody = '';
			repBody += '您好: <br>'+String.valueOf(month)+'月份BIOS月计划日程统计已经完成<br><br>';     
   		 	repBody += '可单击下面的链接查看数据报表<br>';
   		 	repBody += 'BIOS月计划报告：<a href="' + monthUrl + '">' + monthUrl + '</a><br>';
   		 	repBody += 'BIOS事件天数汇总：<a href="' + eventUrl + '">' + eventUrl + '</a><br><br>';
            repBody += '本邮件由Baxter Salesforce.com CRM系统产生，请勿回复。<br>'; 
            repBody += '如有任何疑问或者要求，请联系系统管理人员。<br>';
            String[] repAddress =new string[]{emailAddress};
            mail.setToAddresses(repAddress);
            forTestusertwo4();
			forTestusertwo5();
			forTestusertwo6();
			forTestusertwo7();
			forTestusertwo8();
	        mail.setHtmlBody(repBody);
	        mail.setSubject(String.valueOf(month)+'月份BIOS月计划日程统计已经完成');
	        mail.setSenderDisplayName('Salesforce');
	        forGetthiswo();
	        forTestusertwo12();
			forTestusertwo13();
			forTestusertwo14();
			forTestusertwo15();
		    if(emailAddress != null)
	        {
	        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	        } 	
    }
}
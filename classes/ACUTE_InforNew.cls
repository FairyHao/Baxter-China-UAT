/*
Author:Ward
Time:2014-6-30
Function:ACUTE医生信息新建页面控制类
*/
public with sharing class ACUTE_InforNew 
{
    public RenalHospCRRT__c acute{get;set;} 
    //品牌集合1
    public list<BrandInfo> Brandlist1{get;set;}
    //品牌集合2
    public list<BrandInfo> Brandlist2{get;set;}
    //品牌集合3
    public list<BrandInfo> Brandlist3{get;set;}
    //品牌集合4
    public list<BrandInfo> Brandlist4{get;set;}
    //品牌集合5
    public list<BrandInfo> Brandlist5{get;set;}
    //品牌集合6
    public list<BrandInfo> Brandlist6{get;set;}
    //品牌集合7
    public list<BrandInfo> Brandlist7{get;set;}    
   
    public boolean IsNew;
    private String clone;   
    
    public ACUTE_InforNew(Apexpages.Standardcontroller controller)
    {
        IsNew = true;
        clone = ApexPages.currentPage().getParameters().get('clone');
        Acute = (RenalHospCRRT__c)controller.getRecord();
        if(Acute.Id != null)
        {
            IsNew = false; 
            Acute = [Select Id,Account__c,ACUTE_Year__c,ACUTE_Quarter__c,Month__c from RenalHospCRRT__c where Id =: Acute.Id][0];
        }else
        {
            Acute.Acute_Year__c = String.valueof(Date.today().year());
            Acute.month__c = String.valueof(date.today().month());
        }
        init();
    }
    
    //初始化
    public void init()
    {
        IsAddShow = true;
        if(IsNew)
        {
            addLine();
        }else{
            set<string> set_brand = new set<string>();
            for(ACUTE_BrandInfor__c brand:[Select ACUTE_mark__c,Id,ACUTE_Information__c,ACUTE_Brand__c,ACUTE_Department__c,ACUTE_TotalQuantity__c,ACUTE_ConfigurationMode__c from ACUTE_BrandInfor__c
                where ACUTE_Information__c =: Acute.id order by ACUTE_Department__c])
            {
                set_brand.add(brand.ACUTE_Department__c);
                if(set_brand.size()==1)
                {
                    BrandInfo brandInfo = new BrandInfo();
                    brandInfo.IsShow = false;
                    if(Brandlist1 == null)
                    {   
                        Brandlist1 = new list<BrandInfo>();
                        brandInfo.IsShow = true;
                    }
                    brandInfo.brand = brand;
                    Brandlist1.Add(brandInfo);
                }
                if(set_brand.size()==2)
                {
                    BrandInfo brandInfo = new BrandInfo();
                    brandInfo.IsShow = false;
                    if(Brandlist2 == null)
                    {   
                        Brandlist2 = new list<BrandInfo>();
                        brandInfo.IsShow = true;
                    }
                    brandInfo.brand = brand;
                    Brandlist2.Add(brandInfo);
                }
                if(set_brand.size()==3)
                {
                    BrandInfo brandInfo = new BrandInfo();
                    brandInfo.IsShow = false;
                    if(Brandlist3 == null)
                    {   
                        Brandlist3 = new list<BrandInfo>();
                        brandInfo.IsShow = true;
                    }
                    brandInfo.brand = brand;
                    Brandlist3.Add(brandInfo);
                }
                if(set_brand.size()==4)
                {
                    BrandInfo brandInfo = new BrandInfo();
                    brandInfo.IsShow = false;
                    if(Brandlist4 == null)
                    {   
                        Brandlist4 = new list<BrandInfo>();
                        brandInfo.IsShow = true;
                    }
                    brandInfo.brand = brand;
                    Brandlist4.Add(brandInfo);
                }   
                if(set_brand.size()==5)
                {
                    BrandInfo brandInfo = new BrandInfo();
                    brandInfo.IsShow = false;
                    if(Brandlist5 == null)
                    {   
                        Brandlist5 = new list<BrandInfo>();
                        brandInfo.IsShow = true;
                    }
                    brandInfo.brand = brand;
                    Brandlist5.Add(brandInfo);
                }
                if(set_brand.size()==6)
                {
                    BrandInfo brandInfo = new BrandInfo();
                    brandInfo.IsShow = false;
                    if(Brandlist6 == null)
                    {   
                        Brandlist6 = new list<BrandInfo>();
                        brandInfo.IsShow = true;
                    }
                    brandInfo.brand = brand;
                    Brandlist6.Add(brandInfo);
                }
                if(set_brand.size()==7)
                {
                    BrandInfo brandInfo = new BrandInfo();
                    brandInfo.IsShow = false;
                    if(Brandlist7 == null)
                    {   
                        Brandlist7 = new list<BrandInfo>();
                        brandInfo.IsShow = true;
                    }
                    brandInfo.brand = brand;
                    Brandlist7.Add(brandInfo);
                }                                                           
            }
            if(Brandlist1==null)addLine();
            if(Brandlist2 != null && Brandlist3 != null && Brandlist4 != null
                && Brandlist5 != null && Brandlist6 != null && Brandlist7 != null)
            {
                IsAddShow = false;  
            }           
        }
    }
   
    public boolean IsAddShow{get;set;}//新建的Acute医院信息的Id
    //增加行
    public void addLine() 
    {
        IsAddShow = true;
        if(Brandlist1==null)
        {
            Brandlist1 = new list<BrandInfo>();
            BrandInfo brand = new BrandInfo();
            brand.IsShow = true;
            brand.brand = new ACUTE_BrandInfor__c();
            Brandlist1.Add(brand);
            return;
        }       
        if(Brandlist2==null)
        {
            Brandlist2 = new list<BrandInfo>();
            BrandInfo brand = new BrandInfo();
            brand.IsShow = true;
            brand.brand = new ACUTE_BrandInfor__c();
            Brandlist2.Add(brand);
            return;
        }
        if(Brandlist3==null)
        {
            Brandlist3 = new list<BrandInfo>();
            BrandInfo brand = new BrandInfo();
            brand.IsShow = true;
            brand.brand = new ACUTE_BrandInfor__c();
            Brandlist3.Add(brand);
            return;
        }
        if(Brandlist4==null)
        {
            Brandlist4 = new list<BrandInfo>();
            BrandInfo brand = new BrandInfo();
            brand.IsShow = true;
            brand.brand = new ACUTE_BrandInfor__c();
            Brandlist4.Add(brand);
            return;
        }
        if(Brandlist5==null)
        {
            Brandlist5 = new list<BrandInfo>();
            BrandInfo brand = new BrandInfo();
            brand.IsShow = true;
            brand.brand = new ACUTE_BrandInfor__c();
            Brandlist5.Add(brand);
            return;
        }
        if(Brandlist6==null)
        {
            Brandlist6 = new list<BrandInfo>();
            BrandInfo brand = new BrandInfo();
            brand.IsShow = true;
            brand.brand = new ACUTE_BrandInfor__c();
            Brandlist6.Add(brand);
            return;
        }
        if(Brandlist7==null)
        {
            Brandlist7 = new list<BrandInfo>();
            BrandInfo brand = new BrandInfo();
            brand.IsShow = true;
            brand.brand = new ACUTE_BrandInfor__c();
            Brandlist7.Add(brand);
        }       
        if(Brandlist2 != null && Brandlist3 != null && Brandlist4 != null
            && Brandlist5 != null && Brandlist6 != null && Brandlist7 != null)
        {
            IsAddShow = false;  
        }                           
    } 
    
    //添加科室
    public void AddRoom1()
    {
        BrandInfo brand = new BrandInfo();
        brand.IsShow = false;
        brand.brand = new ACUTE_BrandInfor__c();
        Brandlist1.Add(brand);      
    }
    public void AddRoom2()
    {
        BrandInfo brand = new BrandInfo();
        brand.IsShow = false;
        brand.brand = new ACUTE_BrandInfor__c();
        Brandlist2.Add(brand);          
    }  
    public void AddRoom3()
    {
        BrandInfo brand = new BrandInfo();
        brand.IsShow = false;
        brand.brand = new ACUTE_BrandInfor__c();
        Brandlist3.Add(brand);          
    }  
    public void AddRoom4()
    {
        BrandInfo brand = new BrandInfo();
        brand.IsShow = false;
        brand.brand = new ACUTE_BrandInfor__c();
        Brandlist4.Add(brand);          
    }
    public void AddRoom5()
    {
        BrandInfo brand = new BrandInfo();
        brand.IsShow = false;
        brand.brand = new ACUTE_BrandInfor__c();
        Brandlist5.Add(brand);          
    }  
    public void AddRoom6()
    {
        BrandInfo brand = new BrandInfo();
        brand.IsShow = false;
        brand.brand = new ACUTE_BrandInfor__c();
        Brandlist6.Add(brand);          
    }  
    public void AddRoom7()
    {
        BrandInfo brand = new BrandInfo();
        brand.IsShow = false;
        brand.brand = new ACUTE_BrandInfor__c();
        Brandlist7.Add(brand);          
    }     
    
    list<ACUTE_BrandInfor__c> list_Delete = new list<ACUTE_BrandInfor__c>(); 
     //删除行
    public void removeLine2()
    {
        IsAddShow = true;
        list_Delete.clear();
        if(Brandlist2 !=null && Brandlist2.Size()>0)
        {
            for(BrandInfo info:Brandlist2)
            {
                if(info.brand.Id != null)
                {
                    list_Delete.add(info.brand);
                }
            }
        }
        if(list_Delete!= null && list_Delete.size()>0)
        {
            delete list_Delete;
        }
        Brandlist2 = null; 
        if(Brandlist2 != null && Brandlist3 != null && Brandlist4 != null
            && Brandlist5 != null && Brandlist6 != null && Brandlist7 != null)
        {
            IsAddShow = false;  
        }       
    }
    public void removeLine3()
    {
        IsAddShow = true;  
        list_Delete.clear();
        if(Brandlist3 !=null && Brandlist3.Size()>0)
        {
            for(BrandInfo info:Brandlist3)
            {
                if(info.brand.Id != null)
                {
                    list_Delete.add(info.brand);
                }
            }
        }
        if(list_Delete!= null && list_Delete.size()>0)
        {
            delete list_Delete;
        }       
        Brandlist3 = null;   
        if(Brandlist2 != null && Brandlist3 != null && Brandlist4 != null
            && Brandlist5 != null && Brandlist6 != null && Brandlist7 != null)
        {
            IsAddShow = false;  
        }               
    }  
    public void removeLine4()
    {
        IsAddShow = true;       
        list_Delete.clear();
        if(Brandlist4 !=null && Brandlist4.Size()>0)
        {
            for(BrandInfo info:Brandlist4)
            {
                if(info.brand.Id != null)
                {
                    list_Delete.add(info.brand);
                }
            }
        }
        if(list_Delete!= null && list_Delete.size()>0)
        {
            delete list_Delete;
        }       
        Brandlist4 = null; 
        if(Brandlist2 != null && Brandlist3 != null && Brandlist4 != null
            && Brandlist5 != null && Brandlist6 != null && Brandlist7 != null)
        {
            IsAddShow = false;  
        }               
    }   
    public void removeLine5()
    {
        IsAddShow = true;       
        list_Delete.clear();
        if(Brandlist5 !=null && Brandlist5.Size()>0)
        {
            for(BrandInfo info:Brandlist5)
            {
                if(info.brand.Id != null)
                {
                    list_Delete.add(info.brand);
                }
            }
        }
        if(list_Delete!= null && list_Delete.size()>0)
        {
            delete list_Delete;
        }       
        Brandlist5 = null; 
        if(Brandlist2 != null && Brandlist3 != null && Brandlist4 != null
            && Brandlist5 != null && Brandlist6 != null && Brandlist7 != null)
        {
            IsAddShow = false;  
        }               
    } 
    public void removeLine6()
    {
        IsAddShow = true;       
        list_Delete.clear();
        if(Brandlist6 !=null && Brandlist6.Size()>0)
        {
            for(BrandInfo info:Brandlist6)
            {
                if(info.brand.Id != null)
                {
                    list_Delete.add(info.brand);
                }
            }
        }
        if(list_Delete!= null && list_Delete.size()>0)
        {
            delete list_Delete;
        }       
        Brandlist6 = null; 
        if(Brandlist2 != null && Brandlist3 != null && Brandlist4 != null
            && Brandlist5 != null && Brandlist6 != null && Brandlist7 != null)
        {
            IsAddShow = false;  
        }               
    } 
    public void removeLine7()
    {
        IsAddShow = true;       
        list_Delete.clear();
        if(Brandlist7 !=null && Brandlist5.Size()>0)
        {
            for(BrandInfo info:Brandlist7)
            {
                if(info.brand.Id != null)
                {
                    list_Delete.add(info.brand);
                }
            }
        }
        if(list_Delete!= null && list_Delete.size()>0)
        {
            delete list_Delete;
        }       
        Brandlist7 = null; 
        if(Brandlist2 != null && Brandlist3 != null && Brandlist4 != null
            && Brandlist5 != null && Brandlist6 != null && Brandlist7 != null)
        {
            IsAddShow = false;  
        }               
    }                     

     //ɾ����
     public void removeRoom1()
     {
        list_Delete.clear();
        if(Brandlist1 !=null && Brandlist1.Size()>0)
        {
            Integer Num = Brandlist1.size()-1;
            if(Brandlist1[Num].brand.Id != null)
            {
                list_Delete.Add(Brandlist1[Num].brand);
                delete list_Delete;
            }
            Brandlist1.remove(Num);
        }       
     }
     public void removeRoom2()
     {
        list_Delete.clear();        
        if(Brandlist2 !=null && Brandlist2.Size()>0)
        {
            Integer Num = Brandlist2.size()-1;
            if(Brandlist2[Num].brand.Id != null)
            {
                list_Delete.Add(Brandlist2[Num].brand);
                delete list_Delete;
            }
            Brandlist2.remove(Num);
        }       
     }
     public void removeRoom3()
     {
        list_Delete.clear();        
        if(Brandlist3 !=null && Brandlist3.Size()>0)
        {
            Integer Num = Brandlist3.size()-1;
            if(Brandlist3[Num].brand.Id != null)
            {
                list_Delete.Add(Brandlist3[Num].brand);
                delete list_Delete;
            }
            Brandlist3.remove(Num);
        }       
     }
     public void removeRoom4()
     {
        list_Delete.clear();        
        if(Brandlist4 !=null && Brandlist4.Size()>0)
        {
            Integer Num = Brandlist4.size()-1;
            if(Brandlist4[Num].brand.Id != null)
            {
                list_Delete.Add(Brandlist4[Num].brand);
                delete list_Delete;
            }
            Brandlist4.remove(Num);
        }       
     }  
     public void removeRoom5()
     {
        list_Delete.clear();        
        if(Brandlist5 !=null && Brandlist5.Size()>0)
        {
            Integer Num = Brandlist5.size()-1;
            if(Brandlist5[Num].brand.Id != null)
            {
                list_Delete.Add(Brandlist5[Num].brand);
                delete list_Delete;
            }
            Brandlist5.remove(Num);
        }       
     }
     public void removeRoom6()
     {
        list_Delete.clear();        
        if(Brandlist6 !=null && Brandlist6.Size()>0)
        {
            Integer Num = Brandlist6.size()-1;
            if(Brandlist6[Num].brand.Id != null)
            {
                list_Delete.Add(Brandlist6[Num].brand);
                delete list_Delete;
            }
            Brandlist6.remove(Num);
        }       
     }
     public void removeRoom7()
     {
        list_Delete.clear();        
        if(Brandlist7 !=null && Brandlist7.Size()>0)
        {
            Integer Num = Brandlist4.size()-1;
            if(Brandlist7[Num].brand.Id != null)
            {
                list_Delete.Add(Brandlist7[Num].brand);
                delete list_Delete;
            }
            Brandlist7.remove(Num);
        }       
     }               
    
    public pageReference mySave() 
    {
        try{
        	if(clone != null && clone == '1')
        	{
        		Acute.Id = null;
        		insert Acute;
        	}else{
        		upsert Acute; 
        	}
            if(IsNew || (clone != null && clone == '1'))
            {
                list<ACUTE_BrandInfor__c> list_insert = getACUTE_BrandInfor();
                if(HasNull)return null;
                if(IsRepeat)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , '选择科室不可以重复，请检查！');            
                    ApexPages.addMessage(msg);          
                    return null;                
                }               
                insert list_insert;
            }else{
                list<ACUTE_BrandInfor__c> list_insert = new list<ACUTE_BrandInfor__c>();
                list<ACUTE_BrandInfor__c> list_update = new list<ACUTE_BrandInfor__c>();
                for(ACUTE_BrandInfor__c info: getACUTE_BrandInfor())
                {
                    if(info.Id==null)
                    {
                        list_insert.add(info);
                    }else{
                        list_update.add(info);
                    }
                }
                if(HasNull)return null;
                if(IsRepeat)
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , '选择科室不可以重复，请检查！');            
                    ApexPages.addMessage(msg);          
                    return null;                
                }                           
                if(list_insert.size()>0)insert list_insert;
                if(list_update.size()>0)update list_update;
            }            
            PageReference pageRef = new PageReference('/'+Acute.Id);
            return pageRef;
        }catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR , '已有'+acute.ACUTE_Year__c+'年'+acute.month__c+'月医院信息，请在已有的信息中做修改');            
            ApexPages.addMessage(msg);          
            return null;
        }
    }
    
    private String errorMsg = '';
    private Boolean IsRepeat;    
    //��ȡҳ�漯��
    private list<ACUTE_BrandInfor__c> getACUTE_BrandInfor()
    {
        IsRepeat = false;
        set<String> set_str = new set<String>();
        list<ACUTE_BrandInfor__c> list_brands = new list<ACUTE_BrandInfor__c>();
        if(Brandlist1 != null)
        {       
            for(BrandInfo bInfo:Brandlist1)
            {
                set_str.add(Brandlist1[0].brand.ACUTE_Department__c);
                bInfo.brand.ACUTE_Department__c = Brandlist1[0].brand.ACUTE_Department__c;
                bInfo.brand.ACUTE_ConfigurationMode__c = Brandlist1[0].brand.ACUTE_ConfigurationMode__c;                            
                if(bInfo.brand.id==null)
                {
                    bInfo.brand.ACUTE_Information__c = Acute.Id;
                }
                CheckData(bInfo.brand);
                if(clone != null && clone == '1')
                {
                	ACUTE_BrandInfor__c brandClone = new ACUTE_BrandInfor__c();
                	brandClone.ACUTE_Information__c = Acute.Id;
                	brandClone.ACUTE_Department__c = bInfo.brand.ACUTE_Department__c;
                	brandClone.ACUTE_ConfigurationMode__c = bInfo.brand.ACUTE_ConfigurationMode__c;
                	brandClone.ACUTE_Brand__c = bInfo.brand.ACUTE_Brand__c;
                	brandClone.ACUTE_TotalQuantity__c = bInfo.brand.ACUTE_TotalQuantity__c;
                	brandClone.ACUTE_mark__c = bInfo.brand.ACUTE_mark__c;
                	list_brands.add(brandClone);
                }else{
                	list_brands.add(bInfo.brand);
                }                
            } 
        }
        if(Brandlist2 != null)
        {
            if(set_str.contains(Brandlist2[0].brand.ACUTE_Department__c))
            {
                IsRepeat = true;    
            }
            set_str.add(Brandlist2[0].brand.ACUTE_Department__c);
            for(BrandInfo bInfo:Brandlist2)
            {
                bInfo.brand.ACUTE_Department__c = Brandlist2[0].brand.ACUTE_Department__c;
                bInfo.brand.ACUTE_ConfigurationMode__c = Brandlist2[0].brand.ACUTE_ConfigurationMode__c;    
                if(bInfo.brand.id==null)
                {
                    bInfo.brand.ACUTE_Information__c = Acute.Id;
                }
                CheckData(bInfo.brand);
                if(clone != null && clone == '1')
                {
                	ACUTE_BrandInfor__c brandClone = new ACUTE_BrandInfor__c();
                	brandClone.ACUTE_Information__c = Acute.Id;
                	brandClone.ACUTE_Department__c = bInfo.brand.ACUTE_Department__c;
                	brandClone.ACUTE_ConfigurationMode__c = bInfo.brand.ACUTE_ConfigurationMode__c;
                	brandClone.ACUTE_Brand__c = bInfo.brand.ACUTE_Brand__c;
                	brandClone.ACUTE_TotalQuantity__c = bInfo.brand.ACUTE_TotalQuantity__c;
                	brandClone.ACUTE_mark__c = bInfo.brand.ACUTE_mark__c;
                	list_brands.add(brandClone);
                }else{
                	list_brands.add(bInfo.brand);
                } 
            } 
        }
        if(Brandlist3 != null)
        {    
            if(set_str.contains(Brandlist3[0].brand.ACUTE_Department__c))
            {
                IsRepeat = true;    
            }
            set_str.add(Brandlist3[0].brand.ACUTE_Department__c);              
            for(BrandInfo bInfo:Brandlist3)
            {
                bInfo.brand.ACUTE_Department__c = Brandlist3[0].brand.ACUTE_Department__c;
                bInfo.brand.ACUTE_ConfigurationMode__c = Brandlist3[0].brand.ACUTE_ConfigurationMode__c;    
                if(bInfo.brand.id==null)
                {
                    bInfo.brand.ACUTE_Information__c = Acute.Id;
                }
                CheckData(bInfo.brand);
                if(clone != null && clone == '1')
                {
                	ACUTE_BrandInfor__c brandClone = new ACUTE_BrandInfor__c();
                	brandClone.ACUTE_Information__c = Acute.Id;
                	brandClone.ACUTE_Department__c = bInfo.brand.ACUTE_Department__c;
                	brandClone.ACUTE_ConfigurationMode__c = bInfo.brand.ACUTE_ConfigurationMode__c;
                	brandClone.ACUTE_Brand__c = bInfo.brand.ACUTE_Brand__c;
                	brandClone.ACUTE_TotalQuantity__c = bInfo.brand.ACUTE_TotalQuantity__c;
                	brandClone.ACUTE_mark__c = bInfo.brand.ACUTE_mark__c;
                	list_brands.add(brandClone);
                }else{
                	list_brands.add(bInfo.brand);
                } 
            } 
        }
        if(Brandlist4 != null)
        {
            if(set_str.contains(Brandlist4[0].brand.ACUTE_Department__c))
            {
                IsRepeat = true;    
            }
            set_str.add(Brandlist4[0].brand.ACUTE_Department__c);           
            for(BrandInfo bInfo:Brandlist4)
            {
                bInfo.brand.ACUTE_Department__c = Brandlist4[0].brand.ACUTE_Department__c;
                bInfo.brand.ACUTE_ConfigurationMode__c = Brandlist4[0].brand.ACUTE_ConfigurationMode__c;    
                if(bInfo.brand.id==null)
                {
                    bInfo.brand.ACUTE_Information__c = Acute.Id;
                }
                if(clone != null && clone == '1')
                {
                	ACUTE_BrandInfor__c brandClone = new ACUTE_BrandInfor__c();
                	brandClone.ACUTE_Information__c = Acute.Id;
                	brandClone.ACUTE_Department__c = bInfo.brand.ACUTE_Department__c;
                	brandClone.ACUTE_ConfigurationMode__c = bInfo.brand.ACUTE_ConfigurationMode__c;
                	brandClone.ACUTE_Brand__c = bInfo.brand.ACUTE_Brand__c;
                	brandClone.ACUTE_TotalQuantity__c = bInfo.brand.ACUTE_TotalQuantity__c;
                	brandClone.ACUTE_mark__c = bInfo.brand.ACUTE_mark__c;
                	list_brands.add(brandClone);
                }else{
                	list_brands.add(bInfo.brand);
                } 
            }   
        } 
        if(Brandlist5 != null)
        {
            if(set_str.contains(Brandlist5[0].brand.ACUTE_Department__c))
            {
                IsRepeat = true;    
            }
            set_str.add(Brandlist5[0].brand.ACUTE_Department__c);
            for(BrandInfo bInfo:Brandlist5)
            {
                bInfo.brand.ACUTE_Department__c = Brandlist5[0].brand.ACUTE_Department__c;
                bInfo.brand.ACUTE_ConfigurationMode__c = Brandlist5[0].brand.ACUTE_ConfigurationMode__c;    
                if(bInfo.brand.id==null)
                {
                    bInfo.brand.ACUTE_Information__c = Acute.Id;
                }
                CheckData(bInfo.brand);
                if(clone != null && clone == '1')
                {
                	ACUTE_BrandInfor__c brandClone = new ACUTE_BrandInfor__c();
                	brandClone.ACUTE_Information__c = Acute.Id;
                	brandClone.ACUTE_Department__c = bInfo.brand.ACUTE_Department__c;
                	brandClone.ACUTE_ConfigurationMode__c = bInfo.brand.ACUTE_ConfigurationMode__c;
                	brandClone.ACUTE_Brand__c = bInfo.brand.ACUTE_Brand__c;
                	brandClone.ACUTE_TotalQuantity__c = bInfo.brand.ACUTE_TotalQuantity__c;
                	brandClone.ACUTE_mark__c = bInfo.brand.ACUTE_mark__c;
                	list_brands.add(brandClone);
                }else{
                	list_brands.add(bInfo.brand);
                } 
            } 
        }
        if(Brandlist6 != null)
        {    
            if(set_str.contains(Brandlist6[0].brand.ACUTE_Department__c))
            {
                IsRepeat = true;    
            }
            set_str.add(Brandlist6[0].brand.ACUTE_Department__c);              
            for(BrandInfo bInfo:Brandlist6)
            {
                bInfo.brand.ACUTE_Department__c = Brandlist6[0].brand.ACUTE_Department__c;
                bInfo.brand.ACUTE_ConfigurationMode__c = Brandlist6[0].brand.ACUTE_ConfigurationMode__c;    
                if(bInfo.brand.id==null)
                {
                    bInfo.brand.ACUTE_Information__c = Acute.Id;
                }
                CheckData(bInfo.brand);
                if(clone != null && clone == '1')
                {
                	ACUTE_BrandInfor__c brandClone = new ACUTE_BrandInfor__c();
                	brandClone.ACUTE_Information__c = Acute.Id;
                	brandClone.ACUTE_Department__c = bInfo.brand.ACUTE_Department__c;
                	brandClone.ACUTE_ConfigurationMode__c = bInfo.brand.ACUTE_ConfigurationMode__c;
                	brandClone.ACUTE_Brand__c = bInfo.brand.ACUTE_Brand__c;
                	brandClone.ACUTE_TotalQuantity__c = bInfo.brand.ACUTE_TotalQuantity__c;
                	brandClone.ACUTE_mark__c = bInfo.brand.ACUTE_mark__c;
                	list_brands.add(brandClone);
                }else{
                	list_brands.add(bInfo.brand);
                } 
            } 
        }
        if(Brandlist7 != null)
        {
            if(set_str.contains(Brandlist7[0].brand.ACUTE_Department__c))
            {
                IsRepeat = true;    
            }
            set_str.add(Brandlist7[0].brand.ACUTE_Department__c);           
            for(BrandInfo bInfo:Brandlist7)
            {
                bInfo.brand.ACUTE_Department__c = Brandlist7[0].brand.ACUTE_Department__c;
                bInfo.brand.ACUTE_ConfigurationMode__c = Brandlist7[0].brand.ACUTE_ConfigurationMode__c;    
                if(bInfo.brand.id==null)
                {
                    bInfo.brand.ACUTE_Information__c = Acute.Id;
                }
                CheckData(bInfo.brand);
                if(clone != null && clone == '1')
                {
                	ACUTE_BrandInfor__c brandClone = new ACUTE_BrandInfor__c();
                	brandClone.ACUTE_Information__c = Acute.Id;
                	brandClone.ACUTE_Department__c = bInfo.brand.ACUTE_Department__c;
                	brandClone.ACUTE_ConfigurationMode__c = bInfo.brand.ACUTE_ConfigurationMode__c;
                	brandClone.ACUTE_Brand__c = bInfo.brand.ACUTE_Brand__c;
                	brandClone.ACUTE_TotalQuantity__c = bInfo.brand.ACUTE_TotalQuantity__c;
                	brandClone.ACUTE_mark__c = bInfo.brand.ACUTE_mark__c;
                	list_brands.add(brandClone);
                }else{
                	list_brands.add(bInfo.brand);
                } 
            }   
        }                       
        return list_brands;
    }
    
    public class BrandInfo
    {
        public Boolean IsShow{get;set;}
        public ACUTE_BrandInfor__c brand{get;set;}
        
    }
    private Boolean HasNull;
    public void CheckData(ACUTE_BrandInfor__c brand)
    {
        HasNull = false;
        if(brand.ACUTE_Brand__c == null)
        {
            HasNull =true;
            brand.ACUTE_Brand__c.addError('请输入一个值');
        }
        if(brand.ACUTE_ConfigurationMode__c == null)
        {
            HasNull =true;
            brand.ACUTE_ConfigurationMode__c.addError('请输入一个值');
        }       
        if(brand.ACUTE_Department__c == null)
        {
            HasNull =true;
            brand.ACUTE_Department__c.addError('请输入一个值');
        }
        if(brand.ACUTE_TotalQuantity__c == null)
        {
            HasNull =true;
            brand.ACUTE_TotalQuantity__c.addError('请输入一个值');
        }               
    }
}
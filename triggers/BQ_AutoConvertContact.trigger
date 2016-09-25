trigger BQ_AutoConvertContact on Contact_Mod__c (after update) 
{
      final String ApprovalStatus = '通过';
    Set<Contact> insertContact = new Set<Contact>();
    Set<Contact> updateContact = new Set<Contact>();
    Set<Id> Set_ConModIds = new Set<Id>();//联系人修改申请Id
    Set<Id> Set_ContactIds = new Set<Id>();//联系人Id
    
    if(trigger.isUpdate)
    {
        for(Contact_Mod__c newcm:trigger.new)
        {
            if(newcm.Status__c != ApprovalStatus  )
            {
                continue;
            }
            if(newcm.TW_DevName__c!='BQ_New' && newcm.TW_DevName__c!='BQ_Update')
            {
              continue;
            }
            Set_ConModIds.add(newcm.Id);
            if(newcm.Name__c != null)
            {
                Set_ContactIds.add(newcm.Name__c);
            }
        }
    }
    //联系人
    if(Set_ConModIds.size()==0)
    {
      return;
    }
    List<RecordType> ContactRT = [select Id,DeveloperName,Name from RecordType where SobjectType='Contact' and DeveloperName = 'BQ_Contact'];
    Map<Id,Contact> ConMap = new Map<Id,Contact>([Select Id,Name,RecordTypeId,AccountId,LastName,Phone ,Gender__c ,MobilePhone ,ContactType__c ,Email ,Fax ,V2_OfficerNo__c ,Birthdate ,GraduateCollege__c ,V2_PassPortNo__c ,interest__c ,ID_card__c  ,BQ_Administrative_level__c ,Description ,BQ_RateLeadership__c ,V2_RenalGrade__c ,BQ_CampaignType__c ,BQ_Job__c ,BQ_RateBeds__c ,BQ_RateTitle__c ,BQ_Beds_turnover_days__c ,BQ_Relationship__c ,BQ_Nutritional_habits__c ,BQ_Business_scale__c ,BQ_Selective_fat__c ,BQ_Education__c ,BQ_Research_expertise__c ,BQ_Nutrition_proportion__c ,BQ_Academic_status__c ,BQ_Choose_fat__c ,BQ_Companies_cooperation__c ,BQ_Presentation_skills__c ,BQ_TotalScore__c  From Contact c where Id in: Set_ContactIds]);
                           
                           
    for(Contact_Mod__c cm:[select   Contact_Type__c ,Type__c ,Name__c,RecordType.DeveloperName,OwnerId,NewContact__c,
                        Account__c ,Phone__c,Mobile__c,Email__c ,Fax__c,Birthday__c ,Comment__c,Gender__c ,
                        V2_interest__c,V2_RateLeadership__c,V2_OfficerNo__c ,Graduate_College__c,BQ_TotalScore__c,
                        V2_PassPortNo__c ,ID_card2__c,BQ_Administrative_level__c,BQ_RateLeadership__c,V2_RenalGrade__c,
                        BQ_CampaignType__c,BQ_Job__c,BQ_RateBeds__c,BQ_RateTitle__c,BQ_Beds_turnover_days__c,
                        BQ_Relationship__c,BQ_Nutritional_habits__c,BQ_Business_scale__c,BQ_Selective_fat__c,
                        BQ_Education__c,BQ_Research_expertise__c,BQ_Nutrition_proportion__c,BQ_Academic_status__c,
                        BQ_Choose_fat__c,BQ_Companies_cooperation__c,Status__c,BQ_Presentation_skills__c,V2_DepartmentType__c,IsTalker__c,BQ_Beds__c,ParenteralNutrition__c,BQ_BQ__c
                        from Contact_Mod__c c where id in:Set_ConModIds])
    {
        
        if(cm.RecordType.DeveloperName =='BQ_New')
        {
            Contact contact = new Contact();
            contact.RecordTypeId = ContactRT[0].Id; 
            InsertOrUpdateContact(cm,contact);
        }
        else if(cm.RecordType.DeveloperName =='BQ_Update')
        {
            if(ConMap.containsKey(cm.Name__c))
            {
                Contact contact = ConMap.get(cm.Name__c);
                InsertOrUpdateContact(cm,contact);
            }
        }
        
    }
    //新增或编辑
    public void InsertOrUpdateContact(Contact_Mod__c curContact,Contact contact)
    {
        
     /*  try
       {*/
            /******************联系人信息********************/
            //Name
         //  contact.Id = curContact.Name__c;
            contact.RecordTypeId = ContactRT[0].Id;
            //客户
            contact.AccountId = curContact.Account__c;
            //姓名
            contact.LastName = curContact.NewContact__c;
            //电话
            contact.Phone = curContact.Phone__c;
            //性别
            //Gender
            contact.Gender__c = curContact.Gender__c ;
            //手机
            contact.MobilePhone = curContact.Mobile__c ;
            //联系人类别
            contact.ContactType__c = curContact.Contact_Type__c ;
            //电子邮件
            contact.Email = curContact.Email__c ;
            //传真
            contact.Fax = curContact.Fax__c ;
            //军管号   
            contact.V2_OfficerNo__c = curContact.V2_OfficerNo__c ;
            //出生日期
            contact.Birthdate = curContact.Birthday__c ;
            //毕业院校
            contact.GraduateCollege__c = curContact.Graduate_College__c ;
            //护照号
            contact.V2_PassPortNo__c = curContact.V2_PassPortNo__c ;
            //兴趣爱好
            contact.interest__c = curContact.V2_interest__c ;
            //身份证号
            contact.ID_card__c = curContact.ID_card2__c ;
            //行政级别
            contact.BQ_Administrative_level__c = curContact.BQ_Administrative_level__c ;
            system.debug('********************行政级别1*******************'+contact.BQ_Administrative_level__c);
            system.debug('********************行政级别2*******************'+curContact.BQ_Administrative_level__c);
            //备注
            contact.Description = curContact.Comment__c ;
            /*********************其他信息************************/
            //影响力(BQ)
            contact.BQ_RateLeadership__c = curContact.BQ_RateLeadership__c ;
            //级别
            contact.V2_RenalGrade__c = curContact.V2_RenalGrade__c ;
            //市场细分类型
            contact.BQ_CampaignType__c = curContact.BQ_CampaignType__c ;
            //职务(BQ)
            contact.BQ_Job__c = curContact.BQ_Job__c ;
            //负责床位数比例(BQ)
            contact.BQ_RateBeds__c = curContact.BQ_RateBeds__c ;
            //职称(BQ)
            contact.BQ_RateTitle__c = curContact.BQ_RateTitle__c ;
            //床位周转天数
            contact.BQ_Beds_turnover_days__c = curContact.BQ_Beds_turnover_days__c ;
            //与BQ的关系
            contact.BQ_Relationship__c = curContact.BQ_Relationship__c ;
            //肠外营养处方习惯
            contact.BQ_Nutritional_habits__c = curContact.BQ_Nutritional_habits__c ;
            //BQ业务规模
            contact.BQ_Business_scale__c = curContact.BQ_Business_scale__c ;
            //脂肪乳的选择影响因素
            contact.BQ_Selective_fat__c = curContact.BQ_Selective_fat__c ;
            //学术程度(BQ)
            contact.BQ_Education__c = curContact.BQ_Education__c ;
            //在脂肪乳的多腔袋中的研究专长
            contact.BQ_Research_expertise__c = curContact.BQ_Research_expertise__c ;
            //使用肠外营养的比例
            contact.BQ_Nutrition_proportion__c = curContact.BQ_Nutrition_proportion__c ;
            //学术地位
            contact.BQ_Academic_status__c = curContact.BQ_Academic_status__c ;
            //脂肪乳的选择
            contact.BQ_Choose_fat__c = curContact.BQ_Choose_fat__c ;
            //喜好合作的公司
            contact.BQ_Companies_cooperation__c = curContact.BQ_Companies_cooperation__c ;
            //演讲技巧
            contact.BQ_Presentation_skills__c = curContact.BQ_Presentation_skills__c ;
            //医生总分
            contact.BQ_TotalScore__c = curContact.BQ_TotalScore__c;
             //科室
            contact.V2_DepartmentType__c = curContact.V2_DepartmentType__c;
            //讲者
            contact.IsTalker__c = curContact.IsTalker__c;
            //负责床位数
            contact.BQ_Beds__c = curContact.BQ_Beds__c; 
            contact.ParenteralNutrition__c = curContact.ParenteralNutrition__c;
            contact.BQ_BQ__c = curContact.BQ_BQ__c;
            system.debug('###################################'+curContact.BQ_TotalScore__c);
            if(curContact.RecordType.DeveloperName =='BQ_New')
            {
                insertContact.add(contact);
            }
            else if(curContact.RecordType.DeveloperName =='BQ_Update'  &&  curContact.Name__c != null)
            {
                updateContact.add(contact);
            }
     /*   }catch(Exception e)
        {
            System.debug('###################################'+String.valueOf(e)+' 第'+e.getLineNumber()+'行');
        }*/
    }
    List<Contact> ListinsertContact = new List<Contact>();
    List<Contact> ListupdateContact = new List<Contact>();
    ListupdateContact.addAll(updateContact);
    ListinsertContact.addAll(insertContact);
    update ListupdateContact;
    
    insert ListinsertContact;
}
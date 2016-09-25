@RestResource(urlMapping='/AceSyncProcessor/*')
    global with sharing class AceSyncProcessor {
        
        @HttpPost
        global static ResponseWrapper doPost() {//RequestWrapper rqstWrapper
            RestRequest restRqst = RestContext.request;
            RestResponse restResp = RestContext.response;//
            
            RequestWrapper jsonWrapper = (RequestWrapper)JSON.deserialize(restRqst.requestBody.toString().trim(), RequestWrapper.class);
            ResponseWrapper respWrapper = new ResponseWrapper();
            
            //OrgsRole_Mapper__c[] aceRoleMapper = null;
            
            UserRole tempUserRole  = [Select Id from UserRole where id=:UserInfo.getUserRoleId()];
            String tempIdString1 = UserInfo.getUserId();
            String user15DigitId = tempIdString1.subString(0,15);
            String tempRoleId =  tempUserRole.Id;
            
            User currentUser= [Select Id,Ace_Role__c,isAceAdmin__c from User where id =: UserInfo.getUserId()];
            User[] currUser = [Select Id, ManagerId, UserRoleId, LanguageLocaleKey, FirstName, LastName, Email,Ace_Role__c,isAceAdmin__c from User where Id =:UserInfo.getUserId()];
            
            //if(Test.isRunningTest()) aceRoleMapper= [Select Role_Id__c, isAceAdmin__c, iPad_Key__c from OrgsRole_Mapper__c where isAceAdmin__c =true];
            //else aceRoleMapper= [Select Role_Id__c, isAceAdmin__c, iPad_Key__c from OrgsRole_Mapper__c where Role_Id__c =:UserInfo.getUserRoleId()] ;
            //system.debug('==JSON Body11==>>'+ aceRoleMapper  +'--'+UserInfo.getUserRoleId());
            // if(jsonWrapper.isTestCtx == null) jsonWrapper.isTestCtx =false;
            if ('PLAN_UPSERT' ==  jsonWrapper.operation) { //Operation.
                Plan__c[] jsonObject = jsonWrapper.coachPlan; //rqstWrapper
                system.debug('==CoachPlan Parse==>>'+ jsonWrapper.coachPlan[0].Name);//.coachPlan
            
                CoachPlan[] coachPlanArray = new CoachPlan[jsonObject.size()];
                Database.upsertResult[] queryResult = Database.upsert(jsonObject, false);
                for(Integer idx = 0; idx < queryResult.size(); idx++) {
                    if(queryResult[idx].isSuccess()) {
                        CoachPlan coachPlan = new CoachPlan();
                        coachPlan.coachPlan = jsonObject[idx]; // rqstWrapper.coachPlan[idx];
                        coachPlan.coachPlan.Id = queryResult[idx].getId();
                        coachPlan.responseCode = 'ACE_PLAN_UPSERTED';
                        coachPlan.responseMessage = 'ACE_PLAN_UPSERTED';
                        coachPlanArray[idx] = coachPlan;
                        System.debug('Successfully inserted Plan__c Id: ' + queryResult[idx].getId());
                    } else {
                        for(Database.Error processingError : queryResult[idx].getErrors()) {
                            CoachPlan coachPlan = new CoachPlan();
                            coachPlan.coachPlan = jsonObject[idx]; //(Plan__c)rqstWrapper.coachPlan[idx];
                            coachPlan.responseCode = ''+processingError.getStatusCode(); // +': '+ processingError.getMessage();
                            coachPlan.responseMessage = processingError.getMessage(); // processingError.getFields();
                            coachPlanArray[idx] = coachPlan;
                            System.debug(processingError.getStatusCode() + ': ' + processingError.getMessage() + ': '+ processingError.getFields());
                        }
                    }
                }
                respWrapper.coachPlan = coachPlanArray; //planRecordProcessor(queryResult, coachPlanArray, jsonObject);
                respWrapper.statusMessage = 'ACE_PLAN_PROCESSED';
            } else if ('PLAN_DTLS_UPSERT' ==  jsonWrapper.operation) {
                Plan_Detail__c[] jsonObject = jsonWrapper.coachPlanDetail; //rqstWrapper
                system.debug('==CoachPlanDetail Parse==>>'+ jsonWrapper.coachPlanDetail[0].Name);//.coachPlan
            
                CoachPlanDetail[] coachPlanDetailArray = new CoachPlanDetail[jsonObject.size()];
                Database.upsertResult[] queryResult = Database.upsert(jsonObject, false);
                for(Integer idx = 0; idx < queryResult.size(); idx++) {
                    if(queryResult[idx].isSuccess()) {
                        CoachPlanDetail coachPlanDetail = new CoachPlanDetail();
                        coachPlanDetail.coachPlanDetail = jsonObject[idx]; // rqstWrapper.coachPlan[idx];
                        coachPlanDetail.coachPlanDetail.Id = queryResult[idx].getId();
                        coachPlanDetail.responseCode = 'ACE_PLAN_DTLS_UPSERTED';
                        coachPlanDetail.responseMessage = 'ACE_PLAN_DTLS_UPSERTED';
                        coachPlanDetailArray[idx] = coachPlanDetail;
                        System.debug('Successfully inserted Plan_Detail__c Id: ' + queryResult[idx].getId());
                    } else {
                        for(Database.Error processingError : queryResult[idx].getErrors()) {
                            CoachPlanDetail coachPlanDetail = new CoachPlanDetail();
                            coachPlanDetail.coachPlanDetail= jsonObject[idx]; //(Plan__c)rqstWrapper.coachPlan[idx];
                            coachPlanDetail.responseCode = ''+processingError.getStatusCode(); // +': '+ processingError.getMessage();
                            coachPlanDetail.responseMessage = processingError.getMessage(); // processingError.getFields();
                            coachPlanDetailArray[idx] = coachPlanDetail;
                            System.debug(processingError.getStatusCode() + ': ' + processingError.getMessage() + ': '+ processingError.getFields());
                        }
                    }
                }
                respWrapper.coachPlanDetail = coachPlanDetailArray; //planDetailRecordProcessor(queryResult, coachPlanArray, jsonObject);
                respWrapper.statusMessage = 'ACE_PLAN_DTLS_PROCESSED';
            } else if ('SESSION_UPSERT' ==  jsonWrapper.operation) {
                Coaching_Session__c[] jsonObject = jsonWrapper.coachSession; //rqstWrapper
                system.debug('==CoachSession Parse==>>'+ jsonWrapper.coachSession[0].Name);//.coachPlan
            
                CoachSession[] coachSessionArray = new CoachSession[jsonObject.size()];
                Database.upsertResult[] queryResult = Database.upsert(jsonObject, false);
                for(Integer idx = 0; idx < queryResult.size(); idx++) {
                    if(queryResult[idx].isSuccess()) {
                        CoachSession coachSession = new CoachSession();
                        coachSession.coachSession = jsonObject[idx]; // rqstWrapper.coachPlan[idx];
                        coachSession.coachSession.Id = queryResult[idx].getId();
                        coachSession.responseCode = 'ACE_SESSION_UPSERTED';
                        coachSession.responseMessage = 'ACE_SESSION_UPSERTED';
                        coachSessionArray[idx] = coachSession;
                        System.debug('Successfully inserted Coaching_Session__c Id: ' + queryResult[idx].getId());
                    } else {
                        for(Database.Error processingError : queryResult[idx].getErrors()) {
                            CoachSession coachSession = new CoachSession();
                            coachSession.coachSession = jsonObject[idx]; //(Plan__c)rqstWrapper.coachPlan[idx];
                            coachSession.responseCode = ''+processingError.getStatusCode(); // +': '+ processingError.getMessage();
                            coachSession.responseMessage = processingError.getMessage(); // processingError.getFields();
                            coachSessionArray[idx] = coachSession;
                            System.debug(processingError.getStatusCode() + ': ' + processingError.getMessage() + ': '+ processingError.getFields());
                        }
                    }
                }
                respWrapper.coachSession = coachSessionArray; //planDetailRecordProcessor(queryResult, coachPlanArray, jsonObject);
                respWrapper.statusMessage = 'ACE_SESSION_PROCESSED';
            } else if ('SESSION_DTLS_UPSERT' ==  jsonWrapper.operation) {
                Session_Detail__c[] jsonObject = jsonWrapper.coachSessionDetail; //rqstWrapper
                system.debug('==CoachSessionDetail Parse==>>'+ jsonWrapper.coachSessionDetail[0].Name);//.coachPlan
            
                CoachSessionDetail[] coachSessionDetailArray = new CoachSessionDetail[jsonObject.size()];
                Database.upsertResult[] queryResult = Database.upsert(jsonObject, false);
                for(Integer idx = 0; idx < queryResult.size(); idx++) {
                    if(queryResult[idx].isSuccess()) {
                        CoachSessionDetail coachSessionDetail = new CoachSessionDetail();
                        coachSessionDetail.coachSessionDetail = jsonObject[idx]; // rqstWrapper.coachPlan[idx];
                        coachSessionDetail.coachSessionDetail.Id = queryResult[idx].getId();
                        coachSessionDetail.responseCode = 'ACE_SESSION_DTLS_UPSERTED';
                        coachSessionDetail.responseMessage = 'ACE_SESSION_DTLS_UPSERTED';
                        coachSessionDetailArray[idx] = coachSessionDetail;
                        System.debug('Successfully inserted Session_Detail__c Id: ' + queryResult[idx].getId());
                    } else {
                        for(Database.Error processingError : queryResult[idx].getErrors()) {
                            CoachSessionDetail coachSessionDetail = new CoachSessionDetail();
                            coachSessionDetail.coachSessionDetail = jsonObject[idx]; //(Plan__c)rqstWrapper.coachPlan[idx];
                            coachSessionDetail.responseCode = ''+processingError.getStatusCode(); // +': '+ processingError.getMessage();
                            coachSessionDetail.responseMessage = processingError.getMessage(); // processingError.getFields();
                            coachSessionDetailArray[idx] = coachSessionDetail;
                            System.debug(processingError.getStatusCode() + ': ' + processingError.getMessage() + ': '+ processingError.getFields());
                        }
                    }
                } 
                respWrapper.coachSessionDetail = coachSessionDetailArray; //planDetailRecordProcessor(queryResult, coachPlanArray, jsonObject);
                respWrapper.statusMessage = 'ACE_SESSION_DTLS_PROCESSED';
            } else if ('ACTIVITY_UPSERT' ==  jsonWrapper.operation) {
                Coaching_Activity__c[] jsonObject = jsonWrapper.coachActivity; //rqstWrapper
                System.debug(jsonObject.size()+'==CoachActivity Parse==>>'+ jsonWrapper.coachActivity+'--->>'+jsonObject[0].Mentee_Name__c);//.coachPlan UserInfo.getUserId()
                
                CoachActivity[] coachActivityArray = new CoachActivity[jsonObject.size()];
                Database.upsertResult[] queryResult = Database.upsert(jsonObject, false);
                for(Integer idx = 0; idx < queryResult.size(); idx++) {
                    if(queryResult[idx].isSuccess()) {
                        CoachActivity coachActivity = new CoachActivity();
                        coachActivity.coachActivity = jsonObject[idx]; // rqstWrapper.coachPlan[idx];
                        coachActivity.coachActivity.Id = queryResult[idx].getId();
                        coachActivity.responseCode = 'ACE_ACTIVITY_UPSERTED';
                        coachActivity.responseMessage = 'ACE_ACTIVITY_UPSERTED';
                        coachActivityArray[idx] = coachActivity;
                        System.debug('Successfully inserted Coaching_Activity__c Id: ' + queryResult[idx].getId());
                    } else {
                        for(Database.Error processingError : queryResult[idx].getErrors()) {
                            CoachActivity coachActivity = new CoachActivity();
                            coachActivity.coachActivity = jsonObject[idx]; //(Plan__c)rqstWrapper.coachPlan[idx];
                            coachActivity.responseCode = ''+processingError.getStatusCode(); // +': '+ processingError.getMessage();
                            coachActivity.responseMessage =processingError.getMessage(); // processingError.getFields();
                            coachActivityArray[idx] = coachActivity;
                            System.debug(processingError.getStatusCode() + ': ' + processingError.getMessage() + ': '+ processingError.getFields());
                        }
                    }
                }
                respWrapper.coachActivity = coachActivityArray; //planDetailRecordProcessor(queryResult, coachPlanArray, jsonObject);
                respWrapper.statusMessage = 'ACE_ACTIVITY_PROCESSED';
            } else if ('ACTIVITY_RETRIEVE' ==  jsonWrapper.operation) {
            
            DateTime currentDateTime = System.Now();
            Integer currentMonth = currentDateTime.month();
            Integer currentYear = currentDateTime.Year();
            
            Datetime dt = System.NOW();
            String day = String.valueOf(dt.day());
            String month = String.valueOf(dt.month());
            
            Integer PreviousYear;
            Integer nextYear;
            DateTime lastHalfYearStart;
            DateTime lastHalfYearEnd;
            Date startDate;
            Date endDate;
            
            System.Debug('The currentMonth is' +currentMonth);
            System.Debug('The currentYear is' +currentYear);
            nextYear = currentYear + 1;
            PreviousYear = currentYear-1;
            if(currentMonth >=8 && currentMonth <=12){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(currentYear, 8,1);
                lastHalfYearEnd = datetime.newInstance(nextYear, 1,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            if(currentMonth ==1){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear, 8,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 1,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            if(currentMonth >= 2 && currentMonth < 8 && currentYear !=2015){
                System.Debug('The currentYear3 is' +currentYear);
                System.Debug('The PreviousYear is' +PreviousYear);
                lastHalfYearStart = datetime.newInstance(currentYear,2,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            if(currentMonth >= 2 && currentMonth < 8 && currentYear ==2015){
                System.Debug('The currentYear3 is' +currentYear);
                System.Debug('The PreviousYear is' +PreviousYear);
                lastHalfYearStart = datetime.newInstance(currentYear,1,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            
            System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
            System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            DateTime tempdate = dt.addDays(-1);
            System.Debug('The tempdate is ' + tempdate);
            
            
                Coaching_Activity__c[] resultObject = null;
                if (('SM' ==  currentUser.Ace_Role__c)) { //jsonWrapper.aceRole
                    resultObject = [SELECT Id, OwnerId, Name, Mentee_Name__c, Mentor_Name__c, Action_Plan__c, Focus_Area__c, 
                    Plan_Attachment_Id__c, Session_Attachment_Id__c, Sessions_Allocated__c, Sessions_Completed__c, isArchive__c FROM Coaching_Activity__c 
                        where isArchive__c=false and Mentee_Name__c IN (Select ID from User where ManagerId=:UserInfo.getUserId())  AND CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd];
                } else if (('SEM' ==  currentUser.Ace_Role__c) && (!currentUser.isAceAdmin__c)) {//jsonWrapper.aceRole
                    resultObject = [SELECT Id, OwnerId, Name, Mentee_Name__c, Mentor_Name__c, Action_Plan__c, Focus_Area__c, 
                    Plan_Attachment_Id__c, Session_Attachment_Id__c, Sessions_Allocated__c, Sessions_Completed__c, isArchive__c FROM Coaching_Activity__c 
                        where isArchive__c=false and Mentee_Name__c IN (Select ID from User where Coaching_Manager_Id_Final__c=:user15DigitId)  AND CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd];
                } else if (Test.isRunningTest() || (('SEM' ==  currentUser.Ace_Role__c) && (currentUser.isAceAdmin__c))) {//jsonWrapper.aceRole
                    resultObject = [SELECT Id, OwnerId, Name, Mentee_Name__c, Mentor_Name__c, Action_Plan__c, Focus_Area__c, 
                    Plan_Attachment_Id__c, Session_Attachment_Id__c, Sessions_Allocated__c, Sessions_Completed__c, isArchive__c FROM Coaching_Activity__c 
                        where isArchive__c=false  AND CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd];// and Mentee_Name__c IN (Select ID from User where ManagerId=:UserInfo.getUserId())
                }
                if (currentUser.Ace_Role__c != ''){
                    Coaching_Activity__c[] coachActivityArray = new Coaching_Activity__c[resultObject.size()];
                    
                    for(Integer idx = 0; idx < resultObject.size(); idx++) {
                        Coaching_Activity__c coachActivity = new Coaching_Activity__c();
                        coachActivity = resultObject[idx];//jsonObject[idx]; // rqstWrapper.coachPlan[idx];
                        coachActivity.Id = resultObject[idx].Id;
                        coachActivityArray[idx] = coachActivity;
                        System.debug('Successfully retrieved Coaching_Activity__c Id: ' + resultObject[idx].Id);
                    }
                    
                    respWrapper.coachActivityData = coachActivityArray;//resultObject; //planDetailRecordProcessor(queryResult, coachPlanArray, jsonObject);
                    respWrapper.statusMessage = 'ACE_SUCCESS';
                } else {
                    respWrapper.statusMessage = 'ACE_INVALID_USERROLE';
                }
            } 
            else if ('PLAN_RETRIEVE' ==  jsonWrapper.operation) {
            DateTime currentDateTime = System.Now();
            Integer currentMonth = currentDateTime.month();
            Integer currentYear = currentDateTime.Year();
            
            Datetime dt = System.NOW();
            String day = String.valueOf(dt.day());
            String month = String.valueOf(dt.month());
            
            Integer PreviousYear;
            DateTime lastHalfYearStart;
            DateTime lastHalfYearEnd;
            Date startDate;
            Date endDate;
            PreviousYear = currentYear-1;
            System.Debug('The currentMonth is' +currentMonth);
            System.Debug('The currentYear is' +currentYear);
            if(currentMonth >=8 && currentMonth <=12 && currentYear != 2015){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(currentYear, 2,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            if(currentMonth >=8 && currentMonth <=12 && currentYear == 2015){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(currentYear, 1,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            if(currentMonth == 1 && currentYear != 2016){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear, 2,1);
                lastHalfYearEnd = datetime.newInstance(PreviousYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            
            if(currentMonth == 1 && currentYear == 2016){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear, 1,1);
                lastHalfYearEnd = datetime.newInstance(PreviousYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            if((currentMonth>= 2 && currentMonth < 8) && currentYear != 2015){
                System.Debug('The currentYear3 is' +currentYear);
                
                System.Debug('The PreviousYear is' +PreviousYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear,8,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 1,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            
            if((currentMonth>= 2 && currentMonth < 8) && currentYear == 2015){
                System.Debug('The currentYear3 is' +currentYear);
                
                System.Debug('The PreviousYear is' +PreviousYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear,7,1);
                lastHalfYearEnd = datetime.newInstance(PreviousYear, 12,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
            System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            DateTime tempdate = dt.addDays(-1);
            System.Debug('The tempdate is ' + tempdate);
                Plan__c[] resultObject = null;
                if (('SM' ==  currentUser.Ace_Role__c)) { //jsonWrapper.aceRole
                    resultObject = [SELECT Id, Focus_Area_Note__c, Created_Date__c, Identifier__c, IPad_Key__c, isArchive__c,Period_1__c, Period_value__c, Plan_Session_Id__c, 
                    Rep_SM_Country__c, Rep_First_Name__c,Rep_Last_Name__c,Rep_Id__c,Role_Id__c,Session_Allocated_Goal_Update__c,Session_Status__c,User_Id__c,User_Role__c FROM Plan__c 
                        where isArchive__c=false and Rep_Id__c IN (Select ID from User where ManagerId=:UserInfo.getUserId()) and CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd and Session_Status__c != '0'];
                } else if (('SEM' ==  currentUser.Ace_Role__c) && (!currentUser.isAceAdmin__c)) {//jsonWrapper.aceRole
                    resultObject = [SELECT Id, Focus_Area_Note__c, Created_Date__c, Identifier__c, IPad_Key__c, isArchive__c,Period_1__c, Period_value__c, Plan_Session_Id__c, 
                    Rep_SM_Country__c, Rep_First_Name__c,Rep_Last_Name__c,Rep_Id__c,Role_Id__c,Session_Allocated_Goal_Update__c,Session_Status__c,User_Id__c,User_Role__c FROM Plan__c 
                        where isArchive__c=false and Rep_Id__c IN (Select ID from User where Coaching_Manager_Id_Final__c=:user15DigitId) and CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd and Session_Status__c != '0'];
                } else if (Test.isRunningTest() || (('SEM' ==  currentUser.Ace_Role__c) && (currentUser.isAceAdmin__c))) {//jsonWrapper.aceRole
                    resultObject = [SELECT Id, Focus_Area_Note__c, Created_Date__c, Identifier__c, IPad_Key__c, isArchive__c,Period_1__c, Period_value__c, Plan_Session_Id__c, 
                    Rep_SM_Country__c, Rep_First_Name__c,Rep_Last_Name__c,Rep_Id__c,Role_Id__c,Session_Allocated_Goal_Update__c,Session_Status__c,User_Id__c,User_Role__c FROM Plan__c 
                        where isArchive__c=false and CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd and Session_Status__c != '0' AND IPad_Key__c='SM'];// and Rep_Id__c IN (Select ID from User where ManagerId=:UserInfo.getUserId())
                }
                
                System.Debug('The resultObject is ' + resultObject);
                if (currentUser.Ace_Role__c != ''){
                    Plan__c[] coachActivityArray = new Plan__c[resultObject.size()];
                    
                    for(Integer idx = 0; idx < resultObject.size(); idx++) {
                        Plan__c coachActivity = new Plan__c();
                        coachActivity = resultObject[idx];//jsonObject[idx]; // rqstWrapper.coachPlan[idx];
                        coachActivity.Id = resultObject[idx].Id;
                        coachActivityArray[idx] = coachActivity;
                        System.debug('Successfully retrieved Plan__c Id: ' + resultObject[idx].Id);
                    }
                    
                    respWrapper.coachPlanData = coachActivityArray;//resultObject; //planDetailRecordProcessor(queryResult, coachPlanArray, jsonObject);
                    respWrapper.statusMessage = 'ACE_SUCCESS';
                }else {
                    respWrapper.statusMessage = 'ACE_INVALID_USERROLE';
                }
            }else if ('PLAN_DETAIL_RETRIEVE' ==  jsonWrapper.operation) {
                DateTime currentDateTime = System.Now();
            Integer currentMonth = currentDateTime.month();
            Integer currentYear = currentDateTime.Year();
            
            Datetime dt = System.NOW();
            String day = String.valueOf(dt.day());
            String month = String.valueOf(dt.month());
            
            Integer PreviousYear;
            DateTime lastHalfYearStart;
            DateTime lastHalfYearEnd;
            Date startDate;
            Date endDate;
            PreviousYear = currentYear-1;
            
            if(currentMonth >=8 && currentMonth <=12 && currentYear != 2015){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(currentYear, 2,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            if(currentMonth >=8 && currentMonth <=12 && currentYear == 2015){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(currentYear, 1,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            if(currentMonth == 1 && currentYear != 2016){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear, 2,1);
                lastHalfYearEnd = datetime.newInstance(PreviousYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            
            if(currentMonth == 1 && currentYear == 2016){
                System.Debug('The currentYear2 is' +currentYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear, 1,1);
                lastHalfYearEnd = datetime.newInstance(PreviousYear, 7,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            
            if((currentMonth>= 2 && currentMonth < 8) && currentYear != 2015){
                System.Debug('The currentYear3 is' +currentYear);
                
                System.Debug('The PreviousYear is' +PreviousYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear,8,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 1,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            
            if((currentMonth>= 2 && currentMonth < 8) && currentYear == 2015){
                System.Debug('The currentYear3 is' +currentYear);
                
                System.Debug('The PreviousYear is' +PreviousYear);
                lastHalfYearStart = datetime.newInstance(PreviousYear,7,1);
                lastHalfYearEnd = datetime.newInstance(PreviousYear, 12,31);
                System.Debug('lastHalfYearStart is'+ lastHalfYearStart);
                System.Debug('lastHalfYearEnd is' +lastHalfYearEnd);
            
            }
            
            /*if(currentMonth >=7 && currentMonth <=12){
                lastHalfYearStart = datetime.newInstance(currentYear, 1,1);
                lastHalfYearEnd = datetime.newInstance(currentYear, 6,30);
                
            }
            if(currentMonth >= 1 && currentMonth < 7){
                PreviousYear = currentYear-1;
                lastHalfYearStart = datetime.newInstance(currentYear, 3,10);
                lastHalfYearEnd = datetime.newInstance(currentYear, 3,15);
                }
            */
            System.Debug('The start Date is' + lastHalfYearStart);
            System.Debug('The endDate is' + lastHalfYearEnd);
            DateTime tempdate = dt.addDays(-1);
                Plan_Detail__c[] resultObject = null;
                List<Plan__c> tempPlanList = [SELECT Id FROM Plan__c where isArchive__c=false and Rep_Id__c IN (Select ID from User where ManagerId=:UserInfo.getUserId()) and CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd and Session_Status__c != '0'];
                List<Plan__c> tempPlanList3 = [SELECT Id FROM Plan__c where isArchive__c=false and Rep_Id__c IN (Select ID from User where Coaching_Manager_Id_Final__c=:user15DigitId) and CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd and Session_Status__c != '0'];
                List<Plan__c> tempPlanList2 = [SELECT Id FROM Plan__c where isArchive__c=false and CreatedDate >: lastHalfYearStart and CreatedDate <: lastHalfYearEnd and Session_Status__c != '0' AND IPad_Key__c='SM'];
                
                System.Debug('The planList is' + tempPlanList);
                if (('SM' ==  currentUser.Ace_Role__c)) { //jsonWrapper.aceRole
                    resultObject = [SELECT Id, Answer__c, Numeric_Answer__c, Answer_Equivalent_Key__c, Business_Unit__c, Competency_Id__c, First_Name_Last_Name__c,Identifier__c, isArchive__c, isFocusArea_Selected__c,Question_Number__c, Key_Behaviour__c,Name__c,OrgsRole_Mapper_Eqv__c,Period__c,Plan_Associated_with__c,Plan_Detail__c,Plan__c,Question_Id__c,Question_Name__c,Question_Order__c,Region__c,Rep_SM_Country__c,Rep_SM_Name__c,Rep_First_Name__c,Rep_Last_Name__c,Role__c FROM Plan_Detail__c 
                        where isArchive__c=false and Plan__c IN : tempPlanList];
                } else if (('SEM' ==  currentUser.Ace_Role__c) && (!currentUser.isAceAdmin__c)) {//jsonWrapper.aceRole
                    resultObject = [SELECT Id, Answer__c, Numeric_Answer__c, Answer_Equivalent_Key__c, Business_Unit__c, Competency_Id__c, First_Name_Last_Name__c,Identifier__c, isArchive__c, isFocusArea_Selected__c,Question_Number__c, Key_Behaviour__c,Name__c,OrgsRole_Mapper_Eqv__c,Period__c,Plan_Associated_with__c,Plan_Detail__c,Plan__c,Question_Id__c,Question_Name__c,Question_Order__c,Region__c,Rep_SM_Country__c,Rep_SM_Name__c,Rep_First_Name__c,Rep_Last_Name__c,Role__c FROM Plan_Detail__c
                        where isArchive__c=false and Plan__c IN : tempPlanList3];
                } else if (Test.isRunningTest() || (('SEM' ==  currentUser.Ace_Role__c) && (currentUser.isAceAdmin__c))) {//jsonWrapper.aceRole
                    resultObject = [SELECT Id, Answer__c, Numeric_Answer__c, Answer_Equivalent_Key__c, Business_Unit__c, Competency_Id__c, First_Name_Last_Name__c,Identifier__c, isArchive__c, isFocusArea_Selected__c,Question_Number__c, Key_Behaviour__c,Name__c,OrgsRole_Mapper_Eqv__c,Period__c,Plan_Associated_with__c,Plan_Detail__c,Plan__c,Question_Id__c,Question_Name__c,Question_Order__c,Region__c,Rep_SM_Country__c,Rep_SM_Name__c,Rep_First_Name__c,Rep_Last_Name__c,Role__c FROM Plan_Detail__c
                        where isArchive__c=false and Plan__c IN : tempPlanList2];// and Rep_Id__c IN (Select ID from User where ManagerId=:UserInfo.getUserId())
                }
                if (currentUser.Ace_Role__c != ''){
                    Plan_Detail__c[] coachActivityArray = new Plan_Detail__c[resultObject.size()];
                    
                    for(Integer idx = 0; idx < resultObject.size(); idx++) {
                        Plan_Detail__c coachActivity = new Plan_Detail__c();
                        coachActivity = resultObject[idx];//jsonObject[idx]; // rqstWrapper.coachPlan[idx];
                        coachActivity.Id = resultObject[idx].Id;
                        coachActivityArray[idx] = coachActivity;
                        System.debug('Successfully retrieved Plan_Detail__c Id: ' + resultObject[idx].Id);
                    }
                    
                    respWrapper.coachPlanDetailData = coachActivityArray;//resultObject; //planDetailRecordProcessor(queryResult, coachPlanArray, jsonObject);
                    respWrapper.statusMessage = 'ACE_SUCCESS';
                } else{
                    respWrapper.statusMessage = 'ACE_INVALID_USERROLE';
                }   
            } 
            else if ('REPORTEE_RETRIEVE' ==  jsonWrapper.operation) {
                if(currentUser.Ace_Role__c != '') {
                    String roleFilter =null;
                    Set<String> roleMapperSet = new Set<String>();//:UserInfo.getUserId()
                    Set<String> reporteeIdMapperSet = new Set<String>();
                    //User[] currUser = [Select Id, ManagerId, UserRoleId, LanguageLocaleKey, FirstName, LastName, Email from User where Id =:UserInfo.getUserId()];
                    
                    /***
                    if(aceRoleMapper[0].iPad_Key__c == 'SEM') roleFilter = 'SM';
                    else if (aceRoleMapper[0].iPad_Key__c == 'SM') roleFilter = 'SR';
                    
                    OrgsRole_Mapper__c[] aceSubordinateRoles = [Select Role_Id__c, iPad_Key__c from OrgsRole_Mapper__c where iPad_Key__c=: roleFilter];
                    for(OrgsRole_Mapper__c roleMapper : aceSubordinateRoles) {
                        roleMapperSet.add(''+roleMapper.Role_Id__c);
                    }
                    system.debug(aceRoleMapper[0].iPad_Key__c+'====@@@@==>>>'+aceRoleMapper[0].Role_Id__c);// userRoleId
                    **/
                    
                    User[] resultObject = null;
                    if(currentUser.Ace_Role__c == 'SM') {//
      
      User[] aceSubordinateUsers = [Select Id,Ace_Role__c,isAceAdmin__c from User where Ace_Role__c='SR'];
      for(User userMapper : aceSubordinateUsers) {
       reporteeIdMapperSet.add(''+userMapper.Id);
      }
      
                        //OrgsRole_Mapper__c[] aceSubordinateRoles = [Select Role_Id__c, iPad_Key__c from OrgsRole_Mapper__c where iPad_Key__c='SR'];
                        /*
      for(OrgsRole_Mapper__c roleMapper : aceSubordinateRoles) {
                            roleMapperSet.add(''+roleMapper.Role_Id__c);
                        }
      */
                        resultObject = [Select u.Id, u.Email, u.Username, u.FirstName, u.LastName, u.UserRoleId from User u where
                            u.IsActive = true and u.ManagerId=:UserInfo.getUserId() and u.Id IN : reporteeIdMapperSet];//479 SR and u.UserRole.Id IN : roleMapperSet
                            //and u.UserRoleId != :currUser[0].UserRoleId 
                    } else if((currentUser.Ace_Role__c == 'SEM') && (!currentUser.isAceAdmin__c)) {//isAceAdmin__c 00E20000000ivVKEAY 00E20000000qSQSEA2
                        /*OrgsRole_Mapper__c[] aceSubordinateRoles = [Select Role_Id__c, iPad_Key__c from OrgsRole_Mapper__c where iPad_Key__c='SR' or iPad_Key__c='SM'];//
                        for(OrgsRole_Mapper__c roleMapper : aceSubordinateRoles) {
                            roleMapperSet.add(''+roleMapper.Role_Id__c);
                        }*/
      
      User[] aceSubordinateUsers = [Select Id,Ace_Role__c,isAceAdmin__c from User where Ace_Role__c='SR' or Ace_Role__c='SM'];
                    
      for(User userMapper : aceSubordinateUsers) {
       reporteeIdMapperSet.add(''+userMapper.Id);
      }
      
      
                        resultObject = [Select u.Id, u.Email, u.Username, u.FirstName, u.LastName, u.UserRoleId from User u where 
                            u.IsActive = true and u.Coaching_Manager_Id_Final__c=:user15DigitId and u.Id IN : reporteeIdMapperSet];//105 SM
                            //u.UserRoleId != :currUser[0].UserRoleId and
                    } else if(currentUser.isAceAdmin__c) { //Yufang Wang iPad_Key__c='SR' or 
                        /*OrgsRole_Mapper__c[] aceSubordinateRoles = [Select Role_Id__c, iPad_Key__c from OrgsRole_Mapper__c where iPad_Key__c='SM' ];//or iPad_Key__c='SEM'
                        for(OrgsRole_Mapper__c roleMapper : aceSubordinateRoles) {//or iPad_Key__c='SR' or iPad_Key__c='SEM'
                            roleMapperSet.add(''+roleMapper.Role_Id__c);
                        }*/
      
      User[] aceSubordinateUsers = [Select Id,Ace_Role__c,isAceAdmin__c from User where Ace_Role__c='SM'];
                    
                    for(User userMapper : aceSubordinateUsers) {//or iPad_Key__c='SR' or iPad_Key__c='SEM'
                        reporteeIdMapperSet.add(''+userMapper.Id);
                    }
                        resultObject = [Select u.Id, u.Email, u.Username, u.FirstName, u.LastName, u.UserRoleId from User u where 
                            u.IsActive = true and u.Id IN : reporteeIdMapperSet];//74 SEM  and u.ManagerId=:UserInfo.getUserId()
                    }
                    respWrapper.reporteeData = resultObject;
                    if(currUser.size() > 0) respWrapper.localeKey = currUser[0].LanguageLocaleKey;
                    
                    //respWrapper.reporteeSize = ''+resultObject.size();
                    respWrapper.userFirstName = currUser[0].FirstName;
                    respWrapper.userLastName = currUser[0].LastName;
                    respWrapper.userEmail = currUser[0].Email;
                    respWrapper.userId = currUser[0].Id;
                    respWrapper.statusMessage = 'ACE_SUCCESS';//+aceRoleMapper[0].Role_Id__c
                } else{
                    respWrapper.statusMessage = 'ACE_INVALID_USERROLE';
                }
            }/****/ else respWrapper.statusMessage = 'Please Specify Operation --->> REPORTEE_RETRIEVE, ACTIVITY_RETRIEVE, ACTIVITY_UPSERT, PLAN_UPSERT, PLAN_DTLS_UPSERT, SESSION_UPSERT, SESSION_DTLS_UPSERT';
            respWrapper.aceLanguage = new List<String> { 'en_US', 'zh_CN' };
            respWrapper.aceDefaultLanguage = 'zh_CN';
            respWrapper.userLocaleTime = system.now().format('dd/MM/yyyy');
            respWrapper.aceRegion= 'CHN';
            if(currentUser.Ace_Role__c != null) respWrapper.aceRole = currentUser.Ace_Role__c;// assign istance specific super user
            return respWrapper;
        }
        
        @future
        public static void updateAceRecordOwner(Map<Id, String> userMap) { //Hierarchy AceSyncProcessor.UserWrapper
            // List<GroupMember> newGroupMembers = new List<GroupMember>();
            if (userMap.size() > 0) {
                List<Coaching_Activity__c> coachActivityData = [SELECT Id, OwnerId, Name, Mentee_Name__c, Mentor_Name__c, isArchive__c
                                FROM Coaching_Activity__c where isArchive__c = false and Mentee_Name__c IN :userMap.keySet()];
                for(Coaching_Activity__c coachActivity: coachActivityData){
                    System.Debug('userMap OwnerId is' + userMap);
                    System.Debug('userMap.get(coachActivity.Mentee_Name__c) OwnerId is' + userMap.get(coachActivity.Mentee_Name__c));
                    System.Debug('userMap.get(coachActivity.Mentee_Name__c) is' + userMap.get(coachActivity.Mentee_Name__c).split(':'));
                    String[] userDetails = userMap.get(coachActivity.Mentee_Name__c).split(':');
                    if (userDetails.size() >0 && userDetails[0] != null && userDetails[0] != 'null') {
                        System.Debug('coachActivity is' + coachActivity);
                        System.Debug('coachActivity OwnerId is' + coachActivity.OwnerId);
                        System.Debug('userDetails OwnerId is' + userDetails[0]);
                        
                        coachActivity.OwnerId = String.escapeSingleQuotes(userDetails[0]);
                        coachActivity.Mentor_Name__c = String.escapeSingleQuotes(userDetails[0]);
                    }
                    if (userDetails.size() >1 && userDetails[1] != null && userDetails[1] != 'null') coachActivity.isArchive__c = true;
                    System.debug('AceHierarchyTrigger coachActivity: manager>' +coachActivity.OwnerId);
                }
                
                List<Coaching_Session__c> coachSessionData = [SELECT Id, OwnerId, Name, Rep_Id__c, LoggedIn_User__c, isArchive__c FROM Coaching_Session__c 
                                where isArchive__c = false and Rep_Id__c IN :userMap.keySet()];
                for(Coaching_Session__c coachSession: coachSessionData){
                    String[] userDetails = userMap.get(coachSession.Rep_Id__c).split(':');
                    if (userDetails.size() >0 && userDetails[0] != null && userDetails[0] != 'null') {
                        coachSession.OwnerId = String.escapeSingleQuotes(userDetails[0]);
                        coachSession.LoggedIn_User__c = String.escapeSingleQuotes(userDetails[0]);
                    }
                    if (userDetails.size() >1 && userDetails[1] != null) coachSession.isArchive__c = true;
                    System.debug('AceHierarchyTrigger coachSession: manager>' +coachSession.OwnerId);
                }
                
                List<Plan__c> coachPlanData = [SELECT Id, OwnerId, Name, Rep_Id__c, User_Id__c, isArchive__c FROM Plan__c 
                                where isArchive__c = false and Rep_Id__c IN :userMap.keySet()];
                for(Plan__c coachPlan: coachPlanData){
                    String[] userDetails = userMap.get(coachPlan.Rep_Id__c).split(':');
                    if (userDetails.size() >0 && userDetails[0] != null && userDetails[0] != 'null') {
                        coachPlan.OwnerId = String.escapeSingleQuotes(userDetails[0]);
                        coachPlan.User_Id__c = String.escapeSingleQuotes(userDetails[0]);
                    }
                    if (userDetails.size() >1 && userDetails[1] != null && userDetails[1] != 'null') coachPlan.isArchive__c = true;
                    System.debug('AceHierarchyTrigger coachPlan: manager>' +coachPlan.OwnerId);
                }
                
                if(!Test.isRunningTest() && coachActivityData.size() > 0) upsert coachActivityData;
                if(!Test.isRunningTest() && coachSessionData.size() > 0) upsert coachSessionData;
                if(!Test.isRunningTest() && coachPlanData.size() > 0) upsert coachPlanData;
            }
        }
            
        global class CoachActivity {
            global Coaching_Activity__c coachActivity;
            global String responseMessage;
            global String responseCode; 
        }
        
        global class CoachPlan {
            global Plan__c coachPlan;
            global String responseMessage;
            global String responseCode; 
        }
        
        global class CoachSession {
            global Coaching_Session__c coachSession;
            global String responseMessage;
            global String responseCode; 
        }
        
        global class CoachPlanDetail {
            global Plan_Detail__c coachPlanDetail;
            global String responseMessage;
            global String responseCode; 
        }
        
        global class CoachSessionDetail {
            global Session_Detail__c coachSessionDetail;
            global String responseMessage;
            global String responseCode; 
        }
        
        global class RequestWrapper{
            global Plan__c[] coachPlan;
            global Coaching_Session__c[] coachSession;
            global Plan_Detail__c[] coachPlanDetail;
            global Session_Detail__c[] coachSessionDetail;
            global Coaching_Activity__c[] coachActivity;
            // global String userRoleId; 
            global String aceRole; //@Deprecate userRole input should not be honoured String result = UserInfo.getLocale(); en_US
            global String operation; // activityUpdate; planUpsert; planDetailUpsert; coachSessionUpsert; coachSessionDetailUpsert
            // global Boolean isTestCtx;
        }
        
        global class ResponseWrapper {           
            global CoachPlan[] coachPlan;
            global CoachSession[] coachSession;
            global CoachPlanDetail[] coachPlanDetail;
            global CoachSessionDetail[] coachSessionDetail;
            global CoachActivity[] coachActivity;
            global Coaching_Activity__c[] coachActivityData;
            global Plan__c[] coachPlanData;
            global Plan_Detail__c[] coachPlanDetailData;
            global User[] reporteeData;
            global String statusMessage;
            global String aceRole;
            global String localeKey;
            global String[] aceLanguage;//, u.
            global String aceDefaultLanguage;//, u.
            global String userLocaleTime;
            global String userFirstName;
            global String userLastName;
            global String userEmail;
            global String userId;
            global String reporteeSize;
            global String aceRegion;
        }
        
        global enum Operation {REPORTEE_RETRIEVE, ACTIVITY_RETRIEVE, ACTIVITY_UPSERT, PLAN_UPSERT, PLAN_DTLS_UPSERT, SESSION_UPSERT, SESSION_DTLS_UPSERT}
    }
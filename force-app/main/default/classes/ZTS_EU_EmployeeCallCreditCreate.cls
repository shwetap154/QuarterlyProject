/*************************************************************************************
* Name          :    ZTS_EU_EmployeeCallCreditCreate.
* Description   :    Controller for creating Employee Call Credit when Pitcher loads call
* Author        :    Teresa
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
05/23/2014       Teresa                    Created

**************************************************************************************/
public with sharing class ZTS_EU_EmployeeCallCreditCreate{
/* This method is used to get the Account Position for all the Colleagues added
*  against a Call. If there are multiple account positions against a colleague for the same call
*  assign any one Account Position and create a ECC record
*/ 
public static void createEmployeeCallCredit(List<ZTS_EU_Colleague__c> triggerNew){
    system.debug('**********************createEmployeeCallCredit***************');
    try{
            List<String> accountIds = new List<String>();
            List<String> callIds    = new List<String>();
            Map<String,String> callAccountIdMap = new Map<String,String>();
            List<ZTS_EU_Colleague__c> colleagueList = new List<ZTS_EU_Colleague__c>();
            List<ZTS_EU_Employee_Call_Credit__c> empCreditList = new List<ZTS_EU_Employee_Call_Credit__c>();
            Map<String,Map<String,String>> accUserPosMap = new Map<String,Map<String,String>>();
            List<ZTS_EU_Colleague__c> colleagueList1 = new List<ZTS_EU_Colleague__c>();
            List<Period> FYdates = new List<Period>();
            FYdates= [SELECT FiscalYearSettings.Name,StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY];
            Date currentFiscalYearEnddate = FYdates[0].EndDate;
            Date currentFiscalYearStartdate = FYdates[0].StartDate;
            colleagueList1 = [Select Id,ZTS_EU_Call__c,ZTS_EU_Automatic_ECC_creation__c,ZTS_EU_User__c, ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c, ZTS_EU_Call__r.ZTS_EU_Status__c, ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c from ZTS_EU_Colleague__c where id IN:triggerNew AND ZTS_EU_Market__c != 'United States'];
            for(ZTS_EU_Colleague__c colleague : colleagueList1 ){
                // make a list of all callIds from Colleague that has ZTS_EU_Automatic_ECC_creation__c as 'To be Created'
                system.debug('************************colleague.ZTS_EU_Automatic_ECC_creation__c***************'+colleague.ZTS_EU_Automatic_ECC_creation__c);
                if(colleague.ZTS_EU_Automatic_ECC_creation__c == 'To be Created'){
                    callIds.add(colleague.ZTS_EU_Call__c);
                }
            }
            system.debug('************************callIds***************'+callIds);
            List<Call__c> callsList = [SELECT Id,ZTS_EU_Account__c FROM Call__c WHERE Id IN :callIds AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            for(Call__c call : callsList){
                accountIds.add(call.ZTS_EU_Account__c);
                callAccountIdMap.put(call.Id,call.ZTS_EU_Account__c);
            }
            system.debug('***********accountIds****** ' + accountIds);
            system.debug('***********callAccountIdMap****** ' + callAccountIdMap);
            List<ZTS_EU_Account_Position__c> listAcctPos = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Position__r.Name,ZTS_EU_Position__r.ZTS_EU_Employee__c,ZTS_EU_Employee__c FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Account__c =: accountIds AND ZTS_EU_Is_Active__c = TRUE AND ZTS_EU_Market__c != 'United States'];
            system.debug('***********listAcctPos****** ' + listAcctPos);
            for(ZTS_EU_Account_Position__c accPos : listAcctPos){
                Map<String,String> userPosMap;
                userPosMap = accUserPosMap.get(accPos.ZTS_EU_Account__c) != null?accUserPosMap.get(accPos.ZTS_EU_Account__c): new Map<String,String>();
                userPosMap.put(accPos.ZTS_EU_Position__r.ZTS_EU_Employee__c,accPos.Id);
                accUserPosMap.put(accPos.ZTS_EU_Account__c,userPosMap);
                system.debug('***********userPosMap****** ' + userPosMap);
                system.debug('***********accUserPosMap****** ' + accUserPosMap);
            }
             system.debug('************************accUserPosMap***************'+accUserPosMap);
            for(ZTS_EU_Colleague__c colleague : colleagueList1 ){
                 system.debug('************************callAccountIdMap.containsKey(colleague.ZTS_EU_Call__c))***************'+callAccountIdMap.containsKey(colleague.ZTS_EU_Call__c));
                  system.debug('************************callAccountIdMap.get(colleague.ZTS_EU_Call__c)***************'+callAccountIdMap.get(colleague.ZTS_EU_Call__c));
                 system.debug('************************accUserPosMap.containsKey(callAccountIdMap.get(colleague.ZTS_EU_Call__c)))***************'+accUserPosMap.containsKey(callAccountIdMap.get(colleague.ZTS_EU_Call__c)));
                if((callAccountIdMap != null && callAccountIdMap.containsKey(colleague.ZTS_EU_Call__c)) && (accUserPosMap != null && accUserPosMap.containsKey(callAccountIdMap.get(colleague.ZTS_EU_Call__c)))){
                        system.debug('---------yes 1-------');
                        system.debug('---------yes 1-------');
                   Map<String,String> userPosMap = accUserPosMap.get(callAccountIdMap.get(colleague.ZTS_EU_Call__c));
                     system.debug('************************userPosMap***************'+userPosMap);
                     system.debug('************************Colleague***************'+colleague.ZTS_EU_User__c);
                     system.debug('************************userPosMap**Keyset*************'+userPosMap.keyset());
                     system.debug('************************userPosMap.containsKey(colleague.ZTS_EU_User__c)***************'+userPosMap.containsKey(colleague.ZTS_EU_User__c));
                    if(colleague.ZTS_EU_Automatic_ECC_creation__c == 'To be Created' && (userPosMap != null && userPosMap.containsKey(colleague.ZTS_EU_User__c))){
                        system.debug('---------yes 2-------');
                        ZTS_EU_Employee_Call_Credit__c empCredit = new ZTS_EU_Employee_Call_Credit__c();
                        empCredit.ZTS_EU_Account_Position__c = userPosMap.get(colleague.ZTS_EU_User__c);
                        empCredit.ZTS_EU_Employee_Colleague__c = colleague.Id;
                        empCredit.ZTS_EU_Call__c = colleague.ZTS_EU_Call__c;
                        System.debug('end date----'+colleague.ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c);
                        empCredit.Call_End_Date__c = colleague.ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c;
                        if(currentFiscalYearStartdate<=colleague.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c&&colleague.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c<=currentFiscalYearEnddate&&colleague.ZTS_EU_Call__r.ZTS_EU_Status__c=='completed'){
                        		empCredit.Is_Call_Completed_In_Current_FY__c=true;
                        }
                        empCredit.ZTS_EU_FY_StartDate__c = currentFiscalYearStartdate;
                        empCredit.ZTS_EU_FY_EndDate__c = currentFiscalYearEnddate;
                        empCreditList.add(empCredit);
                    }
                     system.debug('***********empCreditList****** ' + empCreditList);
                      system.debug('***********empCreditList**Size**** ' + empCreditList.Size());
                    // update ZTS_EU_Automatic_ECC_creation__c of Colleague object to 'Has been created'
                    ZTS_EU_Colleague__c col = new ZTS_EU_Colleague__c();
                    col.Id = colleague.Id;
                    col.ZTS_EU_Automatic_ECC_creation__c = 'Has been Created';
                    colleagueList.add(col);
                }
            }
            List<Database.Upsertresult> results  = Database.upsert(empCreditList,false);
            ZTS_EU_Logger.error(results, 'ZTS_EU_EmployeeCallCreditCreate-createEmployeeCallCredit');
            List<Database.Saveresult> results1 = Database.update(colleagueList,false);
            ZTS_EU_Logger.error(results1, 'ZTS_EU_EmployeeCallCreditCreate-createEmployeeCallCredit');
        } catch (DMLException ex){
            ZTS_EU_Logger.error('DMLException : '+ex.getMessage(), null, 'ZTS_EU_EmployeeCallCreditCreate-createEmployeeCallCredit');
            system.debug('*************DML Exception***********'+ex.getMessage());
        } catch (Exception e){
            ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_EmployeeCallCreditCreate-createEmployeeCallCredit');
            system.debug('*************DML Exception***********'+e.getMessage());
        } 
    }
 }
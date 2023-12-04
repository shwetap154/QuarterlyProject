/**
 * @description       : 
 * @author            : Nilanjan @ Cognizant
 * @group             : 
 * @last modified on  : 09-17-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
public with sharing class alphaCaseHandler {

    @AuraEnabled(cacheable=true)
    public static List<string> getCaseType()
    {
       List<string> options = new List<string>();
       Schema.DescribeFieldResult fieldResult = Case.Case_Type__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               options.add(f.getValue());
       }     
       return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getCaseList(string accountId){
        Map<string,sobject> accmap = new Map<string,sobject>();
        List<sobject> accountList = UtilityController.returnObjList();
        //for(account eachacc: sobject){
            accmap.putAll(accountList);
        //}
        try {
                System.debug('Account ID>>>>>>>' + accountId);
                //This is for testing & demo only...
                if(String.isEmpty(accountId))
                {
                    //accountId = '0011g00000u7SSdAAM';
                }

                string QueryText = 'SELECT Id,Account.Name,Subject,Description,Case_Type__c,Created_By__c,createddate  from Case ';

                if(!String.isEmpty(accountId))
                {
                    if( !accmap.containskey(accountId)){
                        throw new AuraHandledException('Market Mismatch');
                    }else{
                        QueryText = QueryText + ' where  AccountId = :accountId';
                    }
                        //QueryText = QueryText + ' Where AccountId = :accountId';
                }else {
                    QueryText +=  ' Where AccountId IN :accountList';
                }

                List<Case> lstCase = Database.query(QueryText);
                return lstCase;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createCase(string payload)
    {
        system.debug('payload>>>'+payload);
        AssignmentRule assignRule = [
            SELECT 
            Id 
            FROM AssignmentRule 
            WHERE SObjectType = 'Case' 
            AND Active = TRUE 
            LIMIT 1
        ];
        Database.DMLOptions saveOptions = new Database.DMLOptions();
        saveOptions.assignmentRuleHeader.assignmentRuleId = assignRule.Id;
        try{

            List<sobject> accountList = UtilityController.returnObjList();

            RecordType recType = [SELECT Id,DeveloperName FROM RecordType WHERE 
                                    SObjectType = 'Case' 
                                    and DeveloperName = 'Open_Service_Request' LIMIT 1];
            Type resultType = Type.forName('Case');
            Case c = (Case)JSON.deserialize(payload, resultType);
            c.accountId = accountList[0].Id;//'0011g00000u7SSdAAM';
            c.RecordTypeId = recType.Id;//'012F0000000WRKdIAO';
            //System.debug('CASE==>' + c);
            c.setOptions(saveOptions);
            insert c;
            return 'success';
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
       
    }
}
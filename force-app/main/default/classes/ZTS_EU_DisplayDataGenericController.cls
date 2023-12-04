/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_DisplayDataGenericController
* Description   :  This is the controller of the generic vf component.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     15th-Oct-14   Shreyas             Created the class.

********************************************************************************************************************************************/

public class ZTS_EU_DisplayDataGenericController {

    public list<string> fieldsList {get; set;}
    public sObject objName {get; set;}
    public string objNamestring {get; set;}
    public string recordId {get; set;}
    public string accountRelationName {get; set;}
    public map<string,string> accountIdTypeMap {get; set;}
    public string label_DisplayName {get; set;}
    public set<string> fieldsSet;
    public map<string,string> accountNameMap {get; set;}
    
    /*
        constructor
    */
    public ZTS_EU_DisplayDataGenericController(){
        fieldsList = new list<string>();
        accountIdTypeMap = new map<string,string>();
        accountNameMap = new map<string,string>();
    }
    
    /*
    Method name: getsObjectData
    Desciption: It takes the accountId and fetches the parent account as well as all the accounts which are associated to it via 'Buying group'.
    It queries the records of the object passed in the parameter: 'objNamestring'.
    Arguments: null
    Return type: List <sobject>
    */
    public List<sobject> getsObjectData(){
    
        List<String> accountIdList = new List<String>();
        List<Account> accountListFetched = new List<Account>();
        List<ZTS_EU_Account_Affiliations__c> accountAffiliationListFetched = new List<ZTS_EU_Account_Affiliations__c>();
        
        accountListFetched = [Select Id, ParentId, Parent.Name from Account where Id =: recordId AND ParentId != null AND ZTS_EU_Market__c != 'United States'];
        accountAffiliationListFetched = [Select ZTS_EU_Affiliated_Account__c, ZTS_EU_Account__r.Name, ZTS_EU_Account__c, ZTS_EU_Role__c from ZTS_EU_Account_Affiliations__c where ZTS_EU_Affiliated_Account__c =: recordId AND ZTS_EU_Role__c = 'Corporate' AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ];
        
        for(Account a: accountListFetched){
            accountIdList.add(a.ParentId);
            accountIdTypeMap.put(a.ParentId,System.Label.ZTS_EU_Parent_in_Hierarchy);
            accountNameMap.put(a.ParentId, a.Parent.Name);
        }
        
        for(ZTS_EU_Account_Affiliations__c aff: accountAffiliationListFetched){
            accountIdList.add(aff.ZTS_EU_Account__c);
            accountIdTypeMap.put(aff.ZTS_EU_Account__c,System.Label.ZTS_EU_Buying_Group);
            accountNameMap.put(aff.ZTS_EU_Account__c, aff.ZTS_EU_Account__r.Name);
        }
        
        
        fieldsSet = new Set<String>(fieldsList);
        
        integer numberOfFields = fieldsSet.size();
        integer i = 0;
        string queryString = 'Select ';
        for(string s: fieldsSet){
            i = i + 1;
            
            if(i < numberOfFields ){
                queryString  = queryString + s + ', ';
            }
            else{
                queryString  = queryString + s;
            }
        }
        
        queryString = queryString + ' from ' + objNamestring + ' where ' + accountRelationName + ' IN: accountIdList';
        system.debug('queryString--- ' + queryString);
        
        List<sobject> sObjectList= new List<sobject>();
        sObjectList = Database.query(queryString);
        
        
        return sObjectList;
    }
    

}
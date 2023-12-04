/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-03-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * @last modified by  : Padma @Zoetis 05/14/2022 SC-009378 US Pet Owner Contact custom button on NewCase componenet Added newPetOwnerContactFieldSet
 * @last modified by  : Padma @Zoetis 05/24/2022 SC-009378 US Pet Owner Contact custom button on NewCase componenet Updated RecordType logic
**/
public with sharing class SL_RxNewCaseController  {

    /* public class AccountSapListWrapper {
@AuraEnabled
public Id accountId                         {   get; set;   }
@AuraEnabled
public String strAccountName                {   get; set;   }
@AuraEnabled
public String Accmarket                     {   get; set;   }
@AuraEnabled
public Boolean isSAPNumber                  {   get; set;   }

public AccountSapListWrapper( Id accountId, String strAccountName, String Accmarket, Boolean isSAPNumber) {
this.accountId = accountId;
this.strAccountName = strAccountName;
this.Accmarket = Accmarket;
this.isSAPNumber = isSAPNumber;
}
} */

    @AuraEnabled
    public static Map<String, Object> searchAccounts( String searchTerm ) {
        List<Account> accounts = new List<Account>();
        List<Address__c> lstAddress = new List<Address__c>();
        Map<Account, List<String>> mapAccountToSapNumber = new Map<Account, List<String>>();
        Map<Id, Boolean> mapAccountIdToIsSapNumber = new Map<Id, Boolean>();
        Map<String,Object> mapData = getfieldSetValues('newCaseAccountList', 'Account');

        // List<AccountSapListWrapper> lstAccountSAPWrapper = new List<AccountSapListWrapper>();

        if ( String.isNotBlank( searchTerm ) )
        {
            List<List<SObject>> searchResults = [
                FIND :searchTerm
                RETURNING Account(Id, Name, DMR_ID__c ORDER BY Name LIMIT 10), Address__c(ZTS_US_Source_Account_Number__c, ZTS_EU_Account__c, ZTS_EU_Account__r.Name Where ZTS_EU_Account__c != null)
            ];

            accounts = ((List<Account>)searchResults[0]);

            lstAddress  = ((List<Address__c>)searchResults[1]);

            for(Address__c objAdd : [SELECT Id, ZTS_EU_Account__c, ZTS_US_Source_Account_Number__c
                                     FROM Address__c
                                     WHERE (ZTS_EU_Account__c IN: accounts OR Id IN: lstAddress) ]) {

                                         if(objAdd.ZTS_US_Source_Account_Number__c != null)
                                             mapAccountIdToIsSapNumber.put(objAdd.ZTS_EU_Account__c, True);
                                     }

            String query = 'SELECT Id, Name, ZTS_EU_Market__c, ';
            Set<Id> ids = mapAccountIdToIsSapNumber.keyset();
            query += String.join((List<String>)mapData.get('listAPINames'), ', ');
            query += ' FROM Account WHERE Id IN: accounts OR Id IN: ids';

            List<Account> accountList = Database.query(query);
            List<Id> isSapIds = new List<Id>();

            /* for(Account objAcc : accountList)
{
lstAccountSAPWrapper.add(new AccountSapListWrapper(objAcc.Id, objAcc.Name, objAcc.ZTS_EU_Market__c,mapAccountIdToIsSapNumber.get(objAcc.Id)));
}
return lstAccountSAPWrapper; */

            return new Map<String, Object> {'columns' => mapData.get('listFieldSetValues'),
                'rowdata' => accountList,
                'isSapIds' => ids};
                    }
        return null;
    }

    @AuraEnabled
    public static Map<String, Object> searchContacts( List<Id> lstAccountId ) {

        Map<String,Object> mapData = getfieldSetValues('newCaseContactList', 'Contact');

        String query = 'SELECT Id, Account.Name, Account.ZTS_EU_Market__c, ';
        query += String.join((List<String>)mapData.get('listAPINames'), ', ');

        query += ' FROM Contact WHERE AccountId IN: lstAccountId';

        List<Contact> lstContacts = Database.query(query);

        return new Map<String, Object> {'columns' => mapData.get('listFieldSetValues'),
            'rowdata' => lstContacts};
                }

    /***********
* Method name  : updateRotorTxnsOnAccountUpdate
* Description  : return's the address data related to the selected account
* Return Type  : Map<String, Object>
* Parameters   : String accountId
***********/
    @AuraEnabled
    public static Map<String, Object> fetchSAPNumbers(String accountId) {
        Id recId = (Id)accountId;
        List<Address__c> lstAddress = new List<Address__c>();
        Map<String,Object> mapData = getfieldSetValues('new_Case_SAPNumberList', 'Address__c');
        String query = 'SELECT Id, ';
        query += String.join((List<String>)mapData.get('listAPINames'), ', ');
        if(recId.getSobjectType() == Schema.Contact.SObjectType ) {
            accountId = [SELECT AccountId FROM Contact WHERE Id =: accountId ].AccountId;
        }
        query += ' FROM Address__c WHERE ZTS_EU_Account__c =: accountId AND ZTS_US_Source_Account_Number__c != null';

        lstAddress = Database.query(query);

        return new Map<String, Object> {'columns' => mapData.get('listFieldSetValues'),
            'rowdata' => lstAddress};
                }

    @AuraEnabled
    public static List<Map<String, String>> getCaseRecordType() {
        List<Map<String,string>> lstCaseRecordType = new List<Map<String,string>>();
        Map<Id, RecordType> mapIdToRT = new Map<Id, RecordType>([SELECT Id, Description FROM RecordType WHERE SobjectType = 'Case' AND IsActive = true ]);
        for(RecordTypeInfo objRecordType : Case.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(mapIdToRT.containsKey(objRecordType.getRecordTypeId()) && objRecordType.isAvailable() && objRecordType.getName() != 'Master')
                lstCaseRecordType.add(new Map<String,string>{'label' => objRecordType.getName(),
                    'Id' => objRecordType.getRecordTypeId(),
                    'Description' =>mapIdToRT.get(objRecordType.getRecordTypeId()).Description});
        }

        return lstCaseRecordType;
    }

    @AuraEnabled
    public static Map<String, Object> fetchInitData(String recordId) {

        Map<String, Object> mapValues= new Map<String, Object>();

        if(String.isNotBlank(recordId) && ((Id)recordId).getSobjectType() == Schema.Account.SObjectType) {
            mapValues.put('recordInfo', [SELECT Id, Name, ZTS_EU_Market__c FROM Account WHERE Id =:recordId LIMIT 1][0]);
        }
        if(String.isNotBlank(recordId) && ((Id)recordId).getSobjectType() == Schema.Contact.SObjectType) {
            mapValues.put('recordInfo', [SELECT AccountId, Account.Name, Account.ZTS_EU_Market__c, Name FROM Contact WHERE Id =:recordId LIMIT 1][0]);
        }

        // fetching the newContact related fieldsetValues
        mapValues.put('newContactFieldSet', getfieldSetValues('NewCaseCreateContact', 'Contact').get('listAPINames'));
        mapValues.put('newPetOwnerContactFieldSet', getfieldSetValues('NewCaseCreatePetOwnerContact', 'Contact').get('listAPINames'));
        return mapValues;
    }

    private static Map<String, Object> getfieldSetValues(String fieldSetName, String ObjectName) {
        List<Map<String, Object>> lstFieldSetValues = new List<Map<String, Object>>();
        List<String> lstApiName = new List<String>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            lstApiName.add(fieldSetMemberObj.getFieldPath());
            lstFieldSetValues.add(new Map<String, Object>{'fieldName' => fieldSetMemberObj.getFieldPath(),
                'type' => (fieldSetMemberObj.getType()+'').toLowerCase(),
                'label' => fieldSetMemberObj.getLabel()});
        }
        return new Map<String, Object> { 'listAPINames' => lstApiName,
            'listFieldSetValues' => lstFieldSetValues};
                }


    /***********************************************************
    @method     	fetchRecords
    @brief      	Retrieves Asset/Error Code records based on input paramaters
                    For retrieving assets, account id is used to query
					for retrieving error codes, asset id / consumable id are used. Asset id takes first preference.
					Active Error Codes are filtered on Product Family values on asset/consumable

    @params     	objectName (string); Name of the object to look for
    @params	        filterField(string); Name of the field to filter on
    @params     	searchString (string); input search string
    @params	        accountId(string); Account id to retrieve related assets
    @params     	assetId (string); AssetId to retrieve error codes records
    @params	        consumableId(string); Consumable Id to retrieve error codes records

    @return type	List<RecordsData>

    ***********************************************************/

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString,String accountId, String assetId, String consumableId) {
        String productFamily = (String.isNotBlank(assetId)) ? getProductFamily(assetId,'Asset') :
        (String.isNotBlank(consumableId)) ? getProductFamily(consumableId,'Product2') : '';
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(productFamily != '') query = 'Select Id, Product_Families__c,' + filterField + ' FROM '+objectName ;
            query += ' WHERE '+filterField+
                ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' ';
            if(String.isNotBlank(accountId)) query += ' AND AccountId = :accountId ';
            if(objectName == 'Diagnostics_Error_Codes__c') query += ' AND Active__c = true ';
            query += ' LIMIT 50000';
            for(SObject s : Database.query(query)) {
                if(String.isNotBlank(productFamily)){
                    String families = (String) s.get('Product_Families__c');
                    if(families != null && families.split(';').contains(productFamily)) recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                }else{
                    recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                }
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }

    /***********************************************************
    @class      RecordsData
    @brief      Initializes public variables to hold fetched records.
                label holds record name
                value holds record id

    ***********************************************************/
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

     /***********************************************************
    @method     	getProductFamily
    @brief      	Invoked by fetchRecords method to return product family of an asset or consumable

    @params     	recordId (string); Asset or Consumable Id
    @params	        objectName(string); Asset or Consumable API name

    @return type	String

    ***********************************************************/

    public static string getProductFamily(string recordId, string objectName){
        String productFamily ='';
        // asset : Product2.Diagnostics_Product_Family__c
        // consumable : Diagnostics_Product_Family__c
        String fieldName = (objectName=='Asset') ? 'Product2.Diagnostics_Product_Family__c' :'Diagnostics_Product_Family__c';
        String query = 'SELECT Id, '+fieldName+' FROM '+objectName + ' where Id =:recordId ';
        if(objectName=='Asset'){
            Asset asset = Database.query(query);
            productFamily = asset.Product2.Diagnostics_Product_Family__c;
        }else{
            Product2 prod = Database.query(query);
            productFamily = prod.Diagnostics_Product_Family__c;
        }
        return productFamily;
    }
    
    /***********************************************************
    @method     	getPetOwnerRecTypeId
    @brief      	returns recordType-US Pet Owner
    @return type	String
	***********************************************************/
    @AuraEnabled(cacheable=true)
    public static String getPetOwnerRecTypeId(){
        string recordType = '';
        String objectApiName = 'Contact';
        if(!String.isBlank(objectApiName)){
            for(Schema.RecordTypeInfo recTypeInfo : Schema.getGlobalDescribe().get(objectApiName).getDescribe().getRecordTypeInfosByName().values()){
                if(recTypeInfo.isAvailable() && recTypeInfo.getDeveloperName().equalsIgnoreCase('ZTS_US_Pet_Owner') 
                  && recTypeInfo.isActive()) {
                    recordType = recTypeInfo.getRecordTypeId();
                    break;
                }
            }
        }
        return recordType;
    }
    
    /***********************************************************
    @method     	isPetOwnerAvailable
    @brief      	returns boolean true if Pet Owner record type available else false
    @return type	boolean
	***********************************************************/
    @AuraEnabled(cacheable=true)
    public static boolean isPetOwnerAvailable(){
        boolean isPetOwner = false;
        String recordType = getPetOwnerRecTypeId();
        if(String.isEmpty(recordType)){
            isPetOwner = false;
        } else {
            isPetOwner = true;
        }
        return isPetOwner;
    }
    
    //Aritra created this method to associate the alllow duplicate contact record creation (SC-008149)
    /***********************************************************
    @method     	createDuplicateRecord
    @brief      	Invoked to create Duplicate Records
    @params     	sObjectRecord (string); Object JSON converted to String
    @params	        objectName(string); Object API Name
    @return type	String

    ***********************************************************/
    
     @AuraEnabled 
    public static String createDuplicateRecord(String sObjectRecord, String objectName){
        String returnVal = 'ERROR';
        SObject recToInsert;
        switch on objectName {
            when 'Contact'
            {
                recToInsert= (Contact)JSON.deserialize(sObjectRecord, Contact.class);
            }
            when 'Call__c'
            {
                recToInsert= (Call__c)JSON.deserialize(sObjectRecord, Call__c.class);
            }
        }
        Database.saveResult sr2;
        Database.DMLOptions dml =  new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        try{
            sr2 = Database.insert(recToInsert, dml);
        }
        catch (DMLException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug('$$$ dex.getDmlMessage(i): '+dex.getDmlMessage(i));
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        catch (Exception ex) {
          throw new AuraHandledException(ex.getMessage());
            
        }
        if(sr2.isSuccess())
        {
            returnVal = recToInsert.Id ;
            Id recId = (Id.valueOf(returnVal));
            String sobjectType = recId.getSObjectType().getDescribe().getName();
            if(sobjectType == 'Contact')
            {
                Contact c = [Select FirstName, LastName from Contact where Id = :recId limit 1];
                returnVal = returnVal + '||'+ c.FirstName+ ' ' + c.LastName;  
            }
        }
        return returnVal;
    }
    //Aritra created this method to return the matching contact details (SC-008149)
    @AuraEnabled(cacheable=true)
    public static List<Contact> getMatchingContactDetails(String selectedIdsJson) {
        List<String> selectedIds = (List<String>)JSON.deserialize(selectedIdsJson,List<String>.class);
        System.debug('selectedIds -->'+selectedIds);
        List<Contact> lstCon = [Select Id, Name, Account_Name__c, Full_Contact_Name__c, Interface_Email__c, Phone,ZTS_US_Profession__c,ZTS_US_Job_Function__c,ZTS_EU_Contact_Status__c from Contact where id in :selectedIds];
         System.debug('lstCon -->'+lstCon);
        return lstCon;
    }

}
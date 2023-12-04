/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_DisplayContractsController
* Description   :  This is the controller of the vf page: ZTS_EU_DisplayContracts.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     15th-Oct-14   Shreyas             Created the class.

********************************************************************************************************************************************/

public class ZTS_EU_DisplayContractsController {

    
    public Account accountObj {get; set;}
    public list<string> fieldAPIList {get; set;}
    public string accountRelationId {get; set;}
    public string label_DisplayName {get; set;}
    public List<Schema.FieldSetMember> fieldSetMemberList = new List<Schema.FieldSetMember>();
    
    /*
        Constructor
    */
    public ZTS_EU_DisplayContractsController(ApexPages.StandardController controller) {

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType contractSchema = schemaMap.get('Contract');
        Map<String, Schema.SObjectField> fieldMap = contractSchema.getDescribe().fields.getMap();
        label_DisplayName = fieldMap.get('Name').getDescribe().getLabel();
        
        accountRelationId = 'AccountId';
        fieldAPIList = new list<String>();
        fieldSetMemberList = new List<Schema.FieldSetMember>();
        fieldSetMemberList = SObjectType.Contract.FieldSets.ZTS_EU_Contract_Field_Set.getFields();
        
        
        for(Schema.FieldSetMember s: fieldSetMemberList){
            fieldAPIList.add(s.getFieldPath());
        }
        fieldAPIList.add(accountRelationId);
    }

}
/*************************************************************************************
* Name          :    DxPrimaryErrorLookupController
* Description   :    Controller for adding Asset/Primary Consumable/Error Code from diagnosticsPrimaryErrorSelection LWC component
* Author        :    Karim Abdelrazek
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
08/22/2022       Karim Abdelrazek         Created
06/28/2023       Sourav Mitra             Changed Primary Consumable(Product Lookup) to Primary Consumable(Product Hierarchy Lookup)

**************************************************************************************/
public with sharing class DxPrimaryErrorLookupController {

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> searchPrimaryErrorCodes(String searchTerm, Id assetId, Id primaryConsumableId){ 
        List<LookupSearchResult> searchResults = new List<LookupSearchResult>();
        List<String> relatedProductFamilies = new List<String>(getRelatedProductFamilies(assetId,primaryConsumableId));
        if(relatedProductFamilies.isEmpty()){
            return searchResults;
        }
        

        String searchKey  =  searchTerm.trim() + '%';        
        String queryString = 'SELECT Id, Name FROM Diagnostics_Error_Codes__c WHERE  Active__c = true AND Product_Families__c INCLUDES '  + concatStrings(relatedProductFamilies) ;
         if(searchTerm != 'all'){
            queryString += ' AND Name LIKE:searchKey ';
         }
         queryString += ' LIMIT 50000';
        List<Diagnostics_Error_Codes__c> errorCodes  = Database.query(queryString);
        
        for(Diagnostics_Error_Codes__c errCode : errorCodes){
            LookupSearchResult  newResult = new LookupSearchResult(errCode.Id,'Diagnostics_Error_Codes__c','custom:custom18', errCode.Name, '');
            searchResults.add(newResult);
        }
        return searchResults; 
    }

    public static String concatStrings(List<String> strings){
        String queryCondition = '(\''+String.join(strings, '\',\'')+'\')';
        return queryCondition;
    }


    @AuraEnabled
    public static DataResult fetchData(Id caseId){
        Case currentCase = [SELECT 	AssetId, ZTS_US_Primary_Consumable__c, Primary_Error_Code__c, Primary_Error_Code__r.Name FROM Case WHERE Id =:caseId];
        return new DataResult(currentCase);
    }

    @AuraEnabled
    public static void saveCase(Id caseId, Id assetId, Id primaryConsumableId, Id errorCodeId){
        update new Case(Id = caseId, AssetId = assetId, ZTS_US_Primary_Consumable__c = primaryConsumableId, Primary_Error_Code__c = errorCodeId);
    }

    public static string getProductFamily(string recordId, string objectName){
        String productFamily ='';
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

    public static Set<String> getRelatedProductFamilies(Id assetId, Id consumableId){
        Set<String> productFamilies = new Set<String>();
        if(assetId != null){
            String assetProductFamily  = getProductFamily(assetId,'Asset');
            productFamilies.add(assetProductFamily);
            
        }
        if(consumableId != null){
            String consumableProductFamily  = getProductFamily(consumableId,'Product2');
            productFamilies.add(consumableProductFamily);        
        }
        return productFamilies;
    }

    public class DataResult{
        @AuraEnabled public Id assetId;
        @AuraEnabled public Id primaryConsumableId;
        @AuraEnabled public Diagnostics_Error_Codes__c primaryErrorCode;
        @AuraEnabled public LookupSearchResult initialPrimaryErrorCode;

        public DataResult(Case caseRecord){
            this.assetId = caseRecord.AssetId;
            this.primaryConsumableId  = caseRecord.ZTS_US_Primary_Consumable__c;
            this.primaryErrorCode = new Diagnostics_Error_Codes__c(Id = caseRecord.Primary_Error_Code__c, Name = caseRecord.Primary_Error_Code__r.Name);
            if(this.primaryErrorCode.Id != null){

                initialPrimaryErrorCode = new LookupSearchResult(this.primaryErrorCode.Id, 'Diagnostics_Error_Codes__c','custom:custom18',this.primaryErrorCode.name, 'initial subtitle');
            }
        }
    }




}
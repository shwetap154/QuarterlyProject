/**
* File Name     :  ProductDescriptionTriggerHandler
* @description  :  Handler class for Product_Description__c trigger.
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group.
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0	  2/27/2020     Cesar Sandrigo @ ATG	Created the class.
*/
public class ProductDescriptionTriggerHandler {
    
    /**
     * @description Handles the After Insert trigger event.
     * @param   newList The new list provided by the trigger.
     */
    public void handleAfterInsert(List<Product_Description__c> newList) {
        updateMaterialProdDescLastModifiedDate(newList);
    }

    /**
     * @description Handles the After Update trigger event.
     * @param   newList The new list provided by the trigger.
     */
    public void handleAfterUpdate(List<Product_Description__c> newList) {

        // Update the 'Description Last Modified Date' in the related Material records.
        updateMaterialProdDescLastModifiedDate(newList);
    }

    /**
     * @description Updates the 'Description Last Modified Date' in the SAP Material records
     *              related to the Product Descriptions received as parameter.
     * @param   prodDescriptionList Product Description records to be processed.
     */
    private void updateMaterialProdDescLastModifiedDate(List<Product_Description__c> prodDescriptionList) {

        Set<Id> materialIdsToUpdate = new Set<Id>();

        for (Product_Description__c prodDesc : prodDescriptionList) {
            if (prodDesc.SAP_Material__c != null && !materialIdsToUpdate.contains(prodDesc.SAP_Material__c)) {
                materialIdsToUpdate.add(prodDesc.SAP_Material__c);
            }
        }

        List<SAP_Material__c> materialsToUpdate = new List<SAP_Material__c>();

        Datetime now = Datetime.now();

        for (Id materialId : materialIdsToUpdate) { 
            materialsToUpdate.add(
                new SAP_Material__c(
                    Id = materialId,
                    Description_Last_Modified_Date__c = now
                )
            );
        }

        Database.SaveResult[] materialSaveResults = Database.update(materialsToUpdate, false);
        ErrorLogUtil.handleSaveResults('Failed to update [Description Last Modified Date] for Materials', materialSaveResults);
        ErrorLogUtil.commitLogs();
    }
}
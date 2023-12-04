/**
* @ClassName    : SL_SampleFromProductsBatch
* @JIRATicket   : LIGHTNI-1682
* @CreatedOn    : 10th Oct 2019
* @CreatedBy    : Premraj K K
* @ModifiedBy   : 
* @Description  : Batch job that creates Sample records for Contacts based on Product-Hierarchy
*/
public class SL_SampleFromProductsBatch implements Database.Batchable<sObject> {
    
    private String productId;
    
    public SL_SampleFromProductsBatch(String productId) {
        this.productId = productId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id FROM Contact ' + 
            'Where ZTS_EU_Contact_type__c = \'Veterinarian\' AND ZTS_EU_Market__c = \'Italy\' '
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        if(String.isNotBlank(productId))
            SL_SampleCreationHelper.createSampleRecords(scope, new List<Id>{productId});
        else
            SL_SampleCreationHelper.createSampleRecords(scope, new List<Id>());
        
    }
    public void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}
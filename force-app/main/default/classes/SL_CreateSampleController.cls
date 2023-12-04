/**
* @ClassName    : SL_CreateSampleController
* @JIRATicket   : LIGHTNI-1684
* @CreatedOn    : 13th Oct 2019
* @CreatedBy    : Premraj K K
* @ModifiedBy   : 
* @Description  : Controller class for the Create Sample button for both Contact and Product Hierarchy
*/
public class SL_CreateSampleController {
	
    @AuraEnabled
    public static void createSamples(Id recordId) {
        
        String objName = recordId.getSObjectType().getDescribe().getName();
        if(objName == 'Contact') {
            
            Contact objContact = [Select Id, ZTS_EU_Contact_type__c, ZTS_EU_Market__c
                                  From Contact
                                  Where Id =: recordId];
            if(objContact.ZTS_EU_Contact_type__c == 'Veterinarian' && objContact.ZTS_EU_Market__c == 'Italy') {
                //Pass the corressponding Contact to create Sample records
                SL_SampleCreationHelper.createSampleRecords(new List<Contact>{objContact}, new List<Id>());
            }
            else
                throw new AuraException('Samples cannot be created for this record. Please contact your administrator.');
        }
        else if(objName == 'ZTS_EU_Species_Product__c') {
            
            ZTS_EU_Species_Product__c prod = [Select Id, ZTS_EU_Market__c, ZTS_EU_is_Samplable__c
                                              From ZTS_EU_Species_Product__c
                                              Where Id =: recordId];
            
            if(prod.ZTS_EU_Market__c == 'Italy' && prod.ZTS_EU_is_Samplable__c) {
                //Execute the batch for a specific Product ID to create Samples for all the contacts
                SL_SampleFromProductsBatch batch = new SL_SampleFromProductsBatch(recordId); 
                Database.executeBatch(batch);
            }
            else
                throw new AuraException('Samples cannot be created for this record. Please contact your administrator.');
        }
    }
}
/**
* @ClassName    : SL_PrimaryAccountOfContact 
* @JIRATicket   : LIGTHTNI-36
* @CreatedOn    : 28th March 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Controller to fetch the address to make the Primary address of the record.
*/
public  with sharing class SL_PrimaryAccountOfContact 
{
    /***********
      * Method name  : fetchAddress
      * Description  : This method will  make the primary address for the Contact and assign ZTS_EU_Affiliations__c as true.
      * Return Type  : NA
      * Parameters   : String strRecordId.
    ***********/ 
    @AuraEnabled
    public static String fetchAddress(String strRecordId)
    {
        ZTS_EU_Affiliations__c objAffiliation = [Select Id, ZTS_EU_Contact__c, ZTS_EU_Account__c 
                                                   From ZTS_EU_Affiliations__c 
                                                   Where Id =: strRecordId AND ZTS_EU_Market_from_Parent__c != 'United States'];
                                                   
        Contact objContact = new Contact(Id = objAffiliation.ZTS_EU_Contact__c, AccountId = objAffiliation.ZTS_EU_Account__c);
        
        Account objAccount = new Account(Id = objAffiliation.ZTS_EU_Account__c);
        
        List<Address__c> lstAddress = [Select Id,ZTS_EU_Primary_Address__c From Address__c 
                                                            Where ZTS_EU_Account__c =: objAffiliation.ZTS_EU_Account__c 
                                                                And ZTS_EU_Primary_Address__c =: true];

        for(Address__c objAdd : lstAddress)
            objContact.ZTS_EU_Primary_Address__c = objAdd.Id;
        
        List<Database.SaveResult> dbResultList = Database.update(new List<Contact>{objContact}, false);
        Integer numFailed, numSucceeded = 0; 
        String strMessage = '';
        
        for(Database.SaveResult result : dbResultList)
        {
            if (result.isSuccess())
                numSucceeded++; 
            else 
            { 
                for(Database.Error err : result.getErrors()) 
                     return err.getMessage();
                numFailed++; 
            } 
            
            if(numFailed > 0)
                strMessage = 'Failed: ' + numFailed + '\nSucceeded: ' + numSucceeded + ' \n Due to: ' + String.join(result.getErrors(), '\n');
        }
        
        return strMessage;
    }
}
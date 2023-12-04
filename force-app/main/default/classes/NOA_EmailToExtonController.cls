public class NOA_EmailToExtonController {
    public Lead newOnlineAcc {get;set;}
    public ID LeadID{get;set;}
    public List<Account> existingAccts {get; set;}
    public string loadData{
    get{
        return loadNOA();
    }
    set;}
    public String baseURL{get;set;}
    public String formType {get;set;}
    
    public String loadNOA(){
        if(newOnlineAcc != null){
            return null;
        }
        baseURL = ZoetisForSheltersSettings__c.getInstance().sf_base_url__c;
        if(newOnlineAcc ==NULL)
            newOnlineAcc = new Lead();
        for(Lead l : [SELECT Id,Name,FirstName,LastName,NOA_Application_Number__c, Step_Number__c,Email,Phone,Company,Business_Name__c,
                      Shipping_Street_1__c, Shipping_Street_2__c,   Shipping_County__c, Shipping_City__c,   Shipping_State__c,  
                      Shipping_Zip_Code__c, Shipping_Phone__c,  Shipping_Fax__c,    Shipping_Email__c,  Billing_Street_1__c,    
                      Billing_Street_2__c,  Billing_County__c,  Billing_City__c,    Billing_State__c,   Billing_Zip_Code__c,    
                      Billing_Phone__c, Billing_Fax__c, Billing_Email__c,   Existing_account_with_Zoetis_at_this_Loc__c,Existing_account_with_Zoetis__c,
                      Existing_Account_Name__c, Zoetis_Account__c,RecordTypeId from Lead where id =:LeadID AND Market__c = 'United States']){
                          newOnlineAcc = l;
        }
        Id vetRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        Id DiagRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Diagnostic_or_Reproduction').getRecordTypeId();
        if(vetRecTypeId == newOnlineAcc.RecordTypeId){
            formType = 'Basic';
            
        }else if(DiagRecTypeId == newOnlineAcc.RecordTypeId){
            formType = 'Diagnostics';
        } 
        
        String noaAcctName = Null;
        if(!String.isBlank(newOnlineAcc.Existing_Account_Name__c)){
            noaAcctName = '%' + newOnlineAcc.Existing_Account_Name__c + '%';
            existingAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                             BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                             FROM Account WHERE ( Name like :noaAcctName ) AND ZTS_EU_Market__c = 'United States'  Limit 10];
            }
            List<Address__c> accAddrs =  [SELECT id,ZTS_EU_Account__c,ZTS_EU_Account__r.Name,ZTS_US_Source_Account_Number__c,
                                          ZTS_Address_Line_1__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Type__c,ZTS_EU_City__c,ZTS_County__c,
                                          ZTS_US_State_Province__c,Zip_Postal_Code__c,ZTS_US_Primary__c 
                                          FROM Address__c  WHERE ( (ZTS_US_Source_Account_Number__c != null AND ZTS_US_Source_Account_Number__c = :newOnlineAcc.Zoetis_Account__c)  
                                                                  OR ((ZTS_EU_Address_Type__c LIKE '%Primary%' OR ZTS_EU_Address_Type__c LIKE '%Bill%' OR ZTS_EU_Address_Type__c LIKE '%Ship%') 
                                                                      AND( (ZTS_Address_Line_1__c = :newOnlineAcc.Billing_Street_1__c AND ZTS_EU_City__c = :newOnlineAcc.Billing_City__c 
                                                                            AND ZTS_US_State_Province__c = :newOnlineAcc.Billing_State__c AND Zip_Postal_Code__c = :newOnlineAcc.Billing_Zip_Code__c)
                                                                          OR (ZTS_Address_Line_1__c = :newOnlineAcc.Shipping_Street_1__c AND ZTS_EU_City__c = :newOnlineAcc.Shipping_City__c 
                                                                              AND ZTS_US_State_Province__c = :newOnlineAcc.Shipping_State__c AND Zip_Postal_Code__c = :newOnlineAcc.Shipping_Zip_Code__c)
                                                                         )  
                                                                     )
                                                                 )
                                          Limit 20];
           if(accAddrs != Null || accAddrs.size() > 0){
               List<ID> accID = new List<ID>();
               for(Address__c ad : accAddrs){
                   accID.add(ad.ZTS_EU_Account__c);
               }
               List<Account> additionalAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                                BillingCountry,ZFS_Status__c FROM Account WHERE id in :accID AND ZTS_EU_Market__c = 'United States'];
                if(additionalAccts != Null || additionalAccts.size() > 0){
                    if(existingAccts == Null){
                        existingAccts = new List<Account>();
                    }
                    existingAccts.addAll(additionalAccts);
                }
           }                               
        
        
        return null;
    }
}
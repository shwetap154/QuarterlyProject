public class ZFS_EmailToExtonController{
    public Id shelterId{get;set;}
    public Lead shelter{get;set;}
    public List<Account> existingAccts {get; set;}
    public string loadData{
    get{
        return loadShelter();
    }
    set;}
    public String baseURL{get;set;}
        
    public String loadShelter(){
        baseURL = ZoetisForSheltersSettings__c.getInstance().sf_base_url__c;
        if(shelter==null)
            shelter = new Lead();
        for(Lead l:[SELECT Id,Salutation, FirstName, LastName, Email, Phone, MobilePhone, Shelter_Name__c, Shelter_Website__c, Existing_account_with_Zoetis__c, 
                    Account_Prefix__c, Account_First_Name__c, Account_Last_Name__c, Shelter_Account_Name__c, Zoetis_Account__c, Shelter_Application_Number__c, 
                    Billing_Street_1__c,Billing_Street_2__c,Billing_City__c,Billing_County__c,Billing_Country__c,Billing_State__c,Billing_Zip_Code__c,
                    Shipping_Address_Type__c,Shipping_Street_1__c,Shipping_Street_2__c,Shipping_City__c,Shipping_County__c,Shipping_Country__c,Shipping_State__c,
                    Shipping_Zip_Code__c from Lead where Id=:shelterId AND Market__c = 'United States'])
            shelter = l;
        
        
        //Start of CR changes for account match
        String shelterAcctName = null;
        if(!String.isBlank(shelter.Shelter_Account_Name__c)){
            shelterAcctName = '%' + shelter.Shelter_Account_Name__c + '%';
            existingAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                             BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                             FROM Account WHERE ( Name like :shelterAcctName ) AND ZTS_EU_Market__c = 'United States' Limit 10];  
            
            List<Address__c> accAddrs =  [SELECT id,ZTS_EU_Account__c,ZTS_EU_Account__r.Name,ZTS_US_Source_Account_Number__c,
                                          ZTS_Address_Line_1__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Type__c,ZTS_EU_City__c,ZTS_County__c,
                                          ZTS_US_State_Province__c,Zip_Postal_Code__c,ZTS_US_Primary__c 
                                          FROM Address__c  WHERE (ZTS_US_Source_Account_Number__c = :shelter.Zoetis_Account__c  
                                                                  OR ((ZTS_EU_Address_Type__c LIKE '%Primary%' OR ZTS_EU_Address_Type__c LIKE '%Bill%' OR ZTS_EU_Address_Type__c LIKE '%Ship%') 
                                                                      AND( (ZTS_Address_Line_1__c = :shelter.Billing_Street_1__c AND ZTS_EU_City__c = :shelter.Billing_City__c 
                                                                            AND ZTS_US_State_Province__c = :shelter.Billing_State__c AND Zip_Postal_Code__c = :shelter.Billing_Zip_Code__c)
                                                                          OR (ZTS_Address_Line_1__c = :shelter.Shipping_Street_1__c AND ZTS_EU_City__c = :shelter.Shipping_City__c 
                                                                              AND ZTS_US_State_Province__c = :shelter.Shipping_State__c AND Zip_Postal_Code__c = :shelter.Shipping_Zip_Code__c)
                                                                         )  
                                                                     )
                                                                 )
                                          Limit 20];       
            if(accAddrs != null && accAddrs.size() > 0){
                List<Id> accIds = new List<Id>();
                for(Address__c ad : accAddrs){
                    accIds.add(ad.ZTS_EU_Account__c);
                }
                List <Account> additionalAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,ZFS_Status__c 
                                                  FROM Account WHERE id in :accIds AND ZTS_EU_Market__c = 'United States'];
                if(additionalAccts != null && additionalAccts.size() > 0){
                    if(existingAccts == null){
                        existingAccts = new List<Account>();
                    }
                    existingAccts.addAll(additionalAccts); 
                }
            }

        }
        //End of CR changes for account match
        
        /*
        //checking billing address match
        String shelterAccName = null;
        if(!String.isBlank(shelter.Shelter_Account_Name__c)){
            shelterAccName = '%' + shelter.Shelter_Account_Name__c + '%';
            existingAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                             BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                             FROM Account WHERE ( Name like :shelterAccName )
                             OR ( BillingStreet = :shelter.Billing_Street_1__c AND BillingCity = :shelter.Billing_City__c 
                                   AND BillingState = :shelter.Billing_State__c AND BillingPostalCode = :shelter.Billing_Zip_Code__c)
                             OR ( ShippingStreet = :shelter.Shipping_Street_1__c AND ShippingCity = :shelter.Shipping_City__c 
                                  AND ShippingState = :shelter.Shipping_State__c AND ShippingPostalCode = :shelter.Shipping_Zip_Code__c)
                             AND ZTS_EU_Market__c = 'United States'
                             Limit 10];  
        } else{
            existingAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                             BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                             FROM Account WHERE 
                                 ( BillingStreet = :shelter.Billing_Street_1__c AND BillingCity = :shelter.Billing_City__c 
                                AND BillingState = :shelter.Billing_State__c AND BillingPostalCode = :shelter.Billing_Zip_Code__c) 
                              OR ( ShippingStreet = :shelter.Shipping_Street_1__c AND ShippingCity = :shelter.Shipping_City__c 
                                  AND ShippingState = :shelter.Shipping_State__c AND ShippingPostalCode = :shelter.Shipping_Zip_Code__c)
                             AND ZTS_EU_Market__c = 'United States'
                             Limit 10];  
        }
    
        //checking SAP# match
        if(shelter.Zoetis_Account__c != null){
            List<Address__c> accAddrs =  [select id,ZTS_EU_Account__c,ZTS_EU_Account__r.Name,ZTS_US_Source_Account_Number__c 
                                          from Address__c  where ZTS_US_Source_Account_Number__c = :shelter.Zoetis_Account__c Limit 10];       
            if(accAddrs != null && accAddrs.size() > 0){
                List<Id> accIds = new List<Id>();
                for(Address__c ad : accAddrs){
                    accIds.add(ad.ZTS_EU_Account__c);
                }
                List <Account> additionalAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                                                  FROM Account WHERE id in :accIds AND ZTS_EU_Market__c = 'United States'];
                if(additionalAccts != null && additionalAccts.size() > 0){
                    if(existingAccts == null){
                        existingAccts = new List<Account>();
                    }
                    existingAccts.addAll(additionalAccts); 
                }
            }
        }   */
            
    return ''; 
    
    }
     
}
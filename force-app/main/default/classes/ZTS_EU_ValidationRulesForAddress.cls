/*************************************************************************************************************************
  Class Name     : ZTS_EU_ValidationRulesForAddress
  Description    : This class is called from trigger on Address for validation of Postal Code and State fields
  Created By     : Teresa Sebastian
  Created On     : 03/06/2014
  
***************************************************************************************************************************/
public class ZTS_EU_ValidationRulesForAddress
{
       
   /***********
        * Method name  : validationRuleForAddress
        * Description  : This will validate whether Postal Code and State fields are mandatory for all coutries except that
        * it is not mandatory for 
        * Spain/Ireland - Postal Code
        * France - State
        * Return Type  : Boolean( true - if record is ready to insert).
        * Parameters   : trigger parameters.
    ***********/
    
 /*   public static void validateAddressFields(List<Address__c> triggerNew)
    {
         // get all the countries for which postal code is not mandatory
         ZTS_Mandatory_Fields_Settings__c notMandCountriesForPC = ZTS_Mandatory_Fields_Settings__c.getValues('PostalCode');
         String postalCodeCountries = notMandCountriesForPC.ZTS_EU_Not_Mandatory_Country__c;
         List<String> postalcountries = postalCodeCountries.split(',');
            
         // get all the countries for which state is not mandatory
         ZTS_Mandatory_Fields_Settings__c notMandCountriesForState = ZTS_Mandatory_Fields_Settings__c.getValues('State');
         String stateCountries = notMandCountriesForState.ZTS_EU_Not_Mandatory_Country__c;
         List<String> stateCountry = stateCountries.split(',');
    
        
        for(Address__c address: triggerNew)
        {
          Boolean postalCodeValidate = true;
          Boolean stateValidate = true;  
          
          if (address.ZTS_EU_Country__c != Null)
          {
               for(String country : postalcountries ){
                   if(address.ZTS_EU_Country__c == country)
                       postalCodeValidate = false;
                       break;
               }
               if(postalCodeValidate){
                   if(address.Zip_Postal_Code__c == null || address.Zip_Postal_Code__c.trim().length() == 0){
                      address.addError('Please enter required field : Zip/Postal Code');
                   }
               }
           }
          if (address.ZTS_EU_Country__c != Null)
            {
                for(String country : stateCountry){
                   if(address.ZTS_EU_Country__c == country)
                       stateValidate = false;
                       break;
               }
               if(stateValidate){
                   if(address.ZTS_EU_State_County__c== null){
                     address.addError('Please enter required field : State/County');
                   }
               }
            } 
               
        
        }
     
     }
     
     public static void validateAddressAccountFields(List<Account> triggerNew)
    {
         // get all the countries for which postal code is not mandatory
         ZTS_Mandatory_Fields_Settings__c notMandCountriesForPC = ZTS_Mandatory_Fields_Settings__c.getValues('PostalCode');
         String postalCodeCountries = notMandCountriesForPC.ZTS_EU_Not_Mandatory_Country__c;
         List<String> postalcountries = postalCodeCountries.split(',');
            
         // get all the countries for which state is not mandatory
         ZTS_Mandatory_Fields_Settings__c notMandCountriesForState = ZTS_Mandatory_Fields_Settings__c.getValues('State');
         String stateCountries = notMandCountriesForState.ZTS_EU_Not_Mandatory_Country__c;
         List<String> stateCountry = stateCountries.split(',');
    
        
        for(Account address: triggerNew)
        {
          Boolean postalCodeValidate = true;
          Boolean stateValidate = true;  
          
          if (address.ZTS_EU_Country__c != Null)
          {
               for(String country : postalcountries ){
                   if(address.ZTS_EU_Country__c == country)
                       postalCodeValidate = false;
                       break;
               }
               if(postalCodeValidate){
                   if(address.ZTS_EU_Zip_Postal_Code__c == null || address.ZTS_EU_Zip_Postal_Code__c.trim().length() == 0){
                      address.addError('Please enter required field : Zip/Postal Code');
                   }
               }
           }
          if (address.ZTS_EU_Country__c != Null)
            {
                for(String country : stateCountry){
                   if(address.ZTS_EU_Country__c == country)
                       stateValidate = false;
                       break;
               }
               if(stateValidate){
                   if(address.ZTS_EU_State_County__c== null){
                      address.addError('Please enter required field : State/County');
                   }
               }
            } 
               
        
        }
        
       
      
     }*/
     
     /***********
        * Method name  : validationRuleForAddressType
        * Description  : This will validate whether Address being added is having a Address Type already added against account or contact
        
    ***********/
    
   /* public static void validationRuleForAddressType(List<Address__c> triggerNew)
    {
        system.debug('Do I reach here**********'+triggerNew);
        List<String> accountId = new List<String>();
        List<String> contactId = new List<String>();
        for(Address__c address: triggerNew)
        { 
            if(address.ZTS_EU_Account__c != null){
                accountId.add(address.ZTS_EU_Account__c);
            }
            else if(address.ZTS_EU_Contact__c != null){
                contactId.add(address.ZTS_EU_Contact__c);
            }
        }
        // querying from object all the addresses for the accounts come in from trigger.new
        List<Address__c> accountAddress = [select Id,ZTS_EU_Address_Type__c,ZTS_EU_Account__c from Address__c where ZTS_EU_Account__c IN :accountId AND Id NOT IN :triggerNew];
        
        // creating a map with accountId and AddressTypes already in database
        Map<String,Set<String>> mapAcctAddressType = new Map<String,Set<String>>();
        
        
        // Looping through queried results and assigning to map key -> AccountId, value -> List of String(AddressTypes)
        // already configured for the said account
        for(Address__c addr : accountAddress){
            Set<String> addType = new Set<String>();
            if(mapAcctAddressType.get(addr.ZTS_EU_Account__c) != null){
                addType = mapAcctAddressType.get(addr.ZTS_EU_Account__c);
                addType.add(addr.ZTS_EU_Address_Type__c);
                mapAcctAddressType.put(addr.ZTS_EU_Account__c,addType);
            } else {
                addType.add(addr.ZTS_EU_Address_Type__c);
                mapAcctAddressType.put(addr.ZTS_EU_Account__c,addType);
            }
        }
        
        // Looping through all Address on which upsert or insert is done to restrict An account having two addresses //of the same type
        for(Address__c address: triggerNew)
        {
            if(mapAcctAddressType.get(address.ZTS_EU_Account__c) != null){
                Set<String> addTypes = mapAcctAddressType.get(address.ZTS_EU_Account__c);
                if(addTypes.contains(address.ZTS_EU_Address_Type__c)){
                    address.addError('An account cannot have two addresses of the same type');
                }else{
                    addTypes.add(address.ZTS_EU_Address_Type__c);
                }
            }
        }
        
     // querying from object all the addresses for the contacts come in from trigger.new
        List<Address__c> contactAddress = [select Id,ZTS_EU_Address_Type__c,ZTS_EU_Contact__c from Address__c where ZTS_EU_Contact__c IN :contactId AND Id NOT IN :Trigger.new];
        
    // creating a map with contactIds and AddressTypes already in database
        Map<String,Set<String>> mapContAddressType = new Map<String,Set<String>>();
        
     
     // Looping through queried results and assigning to map key -> Contactid, value -> List of String(AddressTypes)
        // already configured for the said account
        for(Address__c addr : contactAddress){
            Set<String> addType = new Set<String>();
            if(mapContAddressType.get(addr.ZTS_EU_Contact__c) != null){
                addType = mapContAddressType.get(addr.ZTS_EU_Contact__c);
                addType.add(addr.ZTS_EU_Address_Type__c);
                mapContAddressType.put(addr.ZTS_EU_Contact__c,addType);
            } else {
                addType.add(addr.ZTS_EU_Address_Type__c);
                mapContAddressType.put(addr.ZTS_EU_Contact__c,addType);
            }
        }
        
        // Looping through all Address on which upsert or insert is done to restrict a contact having two addresses //of the same type
        for(Address__c address: triggerNew)
        {
            if(mapContAddressType.get(address.ZTS_EU_Contact__c) != null){
                Set<String> addTypes = mapContAddressType.get(address.ZTS_EU_Contact__c);
                if(addTypes.contains(address.ZTS_EU_Address_Type__c)){
                    address.addError('An account cannot have two addresses of the same type');
                }else{
                    addTypes.add(address.ZTS_EU_Address_Type__c);
                }
            }
        }
     }*/
  
}
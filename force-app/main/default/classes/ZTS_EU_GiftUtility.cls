/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_GiftUtility
* Description   :  This is the utility class for triggers on Gift object.

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     31st-Dec-14   Shreyas             Created the class.

********************************************************************************************************************************************/
Public class ZTS_EU_GiftUtility{


    public static string productName = '';
    /*
        Name: populateYear
        Purpose: to populate the current year on the Gift records 
        Argument: List<ZTS_EU_Gift__c>
        Return type: none
    */
    public static void populateYear(List<ZTS_EU_Gift__c> gftList){
    
        integer currentYear = System.Today().year();
        string currentYearString = string.valueof(currentYear);
        
        for(ZTS_EU_Gift__c gft: gftList){
            gft.ZTS_EU_Year__c = currentYearString;
            gft.ZTS_EU_Is_Current_Year_Gift__c = True;
        }
    }
    
    /*
        Name: populateCurrentYearCheckbox
        Purpose: to populate the current year checkbox on the Gift. Set to true if the year matches current year. 
        Argument: List<ZTS_EU_Gift__c>
        Return type: none
    */
    public static void populateCurrentYearCheckbox(List<ZTS_EU_Gift__c> gftList){
    
        integer currentYear = System.Today().year();
        string currentYearString = string.valueof(currentYear);
        
        for(ZTS_EU_Gift__c gft: gftList){
        
            if(gft.ZTS_EU_Year__c == currentYearString){
                gft.ZTS_EU_Is_Current_Year_Gift__c = True;
            }
            else{
                gft.ZTS_EU_Is_Current_Year_Gift__c = False;
            }
            
        }
    }
    
    /*
        Name: populateGiftValue
        Purpose: to populate the Gift value and Gift Type from the selected product to the gift record. 
        Argument: List<ZTS_EU_Gift__c>
        Return type: none
    */
    public static void populateGiftValue(List<ZTS_EU_Gift__c> gftList){
    
        
        List<String> productIdList = new List<String>();
        for(ZTS_EU_Gift__c gft: gftList){
            productIdList.add(gft.ZTS_EU_Product_Hierarchy__c);
        }
        
        List<ZTS_EU_Species_Product__c> productList = new List<ZTS_EU_Species_Product__c>();
        Map<string, ZTS_EU_Species_Product__c> productMap = new Map<string, ZTS_EU_Species_Product__c>();
        
        productList = [Select Id, Name, ZTS_EU_Gift_Value__c, ZTS_EU_Gift_type__c from ZTS_EU_Species_Product__c where Id IN: productIdList];
        
        for(ZTS_EU_Species_Product__c p: productList){
            productMap.put(p.Id, p);
        }
        
        for(ZTS_EU_Gift__c gft: gftList){
            gft.ZTS_EU_Gift_Value__c = productMap.get(gft.ZTS_EU_Product_Hierarchy__c).ZTS_EU_Gift_Value__c;
            gft.ZTS_EU_Gift_type__c= productMap.get(gft.ZTS_EU_Product_Hierarchy__c).ZTS_EU_Gift_type__c;
            productName = productMap.get(gft.ZTS_EU_Product_Hierarchy__c).Name;
        }
        
        
    }
    
    /*
        Name: checkLimitsForExpensiveAndCheapGifts
        Purpose: to check the number of cheaper/expensive gifts against the limits defined on the contact.  
        Argument: List<ZTS_EU_Gift__c>
        Return type: none
    */
    public static void checkLimitsForExpensiveAndCheapGifts(List<ZTS_EU_Gift__c> gftList){
        
        
        List<String> contactIdList = new List<String>();
        for(ZTS_EU_Gift__c gft: gftList){
            contactIdList.add(gft.ZTS_EU_Contact__c);
        }
        
        List<Contact> contactList = new List<Contact>();
        Map<string, Contact> contactMap = new Map<string, Contact>();
        
        contactList = [Select Id, Name, ZTS_EU_On_Hand_Balance_Cheaper__c, ZTS_EU_On_Hand_Balance_Expensive__c, ZTS_EU_Country__c from Contact where Id IN: contactIdList AND ZTS_EU_Market__c != 'United States'];
        
        for(Contact  c: contactList){
            contactMap.put(c.Id, c);
        }
        
        string countries = system.label.ZTS_EU_CountriesForGiftLimits;
        Set<string> countrySet = new Set<String>(); 
        for(String typeList : countries.split(';')){
            countrySet.add(typeList);  
        }
        
        for(ZTS_EU_Gift__c gft: gftList){
            
            if(gft.ZTS_EU_Is_Current_Year_Gift__c == true && countrySet.contains(contactMap.get(gft.ZTS_EU_Contact__c).ZTS_EU_Country__c) ){
                
                if(gft.ZTS_EU_Gift_Value__c <= 25){
                    if(gft.ZTS_EU_Quantity__c > contactMap.get(gft.ZTS_EU_Contact__c).ZTS_EU_On_Hand_Balance_Cheaper__c){
                        string errorMessage = System.Label.ZTS_EU_GiftsLimitsErrorMessage1 + ' ' +  productName + ' ' + System.Label.ZTS_EU_GiftsLimitsErrorMessage2 + ' ' + contactMap.get(gft.ZTS_EU_Contact__c).Name+ '.';  
                        errorMessage = errorMessage + System.Label.ZTS_EU_GiftsLimitsErrorMessage3 + ' ' + contactMap.get(gft.ZTS_EU_Contact__c).ZTS_EU_On_Hand_Balance_Cheaper__c + '.';
                        gft.addError(errorMessage);
                    }
                }
                else if(gft.ZTS_EU_Gift_Value__c > 25){
                    if(gft.ZTS_EU_Quantity__c > contactMap.get(gft.ZTS_EU_Contact__c).ZTS_EU_On_Hand_Balance_Expensive__c ){
                        string errorMessage = System.Label.ZTS_EU_GiftsLimitsErrorMessage1 + ' ' +  productName + ' ' + System.Label.ZTS_EU_GiftsLimitsErrorMessage2 + ' ' + contactMap.get(gft.ZTS_EU_Contact__c).Name+ '.';  
                        errorMessage = errorMessage + System.Label.ZTS_EU_GiftsLimitsErrorMessage3 + ' ' + contactMap.get(gft.ZTS_EU_Contact__c).ZTS_EU_On_Hand_Balance_Expensive__c + '.';
                        gft.addError(errorMessage);
                    }
                }
            }
            
            
             
            
        }
        
    }

}
/* -----------------------------------------------------------------------------------------------------------------------
   Name:        TestUtilities.cls
   Description: Various Utility functions. Can be used by test classes.
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   12-09-2014   1.0     Bimba               Initial Version          
------------------------------------------------------------------------------------------------------------------------ */

public class TestUtilities{

    /*******************************************************************
     Purpose: Method to create Account Segmentation Threshold records.                                                  
     Parameters: bu-BusUnit Id,market,BUAbbr,thresMin,thresMax,Rating
     Returns: Account_Segmentation_threshold__c record
     Author: Bimba
     *******************************************************************/ 
    public static Account_Segmentation_threshold__c createNoInsertAccountSegmentationThreshold(String market,String BUAbbr,Double thresMin,Double thresMax,String Rating){
        Account_Segmentation_threshold__c thresholdRec = new Account_Segmentation_threshold__c(ZTS_EU_Market__c = market,
                                                                                        BU_Abbrv__c = BUAbbr,
                                                                                        ZTS_EU_Threshold_Minimum_Value_Potential__c = thresMin,
                                                                                        ZTS_EU_Threshold_Maximum_Value_Potential__c = thresMax,
                                                                                        ZTS_EU_Segmentation_Rating__c = Rating);
        return thresholdRec;
        
    } 
    /*******************************************************************
     Purpose: Method to create Business Unit Product Hierarchy records                                                
     Parameters: speciesProdName,recType,Market,BUAbbr
     Returns: ZTS_EU_Species_Product__c record
     Author: Bimba
     Modification Log: Added BusinessUnitRecordTypeId parameter
     *******************************************************************/ 
     public static ZTS_EU_Species_Product__c createNoInsertBusUnit(String speciesProdName,String type,String Market,String BUAbbr, String RecordTypeId){  
        ZTS_EU_Species_Product__c speciesProdRec = new ZTS_EU_Species_Product__c(Name= speciesProdName,
                                                                            ZTS_EU_Type__c= type,
                                                                            ZTS_EU_Market__c= Market ,
                                                                            ZTS_EU_Business_Unit_Abbr__c= BUAbbr,
                                                                            RecordTypeID = RecordTypeId);
                                                                            
        return speciesProdRec;                                                                           
    }
    
    
    /*******************************************************************
     Purpose: Method to create Brand Product Hierarchy Records                                               
     Parameters: speciesProdName,recType,Market
     Returns: ZTS_EU_Species_Product__c record
     Author: Bimba
     *******************************************************************/ 
    public static ZTS_EU_Species_Product__c createNoInsertBrand(String speciesProdName,String recType,String Market,String recTypeId){
        ZTS_EU_Species_Product__c speciesProdRec = new ZTS_EU_Species_Product__c(Name= speciesProdName,
                                                                            ZTS_EU_Type__c= recType ,
                                                                            ZTS_EU_Market__c= Market,
                                                                            RecordTypeID = recTypeId);
                                                                            
        return speciesProdRec;                                                                           
    }
    
    /*******************************************************************
     Purpose: Method to fetch record type Id                                                 
     Parameters: Developer Name
     Returns: RecordType Id
     Author: Bimba
     *******************************************************************/ 
    /*private static String getRecordTypeId(String developerName) {
    
        String RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = developerName].Id;
        
        String acctRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ZTS_EU_Activated_Account'].Id;
        return RecordTypeId;
    }*/
    /*******************************************************************
     Purpose: Method to create Account record                                                
     Parameters: Account name,type,subtype,String recTypeId,market,PotRegion,omitFlag)
     Returns: Account
     Author: Shreyas
     *******************************************************************/ 
    public static Account createNoInsertAccountRecord(String name,String type,String subtype,String recTypeId,String market,String PotRegion,Boolean omitFlag){
        
        Account acc = new Account(Name= name,
                                        Type= type,
                                        ZTS_EU_Sub_Type__c= subtype,
                                        ZTS_EU_Account_Status__c = 'Active',
                                        RecordTypeID = recTypeId,
                                        ZTS_EU_Market__c = market,
                                        Practice_Management_Software__c = 'Other',
                                        Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                        ZTS_EU_Potential_Region__c = PotRegion,
                                        ZTS_EU_Omit_Segmentation_Calculations__c = omitFlag);   
        return acc; 
    }
    
    /*******************************************************************
     Purpose: Method to create Account records                                                 
     Parameters: Account name,type,subtype,String recTypeId,market,PotRegion,omitFlag)
     Returns: List<Account>
     Author: Bimba
     *******************************************************************/ 
    public static List<Account> createNoInsertAccount(String name,String type,String subtype,String recTypeId,String market,String PotRegion,Boolean omitFlag){
        
        List<Account> accountsList= new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account(Name= name + i,
                                        Type= type,
                                        ZTS_EU_Sub_Type__c= subtype,
                                        ZTS_EU_Account_Status__c = 'Active',
                                        RecordTypeID = recTypeId,
                                        ZTS_EU_Market__c = market,
                                        Practice_Management_Software__c = 'Other',
                                        Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                        ZTS_EU_Potential_Region__c = PotRegion,
                                        ZTS_EU_Omit_Segmentation_Calculations__c = omitFlag);
            accountsList.add(acc);  
        }   
        return accountsList; 
    }

    /*******************************************************************
     Purpose: Method to create Account records                                                 
     Parameters: Account name,type,subtype,String recTypeId,market, practiceManagementSoftware ,PotRegion,omitFlag)
     Returns: List<Account>
     Author: Cesar Sandrigo @ ATG
     *******************************************************************/ 
    public static List<Account> createNoInsertAccount(String name,String type,String subtype,String recTypeId,String market, String practiceManagementSoftware,String PotRegion,Boolean omitFlag){
        
        List<Account> accountsList= new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account(Name= name + i,
                                        Type= type,
                                        ZTS_EU_Sub_Type__c= subtype,
                                        ZTS_EU_Account_Status__c = 'Active',
                                        RecordTypeID = recTypeId,
                                        ZTS_EU_Market__c = market,
                                        Practice_Management_Software__c = practiceManagementSoftware,
                                        ZTS_EU_Potential_Region__c = PotRegion,
                                        ZTS_EU_Omit_Segmentation_Calculations__c = omitFlag);

            if (practiceManagementSoftware.equals('Other')) {
                acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            }
                        
            accountsList.add(acc);  
        }   
        return accountsList; 
    }
    
    /*******************************************************************
     Purpose: Method to create Account records with VAT code                                               
     Parameters: Account name,type,subtype,String recTypeId,market,PotRegion,omitFlag)
     Returns: List<Account>
     Author: Bimba
     *******************************************************************/ 
    public static List<Account> createNoInsertVATcodeAccount(String name,String type,String subtype,String recTypeId,String market,String PotRegion,String vatcode,Boolean omitFlag){
        
        List<Account> accountsList= new List<Account>();
        
            Account acc = new Account(Name= name,
                                        Type= type,
                                        ZTS_EU_Sub_Type__c= subtype,
                                        ZTS_EU_Account_Status__c = 'Active',
                                        RecordTypeID = recTypeId,
                                        ZTS_EU_Market__c = market,
                                        Practice_Management_Software__c = 'Other',
                                        Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                        ZTS_EU_Potential_Region__c = PotRegion,
                                        ZTS_EU_VAT_Code__c = vatcode,
                                        ZTS_EU_Omit_Segmentation_Calculations__c = omitFlag);

            accountsList.add(acc);  
         
        return accountsList; 
    }
    
     /*******************************************************************
     Purpose: Method to create Species records                                                 
     Parameters: name,prodHierId,speciesName,market
     Returns: List<Account>
     Author: Bimba
     *******************************************************************/ 
    
    public static ZTS_EU_Species__c createNoInsertSpecies(String name,Id prodHierId,String speciesName,String market){
    
        
        ZTS_EU_Species__c species = new ZTS_EU_Species__c(Name=name,
                                                           ZTS_EU_Business_Unit__c = prodHierId,
                                                           ZTS_EU_Species__c=speciesName,
                                                           ZTS_EU_Market__c= market);
        return species;      
       
       }
       
     /*******************************************************************
     Purpose: Method to create AccountSpeciesPotential records                                                 
     Parameters: acctID,speciesPotId,animalsnew,animalsactual
     Returns: ZTS_EU_Account_Species_Potential__c
     Author: Bimba
     *******************************************************************/ 
     public static ZTS_EU_Account_Species_Potential__c createNoInsertAcctSpcPot(Id acctID,Id speciesPotId,Integer animalsnew,Integer animalsactual) {
         
         ZTS_EU_Account_Species_Potential__c acctPotentialRec = new ZTS_EU_Account_Species_Potential__c(Account__c = acctID,
                                                                                                        ZTS_EU_Species_Potential__c = speciesPotId,
                                                                                                        ZTS_EU_Animal_Consultations_new__c = animalsnew,
                                                                                                        ZTS_EU_Animals_Consultations_actual__c = animalsactual);
                                                                                                        
         return acctPotentialRec;                                                                                    
                                                                                               
     } 
     
     public static ZTS_EU_Potential_Brands__c createNoInsertPotBrands(Id speciesId,Id brandId,Integer valReg1,Integer valReg2,Integer valReg3,Integer valReg4){
         ZTS_EU_Potential_Brands__c potBrandRec = new ZTS_EU_Potential_Brands__c(Potential__c = speciesId,
                                                                              Brand__c =  brandId,
                                                                              ZTS_EU_Value_Region_1__c = valReg1,
                                                                              ZTS_EU_Value_Region_2__c = valReg2,
                                                                              ZTS_EU_Value_Region_3__c = valReg3,
                                                                              ZTS_EU_Value_Region_4__c = valReg4);   
         return potBrandRec; 
     }  
     
     /*******************************************************************
     Purpose: Method to create Account Affiliation record                                                
     Parameters: Primary AccountId, Affiliated AccountId, role
     Returns: ZTS_EU_Account_Affiliations__c
     Author: Shreyas
     *******************************************************************/ 
     public static ZTS_EU_Account_Affiliations__c createNoInsertAccountAffiliation(Id primaryAccId ,Id associatedAccId ,string role){
         ZTS_EU_Account_Affiliations__c accAffRec = new ZTS_EU_Account_Affiliations__c(ZTS_EU_Account__c = primaryAccId,
                                                                              ZTS_EU_Affiliated_Account__c =  associatedAccId,
                                                                              ZTS_EU_Role__c = role);   
         return accAffRec; 
     }                                                                                          
     
}
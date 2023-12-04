/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_SampleAndSampleDropUtility
* Description   :  This is the utility class for triggers on Sample and Sample Drop object.

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     10st-dec-14   Shreyas             Created the class.

********************************************************************************************************************************************/

public class ZTS_EU_SampleAndSampleDropUtility{


    /*
        Name: populateNewSKULookup
        Purpose: to populate the new SKU Lookup if a sample with new SKU is selected.  
        Argument: List<Sample_Drop__c>
        Return type: none
    */
    public static void populateNewSKULookup(List<Sample_Drop__c> sdList){
    
        List<String> sampleIdList = new List<String>();
        Map<String, ZTS_EU_Sample__c> sampleMap = new Map<String, ZTS_EU_Sample__c>();
        
        for(Sample_Drop__c sd: sdList){
            if(sd.ZTS_EU_Sample__c != null){
                sampleIdList.add(sd.ZTS_EU_Sample__c);
            }
        }
        
        List<ZTS_EU_Sample__c> sampleList = [Select Id, ZTS_EU_Product__c, Name from ZTS_EU_Sample__c where Id IN: sampleIdList];
        
        for(ZTS_EU_Sample__c s: sampleList){
            sampleMap.put(s.Id, s);
        }
    
        for(Sample_Drop__c sd: sdList){
            sd.ZTS_EU_Species_Product_New_SKU__c = sampleMap.get(sd.ZTS_EU_Sample__c).ZTS_EU_Product__c;
        }
    }
    
    /*
        Name: populateYear
        Purpose: to populate the current year on the sample drop 
        Argument: List<Sample_Drop__c>
        Return type: none
    */
    public static void populateYear(List<Sample_Drop__c> sdList){
    
        integer currentYear = System.Today().year();
        string currentYearString = string.valueof(currentYear);
        
        for(Sample_Drop__c sd: sdList){
            sd.ZTS_EU_Year__c = currentYearString;
        }
    }

    /*
        Name: populateCurrentYearCheckbox
        Purpose: to populate the current year checkbox on the sample drop. Set to true if the year on sample and sample drop matches.
        Argument: List<Sample_Drop__c>
        Return type: none
    */
    public static void populateCurrentYearCheckbox(List<Sample_Drop__c> sdList){
    
        integer currentYear = System.Today().year();
        string currentYearString = string.valueof(currentYear);
        
        List<String> sampleIdList = new List<String>();
        Map<String, ZTS_EU_Sample__c> sampleMap = new Map<String, ZTS_EU_Sample__c>();
        
        for(Sample_Drop__c sd: sdList){
            if(sd.ZTS_EU_Sample__c != null){
                sampleIdList.add(sd.ZTS_EU_Sample__c);
            }
        }
        
        List<ZTS_EU_Sample__c> sampleList = [Select Id, ZTS_EU_Product__c, Name, ZTS_EU_Year__c from ZTS_EU_Sample__c where Id IN: sampleIdList];
        
        for(ZTS_EU_Sample__c s: sampleList){
            sampleMap.put(s.Id, s);
        }
        
        for(Sample_Drop__c sd: sdList){
        
            string sampleYear = sampleMap.get(sd.ZTS_EU_Sample__c).ZTS_EU_Year__c;
            if(sd.ZTS_EU_Year__c == sampleYear){
                sd.ZTS_EU_Is_Current_Year_Sample_Drop__c = True;
            }
            else{
                sd.ZTS_EU_Is_Current_Year_Sample_Drop__c = False;
            }
            
        }
    }


    /*
        Name: getSampleDrops
        Purpose: fetch sample drops for incoming sample records.
        Argument: List<ZTS_EU_Sample__c>
        Return type: List<Sample_Drop__c>
    */
    public static List<Sample_Drop__c> getSampleDrops(List<ZTS_EU_Sample__c> sList){
    
        List<String> sampleIdList = new List<String>();
        Map<String, ZTS_EU_Sample__c> sampleMap = new Map<String, ZTS_EU_Sample__c>();
        
        for(ZTS_EU_Sample__c s: sList){
            sampleIdList.add(s.Id);
        }
        
        List<Sample_Drop__c> sampleDropList = new List<Sample_Drop__c>();
        
        sampleDropList = [Select Id, ZTS_EU_Is_Current_Year_Sample_Drop__c, ZTS_EU_Year__c, ZTS_EU_Sample__c from Sample_Drop__c where ZTS_EU_Sample__c IN: sampleIdList];
        
        return sampleDropList;
    }
    
   //Srinivas K added code as part of the defect fix INC0657967
    public static void processSampleDataForActivatedContacts(List<Contact> activatedContactLst)
    {   
        
        List<ZTS_EU_Sample__c> samplesListToActivate = new List<ZTS_EU_Sample__c>();
        List<ZTS_EU_Sample__c> updateSamplesListToActivate = new List<ZTS_EU_Sample__c>();
        samplesListToActivate = [select id,ZTS_EU_Is_Active__c from ZTS_EU_Sample__c where ZTS_EU_Contact__c in : activatedContactLst ];
        if(samplesListToActivate.size() > 0){
            for(ZTS_EU_Sample__c sample: samplesListToActivate){
                sample.ZTS_EU_Is_Active__c = True;
                updateSamplesListToActivate .add(sample);
            }
        }
        
        if(updateSamplesListToActivate != null && updateSamplesListToActivate .size()>0){
        
            update updateSamplesListToActivate ;
        }
    }
}
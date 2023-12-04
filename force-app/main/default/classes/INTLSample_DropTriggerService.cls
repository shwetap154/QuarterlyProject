/****************************************************************************************************************************************** 
* Class Name   : INTLSample_DropTriggerService
* Description  : Logic for all Sample_Drop__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 188 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/18/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public class INTLSample_DropTriggerService 
{
    public static void beforeInsert(List<Sample_Drop__c> triggerNew) 
    {
        List<Sample_Drop__c> sdList = new List<Sample_Drop__c>();
        List<Sample_Drop__c> sdList_PopulateYear = new List<Sample_Drop__c>();
        
        for(Sample_Drop__c sd : triggerNew)
        {
            if(sd.ZTS_EU_Sample__c != null)
            {
                sdList.add(sd);
            }
            
            if(sd.ZTS_EU_Year__c == null)
            {
                sdList_PopulateYear.add(sd);
            }
        }
        
        if(sdList.size() > 0)
        {
            ZTS_EU_SampleAndSampleDropUtility.populateNewSKULookup(sdList);
        }
        
        if(sdList_PopulateYear.size() > 0)
        {
            ZTS_EU_SampleAndSampleDropUtility.populateYear(sdList_PopulateYear);
        }
        
        
        ZTS_EU_SampleAndSampleDropUtility.populateCurrentYearCheckbox(triggerNew);
    }
    
    public static void beforeUpdate(List<Sample_Drop__c> triggerOld, Map<Id, Sample_Drop__c> triggerOldMap, List<Sample_Drop__c> triggerNew, Map<Id, Sample_Drop__c> triggerNewMap)
    {
        List<Sample_Drop__c> sdList_YearChanged = new List<Sample_Drop__c>();
        
        for (Integer i = 0; i < triggerNew.size(); i++)
        { 
            if(triggerNew[i].ZTS_EU_Year__c != triggerOld[i].ZTS_EU_Year__c)
            {
                sdList_YearChanged.add(triggerNew[i]);
            }
        }
        
        if(sdList_YearChanged.size() > 0)
        {
            ZTS_EU_SampleAndSampleDropUtility.populateCurrentYearCheckbox(sdList_YearChanged);
        }
    }

    public static void afterInsert(List<Sample_Drop__c> triggerNew, Map<Id, Sample_Drop__c> triggerNewMap)
    {
        List<Sample_Drop__c> sampleDropList = new List<Sample_Drop__c>();
        sampleDropList = [
            SELECT Id, Name, ZTS_EU_Contact__c, ZTS_EU_Call__c, ZTS_EU_Quantity__c, ZTS_EU_Sample__r.ZTS_EU_Contact__c 
            FROM Sample_Drop__c 
            WHERE Id IN: triggerNew
        ];
        
        List<Sample_Drop__c> sampleDropListToUpdate = new List<Sample_Drop__c>();
        integer count = 0;
        integer count2 = 0;
        for(Sample_Drop__c samDrop: sampleDropList)
        {
            samDrop.ZTS_EU_Contact__c = samDrop.ZTS_EU_Sample__r.ZTS_EU_Contact__c;
            sampleDropListToUpdate.add(samDrop);
            count2 = count2 +  Integer.valueOf(samDrop.ZTS_EU_Quantity__c);
        }
        
        update sampleDropListToUpdate;
    }
}
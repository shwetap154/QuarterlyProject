/****************************************************************************************************************************************** 
 * Trigger Name : INTLTime_Out_of_TerritoryTriggerService
 * Description  : Service class to handle Time_Out_of_Territory__c trigger logic  
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 12th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman			02/12/2020		Moved from Triggers into service class per framework
 * Triggers added below:
 -----------------------------------------------------------------------------------------------------------------------------------------
 * @Name: ZTS_EU_AllTOTTrigger
 * @Desciption: Trigger on TOT.
 *              1.Avoids creation and updation of TOT for the User whenever there is a conflict with DateTime of a call associated with that User.
 * @date Created:Feb 20, 2014
 * @author Ketan Prakash Singh
 *
 * Change Description:
 * Author: CloudSense (Shreyas) 
 * @Date: 15th-Sep-2014
 * @Description; Leveraged the method 'calculateDayCount' to calculate the number of weekends/holidays between Start and End date of ToT record. 
                 Leveraged the method 'populateStateOnToT' to populate the state of owner/sales-rep.
                 Will be called on 'before insert' and 'before update' when start/end date is updated. 
*****************************************************************************************************************************************/
public class INTLTime_Out_of_TerritoryTriggerService 
{      
	public static void beforeInsert(List<Time_Out_of_Territory__c> triggerNew)
    {
        ZTS_EU_TOT_Utils.validateTOT(triggerNew);
        ZTS_EU_TOT_Utils.populateAccountingPeriodOnTOT(triggerNew);
        if (!ZTS_EU_TOT_datefillclass.isrecursive)
            // To update the start date time and End Date Time fields
            ZTS_EU_TOT_datefillclass.filldatetime(triggerNew);
        // Code to validate Time Off of an user 
        //   ZTS_EU_TOT_Utils.validateTOT(triggerNew);
        
        //Code to populate the state of owner/sales-rep 
        ZTS_EU_TOT_Utils.populateStateOnToT(triggerNew);
        //Code to calculate the number of days between start and end date
        ZTS_EU_TOT_Utils.calculateDayCount(triggerNew);
    }
    
    public static void beforeUpdate(List<Time_Out_of_Territory__c> triggerOld, Map<Id, Time_Out_of_Territory__c> triggerOldMap, List<Time_Out_of_Territory__c> triggerNew, Map<Id, Time_Out_of_Territory__c> triggerNewMap) 
    {
        List<Time_Out_of_Territory__c> lsttot = new List<Time_Out_of_Territory__c>();
        List<Time_Out_of_Territory__c> lsttot_UpdatedRep = new List<Time_Out_of_Territory__c>();
        
        ZTS_EU_TOT_Utils.populateAccountingPeriodOnTOT(triggerNew);
        for(Time_Out_of_Territory__c tot: triggerNew){
            
            if(tot.ZTS_EU_Sales_Representative__c != triggerOldMap.get(tot.id).ZTS_EU_Sales_Representative__c){
                lsttot_UpdatedRep.add(tot); 
            }
            
            if((tot.ZTS_EU_Start_Date__c != triggerOldMap.get(tot.id).ZTS_EU_Start_Date__c) || (tot.ZTS_EU_End_Date__c != triggerOldMap.get(tot.id).ZTS_EU_End_Date__c) || (tot.ZTS_EU_Duration__c != triggerOldMap.get(tot.id).ZTS_EU_Duration__c)){
                lsttot.add(tot);
            }
        }
        
        if(lsttot_UpdatedRep.size()>0) {
            //Code to populate the state of owner/sales-rep 
            ZTS_EU_TOT_Utils.populateStateOnToT(triggerNew);  
        }
        if(lsttot.size()>0) {
            ZTS_EU_TOT_datefillclass.filldatetime(lsttot); //Added by Shreyas for the fix of ToT defect of 'Day Count' calculation. 
            ZTS_EU_TOT_Utils.validateTOT(lsttot); 
            //Code to calculate the number of days between start and end date
            ZTS_EU_TOT_Utils.calculateDayCount(lsttot);   
            lsttot.clear();
        }    
    }

    public static void afterUpdate(List<Time_Out_of_Territory__c> triggerOld, Map<Id, Time_Out_of_Territory__c> triggerOldMap, List<Time_Out_of_Territory__c> triggerNew, Map<Id, Time_Out_of_Territory__c> triggerNewMap)
    {
        if (!TOTService_ForCreateduser.isEventUpdatingCall) {
            TOTService_ForCreateduser.isEventUpdatingCall = true;
            ZTS_EU_TOT_Utils.IsTotDelete = true;
            TOTService_ForCreateduser.updateAndSyncEventsFromToTs(triggerNewMap, triggerOldMap); 
        }
        
        /* if (!TOTService_Forsalesrep.isEventUpdatingCall) {
        TOTService_Forsalesrep.isEventUpdatingCall = true;
        ZTS_EU_TOT_Utils.IsTotDelete = true;
        TOTService_Forsalesrep.updateAndSyncEventsFromToTs(triggerNewMap, triggerOldMap);
        }*/
    }
    
    public static void afterInsert(List<Time_Out_of_Territory__c> triggerNew, Map<Id, Time_Out_of_Territory__c> triggerNewMap)
    {
        //for passing the Time On records when creating a Time On Records
        List < Time_Out_of_Territory__c > lstTOTall = new List < Time_Out_of_Territory__c > ();
        for (Time_Out_of_Territory__c tot: triggerNew) {
                lstTOTall.add(tot);
        }
        if(lstTOTall.size()>0){
            TOTService_ForCreateduser.generateAndSetupEventsFromToTs(triggerNew);
        }
        
          /*if(lstTOTall.size()>0 && skipCode){
            ZTS_EU_TOT_Utils.validateTOTOffconflicts(lstTOTall);
        }
        
      //for passing the Time Off records when creating a Time On Records
        List < Time_Out_of_Territory__c > lstTOTOffs = new List < Time_Out_of_Territory__c > ();
        for (Time_Out_of_Territory__c tot1: triggerNew) {
            if (tot1.ZTS_EU_Type__c == 'Time Off') {
                lstTOTOffs.add(tot1);
            }
            if(lstTOTOffs.size()>0 && skipCode){
            System.debug('IP: code not skipped');
            ZTS_EU_TOT_Utils.validateTOTDateOnInsertAndUpdate(lstTOTOffs);
        }
        }*/
        
        //Ilirjana 07/01/2015 Changes for trigger bypass
        //Ilirjana 07/01/2015 EOC
        
        // To create events for both Owner and Sales Representative
        
      /*  if(lstTOTOn.size()>0){
            TOTService_ForCreateduser.generateAndSetupEventsFromToTs(triggerNew);
            //TOTService_Forsalesrep.generateAndSetupEventsFromToTs(lstTOTOn);
        }

        //for passing the Time Off records when creating a Time On Records
        List < Time_Out_of_Territory__c > lstTOTOff = new List < Time_Out_of_Territory__c > ();
        for (Time_Out_of_Territory__c tot: triggerNew) {
            if (tot.ZTS_EU_Type__c == 'Time Off') {
                lstTOTOff.add(tot);
            }
        }
        if(lstTOTOff.size()>0){
        ZTS_EU_TOT_Utils.validateTOTOnconflicts(lstTOTOff);
        }*/       
	}

}
/****************************************************************************************************************************************** 
 * Class Name     : ZTS_EU_ECCUpdateOnCallSubmit
 * Description    : This Trigger class for 'CallTrigger' update 'Is Call Status Completed' field on call submition
 *                
 *      
 * Created By   : Sohil Shah(CloudSense)
 * Created Date : 13th July, 2015.
 *
 * Modification Log: 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * sohil shah               07/13/2015          Created
*****************************************************************************************************************************************/
public class ZTS_EU_ECCUpdateOnCallSubmit
{
    public static void updateECC(List<Call__C> TriggerNew)
    {
         List<Call__c> callList = new List<Call__C>();
          List<ZTS_EU_Employee_Call_Credit__c> eccListToUpdate = new List<ZTS_EU_Employee_Call_Credit__c>();
          /*
          String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
          Map<String,Period> check = new Map<String,Period>();
          List<Period> FYdates = new List<Period>();
          FYdates= [SELECT FiscalYearSettings.Name,StartDate,EndDate FROM Period WHERE Type = 'Year'];
          for(Period pd : FYdates){
              check.put(pd.FiscalYearSettings.Name, pd);
          }
            Date currentFiscalYearEnddate = FYdates[0].EndDate;
            Date currentFiscalYearStartdate = FYdates[0].StartDate;
            */
          callList = [Select id, ZTS_EU_Status__c,(Select Id, ZTS_EU_Call__c, ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c, ZTS_EU_FY_StartDate__c, ZTS_EU_FY_EndDate__c, ZTS_EU_Call__r.ZTS_EU_Status__c, Is_Call_status_Completed__c from Employee_Call_Credits__r) from Call__C where id IN :TriggerNew AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']; 
           
            for(call__C call : callList)
            {
                for(ZTS_EU_Employee_Call_Credit__c  ecc : call.Employee_Call_Credits__r)
                {
                     
                       if(ecc.ZTS_EU_FY_StartDate__c<=ecc.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c&&ecc.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c<=ecc.ZTS_EU_FY_EndDate__c&&ecc.ZTS_EU_Call__r.ZTS_EU_Status__c=='completed'){ 
                              ecc.Is_Call_Completed_In_Current_FY__c=true;
                              ecc.Is_Call_status_Completed__c = true;
                        }
                        else if((ecc.ZTS_EU_FY_StartDate__c>ecc.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c||ecc.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c>ecc.ZTS_EU_FY_EndDate__c)&&ecc.ZTS_EU_Call__r.ZTS_EU_Status__c=='completed'){
                            ecc.Is_Call_Completed_In_Current_FY__c=false;
                            ecc.Is_Call_status_Completed__c = true;
                        }
                     eccListToUpdate.add(ecc);
                }
               
            }
            Database.update(eccListToUpdate,false);
    }
}
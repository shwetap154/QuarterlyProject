/***************************************************************************** 
 * Class Name     : ZTS_US_SchedulablePopulateAccountTSF
 * Description    : This is a schedulable class for batch class "ZTS_US_BatchPopulateAccountTSF" 
 * Created By     : Aritra Chakraborty(Cognizant Technology Solutions)
 * Created Date   : 27th June, 2018.
 *
 * Modification Log: 
 * ----------------------------------------------------------------------------
 * Developer                Date               Description 
 * ----------------------------------------------------------------------------
 * 
******************************************************************************/
global class ZTS_US_SchedulablePopulateAccountTSF implements Schedulable{
   
  global void execute(SchedulableContext sc) 
    { 
       ZTS_US_BatchPopulateAccountTSF batch = new ZTS_US_BatchPopulateAccountTSF();
         database.executebatch(batch);          
    } 
}
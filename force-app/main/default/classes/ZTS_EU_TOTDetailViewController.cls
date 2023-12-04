/******************************************************************************************************************************************
 * Class Name   : ZTS_EU_TOTDetailViewController
 * Description  : Controller class for Time_Out_of_Territory__c buttons with StandardController  
 * Created By   : Slalom/Art Smorodin
 * Created Date : 08 June 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     06/08/2020          Created.
 *****************************************************************************************************************************************/
public with sharing class ZTS_EU_TOTDetailViewController {

    private ApexPages.StandardController standardController;
    public Time_Out_of_Territory__c sourceTot;
    public String eventId;

    public ZTS_EU_TOTDetailViewController(ApexPages.StandardController standardController) {

        this.standardController = standardController;
        Time_Out_of_Territory__c tmpContr = (Time_Out_of_Territory__c)standardController.getRecord();
        this.sourceTot = [SELECT id, ZTS_US_Calendar_Event__c FROM Time_Out_of_Territory__c WHERE id = :tmpContr.id limit 1];
        eventId = sourceTot.ZTS_US_Calendar_Event__c;
    }

    
    public PageReference doAddToCal(){
        try {
            String returnUrl = '/lightning/cmp/c__TOTAddCalendarEvtLc?c__recordId='+sourceTot.Id+'&c__event='+eventId;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
}
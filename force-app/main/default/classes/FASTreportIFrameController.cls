/**
	* File Name     :  FASTreportIFrameController
	* description  :  Controller extension for FASTreportIFrame.vfp
	* author       :  Chelsea Paice
	* Modification Log
	===================================================================================================
	* Ver.  Date        Author                 Modification
	---------------------------------------------------------------------------------------------------
	* 1.0   04/16/2021  Chelsea Paice          Created controller
**/

public class FASTreportIFrameController {
	private final Account acct;
    public static Boolean urlError;

    public FASTreportIFrameController(ApexPages.StandardController stdController) {
        this.acct = [SELECT Id,ZTS_US_NARC_ID__c FROM Account WHERE Id=:stdController.getId()];
    }
 
    public String getReportURL() {
        FAST_Report_Base_URL__c baseURL = FAST_Report_Base_URL__c.getOrgDefaults();
        String urlStr = baseURL.URL__c;
        if (acct.ZTS_US_NARC_ID__c == null || urlStr == null || urlStr == '') {
            System.debug('URL Str in If' + urlStr);
            return urlStr;
        } else {
            System.debug('URL Str in else' + urlStr);
            return urlStr  + acct.ZTS_US_NARC_ID__c;
            
        }
        
    }
}
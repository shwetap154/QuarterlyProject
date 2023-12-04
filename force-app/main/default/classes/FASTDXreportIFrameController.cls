/**
	* File Name     :  FASTDXreportIFrameController
	* description  :  Controller extension for FASTDxreportIFrame.vfp
	* author       :  Pranija Nagavelly
	* Modification Log
	===================================================================================================
	* Ver.  Date        Author                 Modification
	---------------------------------------------------------------------------------------------------
	* 1.0   09/24/2021  Pranija Nagavelly      Created controller
**/

public class FASTDXreportIFrameController {
private final Account acct;
 

    public FASTDXreportIFrameController(ApexPages.StandardController stdController) {
        this.acct = [SELECT Id,ZTS_US_NARC_ID__c FROM Account WHERE Id=:stdController.getId()];
        
    }

    
    public String getReportURL() {
        FAST_Report_Base_URL__c baseURL = FAST_Report_Base_URL__c.getOrgDefaults();
        String urlStr = baseURL.FASTDx_URL__c;
        
       
        if (acct.ZTS_US_NARC_ID__c == null || urlStr == null || urlStr == '') {
            return urlStr;
        } else { 
            return urlStr + 'top_sight_view/' + acct.ZTS_US_NARC_ID__c;                               
        }
    }
}
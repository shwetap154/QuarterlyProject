/**
* File Name     :  NGSEInternationaliFrameController
* description  :  Controller extension for NGSEInternationaliFramePage.vfp
* author       :  Padma Nerella
* Created Date : 4/29/2022
**/

public class NGSEInternationaliFrameController {
    
    public NGSEInternationaliFrameController(){}
    
    String frameurl;
     
    public String getFrameurl() {
        NGSE_International_iFrame_URL__c baseURL = NGSE_International_iFrame_URL__c.getInstance();
        frameurl = baseURL.NGSE_IFrame_URL__c;
        System.debug('frameurl: '+frameurl);
        return frameurl;
    }
    
}
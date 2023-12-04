public with sharing class ZTS_US_campaignSearchController {

    public List<CampaignWrapper> lstCampaignWrapp{set;get;}
    public transient String selectedCampaignIds{set;get;}    
    public transient String selectedCampaignNames{set;get;}
    
    public ZTS_US_campaignSearchController()
    {
        // getting the selected user ids (if any) from the URL
        selectedCampaignIds = apexpages.currentpage().getparameters().get('CampaignIds');
        populateCampaignWrapper();
    }
    
    /* 
     * Method name : populateCampaignWrapper
     * Description : This method is used to populate list of users from wrapper class.
     * Param - No parameter 
     * Returns :  null
    */
    
    public void populateCampaignWrapper(){
        List<Campaign> lstCampaign = [Select Id, Name, ZTS_EU_Field_Targeting__c from Campaign where ZTS_EU_Field_Targeting__c =: 'Open' AND ZTS_EU_Market__c = 'United States' order by name limit :Limits.getLimitQueryRows()];
        if(lstCampaign != null && lstCampaign.size()>0){
            lstCampaignWrapp = new List<CampaignWrapper>();
                for(Campaign Camp : lstCampaign){
                if(String.isNotBlank(selectedCampaignIds) && selectedCampaignIds.containsIgnoreCase(Camp.id)){
                    lstCampaignWrapp.add(new CampaignWrapper(Camp,true));
                }
                else{
                    lstCampaignWrapp.add(new CampaignWrapper(Camp,false));
                }
            }
        }
    }
    
    /* 
     * Method name : saveResponse
     * Description : This method is used to save the user details.
     * Param - No parameter 
     * Returns :  null
    */
    
    public void saveResponse(){
        selectedCampaignIds = '';
        selectedCampaignNames = '';
        for(CampaignWrapper campWrap : lstCampaignWrapp){
            if(campWrap.isSelected == true){
                selectedCampaignIds += campWrap.oCampaign.id + ';' ;
                selectedCampaignNames += campWrap.oCampaign.Name+ ';' ;
            }
        }
    }
    
    /*
    *  Classname : CampaignWrapper
    *  Description: This class is used to store the users which are selected. 
    */
    
    public class CampaignWrapper{
        public Campaign oCampaign{set;get;}
        public string CampaignName{set;get;}
        public boolean isSelected{set;get;}
        
        CampaignWrapper(Campaign camp , boolean bIsSelected){
            oCampaign = camp;
            CampaignName = String.escapeSingleQuotes(camp.name);
            isSelected = bIsSelected;
        }
    }
}
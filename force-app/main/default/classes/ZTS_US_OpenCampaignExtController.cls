/****************************************************************************************************************************************** 
 * Class Name   : ZTS_US_OpenCampaignExtController
 * Description  : This class contain operation used to display recent Open & Active Camapaigns.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 17 April 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   04/17/2014           Created
*****************************************************************************************************************************************/
public with sharing class ZTS_US_OpenCampaignExtController {
    public ZTS_US_OpenCampaignExtController(ApexPages.StandardSetController con) {
   
    }
    
    public List<Campaign> getCampaigns(){
    return setCon.getRecords();
    }
    
     public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
            	Integer rec_count=[SELECT COUNT() FROM Campaign  WHERE IsActive=true AND ZTS_EU_Field_Targeting__c='Open'  AND ZTS_EU_Market__c = 'United States'];
            	boolean isrecoredsExits=false;
            	if(rec_count>0){
            		isrecoredsExits=true;
            	}
            	
            	Integer MAX_ROWS=5;
            	String rowPageParam=ApexPages.currentPage().getParameters().get('maxrow');
            	if(!String.isBlank(rowPageParam) && rowPageParam.isNumeric()){
            		MAX_ROWS=Integer.valueOf(rowPageParam);
            	}
                 String fieldTargetStatus=ZTS_GlobalConstants.CAMPAIGN_OPEN_FIELD_TARGET_STATUS;
                 String query='SELECT Name, IsActive ,ZTS_EU_Field_Targeting__c ,Type,NumberOfContacts,status,ownerId FROM Campaign WHERE IsActive=true AND ZTS_EU_Field_Targeting__c=:fieldTargetStatus AND ZTS_EU_Market__c = \'United States\' ORDER BY CreatedDate';	
                 query+=isrecoredsExits?' LIMIT '+MAX_ROWS:'';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query
                    ));    	
                    	
            }
            return setCon;
        }
        set;
    }

}
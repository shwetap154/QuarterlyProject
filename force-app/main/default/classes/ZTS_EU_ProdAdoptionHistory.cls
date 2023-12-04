/*************************************************************************************
* Name          :    ZTS_EU_ProdAdoptionHistory.
* Description   :    Controller for a Product Adoption Profile.It copies the entire record into the 
                     “Product Adoption Profile History” object, and links that new record to the current “Product Adoption Profile”.
                     
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
04/03/2014       Deloitte/Sunil            Created

**************************************************************************************/
public  with sharing class ZTS_EU_ProdAdoptionHistory{

	/*****************************************
    VARIABLES
    ******************************************/
    Public static List<ZTS_EU_Product_Adoption_Profile_History__c> paphList; 
    Public static Set<ID> conId;
    
    public static void createProdAdoptHistory(List<ZTS_EU_Product_Adoption_Profile__c> pAdopList){
    		if(UtilityService.ispapRun()){ // Recursion check
	    		paphList = new List<ZTS_EU_Product_Adoption_Profile_History__c>();
	    		
	    		for(ZTS_EU_Product_Adoption_Profile__c pap : pAdopList){
	    			
	    			ZTS_EU_Product_Adoption_Profile_History__c papH = new ZTS_EU_Product_Adoption_Profile_History__c();
	    			papH.ZTS_EU_Brand_Indication__c = pap.ZTS_EU_Brand_Indication__c;
	    			papH.ZTS_EU_Competitor_Product__c = pap.ZTS_EU_Competitor_Product__c;
	    			papH.ZTS_EU_Contact__c = pap.ZTS_EU_Contact__c;
	    			papH.ZTS_EU_Product_Adoption_Profile__c = pap.id;
	    			papH.ZTS_EU_Product_Barrier__c = pap.ZTS_EU_Product_Barrier__c;
	    			papH.ZTS_EU_Usage__c = pap.ZTS_EU_Usage__c;
	    			paphList.add(papH);
	    		}	
	    		try{
	    			Database.insert(paphList);
	    		}catch(Exception e){
	    			system.debug('Exception*******'+e);
	    		}
    		}
    		UtilityService.setpapRunFalse(); // Recursion check	
    }
    
    public static void updatePrimaryAccount(List<ZTS_EU_Product_Adoption_Profile__c> pAdopList){
    	
    	conId = new Set<Id>();    	
    	for(ZTS_EU_Product_Adoption_Profile__c pap : pAdopList){
    		system.debug('AccountID'+pap.ZTS_EU_Contact__r.AccountId );
    		system.debug('Contact'+pap.ZTS_EU_Contact__c );
    		if(pap.ZTS_EU_Contact_Primary_Account__c == Null){    			
	    		conId.add(pap.ZTS_EU_Contact__c); 		
	    	}
    		  		
    	}
    	List<contact> conList = [select id,accountId from contact where id in : conId AND ZTS_EU_Market__c != 'United States'];
    	Map<Id,Id> conAcccIDMap = new Map<Id,Id>();
    	for(Contact c : conList){
    		conAcccIDMap.put(c.id,c.accountID);
    	}
    	for(ZTS_EU_Product_Adoption_Profile__c pap : pAdopList){
    		if(conAcccIDMap.containsKey(pap.ZTS_EU_Contact__c)){
    			pap.ZTS_EU_Contact_Primary_Account__c = conAcccIDMap.get(pap.ZTS_EU_Contact__c);
    		}
    		
    	}
    	
    }

}
/**
 * @description       : Selector Class for Competency Group Object as part of TPDEV-533
 * @author            : Sibin Kuriakose @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-06-2023
 * @last modified by  : Sibin Kuriakose @ Zoetis Inc
 * Modification Log:
----------------------------------------------------------------------------
Developer			        Date		Description
Sibin Kuriakose		        04-06-2023	Added selectByCompeGroupById and selectByCompeGroupByMarket method to get Competency Group 
Raut, Pranav Krushnarao		04-11-2023	Added method to select all the available Competency Group based on the Set of Market String
----------------------------------------------------------------------------
**/
public inherited sharing class CompetencyGroupSelector {

    /**
     * @description this methode will select Competency Group Having Id in compgroup List
     * @author Sibin Kuriakose @ Zoetis Inc | 04-06-2023
     * @param List of Id
	*/
    Public static List<Competency_Group__c> selectByCompeGroupById(List<Id> compgroup){
        
        List <Competency_Group__c> lstCompGroup = [SELECT Market__c,Role__c FROM Competency_Group__c WHERE Id = :compgroup];
        return lstCompGroup;
    }

    /**
     * @description :This method will select all the available Competency Group based on the Market
     * @author      :Sibin Kuriakose @ Zoetis Inc | 04-06-2023
     * @param       :String Containging market value
	*/
    Public static List<Competency_Group__c> selectByCompeGroupByMarket(String strtempmarket){
        
        String queryString = 'SELECT Id,Market__c,Role__c FROM Competency_Group__c WHERE Market__c INCLUDES '+ strtempmarket;
        List <Competency_Group__c> lsttempCompGroup = DataBase.query(queryString);
        return lsttempCompGroup;
    }

      /**
     * @description :This method will select all the available Competency Group based on the Set of Market String
     * @author      :Raut, Pranav Krushnarao @ Zoetis Inc | 04-11-2023
     * @param       :Set<String> 
	*/
    Public static List<Competency_Group__c> selectByCompeGroupByMarketSet(Set<String> setMarket){
        
        List <Competency_Group__c> lstCompetencyGroup = [SELECT Id,Market__c,Role__c FROM Competency_Group__c WHERE Market__c IN : setMarket];
        return lstCompetencyGroup;
    }
}
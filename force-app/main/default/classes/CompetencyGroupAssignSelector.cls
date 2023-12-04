/**
 * @description       : Selector Class for Competency Group Assignment
 * @author            : Kalyan Nayak @ Zoetis Inc
 * @group             : 
 * @last modified on  : 02-15-2023
 * @last modified by  : Kalyan Nayak @ Zoetis Inc
 * Modification Log:
----------------------------------------------------------------------------
Developer			Date		Description
Kalyan Nayak		02-15-2023	Added selectByCompeGroupMarketRole method to get Competency Group Assignment
Sibin Kuriakose		04-06-2023	Added selectByCompeGroupCompModel method to get Competency Group Assignment
----------------------------------------------------------------------------
**/
public inherited sharing class CompetencyGroupAssignSelector {

    /**
     * @description this methode will select Competency Group Assignment for all the competencies for the current logged in user 
     * @author Kalyan Nayak @ Zoetis Inc | 02-15-2023 
     * @param Market and Role
	*/
    Public static List<Competency_Group_Assignment__c> selectByCompeGroupMarketRole(String Market, String Role){
        
        List<Competency_Group_Assignment__c> objComGrpAss = [SELECT Id, Competency_Group__c, Competency_Model__c,Competency_Model__r.Name 
                                      From Competency_Group_Assignment__c 
                                      Where Competency_Group__r.Market__c includes (:Market) 
                                      AND Competency_Group__r.Role__c includes (:Role) AND Competency_Model__r.Status__c ='Active' ];
        return objComGrpAss;
    }
    
   /**
     * @description :This method will select all the available Competency Group Assignment based on Market 
     * @author      :Raut, Pranav Krushnarao @ Zoetis Inc 
     * @param       :Market
	*/
    Public static List<Competency_Group_Assignment__c> selectByCompeGroupSetOfMarket(Set<String> setMarket){
        
        List<Competency_Group_Assignment__c> objComGrpAss = [SELECT Id, Competency_Group__c, Competency_Model__c,Competency_Model__r.Name, 
                                                             Competency_Group__r.Market__c,Competency_Group__r.Role__c
                                                             From Competency_Group_Assignment__c 
                                                             Where Competency_Group__r.Market__c IN: setMarket 
                                                            ];
        return objComGrpAss;
    }

    /**
     * @description :This method will select all the available Competency Group Assignment based on Competency Model and Competency Group 
     * @author      :Sibin Kuriakose @ Zoetis Inc | 04-06-2023
     * @param       :List of Competency Model and Competency Group
	*/
    Public static List<Competency_Group_Assignment__c> selectByCompeGroupCompModel(List <Competency_Group__c> lstfnlCompGroup, List<Id> compmodel){
        
        List <Competency_Group_Assignment__c> lstfnlCompGroupAssign = [SELECT Id FROM Competency_Group_Assignment__c WHERE 
                                                                      Competency_Group__c = :lstfnlCompGroup AND Competency_Model__c = :compmodel];
        return lstfnlCompGroupAssign;
    }
    
    /**
     * @description :This method will select all the available Competency Group Assignment based on Competency Model and Competency Group 
     * @author      :Kalyan Nayak @ Zoetis Inc | 05-07-2023
     * @param       :List of Competency Group Assignment
	*/
    Public static List<Competency_Group_Assignment__c> selectByBenchmarkMarket(String benchmarkMarket){
        
        String queryString = 'SELECT Id, Competency_Group__c, Competency_Model__c, Competency_Model__r.Name, Competency_Group__r.Market__c,Competency_Group__r.Role__c From Competency_Group_Assignment__c Where Competency_Model__r.Status__c = '+'\'Active\''+ ' AND Competency_Group__r.Market__c INCLUDES ' + benchmarkMarket;
        List<Competency_Group_Assignment__c> lstfnlCompGroupAssign = DataBase.query(queryString);
        return lstfnlCompGroupAssign;
    }    
}
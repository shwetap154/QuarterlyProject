/**
 * @description       : Selector Class for CompetencyModel Object as part of TPDEV-533
 * @author            : Sibin Kuriakose @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-06-2023
 * @last modified by  : Sibin Kuriakose @ Zoetis Inc
 * Modification Log:
----------------------------------------------------------------------------
Developer			Date		Description
Sibin Kuriakose		04-06-2023	Added selectNameByCompeModelById method to get Competency Group 
sweta kumari        11-09-2023  Added selectCompetencyModelListId method to get Competency Group 
----------------------------------------------------------------------------
**/
public inherited sharing class CompetencyModelSelector {

    /**
     * @description this methode will select CompetencyModel Having Id in compmodel List
     * @author Sibin Kuriakose @ Zoetis Inc | 04-06-2023
     * @param List of Id
	*/
    Public static List<Competency_Model__c> selectNameByCompeModelById(List<Id> compmodel){
        
        List<Competency_Model__c> lstCompModel = [SELECT Name,Status__c FROM Competency_Model__c WHERE Id = :compmodel];
        return lstCompModel;
    }  
        /**
     * @Description : This method will select Competency Model 
     * @Author      : Sweta Kumari @ Zoetis Inc | 11-09-2023 
     * @Param       : CompetencyModelList
	*/ 
    
     Public static List<Competency_Model__c> selectCompetencyModelListId(){
        
        List<Competency_Model__c> lstCompModel = [SELECT Name,Status__c FROM Competency_Model__c];
        return lstCompModel;
    } 
}
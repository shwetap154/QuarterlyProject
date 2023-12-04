/**
Class Name	    : CompetencyGroupAssignmentsService
Description	    : Service Class created as part of TPDEV-533 for the Competency_Group_Assignment__c object. 
Created By		: Sibin Kuriakose
Created Date	: 04-06-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Sibin Kuriakose        	04-06-2023   Added Methods to Check for Existing combinations of Competency Group and Competency Model on Competency Group Assignment
*/
public With Sharing class CompetencyGroupAssignmentsService {
    /**     * @Description Method to Check for Existing combinations of Competency Group and Competency Model on Competency Group Assignment      
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-06-2023 
			* @param       List of Competency_Group_Assignment
    */
    public static void competencyGroupValidations(List <Competency_Group_Assignment__c> lstCompGroupAssign){
        List<Id> compmodel = new List<Id>();
        List<Id> compgroup = new List<Id>();
        for(Competency_Group_Assignment__c  tempCGA : lstCompGroupAssign) {
            compmodel.add(tempCGA.Competency_Model__c);
            compgroup.add(tempCGA.Competency_Group__c);
        }
       
        List<Competency_Model__c> lstCompModel = CompetencyModelSelector.selectNameByCompeModelById(compmodel);
        List <Competency_Group__c> lstCompGroup = CompetencyGroupSelector.selectByCompeGroupById(compgroup);

        list<String> lstintmarket = new List<string>();
        List<String> lstintRole = new List<String>();
        String strtempMark='';    
        String strtempRole='';
        List<String> markets = new List<String>();
        for(Competency_Group__c  tempCG : lstCompGroup) {
            lstintmarket.addAll(tempCG.Market__c.split(';'));
            lstintRole.addAll(tempCG.Role__c.split(';'));
        }
		String ComGrpkMarket = '(\'' + String.join(lstintmarket, '\',\'') + '\')';
        List <Competency_Group__c> lsttempCompGroup = CompetencyGroupSelector.selectByCompeGroupByMarket(ComGrpkMarket);

        String strRole = '';
        List <Competency_Group__c> lstfnlCompGroup = new List <Competency_Group__c>();
        for(Competency_Group__c tempCompGroup : lsttempCompGroup){
            for(String strtemp1 : lstintRole){
                List<String> lstfnlRole = tempCompGroup.Role__c.split(';');
                for(String strtemp2 : lstfnlRole){
                    if(strtemp1 == strtemp2 && !lstfnlCompGroup.contains(tempCompGroup)){
                        lstfnlCompGroup.add(tempCompGroup);
                        if(!strRole.contains(strtemp1)){
                            strRole = strRole+strtemp1+',';
                        }
                    }
                }
            }
        }
        strRole = strRole.removeEnd(',');
        List <Competency_Group_Assignment__c> lstfnlCompGroupAssign = CompetencyGroupAssignSelector.selectByCompeGroupCompModel(lstfnlCompGroup,compmodel);
        
        string str1='{compmodel}';
        string str2='{market}';
        string str3='{roles} ';
        
        if(lstfnlCompGroupAssign.size() > 0){
            for(Competency_Group_Assignment__c tempCompGroupAssign : lstCompGroupAssign){
                String error = System.Label.CompetencyGroupAssignmentsError.replace(str1,lstCompModel[0].Name).replace(str2,lsttempCompGroup[0].Market__c).replace(str3,strRole);
                error = error.removeEnd('s');
                tempCompGroupAssign.addError(error);
            }
        }    
    }
}
/**
* @description       : 
* @author            : Kalyan Nayak @ Zoetis Inc
* @group             : 
* @last modified on  : 03-07-2023
* @last modified by  : Kalyan Nayak @ Zoetis Inc
* Modification Log:
----------------------------------------------------------------------------
Developer			Date		Description
Kalyan Nayak		02-16-2023	Added getCompetenceDetails method to get Competencies and return it to the iDevelop - Select Competencies flow
----------------------------------------------------------------------------
**/
public with sharing class ReturnIdsToScoreCompetency {
    
    @InvocableMethod(label='Get Selected Competency Ids' description='Returns the list of selected competency Id' category='String')
    public static List<ReturnVariables> getCompetenceDetails(List<InputVariables> inputVariables) {
        
        //Get input Variables
        String selectedCompetencies = inputVariables.get(0).SelectedCompetencyIds;
        
        List<CompetenciesWithSkills> comIds = (List<CompetenciesWithSkills>)JSON.deserialize(selectedCompetencies, List<CompetenciesWithSkills>.class);
        
        String competecnyIds = '';
        CompetenciesWithSkills objRV = new CompetenciesWithSkills();
        for(CompetenciesWithSkills obj : comIds){
            competecnyIds = competecnyIds+ obj.competencyId + ',';
        }
        
        return null;
    }
    
    public class InputVariables{
        
        @InvocableVariable
        public String SelectedCompetencyIds;
    } 
    
    public class ReturnVariables{
        
        @InvocableVariable
        public String outputCollection;
    } 
}
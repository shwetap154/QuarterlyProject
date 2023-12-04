public with sharing class CompetenciesWithSkills {

     // @AuraEnabled annotation exposes the methods to Lightning Components and Flows
    @AuraEnabled
    public String competencyId;
 
    @AuraEnabled
    public String competencyName;
 
    @AuraEnabled
    public String skillName;
 
    // Define the structure of the Apex-Defined Variable
   /* public CompetenciesWithSkills(
            String competencyId,
            String competencyName,
        	List<String> skillName
    ) {
        this.competencyId = competencyId;
        this.competencyName = competencyName;
        this.skillName = skillName;
    }*/
 
    // Required no-argument constructor
    //public CompetenciesWithSkills() {}
}
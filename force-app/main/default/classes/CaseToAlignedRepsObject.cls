/**
* @ClassName    : AnimalSupportAlignedReps
* @SystemChange : SC-009661
* @CreatedOn    : 09/02/2022
* @CreatedBy    : Prasun Dubey (Cognizant)
* @Description  : Class is used in 'Case After Insert/Update' flow as apex-defined wrapper to pass list of map.
**/

global class CaseToAlignedRepsObject {
    @InvocableVariable
    global string caseId; 
    
    @InvocableVariable
    global List<String> userIds; 
}
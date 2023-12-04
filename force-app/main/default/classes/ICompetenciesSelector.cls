/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
**/
public interface ICompetenciesSelector extends fflib_ISObjectSelector {

    Set<Id> selectCompetencySetwithLessonTemplate(set<Id> CompetencyId);
    
}
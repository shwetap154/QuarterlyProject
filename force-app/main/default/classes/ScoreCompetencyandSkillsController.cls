/**
Class Name	    : ScoreCompetencyandSkillsController
Description	    : Controller Class created as part of TPDEV-59 for the Score_Competency_and_Skills Flow. 
Created By		: Sibin Kuriakose
Created Date	: 03-13-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-13-2023	 Created methods to Score Competencies and Skills and return the values to JS in LWC
*/

public With Sharing class ScoreCompetencyandSkillsController {

    /**     * @Description As part of TPDEV-59 this method will get the list of Competencies and Skills along with translations       
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-13-2023 
    */

    @AuraEnabled(cacheable=true)
    public static List<Data_Translation__c> getCompetencySkills(List<Competency__c> records) {
      

        String userLang = UserInfo.getLanguage();

        List<Competency__c> lstComp = CompetenciesSelector.selectByCompetencyList(records);
        
        List<Data_Translation__c> lstCompTrans = DataTranslationsSelector.selectDataTransByCompetencyList(userLang, records);

        List<Skill__c> lstSkill = SkillsSelector.selectBySkillList(records);

        List<Data_Translation__c> lstSkillTrans = DataTranslationsSelector.selectDataTransBySkillList(userLang, lstSkill);

        List<Data_Translation__c> lstFinal = new List<Data_Translation__c>();
        
        //Logic in Creating Record to be Displayed in Flow
        for(Competency__c objComp : lstComp){
            Competency__c objComptemp = new Competency__c();
            Data_Translation__c objtranstemp = new Data_Translation__c();
            integer intloopcounter = 0;
            String strSkillComptran;
            if(objComp.Skill_Count__c == 0){ 
                if(!lstCompTrans.isEmpty()){
                    intloopcounter = 0; 
                    for(Data_Translation__c objComptrans : lstCompTrans){
                        if(objComptrans.Competency__c == objComp.Id){
                            objtranstemp = objComptrans;
                            objtranstemp.put('Competency__c','');
                            objtranstemp.put('Skill__c',objComp.Id);
                            lstFinal.add(objtranstemp);
                            break;
                        }
                        intloopcounter++;
                    } 
                    if(intloopcounter >= lstCompTrans.size()){
                        objtranstemp.put('Name', objComp.Name);
                        objtranstemp.put('Competency__c', '');
                        objtranstemp.put('Skill__c',objComp.Id);
                        objtranstemp.put('Learning_Description__c', objComp.Learning_Description__c);
                        objtranstemp.put('Applying_Description__c', objComp.Applying_Description__c);
                        objtranstemp.put('Mastery_Description__c', objComp.Mastery_Description__c);
                        objtranstemp.put('Id', objComp.Id);
                        lstFinal.add(objtranstemp);
                        intloopcounter = 0;
                    }   
                    continue;
                }
                else{
                    objtranstemp.put('Name', objComp.Name);
                    objtranstemp.put('Competency__c', '');
                    objtranstemp.put('Skill__c',objComp.Id);
                    objtranstemp.put('Learning_Description__c', objComp.Learning_Description__c);
                    objtranstemp.put('Applying_Description__c', objComp.Applying_Description__c);
                    objtranstemp.put('Mastery_Description__c', objComp.Mastery_Description__c);
                    objtranstemp.put('Id', objComp.Id);
                    lstFinal.add(objtranstemp);
                }  
            }
            else{
                for(Skill__c objSkill : lstSkill){
                    Data_Translation__c objSkillTranstemp = new Data_Translation__c();
                    if(objSkill.Competency__c == objComp.Id){
                         if(!lstCompTrans.isEmpty()){
                            intloopcounter = 0;
                            for(Data_Translation__c objComptrans : lstCompTrans){
                                if(objComptrans.Competency__c == objSkill.Competency__c){
                                    strSkillComptran = objComptrans.Name__c;
                                    intloopcounter = lstCompTrans.size();
                                    intloopcounter++;
                                }
                                intloopcounter++;
                            }
                            if(intloopcounter == lstCompTrans.size()){
                                strSkillComptran = objComp.Name;
                            }
                            
                        }
                        else{
                            strSkillComptran = objComp.Name;
                        }                        

                        if(!lstSkillTrans.isEmpty()){
                            intloopcounter = 0;
                            for(Data_Translation__c objSkilltrans : lstSkillTrans){
                                if(objSkilltrans.Skill__c == objSkill.Id){                        
                                    objSkillTranstemp = objSkilltrans;
                                    objSkillTranstemp.put('Competency__c', strSkillComptran);
                                    objSkillTranstemp.put('Skill__c', objSkill.Id);
                                    lstFinal.add(objSkillTranstemp);
                                    break;
                                }
                                intloopcounter++;
                            }
                            if(intloopcounter >= lstSkillTrans.size()){
                                objSkillTranstemp.put('Name__c', objSkill.Name__c);
                                objSkillTranstemp.put('Competency__c', strSkillComptran);
                                objSkillTranstemp.put('Skill__c', objSkill.Id);
                                objSkillTranstemp.put('Learning_Description__c', objSkill.Learning_Description__c);
                                objSkillTranstemp.put('Applying_Description__c', objSkill.Applying_Description__c);
                                objSkillTranstemp.put('Mastery_Description__c', objSkill.Mastery_Description__c);
                                objSkillTranstemp.put('Id', objSkill.Id);
                                lstFinal.add(objSkillTranstemp);
                                intloopcounter = 0;
                            } 
                            continue;
                        }
                        else{
                            objSkillTranstemp.put('Name__c', objSkill.Name__c);
                            objSkillTranstemp.put('Competency__c', strSkillComptran);
                            objSkillTranstemp.put('Skill__c', objSkill.Id);
                            objSkillTranstemp.put('Learning_Description__c', objSkill.Learning_Description__c);
                            objSkillTranstemp.put('Applying_Description__c', objSkill.Applying_Description__c);
                            objSkillTranstemp.put('Mastery_Description__c', objSkill.Mastery_Description__c);
                            objSkillTranstemp.put('Id', objSkill.Id);
                            lstFinal.add(objSkillTranstemp);
                        }
                    }   
                }
            }
        }
        return lstFinal;
    }

    /**     * @Description This method will get the list of Observed Competencies along with Translations, Skills and Competency IDs      
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-13-2023 
    */

    @AuraEnabled(cacheable=true)
    public static List<Observed_Competency__c> getObservedRecords(List<Data_Translation__c> lstFnlCompSkill, List<Competency__c> records){
        String userLang = UserInfo.getLanguage();
        List<Observed_Competency__c> lstObsRec = new List<Observed_Competency__c>();

        List<Competency__c> lstComp = CompetenciesSelector.selectByCompetencyList(records);
        
        List<Data_Translation__c> lstCompTrans = DataTranslationsSelector.selectDataTransByCompetencyList(userLang, lstComp);

        List<Skill__c> lstSkill = SkillsSelector.selectBySkillList(records);

        List<Data_Translation__c> lstSkillTrans = DataTranslationsSelector.selectDataTransBySkillList(userLang, lstSkill);

        for(Data_Translation__c compskill: lstFnlCompSkill)
        {
            Observed_Competency__c templstObsRec = new Observed_Competency__c();
            templstObsRec.put('Id',compskill.get('Id'));

            for(Skill__c skill: lstSkill){

                if(compskill.get('Skill__c') == skill.Id)
                {
                    templstObsRec.put('Competency__c', skill.Competency__c);
                    templstObsRec.put('Skill__c', skill.Id);
                    templstObsRec.put('Score__c','0');
                    for(Data_Translation__c translation: lstSkillTrans){
                        if(translation.Id == compskill.Id && translation.Skill__c == skill.Id){
                            templstObsRec.put('Skill_Translation__c',compskill.Id);
                            templstObsRec.put('Competency__c',skill.Competency__c);
                            templstObsRec.put('Skill__c',translation.Skill__c);
                            templstObsRec.put('Score__c','0');
                        }
                    }
                    for(Data_Translation__c translation: lstCompTrans){
                        if(translation.Competency__c == skill.Competency__c){
                            templstObsRec.put('Competency_Translation__c',translation.Id);
                        }
                    } 
                } 
            }

            for(Competency__c comp: lstComp){
                if(compskill.get('Skill__c') == comp.Id){
                    templstObsRec.put('Competency__c', comp.Id);
                    templstObsRec.put('Score__c','0');
                    for(Data_Translation__c translation: lstCompTrans){
                        if(translation.Id == compskill.Id && translation.Competency__c == comp.Id){
                            templstObsRec.put('Competency_Translation__c',translation.Id);
                            templstObsRec.put('Competency__c',translation.Competency__c);
                            templstObsRec.put('Score__c','0');
                        }
                    } 
                }
                   
            }
            lstObsRec.add(templstObsRec);
        }
        return lstObsRec;
    }     
}
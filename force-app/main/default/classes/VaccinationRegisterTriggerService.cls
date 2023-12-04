public with sharing class VaccinationRegisterTriggerService {

    @testVisible static final String VACCINATION_REGISTER_UPDATE_ERROR_ORIGIN = 'VaccinationRegisterTriggerService - afterInsert(): update VaccinationRegister__c  ';
    @testVisible static final String VACCINATION_REGISTER_UPDATE_ERROR_ORIGIN_AFTERUPDATE = 'VaccinationRegisterTriggerService - afterUpdate(): update VaccinationRegister__c  ';
   
    public static void afterInsert(List<VaccinationRegister__c> triggerNew){

        if(triggerNew.isEmpty() && triggerNew == null){
            return;
        }

        List<VaccinationRegister__c> lstVaccFinalRcnt = new List<VaccinationRegister__c>();
        Map<string,List<VaccinationRegister__c>> mapVacc = new Map<string,List<VaccinationRegister__c>>();
        Set<Id> setRecentVacRg = new Set<Id>();
        Set<String> setStrTA = new Set<String>();
        
        Set<Id> setAnmlIds = new Set<id>();
        for(VaccinationRegister__c vaccinationRegRec: triggerNew){
            setAnmlIds.add(vaccinationRegRec.Animal__c);
        }

        List<VaccinationRegister__c> lstVacc = [SELECT Id, Animal__c,Inactive__c ,Due_Date__c,Treatment__c 
                                                    FROM VaccinationRegister__c 
                                                    WHERE Due_Date__c != null AND Animal__c != null AND Animal__c IN :setAnmlIds 
                                                    ORDER BY Treatment__c,Due_Date__c];
        
        if(lstVacc.size() > 0){
            for(VaccinationRegister__c vc: lstVacc){
                string strCombo = vc.Treatment__c + '_' + vc.Animal__c;
                setStrTA.add(strCombo);
                List<VaccinationRegister__c> lstVaccMp = new List<VaccinationRegister__c>();
                lstVaccMp.add(vc);
                mapVacc.put(strCombo ,lstVaccMp);
            } 
        }
        if(setStrTA.size() > 0){
            for(string str: setStrTA){ 
                if(mapVacc.containsKey(str)){       
                    for(VaccinationRegister__c vreg: mapVacc.get(str)){
                        setRecentVacRg.add(vreg.Id);
                        break;
                    }
                }
            }
        }
        List<VaccinationRegister__c> lstVaccFinalNonRcnt = [SELECT Id, Animal__c,Due_Date__c,Treatment__c 
                                                            FROM VaccinationRegister__c 
                                                            WHERE Due_Date__c != null AND Animal__c != null 
                                                                    AND Animal__c IN :setAnmlIds AND Id NOT IN :setRecentVacRg];
        if(lstVaccFinalNonRcnt.size()>0){
            for(VaccinationRegister__c  vReg: lstVaccFinalNonRcnt){
                vReg.Inactive__c = TRUE;
            }
        }
        if(lstVaccFinalRcnt.size() > 0){
            for(VaccinationRegister__c  vReg: lstVaccFinalRcnt){
                vReg.Inactive__c = FALSE;
            }
        }

        try{
            update lstVaccFinalNonRcnt;
            update lstVaccFinalRcnt;
        }catch(DmlException dex){
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(VACCINATION_REGISTER_UPDATE_ERROR_ORIGIN);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, VACCINATION_REGISTER_UPDATE_ERROR_ORIGIN);
        }
    }

    public static void afterUpdate(List<VaccinationRegister__c> triggerNew){

        if(triggerNew.isEmpty() && triggerNew == null){
            return;
        }
        
        Map<string,List<VaccinationRegister__c>> mapVacc = new Map<string,List<VaccinationRegister__c>>();
        Set<Id> setRecentVacRg = new Set<Id>();
        Set<String> setStrTA = new Set<String>();
        Set<Id> setAnmlIds = new Set<id>();

        for(VaccinationRegister__c v: triggerNew){
            setAnmlIds.add(v.Animal__c);
        }

        List<VaccinationRegister__c> lstVacc = [SELECT Id, Animal__c,Inactive__c ,Due_Date__c,Treatment__c 
                                                    FROM VaccinationRegister__c 
                                                    WHERE Due_Date__c != null AND Animal__c != null AND Animal__c IN :setAnmlIds 
                                                    ORDER BY Treatment__c,Due_Date__c];

        if(lstVacc.size() > 0){
            for(VaccinationRegister__c vc: lstVacc){
                string strCombo = vc.Treatment__c + '_' + vc.Animal__c;
                setStrTA.add(strCombo);
                List<VaccinationRegister__c> lstVaccMp = new List<VaccinationRegister__c>();
                lstVaccMp.add(vc);
                mapVacc.put(strCombo ,lstVaccMp);
            } 
        }

        if(setStrTA.size() > 0){
            for(string str: setStrTA){ 
                if(mapVacc.containsKey(str)){
                    for(VaccinationRegister__c vreg: mapVacc.get(str)){
                        setRecentVacRg.add(vreg.Id);
                        break;
                    }
                }
            }
        }

        List<VaccinationRegister__c> lstVaccFinalNonRcnt  = [SELECT Id, Animal__c,Due_Date__c,Treatment__c,Inactive__c 
                                                                FROM VaccinationRegister__c 
                                                                WHERE Due_Date__c != null AND Animal__c != null 
                                                                    AND Animal__c IN :setAnmlIds AND Id NOT IN :setRecentVacRg];

        List<VaccinationRegister__c> lstVaccFinalRcnt = [SELECT Id, Animal__c,Due_Date__c,Treatment__c,Inactive__c 
                                                            FROM VaccinationRegister__c 
                                                            WHERE Due_Date__c != null AND Animal__c != null 
                                                                AND Animal__c IN :setAnmlIds AND Id IN :setRecentVacRg ];
        
        if(lstVaccFinalNonRcnt.size()>0){
            for(VaccinationRegister__c  vReg: lstVaccFinalNonRcnt){
                vReg.Inactive__c = true;
            }
        }
        if(lstVaccFinalRcnt.size() > 0){
            for(VaccinationRegister__c  vReg: lstVaccFinalRcnt){
                vReg.Inactive__c = false;
            }
        }
        if(CheckRecursiveTrigger.runOnce()){
            try{
                update lstVaccFinalNonRcnt;
                update lstVaccFinalRcnt;
            }
            catch(DmlException dex){
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(VACCINATION_REGISTER_UPDATE_ERROR_ORIGIN_AFTERUPDATE);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, VACCINATION_REGISTER_UPDATE_ERROR_ORIGIN_AFTERUPDATE);
            }
        }
    }
   
}
public class VaccinationRegisterAction {

    @testVisible static final String VACCINE_REGISTER_ORIGIN_TYPE = 'VaccinationRegisterAction - insertVaccRegister: update active and inactive list of vaccine registers';

    @InvocableMethod(label='update Vaccination Register' description='update  Due Date specified and returns the IDs of the Vaccination Register.')
    
    public static void insertVaccRegister(List<Id> VaccRegister) {
        boolean check_me = false; boolean updateme =false;
        string fk;
        List<VaccinationRegister__c> myvacRegister = [select animal__r.owner__r.name,Animal_Owner_Email__c,Animal_Owner__c,Animal__r.Owner__r.email__c,id,Animal__c,Treatment__c,VaccinationType2__c,clinic__r.email__c  ,VaccinationDate__c,animal__r.recordtype.name,Due_Date__c from VaccinationRegister__c where id In :VaccRegister];
        List<Vaccination_Threshold__mdt> myVThreold_list = new list<Vaccination_Threshold__mdt>([select id,DeveloperName,Animal_Type__c,Due_Date__c,Treatment__c,Vaccination_Type__c from Vaccination_Threshold__mdt ]);
        system.debug(myVThreold_list);
        
        
        
        for (VaccinationRegister__c v1 :myvacRegister){
            if (v1.animal__c !=null)
            fk = v1.animal__c;
        }
        
        List<VaccinationRegister__c> historycheck= [select id, animal__c, Treatment__c, VaccinationType2__c from VaccinationRegister__c where Treatment__c = 'Hendra' and VaccinationType2__c = 'Second Dose' and animal__c = :fk ];
        
        List<Animal__c> myanimaltoupdate = [select id, last_hendra_vaccination__c from animal__c where id = :fk];
        
        
        for (VaccinationRegister__c v :myvacRegister){
            for (Vaccination_Threshold__mdt mymdt :myVThreold_list){//&& v.Vaccination_Type__c ==mymdt.Vaccination_Type__c
                if (v.Treatment__c ==mymdt.Treatment__c  && v.animal__r.recordtype.name ==mymdt.animal_type__c && v.VaccinationType2__c ==mymdt.Vaccination_Type__c) {
                    //v.Due_Date__c = System.Today().addDays((Integer)(mymdt.Due_Date__c));
                    
                    if ((historycheck.size()>1) && (historycheck !=null) && v.treatment__c == 'Hendra' && v.VaccinationType2__c=='Second Dose'){
                        v.Due_Date__c = v.VaccinationDate__c.addDays((Integer)(mymdt.Due_Date__c)) + 182;
                    }
                    
                    else
                    {
                        v.Due_Date__c = v.VaccinationDate__c.addDays((Integer)(mymdt.Due_Date__c));
                    }
                    v.clinic_email__c = v.clinic__r.email__c;
                    v.Animal_Owner_Email__c = v.animal__r.owner__r.email__c;
                    v.Animal_Owner__c = v.animal__r.owner__r.name;
                    
                    system.debug(System.Today().addDays((Integer)(mymdt.Due_Date__c)));
                    if (mymdt.due_date__c <30) v.exception__c = true;
                }
            }
        }
        if (myvacRegister.size()>0)
        Database.SaveResult[] results = Database.update(myvacRegister);
        
        // Added by Keerthi Chandra regarding SC-004210
        try{
            List<VaccinationRegister__c> lstVacc = new List<VaccinationRegister__c>();
            List<VaccinationRegister__c> lstVaccFinalNonRcnt = new List<VaccinationRegister__c>();
            List<VaccinationRegister__c> lstVaccFinalRcnt = new List<VaccinationRegister__c>();
            Map<string,List<VaccinationRegister__c>> mapVacc = new Map<string,List<VaccinationRegister__c>>();
            Set<Id> setRecentVacRg = new Set<Id>();
            set<string> setStrTA = new set<string>();
            set<Id> setAnmlIds = new set<id>();
            
            
            for(VaccinationRegister__c v: myvacRegister){
                setAnmlIds.add(v.Animal__c);
            }
            
            lstVacc = [select Id, Animal__c,Inactive__c ,Due_Date__c,Treatment__c FROM VaccinationRegister__c WHERE Due_Date__c != null AND Animal__c != null AND Animal__c IN: setAnmlIds ORDER BY Treatment__c,Due_Date__c];
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
            lstVaccFinalNonRcnt = [select Id, Animal__c,Due_Date__c,Treatment__c FROM VaccinationRegister__c WHERE Due_Date__c != null AND Animal__c != null AND Animal__c IN: setAnmlIds AND Id Not In: setRecentVacRg];
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
            
            update lstVaccFinalNonRcnt;
            update lstVaccFinalRcnt;
        }
        catch(DmlException dex){
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(VACCINE_REGISTER_ORIGIN_TYPE);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, VACCINE_REGISTER_ORIGIN_TYPE);
        }
        
        
        
        For(animal__c myanimal :myanimaltoupdate){
            For(VaccinationRegister__c mychild :myvacRegister){
                if ( mychild.vaccinationdate__c !=null && mychild.treatment__c =='Hendra' && (myanimal.last_hendra_vaccination__c < mychild.vaccinationdate__c || myanimal.last_hendra_vaccination__c ==null)){
                    
                    // if(myanimal.last_hendra_vaccination__c == null  ||  ){
                        myanimal.last_hendra_vaccination__c = mychild.vaccinationdate__c;
                        updateme = true;  
                        //}
                    }
                }
            }
            
            if (myvacRegister.size()>0 && updateme) update myanimaltoupdate;
        }
        
    }
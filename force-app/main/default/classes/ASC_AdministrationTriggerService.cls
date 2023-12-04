public with sharing class ASC_AdministrationTriggerService {
   
    public static void beforeInsert(List<ASC_Administration__c> triggerNew){
        if(!triggerNew.isEmpty())
            populateBusinessUnit(triggerNew);
    } 

    public static void beforeUpdate(List<ASC_Administration__c> triggerNew){
        if(!triggerNew.isEmpty())
            populateBusinessUnit(triggerNew);
    }

    private static void populateBusinessUnit(List<ASC_Administration__c> triggerNew){

        /*Populating business unit */
        set<id> specieIds  = new set<id>();
        for(ASC_Administration__c asca : triggerNew){
            System.debug('$$$ asca: '+asca);
            System.debug('$$$ asca.Business_Unit__c: '+asca.Business_Unit__c);
            System.debug('$$$ asca.Species__c: '+asca.Species__c);
            if(asca.Business_Unit__c == null && asca.Species__c != null){
                specieIds.add(asca.Species__c);
            }
        }
        if(!specieIds.isEmpty()){
            map<id,ZTS_EU_Species__c> specieLst  = new map<id,ZTS_EU_Species__c>([select id, ZTS_EU_Business_Unit__c from ZTS_EU_Species__c where id=:specieIds]);
            for(ASC_Administration__c asca : triggerNew){
            if(asca.Business_Unit__c == null && asca.Species__c != null && specieLst.get(asca.Species__c)!= null){
                    asca.Business_Unit__c = specieLst.get(asca.Species__c).ZTS_EU_Business_Unit__c;
                }
            }
        }
        
        for(ASC_Administration__c asca : triggerNew){
            if(asca.Business_Unit__c != null && asca.Species__c != null){
                asca.BU_Specie_Combination__c = asca.Business_Unit__c+'-'+asca.Species__c;
            }
        }

    }
}
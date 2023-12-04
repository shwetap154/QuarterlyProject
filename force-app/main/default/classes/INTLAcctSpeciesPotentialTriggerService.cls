/****************************************************************************************************************************************** 
* Class Name   : INTLAcctSpeciesPotentialTriggerService
* Description  : Logic for all US ZTS_EU_Account_Species_Potential__c triggers housed here.
* Created By   : Slalom/Allister McKenzie 
* Created Date : 06 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                     Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Allister McKenzie(Slalom)     12/07/2020         Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public with sharing class INTLAcctSpeciesPotentialTriggerService {

    private static Map<Id, ZTS_EU_Account_Species_Potential__c> aspMap = new Map<Id, ZTS_EU_Account_Species_Potential__c>();
    private static List<SpeciesList__c> speciesSetingsList = SpeciesList__c.getAll().values();//list all custom setting records 
    private static List<String> parentSpeciesNameList = new List<String>();//list of ParentSpeciesName__c present in custom setting
    private static List<String> childSpeciesNameList = new List<String>();//list of ChildSpeciesName__c present in custom setting
    private static Map<Id,String> parentSpeciesNameMap = new Map<Id,String>();//map of species (id and name)
       
    private static  List<ZTS_EU_Account_Species_Potential__c> childSpeciesList = new List<ZTS_EU_Account_Species_Potential__c>();//list of asp to be inserted
    private static List<ZTS_EU_Account_Species_Potential__c> childSpeciesListforupdate = new List<ZTS_EU_Account_Species_Potential__c>();//list of asp records to be updated
    private static map<id,list<SpeciesList__c>> parenttochildmap = new map<id,list<speciesList__c>>();//map of (species id and customsettinglist created by this species)
    private static set<String> cusmsettinguniqueset  =new set<String>();//set of speciesname(present in custom setting)
        
    private static Map<String,Id> spainmktfulllist = new Map<String,Id>();//map of species (name and id)
    private static Map<String,id> uniquenessmap = new Map<String,id>();//map of asp(uniqueness key and id)
    private static Map<id,Double> idnummap = new Map<id,Double>();//map of asp(id and actualvaluefield)

    public static void beforeUpdate(List<ZTS_EU_Account_Species_Potential__c> triggerOld, Map<Id, ZTS_EU_Account_Species_Potential__c> triggerOldMap, List<ZTS_EU_Account_Species_Potential__c> triggerNew, Map<Id, ZTS_EU_Account_Species_Potential__c> triggerNewMap) {
        List<ZTS_EU_Account_Species_Potential__c> AscParentRecord = [select Id,Name,Account__c,updatedbyparentid__c,ZTS_EU_Animals_Consultations_actual__c, 
                                                                    ZTS_EU_Uniqueness_Key__c,ParentSpeciesid__c,ZTS_EU_Species_Potential__c 
                                                                    from ZTS_EU_Account_Species_Potential__c where Account__r.ZTS_EU_Market__c='Spain' and Id in :triggerNewMap.keySet()];
                                
        List <id> AccList = new List<id>();
        for(ZTS_EU_Account_Species_Potential__c AscAcc: AscParentRecord)
        {
            AccList.add(AscAcc.Account__c);
        }
            
        List<ZTS_EU_Account_Species_Potential__c> AllASCRecord = [select Id,Name,Account__c,updatedbyparentid__c,ZTS_EU_Animals_Consultations_actual__c, 
                                                                ZTS_EU_Uniqueness_Key__c,ParentSpeciesid__c,ZTS_EU_Species_Potential__c 
                                                                from ZTS_EU_Account_Species_Potential__c where Account__r.ZTS_EU_Market__c='Spain' and Account__c in: AccList];
                                                    
        List<ZTS_EU_Account_Species_Potential__c> AllParentChildAsc = new List<ZTS_EU_Account_Species_Potential__c>();
                AllParentChildAsc.addall(AscParentRecord);
                AllParentChildAsc.addall(AllASCRecord);
                
        Map<id,ZTS_EU_Account_Species_Potential__c> uniquemap=new Map<id,ZTS_EU_Account_Species_Potential__c>();
        for(ZTS_EU_Account_Species_Potential__c testvar:AllASCRecord){
            uniquemap.put(testvar.id,testvar);
        }
        
        Map<id,list<id>> relationalparenttochildmap=new Map<id,list<id>>();

        for(ZTS_EU_Account_Species_Potential__c test:AllParentChildAsc)
        {
            List<id> relationalparenttochildasp = new List<id>();
            for(ZTS_EU_Account_Species_Potential__c test1:AllASCRecord)
            {
                if(test1.ParentSpeciesid__c==test.id || test1.updatedbyparentid__c==test.id)
                    {
                        relationalparenttochildasp.add(test1.id);
                    }
            }
            relationalparenttochildmap.put(test.id,relationalparenttochildasp);  
        }
        
        for(ZTS_EU_Account_Species_Potential__c test: AllParentChildAsc)
        {
            idnummap.put(test.id,test.ZTS_EU_Animals_Consultations_actual__c); 
            uniquenessmap.put(test.ZTS_EU_Uniqueness_Key__c,test.id); 
        }
    //Defect: SC-003691
        
        for(SpeciesList__c sp : speciesSetingsList)
        {
            parentSpeciesNameList.add(sp.ParentSpeciesName__c);
            childSpeciesNameList.add(sp.ChildSpeciesName__c);     
        }
            
        cusmsettinguniqueset.addall(parentSpeciesNameList);
        cusmsettinguniqueset.addall(childSpeciesNameList);
        
        List<ZTS_EU_Species__c> complsplist = [SELECT Id, Name FROM ZTS_EU_Species__c WHERE ZTS_EU_Market__c = 'Spain' and name in:cusmsettinguniqueset];
        
        
        if(complsplist != null && !complsplist.isEmpty()) {
            for(ZTS_EU_Species__c sp :  complsplist  )
            {
                spainmktfulllist.put(sp.name,sp.Id);   
            }
        }
        
        List<ZTS_EU_Species__c> spParentList = [SELECT Id, Name FROM ZTS_EU_Species__c 
                                            WHERE ZTS_EU_Market__c = 'Spain' 
                                            AND Name IN : parentSpeciesNameList];
        
        
        if(spParentList != null && !spParentList.isEmpty())
        {
            for(ZTS_EU_Species__c sp :  spParentList)
            {
                parentSpeciesNameMap.put(sp.Id, sp.name);   
            }
            
        }
        
        
        for(String test : parentSpeciesNameMap.values())
        {
            list<speciesList__c> childspeciescollection =new list<speciesList__c>();
            for(SpeciesList__c sp : speciesSetingsList)
            {
                
                if(sp.ParentSpeciesName__c==test)
                {
                    childspeciescollection.add(sp);    
                }
                
            }
            parenttochildmap.put(spainmktfulllist.get(test),childspeciescollection);
        }

        System.debug('entered before update');
        List<ZTS_EU_Account_Species_Potential__c> updateasplist=new List<ZTS_EU_Account_Species_Potential__c>();
        system.debug('new values' +triggerNew);
        for(ZTS_EU_Account_Species_Potential__c asp : AscParentRecord)
        {
            Double mf;
            Double mf1;
            Double testactualval=0;
            Double testactualval1=0;
            
            if(relationalparenttochildmap.get(asp.id)!=null){
                ZTS_EU_Account_Species_Potential__c childSpecies = new ZTS_EU_Account_Species_Potential__c();
                for(id test:relationalparenttochildmap.get(asp.id))
                {  
                    childSpecies =uniquemap.get(test);
                    
                    //************* logic to update record by accessing custom setting multiplication factor
                    if(childSpecies.ParentSpeciesid__c!=null) { 
                    
                        for(speciesList__c sprecords:parenttochildmap.get((uniquemap.get(childSpecies.ParentSpeciesid__c)).ZTS_EU_Species_Potential__c))
                        {
                            if(spainmktfulllist.get(sprecords.ChildSpeciesName__c)==childSpecies.ZTS_EU_Species_Potential__c)
                            {
                                mf=sprecords.factor__c;
                                
                                //logic to incorporate update on the basis of parent id and updateid
                                if(triggerNewMap.get(childSpecies.ParentSpeciesid__c)!=null)
                                    testactualval=childSpecies.ZTS_EU_Animals_Consultations_actual__c+((triggerNewMap.get((childSpecies.ParentSpeciesid__c)).ZTS_EU_Animals_Consultations_actual__c))*mf-((triggerOldMap.get((childSpecies.ParentSpeciesid__c)).ZTS_EU_Animals_Consultations_actual__c))*mf;
                                if(childSpecies.ParentSpeciesid__c!=asp.ID)  
                                    childSpecies.updatedbyparentid__c=asp.ID;
                            }
                            
                        }
                    }

                    if(childSpecies.updatedbyparentid__c!=null) {
                        for(speciesList__c sprecords:parenttochildmap.get((uniquemap.get(childSpecies.updatedbyparentid__c)).ZTS_EU_Species_Potential__c))
                        {
                            if(spainmktfulllist.get(sprecords.ChildSpeciesName__c)==childSpecies.ZTS_EU_Species_Potential__c)
                            {
                                mf1=sprecords.factor__c;
                            
                                //logic to incorporate update on the basis of parent id and updateid
                                if(triggerNewMap.get(childSpecies.updatedbyparentid__c)!=null)
                                    testactualval1=childSpecies.ZTS_EU_Animals_Consultations_actual__c+((triggerNewMap.get(childSpecies.updatedbyparentid__c).ZTS_EU_Animals_Consultations_actual__c))*mf1-((triggerOldMap.get((childSpecies.updatedbyparentid__c)).ZTS_EU_Animals_Consultations_actual__c))*mf1;
                                if(childSpecies.ParentSpeciesid__c!=asp.id)
                                    childSpecies.updatedbyparentid__c=asp.ID;
                            }
                            
                        }
                    }
                        
                    if(childSpecies.ParentSpeciesid__c!=null && childSpecies.updatedbyparentid__c!=null && childSpecies.ParentSpeciesid__c!=childSpecies.updatedbyparentid__c)
                        childSpecies.ZTS_EU_Animals_Consultations_actual__c=testactualval+testactualval1;
                    if(childSpecies.ParentSpeciesid__c==null && childSpecies.updatedbyparentid__c!=null)
                        childSpecies.ZTS_EU_Animals_Consultations_actual__c=testactualval1;
                    if(childSpecies.ParentSpeciesid__c!=null && childSpecies.updatedbyparentid__c==null )
                        childSpecies.ZTS_EU_Animals_Consultations_actual__c=testactualval;
                    if(childSpecies.ParentSpeciesid__c!=null && childSpecies.updatedbyparentid__c!=null && childSpecies.ParentSpeciesid__c==childSpecies.updatedbyparentid__c)
                        childSpecies.ZTS_EU_Animals_Consultations_actual__c=testactualval;
                    
                    updateasplist.add(childSpecies);
                }  
            }
        }

        if(updateasplist.size()>0) 
            update(updateasplist); 
    }

    public static void beforeDelete(List<ZTS_EU_Account_Species_Potential__c> triggerOld, Map<Id, ZTS_EU_Account_Species_Potential__c> triggerOldMap) {
        List<ZTS_EU_Account_Species_Potential__c> ListAscDelete  = [select Id,Name,Account__c,updatedbyparentid__c,ZTS_EU_Animals_Consultations_actual__c, 
																		ZTS_EU_Uniqueness_Key__c,ParentSpeciesid__c,ZTS_EU_Species_Potential__c 
																		from ZTS_EU_Account_Species_Potential__c where Account__r.ZTS_EU_Market__c='Spain' and Id in:triggerOld];
            
        List <id> AccDelList = new List<id>();
        for(ZTS_EU_Account_Species_Potential__c AscDelAcc: ListAscDelete)
        {
            AccDelList.add(AscDelAcc.Account__c);
        }
        
        List<ZTS_EU_Account_Species_Potential__c> AllChildASCRecord = [select Id,Name,Account__c,updatedbyparentid__c,ZTS_EU_Animals_Consultations_actual__c, 
                                                                        ZTS_EU_Uniqueness_Key__c,ParentSpeciesid__c,ZTS_EU_Species_Potential__c 
                                                                        from ZTS_EU_Account_Species_Potential__c where Account__r.ZTS_EU_Market__c='Spain' and Account__c in: AccDelList];
                                                                        
        List<ZTS_EU_Account_Species_Potential__c> UpdateParentSpeciesId = new List<ZTS_EU_Account_Species_Potential__c>();
        List<ZTS_EU_Account_Species_Potential__c> UpdateUpdatedbyParentId = new List<ZTS_EU_Account_Species_Potential__c>();
        
        for(ZTS_EU_Account_Species_Potential__c DelAsc : ListAscDelete){
            
            for(ZTS_EU_Account_Species_Potential__c DelAscChild : AllChildASCRecord){
                
                if(DelAscChild.ParentSpeciesid__c == DelAsc.id){
                    DelAscChild.ParentSpeciesid__c = Null;
                    UpdateParentSpeciesId.add(DelAscChild);
                    
                }
                else{
                    if(DelAscChild.updatedbyparentid__c == DelAsc.id){
                        DelAscChild.updatedbyparentid__c = Null;
                        UpdateUpdatedbyParentId.add(DelAscChild);
                    }
                    }
            }
        }
        if(!UpdateParentSpeciesId.isEmpty()){
            Update UpdateParentSpeciesId;
        }
        
        if(!UpdateUpdatedbyParentId.isEmpty()){
            Update UpdateUpdatedbyParentId;
        } 
    }

    public static void afterInsert(List<ZTS_EU_Account_Species_Potential__c> triggerNew, Map<Id, ZTS_EU_Account_Species_Potential__c> triggerNewMap) {
        List<ZTS_EU_Account_Species_Potential__c> AscParentRecord = [select Id,Name,Account__c,updatedbyparentid__c,ZTS_EU_Animals_Consultations_actual__c, 
                                                                    ZTS_EU_Uniqueness_Key__c,ParentSpeciesid__c,ZTS_EU_Species_Potential__c 
                                                                    from ZTS_EU_Account_Species_Potential__c where Account__r.ZTS_EU_Market__c='Spain' and Id in:triggerNew];
                                
        List <id> AccList = new List<id>();
        for(ZTS_EU_Account_Species_Potential__c AscAcc: AscParentRecord)
        {
            AccList.add(AscAcc.Account__c);
        }
            
        List<ZTS_EU_Account_Species_Potential__c> AllASCRecord = [select Id,Name,Account__c,updatedbyparentid__c,ZTS_EU_Animals_Consultations_actual__c, 
                                                                ZTS_EU_Uniqueness_Key__c,ParentSpeciesid__c,ZTS_EU_Species_Potential__c 
                                                                from ZTS_EU_Account_Species_Potential__c where Account__r.ZTS_EU_Market__c='Spain' and Account__c in: AccList];
                                                    
        List<ZTS_EU_Account_Species_Potential__c> AllParentChildAsc = new List<ZTS_EU_Account_Species_Potential__c>();
                AllParentChildAsc.addall(AscParentRecord);
                AllParentChildAsc.addall(AllASCRecord);
                
        Map<id,ZTS_EU_Account_Species_Potential__c> uniquemap=new Map<id,ZTS_EU_Account_Species_Potential__c>();
        for(ZTS_EU_Account_Species_Potential__c testvar:AllASCRecord){
            uniquemap.put(testvar.id,testvar);
        }
        
        Map<id,list<id>> relationalparenttochildmap=new Map<id,list<id>>();

        for(ZTS_EU_Account_Species_Potential__c test:AllParentChildAsc)
        {
            List<id> relationalparenttochildasp = new List<id>();
            for(ZTS_EU_Account_Species_Potential__c test1:AllASCRecord)
            {
                if(test1.ParentSpeciesid__c==test.id || test1.updatedbyparentid__c==test.id)
                    {
                        relationalparenttochildasp.add(test1.id);
                    }
            }
            relationalparenttochildmap.put(test.id,relationalparenttochildasp);  
        }
        
        for(ZTS_EU_Account_Species_Potential__c test: AllParentChildAsc)
        {
            idnummap.put(test.id,test.ZTS_EU_Animals_Consultations_actual__c); 
            uniquenessmap.put(test.ZTS_EU_Uniqueness_Key__c,test.id); 
        }
    //Defect: SC-003691
        
        for(SpeciesList__c sp : speciesSetingsList)
        {
            parentSpeciesNameList.add(sp.ParentSpeciesName__c);
            childSpeciesNameList.add(sp.ChildSpeciesName__c);     
        }
            
        cusmsettinguniqueset.addall(parentSpeciesNameList);
        cusmsettinguniqueset.addall(childSpeciesNameList);
        
        List<ZTS_EU_Species__c> complsplist = [SELECT Id, Name FROM ZTS_EU_Species__c WHERE ZTS_EU_Market__c = 'Spain' and name in:cusmsettinguniqueset];
        
        
        if(complsplist != null && !complsplist.isEmpty()) {
            for(ZTS_EU_Species__c sp :  complsplist  )
            {
                spainmktfulllist.put(sp.name,sp.Id);   
            }
        }
        
        List<ZTS_EU_Species__c> spParentList = [SELECT Id, Name FROM ZTS_EU_Species__c 
                                            WHERE ZTS_EU_Market__c = 'Spain' 
                                            AND Name IN : parentSpeciesNameList];
        
        
        if(spParentList != null && !spParentList.isEmpty())
        {
            for(ZTS_EU_Species__c sp :  spParentList)
            {
                parentSpeciesNameMap.put(sp.Id, sp.name);   
            }
            
        }
        
        
        for(String test : parentSpeciesNameMap.values())
        {
            list<speciesList__c> childspeciescollection =new list<speciesList__c>();
            for(SpeciesList__c sp : speciesSetingsList)
            {
                
                if(sp.ParentSpeciesName__c==test)
                {
                    childspeciescollection.add(sp);    
                }
                
            }
            parenttochildmap.put(spainmktfulllist.get(test),childspeciescollection);
        }

        for(ZTS_EU_Account_Species_Potential__c asp : AscParentRecord) {
                    
            if(parenttochildmap.get(asp.ZTS_EU_Species_Potential__c)!=null)
            {
                for(SpeciesList__c splist : parenttochildmap.get(asp.ZTS_EU_Species_Potential__c)) 
                {
                    ZTS_EU_Account_Species_Potential__c childSpecies = new ZTS_EU_Account_Species_Potential__c();  
                    ZTS_EU_Account_Species_Potential__c childSpecies1 = new ZTS_EU_Account_Species_Potential__c();
                    
                    childSpecies.Account__c =childspecies1.Account__c= asp.Account__c;
                    childSpecies.ParentSpeciesid__c=asp.id;
                    childSpecies.ZTS_EU_Species_Potential__c =childspecies1.ZTS_EU_Species_Potential__c=spainmktfulllist.get(splist .ChildSpeciesName__c);
                    childSpecies.ZTS_EU_Animals_Consultations_actual__c=childSpecies1.ZTS_EU_Animals_Consultations_actual__c=asp.ZTS_EU_Animals_Consultations_actual__c *splist .factor__c;
                    
                    String uniquepair= asp.Account__c+'_'+childSpecies.ZTS_EU_Species_Potential__c;
                    if(uniquenessmap.get(uniquepair)!=null)
                    {
                        if(childSpecies.updatedbyparentid__c!=childSpecies.ParentSpeciesid__c){childSpecies1.updatedbyparentid__c=asp.id;}
                        childSpecies1.ZTS_EU_Animals_Consultations_actual__c=idnummap.get(uniquenessmap.get(uniquepair))+(asp.ZTS_EU_Animals_Consultations_actual__c *splist .factor__c);
                        childspecies1.id=uniquenessmap.get(uniquepair);
                        childSpeciesListforupdate.add(childSpecies1);
                        
                    }
                    else
                    {
                        childSpeciesList.add(childSpecies);
                    }
                }
            }
        }
        
        
        insert childSpeciesList;
        
        update childSpeciesListforupdate;
    }

}
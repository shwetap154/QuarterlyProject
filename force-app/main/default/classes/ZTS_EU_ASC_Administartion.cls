/***********************

@@ Author    : Pavan Kumar
@@ Purpose   : To display ASC parameter dynamically based on Business unit and specie.

************************/
public with sharing class ZTS_EU_ASC_Administartion {
 
    public list<selectoption> businessUnits {get; set;} // Business Unit pick list values
    public list<selectoption> species {get; set;} // Specie pick list values
    public string selectedBusinessUnits{get; set;} // Selected Business units on VF page
    public string selectedSpecie{get; set;} // Selected specie on VF page
    public string accountName {get; set;} // To display account name as command link
    public string accountId{get; set;} // Account Id, Will get value from URL
    public map<string, string> fieldLabels {get; set;}  // Field API as key and Label as value.
    public map<string, list<string>> dynamicField  {get; set;}
    public boolean showAccountSpecieParameterSection {get; set;} // Whethere ASC parameter need to display or not
    public string mode{get; set;}
    public string ascId;
    
    
    map<id, string> idName;
    
    public ZTS_EU_Account_Species_Potential__c ascObj {get; set;}
    
    list<ZTS_EU_Account_Species_Potential__c> ascLst;
    map<string,list<ZTS_EU_Account_Species_Potential__c>> businessUnitASC; // Business unit name as Key and ASC as values.
    map<string,list<ZTS_EU_Species__c>> businessUnitSpecie; // Business unit name as Key and species as values.
    list<account> accountRecord; 
    list<ZTS_EU_Species__c> specieRecord;
    string SobjectApiName;
    string commaSepratedFields;
    string loggedInUserLanguage;
    public ZTS_EU_ASC_Administartion(ApexPages.StandardController sc){
        try{
            
            dynamicField = new map<string, list<string>>();
            
            loggedInUserLanguage = UserInfo.getLanguage();
            
            showAccountSpecieParameterSection = false;
            /*start:Preparing ZTS_EU_Account_Species_Potential__c object all field API names as string*/
            SobjectApiName = 'ZTS_EU_Account_Species_Potential__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            
            commaSepratedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(commaSepratedFields == null || commaSepratedFields == ''){
                    commaSepratedFields = fieldName;
                }else{
                    commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                }
            }
            
            /*end:Preparing ZTS_EU_Account_Species_Potential__c object all field API names as string*/
            
            
            
            
            ascObj = (ZTS_EU_Account_Species_Potential__c)sc.getRecord();
             
            accountId = apexPages.CurrentPage().getParameters().get('accountId');
            mode = apexPages.CurrentPage().getParameters().get('mode');
            ascId = apexPages.CurrentPage().getParameters().get('ascId');
            
            if(ascId != null && ascId != ''){
                list<ZTS_EU_Account_Species_Potential__c> asObjLst = new list<ZTS_EU_Account_Species_Potential__c>();
                /* Querying ASC records based on account,selected business unit and specie, to check whether 
                    ASC available with this combination. If it is vailable parameters will be displayed based on querying record details  */
                string query = 'select ' + commaSepratedFields +',ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__c,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name,ZTS_EU_Business_Unit__r.ZTS_EU_Is_Active__c,ZTS_EU_Species_Potential__r.name' +' from ' + SobjectApiName + ' where id=:ascId and ZTS_EU_Business_Unit__r.ZTS_EU_Is_Active__c = true';
                asObjLst = dataBase.query(query);
                if(!asObjLst.isEmpty()){
                    ascObj = asObjLst[0];
                    selectedBusinessUnits = ascObj.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__c;
                    selectedSpecie = ascObj.ZTS_EU_Species_Potential__c;
                    displayQuetions();
                }
            }
            
            idName = new map<id, string>();
            businessUnits = new list<selectOption>();
            species = new list<selectOption>();
            ascLst = new list<ZTS_EU_Account_Species_Potential__c>();
            businessUnitASC = new map<string,list<ZTS_EU_Account_Species_Potential__c>>();
            accountRecord = new list<account>();
            specieRecord = new list<ZTS_EU_Species__c>();
            businessUnitSpecie = new map<string,list<ZTS_EU_Species__c>>();
            fieldLabels = new map<string, string>();
            
            if(accountId != null && accountId != ''){
                accountRecord = [select id, name, ZTS_EU_Market__c from account where id=:accountId AND ZTS_EU_Market__c != 'United States'];
                if(!accountRecord.isEmpty()){
                    accountName = accountRecord[0].name;
                    specieRecord = [select id,name, ZTS_EU_Market__c,ZTS_EU_Business_Unit__c, ZTS_EU_Business_Unit__r.ZTS_EU_Is_Active__c, ZTS_EU_Business_Unit__r.name from ZTS_EU_Species__c where ZTS_EU_Market__c=:accountRecord[0].ZTS_EU_Market__c and ZTS_EU_Business_Unit__r.ZTS_EU_Is_Active__c = true];
                }
                /* Preparing Specie Select Option */
                if(!specieRecord.isEmpty()){
                    for(ZTS_EU_Species__c sp : specieRecord){
                        businessUnits.add(new selectOption(sp.ZTS_EU_Business_Unit__c,sp.ZTS_EU_Business_Unit__r.name));
                        idName.put(sp.ZTS_EU_Business_Unit__c,sp.ZTS_EU_Business_Unit__r.name);
                        list<ZTS_EU_Species__c> tmpLst = new list<ZTS_EU_Species__c>();
                        tmpLst.add(sp);
                        if(businessUnitSpecie.get(sp.ZTS_EU_Business_Unit__c) != null){
                            tmpLst.addAll(businessUnitSpecie.get(sp.ZTS_EU_Business_Unit__c));
                        }
                        businessUnitSpecie.put(sp.ZTS_EU_Business_Unit__c,tmpLst);
                    }
                }
                
                ascLst = [select id, account__r.name,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name,ZTS_EU_Species_Potential__c,ZTS_EU_Species_Potential__r.name from ZTS_EU_Account_Species_Potential__c where Account__c=:accountId and ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.ZTS_EU_Is_Active__c = true];
                /* Preparing Business Unit Select Option */
                if(!ascLst.isEmpty()){
                    for(ZTS_EU_Account_Species_Potential__c ascRec : ascLst){
                        list<ZTS_EU_Account_Species_Potential__c> tmpLst = new list<ZTS_EU_Account_Species_Potential__c>();
                        if(ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name != null && ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name != '' ){
                            businessUnits.add(new selectOption(ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__c,ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name));
                            idName.put(ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__c,ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name);
                            tmpLst.add(ascRec);
                            if(businessUnitASC.get(ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name) != null){
                                tmpLst.addAll(businessUnitASC.get(ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name));
                            }
                            businessUnitASC.put(ascRec.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__c,tmpLst);
                        }
                    }
                }
            }
            
            
            // Removing duplicate value from selectoption "businessUnits" and sorting by labels
            if(!businessUnits.isEmpty()){
                set<selectOption> tmp = new set<selectOption>();
                tmp.addAll(businessUnits);
                list<selectOption> tmp1 = new list<selectOption>();
                tmp1.addAll(tmp);
                businessUnits.clear();
                businessUnits.addAll(doSort(tmp1));
                
            }
        }catch(Exception e){
            system.debug('Exception ----'+e.getMessage());
        }
    }
    
    /*Below method will return list if specie values based on selected business unit  */
    public pageReference refreshSpecies(){
        try{
            showAccountSpecieParameterSection = false;
            species = new list<selectOption>();
            system.debug('selectedBusinessUnits>>>>'+selectedBusinessUnits);
            if(selectedBusinessUnits != null && selectedBusinessUnits != ''){
                if(businessUnitASC.get(selectedBusinessUnits) != null){
                    for(ZTS_EU_Account_Species_Potential__c ascRec : businessUnitASC.get(selectedBusinessUnits)){
                        species.add(new selectOption(ascRec.ZTS_EU_Species_Potential__c,ascRec.ZTS_EU_Species_Potential__r.name));
                        idName.put(ascRec.ZTS_EU_Species_Potential__c,ascRec.ZTS_EU_Species_Potential__r.name);
                    }
                }
                if(businessUnitSpecie.get(selectedBusinessUnits) != null){
                    for(ZTS_EU_Species__c specie : businessUnitSpecie.get(selectedBusinessUnits)){
                        species.add(new selectOption(specie.id,specie.name));
                        idName.put(specie.id,specie.name);
                    }
                } 
            }
            system.debug('species>>>>'+species);
            // Removing duplicate value from selectoption "species"
            if(!species.isEmpty()){
                set<selectOption> tmp = new set<selectOption>();
                tmp.addAll(species);
                list<selectOption> tmp1 = new list<selectOption>();
                tmp1.addAll(tmp);
                species.clear();
                species.addAll(doSort(tmp1));
            }
        }catch(Exception e){
            system.debug('Exception ----'+e.getMessage());
        }
        return null;
    }
    
    //Below method is used to avoid duplicate values and Sort by labels in select option
    public list<selectOption> doSort(list<Selectoption> opts) {
        Map<String, Selectoption> mapping = new Map<String, Selectoption>();
        list<selectOption> sortedList = new list<selectOption>();
        integer i =1;
        for (Selectoption opt : opts) {
                string label = opt.getLabel()+ '-'+i;
                mapping.put(label,opt);   
                i++;
        }
        
        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());
        sortKeys.sort();
        for (String key : sortKeys) {
            sortedList.add(mapping.get(key));
        }
        return sortedList;
    }
    
    
    /*Preparing paramets details to display on VF page , based on selected Business unit and specie  */
    public pageReference displayQuetions(){
        try{
            system.debug('selectedSpecie>>>'+selectedSpecie);
            system.debug('selectedBusinessUnits>>>'+selectedBusinessUnits);     
            fieldLabels = new map<string, string>();
            dynamicField = new map<string, list<string>>();
            
            
            
            if(selectedBusinessUnits != null && selectedSpecie != null){
                showAccountSpecieParameterSection = true;
                string combination = selectedBusinessUnits+'-'+selectedSpecie;
                if(mode != 'Detail'){
                    list<ZTS_EU_Account_Species_Potential__c> asObjLst = new list<ZTS_EU_Account_Species_Potential__c>();
                    /* Querying ASC records based on account,selected business unit and specie, to check whether 
                        ASC available with this combination. If it is vailable parameters will be displayed based on querying record details  */
                    string query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' where Account__c=:accountId and ZTS_EU_Species_Potential__c=:selectedSpecie and ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__c=:selectedBusinessUnits';
                    asObjLst = dataBase.query(query);
                    if(!asObjLst.isEmpty()){
                        ascObj = asObjLst[0];
                    }else{ //Added by Shefali for DEF-001527
                        ascObj = new ZTS_EU_Account_Species_Potential__c();
                    }
                    
                }
                system.debug('combination>>'+combination);
                list<ASC_Administration__c> ascAdm = new list<ASC_Administration__c>([select Group_Order__c,Order__c,id,Group__c, name, BU_Specie_Combination__c,API_Name__c, Label__c from ASC_Administration__c where BU_Specie_Combination__c=:combination and User_Language__c=:loggedInUserLanguage and User_Visible__c=true order by Order__c]);
                for(ASC_Administration__c ascrec : ascAdm){
                    system.debug('Order__c>>>>>'+ascrec.Order__c);
                    list<string> tmp = new list<string>();
                    if(ascrec.Group_Order__c != null){
                        if(dynamicField.get(string.valueOf(ascrec.Group_Order__c)) != null){
                            tmp.addAll(dynamicField.get(string.valueOf(ascrec.Group_Order__c)));
                        }
                        tmp.add(ascrec.API_Name__c);
                        dynamicField.put(string.valueOf(ascrec.Group_Order__c),tmp);
                    }
                    
                    fieldLabels.put(ascrec.API_Name__c,ascrec.Label__c);
                }
                
                system.debug('fieldLabels>>>'+fieldLabels);
                system.debug('dynamicField>>>'+dynamicField);
            }
        }catch(Exception e){
            system.debug('Exception ----'+e.getMessage());
        }
        return null;
    }
    
    
    public pageReference updateRecord(){
        try{ 
            
            if(ascObj.Account__c == null){
                ascObj.Account__c = accountId;
                ascObj.ZTS_EU_Species_Potential__c = selectedSpecie;
            }
            upsert ascObj;
            /*Navigating to ASC detail page, if user landed on this page from ASC detail page*/
            if(mode == 'Detail'){
                return new pageReference('/'+ascObj.id);
            }else{
                /*Navigating to this page again, if user landed on this page from Account detail page */
                pageReference pf = new pageReference('/apex/ZTS_EU_ASC_Administartion?accountId='+accountId);
                pf.setRedirect(true);
                return pf;
            }
        }catch(exception e){
            system.debug('Exception while upserting record'+e.getMessage());
            return null;
        }
        
    }
    
    public class wrapper{
        public string api {get; set;}
        public string groupName {get; set;}
        public wrapper(string api ,string groupName){
            this.api = api;
            this.groupName = groupName;
        }
        
    }
    
}
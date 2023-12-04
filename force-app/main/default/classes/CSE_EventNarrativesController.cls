/**
* @ClassName    : CSE_EventNarrativesController
* @JIRATicket   : CSE-231
* @CreatedOn    : 7/1/2021
* @CreatedBy    : Madhu Goriparthi
* @Description  : Has the logic to merge fields based on user input and CMT. 
**/
public class CSE_EventNarrativesController {
    
    //Get Event Narrative Text from Custom Metadata    
    public static List<ZTS_US_Event_Narrative_Template__mdt> getEventNarratives(){
        List<ZTS_US_Event_Narrative_Template__mdt> listEventNarratives = [SELECT Id,ZTS_US_Template_Text__c,ZTS_US_Merge_Text__c
                                                                          
                                                                          FROM ZTS_US_Event_Narrative_Template__mdt];
        return listEventNarratives;
    }
    
    public static void updateEventNarrative(Set<ZTS_US_Event_Narrative__c> eventNarratives){
        
        //try{
            Id[] enIds = new Id[]{};
            for(ZTS_US_Event_Narrative__c eventNarrative: eventNarratives){
                enIds.add(eventNarrative.Id);
            }
            // Get fields from Case Products and Case
            Map<Id,Case> caseMap = new Map<Id,Case>([SELECT Id,CreatedDate,ZTS_EU_Sub_Type__c,ZTS_US_Event_Narrative__c,
                            (SELECT Id,ZTS_US_Contact_Role__c FROM Case_Contacts__R),
                            (SELECT Id,ZTS_US_Misuse_Types__c,ZTS_US_Formulation_PV__c,
                                ZTS_US_PVW_Product__r.Name,ZTS_US_Serial_Number__c,
                                ZTS_US_Product_problem_type__c,ZTS_US_Product_Lot__c,
                                ZTS_US_Previous_Exposure__c 
                                FROM Case_Products__r),
                            (SELECT Id,ZTS_US_Animal__c,ZTS_US_Animal_condition_prior_treatment__c FROM Case_Animals__R)
                            FROM Case WHERE ZTS_US_Event_Narrative__c in :enIds]);
            
            if(caseMap!=null && !caseMap.isEmpty()){
                Set<Id> animalIdsToQuery = new Set<Id>();
                Map<Id,ZTS_US_Animal__c> animalMap;
                for(Case queriedCase : caseMap.values()){
                    if(queriedCase.Case_Animals__r!=null && !queriedCase.Case_Animals__r.isEmpty() && !animalIdsToQuery.contains(queriedCase.Case_Animals__r[0].ZTS_US_Animal__c)){
                        animalIdsToQuery.add(queriedCase.Case_Animals__r[0].ZTS_US_Animal__c);
                    }
                }
                if(!animalIdsToQuery.isEmpty()){
                    animalMap = new Map<Id,ZTS_US_Animal__c>([SELECT Id,ZTS_US_Species__c from ZTS_US_Animal__c WHERE Id in :animalIdsToQuery]);
                }
                for(ZTS_US_Event_Narrative__c eventNarrative: eventNarratives){
                    Case caseRecord = caseMap.get(eventNarrative.ZTS_US_Case__c);
                    ZTS_US_Animal__c animalRecord;
                    ZTS_US_Case_Animal__c caseAnimalRecord;
                    if(caseRecord.Case_Animals__R!= null && !caseRecord.Case_Animals__R.isEmpty()){
                        caseAnimalRecord = caseRecord.Case_Animals__r[0];
                        if(caseAnimalRecord!=null && animalMap!=null && animalMap.containsKey(caseAnimalRecord.ZTS_US_Animal__c)){
                            animalRecord = animalMap.get(caseAnimalRecord.ZTS_US_Animal__c);
                        }
                    }
                    
                    String template = eventNarrative.ZTS_US_Event_Narrative_Summary_Field__c;
                    // Setting the feild values from Animal and replacing the null value with a text
                    If(animalRecord!=null && caseAnimalRecord!=null){
                        if(animalRecord.ZTS_US_Species__c!=null){
                            template = template.replace('{species}', animalRecord.ZTS_US_Species__c);
                        }
                        if(String.isNotBlank(caseAnimalRecord.ZTS_US_Animal_condition_prior_treatment__c)){
                            template = template.replace('{HealthStatus}', caseAnimalRecord.ZTS_US_Animal_condition_prior_treatment__c);
                        }
                    }
                    
                    if(caseRecord != null && template !='' && template !=null){
                        template = caseValueAssignment(template,caseRecord);  
                        system.debug('template: '+template);
                        if(template.contains('{') || template.contains('}')){
                            system.debug('template failure: '+template);
                            eventNarrative.addError('We were unable to match data to all merge fields.  Please ensure the required data has been entered for each merge field.');
                        }
                        else{
                            eventNarrative.ZTS_US_Event_Narrative_Summary_Field__c =  template;
                        }
                    }
                }//for(ZTS_US_Event_Narrative__c eventNarrative
            }
            
            
        
        /*}
        catch(Exception ex){
            System.debug('=='+ex.getMessage());
        }  */
        
    }
    
    /* assigning values to template on event narrative object*/
    
    public static String caseValueAssignment(String template,Case caseRecord){
        
        Map<String,String> mapTemplateFieldNameToFieldApiName = new Map<String,String>();
        //get mapping from event narrative template metadata data
        List<ZTS_US_Event_Narrative_Template__mdt> listEventNarrative = getEventNarratives();
        for (ZTS_US_Event_Narrative_Template__mdt Narrativrec: listEventNarrative){
            mapTemplateFieldNameToFieldApiName.put(Narrativrec.ZTS_US_Template_Text__c,Narrativrec.ZTS_US_Merge_Text__c);
        }  
        system.debug('=====mapTemplateFieldNameToFieldApiName====='+mapTemplateFieldNameToFieldApiName);
        //Assigning values to respective sobject list
        sobject recs = caseRecord;
        List<sobject> Case_Contacts = recs.getSobjects('Case_Contacts__R');
        List<sobject> Case_Products = recs.getSobjects('Case_Products__r');
        SObjectType objToken = Schema.getGlobalDescribe().get('Case'); 
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        System.debug('========recs==='+recs);
        String misuseType = ''; 
        String productname ='';
        String problementype ='';
        //iterating over the field to be replace
        for(String fieldName : mapTemplateFieldNameToFieldApiName.keyset()){
            String fieldApiName = mapTemplateFieldNameToFieldApiName.get(fieldName);
  
            //mapping all the case fields

                if (template!= null && template!= '' && fieldName!= null && fieldName!= '' && fieldApiName!= null && fieldApiName!='' &&
                    fieldApiName.contains('Case.') && template.contains(fieldName) && fieldApiName.contains('.') && recs.get(fieldApiName.substringAfter('.'))  != null){
                    system.debug('======+++'+recs.get(fieldApiName.substringAfter('.')));
                    if(fieldName == '{Date}'){
                       template = template.replace(fieldName, date.valueOf((recs.get(fieldApiName.substringAfter('.')))).format()); 
                    }else{
                      template = template.replace(fieldName, String.valueOf(recs.get(fieldApiName.substringAfter('.'))));  
                    }
                }
          
            
            //mapping all the Case_Contacts fields
            if (Case_Contacts!= null && !Case_Contacts.isEmpty() && fieldApiName.contains('Case_Contact__c.') && template.contains(fieldName) && Case_Contacts[0].get(fieldApiName.substringAfter('.'))  != null
                && Case_Contacts[0].get(fieldApiName.substringAfter('.'))  != ''){
                system.debug('======+++'+Case_Contacts[0].get(fieldApiName.substringAfter('.')));
                template = template.replace(fieldName, String.valueOf(Case_Contacts[0].get(fieldApiName.substringAfter('.'))));
            }
             
            if (Case_Products != null && !Case_Products.isEmpty()){
                //Create MisuseType, Product Name, Lot Number and Serial Number Commaseprated string from Case Product
               
                //mapping all the Case_Products fields
                for(Sobject  caseProductRec : Case_Products){
                    if(fieldName == '{Product(s)}' && caseProductRec.getSObject('ZTS_US_PVW_Product__r') != null){
                        SObject PVWProduct = caseProductRec.getSObject('ZTS_US_PVW_Product__r');
                        productname = productname + ',' + (String) PVWProduct.get('Name');
                        
                    }
                    //making misusetype comma seprated 
                    If(fieldName == '{Misuse Type}' && caseProductRec.get(fieldApiName.substringAfter('.'))!= null){
                        misuseType = misuseType + ',' + String.valueOf(caseProductRec.get(fieldApiName.substringAfter('.')));
                    }
                    
                    If(fieldName == '{Case Type}' && caseProductRec.get(fieldApiName.substringAfter('.'))!= null){
                        problementype = problementype + ',' + String.valueOf(caseProductRec.get(fieldApiName.substringAfter('.')));
                    }
                    system.debug('======+++'+misuseType);
                }
                System.debug('1111=====Case_Products========='+Case_Products);
                if (Case_Products != null && !Case_Products.isEmpty() && fieldApiName.contains('ZTS_US_Case_Product__c.') ){
    
                    //Replacing MisuseType
                    if(fieldName == '{Misuse Type}' && template.contains(fieldName)){
                        if(misuseType.contains(','))
                        template = template.replace(fieldName, misuseType.substringAfter(',')); 
                    }//Replacing MisuseType
                    else If(fieldName == '{Product(s)}' && template.contains(fieldName)){
                        if(productname.contains(','))
                        template = template.replace(fieldName, productname.substringAfter(',')); 
                    }//Replacing other fields values on Case product
                    else if(template.contains(fieldName)){
                         if(problementype.contains(','))
                        template = template.replace(fieldName, problementype.substringAfter(',')); 
                    }
                    
                    
                    
                }
            }
            
            
        }
        return template;
    }
}
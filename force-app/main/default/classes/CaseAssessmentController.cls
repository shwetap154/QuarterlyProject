/**********************************************************************************************************
* File Name     :  CaseAssessmentController
* Description   :  Controller class to create Local and Product Assessment records on a Case for CSE Project
* @author       :  Slalom Consulting
* Modification Log
===================================================================================================
* Ver.    Date              Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/1/2021          Apurva Verma            Created the Controller class.

***************************************************************************************************************/
public with sharing class CaseAssessmentController 
{
    private static Boolean IS_LOCAL_SERIOUS = false;
    private static String REC_TYPE_DEV_NAME_LOCAL = 'ZTS_US_Local_Assessment';
    private static String REC_TYPE_DEV_NAME_PRODUCT = 'ZTS_US_Product_Assessment';
    private static String localAssessmentRT = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByName().get('Local Assessment').getRecordTypeId();
    private static String productAssessmentRT = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByName().get('Product Assessment').getRecordTypeId();


    //Check to see if Local Assessment record already exists 
    public static Map<String,ZTS_US_Assessment__c> checkExistingLocalAssessmentRecords(Id caseId, String recTypeDevName)
    {
        //Create a Set to store existing Local Assessment records
        Map<String,ZTS_US_Assessment__c> existingLocalAssessment =  new Map<String,ZTS_US_Assessment__c>();
        try 
        { 
            //Create a List of existing Local Assessment records
            List<ZTS_US_Assessment__c> listOfExistingLocalAssessments = [ SELECT Id,
                                                                    ZTS_US_Local_Assessment__c,
                                                                    RecordType.Name, 
                                                                    RecordType.DeveloperName,
                                                                    RecordTypeId,
                                                                    (SELECT Id,ZTS_US_Assessment__c,ZTS_US_PVW_Product__c,
                                                                            ZTS_US_PVW_Product__r.Name,ZTS_US_PVW_Product__r.Product_Agency__c
                                                                     FROM Assessment_Products__r)
                                                                FROM ZTS_US_Assessment__c 
                                                                WHERE ZTS_US_Case__c =: caseId 
                                                                AND RecordTypeId =: localAssessmentRT ];
                                                                //AND RecordType.DeveloperName =: recTypeDevName ];

            //Loop through the existing Local Assessment records and store them in the set
            for(ZTS_US_Assessment__c assessRec : listOfExistingLocalAssessments)
            {
                if(recTypeDevName != null && assessRec.RecordType.DeveloperName == REC_TYPE_DEV_NAME_LOCAL)
                {
                    existingLocalAssessment.put(assessRec.ZTS_US_Local_Assessment__c,assessRec);
                } 
            } 
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }         
        return existingLocalAssessment;
    }

    //Check to see if Product Assessment record already exists 
    
    public static Set<String> checkExistingProductAssessmentRecords(Id caseId, String recTypeDevName)
    {
        //Create a Set to store existing Product Assessment records
        Set<String> existingProdAssessments =  new Set<String>();
        try 
        { 
            //Create a List of existing Local Assessment records
            List<ZTS_US_Assessment__c> listOfExistingProductAssessments = [ SELECT Id,
                                                                    RecordType.Name, 
                                                                    RecordType.DeveloperName,
                                                                    RecordTypeId,
                                                                    (
                                                                        SELECT Id, ZTS_US_PVW_Product__c
                                                                        FROM Assessment_Products__r
                                                                    ) 
                                                                FROM ZTS_US_Assessment__c 
                                                                WHERE ZTS_US_Case__c =: caseId 
                                                                AND RecordTypeId =: productAssessmentRT ];

            //Loop through the existing Local Assessment records and store them in the set
            for (ZTS_US_Assessment__c assessment: listOfExistingProductAssessments)
            {
                //Loop through the list of existing product assessment records and store them in the Set
                for(ZTS_US_Assessment_Products__c assessProds : assessment.Assessment_Products__r)
                {
                        existingProdAssessments.add(assessProds.ZTS_US_PVW_Product__c); 
                }
            }
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }     
        return existingProdAssessments; 
    }

    //Method to create New Local Assessment Records

    @AuraEnabled
    public Static Boolean createLocalAssessment (String caseIdVal) 
    {
        //this will tell the LWC that something was created, whether it be new assessments or new assessment products
        Boolean recordsCreated = false;
        //Set of String to check and store the existing agencies on the Local Assessment record
        Map<String,ZTS_US_Assessment__c> existingAgencies = checkExistingLocalAssessmentRecords(caseIdVal,REC_TYPE_DEV_NAME_LOCAL);
        system.debug('existingAgencies: '+existingAgencies.keySet());
        Map<Id,Set<Id>> assessmentPVWProductIdsByAssessmentId = new Map<Id,Set<Id>>();
        //organize all of the existing assessment products into a map of assessment ID->pvwProductId
        if(existingAgencies!=null && !existingAgencies.isEmpty()){
            for(ZTS_US_Assessment__c existingAssessment : existingAgencies.values()){
                if(existingAssessment.Assessment_Products__r!=null && !existingAssessment.Assessment_Products__r.isEmpty()){
                    for(ZTS_US_Assessment_Products__c existingAssessmentProduct : existingAssessment.Assessment_Products__r){
                        system.debug('found assessmentProduct for: '+existingAssessmentProduct.ZTS_US_PVW_Product__r.Name);
                        if(assessmentPVWProductIdsByAssessmentId.containsKey(existingAssessment.Id)){
                            Set<Id> pvwProdIds = assessmentPVWProductIdsByAssessmentId.get(existingAssessment.Id);
                            pvwProdIds.add(existingAssessmentProduct.ZTS_US_PVW_Product__c);
                            assessmentPVWProductIdsByAssessmentId.put(existingAssessment.Id,pvwProdIds);
                        }
                        else{
                            assessmentPVWProductIdsByAssessmentId.put(existingAssessment.Id,new Set<Id>{existingAssessmentProduct.ZTS_US_PVW_Product__c});
                        }
                    }
                }
            }
        }
        system.debug('assessmentPVWProductIdsByAssessmentId: '+assessmentPVWProductIdsByAssessmentId);

        //Query on Case to get Event Narrative for Vedra codes 
        Case aCase = [ SELECT Id, ZTS_US_Event_Narrative__c FROM Case WHERE ID=: caseIdVal ];

        //Check to see if Evenet Narrative is not null
        if(aCase.ZTS_US_Event_Narrative__c != null)
        {
            //Create a List of Veddra events associated to the Event Narrative on the Case
            //Get Veddra Codinng and see if it marked as "Is Serious" or not
            List<ZTS_US_VedDRA_Event__c> veddraEvents = [ SELECT Id, 
                                                    Name, 
                                                    ZTS_US_Event_Narrative__c,
                                                    ZTS_US_VedDRA_Coding__r.ZTS_US_Is_Serious__c
                                                FROM ZTS_US_VedDRA_Event__c 
                                                WHERE ZTS_US_Event_Narrative__c =: aCase.ZTS_US_Event_Narrative__c ];

            //Loop through the Veddra events to see if veddra codes are present and if any of them is marked as "Is Serious"
            for(ZTS_US_VedDRA_Event__c vedEvents : veddraEvents)
            {
                if((vedEvents.ZTS_US_VedDRA_Coding__c != null) && (vedEvents.ZTS_US_VedDRA_Coding__r.ZTS_US_Is_Serious__c == 'Yes'))
                {
                    IS_LOCAL_SERIOUS = true;
                    break;
                }
            }
        }

        //Create a Map with a list of Products mapped by their agency
        Map<String, Set<Id>> agencyToProducts = new Map<String, Set<Id>>();

        //Loop through Case Products on the Case and fill the set with agencies

        for(ZTS_US_Case_Product__c caseProds : [ SELECT Id, ZTS_US_Product_Agency__c, ZTS_US_Product_Role__c, ZTS_US_PVW_Product__c, ZTS_US_PVW_Product__r.Name
                                                    FROM ZTS_US_Case_Product__c 
                                                    WHERE ZTS_US_Case__c =: caseIdVal and ZTS_US_Product_Role__c != 'Concomitant' ]){        
            //If the agency key already exists then get the list of products that already exists
            if(agencyToProducts.containsKey(caseProds.ZTS_US_Product_Agency__c))
            {
                Set<Id> prodIds = agencyToProducts.get( caseProds.ZTS_US_Product_Agency__c );
                prodIds.add(caseProds.ZTS_US_PVW_Product__c);
                agencyToProducts.put(caseProds.ZTS_US_Product_Agency__c, prodIds);
            }else
            {
                //Else create a new list of product ids mapped by their agency
                Set<Id> newProdIds = new Set<Id>();
                newProdIds.add(caseProds.ZTS_US_PVW_Product__c);
                agencyToProducts.put(caseProds.ZTS_US_Product_Agency__c, newProdIds);
            }
        }
        system.debug('agencyToProducts: '+agencyToProducts.keySet());

        //Get Local Assessment record type
        Id localAssessmentRT = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByName().get('Local Assessment').getRecordTypeId();

        // Create a map of product agencies to their assessments
        Map<String, ZTS_US_Assessment__c> agencyToAssessment = new Map<String, ZTS_US_Assessment__c>();

        // Loop through the Set of Agencies to create Local Assessment records for each agency 
        try{
            for(String localAssessmentAgency : agencyToProducts.keySet()) {
                if(existingAgencies == null || (existingAgencies!= null && !existingAgencies.containsKey(localAssessmentAgency)))
                {
                    ZTS_US_Assessment__c assessmentLocal = new ZTS_US_Assessment__c();
                    assessmentLocal.ZTS_US_Case__c = caseIdVal;
                    assessmentLocal.RecordTypeId = localAssessmentRT;
                    assessmentLocal.ZTS_US_Local_Assessment__c = localAssessmentAgency;
                    if(IS_LOCAL_SERIOUS)
                    {
                        assessmentLocal.ZTS_US_Is_it_serious__c = 'Yes' ;
                    }
                    agencyToAssessment.put(localAssessmentAgency, assessmentLocal);
                }
            }
        }
        catch (Exception e) 
		{
            system.debug('error in assessment loop: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        // lets insert the value list behind the map
        if(!agencyToAssessment.isEmpty()){
            insert agencyToAssessment.values();
            recordsCreated = true;
        }
        
        if(existingAgencies != null && !existingAgencies.isEmpty()){
            agencyToAssessment.putAll(existingAgencies);
        }
        system.debug('agencyToAssessment after merging existing: '+agencyToAssessment.keySet());

        //Create a list of Assessment Products to be inserted alongside the assessments
        List<ZTS_US_Assessment_Products__c> assessmentProductsToInsert = new List<ZTS_US_Assessment_Products__c>();

        //Take all assessments and make sure they have the correct assessment products
        try
        {
            for(ZTS_US_Assessment__c assessment : agencyToAssessment.values()){
                Set<Id> prods = agencyToProducts.get(assessment.ZTS_US_Local_Assessment__c);
                if(assessmentPVWProductIdsByAssessmentId.containsKey(assessment.Id)){
                    //get the pvw product IDs of all assessment products already created 
                    Set<Id> existingAssessmentProductPVWIds = assessmentPVWProductIdsByAssessmentId.get(assessment.Id);
                    prods.removeAll(existingAssessmentProductPVWIds);
                }
                if(!prods.isEmpty()){
                    for(String productIdNeedingAssessment: prods){
                        ZTS_US_Assessment_Products__c assessmentProduct = new ZTS_US_Assessment_Products__c();
                        assessmentProduct.ZTS_US_PVW_Product__c = productIdNeedingAssessment;
                        assessmentProduct.ZTS_US_Assessment__c = assessment.Id;
                        assessmentProductsToInsert.add(assessmentProduct);
                    }
                }
            }
            if(!assessmentProductsToInsert.isEmpty()){
                insert assessmentProductsToInsert;
                recordsCreated = true;
            }
        }
        catch (Exception e) 
		{
            system.debug('error in assessment product loop: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return recordsCreated;
    }
    
    //Method to create Product Assessment Records

    @AuraEnabled
    public Static List<ZTS_US_Assessment__c> createProductAssessment (String caseIdVal) 
    {
        Id productAssessmentRT = Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByName().get('Product Assessment').getRecordTypeId();

        // set a savepoint because we're dmling on parents and children
        Savepoint sp = Database.setSavepoint();

        try
        {
            Set<String> existingProductAssessments = checkExistingProductAssessmentRecords(caseIdVal,REC_TYPE_DEV_NAME_PRODUCT);

            //Create an empty Set of Products associated to Case Products
            Set<String> prods = new Set<String>();

            //Loop through Case Products on the Case and fill the set with products associated to Case Products
            for(ZTS_US_Case_Product__c caseProducts : [ SELECT Id, ZTS_US_PVW_Product__c, ZTS_US_PVW_Product__r.Name, ZTS_US_Product_Role__c
                                                        FROM ZTS_US_Case_Product__c 
                                                        WHERE ZTS_US_Case__c =: caseIdVal])
            {                
                if(caseProducts.ZTS_US_Product_Role__c != 'Concomitant')
                {
                    prods.add(caseProducts.ZTS_US_PVW_Product__c);
                }
            }

            //Create a List of Product Assessments to be inserted 
            List<ZTS_US_Assessment__c> productAssessmentsList = new List<ZTS_US_Assessment__c>();
            List<ZTS_US_Assessment_Products__c> productAssessmentsChildList = new List<ZTS_US_Assessment_Products__c>();

            // declare a map to hold assesment -> product
            Map<String, ZTS_US_Assessment__c> productsToAssessments = new Map<String, ZTS_US_Assessment__c>();
            for ( String existingProds : prods )
            {
                if ( !existingProductAssessments.contains( existingProds ) )
                {
                    //Create Product Assessment Records
                    ZTS_US_Assessment__c productAssessment = new ZTS_US_Assessment__c();
                    productAssessment.ZTS_US_Case__c = caseIdVal;
                    productAssessment.RecordTypeId = productAssessmentRT;
                    productsToAssessments.put( existingProds, productAssessment );
                }
            }

            // if we didn't need to create any product assessments, just return null here and break out of the function
            if ( productsToAssessments.isEmpty() )
            {
                return null;
            }
            
            // lets insert the value list behind the map
            insert productsToAssessments.values();

            // lets iterate over the map and build our assessment products
            for ( String key : productsToAssessments.keySet() )
            {
                ZTS_US_Assessment__c assessmentRecord = productsToAssessments.get( key );

                // lets create the child assessment product record 
                ZTS_US_Assessment_Products__c assessmentProduct = new ZTS_US_Assessment_Products__c();
                assessmentProduct.ZTS_US_PVW_Product__c = key;
                assessmentProduct.ZTS_US_Assessment__c = assessmentRecord.Id;
                productAssessmentsChildList.add( assessmentProduct );               
            }
            insert productAssessmentsChildList;

            return productsToAssessments.values();
         }
       catch (Exception e) 
		{
            Database.rollback( sp );
            throw new AuraHandledException(e.getMessage());
        }
    }
}
public class CSE_AbstractSummaryController
{
    // constants to represent tags for VEDDRA requirement or not 
    public static final String IGNORE_VEDDRA = 'Ignore';
    public static final String VEDDRA_REQUIRED = 'Required';
    public static final String VEDDRA_NOT_REQUIRED = 'Not Required';
    
    // constants to represent tags to merge our fields into the template text
    public static final String FILLING_PACKAGING_ISSUE_TAG = '<<PRODUCT_DEFECTS2>>';
    public static final String OUTCOME_OF_REACTION_TAG = 'ZTS_US_Event_Narrative__c.ZTS_US_Outcome_of_Reaction__c';
    public static final String PROBLEM_TYPE_OTHER_THAN_AE_TAG = '<<PROBLEM TYPE_OTHER_THAN_AE>>';
    public static final String PRODUCT_NAMES_TAG = 'ZTS_US_Case_Product__c.ZTS_US_PVW_Product__c';
    public static final String PRODUCT_DEFECT_TAG = '<<PRODUCT_DEFECTS1>>';
    public static final String SPECIES_TAG = 'ZTS_US_Animal__c.ZTS_US_Species__c';
    public static final String VEDDRA_CODING_TAG = 'ZTS_US_VedDRA_Event__c.ZTS_US_VedDRA_Coding__c';
    public static final String ADVERSE_REACTION = 'Adverse Reaction';
    public static final String ASSOCIATED_PRODUCT = '(Associated) Product Defect';  
    public static final String YES = 'Yes';
   
    //TPDEV-601 Added
    public static final String ANIMAL_CONDITION_PRIOR_TREAT = 'ZTS_US_Case_Animal__c.ZTS_US_Animal_condition_prior_treatment__c';
    public static final String CONCOMITANT_TAG = '<<CONCOMITANT_PRODUCT>>';
    public static final String IF_PATIENT_TREATED = '<<WAS_REACTION_TREATED>>';
    public static final String WAS = ' was';
    public static final String WERE = ' were';
    public static final String CONCOMITANT_PRODUCT_PRESENT = ' given concomitantly';
    public static final String CONCOMITANT_PRODUCT_ABSENT = ' No concomitant products were reported';
    public static final String NOT_CLAUSE = ' not';
    public static final String LOE_REASON = 'ZTS_US_Case_Product__c.ZTS_US_LOE_Reason__c'; 
    public static final String LACK_OF_EFFICACY = 'Lack of Efficacy';
    public static final String EXTRA_LABEL_USE_STR = 'This represents an extra label use of ';
    public static final String FOR_CLAUSE = ' for ';
    public static final String NO = 'No';
    public static final String EXTRA_LABEL_USE = '<<EXTRA_LABEL_USE>>';
    public static final String PATIENT_TREATED = ' The patient was';
    public static final String TREATED = ' Treated';
    
    //TPDEV-1814 Added
    public static final String DATE_TAG = '<<DATE>>';
    public static final String PRIMARY_REPORTER_ROLE_TAG = 'Case.ZTS_US_Source__c';
    public static final String PREVIOUS_EXPOSURE_DETAIL_ZP_TAG = '<<PREVIOUS_EXPOSURE_DETAIL_ZP>>';
    public static final String PREVIOUS_EXPOSURE_DETAIL_NZP_TAG = '<<PREVIOUS_EXPOSURE_DETAIL_NZP>>';
    public static final String LOT_NUMBER_DETAIL_TAG = '<<LOT_NUMBER_DETAIL>>';
    public static final String CLOSING_STATEMENT_TAG = '<<CLOSING_STATEMENT>>';
    public static final String PATIENT_OUTCOME_TAG = '<<PATIENT_OUTCOME>>';
    
    public static Map<String, List<ZTS_US_Abstract_Summary_Templates__mdt>> getAbstractSummaryTemplates()
    {
        // lets get the abstract summary template metadata
        List<ZTS_US_Abstract_Summary_Templates__mdt> queriedTemplates = [ SELECT Id,
                                                                         Label,
                                                                         ZTS_US_Case_Type__c,
                                                                         ZTS_US_Contains__c,
                                                                         ZTS_US_Problem_Product_Type__c,
                                                                         ZTS_US_VedDra_Code__c,
                                                                         ZTS_US_Abstract_Summary_Template__c 
                                                                         FROM ZTS_US_Abstract_Summary_Templates__mdt
                                                                        ];
        // lets declare a map to hold our key to template mapping
        Map<String, List<ZTS_US_Abstract_Summary_Templates__mdt>> keyToTemplateMetadatasMap = new Map<String, List<ZTS_US_Abstract_Summary_Templates__mdt>>();
        
        // lets map the templates to a key
        for ( ZTS_US_Abstract_Summary_Templates__mdt aTemplate : queriedTemplates )
        {
            // we will use a combination of the case type and the product problem type as a key to look at 
            List<String> keys = new List<String>();
            if ( String.isNotBlank( aTemplate.ZTS_US_Case_Type__c ) )
            {
                keys.add( aTemplate.ZTS_US_Case_Type__c );
            }
            
            if ( String.isNotBlank( aTemplate.ZTS_US_Problem_Product_Type__c ) )
            {
                keys.add( aTemplate.ZTS_US_Problem_Product_Type__c );
            }
            
            if ( !keys.isEmpty() )
            {
                // if we have values to add, lets go ahead and join them to build a "composite" key
                String key = String.join( keys, ';' );
                
                // lets build our map here
                List<ZTS_US_Abstract_Summary_Templates__mdt> innerMetadataList = keyToTemplateMetadatasMap.containsKey( key ) ? keyToTemplateMetadatasMap.get( key )
                    : new List<ZTS_US_Abstract_Summary_Templates__mdt>();
                
                innerMetadataList.add( aTemplate );
                keyToTemplateMetadatasMap.put( key, innerMetadataList );     
            }
        }
        
        return keyToTemplateMetadatasMap;
    }

    public static list<String> getSortedListForAssociateProduct(List<String> caseProductKeys){
        Integer j = 0;
        while (j < caseProductKeys.size())
        {
            if(caseProductKeys.get(j) == ASSOCIATED_PRODUCT)
            {
                caseProductKeys.remove(j);
            }else
            {
                j++;
            }
        }
        return caseProductKeys;
    }
    
    private static String aOrAn(String word) {
        List<String> vowels = new List<String>{'a','e','i','o','u'};
            for (String vowel : vowels) {
                if (word.startsWithIgnoreCase(vowel)) {
                    return ' an ' + word;
                }
            }
        return ' a ' + word;
    }
    
    @AuraEnabled
    public static void updateAbstractSummary( String eventNarrativeRecordId )
    {
        // first, lets get our abstract summary templates 
        Map<String, List<ZTS_US_Abstract_Summary_Templates__mdt>> abstractSummaryMetadataMap = getAbstractSummaryTemplates();
        
        //TPDEV-1814 Added to include in template, contains patient details
        Map<String,String> fieldToLabelMap = new Map<String,String>{'ZTS_US_Recovered__c' => 'recovered',
                                                                    'ZTS_US_Died__c' => 'died',
                                                                    'ZTS_US_Under_Treatment__c' => 'remains under treatment',
                                                                    'ZTS_US_Euthanized__c' => 'euthanized',
                                                                    'ZTS_US_Alive_with_Sequela__c' => 'alive with sequela',
                                                                    'ZTS_US_Unknown__c' => 'unknown'};
                                                                        
        String previeousExposureDetails_zp = '';
        String previeousExposureDetails_nzp = '';
        String lotNumberDetails = '';
        String patientOutcomeDetails = '';
        
        // now lets focus on getting the data we need from the event narrative and the related objects
        // lets get the event narrative template
        ZTS_US_Event_Narrative__c queriedEventNarrative = [ SELECT Id,
                                                           ZTS_US_Outcome_of_Reaction__c,
                                                           ZTS_US_Reaction_Treated__c, // TPDEV-601 Added
                                                           ZTS_US_Event_Narrative_Summary_Field__c,
                                                           ZTS_US_Case__c,
                                                           ( SELECT Id,
                                                            ZTS_US_VedDRA_Coding__c,
                                                            ZTS_US_VedDRA_Coding__r.Name
                                                            FROM Veddra_Events__r 
                                                           )
                                                           FROM ZTS_US_Event_Narrative__c
                                                           WHERE Id = :eventNarrativeRecordId ];
        
        // lets get the related case record (and its children that we need as well )
        Case relatedCase = [ SELECT Id, 
                            Type,
                            ZTS_US_Date_First_Valid__c, ZTS_US_No_More_Information_Expected__c,ZTS_US_Source__c, //TPDEV-1814 Added to include in template
                            ( SELECT Id, 
                             ZTS_US_Contact_Role__c
                             FROM Case_Contacts__r 
                            ),
                            ( SELECT Id, 
                             ZTS_US_Product_problem_type__c, 
                             ZTS_US_Defect_Product__c,
                             ZTS_US_Filling_Packaging__c,
                             ZTS_US_PVW_Product__c, 
                             ZTS_US_PVW_Product__r.Name,
                             ZTS_US_Serial_Number__c,
                             ZTS_US_Product_Lot__c,
                             ZTS_US_Previous_Exposure__c,
                             ZTS_US_Non_Zoetis_Product_Brand__c, //TPDEV-601 Added
                             ZTS_US_LOE_Reason__c,
                             ZTS_US_Product_Used_Correctly__c,
                             ZTS_US_Previous_Exposure_Details__c, //TPDEV-1814 Added to include in template
                             ZTS_US_Misuse_Types__c,
                             RecordType.DeveloperName
                             FROM Case_Products__r //TPDEV-601 Removed record type check to include non-zoetis products
                            ),
                            ( SELECT Id, 
                             ZTS_US_Animal__r.ZTS_US_Species__c,
                             ZTS_US_Animal_condition_prior_treatment__c, //TPDEV-601 Added
                             ZTS_US_Reacted__c, ZTS_US_Recovered__c, ZTS_US_Died__c, ZTS_US_Under_Treatment__c, ZTS_US_Euthanized__c, ZTS_US_Alive_with_Sequela__c, ZTS_US_Unknown__c //TPDEV-1814 Added to include in template
                             FROM Case_Animals__r
                            )
                            FROM Case 
                            WHERE ZTS_US_Event_Narrative__c = :eventNarrativeRecordId 
                           ];
        
        // now that we have all of our data lets get the right lists of templates that we need to iterate over to get the appropriate template to pull in 
        //Not using anywhere...
        Map<Id, List<ZTS_US_Abstract_Summary_Templates__mdt>> caseProductTotemplatesToWorkWith = new Map<Id, List<ZTS_US_Abstract_Summary_Templates__mdt>>();
        
        String caseKey = String.isNotBlank( relatedCase.Type ) ? relatedCase.Type : '';
        Set<String> uniqueCaseProductKeys = new Set<String>();
        
        // while we're here lets also join our product names to use later on
        List<String> productNames = new List<String>();
        
        //TPDEV-601 Join concomcomitant product names 
        List<String> nonZoetisProductNames = new List<String>();
        
        //TPDEV-601 LOE reasons
        Set<String> loeReasons = new Set<String>();
        
        //TPDEV-601 Product used incorrectly Misuse types
        Set<String> productIncorrectlyUsed = new Set<String>();
        
        // we're also going to deal with product defects, filling and packaging issues at the same time
        Set<String> productDefectValues = new Set<String>();
        Set<String> fillingAndPackagingIssues = new Set<String>();
        Boolean isVedra=false;
        if ( queriedEventNarrative.Veddra_Events__r != null && !queriedEventNarrative.Veddra_Events__r.isEmpty() )
        {
            isVedra=true;
        }
        
        // lets iterate over our case products
        for ( ZTS_US_Case_Product__c aCaseProduct : relatedCase.Case_Products__r )
        {
            String productName = '<<Product.Name>>'; //TPDEV-1814 Added
            if(aCaseProduct.RecordType.DeveloperName == 'Zoetis_Product'){ //TPDEV-601 Check Zoetis product
                // lets add all of our product problem types to a set 
                List<String> caseProductProblemTypes = aCaseProduct.ZTS_US_Product_problem_type__c.split( ';' );
                uniqueCaseProductKeys.addAll( caseProductProblemTypes );
                
                // lets add all our product names to a set
                productNames.add( aCaseProduct.ZTS_US_PVW_Product__r.Name );
                
                // lets add all of our product defect values to a set
                if(String.isNotBlank(aCaseProduct.ZTS_US_Defect_Product__c))
                    productDefectValues.addAll( aCaseProduct.ZTS_US_Defect_Product__c.split( ';' ) );
                
                // lets add all of our filling and packaging issues to a set
                if(String.isNotBlank(aCaseProduct.ZTS_US_Filling_Packaging__c))
                    fillingAndPackagingIssues.addAll( aCaseProduct.ZTS_US_Filling_Packaging__c.split( ';' ) );
                
                //TPDEV-601 Adding LOE reasons for lack of efficacy problem type
                if(aCaseProduct.ZTS_US_Product_problem_type__c.contains(LACK_OF_EFFICACY)){
                    loeReasons.add(aCaseProduct.ZTS_US_LOE_Reason__c);
                }
                //TPDEV-601 adding misuse type for incorrectly used products
                if(aCaseProduct.ZTS_US_Product_Used_Correctly__c == NO && aCaseProduct.ZTS_US_Misuse_Types__c != null){
                    productIncorrectlyUsed.add(EXTRA_LABEL_USE_STR+aCaseProduct.ZTS_US_PVW_Product__r.Name+FOR_CLAUSE+aCaseProduct.ZTS_US_Misuse_Types__c);
                }
                
                //TPDEV-1814 Added
                if(aCaseProduct.ZTS_US_Product_Lot__c.containsIgnoreCase('unknown') && aCaseProduct.ZTS_US_Serial_Number__c.containsIgnoreCase('unknown')){
                    lotNumberDetails += 'Lot/Serial numbers were unknown for '+aCaseProduct.ZTS_US_PVW_Product__r.Name+'. ';
                }else if((String.isBlank(aCaseProduct.ZTS_US_Product_Lot__c) || aCaseProduct.ZTS_US_Product_Lot__c.containsIgnoreCase('not given') || aCaseProduct.ZTS_US_Product_Lot__c.containsIgnoreCase('unknown')) 
                         && (String.isBlank(aCaseProduct.ZTS_US_Serial_Number__c) || aCaseProduct.ZTS_US_Serial_Number__c.containsIgnoreCase('not given') || aCaseProduct.ZTS_US_Serial_Number__c.containsIgnoreCase('unknown'))){
                    lotNumberDetails += 'Lot/Serial numbers were not recorded for '+aCaseProduct.ZTS_US_PVW_Product__r.Name+'. ';
                }else{
                    lotNumberDetails += 'Lot/Serial numbers were entered into the case for '+aCaseProduct.ZTS_US_PVW_Product__r.Name+'. ';
                }
                
                if(aCaseProduct.ZTS_US_Previous_Exposure__c == 'Unknown'){
                    previeousExposureDetails_zp += 'It is unknown if the patient had received '+aCaseProduct.ZTS_US_PVW_Product__r.Name+' previously. ';
                }else if(aCaseProduct.ZTS_US_Previous_Exposure__c == 'Yes'){
                    previeousExposureDetails_zp += 'The patient had received '+aCaseProduct.ZTS_US_PVW_Product__r.Name+' previously on '+ aCaseProduct.ZTS_US_Previous_Exposure_Details__c + '. ';
                }else If(aCaseProduct.ZTS_US_Previous_Exposure__c == 'No'){
                    previeousExposureDetails_zp += 'The patient had not received '+aCaseProduct.ZTS_US_PVW_Product__r.Name+' previously. ';
                }
            }else if(aCaseProduct.RecordType.DeveloperName == 'Non_Zoetis_Product'){ //TPDEV-601 Check Non-Zoetis product
                // Add Non-Zoetis(Concomitant) product names
                nonZoetisProductNames.add( aCaseProduct.ZTS_US_Non_Zoetis_Product_Brand__c); 
                
                //TPDEV-601 adding misuse type for incorrectly used products
                if(aCaseProduct.ZTS_US_Product_Used_Correctly__c == NO && aCaseProduct.ZTS_US_Misuse_Types__c != null){
                    productIncorrectlyUsed.add(EXTRA_LABEL_USE_STR+aCaseProduct.ZTS_US_Non_Zoetis_Product_Brand__c+FOR_CLAUSE+aCaseProduct.ZTS_US_Misuse_Types__c);
                }
                
                //TPDEV-1814 Added
                if(aCaseProduct.ZTS_US_Previous_Exposure__c == 'Unknown'){
                    previeousExposureDetails_nzp += 'It is unknown if the patient had received '+aCaseProduct.ZTS_US_Non_Zoetis_Product_Brand__c+' previously. ';
                }else if(aCaseProduct.ZTS_US_Previous_Exposure__c == 'Yes'){
                    previeousExposureDetails_nzp += 'The patient had received '+aCaseProduct.ZTS_US_Non_Zoetis_Product_Brand__c+' previously on '+ aCaseProduct.ZTS_US_Previous_Exposure_Details__c + '. ';
                }else If(aCaseProduct.ZTS_US_Previous_Exposure__c == 'No'){
                    previeousExposureDetails_nzp += 'The patient had not received '+aCaseProduct.ZTS_US_Non_Zoetis_Product_Brand__c+' previously. ';
                }
            }
        }
        
        // lets turn the set into a list and sort it
        List<String> caseProductKeys = new List<String>( uniqueCaseProductKeys );
        caseProductKeys.sort();
        if(caseProductKeys.contains(ADVERSE_REACTION) && caseProductKeys.contains(ASSOCIATED_PRODUCT)){
            caseProductKeys = getSortedListForAssociateProduct(caseProductKeys);
            caseProductKeys.add(ASSOCIATED_PRODUCT);
        }
        
        // lets declare some variables here that will make our life easier below
        String templateTextTemp = ''; 
        // replace last instance of , with and FOR ALL OF THE STRINGS THAT ARE JOINED BELOW
        String concatenatedProductNames = String.join( new List<String>(productNames), ', ' ); 
        String concatenatedProductDefects = String.join( new List<String>(productDefectValues), ', ' );
        String concatenatedFillingAndPackagingIssues = String.join( new List<String>(fillingAndPackagingIssues), ', ' );
        //TPDEV-601 concatenating concomitant (non-zoetis) products
        String concatenatedConcomitantProductNames = String.join( new List<String>(nonZoetisProductNames), ', ' );
        String concatenatedLOEReasons = String.join( new List<String>(loeReasons), ', ' );
        String concatenatedProductIncorrectlyUsed = String.join( new List<String>(productIncorrectlyUsed), '. ' );
        
        // lets build our composite key
        String compositeKey = caseKey + ';' + String.join( caseProductKeys, ';' );
        
        //TPDEV-1814 Added get primary reporter role
        
        Map<String,Integer> patientOutcomeMap = new Map<String,Integer>(); 
        for(ZTS_US_Case_Animal__c animal: relatedCase.Case_Animals__r){
            for(String fieldAPI: fieldToLabelMap.KeySet()){
                if(animal.get(fieldAPI) != null && animal.get(fieldAPI) != 0){
                    if(patientOutcomeMap.containsKey(fieldAPI)){
                        patientOutcomeMap.put(fieldAPI, patientOutcomeMap.get(fieldAPI) + Integer.valueOf((Decimal)animal.get(fieldAPI)));
                    }else{
                        patientOutcomeMap.put(fieldAPI, Integer.valueOf((Decimal)animal.get(fieldAPI)));
                    }
                }
            }
        }
        
        Integer index = 0;
        for(String fieldAPI: patientOutcomeMap.KeySet()){
            if( index == 0 ){
                patientOutcomeDetails = 'The outcome is ';
            }
            patientOutcomeDetails += fieldToLabelMap.get(fieldAPI) + ' for '+ patientOutcomeMap.get(fieldAPI);
            
            if(index == (patientOutcomeMap.KeySet().size() - 1))
                patientOutcomeDetails += '.';
            else
                patientOutcomeDetails += (index++ == patientOutcomeMap.KeySet().size() - 2 ? ' and ' : ', ');
        }
               
        //Adverse Reaction check and change Composite Key
        
        Boolean isAdverseReaction = false;
        if (compositeKey.contains(ADVERSE_REACTION) )
        {
            compositeKey = compositeKey.substringBefore(ADVERSE_REACTION)+ADVERSE_REACTION;
            isAdverseReaction = true;
        }
        
        // lets get our list of templates that we can potentially use here 
        if ( abstractSummaryMetadataMap.containsKey( compositeKey ) )
        {
            List<ZTS_US_Abstract_Summary_Templates__mdt> matchingTemplates = abstractSummaryMetadataMap.get( compositeKey );
            
            // lets iterate over our templates
            for ( ZTS_US_Abstract_Summary_Templates__mdt  aTemplate : matchingTemplates )
            {
                Boolean useTemplate = false; 
                
                // lets check the veddra match if we need one 
                if ( aTemplate.ZTS_US_VedDra_Code__c != IGNORE_VEDDRA )
                {
                    // is veddra required for this template?
                    if ( aTemplate.ZTS_US_VedDra_Code__c == VEDDRA_REQUIRED )
                    {
                        if ( queriedEventNarrative.Veddra_Events__r != null && !queriedEventNarrative.Veddra_Events__r.isEmpty() )
                        {
                            useTemplate = true;
                        }
                    }
                    else if ( aTemplate.ZTS_US_VedDra_Code__c == VEDDRA_NOT_REQUIRED )
                    {
                        if ( queriedEventNarrative.Veddra_Events__r == null && queriedEventNarrative.Veddra_Events__r.isEmpty() )
                        {
                            useTemplate = true;
                        }
                    }
                }
                // we can ignore veddra
                else 
                {
                    useTemplate = true;
                }
                
                // if this template doesn't match, lets just keep moving on
                if ( !useTemplate )
                {
                    //continue;
                }
               
                
                
                //  
                if (  compositeKey.contains(ADVERSE_REACTION) && caseProductKeys.size() >=2 && !String.isEmpty(aTemplate.ZTS_US_Contains__c) && aTemplate.ZTS_US_Contains__c == YES && String.isEmpty(templateTextTemp))
                    
                {   
                 if (isVedra && aTemplate.ZTS_US_VedDra_Code__c == VEDDRA_REQUIRED)
                 {
                     templateTextTemp = aTemplate.ZTS_US_Abstract_Summary_Template__c;
                 }
                 if(!isVedra && aTemplate.ZTS_US_VedDra_Code__c == VEDDRA_NOT_REQUIRED){
                     templateTextTemp = aTemplate.ZTS_US_Abstract_Summary_Template__c;
                 }
                 
                }
                if(compositeKey.contains(ADVERSE_REACTION) && caseProductKeys.size()==1 && String.isEmpty(aTemplate.ZTS_US_Contains__c) && String.isEmpty(templateTextTemp)){
                    
                    if (isVedra && aTemplate.ZTS_US_VedDra_Code__c == VEDDRA_REQUIRED)
                    {
                        templateTextTemp = aTemplate.ZTS_US_Abstract_Summary_Template__c;
                    }
                    if(!isVedra && aTemplate.ZTS_US_VedDra_Code__c == VEDDRA_NOT_REQUIRED){
                     templateTextTemp = aTemplate.ZTS_US_Abstract_Summary_Template__c;
                    }
                }
                
                if ( templateTextTemp.contains( PROBLEM_TYPE_OTHER_THAN_AE_TAG )  )
                {
                    
                    String tempCompositeKey = String.join( caseProductKeys, ',' ).SubstringAfter(ADVERSE_REACTION+',');
                    
                    templateTextTemp = templateTextTemp.replace( PROBLEM_TYPE_OTHER_THAN_AE_TAG,tempCompositeKey); 
                }
                
               
                
                // otherwise, lets just go ahead and do the rest of our processing
                // lets go through our list of merge values that are possible, and then figure out how to replace what needs to be replaced
                if(String.isEmpty(templateTextTemp) && !isAdverseReaction )
                    templateTextTemp = aTemplate.ZTS_US_Abstract_Summary_Template__c;
                
                
                String tempAdverseEffect = '';
                
                if ( templateTextTemp.contains( FILLING_PACKAGING_ISSUE_TAG ) && String.isNotBlank( concatenatedFillingAndPackagingIssues ) )
                {
                    templateTextTemp = templateTextTemp.replace( FILLING_PACKAGING_ISSUE_TAG, concatenatedFillingAndPackagingIssues );
                }
                
                if ( templateTextTemp.contains( OUTCOME_OF_REACTION_TAG ) && String.isNotBlank( queriedEventNarrative.ZTS_US_Outcome_of_Reaction__c ) )
                {
                    templateTextTemp = templateTextTemp.replace( OUTCOME_OF_REACTION_TAG, queriedEventNarrative.ZTS_US_Outcome_of_Reaction__c );
                }
                
                
                
                if ( templateTextTemp.contains( PRODUCT_NAMES_TAG ) && String.isNotBlank( concatenatedProductNames )) 
                {
                    templateTextTemp = templateTextTemp.replace( PRODUCT_NAMES_TAG, concatenatedProductNames );
                }
                
                //TPDEV-601 replace animal condition prior to treatment.
                
                if ( templateTextTemp.contains( ANIMAL_CONDITION_PRIOR_TREAT ) && relatedCase.Case_Animals__r.isEmpty() != null && !relatedCase.Case_Animals__r.isEmpty() && relatedCase.Case_Animals__r[ 0 ].ZTS_US_Animal_condition_prior_treatment__c != null){
                    templateTextTemp = templateTextTemp.replace( ANIMAL_CONDITION_PRIOR_TREAT, relatedCase.Case_Animals__r[ 0 ].ZTS_US_Animal_condition_prior_treatment__c );
                }
                //TPDEV-601 replace concomitant product.
                if ( templateTextTemp.contains( CONCOMITANT_TAG )) 
                {
                    if(String.isBlank( concatenatedConcomitantProductNames ))
                        templateTextTemp = templateTextTemp.replace( CONCOMITANT_TAG, CONCOMITANT_PRODUCT_ABSENT );
                    else
                        templateTextTemp = templateTextTemp.replace( CONCOMITANT_TAG, concatenatedConcomitantProductNames + ( nonZoetisProductNames.size() > 1 ? WERE : WAS) + CONCOMITANT_PRODUCT_PRESENT);
                }
                //TPDEV-601 replace Is patient treated.
                if( templateTextTemp.contains( IF_PATIENT_TREATED )){
                    if(queriedEventNarrative.ZTS_US_Reaction_Treated__c == YES)
                        templateTextTemp = templateTextTemp.replace( IF_PATIENT_TREATED, PATIENT_TREATED+TREATED );
                    else if(queriedEventNarrative.ZTS_US_Reaction_Treated__c == NO)
                        templateTextTemp = templateTextTemp.replace( IF_PATIENT_TREATED, PATIENT_TREATED+NOT_CLAUSE+TREATED);
                    else
                        templateTextTemp = templateTextTemp.replace( IF_PATIENT_TREATED+'.', '' );
                }
                //TPDEV-601 replace lack of efficacy reasons.
                if( templateTextTemp.contains( LOE_REASON ) && String.isNotBlank(concatenatedLOEReasons)){
                    templateTextTemp = templateTextTemp.replace( LOE_REASON, concatenatedLOEReasons );
                }
                
                // TPDEV-601 Adding extra label use for incorrectly used products
                if(templateTextTemp.contains( EXTRA_LABEL_USE )){
                    if(String.isNotBlank(concatenatedProductIncorrectlyUsed)){
                        templateTextTemp = templateTextTemp.replace( EXTRA_LABEL_USE ,' '+concatenatedProductIncorrectlyUsed);
                    }else{
                        templateTextTemp = templateTextTemp.replace( EXTRA_LABEL_USE+'.' ,'' );
                    }
                }
                
                if ( templateTextTemp.contains( PRODUCT_DEFECT_TAG ) && String.isNotBlank( concatenatedProductDefects ) )
                {
                    templateTextTemp = templateTextTemp.replace( PRODUCT_DEFECT_TAG, concatenatedProductDefects );
                }
                
                if ( templateTextTemp.contains( SPECIES_TAG ) && relatedCase.Case_Animals__r.isEmpty() != null && !relatedCase.Case_Animals__r.isEmpty() )
                {
                    templateTextTemp = templateTextTemp.replace( SPECIES_TAG, relatedCase.Case_Animals__r[ 0 ].ZTS_US_Animal__r.ZTS_US_Species__c );
                }
                
                if ( templateTextTemp.contains( VEDDRA_CODING_TAG ) && queriedEventNarrative.Veddra_Events__r != null && !queriedEventNarrative.Veddra_Events__r.isEmpty() )
                {
                    // lets get the veddra merge value
                    Set<String> veddraCodes = new Set<String>();
                    for ( ZTS_US_VedDRA_Event__c aVeddraEvent : queriedEventNarrative.Veddra_Events__r )
                    {
                        veddraCodes.add( aVeddraEvent.ZTS_US_VedDRA_Coding__r.Name );
                    }
                    
                    templateTextTemp = templateTextTemp.replace( VEDDRA_CODING_TAG, String.join( new List<String>(veddraCodes), ', ' ) );
                }
                
                if ( templateTextTemp.contains( DATE_TAG ) && relatedCase.ZTS_US_Date_First_Valid__c != null)
                {
                    String formatteddate = DateTime.newInstance(relatedCase.ZTS_US_Date_First_Valid__c, Time.newInstance(0,0,0,0)).format('ddMMMyyyy');
                    templateTextTemp = templateTextTemp.replace( DATE_TAG, formatteddate );
                } 
                
                if ( templateTextTemp.contains( PRIMARY_REPORTER_ROLE_TAG ) && !String.isBlank(relatedCase.ZTS_US_Source__c))
                {
                    templateTextTemp = templateTextTemp.replace( PRIMARY_REPORTER_ROLE_TAG, aOrAn(relatedCase.ZTS_US_Source__c));
                } 
                 
                if ( templateTextTemp.contains( PREVIOUS_EXPOSURE_DETAIL_ZP_TAG ))
                {  
                    templateTextTemp = templateTextTemp.replace( PREVIOUS_EXPOSURE_DETAIL_ZP_TAG, previeousExposureDetails_zp);
                }
                
                if ( templateTextTemp.contains( PREVIOUS_EXPOSURE_DETAIL_NZP_TAG ))
                {  
                    templateTextTemp = templateTextTemp.replace( PREVIOUS_EXPOSURE_DETAIL_NZP_TAG, previeousExposureDetails_nzp);
                }
                
                if ( templateTextTemp.contains( LOT_NUMBER_DETAIL_TAG ))
                {    
                    templateTextTemp = templateTextTemp.replace( LOT_NUMBER_DETAIL_TAG, lotNumberDetails);
                }
                
                if ( templateTextTemp.contains( CLOSING_STATEMENT_TAG )){
                    templateTextTemp = templateTextTemp.replace( CLOSING_STATEMENT_TAG, relatedCase.ZTS_US_No_More_Information_Expected__c ? 'This case is closed.' : 'An update is expected for this case.');    
                }
                
                if( templateTextTemp.contains( PATIENT_OUTCOME_TAG)){
                    templateTextTemp = templateTextTemp.replace( PATIENT_OUTCOME_TAG, patientOutcomeDetails);
                }
                try{
                    queriedEventNarrative.ZTS_US_Abstract_Summary__c = templateTextTemp;
                    System.debug('Final abstract summary is'+templateTextTemp);
                    update queriedEventNarrative;
                }catch(Exception ex){
                    System.debug(ex.getMessage()+ex.getLineNumber());
                }
            }
        }
    }
}
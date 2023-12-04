global with sharing class PropelPreApprovalValidation {
    /**
     * Reference: https://help.salesforce.com/s/articleView?id=000325250&type=1
     * Required Fields are case sensitive. They need to match API Name on the Object
     * Missing required fields
     * Invalid Child phases
     * Unreleased Children
     * Inactive users as Approvers
     */

    /**
     * 01/12/2023
     *      - Deactivate Inactive Approvers
     *      - Only display values for the current phase
     * 
     * 01/13/2023
     *      - Add PDLM__Phase__c.Run_Audits_Additional_Required_Fields__c
     */

    global class GetRequestsfromFlow{
        @InvocableVariable(label='Change Record ID' required=true) global Id recordId;
        @InvocableVariable(label='Lifecycle Id' required=true) global Id lifecycleId;
        @InvocableVariable(label='Phase Name' required=false) global String phaseName;
    }

    @testVisible static String resultForTest = '';
    @InvocableMethod 

    global static List<String> PropelPreApprovalValidation(List<GetRequestsfromFlow> flows){
        String result = '';
        List<PDLM__Phase__c> phasesForChange = new List<PDLM__Phase__c>();
        List<PDLM__Phase__c> phasesForItem = new List<PDLM__Phase__c>();
        Map<String, List<String>> itemLifecyclePhaseRequiredFields = new Map<String, List<String>>();
        Map<String, List<String>> changeAddlRequiredFields = new Map<String, List<String>>();
        Map<Id, String> ecoAiItemIdLatestPhaseMap = new Map<Id, String>();
        String changeCurrentPhase = flows[0].phaseName;

        for (PDLM__Affected_Item__c ai : [SELECT Id, Name, PDLM__Item_Revision__r.PDLM__Master_Item__c, 
                                          PDLM__Change_Order_lk__c, PDLM__Change_Order_lk__r.Change_Status_Name__c, 
                                          PDLM__Item_Revision__r.PDLM__Master_Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name, 
                                          PDLM__Item_Revision__r.PDLM__Lifecycle_Phase__c FROM PDLM__Affected_Item__c 
                                          WHERE PDLM__Change_Order_lk__c = :flows[0].recordId]){
            String currentLifecycleAndPhase = ai.PDLM__Item_Revision__r.PDLM__Master_Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name + '|' + ai.PDLM__Item_Revision__r.PDLM__Lifecycle_Phase__c;
            ecoAiItemIdLatestPhaseMap.put(ai.PDLM__Item_Revision__r.PDLM__Master_Item__c, currentLifecycleAndPhase);
        }

        for (PDLM__Phase__c phase : [SELECT Id, Name, PDLM__Required__c, PDLM__Required_Affected_Item_Fields__c, PDLM__Child_Phases__c, PDLM__Lifecycle__c, 
                                     PDLM__Lifecycle__r.PDLM__Type__c, PDLM__Lifecycle__r.Name, PDLM__Required_Category_AI_Fields__c, Run_Audits_Additional_Required_Fields__c  
                                     FROM PDLM__Phase__c WHERE PDLM__Lifecycle__c = :flows[0].lifecycleId OR PDLM__Lifecycle__r.PDLM__Type__c = 'Item' Order By PDLM__Order__c]){
            if (phase.PDLM__Lifecycle__c == flows[0].lifecycleId){
                phasesForChange.add(phase);
            }
            else if (phase.PDLM__Lifecycle__r.PDLM__Type__c == 'Item'){
                phasesForItem.add(phase);
                String lifecyclePhaseConcat = phase.PDLM__Lifecycle__r.Name + '|' + phase.Name;
                
                if (phase.PDLM__Required__c != null){
                    itemLifecyclePhaseRequiredFields.put(lifecyclePhaseConcat, phase.PDLM__Required__c.replaceAll('\\s+','').split(','));
                }
                else{
                    itemLifecyclePhaseRequiredFields.put(lifecyclePhaseConcat, new List<String> {});
                }
            }
        }

        List<PDLM__Assembly__c> assemblies = [SELECT Id, Name, PDLM__Item_Revision__c, PDLM__Item_Revision__r.Name, PDLM__Item__r.PDLM__Latest_Revision__c, 
                                              PDLM__Item_Revision__r.PDLM__Lifecycle_Phase__c, PDLM__Item__r.PDLM__Latest_Released_Revision__c, 
                                              PDLM__Item__r.Name, PDLM__Item__r.PDLM__Category__r.Name, PDLM__Item__r.PDLM__Latest_Lifecycle_Phase__c, 
                                              PDLM__Item_Revision__r.PDLM__Master_Item__c, PDLM__Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name, 
                                              PDLM__Item_Revision__r.PDLM__Master_Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name, 
                                              PDLM__Item__r.PDLM__Latest_Revision__r.PDLM__Lifecycle_Phase__c 
                                              FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__r.PDLM__Related_Change__c = :flows[0].recordId];

        //Run for all
        result += checkRequiredFields(flows[0].recordId, phasesForChange, phasesForItem, itemLifecyclePhaseRequiredFields, changeCurrentPhase);
        result = result.removeStart('(').removeEnd(')');

        //Deactivated on 01/12/2023
        // result += checkInactiveApprovers(flows[0].recordId);
        // result = result.removeStart('(').removeEnd(')');

        result += checkUnreleasedChildren(flows[0].recordId, assemblies);
        result = result.removeStart('(').removeEnd(')');

        result += checkInvalidChildPhases(flows[0].recordId, phasesForItem, assemblies, ecoAiItemIdLatestPhaseMap );
        result = result.removeStart('(').removeEnd(')');

        result = result.replace('</table>(<br>', '</table><br>').replace('<br>(<br>', '<br><br>').replace('(<br><b>', '<br><b>');
        resultForTest = result;

        System.debug('result: ' + result);

        return new List<String> {result};
    }

    public static List<String> checkRequiredFields(Id recordId, List<PDLM__Phase__c> phasesForChange, List<PDLM__Phase__c> phasesForItem, 
    Map<String, List<String>> itemLifecyclePhaseRequiredFields, String changeCurrentPhase){
        /**
         * It checks the following
         *      Change Required Fields
         *      Affected Items Required Fields
         *      Item Lifecycle --> Required Fields
         *      Required Category AI Fields
         */

        Map<String, Schema.SObjectField> changeMapFields = Schema.SObjectType.PDLM__Change__c.fields.getMap();
        Map<String, Schema.SObjectField> aiMapFields = Schema.SObjectType.PDLM__Affected_Item__c.fields.getMap();
        Map<String, Schema.SObjectField> revMapFields = Schema.SObjectType.PDLM__Item_Revision__c.fields.getMap();
        Map<String, List<String>> phaseNameChangeRequiredFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> phaseNameChangeAddlRequiredFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> phaseNameAiRequiredFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> phaseNameMissingChangeRequiredFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> phaseNameMissingChangeAddlRequiredFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> phaseNameMissingAiRequiredFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> itemRevMissingCategoryAiRequiredFieldsMap = new Map<String, List<String>>();
        Map<String, List<String>> revMissingRevRequiredFieldsMap = new Map<String, List<String>>();
        Map<String, Map<String,String>> changePhaseRequiredCategoryAiFieldsParsedMap = new Map<String, Map<String,String>>();
        List<PDLM__Change__c> changes = new List<PDLM__Change__c>();
        List<PDLM__Affected_Item__c> affectedItems = new List<PDLM__Affected_Item__c>();
        List<PDLM__Item_Revision__c> itemRevisions = new List<PDLM__Item_Revision__c>();
        String allChangeRequiredFields = '';
        String allAiRequiredFields = '';
        String revRequiredFields = '';
        String tempAiFieldLabel = '';
        String tempCategoryAiFieldLabel = '';
        String tempChangeFieldLabel = '';
        String tempRevFieldLabel = '';

        //Convert key in Maps to lower case
        changeMapFields = convertStringObjectFieldsMapLowerKey(changeMapFields);
        aiMapFields = convertStringObjectFieldsMapLowerKey(aiMapFields);
        revMapFields = convertStringObjectFieldsMapLowerKey(revMapFields);

        for (PDLM__Phase__c phase : phasesForChange){
            phaseNameChangeRequiredFieldsMap.put(phase.Name, new List<String> ());
            phaseNameChangeAddlRequiredFieldsMap.put(phase.Name, new List<String> ());
            phaseNameAiRequiredFieldsMap.put(phase.Name, new List<String> ());

            //Change and Quality Required Fields
            if (phase.PDLM__Required__c != null){
                String[] changeFieldsList = new List<String>();
                changeFieldsList = phase.PDLM__Required__c.replaceAll('\\s+','').split(',');

                for (String changeField : changeFieldsList){
                    String changeFieldTrimmed = changeField.trim().toLowerCase();
                    List<String> tempChangeRequiredFields = phaseNameChangeRequiredFieldsMap.get(phase.Name);
                    tempChangeRequiredFields.add(changeFieldTrimmed);
                    phaseNameChangeRequiredFieldsMap.put(phase.Name, tempChangeRequiredFields);
                }
            }

            //Added additional fields check on Change
            if (phase.Run_Audits_Additional_Required_Fields__c != null){
                String[] changeAllFieldsList = new List<String>();
                changeAllFieldsList = phase.Run_Audits_Additional_Required_Fields__c.replaceAll('\\s+','').split(',');

                for (String changeAddlField : changeAllFieldsList){
                    String changeAddlFieldTrimmed = changeAddlField.trim().toLowerCase();
                    List<String> tempChangeAddlRequiredFields = phaseNameChangeAddlRequiredFieldsMap.get(phase.Name);
                    tempChangeAddlRequiredFields.add(changeAddlFieldTrimmed);
                    phaseNameChangeAddlRequiredFieldsMap.put(phase.Name, tempChangeAddlRequiredFields);
                }
            }

            //Affected Item Required Fields
            if (phase.PDLM__Required_Affected_Item_Fields__c != null){
                String[] aiFieldsList = new List<String>();
                aiFieldsList = phase.PDLM__Required_Affected_Item_Fields__c.replaceAll('\\s+','').split(',');

                for (String aiField : aiFieldsList){
                    String aiFieldTrimmed = aiField.trim().toLowerCase();
                    List<String> tempAieRequiredFields = phaseNameAiRequiredFieldsMap.get(phase.Name);
                    tempAieRequiredFields.add(aiFieldTrimmed);
                    phaseNameAiRequiredFieldsMap.put(phase.Name, tempAieRequiredFields);
                }
            }

            //Category Required AI Fields
            if (phase.PDLM__Required_Category_AI_Fields__c != null && phase.PDLM__Required_Category_AI_Fields__c.contains(':')){
                changePhaseRequiredCategoryAiFieldsParsedMap.put(phase.Name, parseStringIntoMap(phase.PDLM__Required_Category_AI_Fields__c));
            }
            else {
                changePhaseRequiredCategoryAiFieldsParsedMap.put(phase.Name, new Map<String, String>());
            }
        }

        System.debug('phaseNameChangeRequiredFieldsMap: ' + phaseNameChangeRequiredFieldsMap);
        System.debug('phaseNameChangeAddlRequiredFieldsMap: ' + phaseNameChangeAddlRequiredFieldsMap);
        System.debug('phaseNameAiRequiredFieldsMap: ' + phaseNameAiRequiredFieldsMap);
        System.debug('changePhaseRequiredCategoryAiFieldsParsedMap: ' + changePhaseRequiredCategoryAiFieldsParsedMap);

        //Changes
        List<String> allChangeFieldsList = new List<String>();
        allChangeFieldsList.addAll(changeMapFields.keySet());
        allChangeRequiredFields = String.join(allChangeFieldsList,',');

        if (allChangeFieldsList.size() > 0){
            String changeQuery = String.format('SELECT {0} FROM PDLM__Change__c WHERE Id = :recordId', new List<String> {allChangeRequiredFields});
            changes.addAll((List<PDLM__Change__c>)(Database.query(changeQuery)));

            if (changes.size() != 0){
                PDLM__Change__c chg = changes[0];
                Map<String, Object> changeMap = chg.getPopulatedFieldsAsMap();
                changeMap = convertStringObjectMapLowerKey(changeMap);

                for (String PhaseName : phaseNameChangeRequiredFieldsMap.keySet()){
                    List<String> currentChangeRequiredFields = phaseNameChangeRequiredFieldsMap.get(phaseName);
                    phaseNameMissingChangeRequiredFieldsMap.put(phaseName, new List<String> ());
                    
                    for (String field : currentChangeRequiredFields){
                        field = field.trim().toLowerCase();
                        String fieldNamespace = 'pdlm__' + field;

                        if (!changeMap.containsKey(field) && allChangeFieldsList.contains(field)) {
                            Schema.SObjectField fieldDescribe = changeMapFields.get(field);

                            if (fieldDescribe != null && fieldDescribe.getDescribe().getLabel() != null) {
                                tempChangeFieldLabel = changeMapFields.get(field).getDescribe().getLabel();
                            } 
                            else{
                                tempChangeFieldLabel =  field;
                            }

                            phaseNameMissingChangeRequiredFieldsMap.get(phaseName).add(tempChangeFieldLabel);
                        }
                        else if (!changeMap.containsKey(fieldNamespace) && allChangeFieldsList.contains(fieldNamespace)) {
                            Schema.SObjectField fieldDescribeNameSpace = changeMapFields.get(fieldNamespace);

                            if (fieldDescribeNameSpace != null && fieldDescribeNameSpace.getDescribe().getLabel() != null) {
                                tempChangeFieldLabel = changeMapFields.get(fieldNamespace).getDescribe().getLabel();
                            } 
                            else{
                                tempChangeFieldLabel =  fieldNamespace;
                            }

                            phaseNameMissingChangeRequiredFieldsMap.get(phaseName).add(tempChangeFieldLabel);
                        }
                    }
                }

                //Check Additional Fields on Change
                for (String PhaseName : phaseNameChangeAddlRequiredFieldsMap.keySet()){
                    List<String> currentChangeAddlRequiredFields = phaseNameChangeAddlRequiredFieldsMap.get(phaseName);
                    phaseNameMissingChangeAddlRequiredFieldsMap.put(phaseName, new List<String> ());
                    
                    for (String field : currentChangeAddlRequiredFields){
                        field = field.trim().toLowerCase();
                        String fieldNamespace = 'pdlm__' + field;

                        if (!changeMap.containsKey(field) && allChangeFieldsList.contains(field)) {
                            Schema.SObjectField fieldDescribe = changeMapFields.get(field);

                            if (fieldDescribe != null && fieldDescribe.getDescribe().getLabel() != null) {
                                tempChangeFieldLabel = changeMapFields.get(field).getDescribe().getLabel();
                            } 
                            else{
                                tempChangeFieldLabel =  field;
                            }

                            phaseNameMissingChangeAddlRequiredFieldsMap.get(phaseName).add(tempChangeFieldLabel);
                        }
                        else if (!changeMap.containsKey(fieldNamespace) && allChangeFieldsList.contains(fieldNamespace)) {
                            Schema.SObjectField fieldDescribeNameSpace = changeMapFields.get(fieldNamespace);

                            if (fieldDescribeNameSpace != null && fieldDescribeNameSpace.getDescribe().getLabel() != null) {
                                tempChangeFieldLabel = changeMapFields.get(fieldNamespace).getDescribe().getLabel();
                            } 
                            else{
                                tempChangeFieldLabel =  fieldNamespace;
                            }

                            phaseNameMissingChangeAddlRequiredFieldsMap.get(phaseName).add(tempChangeFieldLabel);
                        }
                    }
                }
            }        
        }

        //Affected Items
        List<String> allAiFieldsList = new List<String>();
        allAiFieldsList.addAll(aiMapFields.keySet());
        allAiRequiredFields = String.join(allAiFieldsList,',');

        if (allAiFieldsList.size() != 0){
            String aiQuery = String.format('SELECT {0}, PDLM__Item_Revision__r.Name, PDLM__Item_Revision__r.PDLM__Category__c, ' +
                                           'PDLM__Change_Order_lk__r.PDLM__Status_lk__r.Name, ' +
                                           'PDLM__Quality_Issue_lk__r.PDLM__Status_lk__r.Name FROM PDLM__Affected_Item__c ' +
                                           'WHERE PDLM__Change_Order_lk__c = :recordId OR PDLM__Quality_Issue_lk__c = :recordId', new List<String> {allAiRequiredFields});
            affectedItems.addAll((List<PDLM__Affected_Item__c>)(Database.query(aiQuery)));

            if (affectedItems.size() != 0){
                String changeQualityStatus = affectedItems[0].PDLM__Change_Order_lk__r.PDLM__Status_lk__r.Name != null ? affectedItems[0].PDLM__Change_Order_lk__r.PDLM__Status_lk__r.Name : affectedItems[0].PDLM__Quality_Issue_lk__r.PDLM__Status_lk__r.Name;

                for (PDLM__Affected_Item__c ai: affectedItems){
                    Map<String, Object> aiMap = ai.getPopulatedFieldsAsMap();
                    aiMap = convertStringObjectMapLowerKey(aiMap);

                    //Required AI Fields
                    for (String phaseName : phaseNameAiRequiredFieldsMap.keySet()){
                        List<String> currentAiRequiredFields = phaseNameAiRequiredFieldsMap.get(phaseName);
                        phaseNameMissingAiRequiredFieldsMap.put(phaseName, new List<String> ());

                        for (String field : currentAiRequiredFields){
                            field = field.trim().toLowerCase();
                            String fieldNamespace = 'pdlm__' + field;

                            if (!aiMap.containsKey(field) && allAiFieldsList.contains(field)) {
                                Schema.SObjectField fieldDescribe = aiMapFields.get(field);

                                if (fieldDescribe != null && fieldDescribe.getDescribe().getLabel() != null) {
                                    tempAiFieldLabel = aiMapFields.get(field).getDescribe().getLabel();
                                } 
                                else{
                                    tempAiFieldLabel =  field;
                                }

                                phaseNameMissingAiRequiredFieldsMap.get(phaseName).add(tempAiFieldLabel);
                            }
                            else if (!aiMap.containsKey(fieldNamespace) && allAiFieldsList.contains(fieldNamespace)) {
                                Schema.SObjectField fieldDescribeNameSpace = aiMapFields.get(fieldNamespace);

                                if (fieldDescribeNameSpace != null && fieldDescribeNameSpace.getDescribe().getLabel() != null) {
                                    tempAiFieldLabel = aiMapFields.get(fieldNamespace).getDescribe().getLabel();
                                } 
                                else{
                                    tempAiFieldLabel =  fieldNamespace;
                                }

                                phaseNameMissingAiRequiredFieldsMap.get(phaseName).add(tempAiFieldLabel);
                            }
                        }
                    }

                    //Required Category AI Fields
                    String currentCategoryAiRequiredFields = changePhaseRequiredCategoryAiFieldsParsedMap.get(changeQualityStatus).get(ai.PDLM__Item_Revision__r.PDLM__Category__c);                    
                    
                    if (currentCategoryAiRequiredFields != '' && currentCategoryAiRequiredFields != null){
                        currentCategoryAiRequiredFields = currentCategoryAiRequiredFields.toLowerCase();
                        List<String> tempCategoryAiRequiredFields = new List<String>();
                        itemRevMissingCategoryAiRequiredFieldsMap.put(ai.PDLM__Item_Revision__r.Name, new List<String> ());

                        if (currentCategoryAiRequiredFields.contains(',')){
                            tempCategoryAiRequiredFields = currentCategoryAiRequiredFields.split(',');
                        }
                        else{
                            tempCategoryAiRequiredFields = new List<String> {currentCategoryAiRequiredFields};
                        }

                        for (String field : tempCategoryAiRequiredFields){
                            field = field.trim().toLowerCase();
                            String fieldNamespace = 'pdlm__' + field;

                            if (!aiMap.containsKey(field) && allAiFieldsList.contains(field)) {
                                Schema.SObjectField fieldDescribe = aiMapFields.get(field);

                                if (fieldDescribe != null && fieldDescribe.getDescribe().getLabel() != null) {
                                    tempCategoryAiFieldLabel = aiMapFields.get(field).getDescribe().getLabel();
                                } 
                                else{
                                    tempCategoryAiFieldLabel =  field;
                                }

                                itemRevMissingCategoryAiRequiredFieldsMap.get(ai.PDLM__Item_Revision__r.Name).add(tempCategoryAiFieldLabel);
                            }
                            else if (!aiMap.containsKey(fieldNamespace) && allAiFieldsList.contains(fieldNamespace)) {
                                Schema.SObjectField fieldDescribeNameSpace = aiMapFields.get(fieldNamespace);

                                if (fieldDescribeNameSpace != null && fieldDescribeNameSpace.getDescribe().getLabel() != null) {
                                    tempCategoryAiFieldLabel = aiMapFields.get(fieldNamespace).getDescribe().getLabel();
                                } 
                                else{
                                    tempCategoryAiFieldLabel =  fieldNamespace;
                                }

                                itemRevMissingCategoryAiRequiredFieldsMap.get(ai.PDLM__Item_Revision__r.Name).add(tempCategoryAiFieldLabel);
                            }
                        }
                    }
                }
            }
        }

        //Item Revisions
        List<String> allRevFieldsList = new List<String>();
        allRevFieldsList.addAll(revMapFields.keySet());
        revRequiredFields = String.join(allRevFieldsList,',');

        String revQuery = String.format('SELECT {0}, PDLM__Master_Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name FROM PDLM__Item_Revision__c WHERE PDLM__Related_Change__c = :recordId', new List<String> {revRequiredFields});
        itemRevisions.addAll((List<PDLM__Item_Revision__c>)(Database.query(revQuery)));

        if (itemRevisions.size() != 0){
            for (PDLM__Item_Revision__c rev: itemRevisions){
                Map<String, Object> revMap = rev.getPopulatedFieldsAsMap();
                revMap = convertStringObjectMapLowerKey(revMap);

                String currentLifecyclePhaseConcat = rev.PDLM__Master_Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name + '|' + rev.PDLM__Lifecycle_Phase__c;
                
                List<String> currentRevRequiredFields = itemLifecyclePhaseRequiredFields.get(currentLifecyclePhaseConcat);
                revMissingRevRequiredFieldsMap.put(rev.Name, new List<String> ());
                
                for (String field : currentRevRequiredFields){
                    field = field.trim().toLowerCase();
                    String fieldNamespace = 'pdlm__' + field;

                    if (!revMap.containsKey(field) && allRevFieldsList.contains(field)) {
                        Schema.SObjectField fieldDescribe = revMapFields.get(field);

                        if (fieldDescribe != null && fieldDescribe.getDescribe().getLabel() != null) {
                            tempRevFieldLabel = revMapFields.get(field).getDescribe().getLabel();
                        }
                        else{
                            tempRevFieldLabel =  field;
                        }

                        revMissingRevRequiredFieldsMap.get(rev.Name).add(tempRevFieldLabel);
                    }
                    else if (!revMap.containsKey(fieldNamespace) && allRevFieldsList.contains(fieldNamespace)) {
                        Schema.SObjectField fieldDescribeNameSpace = revMapFields.get(fieldNamespace);

                        if (fieldDescribeNameSpace != null && fieldDescribeNameSpace.getDescribe().getLabel() != null) {
                            tempRevFieldLabel = revMapFields.get(fieldNamespace).getDescribe().getLabel();
                        } 
                        else{
                            tempRevFieldLabel =  fieldNamespace;
                        }

                        revMissingRevRequiredFieldsMap.get(rev.Name).add(tempRevFieldLabel);
                    }
                }
            }
        }

        System.debug('phaseNameMissingChangeRequiredFieldsMap: ' + phaseNameMissingChangeRequiredFieldsMap);
        System.debug('phaseNameMissingChangeAddlRequiredFieldsMap: ' + phaseNameMissingChangeAddlRequiredFieldsMap);
        System.debug('phaseNameMissingAiRequiredFieldsMap: ' + phaseNameMissingAiRequiredFieldsMap);
        System.debug('revMissingRevRequiredFieldsMap: ' + revMissingRevRequiredFieldsMap);
        System.debug('itemRevMissingCategoryAiRequiredFieldsMap: ' + itemRevMissingCategoryAiRequiredFieldsMap);

        String htmlBody = '';

        //Change and Affected Item HTML Table
        if (phaseNameMissingChangeRequiredFieldsMap.size() > 0 && phaseNameMissingAiRequiredFieldsMap.size() > 0){
            htmlBody = '<table border="1" style="border-collapse: collapse"><caption><b>Required Fields Check - Change and Affected Items</b></caption><tr><th>Phase</th><th>Change Missing Required Fields</th><th>Affected Items Missing Required Fields</th><th>Change Additional Missing Required Fields</th></tr>';

            for (String phase : phaseNameMissingChangeRequiredFieldsMap.keySet()){
                //Added on 01/12/2023: only display the current phase
                if (phase == changeCurrentPhase || changeCurrentPhase == null || changeCurrentPhase == ''){
                    List<String> currentChangeMissingRequiredFields = phaseNameMissingChangeRequiredFieldsMap.get(phase);
                    List<String> currentChangeMissingAddlRequiredFields = phaseNameMissingChangeAddlRequiredFieldsMap.get(phase);
                    List<String> currentAiMissingRequiredFields = phaseNameMissingAiRequiredFieldsMap.get(phase);

                    //Required Change Fields
                    String changeMissing = currentChangeMissingRequiredFields.size() == 0 ? 'No Missing Required Fields for Change' : String.join(currentChangeMissingRequiredFields,', ');
                    
                    //Required Affected Item Fields
                    String aiMissing = currentAiMissingRequiredFields.size() == 0 ? 'No Missing Required Fields for Affected Items' : String.join(currentAiMissingRequiredFields,', ');

                    //Additional Required Change Fields
                    String changeAddlMissing = currentChangeMissingAddlRequiredFields.size() == 0 ? 'No Missing Additional Required Fields for Change' : String.join(currentChangeMissingAddlRequiredFields,', ');

                    htmlBody += '<tr><td>' + phase + '</td><td>' + changeMissing + '</td><td>' + aiMissing + '</td><td>' + changeAddlMissing + '</td></tr>';
                }
            }

            htmlBody += '</table>';
        }
        else if (phaseNameMissingChangeRequiredFieldsMap.size() > 0){
            htmlBody = '<table border="1" style="border-collapse: collapse"><caption><b>Required Fields Check - Change and Affected Items</b></caption><tr><th>Phase</th><th>Change Missing Required Fields</th><th>Affected Items Missing Required Fields</th><th>Change Additional Missing Required Fields</th></tr>';

            for (String phase : phaseNameMissingChangeRequiredFieldsMap.keySet()){
                //Added on 01/12/2023: only display the current phase
                if (phase == changeCurrentPhase || changeCurrentPhase == null || changeCurrentPhase == ''){
                    List<String> currentChangeMissingRequiredFields = phaseNameMissingChangeRequiredFieldsMap.get(phase);
                    List<String> currentChangeMissingAddlRequiredFields = phaseNameMissingChangeAddlRequiredFieldsMap.get(phase);

                    //Required Change Fields
                    String changeMissing = currentChangeMissingRequiredFields.size() == 0 ? 'No Missing Required Fields for Change' : String.join(currentChangeMissingRequiredFields,', ');
                    
                    //Additional Required Change Fields
                    String changeAddlMissing = currentChangeMissingAddlRequiredFields.size() == 0 ? 'No Missing Additional Required Fields for Change' : String.join(currentChangeMissingAddlRequiredFields,', ');

                    htmlBody += '<tr><td>' + phase + '</td><td>' + changeMissing + '</td><td>' + 'N/A' + '</td><td>' + changeAddlMissing + '</td></tr>';
                }
            }

            htmlBody += '</table>';
        }
        
        //Item Revision HTML Table
        if (revMissingRevRequiredFieldsMap.size() > 0){
            String htmlBodyRev = '<br><table border="1" style="border-collapse: collapse"><caption><b>Required Fields Check - Item Revisions</b></caption><tr><th>Item Revision</th><th>Missing Required Fields</th></tr>';

            for (String revName : revMissingRevRequiredFieldsMap.keySet()){
                List<String> currentRevMissingRequiredFields = revMissingRevRequiredFieldsMap.get(revName);
                // String revMissing = currentRevMissingRequiredFields.size() == 0 ? 'No Missing Required Fields for Item Revisions' : String.join(currentRevMissingRequiredFields,', ');
                // htmlBodyRev += '<tr><td>' + revName + '</td><td>' + revMissing + '</td></tr>';

                if (currentRevMissingRequiredFields.size() > 0){
                    String revMissing = String.join(currentRevMissingRequiredFields,', ');
                    htmlBodyRev += '<tr><td>' + revName + '</td><td>' + revMissing + '</td></tr>';
                }
            }

            if (htmlBodyRev == '<br><table border="1" style="border-collapse: collapse"><caption><b>Required Fields Check - Item Revisions</b></caption><tr><th>Item Revision</th><th>Missing Required Fields</th></tr>'){
                htmlBodyRev = '<br><b>No Missing Required Fields for Item Revisions</b><br>';
            }
            else{
                htmlBodyRev += '</table>';
            }

            htmlBody += htmlBodyRev; 
        }

        //Category Affected Items HTML Table
        if (itemRevMissingCategoryAiRequiredFieldsMap.size() > 0){
            String htmlBodyTemp = '<br><table border="1" style="border-collapse: collapse"><caption><b>Required Fields Check - Affected Items (Category-Specific)</b></caption><tr><th>Item Number</th><th>Affected Items Missing Required Fields (Category-Specific)</th></tr>';
            
            for (String itemRev : itemRevMissingCategoryAiRequiredFieldsMap.keySet()){
                List<String> currentCategoryAiMissingRequiredFields = itemRevMissingCategoryAiRequiredFieldsMap.get(itemRev);
                if (currentCategoryAiMissingRequiredFields.size() > 0){
                    String categoryAiMissing = String.join(currentCategoryAiMissingRequiredFields,', ');
                    htmlBodyTemp += '<tr><td>' + itemRev + '</td><td>' + categoryAiMissing + '</td></tr>';
                }
            }

            if (htmlBodyTemp == '<br><table border="1" style="border-collapse: collapse"><caption><b>Required Fields Check - Affected Items (Category-Specific)</b></caption><tr><th>Item Number</th><th>Affected Items Missing Required Fields (Category-Specific)</th></tr>'){
                htmlBodyTemp = '<br><b>No Missing Required Fields for Affected Item (Category-Specific)</b><br>';
            }
            else{
                htmlBodyTemp += '</table>';
            }
             
            htmlBody += htmlBodyTemp; 
        }

        List<String> returnedString = new List<String> {htmlBody};
        return returnedString;
    }

    public static List<String> checkUnreleasedChildren(Id recordId, List<PDLM__Assembly__c> assemblies){
        /**
         * It checks
         *  If there is any unreleased children
         *  Or any unreleased children are not included in the current Change Order
         */

        String htmlBody = '<br><table border="1" style="border-collapse: collapse"><caption><b>Unreleased Children</b></caption><tr><th>Parent Item Revision</th><th>Unreleased Child Name</th></tr>';
        
        List<Id> itemRevisionIdOnChange = new List<Id>();
        for (PDLM__Affected_Item__c ai : [SELECT Id, PDLM__Item_Revision__c FROM PDLM__Affected_Item__c 
                                          WHERE PDLM__Change_Order_lk__c = :recordId OR PDLM__Quality_Issue_lk__c = :recordId]){
            itemRevisionIdOnChange.add(ai.PDLM__Item_Revision__c);
        }

        for (PDLM__Assembly__c ass : assemblies){
            if (!itemRevisionIdOnChange.contains(ass.PDLM__Item__r.PDLM__Latest_Revision__c) && ass.PDLM__Item__r.PDLM__Latest_Released_Revision__c == null){
                htmlBody += '<tr><td>' + ass.PDLM__Item_Revision__r.Name + '</td><td>' + ass.PDLM__Item__r.Name + '</td></tr>';
            }
        }

        if (htmlBody == '<br><table border="1" style="border-collapse: collapse"><caption><b>Unreleased Children</b></caption><tr><th>Parent Item Revision</th><th>Unreleased Child Name</th></tr>'){
            htmlBody = '<br><b>No Unreleased Children Found.</b><br>';
        }
        else{
            htmlBody += '</table>';
        }
        
        List<String> returnedString = new List<String> {htmlBody};
        return returnedString;
    }

    //Deactivated on 01/12/2023
    // public static List<String> checkInactiveApprovers(Id recordId){
    //     String htmlBody = '<br><table border="1" style="border-collapse: collapse"><caption><b>Inactive Approvers</b></caption><tr><th>Phase</th><th>List of Inactive Approvers</th></tr>';
    //     Map<Id, Set<Id>> phaseApproversSetMap = new Map<Id, Set<Id>>();
    //     Map<Id, String> phaseIdNameMap = new Map<Id, String>();
    //     Map<String, Set<String>> phaseNameInactiveApproversSetMap = new Map<String, Set<String>>();
    //     Set<Id> userIds = new Set<Id>();

    //     for (PDLM__Change_Phase__c phase : [SELECT Id, Name, PDLM__Approver_1__c, PDLM__Approver_2__c, PDLM__Approver_3__c,  PDLM__Approver_4__c,
    //                                         PDLM__Approver_5__c, PDLM__Approver_6__c, PDLM__Approver_7__c,  PDLM__Approver_8__c,
    //                                         PDLM__Approver_9__c, PDLM__Approver_10__c, PDLM__Approver_11__c,  PDLM__Approver_12__c,
    //                                         PDLM__Approver_13__c, PDLM__Approver_14__c, PDLM__Approver_15__c,  PDLM__Approver_16__c,
    //                                         PDLM__Approver_17__c, PDLM__Approver_18__c, PDLM__Approver_19__c,  PDLM__Approver_20__c 
    //                                         FROM PDLM__Change_Phase__c WHERE PDLM__Approver_1__c != null AND 
    //                                         (PDLM__Change_lk__c = :recordId OR PDLM__Quality_lk__c = :recordId)]){
    //         if (!phaseApproversSetMap.containsKey(phase.Id)){
    //             phaseApproversSetMap.put(phase.Id, new Set<Id> ());
    //         }

    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_1__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_2__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_3__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_4__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_5__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_6__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_7__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_8__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_9__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_10__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_11__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_12__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_13__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_14__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_15__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_16__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_17__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_18__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_19__c);
    //         phaseApproversSetMap.get(phase.Id).add(phase.PDLM__Approver_20__c);
    //         userIds.addAll(phaseApproversSetMap.get(phase.Id));
    //         phaseIdNameMap.put(phase.Id, phase.Name);
    //     }

    //     if (phaseApproversSetMap.size() > 0){
    //         for (ProcessInstanceWorkitem piwi : [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId, OriginalActorId, ActorId 
    //                                              FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId in :phaseApproversSetMap.keySet()]){
    //             Id currentPhaseId = piwi.ProcessInstance.TargetObjectId;
    //             phaseApproversSetMap.get(currentPhaseId).add(piwi.OriginalActorId);
    //             phaseApproversSetMap.get(currentPhaseId).add(piwi.ActorId);
    //             userIds.addAll(phaseApproversSetMap.get(currentPhaseId));
    //         }

    //         System.debug('phaseApproversSetMap: ' + phaseApproversSetMap);

    //         Map<Id, User> userIdUserMap = new Map<Id, User>([SELECT Id, Name, IsActive FROM User WHERE Id in :userIds]);

    //         for (Id phaseId : phaseApproversSetMap.keySet()){
    //             String phaseName = phaseIdNameMap.get(phaseId);

    //             if (!phaseNameInactiveApproversSetMap.containsKey(phaseName)){
    //                 phaseNameInactiveApproversSetMap.put(phaseName, new Set<String>());
    //             }

    //             for (Id userId : phaseApproversSetMap.get(phaseId)){
    //                 if (userId != null && userIdUserMap.get(userId).IsActive == false){
    //                     phaseNameInactiveApproversSetMap.get(phaseName).add(userIdUserMap.get(userId).Name);
    //                 }
    //             }
    //         }
                
    //         System.debug('phaseNameInactiveApproversSetMap: ' + phaseNameInactiveApproversSetMap);
                
    //         if (phaseNameInactiveApproversSetMap.size() > 0){
    //             for (String phaseName : phaseNameInactiveApproversSetMap.keySet()){
    //                 List<String> inactiveApproversSet = new List<String> (phaseNameInactiveApproversSetMap.get(phaseName));
    //                 String inactiveApprovers = inactiveApproversSet.size() == 0 ? 'All Approvers are Active.' : String.join(inactiveApproversSet,', ');
    //                 htmlBody += '<tr><td>' + phaseName + '</td><td>' + inactiveApprovers + '</td></tr>';
    //             }

    //             htmlBody += '</table>';
    //         }
    //     }

    //     List<String> returnedString = new List<String> {htmlBody};
    //     return returnedString;
    // }

    public static List<String> checkInvalidChildPhases(Id recordId, List<PDLM__Phase__c> phasesForItem, List<PDLM__Assembly__c> assemblies, Map<Id, String> ecoAiItemIdLatestPhaseMap ){
        /**
         * Child Phase ex: Part: Initial, Document: Prototype, Production
         * Format: Lifecycle1: Phase1, Phase2, Lifecycle2: Phase1, Phase2, Phase3
         */

        String htmlBody = '<br><table border="1" style="border-collapse: collapse"><caption><b>Invalid Child Phases</b></caption><tr><th>Parent Item Revision</th><th>Child Item Number</th><th>Child Lifecycle Name</th><th>Current Phase</th><th>Allowed Phase</th></tr>';
        Map<String, String> itemLifecyclePhaseNameChildPhasesMap = new Map<String, String>();
        // Map<String, Map<String,String>> itemLifecycleValidPhasesParsedMap = new Map<String, Map<String, String>>();

        for (PDLM__Phase__c phase : phasesForItem){
            String tempLifecyclePhaseConcat = phase.PDLM__Lifecycle__r.Name + '|' + phase.Name;
            itemLifecyclePhaseNameChildPhasesMap.put(tempLifecyclePhaseConcat, phase.PDLM__Child_Phases__c);

            // if (phase.PDLM__Child_Phases__c != null && phase.PDLM__Child_Phases__c.contains(':')){
            //     itemLifecycleValidPhasesParsedMap.put(tempLifecyclePhaseConcat, parseStringIntoMap(phase.PDLM__Child_Phases__c));
            // }
            // else {
            //     itemLifecycleValidPhasesParsedMap.put(tempLifecyclePhaseConcat, new Map<String, String>());
            // }
        }

        System.debug('itemLifecyclePhaseNameChildPhasesMap: ' + itemLifecyclePhaseNameChildPhasesMap);
        // System.debug('itemLifecycleValidPhasesParsedMap: ' + itemLifecycleValidPhasesParsedMap);
        System.debug('ecoAiItemIdLatestPhaseMap: ' + ecoAiItemIdLatestPhaseMap);
        
        for (PDLM__Assembly__c ass : assemblies){
            String currentLifecyclePhaseConcat = ass.PDLM__Item_Revision__r.PDLM__Master_Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name + '|' + ass.PDLM__Item_Revision__r.PDLM__Lifecycle_Phase__c;
            String currentAllowedChildPhases = itemLifecyclePhaseNameChildPhasesMap.get(currentLifecyclePhaseConcat);
            String currentChildPhase = ass.PDLM__Item__r.PDLM__Latest_Lifecycle_Phase__c.replace(' (Pending)', '').trim();
            // String currentValidPhasesParsed = itemLifecycleValidPhasesParsedMap.get(currentLifecyclePhaseConcat).get(ass.PDLM__Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name);
            List<String> currentAllowedPhasesList = currentAllowedChildPhases.split(',');
            String childLifecycleName = ass.PDLM__Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name;

            //Check if the child revisions with invalid child phase are in the same change order or not
            if (ecoAiItemIdLatestPhaseMap.containsKey(ass.PDLM__Item__c) &&
            (currentAllowedPhasesList.contains(ecoAiItemIdLatestPhaseMap.get(ass.PDLM__Item__c)) ||
            ass.PDLM__Item_Revision__r.PDLM__Master_Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name == ass.PDLM__Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name &&
            currentAllowedPhasesList.contains(ass.PDLM__Item__r.PDLM__Latest_Revision__r.PDLM__Lifecycle_Phase__c))){
                continue;
            }
            else if (ecoAiItemIdLatestPhaseMap.containsKey(ass.PDLM__Item__c) &&
            !currentAllowedPhasesList.contains(ecoAiItemIdLatestPhaseMap.get(ass.PDLM__Item__c)) &&
            ass.PDLM__Item_Revision__r.PDLM__Master_Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name == ass.PDLM__Item__r.PDLM__Category__r.PDLM__Lifecycle__r.Name &&
            !currentAllowedPhasesList.contains(ass.PDLM__Item__r.PDLM__Latest_Revision__r.PDLM__Lifecycle_Phase__c)
            ){
                String tempDraftLifecylePhase = ass.PDLM__Item__r.PDLM__Latest_Revision__r.PDLM__Lifecycle_Phase__c;
                htmlBody += '<tr><td>' + ass.PDLM__Item_Revision__r.Name + '</td><td>' + ass.PDLM__Item__r.Name + '</td><td>' + childLifecycleName + '</td><td>' + tempDraftLifecylePhase  + '</td><td>' + currentAllowedChildPhases  + '</td></tr>';
            }
            // else if (currentValidPhasesParsed != null && !currentValidPhasesParsed.contains(currentChildPhase)){
            //     htmlBody += '<tr><td>' + ass.PDLM__Item_Revision__r.Name + '</td><td>' + ass.PDLM__Item__r.Name + '</td><td>' + childLifecycleName + '</td><td>' + currentChildPhase  + '</td><td>' + currentValidPhasesParsed  + '</td></tr>';
            // }
            else if (currentAllowedChildPhases != null && !currentAllowedChildPhases.contains(currentChildPhase)){
                htmlBody += '<tr><td>' + ass.PDLM__Item_Revision__r.Name + '</td><td>' + ass.PDLM__Item__r.Name + '</td><td>' + childLifecycleName + '</td><td>' + currentChildPhase  + '</td><td>' + currentAllowedChildPhases  + '</td></tr>';
            }
        }

        if (htmlBody == '<br><table border="1" style="border-collapse: collapse"><caption><b>Invalid Child Phases</b></caption><tr><th>Parent Item Revision</th><th>Child Item Number</th><th>Child Lifecycle Name</th><th>Current Phase</th><th>Allowed Phase</th></tr>'){
            htmlBody = '<br><b>No Disallowed Child Phases Found.</b><br>';
        }
        else{
            htmlBody += '</table>';
        }
        
        List<String> returnedString = new List<String> {htmlBody};

        return returnedString;
    }

    public static Map<String, String> parseStringIntoMap(String stringToParse){
        Map<String, String> mapToReturn = new Map<String, String>();

        while (stringToParse.contains(':')){
            List<String> tempKeyValueStringList = stringToParse.split(':');
            String valueInMap = tempKeyValueStringList.get(tempKeyValueStringList.size()-1); //Get the last element from the map, which will be the value in the map
            tempKeyValueStringList.remove(tempKeyValueStringList.size()-1); //Remove the processed value from the List
            String keyInMap =  tempKeyValueStringList.get(tempKeyValueStringList.size()-1);
            String newKeyInMap = keyInMap.right(keyInMap.length() - keyInMap.lastIndexOf(',') - 1);
            tempKeyValueStringList.remove(tempKeyValueStringList.size()-1);
            tempKeyValueStringList.add(keyInMap.left(keyInMap.lastIndexOf(','))); //Remove the processed key from the List
            newKeyInMap = newKeyInMap.trim();
            valueInMap = valueInMap.trim();
            
            if (!mapToReturn.containsKey(newKeyInMap)){
                mapToReturn.put(newKeyInMap, valueInMap);
            }
            else{
                String currentValue = mapToReturn.get(newKeyInMap);
                mapToReturn.put(newKeyInMap, currentValue + ',' + valueInMap);
            }
            stringToParse = String.join(tempKeyValueStringList, ':');
        }
        
        System.debug('mapToReturn: ' + mapToReturn);
        return mapToReturn;
    }

    public static Map<String, Object> convertStringObjectMapLowerKey(Map<String, Object> inputMap){
        Map<String, Object> outputMap = new Map<String, Object>();

        for (String key : inputMap.keySet()){
            outputMap.put(key.trim().toLowerCase(), inputMap.get(key));
        }

        return outputMap;
    }

    public static Map<String, Schema.SObjectField> convertStringObjectFieldsMapLowerKey(Map<String, Schema.SObjectField> inputMap){
        Map<String, Schema.SObjectField> outputMap = new Map<String, Schema.SObjectField>();

        for (String key : inputMap.keySet()){
            outputMap.put(key.trim().toLowerCase(), inputMap.get(key));
        }

        return outputMap;
    }
}
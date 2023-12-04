global with sharing class PropelSapEventServiceClass {
    public static results afterInsert(List<SAP_Integration_Event__e> events) {
    /**
    * It's processing all the changes no matter what category they have since we need to set some of them to Not Applicable
    * This trigger does three things
    * 1. Pre-filtering after the Change is released (flag: Pre_filtering_After_Release__c)
    * 2. Update NFR_to_FR_Change__c and Create_SAP_Material__c before Item Revision is released (flag: Field_Update_Before_Release__c)
    * 3. Insert qualified BOMs to the SAP_BOM_Interface_Status__c custom object
    * 4. Before Change_Interface_Status__c is set, we will need to check if there is any previous revisions are blocking us.
    *           When ALL Affected Items' Previously Released Revision's Overall Change Interface Status NOT EQUAL TO
    *                   Completed or Manually Completed or <<< Not Applicable >>>
    *           Set Change_Interface_Status__c = Queued
    * 
    * Added on 01/05/2023
    *       - Turn off Item Revision Trigger and Item Trigger during this process
    *       - Turn it back on after the job is done
    */
    
        //For Pre-filtering After Release
        List<Id> changeRecordIdsFromFlow = new List<Id>();
        List<PDLM__Change__c> changesToUpdate = new List<PDLM__Change__c>();
        List<PDLM__Item_Revision__c> itemRevisions = new List<PDLM__Item_Revision__c>();
        List<PDLM__Item_Revision__c> revsToUpdate = new List<PDLM__Item_Revision__c>();
        List<Id> itemIds = new List<Id>();
        List<PDLM__Item__c> itemRecordsToUpdate = new List<PDLM__Item__c>();
        List<Id> prevReleasedRevIds = new List<Id>();
        Map<Id, Integer> changeAisNonSapCountMap = new Map<Id, Integer>();
        Map<Id, PDLM__Affected_Item__c> revIdAiRecordMap = new Map<Id, PDLM__Affected_Item__c>();
        Map<Id, PDLM__Item_Revision__c> itemRevisionsToUpdateMap = new Map<Id, PDLM__Item_Revision__c>();
        Map<String, Schema.SObjectField> revMapFields = Schema.SObjectType.PDLM__Item_Revision__c.fields.getMap();
        Map<Id, List<PDLM__Item_Revision__c>> itemIdRevsMap = new Map<Id, List<PDLM__Item_Revision__c>>();
        Map<Id, PDLM__Item_Revision__c> itemIdLatestReleasedRevDoubleCheckMap = new Map<Id, PDLM__Item_Revision__c>();
        Map<Id, PDLM__Item_Revision__c> revIdRevRecordMap = new Map<Id, PDLM__Item_Revision__c>();
        Map<Id, Integer> revIdBomTotalCountMap = new Map<Id, Integer>();
        Map<Id, Integer> revIdBomNonSapCountMap = new Map<Id, Integer>();
        Map<Id, String> revIdChangeCategoryNameMap = new Map<Id, String>();
        Map<Id, PDLM__Change__c> changeIdChangeRecordMap = new Map<Id, PDLM__Change__c>();
        Map<Id, Id> itemIdLatestChangeIdMap = new Map<Id, Id>();
        Map<Id, String> revIdMakeBuyTransitionMap = new Map<Id, String>();
        String NaPicklistApiName = null;
        String[] categoryNamesList = new List<String>();
        String buyApiName = null;
        String subcontractingApiName = null;
        String revFieldsParsed = '';
        String[] revFieldsList = new List<String>();

        //For Field Update Before Rlease
        List<Id> changeIdsForAisAndRevs = new List<Id>();
        List<PDLM__Item_Revision__c> revsFromFieldUpdates = new List<PDLM__Item_Revision__c>();
        Map<Id, PDLM__Affected_Item__c> revIdAiRecordFieldUpdateMap = new Map<Id, PDLM__Affected_Item__c>();
        Map<Id, PDLM__Item_Revision__c> itemRevisionsFieldUpdateMap = new Map<Id, PDLM__Item_Revision__c>();
        
        //For SAP_BOM_Interface_Status__c custom object insert
        List<PDLM__Assembly__c> boms = new List<PDLM__Assembly__c>();
        List<SAP_BOM_Interface_Status__c> bomStatusesToInsert = new List<SAP_BOM_Interface_Status__c>();
        Map<Id, Set<String>> revIdSitesMap = new Map<Id, Set<String>>();
        List<String> existingStatusesList = new List<String>();

        //Loop through records that trigger the Process Builder or Flow
        for (SAP_Integration_Event__e event : events){
            if (event.Pre_filtering_After_Release__c == true && event.Change_Record_Id__c != null){
                changeRecordIdsFromFlow.add(event.Change_Record_Id__c);
                NaPicklistApiName = event.Not_Applicable_Picklist_API_Name__c;
                buyApiName = event.Buy_Picklist_API_Nam__c;
                subcontractingApiName = event.X30_Subcontracting_Picklist_API_Name__c;
                categoryNamesList = event.Change_Category_e_g_ECO_ECO_QMS__c.split(';');
                revFieldsList = event.Rev_Fields_e_g_Name_MSC_Group_c__c.split(';');
                revFieldsParsed = String.join(revFieldsList, ',').trim();
            }
            else if (event.Field_Update_Before_Release__c == true && event.Change_Record_Id__c != null){
                changeIdsForAisAndRevs.add(event.Change_Record_Id__c);
            }
        }

        System.debug('changeRecordIdsFromFlow: ' + changeRecordIdsFromFlow);
        System.debug('categoryNamesList: ' + categoryNamesList);
        System.debug('revFieldsParsed: ' + revFieldsParsed);
        System.debug('changeIdsForAisAndRevs: ' + changeIdsForAisAndRevs);

        if (changeRecordIdsFromFlow.size() > 0){
            /**
             * Update Change_Interface_Status__c = '<<< Not Applicable >>>' when
             *      Categories NOT in ECO-QMS, ECO, BCO-QMS, BCO
             * OR
             *      (Categories in ECO-QMS, ECO, BCO-QMS, BCO
             * AND
             *      If a change order has no valid items to sent to SAP, then in lieu of “Success” value being set in PLM, the status of the interface value on the change object shall be “<<< Not Applicable >>>”
             *          All Affected Items have PDLM__Affected_Item__c.Send_To_SAP__c = false) OR
             *          There is no Affected Item 
            */

            //Query Affected Items
            for (PDLM__Affected_Item__c ai : [SELECT Id, PDLM__Change_Order_lk__c, PDLM__Change_Order_lk__r.PDLM__Category__r.Name, 
                                            PDLM__Item_Revision__c, Send_To_SAP__c, PDLM__Item_Revision__r.PDLM__Master_Item__c  
                                            FROM PDLM__Affected_Item__c WHERE PDLM__Change_Order_lk__c in :changeRecordIdsFromFlow]){
                                                
                itemIds.add(ai.PDLM__Item_Revision__r.PDLM__Master_Item__c);
                itemIdLatestChangeIdMap.put(ai.PDLM__Item_Revision__r.PDLM__Master_Item__c, ai.PDLM__Change_Order_lk__c);

                if (ai.Send_To_SAP__c == false){
                    if (!changeAisNonSapCountMap.containsKey(ai.PDLM__Change_Order_lk__c)){
                        changeAisNonSapCountMap.put(ai.PDLM__Change_Order_lk__c, 1);
                    }
                    else{
                        Integer tempCount = changeAisNonSapCountMap.get(ai.PDLM__Change_Order_lk__c);
                        changeAisNonSapCountMap.put(ai.PDLM__Change_Order_lk__c, tempCount + 1);
                    }
                }

                revIdAiRecordMap.put(ai.PDLM__Item_Revision__c, ai);
                revIdChangeCategoryNameMap.put(ai.PDLM__Item_Revision__c, ai.PDLM__Change_Order_lk__r.PDLM__Category__r.Name);
            }

            System.debug('itemIds: ' + itemIds);
            System.debug('revIdAiRecordMap: ' + revIdAiRecordMap);
            System.debug('changeAisNonSapCountMap: ' + changeAisNonSapCountMap);
            System.debug('itemIdLatestChangeIdMap: ' + itemIdLatestChangeIdMap);
            
            //Query Changes
            for (PDLM__Change__c chg : [SELECT Id, Name, PDLM__Category__r.Name, Change_Interface_Status__c, PDLM__Affected_Item_Counter__c, 
                                        Ready_for_SAP_Processing__c, Overall_Interface_Status__c
                                        FROM PDLM__Change__c WHERE Id in :changeRecordIdsFromFlow]){   
                
                if (!categoryNamesList.contains(chg.PDLM__Category__r.Name)){
                    chg.Change_Interface_Status__c = NaPicklistApiName;
                    chg.Overall_Interface_Status__c = NaPicklistApiName;
                }
                else if (chg.PDLM__Affected_Item_Counter__c == 0 || 
                chg.PDLM__Affected_Item_Counter__c == changeAisNonSapCountMap.get(chg.Id)){
                    chg.Change_Interface_Status__c = NaPicklistApiName;
                    chg.Overall_Interface_Status__c = NaPicklistApiName;
                }
                else{
                    chg.Ready_for_SAP_Processing__c = true;
                }       
                
                changeIdChangeRecordMap.put(chg.Id, chg);
            }

            /**
             * Update SAP_Material_Interface_Status__c to "<<< Not Applicable >>>" when 
             *          PDLM__Affected_Item__c.Send_To_SAP__c = false 
             * OR
             *          If there are no SAP values redlined, then no updates to SAP are necessary and the Material Interface Status field on the Affected Items shall be set to “<<< Not Applicable >>>"
             *              Get lastest and second latest released revisions
             * 
             * Update SAP_BOM_Interface_Status__c to "<<< Not Applicable >>>" when
             *          Part has no BOM
             * OR
             *          Part is Make/Buy = Buy and Special Procurement != '30 - Subcontracting'
             *          Added on 08/15/2022: When transitioning from Make to Buy and Special Procurement != '30 - Subcontracting'
             *                  - Need to compare two latest released revisions
             *                  - The BOM should be sent to SAP with BOM Header ONLY (BOM Status included and no children)
             *                  - PDLM__Item_Revision__c.SAP_BOM_Interface_Status__c should not be set as <<< Not Applicable >>>
             */

            /**
             * Update the Previously Released Revision on Item when an Item is released via Changes starts with BCO or ECO
             * The trigger conditions are covered by the Flow when passing the list of Categories
            */

            /**
             * Update SAP_New_BOM__c on Item Revision
             * Update the flag when SAP_BOM_Interface_Status__c changed from N/A on Previously Released Revision to null on current Latest Released Revision
             * OR
             * There is only one revision and the status is null
             * It's a new BOM and update the field
             */

            //Query Item Revision
            String revQuery = String.format('SELECT {0}, Id, Name, PDLM__Master_item__c, PDLM__Is_Latest_Released__c, PDLM__Has_Bom__c, ' +
                                            'SAP_BOM_Interface_Status__c, SAP_Material_Interface_Status__c, PDLM__Related_Change__c, Send_to_SAP__c ' + 
                                            'FROM PDLM__Item_Revision__c WHERE PDLM__Master_item__c in :itemIds and PDLM__Released__c = true ' +
                                            'and Deviation_Revision__c != true ORDER BY PDLM__Released_Date_Time__c DESC', new list<string>{revFieldsParsed}); 
            itemRevisions.addAll((List<PDLM__Item_Revision__c>)(Database.query(revQuery)));
            System.Debug('revQuery: ' + revQuery);
            System.Debug('Item Revision Records: ' + itemRevisions);
            
            //Create the Item Id to Item Revisions Record List Map
            for (PDLM__Item_Revision__c rev : itemRevisions){
                revIdRevRecordMap.put(rev.Id, rev);

                if (rev.PDLM__Is_Latest_Released__c == true && (rev.PDLM__Has_Bom__c == false || 
                (rev.Make_or_Buy__c == buyApiName && rev.Special_Procurement__c != subcontractingApiName) ||
                !categoryNamesList.contains(revIdChangeCategoryNameMap.get(rev.Id)))){                
                    rev.SAP_BOM_Interface_Status__c = NaPicklistApiName;
                    itemRevisionsToUpdateMap.put(rev.Id, rev);               
                }

                if (rev.PDLM__Is_Latest_Released__c == true && (revIdAiRecordMap.get(rev.Id).Send_To_SAP__c == false || 
                !categoryNamesList.contains(revIdChangeCategoryNameMap.get(rev.Id)))){
                    rev.SAP_Material_Interface_Status__c = NaPicklistApiName;
                    rev.SAP_BOM_Interface_Status__c = NaPicklistApiName;
                    itemRevisionsToUpdateMap.put(rev.Id, rev);
                }
                else if (rev.PDLM__Is_Latest_Released__c == true){
                    itemIdLatestReleasedRevDoubleCheckMap.put(rev.PDLM__Master_item__c, rev);
                }
                
                if (itemIdRevsMap.containsKey(rev.PDLM__Master_item__c)){
                    itemIdRevsMap.get(rev.PDLM__Master_item__c).add(rev);
                }
                else{
                    itemIdRevsMap.put(rev.PDLM__Master_item__c, new List<PDLM__Item_Revision__c> {rev});
                }
            }

            System.Debug('itemIdLatestReleasedRevDoubleCheckMap: ' + itemIdLatestReleasedRevDoubleCheckMap);
            System.Debug('itemIdRevsMap: ' + itemIdRevsMap);
            System.debug('itemRevisionsToUpdateMap when no Item or no BOMs or no Qualified BOMs to send: ' + itemRevisionsToUpdateMap);

            //Loop through and compare the value between the last two Latest Released Revisions
            for (Id itemId : itemIdRevsMap.keySet()){
                PDLM__Item_Revision__c latestReleasedRev  = itemIdLatestReleasedRevDoubleCheckMap.get(itemId);
                Boolean notApplicableFlag = true;

                //Update Previously Released Revision
                if (itemIdRevsMap.get(itemId).size() >= 2){
                    PDLM__Item__c tempItem = new PDLM__Item__c();
                    tempItem.Id = itemId;
                    tempItem.Previously_Released_Revision__c = itemIdRevsMap.get(itemId)[1].Id;
                    itemRecordsToUpdate.add(tempItem);
                    prevReleasedRevIds.add(itemIdRevsMap.get(itemId)[1].Id);
                }

                if (latestReleasedRev == null){continue;}

                for (String field : revFieldsList){
                    field = field.trim();

                    if (itemIdRevsMap.get(itemId).size() >= 2 && itemIdRevsMap.get(itemId)[0].get(field) != itemIdRevsMap.get(itemId)[1].get(field)){
                        //It means at least one of the AIs meets the criteria, so we can't set SAP_Material_Interface_Status__c to "<<< Not Applicable >>>"
                        notApplicableFlag = false;
                        break;
                    }
                }

                if ((itemIdRevsMap.get(itemId).size() >= 2 && notApplicableFlag) || 
                !categoryNamesList.contains(revIdChangeCategoryNameMap.get(latestReleasedRev.Id))){
                    latestReleasedRev.SAP_Material_Interface_Status__c = NaPicklistApiName;
                    latestReleasedRev.SAP_BOM_Interface_Status__c = NaPicklistApiName;
                    itemRevisionsToUpdateMap.put(latestReleasedRev.Id, latestReleasedRev);
                }

                if ((itemIdRevsMap.get(itemId).size() >= 2 && 
                itemIdRevsMap.get(itemId)[0].SAP_BOM_Interface_Status__c == null &&
                itemIdRevsMap.get(itemId)[1].SAP_BOM_Interface_Status__c == NaPicklistApiName) || 
                (itemIdRevsMap.get(itemId).size() == 1 && 
                itemIdRevsMap.get(itemId)[0].SAP_BOM_Interface_Status__c == null)){
                    latestReleasedRev.SAP_New_BOM__c = true;
                    itemRevisionsToUpdateMap.put(latestReleasedRev.Id, latestReleasedRev);
                }
            }

            System.debug('itemRevisionsToUpdateMap: ' + itemRevisionsToUpdateMap);

            /**
             * Update SAP_BOM_Interface_Status__c to "<<< Not Applicable >>>" when
             *          Part has a BOM no valid children to send (PDLM__Assembly__c.Send_To_SAP__c = false for all children)
             */

            //Query Assemblies
            for (PDLM__Assembly__c ass : [SELECT Id, PDLM__Item_Revision__c, Send_To_SAP__c FROM PDLM__Assembly__c 
                                            WHERE PDLM__Item_Revision__c in :itemIdLatestReleasedRevDoubleCheckMap.values() ORDER BY PDLM__Item_Revision__c]){

                if (!revIdBomNonSapCountMap.containsKey(ass.PDLM__Item_Revision__c)){
                    revIdBomNonSapCountMap.put(ass.PDLM__Item_Revision__c, 0);
                }

                if (!revIdBomTotalCountMap.containsKey(ass.PDLM__Item_Revision__c)){
                    revIdBomTotalCountMap.put(ass.PDLM__Item_Revision__c, 0);
                }

                if (ass.Send_To_SAP__c == false){
                    revIdBomNonSapCountMap.put(ass.PDLM__Item_Revision__c, revIdBomNonSapCountMap.get(ass.PDLM__Item_Revision__c) + 1);
                }

                revIdBomTotalCountMap.put(ass.PDLM__Item_Revision__c, revIdBomTotalCountMap.get(ass.PDLM__Item_Revision__c) + 1);
            }

            System.debug('revIdBomTotalCountMap: ' + revIdBomTotalCountMap);
            System.debug('revIdBomNonSapCountMap: ' + revIdBomNonSapCountMap);
            
            for (Id revId : revIdBomTotalCountMap.keySet()){
                if (revIdBomTotalCountMap.get(revId) == revIdBomNonSapCountMap.get(revId)){
                    PDLM__Item_Revision__c rev = revIdRevRecordMap.get(revId);

                    if (rev.SAP_BOM_Interface_Status__c != NaPicklistApiName){
                        rev.SAP_BOM_Interface_Status__c = NaPicklistApiName;
                        //If SAP_BOM_Interface_Status__c on Latest Released Revision has been set to N/A
                        //We need to remove the key from the Map
                        rev.SAP_New_BOM__c = false;
                        itemRevisionsToUpdateMap.put(rev.Id, rev);
                    }
                }
            }

            System.debug('itemRevisionsToUpdateMap when no BOM to send: ' + itemRevisionsToUpdateMap);

            //Added on 08/15/2022
            //This should be checked the last since it's an exception and impact all the interface statuses
            for (Id itemId : itemIdRevsMap.keySet()){
                if (itemIdRevsMap.get(itemId).size() >= 2){
                    PDLM__Item_Revision__c latestReleasedRevTemp = itemIdRevsMap.get(itemId)[0];
                    PDLM__Item_Revision__c previouslyReleasedRevTemp = itemIdRevsMap.get(itemId)[1];
                    Id latestChangeId = itemIdLatestChangeIdMap.get(itemId); 

                    if (itemRevisionsToUpdateMap.containsKey(latestReleasedRevTemp.Id) && 
                    latestReleasedRevTemp.Make_or_Buy__c == buyApiName && previouslyReleasedRevTemp.Make_or_Buy__c == 'Make' && 
                    latestReleasedRevTemp.Special_Procurement__c != subcontractingApiName){
                        itemRevisionsToUpdateMap.get(latestReleasedRevTemp.Id).SAP_BOM_Interface_Status__c = null;
                        itemRevisionsToUpdateMap.get(latestReleasedRevTemp.Id).SAP_Material_Interface_Status__c = null;
                        changeIdChangeRecordMap.get(latestChangeId).Change_Interface_Status__c = null;
                        changeIdChangeRecordMap.get(latestChangeId).Overall_Interface_Status__c = null;
                        changeIdChangeRecordMap.get(latestChangeId).Ready_for_SAP_Processing__c = true;
                    }
                }
            }

            System.debug('itemRevisionsToUpdateMap after Make Buy Transition Check and before UPDATE: ' + itemRevisionsToUpdateMap);
            System.debug('changeIdChangeRecordMap after Make Buy Transition Check: ' + changeIdChangeRecordMap);

            //Triger Disable Section
            PDLM__Configuration__c itemConfig = getConfig('ItemTriggerDisable');
            PDLM__Configuration__c itemRevisionConfig = getConfig('ItemRevisionTriggerDisable');

            List<Database.SaveResult> retItems = new List<Database.SaveResult>();
            List<Database.SaveResult> retItemRevisions = new List<Database.SaveResult>();
            try {
                // set the bypass flag
                setConfiguration(itemConfig, 'true');
                setConfiguration(itemRevisionConfig, 'true');

                //UPDATE on Item Revisions
                revsToUpdate.addAll(itemRevisionsToUpdateMap.values());
                System.debug('revsToUpdate: ' + revsToUpdate);

                if (revsToUpdate.size() > 0){
                    retItemRevisions = Database.update(revsToUpdate);
                }

                //Update Previously_Released_Revision__c on Items
                System.debug('itemRecordsToUpdate: ' + itemRecordsToUpdate);

                if (itemRecordsToUpdate.size() > 0){
                    retItems = Database.update(itemRecordsToUpdate);
                }
            } 
            catch(Exception ex){
                System.debug(LoggingLevel.ERROR, retItems);
                System.debug(LoggingLevel.ERROR, retItemRevisions);
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            } 
            finally{
                // restore the flag after updating the record
                setConfiguration(itemConfig, 'false');
                setConfiguration(itemRevisionConfig, 'false');
            }

            //Set Change_Interface_Status__c to Queued if the previous one is not completed
            if (prevReleasedRevIds.size() > 0 && itemIdLatestChangeIdMap.size() > 0){
                for (PDLM__Item_Revision__c rev : [SELECT Id, Name, PDLM__Related_Change__r.Overall_Interface_Status__c, PDLM__Master_Item__c
                                                FROM PDLM__Item_Revision__c WHERE Id in :prevReleasedRevIds]){
                    String tempPrevOverallStatus = rev.PDLM__Related_Change__r.Overall_Interface_Status__c;
                    Id latestChangeId = itemIdLatestChangeIdMap.get(rev.PDLM__Master_Item__c);

                    // if (tempPrevOverallStatus != 'Completed' && tempPrevOverallStatus!= 'Manually Completed' && 
                    // tempPrevOverallStatus != NaPicklistApiName){
                    //Added on 10/27/2022
                    if (tempPrevOverallStatus == 'In Process' || tempPrevOverallStatus == 'Queued' || tempPrevOverallStatus == 'Failed'){
                        changeIdChangeRecordMap.get(latestChangeId).Change_Interface_Status__c = 'Queued';
                    }
                }
            }

            //UPDATE on Changes
            System.debug('changeIdChangeRecordMap after checking for Queued: ' + changeIdChangeRecordMap);

            //Added on 10/05/2022: check SAP_Material_Interface_Status__c before updating Changes
            Map<Id, Integer> changeIdNaMaterialStatusCountMap = new Map<Id, Integer>();
            Map<Id, Integer> changeIdTotalAiCountMap = new Map<Id, Integer>();

            for (PDLM__Item_Revision__c rev : [SELECT Id, Name, SAP_Material_Interface_Status__c, PDLM__Related_Change__c  
                                               FROM PDLM__Item_Revision__c WHERE PDLM__Related_Change__c in :changeRecordIdsFromFlow]){
                
                if (!changeIdTotalAiCountMap.containsKey(rev.PDLM__Related_Change__c)){
                    changeIdTotalAiCountMap.put(rev.PDLM__Related_Change__c, 0);
                }

                if (!changeIdNaMaterialStatusCountMap.containsKey(rev.PDLM__Related_Change__c)){
                    changeIdNaMaterialStatusCountMap.put(rev.PDLM__Related_Change__c, 0);
                }

                Integer tempAiCount = changeIdTotalAiCountMap.get(rev.PDLM__Related_Change__c);
                changeIdTotalAiCountMap.put(rev.PDLM__Related_Change__c, tempAiCount + 1);

                if (rev.SAP_Material_Interface_Status__c == NaPicklistApiName){
                    Integer tempNaMaterialCount = changeIdNaMaterialStatusCountMap.get(rev.PDLM__Related_Change__c);
                    changeIdNaMaterialStatusCountMap.put(rev.PDLM__Related_Change__c, tempNaMaterialCount + 1);
                }
            }
            for (Id chgId: changeRecordIdsFromFlow){
                if (changeIdNaMaterialStatusCountMap.get(chgId) == changeIdTotalAiCountMap.get(chgId)){
                    //Change_Interface_Status__c needs to be set to <<< Not Applicable >>>
                    if (changeIdChangeRecordMap.containsKey(chgId) && changeIdChangeRecordMap.get(chgId).Change_Interface_Status__c != NaPicklistApiName){
                        changeIdChangeRecordMap.get(chgId).Change_Interface_Status__c = NaPicklistApiName;
                        changeIdChangeRecordMap.get(chgId).Overall_Interface_Status__c = NaPicklistApiName;
                        changeIdChangeRecordMap.get(chgId).Ready_for_SAP_Processing__c = false;
                        
                    }
                    else{
                        PDLM__Change__c tempChange = new PDLM__Change__c();
                        tempChange.Id = chgId;
                        tempChange.Change_Interface_Status__c = NaPicklistApiName;
                        tempChange.Overall_Interface_Status__c = NaPicklistApiName;
                        tempChange.Ready_for_SAP_Processing__c = false;
                        changeIdChangeRecordMap.put(chgId, tempChange);
                    }
                }
            }    

            changesToUpdate.addAll(changeIdChangeRecordMap.values());
            System.debug('changesToUpdate before UPDATE: ' + changesToUpdate);

            if (changesToUpdate.size() > 0){
                update changesToUpdate;
            }

            //Loops and prepare the list of records to insert to the SAP_BOM_Interface_Status__c custom object
            boms = [SELECT Id, PDLM__Item_Revision__c, PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c,
                    PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c FROM PDLM__Assembly__c 
                    WHERE Send_To_SAP__c = TRUE 
                    AND PDLM__Item_Revision__r.PDLM__Related_Change__c in :changeRecordIdsFromFlow 
                    AND (PDLM__Item_Revision__r.PDLM__Related_Change__r.Change_Interface_Status__c = null
                        OR PDLM__Item_Revision__r.PDLM__Related_Change__r.Change_Interface_Status__c = 'Queued')
                    AND PDLM__Item_Revision__r.Send_To_SAP__c = TRUE 
                    AND PDLM__Item_Revision__r.SAP_BOM_Interface_Status__c = NULL];
            
            System.debug('boms: ' + boms);

            if (boms.size()> 0){
                for (PDLM__Assembly__C bom : boms){
                    if (bom.PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c != '<<< Not Applicable >>>' &&
                    bom.PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c != null){
                        if (!revIdSitesMap.containsKey(bom.PDLM__Item_Revision__c)){
                            revIdSitesMap.put(bom.PDLM__Item_Revision__c, new Set<String> {bom.PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c});
                        }
                        else{
                            revIdSitesMap.get(bom.PDLM__Item_Revision__c).add(bom.PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c);
                        }
                    }
                    
                    //Removed on 08/26/2022: && bom.PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c != '<<< Not Applicable >>>'
                    if (bom.PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c != null){
                        List<String> tempSalesVcSitesList = bom.PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c.split(';');
                        Set<String> tempSalesVcSitesSet = new Set<String>(tempSalesVcSitesList);
                        if (!revIdSitesMap.containsKey(bom.PDLM__Item_Revision__c)){
                            revIdSitesMap.put(bom.PDLM__Item_Revision__c, tempSalesVcSitesSet);
                        }
                        else{
                            revIdSitesMap.get(bom.PDLM__Item_Revision__c).addAll(tempSalesVcSitesSet);
                        }
                    }
                }
            }

            System.debug('revIdSitesMap: ' + revIdSitesMap);

            for (SAP_BOM_Interface_Status__c status : [SELECT Id, Item_Revision__c, Site__c FROM SAP_BOM_Interface_Status__c WHERE Completed__c = FALSE]){
                String tempConcat = status.Item_Revision__c + '-' + status.Site__c;
                existingStatusesList.add(tempConcat);
            }

            System.debug('existingStatusesList: ' + existingStatusesList);

            for (Id revId : revIdSitesMap.keySet()){
                Set<String> tempSites = revIdSitesMap.get(revId);
                if (tempSites.size() > 0){
                    for (String tempSite : tempSites){
                        String check = revId + '-' + tempSite;
                        System.debug('current revId and site: ' + check);

                        if (!existingStatusesList.contains(check)){
                            SAP_BOM_Interface_Status__c tempStatus = new SAP_BOM_Interface_Status__c();
                            tempStatus.Item_Revision__c = revId;
                            tempStatus.Site__c = tempSite;
                            bomStatusesToInsert.add(tempStatus);
                        }
                    }
                }
            }

            System.debug('bomStatusesToInsert: ' + bomStatusesToInsert);

            if (bomStatusesToInsert.size() > 0 ){
                insert bomStatusesToInsert;
            }
        }
        else if (changeIdsForAisAndRevs.size() > 0){
            /**
             * Update Create_SAP_Material__c on Item Revision
             * Update flag before released (preferred) when changing moves into SAP Implementation Tasks or Change Analyst Review phase
             *      PDLM__Affected_Item__c.PreProd_Prod_1st_Rev__c = true then CREATE SAP MATERIAL = true
             *      If SAP__MSC__c is changed from NS on the Latest Released Revisionn to something else on the current Revision
             *          Set it to TRUE
             */

            /**
             * Update NFR_to_FR_Change__c on Item Revision
             * Update flag before released (preferred) when changing moves into SAP Implementation Tasks or Change Analyst Review phase
             *      Revision on the change: Field_Service_Replaceable_Part__c = Yes AND 
             *      Previous released revision: Field_Service_Replaceable_Part__c = No
             */

            for (PDLM__Affected_Item__c ai : [SELECT Id, PreProd_Prod_1st_Rev__c, PDLM__Item_Revision__c FROM PDLM__Affected_Item__c 
                                            WHERE PDLM__Change_Order_lk__c in :changeIdsForAisAndRevs]){
                revIdAiRecordFieldUpdateMap.put(ai.PDLM__Item_Revision__c, ai);
            }

            for (PDLM__Item_Revision__c rev : [SELECT Id, Field_Service_Replaceable_Part__c, NFR_to_FR_Change__c, Create_SAP_Material__c, PDLM__Master_Item__c, 
                                            PDLM__Master_Item__r.PDLM__Latest_Released_Revision__r.Field_Service_Replaceable_Part__c, 
                                            SAP_MSC__c, PDLM__Master_Item__r.PDLM__Latest_Released_Revision__r.SAP_MSC__c
                                            FROM PDLM__Item_Revision__c WHERE PDLM__Related_Change__c in :changeIdsForAisAndRevs]){
                if (rev.Field_Service_Replaceable_Part__c == 'Yes' &&
                rev.PDLM__Master_Item__r.PDLM__Latest_Released_Revision__r.Field_Service_Replaceable_Part__c != 'Yes'){    
                    rev.NFR_to_FR_Change__c = true;
                    itemRevisionsFieldUpdateMap.put(rev.Id, rev);
                }
                
                if (revIdAiRecordFieldUpdateMap.get(rev.Id).PreProd_Prod_1st_Rev__c == true ||
                (rev.PDLM__Master_Item__r.PDLM__Latest_Released_Revision__r.SAP_MSC__c == 'NS' && rev.SAP_MSC__c != null && rev.SAP_MSC__c != 'NS')){
                    rev.Create_SAP_Material__c = true;
                    itemRevisionsFieldUpdateMap.put(rev.Id, rev);
                }
            }

            //Update Create_SAP_Material__c and NFR_to_FR_Change__c on Item Revisions
            revsFromFieldUpdates.addAll(itemRevisionsFieldUpdateMap.values());
            System.debug('revsFromFieldUpdates: ' + revsFromFieldUpdates);

            if (revsFromFieldUpdates.size() != 0){    
                update revsFromFieldUpdates;
            }
        }

        results retultsReturned = new results();
        retultsReturned.revsFromUpdate = revsToUpdate.size() > 0 ? revsToUpdate : revsFromFieldUpdates;
        retultsReturned.itemsFromUpdate = itemRecordsToUpdate;
        retultsReturned.changesFromUpdate = changesToUpdate;
        retultsReturned.bomStatusesFromInsert = bomStatusesToInsert;
        return retultsReturned;
    }

    public class results{
        //It will return list of object results for testing
        public List<PDLM__Item_Revision__c> revsFromUpdate;
        public List<PDLM__Item__c> itemsFromUpdate;
        public List<PDLM__Change__c> changesFromUpdate;
        public List<SAP_BOM_Interface_Status__c> bomStatusesFromInsert;
    }

    private static PDLM__Configuration__c getConfig(String configFlag) {
        PDLM__Configuration__c config = PDLM__Configuration__c.getValues(configFlag);
        if (config == null) { // this flag does not exist, create it now
            config = new PDLM__Configuration__c(Name = configFlag, PDLM__Value__c = 'true');
        }

        return config;
    }

    private static void setConfiguration(PDLM__Configuration__c cfg, String value) {
        cfg.PDLM__Value__c = value;
        Database.upsert(new List<sObject>{cfg});
    }
}
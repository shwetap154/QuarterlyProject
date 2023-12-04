@isTest 
public with sharing class PropelPreApprovalValidationTest {
    static void SetUpData(){
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        List<PDLM__Category__c> categoriesToInsert = new List<PDLM__Category__c>();
        List<PDLM__Autonumber__c> autonumbersToInsert = new List<PDLM__Autonumber__c>();
        List<PDLM__Lifecycle__c> lifecyclesToInsert = new List<PDLM__Lifecycle__c>();
        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();

        //Autonumbers
        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(name='Autonumber for ECO', PDLM__prefix__c = 'ECO-', PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        autonumbersToInsert.add(autonumberChange);
        PDLM__Autonumber__c autonumberFG = new PDLM__Autonumber__c(name='Autonumber for Finished Good', PDLM__prefix__c = 'FG-', PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        autonumbersToInsert.add(autonumberFG);
        PDLM__Autonumber__c autonumberPart = new PDLM__Autonumber__c(name='Autonumber for Part', PDLM__prefix__c = 'PR-', PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        autonumbersToInsert.add(autonumberPart);
        insert autonumbersToInsert;

        //Lifecycles
        lifecycleChange = new PDLM__Lifecycle__c(name='ECO');
        lifecyclesToInsert.add(lifecycleChange);
        PDLM__Lifecycle__c lifecycleFG = new PDLM__Lifecycle__c(name='Finished Good');
        lifecyclesToInsert.add(lifecycleFG);
        PDLM__Lifecycle__c lifecyclePart = new PDLM__Lifecycle__c(name='Part');
        lifecyclesToInsert.add(lifecyclePart);
        insert lifecyclesToInsert;

        //Change Phases
        pendingPhaseChange = new PDLM__Phase__c(Name='Pending', 
                                                               PDLM__Is_First_Phase__c = true, 
                                                               PDLM__order__c = 1, 
                                                               PDLM__No_Approval__c = true,
                                                               PDLM__lifecycle__c = lifecycleChange.Id,
                                                               PDLM__Required__c = 'PDLM__Title__c, Reason_for_Change__c', 
                                                               PDLM__Required_Affected_Item_Fields__c = 'Stock__c, PDLM__Notes__c', 
                                                               PDLM__Required_Category_AI_Fields__c = 'Finished Good: Stock__c, PDLM__Notes__c, Part: Stock__c');
        phasesToInsert.add(pendingPhaseChange);
        PDLM__Phase__c CCBPhaseChange = new PDLM__Phase__c(Name='PLM Review', 
                                                           PDLM__order__c = 2, 
                                                           PDLM__Auto_Submit_For_Approval__c = true, 
                                                           PDLM__lifecycle__c = lifecycleChange.Id,
                                                           PDLM__Required__c = 'Title__c, Reason_for_Change__c', 
                                                           PDLM__Required_Affected_Item_Fields__c = 'Stock__c, Notes__c', 
                                                           PDLM__Required_Category_AI_Fields__c = 'Finished Good: Stock__c, Notes__c, Part: Stock__c');
        phasesToInsert.add(CCBPhaseChange);
        PDLM__Phase__c approvedPhaseChange = new PDLM__Phase__c(Name='Released', PDLM__order__c = 3, PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycleChange.id);
        phasesToInsert.add(approvedPhaseChange);

        //Item Phases
        PDLM__Phase__c firstPhaseFG = new PDLM__Phase__c(Name='Prototype', 
                                                         PDLM__order__c = 1, 
                                                         PDLM__Default_No_Change_Control__c = true, 
                                                         PDLM__lifecycle__c = lifecycleFG.id, 
                                                         PDLM__Next_Phases__c = '["Discontinue Production", "Production"]',
                                                         PDLM__Required__c = 'Notes__c, PDLM__Description__c, Detailed_Description__c',
                                                         PDLM__Child_Phases__c = 'Finished Good: Production, Part: Released');
        phasesToInsert.add(firstPhaseFG);
        PDLM__Phase__c secondPhaseFG = new PDLM__Phase__c(Name='Production', PDLM__order__c = 2, PDLM__Default_No_Change_Control__c = true, 
                                                          PDLM__lifecycle__c = lifecycleFG.id, PDLM__Next_Phases__c = '["Discontinue Production"]');
        phasesToInsert.add(secondPhaseFG);
        PDLM__Phase__c thirdPhaseFG = new PDLM__Phase__c(Name='Discontinue Production', PDLM__order__c = 3, PDLM__Default_No_Change_Control__c = true, 
                                                         PDLM__lifecycle__c = lifecycleFG.id);
        phasesToInsert.add(thirdPhaseFG);
        PDLM__Phase__c firstPhasePart = new PDLM__Phase__c(Name='Prototype', PDLM__order__c = 1, PDLM__Default_No_Change_Control__c = true, 
                                                         PDLM__lifecycle__c = lifecyclePart.id, PDLM__Next_Phases__c = '["Inactive", "Released"]');
        phasesToInsert.add(firstPhasePart);
        PDLM__Phase__c secondPhasePart = new PDLM__Phase__c(Name='Released', PDLM__order__c = 2, PDLM__Default_No_Change_Control__c = true, 
                                                          PDLM__lifecycle__c = lifecyclePart.id, PDLM__Next_Phases__c = '["Inactive"]');
        phasesToInsert.add(secondPhasePart);
        PDLM__Phase__c thirdPhasePart = new PDLM__Phase__c(Name='Inactive', PDLM__order__c = 3, PDLM__Default_No_Change_Control__c = true, 
                                                         PDLM__lifecycle__c = lifecyclePart.id);
        phasesToInsert.add(thirdPhasePart);
        insert phasesToInsert;

        //Categories
        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycleChange.id);
        categoriesToInsert.add(categoryForChange);
        PDLM__Category__c categoryForFG = new PDLM__Category__c(Name='Finished Good', PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleFG.id);
        categoriesToInsert.add(categoryForFG);
        PDLM__Category__c categoryForPart = new PDLM__Category__c(Name='Part', PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecyclePart.id);
        categoriesToInsert.add(categoryForPart);
        insert categoriesToInsert;

        //Create Change Orders
        change = new PDLM__Change__c(Name = 'ECO-000001', PDLM__Category__c = categoryForChange.Id, PDLM__Title__c='Test ECO');
        insert change;
        change2 = new PDLM__Change__c(Name = 'ECO-000002', PDLM__Category__c = categoryForChange.Id, PDLM__Title__c='Test ECO');
        insert change2;

        //Create Paretnt Item and Item Revision
        PDLM__Item__c parentItem1 = new PDLM__Item__c(Name = 'Parent Item 1', PDLM__Category__c = categoryForFG.Id);
        insert parentItem1;
        parentItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem1.Id, 
                                                    PDLM__Revision__c = '1',
                                                    PDLM__Lifecycle_Phase__c = 'Prototype',
                                                    PDLM__Related_Change__c = change.Id,
                                                    Description_Standard__c = 'Test',
                                                    Manufacturing_Plant_Extension__c = 'US45:1:01');
        revsListToInsert.add(parentItem1Rev);
        
        PDLM__Item__c parentItem2 = new PDLM__Item__c(Name = 'Parent Item 2', PDLM__Category__c = categoryForFG.Id);
        insert parentItem2;
        parentItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem2.Id, 
                                                    PDLM__Revision__c = '1',
                                                    PDLM__Lifecycle_Phase__c = 'Prototype',
                                                    PDLM__Related_Change__c = change.Id,
                                                    Description_Standard__c = 'Test',
                                                    Manufacturing_Plant_Extension__c = 'US45:1:01');
        revsListToInsert.add(parentItem2Rev);

        PDLM__Item__c childItem1 = new PDLM__Item__c(Name = 'Child Item 1', PDLM__Category__c = categoryForFG.Id);
        insert childItem1;
        childItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem1.Id, 
                                                   PDLM__Revision__c = 'A',
                                                   PDLM__Lifecycle_Phase__c = 'Production',
                                                   PDLM__Released__c = true,
                                                   Description_Standard__c = 'Test',
                                                   Extended_Site_s__c = 'US45;BE02;US87');
        revsListToInsert.add(childItem1Rev);
        childItem2 = new PDLM__Item__c(Name = 'Child Item 2', PDLM__Category__c = categoryForPart.Id);
        insert childItem2;
        childItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem2.Id, 
                                                   PDLM__Revision__c = '1',
                                                   PDLM__Lifecycle_Phase__c = 'Prototype',
                                                   Description_Standard__c = 'Test',
                                                   Extended_Site_s__c = 'US45;BE02;US87');
        revsListToInsert.add(childItem2Rev);
        childItem3 = new PDLM__Item__c(Name = 'Child Item 3', PDLM__Category__c = categoryForPart.Id);
        insert childItem3;
        childItem3Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem3.Id, 
                                                   PDLM__Revision__c = 'A',
                                                   PDLM__Lifecycle_Phase__c = 'Released',
                                                   Description_Standard__c = 'Test',
                                                   Extended_Site_s__c = 'US45;BE02;US87');
        revsListToInsert.add(childItem3Rev);
        insert revsListToInsert;

        //Add Assemblies
        List<PDLM__Assembly__c> assListToInsert = new List<PDLM__Assembly__c>();
        PDLM__Assembly__c ass1 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id,
                                                       PDLM__Item__c = childItem1.Id,
                                                       PDLM__Quantity__c = 1);
        assListToInsert.add(ass1);
        insert assListToInsert;
    }

    static PDLM__Lifecycle__c lifecycleChange;
    static PDLM__Change__c change;
    static PDLM__Change__c change2;
    static PDLM__Item_Revision__c parentItem1Rev;
    static PDLM__Item_Revision__c parentItem2Rev;
    static PDLM__Item_Revision__c childItem1Rev;
    static PDLM__Item_Revision__c childItem2Rev;
    static PDLM__Item_Revision__c childItem3Rev;
    static PDLM__Item__c childItem2;
    static PDLM__Item__c childItem3;
    static PDLM__Phase__c pendingPhaseChange;

    @isTest static void checkRequiredFields() {
        SetUpData();

        PropelPreApprovalValidation.GetRequestsfromFlow flow = new PropelPreApprovalValidation.GetRequestsfromFlow();
        flow.recordId = change.Id;
        flow.lifecycleId = lifecycleChange.Id;
        flow.phaseName = 'Pending';
        PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow});

        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains(
                                  '<caption><b>Required Fields Check - Change and Affected Items</b></caption><tr><th>Phase</th>'+
                                  '<th>Change Missing Required Fields</th><th>Affected Items Missing Required Fields</th><th>Change Additional Missing Required Fields</th></tr>'+
                                  '<tr><td>Pending</td><td>Reason for Change</td><td>N/A</td><td>No Missing Additional Required Fields for Change</td></tr>'));
        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains(
                                  '<b>Required Fields Check - Item Revisions</b></caption><tr><th>Item Revision</th><th>Missing Required Fields</th></tr>'+
                                  '<tr><td>Parent Item 1:1*</td><td>Notes, Description - Do Not Use, Detailed Description</td></tr>'+
                                  '<tr><td>Parent Item 2:1*</td><td>Notes, Description - Do Not Use, Detailed Description</td></tr></table>'));

        //Insert Affected Items
        List<PDLM__Affected_Item__c> aisToInsert = new List<PDLM__Affected_Item__c>();
        PDLM__Affected_Item__c  ai1 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = parentItem1Rev.Id);
        aisToInsert.add(ai1);
        PDLM__Affected_Item__c  ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = parentItem2Rev.Id);
        aisToInsert.add(ai2);
        insert aisToInsert;

        PropelPreApprovalValidation.GetRequestsfromFlow flow2 = new PropelPreApprovalValidation.GetRequestsfromFlow();
        flow2.recordId = change.Id;
        flow2.lifecycleId = lifecycleChange.Id;
        PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow2});
        
        System.debug('PropelPreApprovalValidation.resultForTest: ' + PropelPreApprovalValidation.resultForTest);
        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains(
                                '<caption><b>Required Fields Check - Change and Affected Items</b></caption><tr><th>Phase</th>'+
                                '<th>Change Missing Required Fields</th><th>Affected Items Missing Required Fields</th><th>Change Additional Missing Required Fields</th></tr>'+
                                '<tr><td>Pending</td><td>Reason for Change</td><td>Stock, Notes</td><td>No Missing Additional Required Fields for Change</td></tr>'));
        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains(
                                '<caption><b>Required Fields Check - Affected Items (Category-Specific)</b></caption>'+
                                '<tr><th>Item Number</th><th>Affected Items Missing Required Fields (Category-Specific)</th></tr>'+
                                '<tr><td>Parent Item 1:1*</td><td>Stock, Notes</td></tr>'+
                                '<tr><td>Parent Item 2:1*</td><td>Stock, Notes</td></tr>'));
        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains(
                                '<b>Required Fields Check - Item Revisions</b></caption><tr><th>Item Revision</th><th>Missing Required Fields</th></tr>'+
                                '<tr><td>Parent Item 1:1*</td><td>Notes, Description - Do Not Use, Detailed Description</td></tr>'+
                                '<tr><td>Parent Item 2:1*</td><td>Notes, Description - Do Not Use, Detailed Description</td></tr></table>'));

        //Set the Values on Change, Affected Items, Item Revisions
        change.Reason_for_Change__c = 'Test';
        update Change;

        List<PDLM__Item_Revision__c> revsToUpdate = new List<PDLM__Item_Revision__c>();
        parentItem1Rev.Notes__c = 'Test';
        parentItem1Rev.PDLM__Description__c = 'Test';
        parentItem1Rev.PDLM__Detailed_Description__c = 'Test';
        revsToUpdate.add(parentItem1Rev);
        parentItem2Rev.Notes__c = 'Test';
        parentItem2Rev.PDLM__Description__c = 'Test';
        parentItem2Rev.PDLM__Detailed_Description__c = 'Test';
        revsToUpdate.add(parentItem2Rev);
        update revsToUpdate;

        List<PDLM__Affected_Item__c> aisToUpdate = new List<PDLM__Affected_Item__c>();
        ai1.Stock__c = 'N/A';
        ai1.PDLM__Notes__c = 'N/A';
        aisToUpdate.add(ai1);
        ai2.Stock__c = 'N/A';
        ai2.PDLM__Notes__c = 'N/A';
        aisToUpdate.add(ai2);
        update aisToUpdate;

        PropelPreApprovalValidation.GetRequestsfromFlow flow3 = new PropelPreApprovalValidation.GetRequestsfromFlow();
        flow3.recordId = change.Id;
        flow3.lifecycleId = lifecycleChange.Id;
        PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow3});

        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains(
                                '<caption><b>Required Fields Check - Change and Affected Items</b></caption><tr><th>Phase</th>'+
                                '<th>Change Missing Required Fields</th><th>Affected Items Missing Required Fields</th><th>Change Additional Missing Required Fields</th></tr>'+
                                '<tr><td>Pending</td><td>No Missing Required Fields for Change</td><td>No Missing Required Fields for Affected Items</td><td>No Missing Additional Required Fields for Change</td></tr>'));
        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains('<br><b>No Missing Required Fields for Affected Item (Category-Specific)</b><br>'));
        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains('<br><b>No Missing Required Fields for Item Revisions</b><br>'));
    }

    // @isTest static void checkInactiveApprovers() {
    //     SetUpData();

    //     User activeUser = [SELECT Id FROM User WHERE IsActive = true limit 1];
    //     User inactiveUser = [SELECT Id FROM User WHERE IsActive = false limit 1];

    //     //Move the change to an approval phase
    //     PDLM__Change_Phase__c plmReviewPhase = [SELECT Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'PLM Review' LIMIT 1];
    //     plmReviewPhase.PDLM__Approver_1__c = activeUser.Id;
    //     update plmReviewPhase;

    //     change.Reason_for_Change__c = 'Test';
    //     change.PDLM__Status_lk__c = plmReviewPhase.Id;
    //     update change;

    //     //Reassign Approvers
    //     Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    //     req1.setComments('Submitting request for approval.');
    //     req1.setObjectId(plmReviewPhase.Id);
    //     Approval.ProcessResult result = Approval.process(req1);

    //     PropelPreApprovalValidation.GetRequestsfromFlow flow = new PropelPreApprovalValidation.GetRequestsfromFlow();
    //     flow.recordId = change.Id;
    //     flow.lifecycleId = lifecycleChange.Id;
    //     PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow});

    //     System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains('All Approvers are Active.'));

    //     ProcessInstanceWorkItem pi = [SELECT Id, ActorId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :plmReviewPhase.Id LIMIT 1];
    //     pi.ActorId = inactiveUser.Id;
    //     update pi;     

    //     PropelPreApprovalValidation.GetRequestsfromFlow flow2 = new PropelPreApprovalValidation.GetRequestsfromFlow();
    //     flow2.recordId = change2.Id;
    //     flow2.lifecycleId = lifecycleChange.Id;
    //     PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow2});

    //     System.assertEquals(false, PropelPreApprovalValidation.resultForTest.contains('All Approvers are Active.'));
    // }

    @isTest static void checkUnreleasedChildren() {
        SetUpData();

        PropelPreApprovalValidation.GetRequestsfromFlow flow = new PropelPreApprovalValidation.GetRequestsfromFlow();
        flow.recordId = change.Id;
        flow.lifecycleId = lifecycleChange.Id;
        PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow});

        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains('No Unreleased Children Found.'));

        //Released Child Item 1 Revision
        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem2Rev.Id, PDLM__Item__c = childItem2.Id,PDLM__Quantity__c = 1);
        insert ass;

        PropelPreApprovalValidation.GetRequestsfromFlow flow2 = new PropelPreApprovalValidation.GetRequestsfromFlow();
        flow2.recordId = change.Id;
        flow2.lifecycleId = lifecycleChange.Id;
        PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow2});

        System.assertEquals(false, PropelPreApprovalValidation.resultForTest.contains('No Unreleased Children Found.'));
    }

    @isTest static void checkInvalidChildPhases() {
        SetUpData();

        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem2Rev.Id, PDLM__Item__c = childItem2.Id,PDLM__Quantity__c = 1);
        insert ass;
        
        PropelPreApprovalValidation.GetRequestsfromFlow flow = new PropelPreApprovalValidation.GetRequestsfromFlow();
        flow.recordId = change.Id;
        flow.lifecycleId = lifecycleChange.Id;
        PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow});

        System.assertEquals(false, PropelPreApprovalValidation.resultForTest.contains('No Disallowed Child Phases Found.'));
    }

    @isTest static void checkNoInvalidChildPhases() {
        SetUpData();

        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem2Rev.Id, PDLM__Item__c = childItem3.Id,PDLM__Quantity__c = 1);
        insert ass;
        
        PropelPreApprovalValidation.GetRequestsfromFlow flow = new PropelPreApprovalValidation.GetRequestsfromFlow();
        flow.recordId = change.Id;
        flow.lifecycleId = lifecycleChange.Id;
        PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow});

        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains('No Disallowed Child Phases Found.'));
    }

    @isTest static void checkRequiredFieldsWithAddlChangeFields() {
        SetUpData();

        change.PDLM__Title__c = '';
        update change;

        pendingPhaseChange.PDLM__Required__c = 'Title__c, Reason_for_Change__c';
        pendingPhaseChange.Run_Audits_Additional_Required_Fields__c = 'Description_5000__c, PDLM__Approved_Date__c';
        update pendingPhaseChange;

        PropelPreApprovalValidation.GetRequestsfromFlow flow = new PropelPreApprovalValidation.GetRequestsfromFlow();
        flow.recordId = change.Id;
        flow.lifecycleId = lifecycleChange.Id;
        flow.phaseName = 'Pending';
        PropelPreApprovalValidation.PropelPreApprovalValidation(new List<PropelPreApprovalValidation.GetRequestsfromFlow> {flow});

        System.assertEquals(true, PropelPreApprovalValidation.resultForTest.contains(
                                  '<caption><b>Required Fields Check - Change and Affected Items</b></caption><tr><th>Phase</th>'+
                                  '<th>Change Missing Required Fields</th><th>Affected Items Missing Required Fields</th><th>Change Additional Missing Required Fields</th></tr>'+
                                  '<tr><td>Pending</td><td>Title, Reason for Change</td><td>N/A</td><td>Description, Approved Date</td></tr>'));
    }
}
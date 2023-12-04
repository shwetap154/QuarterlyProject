@isTest
public with sharing class PropelEmailWithFieldsValidationTest { 
    public static testmethod void PropelEmailWithFieldsValidationTest() {
        User changeAnalyst = [SELECT Id, Name FROM User WHERE Propel_Change_Analyst__c = true and IsActive = true limit 1];
        List<Id> userIds = new List<Id>();

        //Create Item
        PDLM__Lifecycle__c lifecycleItem = new PDLM__Lifecycle__c(name='Parts', PDLM__primary_key__c = 'Parts');
        insert lifecycleItem;

        PDLM__Phase__c firstPhase = new PDLM__Phase__c(Name='First Phase', PDLM__order__c = 1, PDLM__Default_No_Change_Control__c = true, 
        PDLM__lifecycle__c = lifecycleItem.id, PDLM__Next_Phases__c = '["Discontinue Production","Pre-Production", "Production"]');
        insert firstPhase;

        PDLM__Phase__c secondPhase = new PDLM__Phase__c(Name='Discontinue Production', PDLM__order__c = 2, PDLM__Default_No_Change_Control__c = true, 
        PDLM__lifecycle__c = lifecycleItem.id, PDLM__Next_Phases__c = '["Pre-Production", "Production"]');
        insert secondPhase;

        PDLM__Autonumber__c autonumberPart = new PDLM__Autonumber__c(name='Part', PDLM__prefix__c = 'PN-', 
        PDLM__Length__c = 3, PDLM__Next_Number__c = 1);
        insert autonumberPart;

        PDLM__Category__c partCategory = new PDLM__Category__c(name='Part', PDLM__autonumber__c = autonumberPart.id, 
        PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        insert partCategory;

        PDLM__Item__c Item = new PDLM__Item__c(PDLM__Category__c = partCategory.id);
        insert Item;

        PDLM__Item_Revision__c ItemRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = Item.id, PDLM__Revision__c = 'A', Description_Standard__c = 'Test');
        insert ItemRev;

        //Create Change Order
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='ECO', PDLM__primary_key__c = 'ECO');
        insert lifecycle;

        PDLM__Phase__c assessmentPhase = new PDLM__Phase__c(Name='Assessment', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, 
                                                         PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        insert assessmentPhase;

        PDLM__Phase__c QaPhase = new PDLM__Phase__c(Name='Quality Assessment', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, 
                                                     PDLM__lifecycle__c = lifecycle.id);
        insert QaPhase;

        PDLM__Phase__c approvedPhase = new PDLM__Phase__c(Name='Approved', PDLM__order__c = 3, 
                                                         PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        insert approvedPhase;

        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(name='Autonumber for ECR-QMS', PDLM__prefix__c = 'ECO-', 
        PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        insert autonumberChange;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(name='ECR-QMS', PDLM__autonumber__c = autonumberChange.id, 
        PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        insert categoryForChange;

        PDLM__Change__c change = new PDLM__Change__c(PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test ECO', 
        PDLM__primary_Key__c = 'ECO1', Change_Analyst__c = changeAnalyst.Id);
        insert change;

        userIds.add(change.Change_Analyst__c);
        userIds.add(change.OwnerId);

        //Move the change to an approval phase
        PDLM__Change_Phase__c QaPhaseRecord = [SELECT Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.id and Name = 'Quality Assessment' LIMIT 1];

        //Add Affected Items
        PDLM__Affected_Item__c ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = itemRev.Id);
        insert ai;

        change.PDLM__Status_lk__c = QaPhaseRecord.Id;
        change.Cost_Center_s__c = '<<< Not Applicable >>>';
        update change;

        //Invoke the method
        PropelEmailWithFieldsValidation.GetRequestsfromPB notificationGroup = new PropelEmailWithFieldsValidation.GetRequestsfromPB();
        notificationGroup.changeId = change.Id;
        notificationGroup.changeFields = 'VMRD_Project_s__c;Pre_ECO_Part_Number_s__c;Recommended_Action__c';
        notificationGroup.aiFields = 'Scrap_Cost__c;Rework_Cost__c';
        notificationGroup.userIds = userIds;
        PropelEmailWithFieldsValidation.PropelEmailWithFieldsValidation(new List<PropelEmailWithFieldsValidation.GetRequestsfromPB> {notificationGroup});

        //Did I send that email?
        System.assert(PropelEmailWithFieldsValidation.num_of_emails_sent >= 1, 'Expected at least 1');   


    }
}
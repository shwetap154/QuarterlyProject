/**
* File Name     :  FlexibleGroupItemTriggerHandler
* @description  :  Handler class for the Flexible Group Item Trigger
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/19/2019		Cesar Sandrigo @ ATG     Created the Class.
*/
@istest
public class FlexibleGroupItemTriggerHandlerTest {
    
    @testSetup
	public static void setup() { 

		// Create materials
		insert new List<SAP_Material__c> {
		    CPQ_TestDataFactory.createSAPMaterial('PC', '000000000011111111', 'NORM', 'ZFER', '015000715177010', false),
		    CPQ_TestDataFactory.createSAPMaterial('SU', '000000000022222222', 'DIEN', 'DIEN', '015000715184050', false)
        };

        // Create flexible groups
        insert new List<Flexible_Group__c> {
            CPQ_TestDataFactory.createFlexibleGroup('00001234', 'ZFLX', false),
		    CPQ_TestDataFactory.createFlexibleGroup('00009999', 'ZFLX', false)
        };
    }

    @istest
    public static void handleBeforeInsert() {

        Test.startTest();

        insert new List<Flexible_Group_Item__c> {
            // Flexible Group: 00001234
            CPQ_TestDataFactory.createFlexibleGroupItem('00001234', '000001', '000000000011111111', false),
            CPQ_TestDataFactory.createFlexibleGroupItem('00001234', '000002', '000000000022222222', false),

            // Flexible Group: 00009999
            CPQ_TestDataFactory.createFlexibleGroupItem('00009999', '000003', '000000000011111111', false),
            CPQ_TestDataFactory.createFlexibleGroupItem('00009999', '000004', '000000000022222222', false),

            // Non-existent Flexible Group, Existing Material
            CPQ_TestDataFactory.createFlexibleGroupItem('55555555', '000005', '000000000011111111', false),

            // Existent Flexible Group, Non-existent Material
            CPQ_TestDataFactory.createFlexibleGroupItem('00001234', '000006', '000000000055555555', false),

            // Non-existent Flexible Group and Material
            CPQ_TestDataFactory.createFlexibleGroupItem('55555555', '000007', '000000000055555555', false)
        };

        Test.stopTest();

        List<Flexible_Group_Item__c> flexibleGroupItems = [SELECT Id, External_ID__c, Flexible_Group__c,
                                                                Flexible_Group_Number__c, SAP_Material__c, SAP_Material_Number__c,
                                                                Unit_of_Measure__c, Valid_From_Date__c, Valid_To_Date__c,
                                                                Flexible_Group__r.Flexible_Group_Number__c, SAP_Material__r.SAP_Product_Number__c
                                                            FROM Flexible_Group_Item__c];

        // Check the number of FG Items inserted
        System.assertEquals(7, flexibleGroupItems.size());

        for (Flexible_Group_Item__c flexGroupItem : flexibleGroupItems) {
            
            // If the material number is valid, check there is a Material associated to the FG Item
            if (flexGroupItem.SAP_Material_Number__c == '000000000011111111' || flexGroupItem.SAP_Material_Number__c == '000000000022222222') {
                System.assert(flexGroupItem.SAP_Material__c != null);
                System.assertEquals(flexGroupItem.SAP_Material_Number__c, flexGroupItem.SAP_Material__r.SAP_Product_Number__c);
            }
            else {
                System.assert(flexGroupItem.SAP_Material__c == null);
            }

            // If the FG number is valid, check there is a FG record associated to the FG Item
            if (flexGroupItem.Flexible_Group_Number__c == '00001234' || flexGroupItem.Flexible_Group_Number__c == '00009999') {
                System.assert(flexGroupItem.Flexible_Group__c != null);
                System.assertEquals(flexGroupItem.Flexible_Group_Number__c, flexGroupItem.Flexible_Group__r.Flexible_Group_Number__c);
            }
            else {
                System.assert(flexGroupItem.Flexible_Group__c == null);
            }
        }
    }
}
/******************************************************************************************************************************************
 * Class Name   : FieldSetRecordFormControllerTest
 * Description  : Test for FieldSetRecordFormController
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 28 February 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     02/28/2020          Created.
 *****************************************************************************************************************************************/

@isTest
public with sharing class FieldSetRecordFormControllerTest {

    static final STRING ACC = 'Account';
    static final STRING FS_NAME_POS = 'LE_Contract';
    static final STRING FS_NAME_NEG = 'LE_Negative';

    static void setupData() {

    }

    @isTest static void getFieldsByFieldSetName_Positive() {

        Test.startTest();
            List<FieldSetWrapperLWC> actualFieldSetList = FieldSetRecordFormController.getFieldsByFieldSetName(ACC, FS_NAME_POS);
        Test.stopTest();

        System.assert(actualFieldSetList.size() > 0, 'Field set should not be empty');
    }

    @isTest static void getFieldsByFieldSetName_Negative() {

        try {
            Test.startTest();
            List<FieldSetWrapperLWC> actualFieldSetList = FieldSetRecordFormController.getFieldsByFieldSetName(ACC, FS_NAME_NEG);
            Test.stopTest();
        }
        catch(Exception ex) {
            System.assert(ex instanceof AuraHandledException, 'Aura handled exception was thrown');
        }


    }
}
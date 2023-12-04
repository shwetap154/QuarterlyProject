/******************************************************************************************************************************************
 * Class Name   : FieldSetRecordFormController
 * Description  : Apex controller for fieldSetRecordForm lightning web component
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 28 February 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     02/28/2020          Created.
 *****************************************************************************************************************************************/

public with sharing class FieldSetRecordFormController {

    @AuraEnabled(cacheable = true)
    public static List<FieldSetWrapperLWC> getFieldsByFieldSetName(String objectApiName, String fieldSetName) {
        try {
            List<Schema.FieldSetMember> fieldSetMembers = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
            List<FieldSetWrapperLWC> fields = new List<FieldSetWrapperLWC>();
            for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
                FieldSetWrapperLWC fieldSetField = new FieldSetWrapperLWC(fieldSetMember, objectApiName);
                fields.add(fieldSetField);
            }
            return fields;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

}
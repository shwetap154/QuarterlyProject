/******************************************************************************************************************************************
 * Class Name   : FieldSetWrapperLWC
 * Description  : Wrapper to pass fields from field set to lightning web component lightning-record-form
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 28 February 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     02/28/2020          Created.
 *****************************************************************************************************************************************/

public with sharing class FieldSetWrapperLWC {

    @AuraEnabled
    public String objectApiName {get;set;}

    @AuraEnabled
    public String fieldApiName {get;set;}

    public FieldSetWrapperLWC(Schema.FieldSetMember objectField, String objectApiName) {
        this.objectApiName = objectApiName;
        this.fieldApiName = objectField.getFieldPath();
    }
}
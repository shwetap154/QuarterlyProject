/******************************************************************************************************************************************
 * Class Name   : DatatableWrapperLWC
 * Description  : Wrapper to pass fields from field set to lightning web component datatable
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 22 April 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     04/22/2020          Created.
 *****************************************************************************************************************************************/
public with sharing class DatatableWrapperLWC {

    @AuraEnabled
    public String label {get;set;}

    @AuraEnabled
    public String fieldName {get;set;}
    
    @AuraEnabled
    public String type {get;set;}

    public DatatableWrapperLWC(Schema.FieldSetMember objectField) {
        this.label = objectField.getLabel();
        this.fieldName = objectField.getFieldPath();
        this.type = String.valueOf(objectField.getType()).toLowerCase();
    }
}
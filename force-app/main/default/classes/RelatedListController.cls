/******************************************************************************************************************************************
 * Class Name   : RelatedListController
 * Description  : Controller for related list lightning web component
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 22 April 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     04/22/2020          Created.
 *****************************************************************************************************************************************/
public with sharing class RelatedListController {

    @AuraEnabled(cacheable = true)
    public static List<DatatableWrapperLWC> getColumns(String objectApiName, String fieldSetName) {
        try {
            List<Schema.FieldSetMember> fieldSetMembers = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
            List<DatatableWrapperLWC> columns = new List<DatatableWrapperLWC>();
            for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
                DatatableWrapperLWC fieldSetField = new DatatableWrapperLWC(fieldSetMember);
                columns.add(fieldSetField);
            }
            return columns;
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static String getData(String objectApiName, String fieldSetName, String filterId, String filterField){
        try {
            List<Schema.FieldSetMember> fieldSetMembers = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
            String listQuery = '';
            listQuery += 'SELECT ';
            for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
                listQuery += fieldSetMember.getFieldPath() + ', ';
            }
            listQuery += 'Id ';
            listQuery += 'FROM ' + objectApiName + ' ';
            listQuery += 'WHERE ' + filterField + '=:filterId';
            return JSON.serialize(Database.query(listQuery));
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

}
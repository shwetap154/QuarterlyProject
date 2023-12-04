/**
 * @description       : Selector class for Merge_Related_Record_Lookup__mdt. 
 *                      Due to bugs with Entity Definitions in Custom Metadata in fflib, fflib is not used
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-11-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-25-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectChildObjectsByParentObjectAndMarket method
 * 1.1   07-11-2022   Ethan Hirsch @ Zoetis Inc   Return an Object from selectChildObjectsByParentObjectAndMarket 
 *                                                to consolidate Object Name and the checkbox field to set.
**/
public inherited sharing class MergeRelatedRecordLookupsSelector {
    public static Map<String, Map<String, ChildObject>> selectChildObjectsByParentObjectAndMarket(Set<String> parentObjectNames, String market) {
        Map<String, Map<String, ChildObject>> childObjectsByParentObjects = new Map<String, Map<String, ChildObject>>();
        for (Merge_Related_Record_Lookup__mdt relatedRecord : [
            SELECT Child_Object__r.QualifiedApiName, Parent_Object__r.QualifiedApiName, Boolean_Field_to_Set__c
            FROM Merge_Related_Record_Lookup__mdt
            WHERE Parent_Object__r.QualifiedApiName in: parentObjectNames
            AND (Market__c =: market OR Market__c = null)]) {

            string parentName = relatedRecord.Parent_Object__r.QualifiedApiName;
            if (!childObjectsByParentObjects.containsKey(parentName)) {
                childObjectsByParentObjects.put(parentName, new Map<String, ChildObject>());
            }

            childObjectsByParentObjects.get(parentName).put(relatedRecord.Child_Object__r.QualifiedApiName,
                new ChildObject(relatedRecord.Child_Object__r.QualifiedApiName, relatedRecord.Boolean_Field_to_Set__c));
        }

        return childObjectsByParentObjects;
    }

    public class ChildObject {
        public String ObjectName {get; private set;}
        public String CheckboxField {get; private set;}

        public ChildObject(String objectName, String checkboxField) {
            this.ObjectName = objectName;
            this.CheckboxField = checkboxField;
        }
    }
}
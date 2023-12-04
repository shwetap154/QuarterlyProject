public with sharing class PicklistsService {
  public static Set<String> getActivePicklistValues(
    String objectName,
    String fieldName
  ) {
    Set<String> picklistValueSet = new Set<String>();
    List<Schema.PicklistEntry> entries = getPicklist(objectName, fieldName);
    for (Schema.PicklistEntry entry : entrieS) {
      if (entry.isActive()) {
        picklistValueSet.add(entry.getValue());
      }
    }
    return picklistValueSet;
  }

  public static Set<String> getAllPicklistValues(
    String objectName,
    String fieldName
  ) {
    Set<String> picklistValueSet = new Set<String>();
    List<Schema.PicklistEntry> entries = getPicklist(objectName, fieldName);
    for (Schema.PicklistEntry entry : entries) {
      picklistValueSet.add(entry.getValue());
    }
    return picklistValueSet;
  }

  private static List<Schema.PicklistEntry> getPicklist(
    String objectName,
    String fieldName
  ) {
    SObjectType objectType = ((SObject) Type.forName(objectName).newInstance())
      .getSObjectType();

    // Describe the SObject using its object type.
    Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
    // Get a map of fields for the SObject
    map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    // Get the list of picklist values for this field.
    List<Schema.PicklistEntry> values = fieldMap.get(fieldName)
      .getDescribe()
      .getPickListValues();
    return values;
  }
}
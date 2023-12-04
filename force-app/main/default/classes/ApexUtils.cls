/**
* File Name     :  ApexUtils
* @description  :  Utility class for common operations.
* @author       :  ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/24         Cesar Sandrigo @ ATG     Created the Class.
*
*/
public class ApexUtils {

    public class NoParentRecordIncludedException extends Exception {}
    
    private static final String ID_STR = 'Id'; 
    private static Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
    
    @TestVisible
    private static String subDomainWithProtocol = (System.URL.getSalesforceBaseURL().toExternalForm()).split('\\.')[0];

    public static RecordType getRecordTypeByDeveloperName(String developerName) {
        if(recordTypeMap.isEmpty()) {
            List<RecordType> recordTypes = [SELECT Id , DeveloperName FROM RecordType];
            for(RecordType recordType : recordTypes) {
                recordTypeMap.put(recordType.DeveloperName, recordType);
            }
        }
        return recordTypeMap.get(developerName);
    }

    /**
     * Given a list and a string property (of an ID field), return a set of the extracted ids
     * (Example: Given a list of contacts where prop='AccountId', return a set of the account Id's)
     * @param  items [description]
     * @param  prop  [description]
     * @return       [description]
     */
    public static Set<Id> pluckIdSet(List<SObject> items, Schema.SObjectField prop) {
        Set<Id> ids = new Set<Id>();
        for(SObject obj : items) {
            try {
                if(obj.get(prop) != null) {
                    ids.add((Id)obj.get(prop));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return ids;
    }

    /**
     * Given a list and a string property (of an ID field), return a set of the extracted ids
     * (Example: Given a list of contacts where prop='AccountId', return a set of the account Id's)
     * This method allows relationships - Ex. 'Account.CreatedBy.Id'
     * @param  items [description]
     * @param  prop  [description]
     * @return       [description]
     */
    public static Set<Id> pluckIdSet(List<SObject> items, String prop) {
        Set<Id> ids = new Set<Id>();
        for(SObject obj : items) {
            try {
                if(prop.contains('.')) {
                    SObject currObj = obj;
                    List<String> fields = prop.split('\\.');
                    for(String field : fields) {
                        try {
                            currObj = (SObject)currObj.getSobject(field);
                        } catch (Exception ex) {
                            ids.add((Id)currObj.get(field));
                        }
                    }
                } else if (obj.get(prop) != null) {
                    ids.add((Id)obj.get(prop));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return ids;
    }

    /**
     * Given a list and a string property (of a String field), return a set of the extracted values
     * (Example: Given a list of contacts where prop='FirstName', return a set of the contacts first name)
     * @param  items [description]
     * @param  prop  [description]
     * @return       [description]
     */
    public static Set<String> pluckStringSet(List<SObject> items, Schema.SObjectField prop) {
        Set<String> strings = new Set<String>();
        for(SObject obj : items) {
            try {
                if(obj.get(prop) != null) {
                    strings.add((String)obj.get(prop));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return strings;
    }

    /**
     * Given a list and a string property (of a String field), return a set of the extracted values
     * The string version provides the ability to get relationship fields - e.x. 'Account.CreatedBy.Name'
     * @param  items [description]
     * @param  prop  [description]
     * @return       [description]
     */
    public static Set<String> pluckStringSet(List<SObject> items, String prop) {
        Set<String> strings = new Set<String>();
        for(SObject obj : items) {
            try {
                if(prop.contains('.')) {
                    SObject currObj = obj;
                    List<String> fields = prop.split('\\.');
                    for(String field : fields) {
                        try {
                            currObj = (SObject)currObj.getSobject(field);
                        } catch (Exception ex) {
                            strings.add((String)currObj.get(field));
                        }
                    }
                } else if (obj.get(prop) != null) {
                    strings.add((String)obj.get(prop));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return strings;
    }

    /**
     * Build a map from two proprties on a list of objects
     * Example: Given a list of Opportunites, passing in prop1='Id', prop2='AccountId', get a map back with the opp id to the account id
     * If two records have the same value for key, then record later in the list will overwrite prior value
     * @param  items list of SObject
     * @param  key Property to get a map by
     * @param  value [description]
     * @return       [description]
     */
    public static Map<String, String> pluckMap(List<SObject> items, Schema.SObjectField key, Schema.SObjectField value) {
        Map<String, String> outputMap = new Map<String, String>();
        for(SObject obj : items) {
            try {
                if(obj.get(key) != null && obj.get(value) != null) {
                    outputMap.put((String)obj.get(key), (String)obj.get(value));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return outputMap;
    }

    /**
     * Same logic as pluckMap, but value is of type Object and will need to be casted to proper type
     * @param  items list of SObject
     * @param  key Property to get a map by
     * @param  value [description]
     * @return       [description]
     */
    public static Map<String, Object> pluckMapAny(List<SObject> items, Schema.SObjectField key, Schema.SObjectField value) {
        Map<String, Object> propToPropMap = new Map<String, Object>();
        for(SObject obj : items) {
            try {
                if(obj.get(key) != null && obj.get(value) != null) {
                    propToPropMap.put((String)obj.get(key), obj.get(value));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
            }
        }
        return propToPropMap;
    }

    /**
     * Group a list of SObjects by any field on the SObject.
     * @param  items list of SObject
     * @param  field Property to get a map by
     * @return       [description]
     */
    public static Map<String, List<SObject>> groupBy(List<SObject> items, Schema.SObjectField field) {
        Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
        for(SObject obj : items) {
            try {
                if(obj.get(field) != null) {
                    if(!propToPropMap.containsKey((String)obj.get(field))) {
                        propToPropMap.put((String)obj.get(field), new List<SObject>());
                    }
                    propToPropMap.get((String)obj.get(field)).add(obj);

                } else {
                    System.debug(field + ' is null, ignoring record: ' + obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
            }
        }
        return propToPropMap;
    }

    /**
     * Group a list of SObjects by any field on the SObject.
     * This version of the method supports passing in a string key with relationship fields
     * For example, if you want to group Contacts by Contact.Account.Name
     * @param  items list of SObject
     * @param  field Property to get a map by
     * @return       [description]
     */
    public static Map<String, List<SObject>> groupBy(List<SObject> items, String field) {
      Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
      for(SObject obj : items) {
          try {
              SObject baseObj = obj;
              SObject tempObj = obj; // if field has a "." this holds the nested objects until fields is reached
              String currField = field;
              // If provided field is using dot notation, get nested object and field
              if(field.contains('.')) {
                  List<String> fields = field.split('\\.');
                  for(String splitField : fields) {
                      try {
                          tempObj = (SObject)tempObj.getSobject(splitField);
                      } catch (Exception ex) {
                          currField = splitField;
                      }
                  }
              }

              if(tempObj.get(currField) != null) {
                  if(!propToPropMap.containsKey((String)tempObj.get(currField))) {
                      propToPropMap.put((String)tempObj.get(currField), new List<SObject>());
                  }
                  propToPropMap.get((String)tempObj.get(currField)).add(baseObj);

              } else {
                  System.debug(currField + ' is null, ignoring record: ' + baseObj);
              }
          } catch (Exception ex) {
              System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
          }
      }
      return propToPropMap;
    }

    /**
     * Sames as groupBy, but only returns one record per key
     * if two records have the same key, the record later in the list will overwrite the previous record
     * @param  items list of records
     * @param  key  field key
     * @return       [description]
     */
    public static Map<String, SObject> groupByFlat(List<SObject> items, Schema.SObjectField key) {
        Map<String, SObject> propToSObjMap = new Map<String, SObject>();
        for(SObject obj : items) {
            try {
                if(obj.get(key) != null) {
                    propToSObjMap.put((String)obj.get(key), obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
            }
        }
        return propToSObjMap;
    }

    /**
     * Get a list of records where the specified value changed
     * @param  items       trigger.new
     * @param  oldItemsMap trigger.oldMap
     * @param  fields      string | string[], name(s) of property to check
     * @return             
     */
    public static List<SObject> findChangedRecs(List<SObject> items, Map<Id, SObject> oldItemsMap, Schema.SObjectField field) {
        return findChangedRecs(items, oldItemsMap, new List<Schema.SObjectField>{field});
    }
    public static List<SObject> findChangedRecs(List<SObject> items, Map<Id, SObject> oldItemsMap, List<Schema.SObjectField> fields) {
        List<SObject> changedObjects = new List<SObject>();
        for(SObject obj : items) {
            for(Schema.SObjectField field : fields) {
                try {
                    Object newObjValue = obj.get(field);
                    Object oldObjValue = oldItemsMap.get((Id)obj.get(ID_STR)).get(field);
                    if(newObjValue != oldObjValue) {
                        changedObjects.add(obj);
                        break; // do not need to continue checking for this record
                    }
                } catch (Exception ex) {
                    System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
                }
            }

        }
        return changedObjects;
    }

    /**
     * Same as findChangedRecs, but check if changed values meet a specific new value
     * @param  items            List of new records
     * @param  oldItemsMap      Map of old records
     * @param  field            The field on the SObject to check
     * @param  expectedNewValue The value that is desired on the new records. IF the value on the new record equals this value, then the old record is checked
     *                          to see if the value is set differently
     * @return                  List of eligible objects, or an empy list
     */
    public static List<SObject> findChangedRecsWithMatchingVal(List<SObject> items, Map<Id, SObject> oldItemsMap, Schema.SObjectField field, Object expectedNewValue) {
        List<SObject> changedObjects = new List<SObject>();
        for(SObject obj : items) {
            try {
                Object newObjValue = obj.get(field);
                if(newObjValue == expectedNewValue) {
                    Object oldObjValue = oldItemsMap.get((Id)obj.get(ID_STR)).get(field);
                    if(newObjValue != oldObjValue) {
                        changedObjects.add(obj);
                    }
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return changedObjects;
    }

    /**
     * Given a newList and oldMap, return the records that have a matching old value and new value.
     * This use-case is used when we only want to match records that had a specific value to begin with where the field was changed to another specified value
     * Example: Status changed from "Draft" to "Cancelled"
     * @param  items            List of new records
     * @param  oldItemsMap      Map of old records
     * @param  field            The field on the SObject to check
     * @param  oldValue         Old value of the record that the value should had to be considered to be returned
     * @param  expectedNewValue Value that the record should have to be returned
     * @return                  List of eligible objects, or an empy list
     */
    public static List<SObject> findChangedRecsWithMatchingVal(List<SObject> items, Map<Id, SObject> oldItemsMap, Schema.SObjectField field, Object oldValue, Object expectedNewValue) {
        List<SObject> changedObjects = new List<SObject>();
        for(SObject obj : items) {
            try {
                Object newObjValue = obj.get(field);
                Object oldObjValue = oldItemsMap.get((Id)obj.get(ID_STR)).get(field);
                if(oldObjValue == oldValue && newObjValue == expectedNewValue) {
                    changedObjects.add(obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return changedObjects;
    }

    /**
     * Same as findChangedRecs, but check if changed values meet a specific new value
     * @param  items            List of new records
     * @param  field            The field to check
     * @param  expectedValue    Return the record if the field's value equals this value
     * @return                  List of records where the field == expectedValue
     */
    public static List<SObject> findRecsWithMatchingValue(List<SObject> items, Schema.SObjectField field, Object expectedValue) {
        List<SObject> matchedObjects = new List<SObject>();
        for(SObject obj : items) {
            try {
                if(obj.get(field) == expectedValue) {
                    matchedObjects.add(obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return matchedObjects;
    }

    /**
     * Same as findChangedRecs, but check if changed values meet a specific new value
     * @param  items            List of new records
     * @param  field            The field to check
     * @param  expectedValue    Return the record if the field's value does not equals this value
     * @return                  List of records where the field != expectedValue
     */
    public static List<SObject> findRecsWithNonMatchingValue(List<SObject> items, Schema.SObjectField field, Object expectedValue) {
        List<SObject> matchedObjects = new List<SObject>();
        for(SObject obj : items) {
            try {
                if(obj.get(field) != expectedValue) {
                    matchedObjects.add(obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return matchedObjects;
    }

    public static Date getEarliestDate(List<SObject> items, Schema.SObjectField field) {
        return getEarliestDate(items, field, Date.today());
    }
    public static Date getEarliestDate(List<SObject> items, Schema.SObjectField field, Date defaultIfNull) {
        Date outputDate;
        for(SObject obj : items) {
            try {
                if(outputDate == null || outputDate > (Date) obj.get(field)) {
                    outputDate = (Date)obj.get(field);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        outputDate = outputDate != null ? outputDate : defaultIfNull;
        return outputDate;
    }

    public static Date getLatestDate(List<SObject> items, Schema.SObjectField field) {
        return getLatestDate(items, field, Date.today());
    }
    public static Date getLatestDate(List<SObject> items, Schema.SObjectField field, Date defaultIfNull) {
        Date outputDate;
        for(SObject obj : items) {
            try {
                if(outputDate == null || outputDate < (Date) obj.get(field)) {
                    outputDate = (Date)obj.get(field);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        outputDate = outputDate != null ? outputDate : defaultIfNull;
        return outputDate;
    }

    /**
     * Find a record where a date is between a start/end date on a given record
     * This method is useful to find a record that exists within some defined range of another set of records
     *
     * @param items
     * @param valueToCompare Date to compare against, usually obtained from a record
     * @param startDateField Field containing a start date
     * @param endDateField field containing an end date
     * @param isInclusive [*optional] Defaults = true. IF true, this uses <= and >= instead of < and >
     *
     * @return
     */
    public static SObject findRecWithDateBetween(List<SObject> items, Date valueToCompare, Schema.SObjectField startDateField, Schema.SObjectField endDateField) {
        return findRecWithDateBetween(items, valueToCompare, startDateField, endDateField, true);
    }
    public static SObject findRecWithDateBetween(List<SObject> items, Date valueToCompare, Schema.SObjectField startDateField, Schema.SObjectField endDateField, Boolean isInclusive) {
        for(SObject obj : items) {
            try {
                if(isInclusive) {
                    if(valueToCompare >= (Date) obj.get(startDateField) && valueToCompare <= (Date) obj.get(endDateField)) {
                        return obj;
                    }
                } else {
                    if(valueToCompare > (Date) obj.get(startDateField) && valueToCompare < (Date) obj.get(endDateField)) {
                        return obj;
                    }
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return null;
    }

    /**
     * For a given record, compare a decimal field to see if record is between a range of two fields
     * Example: If you have an object with "Start" and "End" (as decimals), then you can pass in a number and find the record that matches that range
     * This is useful when you are working with many records, so you need to perform multiple matches, thus cannot use SOQL to target just one record  
     * 
     * This method returns the first match, and not multiple matches. Ensure that your orders are sorted appropriately.
     *
     * @param items
     * @param valueToCompare Date to compare against, usually obtained from a record
     * @param startField Field containing a start decimal
     * @param endField Field containing an end decimal
     * @param startIsInclusive [*optional] Defaults = true. If true, this uses <= and >= instead of < and >
     * @param endIsInclusive [*optional] Defaults = true. If true, this uses <= and >= instead of < and >
     * @param allowNullEnd [*optional] Defaults = false. If true, this allows end field to be null
     *
     * @return
     */
    public static SObject findRecWithDecimalBetween(List<SObject> items, Decimal valueToCompare, Schema.SObjectField startField, Schema.SObjectField endField) {
        return findRecWithDecimalBetween(items, valueToCompare, startField, endField, true, true);
    }
    public static SObject findRecWithDecimalBetween(List<SObject> items, Decimal valueToCompare, Schema.SObjectField startField, Schema.SObjectField endField, Boolean startIsInclusive, Boolean endIsInclusive) {
        return findRecWithDecimalBetween(items, valueToCompare, startField, endField, startIsInclusive, endIsInclusive, false);
    }
    public static SObject findRecWithDecimalBetween(List<SObject> items, Decimal valueToCompare, Schema.SObjectField startField, Schema.SObjectField endField, Boolean startIsInclusive, Boolean endIsInclusive, Boolean allowNullEnd) {
        for(SObject obj : items) {
            try {
                if(startIsInclusive) {
                    if(endIsInclusive) {
                        if (allowNullEnd) {
                            if(valueToCompare >= (Decimal) obj.get(startField) && (obj.get(endField) == null || valueToCompare <= (Decimal) obj.get(endField))) {
                                return obj;
                            }
                        } else {
                            if(valueToCompare >= (Decimal) obj.get(startField) && (obj.get(endField) != null && valueToCompare <= (Decimal) obj.get(endField))) {
                                return obj;
                            }
                        }
                    } else {
                        if (allowNullEnd) {
                            if(valueToCompare >= (Decimal) obj.get(startField) && (obj.get(endField) == null || valueToCompare < (Decimal) obj.get(endField))) {
                                return obj;
                            }                            
                        } else {
                            if(valueToCompare >= (Decimal) obj.get(startField) && (obj.get(endField) != null && valueToCompare < (Decimal) obj.get(endField))) {
                                return obj;
                            }
                        }
                    }
                } else {
                    if(endIsInclusive) {
                        if (allowNullEnd) {
                            if(valueToCompare > (Decimal) obj.get(startField) && (obj.get(endField) == null || valueToCompare <= (Decimal) obj.get(endField))) {
                                return obj;
                            }
                        } else {
                            if(valueToCompare > (Decimal) obj.get(startField) && (obj.get(endField) != null && valueToCompare <= (Decimal) obj.get(endField))) {
                                return obj;
                            }
                        }
                    } else {
                        if (allowNullEnd) {
                            if(valueToCompare > (Decimal) obj.get(startField) && (obj.get(endField) == null || valueToCompare < (Decimal) obj.get(endField))) {
                                return obj;
                            }

                        } else {
                            if(valueToCompare > (Decimal) obj.get(startField) && (obj.get(endField) != null && valueToCompare < (Decimal) obj.get(endField))) {
                                return obj;
                            }
                        }
                    }
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return null;
    }

    /**
     * For items that are "bundled" by a self-lookup (e.x. quote lines or order product lines), this method groups
     * the quote lines by the parent most record id. Items will appear in the list in the order they are provided
     * @param  items            List of records
     * @param  bundleField      Field that has the self-lookup
     * @return                  List of eligible objects, or an empy list
     */
    public static Map<Id, List<SObject>> groupByTopLevelBundle(List<SObject> items, Schema.SObjectField bundleField) {
        Map<Id, List<SObject>> output = new Map<Id, List<SObject>>();
        Map<Id, Id> temp = new Map<Id, Id>();

        // Get top level bundle and create map of records and their parents
        for(SObject obj : items) {
            try {
                if(obj.get(bundleField) == null) {
                    output.put((Id) obj.get(ID_STR), new List<SObject>{obj});
                } else {
                    temp.put((Id) obj.get(ID_STR), (Id) obj.get(bundleField));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }

        for(SObject obj : items) {
            // skip parent items
            if(output.containsKey((Id) obj.get(ID_STR))) {
                continue;
            }
            Boolean foundTopMostParent = false;
            Id currParent = (Id) obj.get(bundleField);

            // keep looking up through parent/grandparents until we find the topMost grandparent
            while(!foundTopMostParent) {
                if(output.containsKey(currParent)) {
                    output.get(currParent).add(obj);
                    foundTopMostParent = true;
                } else {
                    currParent = temp.get((Id) obj.get(bundleField));
                }
                if(currParent == null) {
                    throw new NoParentRecordIncludedException('Parent record not included in dataset');
                }
            }
        }

        return output;
    }

    /**
     * Format a date using the format options offered with a Datetime
     * Format options: https://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
     *
     * @param d
     * @param format
     *
     * @return
     */
    public static String formatDate(Date d, String format) {
        if(d == null) { return null; }
        return DateTime.newInstance(d, Time.newInstance(1, 0, 0, 0)).format(format);
    }



    /**
     * ********************** Query Helpers ********************
     */
    /**
     * Query records with a string SObject name
     * @params objectName
     * @params whereClause [*optional] Where clause (this must begin with "WHERE", e.x. "WHERE Type = \'Foo\'")
     *  This can be overloaded with any final part of the query (e.x. LIMIT, ORDER BY) that can be included with or without "WHERE"
     *
     */
    public static List<sObject> dynamicQuery(String objectName) {
        return dynamicQuery(objectName, 'WHERE ZTS_EU_MARKET__c != \'United States\'');
    }
    public static List<sObject> dynamicQuery(String objectName, String whereClause) {
        if (whereClause == '') whereClause = 'WHERE ZTS_EU_MARKET__c != \'United States\'';
        if (!whereClause.contains('ZTS_EU_MARKET__c != \'United States\'')) whereClause += ' AND ZTS_EU_MARKET__c != \'United States\'';
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr(objectName) + ' FROM ' + objectName + ' ' + whereClause;
        return Database.query(soql);
    }

    /**
     * Query records with a string SObject name
     * @params parentObjName
     * @params childObjName
     * @params childObjRelationshipName
     * @params whereClause [*optional] Where clause (this must begin with "WHERE", e.x. "WHERE Type = \'Foo\'")
     *  This can be overloaded with any final part of the query (e.x. LIMIT, ORDER BY) that can be included with or without "WHERE"
     *
     */
    public static List<sObject> dynamicQueryWithSubquery(String parentObjName, String childObjName, String childObjRelationshipName) {
        return dynamicQueryWithSubquery(parentObjName, childObjName, childObjRelationshipName, '', '');
    }
    public static List<sObject> dynamicQueryWithSubquery(String parentObjName, String childObjName, String childObjRelationshipName, String parentWhereClause, String childWhereClause) {
        if (parentWhereClause == '') parentWhereClause = 'WHERE ZTS_EU_MARKET__c != \'United States\'';
        if (!parentWhereClause.contains('ZTS_EU_MARKET__c != \'United States\'')) parentWhereClause += ' AND ZTS_EU_MARKET__c != \'United States\'';
        String soql = 'SELECT ' + getAllFieldsForSObjAsStr(parentObjName) + ', (SELECT ' + getAllFieldsForSObjAsStr(childObjName) + ' FROM ' + childObjRelationshipName + ' ' + childWhereClause + ') FROM ' + parentObjName + ' ' + parentWhereClause;
        return Database.query(soql);
    }

    /** Get all fields for an sobject as a list - helpful for dynamic SOQL */
    public static List<String> getAllFieldsForSobj(String sobjectName) {
        //List<String> allFields = new List<String>(Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().keySet());
        List<String> allFields = new List<String>(((SObject)Type.forName('Schema',sobjectName).newInstance()).getSObjectType().getDescribe().fields.getMap().keySet());

        
        return allFields;
    }

    /**
     * Method to return list of creatable fields for a given object.
     * @param String objectName
     * @return List of creatable fields for a given sObject.
     */
    public static List<String> getCreatableFields(String sObjectName) { // Get a map of field name and field token
       // Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMap = ((SObject)Type.forName('Schema',sObjectName).newInstance()).getSObjectType().getDescribe().fields.getMap();

        List<String> creatableFields = new List<String>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable() && !(fd.isExternalId() && fd.isAutoNumber())){ // field is creatable
                    creatableFields.add(fd.getName());
                }
            }
        }
         
        return creatableFields;         
    }

    /** Get all fields for an sobject as a list, except those in the blacklist */
    public static List<String> getAllFieldsExceptBlacklist(String sobjectName, List<String> blackList) {
        Set<string> fields = new Set<String>(getAllFieldsForSobj(sobjectName));
        for(String blackListedField : blackList) {
             if(fields.contains(blackListedField)) {
                 fields.remove(blackListedField);
             } else if(fields.contains(blackListedField.toLowerCase())) {
                 fields.remove(blackListedField.toLowerCase());
             }
         }
        return new List<String>(fields);
    }

    /** Get comma delimited string list of all sobject fields */
    public static String getAllFieldsForSObjAsStr(String sobjectName) {
       return String.join(getAllFieldsForSobj(sobjectName), ', ');
    }
    /** Get comma delimited string list of sobject fields, except those in the blacklist */
    public static String getAllFieldsExceptBlacklistAsStr(String sobjectName, List<String> blackList) {
       return String.join(getAllFieldsExceptBlacklist(sobjectName, blackList), ', ');
    }

    /** Get comma delimited string list of creatable sobject fields */
    public static String getCreatableFieldsAsStr(String sobjectName) {
        List<String> creatableFields = getCreatableFields(sobjectName);
        return String.join(creatableFields, ', ');
    }

    /*
    * randomizers
    */
    public static String randomString(Integer length){
        String key = EncodingUtil.base64encode(crypto.generateAesKey(192));
        return key.substring(0,length);
    }

    /*
     * Id validation
     */
    static public String validateId(String Idparam) {
        String id = String.escapeSingleQuotes(Idparam);
        if((Idparam InstanceOf ID) && (id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return id;
        }
        return null;
    }

    /**
     * Get environment short name from url.
     * @param none
     * @return String of the environment name
     * Example:
     *   URL structure: https://xyzcompany.my.salesforce.com
     *   This method will return 'xyzcompany'
     */
    public static String getEnvironmentName() {
        return getEnvironmentName(null);
    }
    /* Optionally pass in a string to detect in the subDomainWithProtocol name and truncate after that.
     * Example:
     *   URL structure: https://xyzcompany--dev.cs77.my.salesforce.com
     *   Passing in '--' as the parameter will cause the method to return 'dev'
     */ 
    public static String getEnvironmentName(String urlPortionToSnipAfter) {
        // subDomainWithProtocol is set at the class level to allow mocking in unit test by setting specific URL
        if(urlPortionToSnipAfter == null || !subDomainWithProtocol.contains(urlPortionToSnipAfter)) {
            urlPortionToSnipAfter = 'https://'; 
        }
        Integer intIndex = subDomainWithProtocol.indexOf(urlPortionToSnipAfter) + urlPortionToSnipAfter.length();
        String envName = subDomainWithProtocol.substring(intIndex, subDomainWithProtocol.length());
      
        return envName;
    }

    /**
     * Method to make it easier to build a 'string to list of sObjects' map within a loop.
     * 
     * @param Map<String, List<sObject>> mapParam -> the map to build/add to
     * @param String mapKey -> the map key (you will probably have multiple map keys in which to store the values at)
     * @param sObject objToPutAtKey -> the obj to accrue at the mapKey
     */
    public static Map<String, List<sObject>> stringToObjListMapBuilder(Map<String, List<sObject>> mapParam, String mapKey, sObject objToPutAtKey) {
        List<sObject> objList = mapParam.get(mapKey) == null ? new List<sObject>() : mapParam.get(mapKey);
        objList.add(objToPutAtKey);
        mapParam.put(mapKey, objList);
        return mapParam;
    }

    /**
     * Sort an id to sObject map by the number of items in each list ascending.
     * Example param: we have a list of sObjects (assets and subs for example) where the list is chunked as follows:
     *   A, S, A, A, S, A, S, A, S, A, S, A, S, A, S, A
     *   
     *   Salesforce gives a 'Cannot have more than 10 chunks in a single operation' error if trying to peform DML on the list, if the list
     *   switches object types more than 10 times (like the above list does).
     *   
     *   This method sorts the objects by Id, so then afterwards the list is chunked as follows:
     *   A, A, A, A, A, A, A, A, A, S, S, S, S, S, S, S

     *   Thus we can perform DML on the list no problem. This method has been tested and works as expected. Your mileage may vary, but doubtful :)
     * 
     * @param  mapToSort -> Id to sObject map to sort, in order to consolidate the chunks 
     * @return sortedMap -> an Id to sObject map with consolidated chunks (1 chunk per object type)
     */ 
    public static Map<Id, sObject> mapSorter(Map<Id, sObject> mapToSort) {
        List<Id> sortedList = new List<Id>(mapToSort.keyset());
        sortedList.sort();
    
        Map<Id, sObject> sortedMap = new Map<Id, sObject>();
        for(String idKey : sortedList) {
            sortedMap.put(idKey, mapToSort.get(idKey));
        }
    
        return sortedMap;
    }

    /**
     * Method to sort an Id to sObject map by object types of the Id keys. This method could be a more reliable means of sorting as compared
     *  to the mapSorterById method, but it won't be as good on performance.
     *
     * @param  mapToSort -> Id to sObject map to sort, in order to consolidate the chunks 
     * @return sortedMap -> an Id to sObject map with consolidated chunks (1 chunk per object type)
     */
    public static Map<Id, sObject> mapSorterByObjType(Map<Id, sObject> mapToSort) {
        Map<String, List<sObject>> objTypeToObjListMap = new Map<String, List<sObject>>();
        for(sObject obj : mapToSort.values()) {
            String objType = String.valueOf(obj.getSobjectType()); // can't use groupBy since we're grouping by objType
            stringToObjListMapBuilder(objTypeToObjListMap, objType, obj);
        }

        Map<Id, sObject> sortedMap = new Map<Id, sObject>();
        // Loop through each object type:
        for(String objType : objTypeToObjListMap.keySet()) {
            // Loop through each object that has that type:
            for(sObject obj : objTypeToObjListMap.get(objType)) {
                sortedMap.put((Id)obj.get(ID_STR), obj);
            }
        }

        // Now the sortedMap will be nice and organized by obj type, as to avoid the 'over 10 chunks' apex error.
        return sortedMap;
    }

    /**
     * Sort a string to list map by the number of items in each list ascending.
     * Example param: We have a quote id to quote lines map, where each quote id is mapped to associated list of quote lines.
     *   quote id A (first quote id in the map) has 5 quote lines
     *   quote id B (second quote in id the map) has 3 quote lines
     *   quote id C (third quote id in the map) has 11 quote lines
     *   
     *   After sorting:
     *   quote id B (first quote id in the map, 3 quote lines)
     *   quote id A (second quote id in the map, 5 quote lines)
     *   quote id C (third quote id in the map, 11 quote lines)
     * 
     * @param  mapToSort -> map of: String to list of sobjects to sort. 
     * @return sortedMap -> a sorted map by the number of items in each of the key's lists ascending
     */ 
    public static Map<String, List<sObject>> mapSorterByNumOfChildren(Map<String, List<sObject>> mapToSort) {
        Map<String, List<sObject>> prepSortedMap = new Map<String, List<sObject>>();
        String placeholderDigits = '00000';
        for(String key : mapToSort.keySet()) {
            List<sObject> childObjList = mapToSort.get(key) == null ? new List<sObject>() : mapToSort.get(key);
            String numOfChildren = String.valueOf(childObjList.size());
            String keyPrefix = placeholderDigits.substring(0, placeholderDigits.length() - numOfChildren.length()) + numOfChildren;
            prepSortedMap.put(keyPrefix + '*' + key, childObjList);
        }
        
        List<String> sortedList = new List<String>(prepSortedMap.keyset());
        sortedList.sort();
    
        Map<String, List<sObject>> sortedMap = new Map<String, List<sObject>>();
        for(String idKey : sortedList) {
            Id idFromIdKey = Id.valueOf(idKey.substring(idKey.indexOf('*') + 1, idKey.length()));
            sortedMap.put(idFromIdKey, prepSortedMap.get(idKey));
        }
    
        return sortedMap;
    }

    /**
     * 
     */
    public static List<Schema.SObjectField> getSobjectFieldsByName(String sObjectName, List<String> fieldNames) {

        List<Schema.SObjectField> result = new List<Schema.SObjectField>();

        Map<String, Schema.SObjectField> sObjectFields;

        try {
           // sObjectFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
           sObjectFields = ((SObject)Type.forName('Schema',sObjectName).newInstance()).getSObjectType().getDescribe().fields.getMap();

            
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.WARN, 'ApexUtils.getSobjectFieldsFromName ERROR: ' + ex.getMessage());
            return result;
        }

        for (String fieldName : fieldNames) {
            string lowerCaseName = fieldName.toLowerCase();

            if (sObjectFields.containsKey(lowerCaseName)) {
                result.add(sObjectFields.get(lowerCaseName));
            }
        }

        return result;
    }

    /**
     * Inner class to assist in sheduling apex jobs. 
     *
     * Example usage:
     *  ScheduleBuilder sch = new ScheduleBuilder(7, 'seconds', 'Desired name of Scheduled run'); // prime the schedule
     *  Id scheduleId = System.schedule(sch.strJobName, sch.strSchedule, new RenewContractsAltSchedulableSB()); // schedule it
     * 
     * @property strJobName -> the job name of the scheduled job
     * @property strSchedule -> when the schedule is going to fire the execute method
     * 
     * Constructor flavor 1 params:
     * @param secondsToAdd -> how late in the future (in seconds) to execute the scheduled apex
     * @param strSchedule -> the desired name of the schedule
     *
     * Constructor flavor 2 params:
     * @param timeToAdd -> how late in the future (in seconds, minutes, hours, or days) to execute the scheduled apex
     * @param timeUnitOfMeasure -> the desired time unit of measure. The following are acceptable: seconds, minutes, hours, days
     * @param strSchedule -> the desired name of the schedule
     */ 
    public class ScheduleBuilder {
        public DateTime pointInFuture;
        public String strJobName;
        public String strSchedule;
        private final String SECONDS = 'seconds';
        private final String MINUTES = 'minutes';
        private final String HOURS = 'hours';
        private final String DAYS = 'days';

        // contructor flavor 1:
        public ScheduleBuilder(Integer secondsToAdd, String jobName) {
            this.pointInFuture = system.now().addSeconds(secondsToAdd);
            this.strJobName = jobName + '. Date: ' + this.pointInFuture.month() + '/' + this.pointInFuture.day() + '/' + this.pointInFuture.year() + ' ' + this.pointInFuture.hour() + ':' + this.pointInFuture.minute() + ':' + this.pointInFuture.second();
            this.strSchedule = this.pointInFuture.second() + ' ' + this.pointInFuture.minute() + ' ' + this.pointInFuture.hour() + ' ' + this.pointInFuture.day() + ' ' + this.pointInFuture.month() + ' ?' + ' ' + this.pointInFuture.year();
        }

        // contructor flavor 2:
        public ScheduleBuilder(Integer timeToAdd, String timeUnitOfMeasure, String jobName) {
            if(timeUnitOfMeasure.containsIgnoreCase(this.SECONDS)) {
                this.pointInFuture = system.now().addSeconds(timeToAdd);
            } else if(timeUnitOfMeasure.containsIgnoreCase(this.MINUTES)) {
                this.pointInFuture = system.now().addMinutes(timeToAdd);
            } else if(timeUnitOfMeasure.containsIgnoreCase(this.HOURS)) {
                this.pointInFuture = system.now().addHours(timeToAdd);
            } else if(timeUnitOfMeasure.containsIgnoreCase(this.DAYS)) {
                this.pointInFuture = system.now().addDays(timeToAdd);
            } else {
                String errorMessage = 'ApexUtils.ScheduleBuilder: could not recognize the timeUnitOfMeasure parameter. Please use \'seconds\', \'minutes\', \'hours\', or \'days\'.';
                System.debug(errorMessage);
                StringException e = new StringException();
                e.setMessage(errorMessage);
                throw e;
            }

            this.strJobName = jobName + '. Date: ' + this.pointInFuture.month() + '/' + this.pointInFuture.day() + '/' + this.pointInFuture.year() + ' ' + this.pointInFuture.hour() + ':' + this.pointInFuture.minute() + ':' + this.pointInFuture.second();
            this.strSchedule = this.pointInFuture.second() + ' ' + this.pointInFuture.minute() + ' ' + this.pointInFuture.hour() + ' ' + this.pointInFuture.day() + ' ' + this.pointInFuture.month() + ' ?' + ' ' + this.pointInFuture.year();
        }

    }

}
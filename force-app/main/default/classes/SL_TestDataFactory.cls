@isTest
public class SL_TestDataFactory {
	public static String currentTest = 'NULL';
    private static Map<Boolean, String> mapMessageByResult = new Map<Boolean, String>();
    private static Integer failures = 0;
    private static Integer passes = 0;
    
    public static void generateTestData() {
        //to be completed by developer
        
    }
    
	public static SObject createSObject(SObject sObj) {
		// Check what type of object we are creating and add any defaults that are needed.
		String objectName = String.valueOf(sObj.getSObjectType());
		// Construct the default values class. Salesforce doesn't allow '__' in class names
		// Special cases can be adjusted on a case by case basis 
		//(i.e. orgs with standard and custom objects that would result in the same objectName)
		String defaultClassName = 'SL_TestDataFactory.' + objectName.replaceAll('__(c|C)$|__', '') + 'Defaults';
		// If there is a class that exists for the default values, then use them
		if (Type.forName(defaultClassName) != null) {
			sObj = createSObject(sObj, defaultClassName);
		}
		return sObj;
	}

	public static SObject createSObject(SObject sObj, Boolean doInsert) {
		SObject retObject = createSObject(sObj);
		if (doInsert) {
			insert retObject;
		}
		return retObject;
	}

	public static SObject createSObject(SObject sObj, String defaultClassName) {
		// Create an instance of the defaults class so we can get the Map of field defaults
		Type t = Type.forName(defaultClassName);
		if (t == null) {
			Throw new TestFactoryException('Invalid defaults class.');
		}
		FieldDefaults defaults = (FieldDefaults)t.newInstance();
		addFieldDefaults(sObj, defaults.getFieldDefaults());
		return sObj;
	}

	public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
		SObject retObject = createSObject(sObj, defaultClassName);
		if (doInsert) {
			insert retObject;
		}
		return retObject;
	}

	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
		return createSObjectList(sObj, numberOfObjects, (String)null);
	}

	public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
		SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
		if (doInsert) {
			insert retList;
		}
		return retList;
	}

	public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
		SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
		if (doInsert) {
			insert retList;
		}
		return retList;
	}

	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
		SObject[] sObjs = new SObject[] {};
		SObject newObj;

		// Get one copy of the object
		if (defaultClassName == null) {
			newObj = createSObject(sObj);
		} else {
			newObj = createSObject(sObj, defaultClassName);
		}

		// Get the name field for the object
		String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
		if (nameField == null) {
			nameField = 'Name';
		}

		//Getting Field map to check if the Name is updateable...
		String type = String.valueOf(sObj.getSObjectType());
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

        Schema.SObjectType objSchema = schemaMap.get(type);
		Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();

		// Clone the object the number of times requested. Increment the name field so each record is unique
		for (Integer i = 0; i < numberOfObjects; i++) {
			SObject clonedSObj = newObj.clone(false, true);
			//Checking if the Name is Updateable.....
			//If true only then increment the value..
			if(fieldMap.get(nameField).getDescribe().isUpdateable())
				clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
			sObjs.add(clonedSObj);
		}
		return sObjs;
	}

	private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults) {
		// Loop through the map of fields and if they weren't specifically assigned, fill them.
		Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
        	for (Schema.SObjectField field : defaults.keySet()) {
			if (!populatedFields.containsKey(String.valueOf(field))) {
				sObj.put(field, defaults.get(field));
			}
		}
	}

	// When we create a list of SObjects, we need to
	private static Map<String, String> nameFieldMap = new Map<String, String> {
		'Contact' => 'LastName',
		'Case' => 'Subject'
	};

	public class TestFactoryException extends Exception {}

	// Use the FieldDefaults interface to set up values you want to default in for all objects.
	public interface FieldDefaults {
		Map<Schema.SObjectField, Object> getFieldDefaults();
	}

	// To specify defaults for objects, use the naming convention [ObjectName]Defaults.
	// For custom objects, omit the __c from the Object Name

	public class AccountDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Account.Name => 'Test Account'
			};
		}
	}

	public class ContactDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Contact.FirstName => 'First',
				Contact.LastName => 'Last'
			};
		}
	}

	public class OpportunityDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Opportunity.Name => 'Test Opportunity',
				Opportunity.StageName => 'Closed Won',
				Opportunity.CloseDate => System.today()
			};
		}
	}

	public class CaseDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Case.Subject => 'Test Case'
			};
		}
	}
    
    //used to soft assert primitive data types
	public static void softAssertEquals(Object o1, Object o2){
        String message;
        
        if(o1 == o2) {
            passes++;
            message = '\n\nSoft Assert Succeeded: [' + o1 + ' = ' + o2 + ']\n';
            system.debug(message);
            trackSoftAssertResult(true, message);
        }
        else {
            failures++;
            message = '\n\nSoft Assert Failed: [' + o1 + ' != ' + o2 + ']\n';
			system.debug(message);
			trackSoftAssertResult(false, message);
        }
	}
    //used to soft assert primitive data types
	public static void softAssertNotEquals(Object o1, Object o2){
        String message;
        
        if(o1 == o2) {
            failures++;
            message = '\n\nSoft Assert Failed: [' + o1 + ' = ' + o2 + ']\n';
            system.debug(message);
            trackSoftAssertResult(false, message);
        }
        else {
            passes++;
            message = '\n\nSoft Assert Passed: [' + o1 + ' != ' + o2 + ']\n';
			system.debug(message);
			trackSoftAssertResult(true, message);
        }
	}    
    public static void softAssert(Boolean result, String message) {
        if (result) {
            passes++;
            system.debug(message);
            trackSoftAssertResult(true, message);
        } else {
            failures++;
            system.debug(message);
            trackSoftAssertResult(false, message);
        }
    }
    
    //call after all soft asserts completed in a given method to determine
    // if any or all test passed
    // if one or more soft assert test fail, entire method will fail
    public static void hardAssertAllResults() {
        if (mapMessageByResult.containsKey(false)) {
            //fail
            String failResult = mapMessageByResult.get(false);
            String passResult = mapMessageByResult.containsKey(true) ? ' with results ' + mapMessageByResult.get(true) : '';
            mapMessageByResult.clear(); //clear results for next test
            System.assert(false, 'Fail: ' + failures + ' test(s) fail because of ' + failResult + ' '
                         + passes + ' test(s) passes' + passResult);
        } else {
            //pass
            System.assert(true);
        }
    }
    private static void trackSoftAssertResult(Boolean hasPass, String testResult) {
        if(mapMessageByResult.containsKey(hasPass)) {
            testResult = mapMessageByResult.get(hasPass) + '\n' + testResult;
        }
        mapMessageByResult.put(hasPass, testResult);
    }
}
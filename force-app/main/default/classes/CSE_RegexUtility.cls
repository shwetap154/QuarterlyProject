public class CSE_RegexUtility {
    
    //Checking Regex ASCII character
    
    public static Boolean isRegexValid(String tempFieldVal){
        Pattern regexPattern = Pattern.compile('^\\d*[a-zA-Z\\d\\. \'-]*$');
        return regexPattern.matcher(tempFieldVal).matches();
        
    }   	
    
    //get all the fields api name in Set
    public static Set<String> getFieldsApiName(String sObjTypes,String FIELD_SET_NAME){
        // lets declare our return map
        Map<String, Set<String>> sObjTypeToValidationFieldsMap = new Map<String, Set<String>>();
        // lets declare a set to store our field api names in
        Set<String> fieldSetFields = new Set<String>();
        // first lets describe the objects 
        Schema.DescribeSObjectResult[] sObjDescResults = Schema.describeSObjects( new List<String>{ sObjTypes } );
        
        // next lets get the field sets for each object
        for ( Schema.DescribeSObjectResult describeResult : sObjDescResults )
        {
            // lets get the field set map
            Map<String, Schema.FieldSet> fieldSetMap = describeResult.fieldSets.getMap();
            
            // lets stick the field set string values in the return map
            if ( fieldSetMap.containsKey( FIELD_SET_NAME ) )
            {
                // lets get the field set members and add them to our set of strings
                List<Schema.FieldSetMember> fieldSetMembers = fieldSetMap.get( FIELD_SET_NAME ).getFields();
                for ( Schema.FieldSetMember aField : fieldSetMembers )
                {
                    fieldSetFields.add( aField.getFieldPath() );
                }
                
            }
            
        }
        
        return fieldSetFields;
    }
    
}
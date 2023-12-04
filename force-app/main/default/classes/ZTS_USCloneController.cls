public class ZTS_USCloneController 
{
    @AuraEnabled
    public static String getUrl(String recordId)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String objectAPIName = 'ZTS_Events__c';
        List<String> selectFields = new List<String>();
        
        Set <String> fieldMap = schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet();
        String soqlQuery = 'SELECT ';
        for (String s :fieldMap )
        {
            if(schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(s).getDescribe().isAccessible())
            {
               selectFields.add(s);
            }
        }
        soqlQuery =  soqlQuery + String.join(selectFields, ',');
        soqlQuery += ' FROM ' + objectAPIName + ' WHERE Id = \'' + recordId +'\'' ;
        
        ZTS_Events__c record = (ZTS_Events__c)Database.query(soqlQuery);
        Map<String, Object> fieldsToValue = record.getPopulatedFieldsAsMap().clone();
        
        String url = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/ZTS_Events__c/new?nooverride=1&defaultFieldValues=RecordType=' + record.RecordTypeId + ',';
		List<String> urlParams = new List<String>();
        Map<String, Object> defaultValues = new Map<String, Object>();
        defaultValues.put('RecordType', record.RecordTypeId);
        for (String fieldName : fieldsToValue.keySet())
        {
			if(fieldsToValue.get(fieldName) instanceof String && ((String)fieldsToValue.get(fieldName)).contains(','))
            {
               fieldsToValue.put(fieldName, (Object)(((String)fieldsToValue.get(fieldName)).replace(',', '+')));                
            }
            
            if( fieldName == 'ZTS_US_Status__c' )
            {
                urlParams.add('ZTS_US_Status__c=New');
            }
            else if( fieldName == 'ZTS_US_Approved_Date__c' )
            {
                urlParams.add('ZTS_US_Approved_Date__c=');
            }
            else if( fieldName == 'ZTS_US_Start_Date__c' )
            {
                String formattedDT = DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

                urlParams.add('ZTS_US_Start_Date__c=' + formattedDT);
            }
            else if( fieldName == 'ZTS_US_End_Date__c' )
            {
                String formattedDT = DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                
                urlParams.add('ZTS_US_End_Date__c=' + formattedDT);
            }
            else if( fieldName == 'ZTS_US_Approved__c' )
            {
                urlParams.add('ZTS_US_Approved__c=');           
            }
            else if( fieldName == 'ZTS_US_Approval_Status__c' )
            {
                urlParams.add('ZTS_US_Approval_Status__c='); 
            }
            else if( fieldName == 'RecordTypeId' || fieldName == 'Id')
            {
                continue;
            }
            else
            {
                urlParams.add(fieldName + '=' + fieldsToValue.get(fieldName) );
            }
        }
        
        url+= String.join(urlParams, ',');
       /*for (Integer i = 0; i < url.length(); i=i+300) {
            Integer iEffectiveEnd = (i+300 > (url.length()) ? url.length()-1 : i+300);
            System.debug(url.substring(i,iEffectiveEnd));
        }*/
       // /{!ZTS_Events__c.Id}/e?clone=1&retURL=%2F{!ZTS_Events__c.Id}&{!$Label.ZTS_US_Event_Status}=New&{!$Label.ZTS_US_Event_ApprovedDate}=&{!$Label.ZTS_US_Events_Start_Date_c}={! NOW() }&{!$Label.ZTS_US_Events_End_Date_c}={! NOW()}&{!$Label.ZTS_US_Event_Approved}=
		//url = EncodingUtil.urlEncode(url, 'UTF-8');
        //system.debug(url);
        return url;
    }
}
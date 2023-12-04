/*************************************************************************************************************************
  Class Name     : GlobalVariablesService
  Description    : This class contains global environment variable used by several service classes.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/17/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer              				Date                    Description
  ---------     		   				----             		-----------
  Deloitte Constulting/Fayas Mansoor	01/17/2014              Created
  Deloitte Consulting/Sunil 			05/21/2014				Modified
***************************************************************************************************************************/
global class GlobalVariablesService {


	public static boolean isCallUpdatingEvent	= false;
	public static boolean isEventUpdatingCall	= false;
	
	public static boolean isCallDeletingEvent	= false;
	public static boolean isEventDeletingCall	= false;
	public static ZTS_Settings__c zoetisAppConfig=CustomSettingService.getZoetisAppConfig();
	//Chnages made by Sunil
	 /** ORG INSTANCE BASE URL **/
    public static String SERVER_URL{get{
		String BASEURL=Url.getSalesforceBaseUrl().toExternalForm();
		String sfurl=BASEURL;
		if(BASEURL.contains('visual')){
		String[] result=BASEURL.split('\\.',3);
		String instance=result[1];
		sfurl='https://'+instance+'.salesforce.com';
		System.debug('sfurl from Visualforce '+sfurl);
    } 
    	return sfurl;
    }}
    
     public static String getString(SObject sobj,String property, String default_value){
    	String result=default_value;
    	if(sobj!=null && sobj.get(property)!=null){
    		result=(String)sobj.get(property);
    	}
    	return result;
    	
    }    
    
    /** TERRITORY MGMT Constants **/
     public final static String USER_LOOKUP_FIELD='ZTS_EU_Employee__c';
     public final static String USER_KEYCODE='005';
     public static String CRON_EXP_REMOVE_USERS{get{return getString(zoetisAppConfig,'ZTS_CRON_EXP_REMOVE_USERS__c','0 05 * * * ?');}}
	// End of change.
	
}
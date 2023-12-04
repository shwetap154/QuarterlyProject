/** Global Constants  class for Zoetis application **/
public class ZTS_GlobalConstants {
    public final static String INACTIVE_STATUS='Inactive';//TO BE RETRIEVED FROM CUSTOM SETTINGS
    public final static String ACCNT_BUSINESSCLASS_PRODUCERS='Producers';
    public final static String ACCNT_BUSINESSCLASS_SELECTPRODUCER='Select Producer';
    public final static String ACCNT_BUSINESSCLASS_STRATEGICPRODUCER='Strategic Producer';
    public final static String ACCNT_BUSINESSCLASS_VETERINARIAN='Veterinarian';
    public static ZTS_Settings__c zoetisAppConfig=CustomSettingService.getZoetisAppConfig();
    
    /** VMIPS_CASE Constants **/
    public  static boolean ENABLE_VMIPS_CASE_TASK_NOTIFY{get{return getBoolean(zoetisAppConfig,'ZTS_VMIPS_Case_Task_Notification__c',FALSE);}}
    public final static Integer WEEK_DAYS=7;
    public final static String  VMIPS_CASE_TASK_PRIORITY='High';
    public final static String  VMIPS_CASE_TASK_SUBJ_PRETEXT='Review New VMIPS Case - ';
    public final static String  VMIPS_CASE_TASK_TYPE='VMIPS Case'; //VMIPS Case
    public final static String  VMIPS_CASE_TYPE_INQUIRY='Inquiry';
    
    public final static String INACTIVE_CONTACT='Inactive';
    
    /** CAMPAIGN Constants **/
    public final static String CAMPAIGN_TYPE_EMAIL='Email';
    public final static String TELEMARKET_TYPE_EMAIL='Telemarketing';
    public final static String DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS='Sent';
    public final static String CAMPAIGN_OPEN_FIELD_TARGET_STATUS='Open';
    
    
    /** TERRITORY MGMT Constants **/
    
    public final static String DEFAULT_ACC_ACCESS='EDIT';
    public final static String DEFAULT_CASE_ACCESS='READ';
    public final static String DEFAULT_OPP_ACCESS='EDIT';
    public final static String DEFAULT_CONTACT_ACCESS='READ';
    public final static boolean DEFAULT_RESTRICT_OPP_TRANSFER=FALSE;
    public final static String USER_LOOKUP_FIELD='ZTS_EU_Employee__c';
    public final static String USER_KEYCODE='005';
    public final static String CHANGE_FLAG_STATUS_INSERT='Insert';
    public final static String CHANGE_FLAG_STATUS_DELETE='Delete';
    public static Date DATA_LOAD_END_DATE{get{return getDate(zoetisAppConfig,'ZTS_Data_Load_End_Date__c',Date.valueOf('2014-08-06'));}}
    
    /** CALL MGMT Constants **/
    public final static String COMPLETED_STATUS='Submitted';
    
    /** ZTS_Animal_Count_Potential__c Constants **/
    public final static String RECTYPE_CATTLECOUNT='Cattle Count';
    public final static String RECTYPE_PORKCOUNT='Pork Count';
    public final static String RECTYPE_EQUINECOUNT='Equine Count';
    public final static String RECTYPE_VETFTE='Vet FTE'; 
    
    /** KOL MGMT Constants **/
    public final static String KOL_SPEAKER_ROLE='Speaker'; 
    public final static String KOL_INFLUENCER_ROLE='Influencer';
    
    /** CALL Constants **/
    public final static String CALL_STATUS_COMPLETED='Submitted';
    
    /** Async Jobs **/
    public static String CRON_EXP_JOBS_CLOSE{get{return getString(zoetisAppConfig,'ZTS_CRON_EXP_JOBS_CLOSE__c','0 15 * * * ?');}}
    public static String CRON_EXP_REMOVE_USERS{get{return getString(zoetisAppConfig,'ZTS_CRON_EXP_REMOVE_USERS__c','0 05 * * * ?');}}
    public static String CRON_EXP_ACCTEAM_EXCEPTION_FLAG{get{return getString(zoetisAppConfig,'ZTS_CRON_EXP_EXCEPTION_FLAG__c','0 0 13 * * ?');}}
    public static String CRON_EXP_KOL_JOBS{get{return getString(zoetisAppConfig,'ZTS_CRON_KOL_JOBS__c','0 0 23 * * ?');}}
    
    /** Account teams chatter feed follow **/
    public static boolean ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS{get{return getBoolean(zoetisAppConfig,'ZTS_AccountTeamsAutoFollowChatterFeed__c',false);}}
    /** ORG INSTANCE BASE URL **/
    public static String SERVER_URL{get{
        String BASEURL=Url.getSalesforceBaseUrl().toExternalForm();
        String sfurl='';
        System.debug('Base URL is:'+BASEURL);
        system.debug('Url is :-'+sfurl);
        
        if(BASEURL.contains('vf')){
            String[] result=BASEURL.split('\\.',3);
            boolean isSanboxUrl = result[0].countMatches('--') > 1 ? true : false ;
            sfurl+= isSanboxUrl ? result[0].substring(0, result[0].lastIndexOf('--')) +'.'+ result[1] +'.my' : result[1];
            sfurl+= '.salesforce.com'; 
            System.debug('sfurl from Visualforce '+sfurl);
        }else{
            sfurl = BASEURL; 
        } 
        return sfurl;
    }}
    
    
    public static boolean getBoolean(SObject sobj,String property, boolean default_value){
        boolean result=default_value;
        if(sobj!=null && sobj.get(property)!=null){
            result= (Boolean)sobj.get(property);
        }
        return result;
        
    }
    
     public static String getString(SObject sobj,String property, String default_value){
        String result=default_value;
        if(sobj!=null && sobj.get(property)!=null){
            result=(String)sobj.get(property);
        }
        return result;
        
    }
    
        public static Date getDate(SObject sobj,String property, Date default_value){
        Date result=default_value;
        if(sobj!=null && sobj.get(property)!=null){
            result=(Date)sobj.get(property);
        }
        return result;
        
    }
    
}
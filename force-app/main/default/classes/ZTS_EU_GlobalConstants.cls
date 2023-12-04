/** Global Constants  class for Zoetis application **/
public class ZTS_EU_GlobalConstants {
   
    
    public final static String INACTIVE_CONTACT='Inactive';
    public static ZTS_Settings__c zoetisAppConfig=CustomSettingService.getZoetisAppConfig();
    
    /** CAMPAIGN Constants **/
    public final static String CAMPAIGN_TYPE_EMAIL='Email';
    public final static String TELEMARKET_TYPE_EMAIL='Telemarketing';
    public final static String DEFAULT_NEW_CAMPAIGN_MEMBER_STATUS='Sent';
    
        /** ToT Constants **/
    public static final string ToT_Full = 'Full Day = 9 AM - 5 PM';
    public static final string ToT_AM = 'AM = 9 AM to 1 PM';
    public static final string ToT_PM = 'PM = 1 PM to 5 PM';
    public static final string ToT_TIMEON = 'Time On';
    public static final string ToT_TIMEOFF = 'Time Off';
    public static final string SUBMITTED_VAL = 'Submitted';
    
    /** Account status Values **/
    public static final string ACTIVE_VAL = 'Active'; 
    public static final string INACTIVE_VAL = 'Inactive';    
    
    /***** Market value for Territory alignment***************/ 
    public static final string  MARKET_VAL = 'Ireland';
    public static final string  UK_MARKET_VAL = 'United Kingdom';
    
    //Ilirjana 10/14/14 Adding potential by BU to account
    public static final String potentialPrefix = 'ZTS_EU_'; 
    public static final String potentialSuffix = '_Potential__c';
    
    //Ilirjana 01/16/14 Ratings from account
    public static final String CADPre = 'CAD Pre';
    public static final String CADTher = 'CAD Ther';
    public static final String CA = 'CA';
    public static final String CTBF = 'CTBF';
    public static final String CTDY = 'CTDY';
    public static final String CTFL = 'CTFL';
    public static final String EQ = 'EQ';
    public static final String PY = 'PY';
    public static final String RU = 'RU';
    public static final String SW = 'SW';
    public static final String VPS = 'VPS';
    public static final String All = 'All';
    
    //Ilirjana 01/20/14 Part of SOQL
    public static final String emptyWhere = 'where ';
    
    //Ilirjana 28-Jan-14 Boolean values as string
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    
    /** TERRITORY MGMT Constants **/
    
    public final static String DEFAULT_ACC_ACCESS='EDIT';
    public final static String DEFAULT_CASE_ACCESS='READ';
    public final static String DEFAULT_OPP_ACCESS='EDIT';
    public final static String DEFAULT_CONTACT_ACCESS='READ';
    public final static boolean DEFAULT_RESTRICT_OPP_TRANSFER=FALSE;
    public final static String USER_LOOKUP_FIELD='ZTS_US_Employee__c';
    public final static String USER_KEYCODE='005';
    public final static String CHANGE_FLAG_STATUS_INSERT='Insert';
    public final static String CHANGE_FLAG_STATUS_DELETE='Delete';
    
        /** CALL Constants **/
    public final static String CALL_STATUS_COMPLETED='Submitted';
    
    /** KOL MGMT Constants **/
    public final static String KOL_SPEAKER_ROLE='Speaker'; 
    public final static String KOL_INFLUENCER_ROLE='Influencer';
    
    /** Account teams chatter feed follow **/
    public static boolean ACC_TEAM_AUTOFOLLOW_CHATTER_FEEDS{get{return getBoolean(zoetisAppConfig,'ZTS_AccountTeamsAutoFollowChatterFeed__c',false);}}
    
    public static boolean getBoolean(SObject sobj,String property, boolean default_value){
        boolean result=default_value;
        if(sobj!=null && sobj.get(property)!=null){
            result= (Boolean)sobj.get(property);
        }
        return result;
        
    }
}
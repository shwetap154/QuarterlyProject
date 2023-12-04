/*
    @@ Puropose: Abstract class with with code to be shared with ZTS_Calendar and ZTS_MonthlyPlanning classes. 
    @@ Author: Ilirjana Predojević (intial code transferred from ZTS_Calendar)

	calculateEndDateTime(dateTime, string) - To generate End date, when creating call.
    generateDateTime() - To convert Javascript datetime value to Apex dateTime value
    generateDate() - To convert Javascript date value to Apex date value
    createTimezoneMap() - To create Timezones map along with time zone id and offset value.
*/
public abstract class AbstractCalendar {
    public string userLanguage {get; set;} /* To getcurrent logged user language*/
    public string accId {get; set;} /* To store Account Id*/
    public string accName {get; set;} /* To store Account Name.*/
    public string cIds {get; set;} /*To store user record ids. Used to create Colleague records. This value comes from URL */
    
    /*To create JSON Object with list of event records */  
    public string open_cur_brace = '{';      
    public string close_cur_brace = '}';
    public string comma = ',';
    public string double_quote = '\"';
    public string open_sqaure = '[';
    public string close_square = ']';
    public string single_quote = '\'';
    public string open_brace = '(';      
    public string close_brace = ')';
    public integer i=0;
    
    /* To Store all time zone values*/
    public map<string,string> timeZonesMap;
    public string CurrentTimeZone;
    
    /*to store current user time zone */
    public string TimeZoneVal {get; set;}   
    
    //IP 29-Jan-2015 To store list of user's holidays
    List<string> lstHolidays = new List<string>();
    
    public AbstractCalendar(){
        userLanguage = userInfo.getLanguage();
        CurrentTimeZone = string.valueOf(userinfo.getTimeZone());
        
        /* Below map should contain all time zone values for respective time zones with opposit sign. To show proper timings on full calendar. */
        timeZonesMap = new map<string,string>();
        createTimezoneMap();
        if(timeZonesMap.get(CurrentTimeZone) != null){
            TimeZoneVal = timeZonesMap.get(CurrentTimeZone);
        }
    }
    
    /*Generate dateTime based on given start date and duration */
    public static dateTime calculateEndDateTime(dateTime startDate, string duration){
            List <String> strList = duration.split(' ');
            String str1 = strList[0];
            str1 = str1.trim();
            Double minutes = Double.valueOf(str1) * 60; 
            return (startDate.addMinutes(Integer.valueOf(minutes)));
    }
    
    public static dateTime generateDateTime(string dt){
        try{
            Datetime result;
            dt= dt.replace(' ','/');
            dt= dt.replace(':','/');
            string y;
            string m;
            string d;
            string min;
            string h;
            string a;
            string second = '0';
            list<string> s = new list<string>();
            s = dt.split('/');
            if(s.size()>0){
                m = s[0];
                d = s[1];
                y = s[2];
                h = s[3];
                min = s[4];
                a = s[5];
                if(a != 'AM'){
                    h = string.valueOf(integer.valueOf(h)+12);
                }
                
                string stringDate = y + '-' + m + '-' + d+ ' ' +h + ':' 
                    + min +  ':' + second;
                result = Datetime.valueOf(stringDate);
            }
            
            return result;
        }catch(exception e){
            return null;
        }
    }
    
    public static date generateDate(string dt){
        try{
            date result;
            string y;
            string m;
            string d;
            List<string> s = dt.split('/');
            if(s.size()>0){
                m = s[0];
                d = s[1];
                y = s[2];
                string stringDate = y + '-' + m + '-' + d;
                result = date.valueOf(stringDate);
            }
            return result;
        }catch(exception e){
            return null;
        }
    }
    
    public void createTimezoneMap(){
        /*Time zone values must be store with opposite sign. If Asia actual time zone +5:30, then it should be sotre as -5:30. To display event excatly, because by defualt full calendar runs in GMT time zone. */
        timeZonesMap.put('Pacific/Kiritimati','-14:00');
        timeZonesMap.put('Pacific/Chatham','-13:45');
        timeZonesMap.put('Pacific/Auckland','-13:00');
        timeZonesMap.put('Pacific/Enderbury','-13:00');
        timeZonesMap.put('Pacific/Fiji','-13:00');
        timeZonesMap.put('Pacific/Tongatapu','-13:00');
        timeZonesMap.put('Asia/Kamchatka','-12:00');
        timeZonesMap.put('Pacific/Norfolk','-11:30');
        timeZonesMap.put('Australia/Lord_Howe','-11:00');
        timeZonesMap.put('Australia/Sydney','-11:00');
        timeZonesMap.put('Pacific/Guadalcanal','-11:00');
        timeZonesMap.put('Australia/Adelaide','-10:30');
        timeZonesMap.put('Australia/Darwin','-9:30');
        timeZonesMap.put('Asia/Seoul','-9:00');
        timeZonesMap.put('Asia/Tokyo','-9:00');
        timeZonesMap.put('Asia/Hong_Kong','-8:00');
        timeZonesMap.put('Asia/Kuala_Lumpur','-8:00');
        timeZonesMap.put('Asia/Manila','-8:00');
        timeZonesMap.put('Asia/Shanghai','-8:00');
        timeZonesMap.put('Asia/Singapore','-8:00');
        timeZonesMap.put('Asia/Taipei','-8:00');
        timeZonesMap.put('Australia/Perth','-8:00');
        timeZonesMap.put('Asia/Bangkok','-7:00');
        timeZonesMap.put('Asia/Ho_Chi_Minh','-7:00');
        timeZonesMap.put('Asia/Jakarta','-7:00');
        timeZonesMap.put('Asia/Rangoon','-6:30');
        timeZonesMap.put('Asia/Dhaka','-6:00');
        timeZonesMap.put('Asia/Yekaterinburg','-6:00');
        timeZonesMap.put('Asia/Kathmandu','-5:45');
        timeZonesMap.put('Asia/Colombo','-5:30');
        timeZonesMap.put('Asia/Kolkata','-5:30');
        timeZonesMap.put('Asia/Karachi','-5:00');
        timeZonesMap.put('Asia/Tashkent','-5:00');
        timeZonesMap.put('Asia/Kabul','-4:30');
        timeZonesMap.put('Asia/Dubai','-4:00');
        timeZonesMap.put('Asia/Tbilisi','-4:00');
        timeZonesMap.put('Europe/Moscow','-4:00');
        timeZonesMap.put('Asia/Tehran','-3:30');
        timeZonesMap.put('Africa/Nairobi','-3:00');
        timeZonesMap.put('Asia/Baghdad','-3:00');
        timeZonesMap.put('Asia/Kuwait','-3:00');
        timeZonesMap.put('Asia/Riyadh','-3:00');
        timeZonesMap.put('Europe/Minsk','-3:00');
        timeZonesMap.put('Africa/Cairo','-2:00');
        timeZonesMap.put('Africa/Johannesburg','-2:00');
        timeZonesMap.put('Asia/Jerusalem','-2:00');
        timeZonesMap.put('Europe/Athens','-2:00');
        timeZonesMap.put('Europe/Bucharest','-2:00');
        timeZonesMap.put('Europe/Helsinki','-2:00');
        timeZonesMap.put('Europe/Istanbul','-2:00');
        timeZonesMap.put('Africa/Algiers','-1:00');
        timeZonesMap.put('Europe/Amsterdam','-1:00');
        timeZonesMap.put('Europe/Berlin','-1:00');
        timeZonesMap.put('Europe/Brussels','-1:00');
        timeZonesMap.put('Europe/Paris','-1:00');
        timeZonesMap.put('Europe/Prague','-1:00');
        timeZonesMap.put('Europe/Rome','-1:00');
        timeZonesMap.put('Europe/Dublin','-0:00');
        timeZonesMap.put('Europe/Lisbon','-0:00');
        timeZonesMap.put('Europe/London','-0:00');
        timeZonesMap.put('GreenwichMeanTime','-0:00');
        timeZonesMap.put('Atlantic/Cape_Verde','+1:00');
        timeZonesMap.put('America/Sao_Paulo','+2:00');
        timeZonesMap.put('Atlantic/South_Georgia','+2:00');
        timeZonesMap.put('America/Argentina/Buenos_Aires','+3:00');
        timeZonesMap.put('America/Santiago','+3:00');
        timeZonesMap.put('America/St_Johns','+3:30');
        timeZonesMap.put('America/Halifax','+4:00');
        timeZonesMap.put('America/Puerto_Rico','+4:00');
        timeZonesMap.put('Atlantic/Bermuda','+4:00');
        timeZonesMap.put('America/Caracas','+4:30');
        timeZonesMap.put('America/Bogota','+5:00');
        timeZonesMap.put('America/Indiana/Indianapolis','+5:00');
        timeZonesMap.put('America/Lima','+5:00');
        timeZonesMap.put('America/New_York','+5:00');
        timeZonesMap.put('America/Panama','+5:00');
        timeZonesMap.put('America/Chicago','+6:00');
        timeZonesMap.put('America/El_Salvador','+6:00');
        timeZonesMap.put('America/Mexico_City','+6:00');
        timeZonesMap.put('America/Denver','+7:00');
        timeZonesMap.put('America/Phoenix','+7:00');
        timeZonesMap.put('America/Los_Angeles','+8:00');
        timeZonesMap.put('America/Tijuana','+8:00');
        timeZonesMap.put('America/Anchorage','+9:00');
        timeZonesMap.put('Pacific/Honolulu','+10:00');
        timeZonesMap.put('Pacific/Niue','+11:00');
        timeZonesMap.put('Pacific/Pago_Pago','+11:00');
    }
    
    //Ilirjana Predojević 28-Jan-2015
    //Get list of holidays for logged in user.
    public String getLstHolidays(){
        try{
            if (lstHolidays != null && lstHolidays.size() > 0)
                return JSON.serialize(lstHolidays);
            
            List<User> user = [
                select ZTS_EU_Market__c, ZTS_EU_State_County_Id__c
                from User
                where Id = :UserInfo.getUserId()];
                
            List<Holiday__c> holidays = [
                select Id, ZTS_EU_Holiday_Date__c
                from Holiday__c
                where ZTS_EU_Is_Active__c = true 
                    and ZTS_EU_Market__c = :user[0].ZTS_EU_Market__c 
                    and (ZTS_EU_Default_Holiday__c = true or ZTS_EU_State_County__c = :user[0].ZTS_EU_State_County_Id__c)];
            
            for (Holiday__c holiday : holidays){
                if (holiday.ZTS_EU_Holiday_Date__c != null && String.ValueOf(holiday.ZTS_EU_Holiday_Date__c) != '')
                    lstHolidays.add(String.ValueOf(holiday.ZTS_EU_Holiday_Date__c));
            }
        }
        catch(exception e){
            system.debug('exMessage from getLstHolidays '+e.getMessage());
        }
        return JSON.serialize(lstHolidays);
    }
}
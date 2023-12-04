/*
 * @Name: ZTS_EU_UserUtility
 * @Desciption: Utility Class for the trigger on User.
                1. Populates the state Id on the user record if the appropriate state and country are added. Else gives an error.
 * Author: CloudSense (Shreyas) 
 * @Date: 30th-Sep-2014
 * Modification Log
-------------------------
Date             Developer                Comments  
---------------------------------------------------------------------------------------
30th-Sep-2014	Cloudsense			     Created
13-Feb-2017	    Aritra(Cognizant)        Added method "createTotforHoliday" to create TOT for holiday records automatically when a new user joins. (as a part of SC-002868)
 */

public class ZTS_EU_UserUtility{

    /*
    Method name: populateStateId
    Arguments: List <User>
    Return type: Void
    */
    public static void populateStateId(List<User> userList){
    
        List<string> stateNameList = new List<string>();
        
        for(User u: userList){
            stateNameList.add(u.state);
        }
    
        List<State_Country__c> stateList = new List<State_Country__c>();
        Map<string, string> stateMap = new Map<string, string>();
        
        stateList = [Select Name, ZTS_EU_Country__c from State_Country__c where Name IN: stateNameList];
        
        for(State_Country__c state: stateList){
            string stateKey = state.ZTS_EU_Country__c + '-' + state.Name;
            stateMap.put(stateKey, state.Id);
        }
        
        for(User u: userList){
            string userKey = u.Default_Country__c + '-' + u.State;
            if(stateMap.containsKey(userKey)){
                if(stateMap.get(userKey) != null){
                    string stateId = stateMap.get(userKey);
                    stateId = stateId.substring(0,15);
                    u.ZTS_EU_State_County_Id__c = stateId;
                }
            }
            else if (u.State != null){
                u.addError(System.Label.ZTS_EU_Invalid_State);
            }
        
        }
    }
    
    /*
    Method name: createTotforHoliday
	Purpose: This method will create TOT for all the Holidays for the market
    Arguments: Map <Id,Market>
    Return type: Void
    */
    @future
    public static void createTotforHoliday(Map <Id,String> userMap){
        
		List < Time_Out_of_Territory__c> lstTot = new List <Time_Out_of_Territory__c> ();
        List <Excluded_Profiles_for_Auto_TOT__c> Profs = Excluded_Profiles_for_Auto_TOT__c.getall().values();
        
        List<String> marketsList = userMap.values();
        Map<String, List<Holiday__c>> mapProfileToHolidayList = new Map<String, List<Holiday__c>>();

        List < Holiday__c > holidayList = [ SELECT Id,Name,ZTS_EU_Holiday_Date__c,ZTS_EU_Market__c 
                                            FROM Holiday__c 
                                            WHERE ZTS_EU_Market__c IN :marketsList AND ZTS_EU_Is_Active__c = True AND ZTS_EU_Default_Holiday__c = true AND ZTS_EU_Current_Year_Holiday__c ='Yes'
                                            ];
        for(Holiday__c holidayRec : holidayList){

            if(mapProfileToHolidayList.containsKey(holidayRec.ZTS_EU_Market__c)){
                List <Holiday__c> tempList =  mapProfileToHolidayList.get(holidayRec.ZTS_EU_Market__c);
                tempList.add(holidayRec);
                mapProfileToHolidayList.put(holidayRec.ZTS_EU_Market__c, tempList);
            }
            else{
                List <Holiday__c> tempList =  new List <Holiday__c>();
                tempList.add(holidayRec);
                mapProfileToHolidayList.put(holidayRec.ZTS_EU_Market__c, tempList);
            }

        }
        
        for (Id entry : userMap.keySet()) 
		{
            Id uid = entry;
            String profile = userMap.get(entry);
            system.debug('profile->'+profile);
            List <Holiday__c> lstHoliday = mapProfileToHolidayList.get(profile);
            system.debug('lstHoliday--->>>'+ lstHoliday);
            if(lstHoliday!=null && lstHoliday.size()>0)
            {
                for (Holiday__c h: lstHoliday)
                {
                    Time_Out_of_Territory__c tot = new Time_Out_of_Territory__c();
                    tot.ZTS_EU_Type__c = 'Time Off';
                    tot.ZTS_EU_Reason__c = 'NW - Company holiday';
                    tot.ZTS_EU_Start_Date__c = h.ZTS_EU_Holiday_Date__c;
                    tot.ZTS_EU_End_Date__c = h.ZTS_EU_Holiday_Date__c;
                    tot.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
                    tot.OwnerId = uid;
                    tot.ZTS_Market__c = h.ZTS_EU_Market__c;
                    tot.ZTS_EU_Status__c = 'Submitted';
                    tot.ZTS_EU_Description__c = h.Name;
                    lstTot.add(tot);
                }
            
            system.debug('lsttot::'+lstTot);
            }
            else
            {
                system.debug('Currently no Holiday present for the market');
            }
        }
        
        if(lstTot.size()>0)
        {
            insert lstTot;
        }
            
		} 
    public static Map<Id, List<Time_Out_of_Territory__c>> fetchUserTotRecords(List <User > lstNew){
          Map<Id, List<Time_Out_of_Territory__c>> userTotMap = new Map<Id, List<Time_Out_of_Territory__c>>();
          for(Time_Out_of_Territory__c tot: [select id, ZTS_EU_Type__c, ZTS_EU_Reason__c, OwnerId, ZTS_Market__c from Time_Out_of_Territory__c where OwnerId IN : lstNew 
                                             and ZTS_EU_Reason__c = 'NW - Company holiday' ]){
            if(!userTotMap.containsKey(tot.id))
                userTotMap.put(tot.ownerId, new List<Time_Out_of_Territory__c>());
                userTotMap.get(tot.ownerId).add(tot); 
            System.debug('User TOT map records' + userTotMap);
            
        }
        return userTotMap; 
        
    }

    }
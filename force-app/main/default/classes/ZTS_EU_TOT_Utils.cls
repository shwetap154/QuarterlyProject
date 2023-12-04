/*
 * @Name: ZTS_EU_TOT_Utils
 * @Desciption: Utils Class for the trigger on TOT.
 *              1.Avoids creation and updation of TOT for the User whenever there is a conflict with DateTime of a call associated with that User.
 *              2.Avoids creation and updation of TOT ON the User whenever there is a conflict with TOT OFF associated with that User.
 *              3.Avoids creation and updation of TOT OFF the User whenever there is a conflict with TOT ON associated with that User.
 * @date Created:May 29, 2014
 * @author Deloitte Consulting/Chandra Pinarouthu
 * 
 * Change Description:
 * Author: CloudSense (Shreyas) 
 * @Date: 15th-Sep-2014
 * @Description; Added the method 'calculateDayCount' to calculate the number of weekends/holidays between Start and End date of ToT record. 
                 Added the method 'populateStateOnToT' to populate the state of owner/sales-rep.
                 Will be called from the trigger: ZTS_EU_AllTOTTrigger
 */
 
public class ZTS_EU_TOT_Utils {
    /***********
     * Method name  : validateTOTDateOnInsertAndUpdate
     * Description  : This method will check Time OFF/ON conflicts with existing Calls associated with the owner of Sales Rep
     * Return Type  : None.
     * Parameters   : List of ToT records
     ***********/
    public Static Boolean  IsTotDelete = false;
    public static final string ToT_Full = ZTS_EU_GlobalConstants.ToT_Full;
    public static final string ToT_AM = ZTS_EU_GlobalConstants.ToT_AM;
    public static final string ToT_PM = ZTS_EU_GlobalConstants.ToT_PM;
    public static final string ToT_TIMEON = ZTS_EU_GlobalConstants.ToT_TIMEON;
    public static final string ToT_TIMEOFF = ZTS_EU_GlobalConstants.ToT_TIMEOFF;    
    public static void validateTOTDateOnInsertAndUpdate(List < Time_Out_of_Territory__c > lstTOT) {
    /*****************************************
    VARIABLES
    ******************************************/
            List < ZTS_EU_Colleague__c > lstclg = new List < ZTS_EU_Colleague__c > ();
            List < Call__c > lstCall = new List < Call__c > ();
            Set < Id > setCallId = new Set < Id > ();
            Set < Integer > beforeHours = new Set < Integer > {
                9, 10, 11, 12
            };
            //  updated code as part of the ticket T-17207 by Srinivas
            Set < Integer > afterHours = new Set < Integer > {
                13,14, 15, 16, 17, 18
            };
            Set < Id > srepId = new Set < Id > ();
            for (Time_Out_of_Territory__c tot: lstTOT) {
                srepId.add(tot.Record_Owner__c);
            }
            lstclg = [Select a.ZTS_EU_call__c, a.ZTS_EU_call__r.ZTS_EU_Start_Date_Time__c, a.ZTS_EU_call__r.Id, a.ZTS_EU_call__r.ZTS_EU_End_Date_Time__c, a.ZTS_EU_User__c From ZTS_EU_Colleague__c a where a.ZTS_EU_User__c IN: srepId AND ZTS_EU_Market__c != 'United States'];
            Map < id, List < Call__c >> mapUserCalls = new Map < id, List < Call__c > > ();
            if (lstclg != null && lstclg.size() > 0) {
                for (ZTS_EU_Colleague__c clg: lstclg) {
                    setCallId.add(clg.ZTS_EU_call__c);
                    if (!mapUserCalls.containsKey(clg.ZTS_EU_User__c)) {
                        mapUserCalls.put(clg.ZTS_EU_User__c, new List < Call__c > ());
                    }
                    mapUserCalls.get(clg.ZTS_EU_User__c).add(clg.ZTS_EU_call__r);
                }
            }
			 
            lstCall = [Select c.ZTS_EU_Start_Date_Time__c, c.Id, c.ZTS_EU_End_Date_Time__c, c.ZTS_EU_Account__c, c.CreatedById From Call__c c where c.ZTS_EU_Record_Owner__c IN: srepId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            for (Call__c call: lstCall) {
                if (!mapUserCalls.containsKey(call.CreatedbyId)) {
                    mapUserCalls.put(call.CreatedbyId, new List < Call__c > ());
                }
                mapUserCalls.get(call.CreatedbyId).add(call);
            }
            for (Time_Out_of_Territory__c tot: lstTOT) {
                if (mapUserCalls.containsKey(tot.Record_Owner__c)) {
                    for (Call__c c: mapUserCalls.get(tot.Record_Owner__c)) {
                        system.debug('call start date' + c );
                        if(c.ZTS_EU_Start_Date_Time__c !=null && c.ZTS_EU_End_Date_Time__c!=null){
                  
                //(original code) if (tot.ZTS_EU_Start_Date__c == c.ZTS_EU_Start_Date_Time__c.date()) {
                // Modified code added by Priya
 
                  if (tot.ZTS_EU_Start_Date__c == c.ZTS_EU_Start_Date_Time__c.date() || (tot.ZTS_EU_Start_Date__c < c.ZTS_EU_Start_Date_Time__c.date() && tot.ZTS_EU_End_Date__c >= c.ZTS_EU_End_Date_Time__c.date())) {
                            if (tot.ZTS_EU_Duration__c == ToT_AM && beforehours.contains(c.ZTS_EU_Start_Date_Time__c.hour())) {
                                tot.addError(System.Label.Call_conflict_message);
                            } else if (tot.ZTS_EU_Duration__c == ToT_PM && afterhours.contains(c.ZTS_EU_Start_Date_Time__c.hour())) {
                                tot.addError(System.Label.Call_conflict_message);
                            } else if (tot.ZTS_EU_Duration__c == ToT_Full && (afterhours.contains(c.ZTS_EU_Start_Date_Time__c.hour()) || beforehours.contains(c.ZTS_EU_Start_Date_Time__c.hour()))) {
                                tot.addError(System.Label.Call_conflict_message);
                            }
                        }
                    }
                    }
                }
            }
        }
        /***********
         * Method name  : validateTOT
         * Description  : This method will check Time OFF/ON conflicts with existing Time OFF's/ON's
         * Return Type  : None.
         * Parameters   : List of ToT records
         ***********/
   
    public static void validateTOT(List < Time_Out_of_Territory__c > lstTOT) {
       
        
            List < Time_Out_of_Territory__c > lstOldTOT = new List < Time_Out_of_Territory__c > ();
            List < Time_Out_of_Territory__c > lstOldTOff = new List < Time_Out_of_Territory__c > ();
            List < Time_Out_of_Territory__c > lstOldTOn = new List < Time_Out_of_Territory__c > ();
            Map < String, String > mapStartdtTOT = new Map < String, String > ();
            Map < String, String > mapEnddtTOT = new Map < String, String > ();
            Set < Id > srepId = new Set < Id > ();
            for (Time_Out_of_Territory__c tot: lstTOT) {
                srepId.add(tot.ownerId);
            }
            Map < Id, List < Time_Out_of_Territory__c >> mapuserToTs = new Map < Id, List < Time_Out_of_Territory__c >> ();
        //Added by Ankur as part of TPDEV-862 to filter out TOT of current year. 
        lstOldTOT = [Select ZTS_EU_Start_Date__c, OwnerId, ZTS_EU_End_Date__c, Record_Owner__c, ZTS_EU_Duration__c, ZTS_EU_Sales_Representative__c, ZTS_EU_Type__c, ZTS_EU_Status__c From Time_Out_of_Territory__c where  ZTS_EU_Start_Date__c>= THIS_YEAR and ZTS_EU_Status__c != 'Cancelled' 
                and ownerId IN: srepId AND ZTS_Market__c != 'United States' Order By ZTS_EU_Duration__c];   
         for (Time_Out_of_Territory__c tot2: lstOldTOT) {
                if (!mapuserToTs.containsKey(tot2.ownerId)) {
                    mapuserToTs.put(tot2.ownerId, new List < Time_Out_of_Territory__c > {
                        tot2
                    });
                } else {
                    mapuserToTs.get(tot2.ownerId)
                        .add(tot2);
                }
            }
            for (Time_Out_of_Territory__c tot1: lstTOT) {
                if (mapuserToTs.containsKey(tot1.ownerId)) {
                    List < Time_Out_of_Territory__c > lstToTOff2 = mapuserToTs.get(tot1.ownerId);
                    system.debug('tot1.ownerId====>'+tot1.ownerId);
                    // lstToTOff2.addall(mapuserToTs.get(srepId));                    
                    for (Time_Out_of_Territory__c totOff: lstToTOff2) {
                        if (tot1.ZTS_EU_Type__c == ToT_TIMEOFF) {
            System.debug('check values** '+tot1.ZTS_EU_Start_Date__c +'*= '+ totOff.ZTS_EU_End_Date__c);                
                            //original code
                            /*Integer numberOfNewDays =  tot1.ZTS_EU_Start_Date__c.daysBetween(tot1.ZTS_EU_End_Date__c);
                            Integer numberOfOldDays = totOff.ZTS_EU_Start_Date__c.daysBetween(totOff.ZTS_EU_End_Date__c);
                            system.debug('numberOfOldDays====>'+ numberOfOldDays);
                            system.debug('numberOfNewDays====>'+ numberOfNewDays);*/
                           
                          if (tot1.ZTS_EU_Start_Date__c == totOff.ZTS_EU_End_Date__c && totOff.ZTS_EU_Type__c == ToT_TIMEOFF &&  tot1.id!=totOff.id) {  
                             if ((tot1.ZTS_EU_Duration__c == ToT_AM && (totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_Full)) || (tot1.ZTS_EU_Duration__c == ToT_Full && (totOff.ZTS_EU_Duration__c == ToT_Full || totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_PM)) || (tot1.ZTS_EU_Duration__c == ToT_PM && (totOff.ZTS_EU_Duration__c == ToT_PM || totOff.ZTS_EU_Duration__c == ToT_Full))) {
                                     System.debug('tot1.ZTS_EU_Start_Date__c=====>'+tot1.ZTS_EU_Start_Date__c); 
                                      System.debug('totOff.ZTS_EU_End_Date__c=====>'+totOff.ZTS_EU_End_Date__c); 
                                      System.debug('totOff.ZTS_EU_Duration__c'+totOff.ZTS_EU_Duration__c); 
                                      System.debug('ToT_AM=====>'+ToT_AM); 
                                      System.debug('ToT_Full'+ToT_Full); 
                                      System.debug('ToT_PM'+ToT_PM); 
                                      System.debug('inside if1=====>'); 
                                      System.debug('inside if1=====>'); 
                                     System.debug('tot1.ZTS_EU_Duration__c=====>' + tot1.ZTS_EU_Duration__c);
                                     System.debug('totOff.ZTS_EU_Duration__c=====>' + totOff.ZTS_EU_Duration__c);
                                    tot1.addError(System.label.ToT_Validate_message1);
                                }
                             else if (tot1.ZTS_EU_Start_Date__c == totOff.ZTS_EU_End_Date__c && totOff.ZTS_EU_Type__c == ToT_TIMEON) {
                                if ((tot1.ZTS_EU_Duration__c == ToT_AM && (totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_Full)) || (tot1.ZTS_EU_Duration__c == ToT_Full && (totOff.ZTS_EU_Duration__c == ToT_Full || totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_PM)) || (tot1.ZTS_EU_Duration__c == ToT_PM && (totOff.ZTS_EU_Duration__c == ToT_PM || totOff.ZTS_EU_Duration__c == ToT_Full))) {
                                     System.debug('inside else=====>');
                                    tot1.addError(System.label.ToT_Validate_message1);
                                }
                            }
                          }
                            //Code modified by Priya to prevent overlapping of Tot's.
                          else  if ((tot1.ZTS_EU_Start_Date__c >= totOff.ZTS_EU_Start_Date__c && tot1.id!=totOff.id &&tot1.ZTS_EU_Start_Date__c <= totOff.ZTS_EU_End_Date__c) || 
                                (tot1.ZTS_EU_End_Date__c >= totOff.ZTS_EU_Start_Date__c && tot1.ZTS_EU_End_Date__c <= totOff.ZTS_EU_End_Date__c) || 
                                (tot1.ZTS_EU_Start_Date__c <= totOff.ZTS_EU_Start_Date__c && tot1.ZTS_EU_End_Date__c >= totOff.ZTS_EU_End_Date__c) && totOff.ZTS_EU_Type__c == ToT_TIMEOFF)
                            {
                                System.debug('inside 1=====>'+tot1.id);
                                System.debug('inside 1=====>'+totOff.id);
                                System.debug('tot1.ZTS_EU_Start_Date__c=====>'+ tot1.ZTS_EU_Start_Date__c);
                                System.debug('tot1.ZTS_EU_End_Date__c=====>'+ tot1.ZTS_EU_End_Date__c);
                                System.debug('totOff.ZTS_EU_Start_Date__c=====>' +totOff.ZTS_EU_Start_Date__c );
                                System.debug('totOff.ZTS_EU_End_Date__c=====>'+ totOff.ZTS_EU_End_Date__c);
                               if ( (tot1.id!=totOff.id) && ((tot1.ZTS_EU_Duration__c == ToT_AM && (totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_Full)) || (tot1.ZTS_EU_Duration__c == ToT_Full && (totOff.ZTS_EU_Duration__c == ToT_Full || totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_PM)) || (tot1.ZTS_EU_Duration__c == ToT_PM && (totOff.ZTS_EU_Duration__c == ToT_PM || totOff.ZTS_EU_Duration__c == ToT_Full)))) {
                                     //System.debug('inside========>'+tot1.id!=totOff.id);
                                     System.debug('tot1.ZTS_EU_Duration__c=====>' + tot1.ZTS_EU_Duration__c);
                                     System.debug('totOff.ZTS_EU_Duration__c=====>' + totOff.ZTS_EU_Duration__c);
                                    tot1.addError(System.label.ToT_Validate_message1);
                                }
                            } else if (tot1.ZTS_EU_Start_Date__c == totOff.ZTS_EU_End_Date__c && totOff.ZTS_EU_Type__c == ToT_TIMEON) {
                                if ((tot1.ZTS_EU_Duration__c == ToT_AM && (totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_Full)) || (tot1.ZTS_EU_Duration__c == ToT_Full && (totOff.ZTS_EU_Duration__c == ToT_Full || totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_PM)) || (tot1.ZTS_EU_Duration__c == ToT_PM && (totOff.ZTS_EU_Duration__c == ToT_PM || totOff.ZTS_EU_Duration__c == ToT_Full))) {
                                     System.debug('inside else=====>');
                                    tot1.addError(System.label.ToT_Validate_message1);
                                }
                            }
                        } else if (tot1.ZTS_EU_Type__c == ToT_TIMEON) {
                            system.debug('tot1.ZTS_EU_Type__c====>'+tot1.ZTS_EU_Type__c);
                            system.debug('tot1.Id====>'+tot1.Id);
                            system.debug('totoff.Id====>'+totoff.Id);
                            
                           // if (tot1.ZTS_EU_Start_Date__c == totOff.ZTS_EU_End_Date__c && totOff.ZTS_EU_Type__c == ToT_TIMEOFF) {
                           if ((tot1.ZTS_EU_Start_Date__c >= totOff.ZTS_EU_Start_Date__c && tot1.Id!=totoff.Id &&tot1.ZTS_EU_Start_Date__c <= totOff.ZTS_EU_End_Date__c) || 
                                (tot1.ZTS_EU_End_Date__c >= totOff.ZTS_EU_Start_Date__c && tot1.ZTS_EU_End_Date__c <= totOff.ZTS_EU_End_Date__c) || 
                                (tot1.ZTS_EU_Start_Date__c <= totOff.ZTS_EU_Start_Date__c && tot1.ZTS_EU_End_Date__c >= totOff.ZTS_EU_End_Date__c)  && totOff.ZTS_EU_Type__c == ToT_TIMEOFF) {
                                system.debug('totOffId'+totOff.Id);
                                if ( (tot1.Id!=totoff.Id ) && ((tot1.ZTS_EU_Duration__c == ToT_AM && (totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_Full)) || (tot1.ZTS_EU_Duration__c == ToT_Full && (totOff.ZTS_EU_Duration__c == ToT_Full || totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_PM)) || (tot1.ZTS_EU_Duration__c == ToT_PM && (totOff.ZTS_EU_Duration__c == ToT_PM || totOff.ZTS_EU_Duration__c == ToT_Full)))) 
                                {
                                    system.debug('tot1.Id============>'+tot1.Id);
                                    system.debug('totoff.Id============>'+totoff.Id);
                                    tot1.addError(System.label.ToT_Validate_message2);
                                }
                            } else if (tot1.ZTS_EU_Start_Date__c == totOff.ZTS_EU_End_Date__c && totOff.ZTS_EU_Type__c == ToT_TIMEON) {
                                system.debug('tot1====>'+tot1);
                                system.debug('totOff====>'+totOff);
                                if ((tot1.ZTS_EU_Duration__c == ToT_AM && (totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_Full)) || (tot1.ZTS_EU_Duration__c == ToT_Full && (totOff.ZTS_EU_Duration__c == ToT_Full || totOff.ZTS_EU_Duration__c == ToT_AM || totOff.ZTS_EU_Duration__c == ToT_PM)) || (tot1.ZTS_EU_Duration__c == ToT_PM && (totOff.ZTS_EU_Duration__c == ToT_PM || totOff.ZTS_EU_Duration__c == ToT_Full))) {tot1.addError(System.label.ToT_Validate_message2);
                                }
                            }
                        }
                    }
                }
            }
        }
        /***********
         * Method name  : validateTOTOffconflicts
         * Description  : This method will check Time OFF conflicts with Time ON's
         * Return Type  : None.
         * Parameters   : List of ToT records
         ***********/
    public static void validateTOTOffconflicts(List < Time_Out_of_Territory__c > lstTOTOn) {
              // Commented code as part of the ticket T-17374 by Srinivas
            /*Set < Id > srepId1 = new Set < Id > ();
            for (Time_Out_of_Territory__c tot: lstTOTOn) {
                srepId1.add(tot.ZTS_EU_Sales_Representative__c);
            }
            List < Time_Out_of_Territory__c > lstToTOff = new List < Time_Out_of_Territory__c > ();
            lstToTOff = [Select ZTS_EU_Start_Date__c, OwnerId, ZTS_EU_End_Date__c, ZTS_EU_Duration__c, ZTS_EU_Sales_Representative__c, ZTS_EU_Type__c, ZTS_EU_Status__c From Time_Out_of_Territory__c where ZTS_EU_Status__c != 'Cancelled'
                and OwnerId = : srepId1 AND ZTS_Market__c != 'United States'];
            //Create Map and put Ownerid,List of ToT's as values
            Map < Id, List < Time_Out_of_Territory__c >> mapOfTotOff = new Map < Id, List < Time_Out_of_Territory__c >> ();
            //  List<Time_Out_of_Territory__c> lstToTOff = new List<Time_Out_of_Territory__c>();
            for (Time_Out_of_Territory__c totOff: lstToTOff) {
                if (!mapOfTotOff.containsKey(totOff.OwnerId)) {
                    mapOfTotOff.put(totOff.OwnerId, new List < Time_Out_of_Territory__c > ());
                }
                mapOfTotOff.get(totOff.OwnerId)
                    .add(totOff);
            }
            Map < Id, List < Time_Out_of_Territory__c >> mapOfTotOn = new Map < Id, List < Time_Out_of_Territory__c >> ();

            for (Time_Out_of_Territory__c totOn: lstToTOn) {
                if (!mapOfTotOn.containsKey(totOn.OwnerId)) {
                    mapOfTotOn.put(totOn.ZTS_EU_Sales_Representative__c, new List < Time_Out_of_Territory__c > ());

                }
                mapOfTotOn.get(totOn.ZTS_EU_Sales_Representative__c)
                    .add(totOn);
            }

            Map < Id, List < Time_Out_of_Territory__c >> mapToT = new Map < Id, List < Time_Out_of_Territory__c >> ();

            for (Id sid: mapOfTotOn.keySet()) {
                for (Time_Out_of_Territory__c totOn: mapOfTotOn.get(sid)) {
                    if (mapOfTotOff.containsKey(sid)) {
                        List < Time_Out_of_Territory__c > lstToTOff2 = mapOfTotOff.get(sid);
                        for (Time_Out_of_Territory__c totOff: lstToTOff2) {
                            if (totOn.ZTS_EU_Start_Date__c == totOff.ZTS_EU_End_Date__c) {
                                if ((totOn.ZTS_EU_Duration__c == totOff.ZTS_EU_Duration__c) || totOn.ZTS_EU_Duration__c == ToT_Full || totOff.ZTS_EU_Duration__c == ToT_Full) {totOn.addError(System.label.TimeOff_conflicts_messages);
                                }
                            }
                        }
                    }
                }
            }*/
        }
        /***********
         * Method name  : validateTOTOnconflicts
         * Description  : This method will check Time ON conflicts with Time Off
         * Return Type  : None.
         * Parameters   : List of ToT records
         ***********/
    public static void validateTOTOnconflicts(List < Time_Out_of_Territory__c > lstTOTOFF) {
     //Commented code as part of the ticket Def-1423 by Priya
       /* Set < Id > srepId1 = new Set < Id > ();
        for (Time_Out_of_Territory__c tot: lstTOTOFF) {
            srepId1.add(tot.ownerid);
        }

        List < Time_Out_of_Territory__c > lstToTON = new List < Time_Out_of_Territory__c > ();
        lstToTON = [Select ZTS_EU_Start_Date__c, OwnerId, ZTS_EU_End_Date__c, ZTS_EU_Duration__c, ZTS_EU_Sales_Representative__c, ZTS_EU_Type__c, ZTS_EU_Status__c From Time_Out_of_Territory__c where ZTS_EU_Status__c != 'Cancelled'
            and ZTS_EU_Sales_Representative__c = : srepId1 AND ZTS_Market__c != 'United States'];
        //Create Map and put Ownerid,List of ToT's as values
        Map < Id, List < Time_Out_of_Territory__c >> mapOfTotON = new Map < Id, List < Time_Out_of_Territory__c >> ();
        for (Time_Out_of_Territory__c totON: lstToTON) {
            if (!mapOfTotON.containsKey(totON.ZTS_EU_Sales_Representative__c)) {
                mapOfTotON.put(totON.ZTS_EU_Sales_Representative__c, new List < Time_Out_of_Territory__c > ());

            }
            mapOfTotON.get(totON.ZTS_EU_Sales_Representative__c)
                .add(totON);
        }
        Map < Id, List < Time_Out_of_Territory__c >> mapOfTotOFF = new Map < Id, List < Time_Out_of_Territory__c >> ();

        for (Time_Out_of_Territory__c totOFF: lstToTOFF) {
            if (!mapOfTotOFF.containsKey(totOFF.OwnerId)) {
                mapOfTotOFF.put(totOFF.OwnerId, new List < Time_Out_of_Territory__c > ());

            }
            mapOfTotOFF.get(totOFF.OwnerId)
                .add(totOFF);
        }
        Map < Id, List < Time_Out_of_Territory__c >> mapToT = new Map < Id, List < Time_Out_of_Territory__c >> ();
        for (Id sid: mapOfTotOFF.keySet()) {
            for (Time_Out_of_Territory__c totOFF: mapOfTotOFF.get(sid)) {
                if (mapOfTotON.containsKey(sid)) {
                    List < Time_Out_of_Territory__c > lstToTON2 = mapOfTotON.get(sid);
                    for (Time_Out_of_Territory__c totON: lstToTON2) {
                        if (totOFF.ZTS_EU_Start_Date__c == totON.ZTS_EU_End_Date__c) {
                            if ((totOFF.ZTS_EU_Duration__c == totON.ZTS_EU_Duration__c) || totOFF.ZTS_EU_Duration__c == ToT_Full || totON.ZTS_EU_Duration__c == ToT_Full) {
                                totOFF.addError(System.label.TimeOn_conflicts_messages);
                            }
                        }
                    }
                }
            }
        }*/
    }
    
    /***********
     * Method name  : populateAccountingPeriodOnTOT
     * Description  : This method will fetch the Accounting Period corresponding to TOT Record and populate the 
     *        : Accounting period look up on TOT record
     *        : When the ToT record is created or updated (before insert), it should search the “Accounting Periods” (AccP) records to find the one record where: 
        :  •  The “start date” of the ToT is on or after the “AP Start”-date on AccP
        :  •  The “end date” of the ToT is on or before the “AP End”-date on AccP
        :  •  The “Market” of the ToT is equal to the “Market” of the AccP
        :  The ToT records should then be linked to the AccP record found.
     * Return Type  : None.
     * Parameters   : List of ToT records
     ***********/
    public static void populateAccountingPeriodOnTOT(List < Time_Out_of_Territory__c > lstTOT) {

        List<String> marketOfTOT = new List<String>();
        Map<String,Map<String,String>> marketStartEndDateMap = new Map<String,Map<String,String>>();
        for (Time_Out_of_Territory__c tot: lstTOT) {
            marketOfTOT.add(tot.ZTS_Market__c);
        }

        List < ZTS_EU_Accounting_Period__c > lstAccPeriod = [SELECT ZTS_EU_AP_Start__c, ZTS_EU_AP_End__c, ZTS_EU_Market__c, Id FROM ZTS_EU_Accounting_Period__c WHERE ZTS_EU_Market__c IN: marketOfTOT];
        for(ZTS_EU_Accounting_Period__c accPeriod : lstAccPeriod){
            Map<String,String> startEndDateMap = new Map<String,String>();
            if(marketStartEndDateMap.get(accPeriod.ZTS_EU_Market__c) != null){
                startEndDateMap = marketStartEndDateMap.get(accPeriod.ZTS_EU_Market__c);
                startEndDateMap.put(accPeriod.ZTS_EU_AP_Start__c+'#'+accPeriod.ZTS_EU_AP_End__c,accPeriod.Id);
            } else {
                startEndDateMap.put(accPeriod.ZTS_EU_AP_Start__c+'#'+accPeriod.ZTS_EU_AP_End__c,accPeriod.Id);
            }
            marketStartEndDateMap.put(accPeriod.ZTS_EU_Market__c,startEndDateMap);
        }
        
        for (Time_Out_of_Territory__c tot: lstTOT) {
          if(marketStartEndDateMap.get(tot.ZTS_Market__c) != null){
              Map<String,String> stEnDateMap = marketStartEndDateMap.get(tot.ZTS_Market__c);
              Integer countOfAccountingPeriods = 0;
              for(String stEnDate : stEnDateMap.keySet()){
                String[] arrDates = stEnDate.split('#');
                if(arrDates.size() > 0){
                  Date stDate = Date.valueOf(arrDates[0]);
                  Date enDate = Date.valueOf(arrDates[1]);
                  if(tot.ZTS_EU_Start_Date__c >= stDate && tot.ZTS_EU_End_Date__c <= enDate){tot.ZTS_EU_Accounting_Period__c = stEnDateMap.get(stEnDate);} 
                  else if(tot.ZTS_EU_Start_Date__c >= stDate && tot.ZTS_EU_Start_Date__c <= enDate){countOfAccountingPeriods = countOfAccountingPeriods + 1; } 
                  else if(tot.ZTS_EU_End_Date__c >= stDate && tot.ZTS_EU_End_Date__c <= enDate){countOfAccountingPeriods = countOfAccountingPeriods + 1;}
                }
                if(countOfAccountingPeriods >= 2)
                  break;
                system.debug('***************countOfAccountingPeriods***********'+countOfAccountingPeriods);
         }
         system.debug('***************countOfAccountingPeriods***********'+countOfAccountingPeriods);
         /*if(countOfAccountingPeriods == 2){
             tot.addError('Time Off Territory cannot span two Accounting Periods. Please enter your Time off Territory separately for each Accounting Period.');
             
        }*/
         }
        }
        
    }
    
    
    /*
    Method name: calculateDayCount
    Arguments: List <Time_Out_of_Territory__c>
    Return type: Void
    */
    
    public static void calculateDayCount(List<Time_Out_of_Territory__c> lstTOT) {
        
        List<String> marketList = new List<String>();
        List<String> stateList = new List<String>();
        
        for(Time_Out_of_Territory__c tot: lstTOT){
            marketList.add(tot.ZTS_Market__c);
            if(tot.ZTS_EU_State_County__c != null){
                stateList.add(tot.ZTS_EU_State_County__c);
            }   
        }
        
        // consider the Holidays as per the market to calculate the number of holidays.
        List<Holiday__c> holidaysList = new List<Holiday__c>();
        Map<String, Set<Date>> holidayMap_State = new Map<String, Set<Date>>();
        Map<String, Set<Date>> defaultHolidayMap = new Map<String, Set<Date>>();
        
        holidaysList = [Select Id, Name, ZTS_EU_Holiday_Date__c, ZTS_EU_Market__c, ZTS_EU_Default_Holiday__c, 
                        ZTS_EU_Country__c, ZTS_EU_State_County__c from Holiday__c where 
                        ZTS_EU_Market__c in: marketList AND ZTS_EU_Is_Active__c = True AND 
                        ( (ZTS_EU_State_County__c in: stateList) OR (ZTS_EU_Default_Holiday__c = true) )];
        
        for(Holiday__c h: holidaysList){
            
            if(h.ZTS_EU_Default_Holiday__c){
                string defaultHolidayKey = h.ZTS_EU_Market__c;
                if(defaultHolidayMap.containsKey(defaultHolidayKey)){
                    defaultHolidayMap.get(defaultHolidayKey).add(h.ZTS_EU_Holiday_Date__c);
                }
                else{
                    defaultHolidayMap.put(defaultHolidayKey, new Set<Date>{h.ZTS_EU_Holiday_Date__c});
                }
            }
            else{
                string stateId = h.ZTS_EU_State_County__c;
                stateId = stateId.substring(0,15);
                string holidayKey_State = h.ZTS_EU_Market__c + '-' + stateId;
                if(holidayMap_State.containsKey(holidayKey_State)){
                    holidayMap_State.get(holidayKey_State).add(h.ZTS_EU_Holiday_Date__c);
                }
                else{
                    holidayMap_State.put(holidayKey_State, new Set<Date>{h.ZTS_EU_Holiday_Date__c});
                }
            }
            
        }      
        
        // consider the business hours as per the market and timezone to calculate the number of weekends.
        List<BusinessHours> businessHoursList = new List<BusinessHours>();
        Map<String, String> businessHoursMap = new Map<String, String>();
        businessHoursList = [SELECT Id, Name FROM BusinessHours WHERE Name IN: marketList];
        for(BusinessHours bh: businessHoursList){
            businessHoursMap.put(bh.Name, bh.Id);
        }
        
        
        for(Time_Out_of_Territory__c tot: lstTOT){
            
            date startdate = tot.ZTS_EU_Start_Date__c;
            Datetime startdatetime = datetime.newInstance(startdate.year(), startdate.month(),startdate.day(),12,0,0);
            date enddate = tot.ZTS_EU_End_Date__c;
            Datetime enddatetime = datetime.newInstance(enddate.year(), enddate.month(),enddate.day(),12,0,0);
            
            integer count = 0;
            
            for(integer i=0;i<=tot.ZTS_EU_Days_between_Start_and_End_date__c;i++){
                
                // if we need to include the end date in the calculation, it should be <= else !=
                if(startdatetime <= enddatetime){
                    
                    //code for checking whether the date is a weekend or not...
                    boolean isWeekDay = false;
                    if(businessHoursMap.get(tot.ZTS_Market__c) != null){
                        isWeekDay = BusinessHours.isWithin(businessHoursMap.get(tot.ZTS_Market__c), startdatetime);
                        system.debug('datetime: ' + startdatetime + ' -- isWeekDay: ' + isWeekDay); 
                    }
                    if(!isWeekDay){
                        count = count + 1;
                    }
                    else{
                        //code for checking whether the date is a holiday or not...
                        boolean isDefaultHoliday = false;
                        
                        // checking whether the date is present in the map of default holidays
                        if(defaultHolidayMap.get(tot.ZTS_Market__c) != null){
                            if(defaultHolidayMap.get(tot.ZTS_Market__c).contains(startdate)){
                                isDefaultHoliday = true;
                                system.debug('datetime: ' + startdatetime + ' -- isDefaultHoliday:- ' + isDefaultHoliday); 
                                count = count + 1;
                            }
                        }
                        
                        if(!isDefaultHoliday){
                            
                            string stateId = '';
                            if(tot.ZTS_EU_State_County__c != null){
                                stateId = tot.ZTS_EU_State_County__c;
                                stateId = stateId.substring(0,15);
                            }
                            string totKey_State = tot.ZTS_Market__c + '-' + stateId;
                            boolean isStateHoliday = false;
                            
                            // checking whether the date is present in the map of State-wise holidays
                            if(holidayMap_State.get(totKey_State) != null){
                                if(holidayMap_State.get(totKey_State).contains(startdate)){
                                    isStateHoliday = true;
                                    system.debug('datetime: ' + startdatetime + ' -- isHoliday(State):- ' + isStateHoliday); 
                                    count = count + 1;
                                }
                            }
                            
                        }
                            
                    }
                    
                    startdate = startdate.addDays(1);
                    startdatetime = startdatetime.addDays(1);
                } 
            }
            
            tot.ZTS_EU_Number_of_non_working_days_within__c = count;
        }
   
    }
    
    /*
    Method name: populateStateOnToT
    Arguments: List <Time_Out_of_Territory__c>
    Return type: Void
    */
    
    public static void populateStateOnToT(List<Time_Out_of_Territory__c> lstTOT) {
        
        List<String> userIdList = new List<String>();
        Map<String, String> userMap = new Map<String, String>();
        
        for(Time_Out_of_Territory__c tot: lstTOT){
            if(tot.ZTS_EU_Sales_Representative__c != null){
                userIdList.add(tot.ZTS_EU_Sales_Representative__c);
            }
            else{
                userIdList.add(tot.OwnerId);
            }   
        }
        
        List<User> userListFetch = new List<User>();
        
        userListFetch = [Select Id, ZTS_EU_State_County_Id__c from User where Id IN: userIdList AND ZTS_EU_Market__c != 'United States'];
        
        for(User u: userListFetch){
            userMap.put(u.Id, u.ZTS_EU_State_County_Id__c);
        }
         
        for(Time_Out_of_Territory__c tot: lstTOT){
            
            if(tot.ZTS_EU_Sales_Representative__c != null){
                tot.ZTS_EU_State_County__c = userMap.get(tot.ZTS_EU_Sales_Representative__c);
            }
            else{
                tot.ZTS_EU_State_County__c = userMap.get(tot.OwnerId);
            }
        }
        
        
    }
    
    
      
}
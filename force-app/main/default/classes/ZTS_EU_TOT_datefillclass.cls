/*
*Class Name - ZTS_EU_TOT_datefillclass
*Descirption - This class is used to fill the Start Time and End Time Date fields of ToT
*Author - Chandra Pinarouthu
*/
public class ZTS_EU_TOT_datefillclass {
public static boolean isrecursive = False ;
public static void filldatetime(List < Time_Out_of_Territory__c > lstTOT) {

//List<Time_Out_of_Territory__c> lstToT1 = new List<Time_Out_of_Territory__c>([Select Id,ZTS_EU_Duration__c,ZTS_EU_Start_Date__c,ZTS_EU_End_Date__c from Time_Out_of_Territory__c where id In : lstTOT AND ZTS_Market__c != 'United States']);
    List<Time_Out_of_Territory__c> lstToTupdate = new List<Time_Out_of_Territory__c>();    
    for(Time_Out_of_Territory__c tot : lstToT){
        if(tot.ZTS_EU_Duration__c == 'Full Day = 9 AM - 5 PM'){
            tot.ZTS_EU_Start_Date_Time__c = datetime.newInstance(tot.ZTS_EU_Start_Date__c.year(),tot.ZTS_EU_Start_Date__c.month(),tot.ZTS_EU_Start_Date__c.day(),09,00,00);
            tot.ZTS_EU_End_Date_Time__c = datetime.newInstance(tot.ZTS_EU_End_Date__c.year(),tot.ZTS_EU_End_Date__c.month(),tot.ZTS_EU_End_Date__c.day(),17,00,00);

            lstToTupdate.add(tot);
        }

        if(tot.ZTS_EU_Duration__c == 'AM = 9 AM to 1 PM'){
            tot.ZTS_EU_Start_Date_Time__c = datetime.newInstance(tot.ZTS_EU_Start_Date__c.year(),tot.ZTS_EU_Start_Date__c.month(),tot.ZTS_EU_Start_Date__c.day(),09,00,00);
            tot.ZTS_EU_End_Date_Time__c = datetime.newInstance(tot.ZTS_EU_End_Date__c.year(),tot.ZTS_EU_End_Date__c.month(),tot.ZTS_EU_End_Date__c.day(),13,00,00);

            lstToTupdate.add(tot);
        }

        if(tot.ZTS_EU_Duration__c == 'PM = 1 PM to 5 PM'){
            tot.ZTS_EU_Start_Date_Time__c = datetime.newInstance(tot.ZTS_EU_Start_Date__c.year(),tot.ZTS_EU_Start_Date__c.month(),tot.ZTS_EU_Start_Date__c.day(),13,00,00);
            tot.ZTS_EU_End_Date_Time__c = datetime.newInstance(tot.ZTS_EU_End_Date__c.year(),tot.ZTS_EU_End_Date__c.month(),tot.ZTS_EU_End_Date__c.day(),17,00,00);
            lstToTupdate.add(tot);
        }

     }
   }
}
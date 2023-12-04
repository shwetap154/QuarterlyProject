/*************************************************************************************
* Name          :    ZTS_EU_contypeUpdateonAff
* Description   :    This code is developed to update the Contact Type field on Affiliation
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
 5/6/2014       Chandra            Created

**************************************************************************************/
public class ZTS_EU_contypeUpdateonAff {
    /***********
        * Method name  : contypeUpdateonAff
        * Description  : This method will update the new value of Contact type whenever there is an update of
                         Contact Type on Contact record
        * Return Type  : None
        * Parameters   : List of new affiliations from Trigger and Map of Contact records
    ***********/
    public static void contypeUpdateonAff(List < Contact > lstCon, Map < Id, Contact > conMap) {

        List < ZTS_EU_Affiliations__c > affupdate = new List < ZTS_EU_Affiliations__c > ();
        List < Contact > VLstContact = new List < Contact > ([Select Id, ZTS_EU_Contact_type__c from Contact where Id In: lstCon AND ZTS_EU_Market__c != 'United States']);
        List < ZTS_EU_Affiliations__c > aff = new List < ZTS_EU_Affiliations__c > ([Select Id, ZTS_EU_Contact_type__c, ZTS_EU_Contact__c from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c IN: VLstContact AND ZTS_EU_Market_from_Parent__c != 'United States']);


        for (Contact con: VLstContact) {
            if (conMap.get(con.Id)
                .ZTS_EU_Contact_type__c != con.ZTS_EU_Contact_type__c) {
                for (ZTS_EU_Affiliations__c affnewval: aff) {
                    if (affnewval.ZTS_EU_Contact__c == con.id) {
                        affnewval.ZTS_EU_Contact_type__c = con.ZTS_EU_Contact_type__c;
                        affupdate.add(affnewval);
                    }
                }
            }

        }
        if (affupdate.size() > 0)
            update affupdate;
    }
}
/*************************************************************************************
* Name          :    ZTS_EU_BUG_AccountAffiliation
* Description   :    This code is developed to update the Species Speciality field when no Account Contact Affiliation
                     when no species speciality is selected after Contact is selcted for affiliation
 
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
 5/1/2014       Chandra            Created

**************************************************************************************/
public class ZTS_EU_UpdateSpeciesSpeciality {
/***********
        * Method name  : UpdateSpeciesSpeciality
        * Description  : This method will update the Species Speciality field on Account Contact Affiliation record selecting
                         Species Speciality of Contact 
                         
        * Return Type  : None
        * Parameters   : List of new affiliations from Trigger
    ***********/
    public static void UpdateSpeciesSpeciality(List<ZTS_EU_Affiliations__c> lstAccon){

    List<ZTS_EU_Affiliations__c> lstupdate = new List<ZTS_EU_Affiliations__c>();
    //Get the Affiliation record which is inserted and check if Species Speciality is filled for that recoerd or not
    List<ZTS_EU_Affiliations__c> afflst = new List<ZTS_EU_Affiliations__c>([select Id, ZTS_EU_Species_Speciality__c,ZTS_EU_Contact__r.ZTS_EU_Species_Specialty__c from ZTS_EU_Affiliations__c where Id IN : lstAccon AND ZTS_EU_Market_from_Parent__c != 'United States']);
    for(ZTS_EU_Affiliations__c aff : afflst){
        if(aff.ZTS_EU_Species_Speciality__c == null)
        aff.ZTS_EU_Species_Speciality__c = aff.ZTS_EU_Contact__r.ZTS_EU_Species_Specialty__c;
        lstupdate.add(aff);
}

        update lstupdate;
}
}
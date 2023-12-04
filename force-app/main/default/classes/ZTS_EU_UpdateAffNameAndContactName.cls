/*************************************************************************************
* Name          :    ZTS_EU_UpdateAffNameAndContactName .
* Description   :    Class called from Trigger for updation of Affiliation records.
                :    It is used to update the Status field of Account Contact Affiliation record
                     if Contact name(First name and Lst name for All market ) & Salutation(for Canada) is changed
                :    
* Author        :    Sohil Shah(CloudSense)
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
09/24/2015       Sohil Shah(CloudSense)                   Created


*/
public class ZTS_EU_UpdateAffNameAndContactName
{
    
    public static void updateAffNameOnContactNameUpdate(List<Contact> newlyUpdatedContactList)
    {   
        boolean myFlag = false;
        if(myFlag == false)
        {
            Map <Id,List<ZTS_EU_Affiliations__c>> mapConidAndAff=new Map<Id,List<ZTS_EU_Affiliations__c>>();
            List<ZTS_EU_Affiliations__c> modifiedList=new List<ZTS_EU_Affiliations__c>();
            for(ZTS_EU_Affiliations__c aff : [select ZTS_EU_Contact__r.id,ZTS_EU_Affiliation_Status__c, Name from ZTS_EU_Affiliations__c where ZTS_EU_Contact__r.id IN :newlyUpdatedContactList AND ZTS_EU_Market_from_Parent__c != 'United States'])
            {
                list<ZTS_EU_Affiliations__c> listofAff = new List<ZTS_EU_Affiliations__c>();
                if(mapConidAndAff.get(aff.ZTS_EU_Contact__r.id)!= null){
                    listofAff = mapConidAndAff.get(aff.ZTS_EU_Contact__r.id);
                    listofAff.add(aff);
                    mapConidAndAff.put(aff.ZTS_EU_Contact__r.id,listofAff);
                } else {
                    listofAff.add(aff);
                    mapConidAndAff.put(aff.ZTS_EU_Contact__r.id,listofAff);
                }      
            }
            for(Contact con: newlyUpdatedContactList)
            {
                if(mapConidAndAff.containsKey(con.id)){
                    for(ZTS_EU_Affiliations__c affiliation: mapConidAndAff.get(con.id))
                    {
                        String affName = affiliation.Name;
                        System.debug('affName-1--------'+affName);
                        if(con.ZTS_EU_Market__c == 'Canada')
                        {
                            System.debug('If Canada----');
                            affName = affName.split('@')[1];
                            System.debug('affName-2--------'+affName);
                            affName = con.title + ' '  + con.Full_Contact_Name__c + ' @ ' + affName ;
                            System.debug('affName-3--------'+affName);
                            if(affName.length() > 77)
                            {
                                System.debug('if length > 77');
                                affName = affName.subString(0,76) + '...';
                                System.debug('if length > 77---affname'+affName);
                            }                                   
                            
                        }
                        else
                        {                                   
                            System.debug('If not Canada----');
                            affName = affName.split('@')[1];
                            affName = con.Name + '@' + affName;
                            System.debug('affName-1--------'+affName);
                        }
                        affiliation.Name = affName;
                        System.debug('Final affName'+affName);          
                    modifiedList.add(affiliation);
                    }
                }   
            }
            myFlag = true;
            List<Database.SaveResult> results=Database.update(modifiedList);
            ZTS_EU_Logger.error(results, 'ZTS_EU_Affiliation_Update-UpdateContactAffilation');  
            
        }       
    }
   
}
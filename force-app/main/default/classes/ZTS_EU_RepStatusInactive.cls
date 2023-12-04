public class ZTS_EU_RepStatusInactive{
    public static void cannotinactivate(List<Contact> lstCon, Map<id,Contact> mapAcc, Map<Id,Contact> mapCon){

        Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
        Primary_Contact_Inactive_Profile_List__c customSetting = Primary_Contact_Inactive_Profile_List__c.getValues('Profile Names');
        Primary_Contact_Inactive_Profile_List__c customSetting1 = Primary_Contact_Inactive_Profile_List__c.getValues('Profile Names 1');
        Primary_Contact_Inactive_Profile_List__c customSetting2 = Primary_Contact_Inactive_Profile_List__c.getValues('Profile Names 2');       
        
        String profiles = customSetting.Profile__c;
        String profiles1 = customSetting1.Profile__c;
        string profiles2 = customSetting2.Profile__c;
         
        System.debug('profiles -----------'+profiles); 
         System.debug('boolean----------'+profiles.contains(ProfileName.Name)); 
            if(!(profiles.contains(ProfileName.Name) || (profiles1.contains(ProfileName.Name))|| (profiles2.contains(ProfileName.Name)))){
            Map<Id, Account> mapAccount = new Map<Id,Account>([Select Id, ZTS_EU_Primary_Contact__c,Name from Account where ZTS_EU_Primary_Contact__c IN : mapAcc.Keyset() AND ZTS_EU_Market__c != 'United States']); 
            for(Contact Con: lstCon){
                if(mapAccount != null &&  mapAccount.get(Con.AccountId) != null){  
                    if((Con.ZTS_EU_Rep_Contact_Status__c == 'Inactive' && mapCon.get(Con.id).ZTS_EU_Rep_Contact_Status__c == 'Active') && Con.Id == mapAccount.get(Con.AccountId).ZTS_EU_Primary_Contact__c){
                        Con.ZTS_EU_Rep_Contact_Status__c.adderror('Cannot make a primary contact inactive');
                    }
                }
            }
        }
    }
}
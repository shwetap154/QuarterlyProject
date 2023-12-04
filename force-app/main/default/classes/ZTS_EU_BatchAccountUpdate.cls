global class ZTS_EU_BatchAccountUpdate implements Database.Batchable<sObject>
{   
    global Database.queryLocator start(Database.BatchableContext BC)
    {   
        string query= 'Select Id, Name,ZTS_EU_Address_Line_1__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,ZTS_EU_Address_Line_4__c,ZTS_EU_City__c,ZTS_EU_City_Country__c,ZTS_EU_Commune_Lookup__c,ZTS_EU_Country__c,ZTS_EU_Primary_Address__c from Account';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> acclst)
    {   
        List<Account> accountList = new List<Account>();
        List<Account> accountListToUpdate = new List<Account>();
        accountList = [Select Id, Name,ZTS_EU_Address_Line_1__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,ZTS_EU_Address_Line_4__c,ZTS_EU_City__c,ZTS_EU_City_Country__c,ZTS_EU_Commune_Lookup__c,ZTS_EU_Country__c,ZTS_EU_Primary_Address__c from Account where id IN:acclst AND ZTS_EU_Market__c != 'United States'];
        for(Account acc: accountList)
        {
            accountListToUpdate.add(acc);
        }
        // Sync Account and Contact primary addresses
        PrimatyAddressUpdate.ContactsUpdateOnPrimaryAddressUpdate(accountListToUpdate);
        
        // Update Account contact affiliation record with modified account name
        Map <Id,List<ZTS_EU_Affiliations__c>> mapAccidAndAff=new Map<Id,List<ZTS_EU_Affiliations__c>>();

        for(ZTS_EU_Affiliations__c aff : [select ZTS_EU_Account__r.id,ZTS_EU_Account__r.Name,ZTS_EU_Affiliation_Status__c, Name from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.id IN :accountListToUpdate AND ZTS_EU_Market_from_Parent__c != 'United States'])
        {
            list<ZTS_EU_Affiliations__c> listofAff = new List<ZTS_EU_Affiliations__c>();
            if(mapAccidAndAff.get(aff.ZTS_EU_Account__r.id)!= null){
                listofAff = mapAccidAndAff.get(aff.ZTS_EU_Account__r.id);
                listofAff.add(aff);
                mapAccidAndAff.put(aff.ZTS_EU_Account__r.id,listofAff);
            } else {
                listofAff.add(aff);
                mapAccidAndAff.put(aff.ZTS_EU_Account__r.id,listofAff);
            }
        } 


        List<ZTS_EU_Affiliations__c> modifiedList=new List<ZTS_EU_Affiliations__c>();
        for(Account eachAccount: accountListToUpdate){                                       
            if(mapAccidAndAff.containsKey(eachAccount.id)){
                for(ZTS_EU_Affiliations__c affiliation:mapAccidAndAff.get(eachAccount.id))
                {                                                                               
                    //Sohil shah Update all affiliated records Name if Account name modifies
                    String affName = affiliation.Name;
                    affName = affName.split('@')[0];
                    affName = affName + ' @ ' + affiliation.ZTS_EU_Account__r.Name;                 
                    affiliation.Name = affName;
                    // EOC Sohil Shah -Update all affiliated records Name if Account name modifies
                    modifiedList.add(affiliation);
                } 
            }
        }
        System.debug('modifiedList----------'+modifiedList);
        Database.update(modifiedList,false);

    }
    global void finish(Database.BatchableContext BC)
    {
        
    }   
}
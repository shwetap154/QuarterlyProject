/*************************************************************************************
* Name          :    updatePrimaryAddonAccount
* Description   :    This clas is called on click of "Make Primary Address" button on
Address page which will update address fields on Account/Contact
* Author        :    Chandra

Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
5/8/2014       Chandra            Created
3-Sep-2014     Shreyas            Added the field 'ZTS_EU_City_Country__c' in 'updatePrimaryaddress' method for CLAR.
17-Mar-2015    Shreyas            Added the field 'Address line 4' for accounts.
21-May-2015    Shreyas            Added the field 'District' field for accounts/contact/address.
08-Jun-2015    Shreyas            Added the field 'Commune' field for accounts/contact/address.
18-Sep-2020    Alex               Updated logic to toggle US Primary Addresses as well as INT Primary Addresses
22-Sep-2020    Taylor             Fixed US query to only search for US Addresses (50001 SOQL Error)
**************************************************************************************/
global class ZTS_EU_updatePrimaryAddonAccount
{

    static final String MARKET_CHECK = 'United States';

    @AuraEnabled
    webservice static void updatePrimaryaddress(Id addressId)
    {
        List<Address__c> addresses = new List<Address__c>();

        List<Account> acc = new List<Account>();
        List<Contact> con = new List<Contact>();
        List<SObject> objectsToUpdate = new List<SObject>();

        addresses = [   SELECT Id, ZTS_US_Primary__c,ZTS_EU_Is_Account__c,ZTS_EU_Is_Contact__c,ZTS_EU_Account__c,ZTS_EU_Contact__c,Name
                ,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,Address_Line_4__c,ZTS_EU_City__c,ZTS_EU_City_Country__c
                ,Zip_Postal_Code__c,ZTS_EU_District__c,ZTS_EU_State_County__c,ZTS_EU_Country__c,ZTS_EU_Commune_Lookup__c, ZTS_EU_Phone__c
                ,ZTS_EU_Market_from_Parent__c
        FROM Address__c
        WHERE Id = :addressId
        WITH SECURITY_ENFORCED
        ];

        if( addressId != null && addresses[0].ZTS_EU_Market_from_Parent__c == 'United States' )
        {
            Address__c currentAddr = addresses[0];
            addresses.addAll( [SELECT ZTS_US_Primary__c, ZTS_EU_Market_from_Parent__c
            FROM Address__c
            WHERE ZTS_EU_Account__c = :currentAddr.ZTS_EU_Account__c
            AND Id != :addressId
            AND ZTS_EU_Market_from_Parent__c = 'United States'
            WITH SECURITY_ENFORCED
            ]
            );
        }
        for( Address__c relatedAddress : addresses )
        {
            if(relatedAddress.Id == addressId) {
                if(relatedAddress.ZTS_EU_Market_from_Parent__c == MARKET_CHECK) {
                    relatedAddress.ZTS_US_Primary__c = true;
                    objectsToUpdate.add(relatedAddress);
                }
                else {

                    if(relatedAddress.ZTS_EU_Is_Account__c == True){
                        Account a = new Account(Id = relatedAddress.ZTS_EU_Account__c);
                        a.ZTS_EU_Primary_Address__c = relatedAddress.Id;
                        a.ZTS_EU_Address_Line_1__c = relatedAddress.Name;
                        a.ZTS_EU_Address_Line_2__c = relatedAddress.ZTS_EU_Address_Line_2__c;
                        a.ZTS_EU_Address_Line_3__c = relatedAddress.ZTS_EU_Address_Line_3__c;
                        a.ZTS_EU_Address_Line_4__c = relatedAddress.Address_Line_4__c;
                        a.ZTS_EU_City__c = relatedAddress.ZTS_EU_City__c;
                        a.ZTS_EU_City_Country__c = relatedAddress.ZTS_EU_City_Country__c;
                        a.ZTS_EU_State_County__c = relatedAddress.ZTS_EU_State_County__c;
                        a.ZTS_EU_Zip_Postal_Code__c = relatedAddress.Zip_Postal_Code__c;
                        a.ZTS_EU_District__c = relatedAddress.ZTS_EU_District__c;
                        a.ZTS_EU_Commune_Lookup__c= relatedAddress.ZTS_EU_Commune_Lookup__c;
                        a.ZTS_EU_Country__c = relatedAddress.ZTS_EU_Country__c;
                        if(relatedAddress.ZTS_EU_Phone__c != null && relatedAddress.ZTS_EU_Phone__c != '')
                            a.ZTS_EU_Main_Phone__c = relatedAddress.ZTS_EU_Phone__c;
                        objectsToUpdate.add(a);
                    }

                    if(relatedAddress.ZTS_EU_Is_Contact__c == True){
                        Contact c = new Contact(Id = relatedAddress.ZTS_EU_Contact__c);
                        c.ZTS_EU_Primary_Address__c = relatedAddress.Id;
                        c.ZTS_EU_Address_Line_1__c = relatedAddress.Name;
                        c.ZTS_EU_Address_Line_2__c = relatedAddress.ZTS_EU_Address_Line_2__c;
                        c.ZTS_EU_Address_Line_3__c = relatedAddress.ZTS_EU_Address_Line_3__c;
                        c.ZTS_EU_City__c = relatedAddress.ZTS_EU_City__c;
                        c.ZTS_EU_City_Country__c = relatedAddress.ZTS_EU_City_Country__c;
                        c.ZTS_EU_State_County__c = relatedAddress.ZTS_EU_State_County__c;
                        c.ZTS_EU_Zip_Postal_Code__c = relatedAddress.Zip_Postal_Code__c;
                        c.ZTS_EU_Country__c = relatedAddress.ZTS_EU_Country__c;
                        c.ZTS_EU_Private_Phone__c = relatedAddress.ZTS_EU_Phone__c;
                        c.ZTS_EU_District__c = relatedAddress.ZTS_EU_District__c;
                        c.ZTS_EU_Commune_Lookup__c= relatedAddress.ZTS_EU_Commune_Lookup__c;
                        objectsToUpdate.add(c);
                    }

                }
            }
            else {
                if(relatedAddress.ZTS_EU_Market_from_Parent__c == MARKET_CHECK) {
                    relatedAddress.ZTS_US_Primary__c = false;
                    relatedAddress.ZTS_GL_Unique_Primary_Address_Key__c = null;
                    objectsToUpdate.add(relatedAddress);
                }
            }


        }
        try {
            update objectsToUpdate;
        }
        catch(DMLException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug('dex.getDmlMessage(i): '+dex.getDmlMessage(i));
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }

    }
}
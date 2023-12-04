public class ZTS_EU_accUpdateClass {
    List < Contact > listContact = new List < Contact > ();
    Map < id, Account > mapIdAcc = new Map < id, Account > ();
    public void UpdateAccOnCont(List < ZTS_EU_Affiliations__c > Triggernew, Map < id, ZTS_EU_Affiliations__c > triggerOldMap, boolean isUpdate, boolean isInsert) {
        for (ZTS_EU_Affiliations__c oAff: triggerNew) {
            mapIdAcc.put(oAff.ZTS_EU_Account__c, null);
            system.debug('*' + oAff.ZTS_EU_Account__c);
        }
        for (Account oAcc: [SELECT id, name, Phone, ZTS_EU_Address_Line_1__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,ZTS_EU_City__c,ZTS_EU_State_County__c,ZTS_EU_Country__c,ZTS_EU_Main_Phone__c, ZTS_EU_Zip_Postal_Code__c FROM Account WHERE ID IN: mapIdAcc.keyset() AND ZTS_EU_Market__c != 'United States']) {
            mapIdAcc.put(oAcc.id, oAcc);
        }
        for (ZTS_EU_Affiliations__c oAff: Triggernew) {
          /*  if (isInsert) {
                if (oAff.ZTS_EU_Primary_Account__c) {
                    Contact oCon = new Contact(id = oAff.ZTS_EU_Contact__c, AccountId = mapIdAcc.get(oAff.ZTS_EU_Account__c).id, ZTS_EU_City__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_City__c, ZTS_EU_Address_Line_1__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Address_Line_1__c, ZTS_EU_Address_Line_2__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Address_Line_2__c, ZTS_EU_Address_Line_3__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Address_Line_3__c, ZTS_EU_State_County__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_State_County__c, ZTS_EU_Country__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Country__c, ZTS_EU_Zip_Postal_Code__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Private_Phone__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Main_Phone__c);
                    listContact.add(oCon);
                    system.debug('**' + listContact);
                }
            }*/
            if (isUpdate) {
                if ((triggerOldMap.get(oAff.id).ZTS_EU_Account__c) <> (oAff.ZTS_EU_Account__c)) {
                    if (oAff.ZTS_EU_Primary_Account__c) {
                        Contact oCon = new Contact(id = oAff.ZTS_EU_Contact__c
                                                   , AccountId = mapIdAcc.get(oAff.ZTS_EU_Account__c).id
                                                   , ZTS_EU_City__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_City__c
                                                   , ZTS_EU_Address_Line_1__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Address_Line_1__c
                                                   , ZTS_EU_Address_Line_2__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Address_Line_2__c
                                                   , ZTS_EU_Address_Line_3__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Address_Line_3__c
                                                   , ZTS_EU_State_County__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_State_County__c
                                                   , ZTS_EU_Country__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Country__c
                                                   , ZTS_EU_Zip_Postal_Code__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Zip_Postal_Code__c
                                                   ,ZTS_EU_Private_Phone__c = mapIdAcc.get(oAff.ZTS_EU_Account__c).ZTS_EU_Main_Phone__c);
                        listContact.add(oCon);
                        system.debug('**' + listContact);
                    }
                }


            }

        }

        update listContact;
    }
}
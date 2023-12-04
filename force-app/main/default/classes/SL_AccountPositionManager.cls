/**
* @ClassName    : SL_AccountPositionManager 
* @JIRATicket   : LIGHTNI-1561
* @CreatedOn    : 05 sept 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : manager class for the account posiion object.
*/
public class SL_AccountPositionManager {

    @InvocableMethod(label='mark account position as inactive and delete bring offline record')
    public static void markAccountPositionInactive(List<Id> lstAccountId) {
        List<ZTS_EU_Account_Position__c> lstAccountPosition = [SELECT Id, ZTS_EU_Active__c, ZTS_EU_Bring_offline__c 
                                                                FROM ZTS_EU_Account_Position__c
                                                                WHERE ZTS_EU_Active__c = true
                                                                AND ZTS_EU_Account__c IN :lstAccountId
                                                                AND ZTS_EU_Market__c != 'United States'];
        for (ZTS_EU_Account_Position__c objAccPos : lstAccountPosition) {
            objAccPos.ZTS_EU_Active__c = false;
            objAccPos.ZTS_EU_Bring_offline__c = false;
        }
        if(lstAccountPosition.size() > 0)
            update lstAccountPosition;

        // delete bring offline
        List<ZTS_EU_Bring_Offline__c> lstBringOffline = new List<ZTS_EU_Bring_Offline__c>();
        lstBringOffline = [SELECT Id FROM ZTS_EU_Bring_Offline__c WHERE ZTS_EU_Account__c IN :lstAccountId];

        if(lstBringOffline.size() > 0)
            delete lstBringOffline;
    }
}
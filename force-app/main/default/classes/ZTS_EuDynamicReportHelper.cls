public class ZTS_EuDynamicReportHelper{
    
    //This method filters those accounts (and their corresponding sales recprds) where the currency is not same as the currency of the context user 
    public static List<ZTS_EU_Sales__c> filterSalesRecordOnCurrency(List<ZTS_EU_Sales__c> queriedList){
        String currentUsersCurrency = UserInfo.getDefaultCurrency();
        // map of Account id versus list of accounts
        map<Id,List<ZTS_EU_Sales__c>> mapAccIdLstSales = new map<Id,List<ZTS_EU_Sales__c>>();
        List<ZTS_EU_Sales__c> filteredSales = new List<ZTS_EU_Sales__c>();
        
        // grouping sales record on the account id
        for(ZTS_EU_Sales__c sales : queriedList){
            if(mapAccIdLstSales.containsKey(sales.ZTS_EU_Account__c)){
                mapAccIdLstSales.get(sales.ZTS_EU_Account__c).add(sales);
            }
            else{
                mapAccIdLstSales.put(sales.ZTS_EU_Account__c , new List<ZTS_EU_Sales__c>{sales});
            }
        }
        
        for(ZTS_EU_Sales__c sales : queriedList){
            if(sales.CurrencyIsoCode != currentUsersCurrency){
                mapAccIdLstSales.remove(sales.ZTS_EU_Account__c);
            }
        }
        // adding up the sales records for the remaining accounts
        for(List<ZTS_EU_Sales__c> lstSales : mapAccIdLstSales.values()){
            filteredSales.addAll(lstSales);
        }
        return filteredSales;
    }
}
public class PIT_OrderTriggerHandler {

    public void onBeforeInsert(list<PIT_Order__c> orders) {
        set<String> productIds = new set<String>();
        set<String> territoryIds = new set<String>();
        map<String, PIT_Budget_Allocation__c> allocMap = new map<String, PIT_Budget_Allocation__c>(); //indexed by extId
        Set<Id> sTerritoryIds = new Set<Id>();
        for(PIT_Order__c order: orders) {
            sTerritoryIds.add(order.PIT_Territory__c);
        }
        
        Map<Id, ZTS_EU_Territory__c> mId2Ter = new Map<Id, ZTS_EU_Territory__c>([select id, Name, ZTS_EU_Type__c, (Select Name, ZTS_EU_Employee__r.FirstName, ZTS_EU_Employee__r.Lastname, ZTS_EU_Employee__c, ZTS_EU_Territory__c, ZTS_Start_Date__c, ZTS_End_Date__c From Positions__r order by PIT_Is_Active__c desc) from ZTS_EU_Territory__c where Id in :sTerritoryIds AND ZTS_EU_Market__c = 'United States']);
        
        
        for(PIT_Order__c order: orders) {
            productIds.add(order.PIT_Product__c);
            territoryIds.add(order.PIT_Territory__c);
            PIT_Budget_Allocation__c alloc = new PIT_Budget_Allocation__c();
            alloc.PIT_Fiscal_Year__c = order.PIT_Registration_Date__c.year();
            if(mId2Ter.get(order.PIT_Territory__c).ZTS_EU_Type__c != 'Territory'){
                order.PIT_Territory__c.addError('Orders needs to point Territory to which they belong (not Region, nor Area)');
            } else {
                alloc.PIT_Territory__c = order.PIT_Territory__c;
            }
            alloc.PIT_External_ID__c = String.valueOf(order.PIT_Territory__c) + String.valueOf(order.PIT_Registration_Date__c.year());
            alloc.PIT_Allocation_Type__c = 'Territory';
            if(mId2Ter.get(order.PIT_Territory__c).Positions__r != null && mId2Ter.get(order.PIT_Territory__c).Positions__r.size() > 0){
                if(mId2Ter.get(order.PIT_Territory__c).Positions__r[0].ZTS_EU_Employee__c != null){
                    alloc.PIT_Responsible__c = mId2Ter.get(order.PIT_Territory__c).Positions__r[0].ZTS_EU_Employee__c;
                } 
            } else {
                alloc.PIT_Responsible__c = null;    
            }
            alloc.Name = mId2Ter.get(order.PIT_Territory__c).Name + ' - ' + order.PIT_Registration_Date__c.year();
            allocMap.put(alloc.PIT_External_ID__c, alloc);
        }
        
        Database.upsert(allocMap.values(), PIT_Budget_Allocation__c.PIT_External_ID__c);
        
        map<Id, ZTS_EU_Species_Product__c> productMap = new map<Id, ZTS_EU_Species_Product__c>([select Id, ZTS_US_Cost__c from ZTS_EU_Species_Product__c where Id in :productIds]);
        map<Id, ZTS_EU_Territory__c> territoryMap = new map<Id, ZTS_EU_Territory__c>([select Id, ZTS_EU_Parent_Territory__c, ZTS_EU_Parent_Territory__r.ZTS_EU_Parent_Territory__c from ZTS_EU_Territory__c where Id in :territoryIds AND ZTS_EU_Market__c = 'United States']);
         
        for(PIT_Order__c order: orders) {
            ZTS_EU_Species_Product__c prod = productMap.get(order.PIT_Product__c);
            ZTS_EU_Territory__c terr = territoryMap.get(order.PIT_Territory__c);
            PIT_Budget_Allocation__c alloc = allocMap.get(String.valueOf(order.PIT_Territory__c) + String.valueOf(order.PIT_Registration_Date__c.year()));
            order.PIT_Total_Cost__c = order.PIT_Quantity__c * prod.ZTS_US_Cost__c;
            order.PIT_Area__c = terr.ZTS_EU_Parent_Territory__c;
            order.PIT_Region__c = terr.ZTS_EU_Parent_Territory__r.ZTS_EU_Parent_Territory__c;
            order.PIT_Budget_Allocation_Territory__c = alloc.Id;
        }
    }
}
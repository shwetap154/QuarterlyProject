public class PIT_BudgetAllocationTriggerHandler {

    public void onBeforeInsert(list<PIT_Budget_Allocation__c> allocs) {
        for(PIT_Budget_Allocation__c alloc: allocs) {
            alloc.PIT_External_ID__c = String.valueOf(alloc.PIT_Territory__c) + String.valueOf(alloc.PIT_Fiscal_Year__c);
        }
    }
    
    public void onBeforeUpdate(list<PIT_Budget_Allocation__c> allocs) {
        for(PIT_Budget_Allocation__c alloc: allocs) {
            alloc.PIT_External_ID__c = String.valueOf(alloc.PIT_Territory__c) + String.valueOf(alloc.PIT_Fiscal_Year__c);
        }
    }

    /*****START - Commented to optmize the code to avoid the FOR inside FOR method calling.******/
    /*public static void updateBudgetOwner(List<ZTS_EU_Position__c> uts)
    {
        Map<id,id> utmap = new Map<id,id>();
        List<PIT_Budget_Allocation__c> allocs = new List<PIT_Budget_Allocation__c>();

        for(ZTS_EU_Position__c ut : uts)
        {
            if(ut.ZTS_EU_Territory__c!=null && ut.ZTS_PrimaryUser__c==true)
                utmap.put(ut.ZTS_EU_Territory__c,ut.ZTS_EU_Employee__c);
        }
        List<PIT_Budget_Allocation__c> bdgts = [select id,ownerId, PIT_Responsible__c,PIT_Territory__c from PIT_Budget_Allocation__c where PIT_Territory__c IN:utmap.keyset()];

       for(PIT_Budget_Allocation__c budget : bdgts)
       {
           budget.PIT_Responsible__c = utmap.get(budget.PIT_Territory__c);
           allocs.add(budget);
       }
       update allocs;
    }*/
    /*****END - Commented to optmize the code to avoid the FOR inside FOR method calling.******/

    public static void updateBudgetOwner(Map<Id, ZTS_EU_Position__c> mapUserTerritoryOld, 
                                            Map<Id, ZTS_EU_Position__c> mapUserTerritoryNew )
    {
        Map<id,id> utmap = new Map<id,id>();
        List<PIT_Budget_Allocation__c> allocs = new List<PIT_Budget_Allocation__c>();

        for(ZTS_EU_Position__c objUT : mapUserTerritoryNew.values())
        {
            if(mapUserTerritoryOld.get(objUT.Id).ZTS_EU_Employee__c != objUT.ZTS_EU_Employee__c  
                && objUT.ZTS_EU_Employee__c !=null && (objUT.ZTS_EU_Territory__c!=null && objUT.ZTS_PrimaryUser__c==true))
                utmap.put(objUT.ZTS_EU_Territory__c, objUT.ZTS_EU_Employee__c);
        }

        List<PIT_Budget_Allocation__c> bdgts = [select id,ownerId, PIT_Responsible__c,PIT_Territory__c from PIT_Budget_Allocation__c where PIT_Territory__c IN:utmap.keyset()];

        for(PIT_Budget_Allocation__c budget : bdgts)
        {
            budget.PIT_Responsible__c = utmap.get(budget.PIT_Territory__c);
            allocs.add(budget);
        }
        update allocs;
    }
    
}
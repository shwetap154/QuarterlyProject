public without sharing class PIT_BudgetAllocationController {
    
    public AllocationEntry statTM   {get; set;}
      
    public class AllocationEntry{
        public string lastName      {get; set;}
        public string firstName     {get; set;}
        public string position      {get; set;}
        public Double allocation   {get; set;}
        public Double consumed     {get; set;}
        public Double remaining    {get; set;}
        public Double Shipped      {get; set;}
        public Double completed    {get; set;}
        public Double AdjBudget    {get; set;}
        public Double Adjustment    {get; set;}
        public Double allocBelow   {get; set;}
        public String alocId        {get; set;}
        public boolean selected     {get; set;}
        public Id territoryId       {get; set;}
        public Id territoryRespId   {get; set;}
        public list<AllocationSubentry> subAllocs   {get;set;}
        public String subData;  
        public String subDataComplex {get; set;}
        
        public String getSubData() {
            String result = ' ';                 
            if(subAllocs != null ){
                result = '[';
                for(Integer i = 0 ; i < this.subAllocs.size(); i++) {
                    result += '["' + subAllocs[i].name + '",' + subAllocs[i].remaining + ',' + subAllocs[i].consumed + ']';
                    if(this.subAllocs.size() > 1 && i < this.subAllocs.size() - 1) {
                        result += ',';
                    }   
                }
                result += ']';
            }
            return result;
        }
    }
    
    public string curSymbol {get; set;}
    
    public static string calcCurSymbol(){
        string symbol = ' ';
        if(Userinfo.getDefaultCurrency() == 'USD'){
            symbol = '$';
        } else if(Userinfo.getDefaultCurrency() == 'JPY' || Userinfo.getDefaultCurrency() == 'CNY'){
            symbol = '�';
        } else if(Userinfo.getDefaultCurrency() == 'EUR'){
            symbol = '�';
        } else if(Userinfo.getDefaultCurrency() == 'RUB'){
            symbol = 'RUB ';
        } else if(Userinfo.getDefaultCurrency() == 'GBP'){
            symbol = '�';
        }    
        return symbol;
    }
    
    //stores subregion data for every alocation entry
    public class AllocationSubentry{
        public string name          {get; set;}
        public Double allocation   {get; set;}
        public Double consumed     {get; set;}
        public Double remaining    {get; set;}
        public Double Shipped      {get; set;}
        public Double completed    {get; set;}
        public Double AdjBudget    {get; set;}
        public Double Adjustment    {get; set;}
    }
    
    public boolean isRSD       {get; set;}
    public boolean isAM        {get; set;}
    public boolean isTM        {get; set;}
    public boolean multiMode   {get; set;}
    public boolean initLoad    {get; set;}
    public boolean noAccess    {get; set;}
    public Id contextId        {get; set;}
    public Id impersId         {get; set;}
    public string selyear      {get; set;}
    public List<SelectOption> contextList   {get; set;}
    public ZTS_EU_Position__c[] usTer  {get; set;}
    public ZTS_EU_Position__c curRec           {get; set;}
    public Double totalBudget {get; set;}
    
    public string getCurYear(){
        return string.valueOf(System.today().year());
    } 
    
    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('2013','2013'));
        options.add(new SelectOption('2014','2014'));
        options.add(new SelectOption('2015','2015'));
        options.add(new SelectOption('2016','2016'));
        return options;
    }
    
    public AllocationEntry[] AMs    {get; set;}      
    
    public PageReference changeContext(){
        totalBudget = 0;
        System.debug('XXX current context Id : ' + contextId + ' CURrEC: ' + curRec);
        for(ZTS_EU_Position__c t1 : usTer){
            System.debug('XXX0 current rec: ' + t1.Id); 
            if(t1.Id == contextId){
                System.debug('XXX0 found' + t1.Id);
                curRec = t1;
                break;
            }
        }
        System.debug('XXX2 current context Id : ' + contextId + ' CURrEC: ' + curRec);
        if(curRec.ZTS_EU_Territory__r.ZTS_EU_Type__c == 'Region'){
            isRSD = true;
            isAM = false;
            isTM = false;
        } else if(curRec.ZTS_EU_Territory__r.ZTS_EU_Type__c == 'Area'){
            isAM = true;
            isRSD = false;
            isTM = false;
        } else if(curRec.ZTS_EU_Territory__r.ZTS_EU_Type__c == 'Territory'){
            isAM = false;
            isRSD = false;
            isTM = true;
        }
        refreshData();
        if(initLoad){
            return null;
        } else {
            String refUrl = '/apex/PIT_BudgetAllocation?contextID='+contextId;
            if(impersId != null){
                refUrl = refUrl + '&impersonationId=' + impersId;
            }
            PageReference pageRef = new PageReference(refUrl);
            return pageRef.setRedirect(true);   
        }
        
    }
    
    public PIT_BudgetAllocationController(){
        //isRSD = true;
        initLoad = true;
        contextList = new List<SelectOption>();
        impersId = ApexPages.CurrentPage().getParameters().get('impersonationID');
        Id contextParId = ApexPages.CurrentPage().getParameters().get('contextID');
        contextId = impersId;
        if(contextParId != null){
            contextId = contextParId; 
        }
        curSymbol = calcCurSymbol();
        selYear = String.valueOf(System.today().year());
        Integer iSelYear = Integer.valueOf(selYear);
        totalBudget = 0;
        isRSD = false;
        isAM = false;
        isTM = false;
        multiMode = false;
        usTer = [Select ZTS_EU_Employee__r.Name, ZTS_EU_Territory__c,ZTS_EU_Territory__r.Name, ZTS_EU_Territory__r.ZTS_EU_Type__c ,ZTS_Start_Date__c,ZTS_End_Date__c,ZTS_EU_Employee__c,Id From ZTS_EU_Position__c where ZTS_EU_Employee__c = :Userinfo.getUserId() or Id = :impersId order by PIT_Is_Active__c desc];
        if(usTer.size() > 0){
            if(usTer.size() > 1){
                multiMode = true;
            } 
            boolean found = false;
            for(ZTS_EU_Position__c t1 : usTer){
                if(contextId == null){
                    contextId = t1.Id;
                }
                string name;
                if(t1.ZTS_EU_Territory__r.ZTS_EU_Type__c == 'Region'){
                    name = 'Regional Sales Director: ';
                } else if(t1.ZTS_EU_Territory__r.ZTS_EU_Type__c == 'Area'){
                    name = 'Area Business Manager: ';
                } else {
                    name = 'Territory Manager: ';
                }
                name = name + t1.ZTS_EU_Territory__r.Name;
                if(t1.ZTS_EU_Employee__c != Userinfo.getUserId()){
                    name = name + ' [' + t1.ZTS_EU_Employee__r.Name + ']';
                }
                contextList.add(new SelectOption(t1.Id, name));
            }
            changeContext();
        } else {           
            noAccess = true;
        }
    }
    
    public PageReference refreshData() {
        //TODO: get data from DB
        //parameter: selYear
        Integer iSelYear = Integer.valueOf(selYear);
        AMs = new AllocationEntry[]{};
        Set<Id> sIdsTerritory = new Set<Id>();
        PIT_Budget_Allocation__c[] pbAloc = [Select Name, PIT_Completed_Orders_Value__c,PIT_Remaining__c, PIT_Fiscal_Year__c, PIT_Allocation_Type__c, PIT_Budget__c, PIT_Consumed_Budget__c, PIT_Territory__c, ZTS_US_Adjustment_Summary__c, ZTS_US_Adj_Bud__c From PIT_Budget_Allocation__c where PIT_Territory__c = :curRec.ZTS_EU_Territory__c and PIT_Fiscal_Year__c = :iSelYear];
        if(isTM){
            statTM = new AllocationEntry();
            statTM.completed = 0;
            statTM.consumed = 0;
            statTM.allocation = 0;
            statTM.remaining = 0;
            statTM.Shipped = 0;
            statTM.AdjBudget = 0;
            statTM.Adjustment = 0;
            if(pbAloc.size() > 0){
                statTM.completed = pbAloc[0].PIT_Completed_Orders_Value__c;
                statTM.consumed = pbAloc[0].PIT_Consumed_Budget__c;
                statTM.allocation = pbAloc[0].PIT_Budget__c;
                statTM.AdjBudget=pbAloc[0].ZTS_US_Adj_Bud__c;
                statTM.Adjustment =pbAloc[0].ZTS_US_Adjustment_Summary__c;
                statTM.remaining = pbAloc[0].PIT_Remaining__c;
            }
        }
        if(pbAloc.size () > 0){
            totalBudget = Double.valueOf(pbAloc[0].PIT_Budget__c); 
        } else {
            totalBudget = 0;
        }
        Map<Id, PIT_Budget_Allocation__c> mIdTerritory2Budget = new Map<Id, PIT_Budget_Allocation__c>(); 
        ZTS_EU_Territory__c[] trts = [Select z.Name, (Select Name, ZTS_EU_Employee__r.FirstName, ZTS_EU_Employee__r.Lastname, ZTS_EU_Employee__c, ZTS_EU_Territory__c, ZTS_Start_Date__c, ZTS_End_Date__c From Positions__r order by ZTS_PrimaryUser__c desc, PIT_Is_Active__c desc), (Select ZTS_EU_Description__c, Name, ZTS_EU_Type__c From Territories__r), z.ZTS_EU_Type__c, z.ZTS_TerritoryRole__c, z.ZTS_EU_Terr_SFID__c, z.ZTS_Species__c, z.ZTS_EU_Parent_Territory__c, z.ZTS_US_External_ID__c, z.ZTS_BusinessSub_Unit__c, z.ZTS_EU_Is_Active__c, z.IsDeleted,  (Select Name, PIT_Fiscal_Year__c, PIT_Allocation_Type__c, PIT_Budget__c, PIT_Consumed_Budget__c, PIT_Remaining__c, ZTS_US_Adjustment_Summary__c, ZTS_US_Adj_Bud__c From Budgets_Allocation__r where PIT_Fiscal_Year__c = :iSelYear) From ZTS_EU_Territory__c z where z.ZTS_EU_Parent_Territory__c = :curRec.ZTS_EU_Territory__c AND ZTS_EU_Market__c = 'United States'];
        if(trts.size() > 0){ 
            for(ZTS_EU_Territory__c t1 : trts){
                sIdsTerritory.add(t1.Id);            
                if(t1.Territories__r != null && t1.Territories__r.size() > 0){
                    for(ZTS_EU_Territory__c t11 : t1.Territories__r){
                        sIdsTerritory.add(t11.Id);    
                    }
                } 
            }
            Map<Id, ZTS_EU_Territory__c> mAllTrts = new Map<Id, ZTS_EU_Territory__c>([Select z.Name, (Select Name, ZTS_EU_Employee__r.FirstName, ZTS_EU_Employee__r.Lastname, ZTS_EU_Employee__c, ZTS_EU_Territory__c, ZTS_Start_Date__c, ZTS_End_Date__c From Positions__r order by ZTS_PrimaryUser__c desc, PIT_Is_Active__c desc), (Select ZTS_EU_Description__c, Name, ZTS_EU_Type__c From Territories__r), z.ZTS_EU_Type__c, z.ZTS_TerritoryRole__c, z.ZTS_EU_Terr_SFID__c, z.ZTS_Species__c, z.ZTS_EU_Parent_Territory__c, z.ZTS_US_External_ID__c, z.ZTS_BusinessSub_Unit__c, z.ZTS_EU_Is_Active__c, z.IsDeleted,  (Select Name, PIT_Fiscal_Year__c, PIT_Allocation_Type__c, PIT_Budget__c, PIT_Consumed_Budget__c, PIT_Remaining__c, ZTS_US_Adjustment_Summary__c, ZTS_US_Adj_Bud__c From Budgets_Allocation__r where PIT_Fiscal_Year__c = :iSelYear) From ZTS_EU_Territory__c z where Id in : sIdsTerritory AND ZTS_EU_Market__c = 'United States']);
            PIT_Budget_Allocation__c[] childBudget = [Select PIT_Completed_Orders_Value__c, PIT_Responsible__c,  Name, PIT_Fiscal_Year__c, PIT_Allocation_Type__c, PIT_Budget__c, PIT_Consumed_Budget__c, PIT_Territory__c, PIT_Remaining__c,ZTS_US_Adjustment_Summary__c, ZTS_US_Adj_Bud__c From PIT_Budget_Allocation__c where PIT_Territory__c in :sIdsTerritory and PIT_Fiscal_Year__c = :iSelYear];
            if(childBudget.size() > 0){
                for(PIT_Budget_Allocation__c b1 : childBudget){
                    mIdTerritory2Budget.put(b1.PIT_Territory__c, b1);
                }    
            } 
            for(ZTS_EU_Territory__c t1 : trts){
                AllocationEntry a1 = new AllocationEntry();
                if(t1.Positions__r != null && t1.Positions__r.size() > 0){
                    a1.territoryRespId = t1.Positions__r[0]. ZTS_EU_Employee__c;
                    a1.firstName = t1.Positions__r[0]. ZTS_EU_Employee__r.FirstName;
                    a1.lastName = t1.Positions__r[0]. ZTS_EU_Employee__r.LastName; 
                } else {             
                    a1.firstName = '-'; 
                    a1.lastName = '-'; 
                }
                a1.territoryId = t1.Id;
                a1.position = t1.Name;
                a1.allocation = 0;
                a1.consumed = 0;
                a1.AdjBudget=0;
                a1.Adjustment=0;
                a1.Remaining=0;
                a1.allocBelow = 0;
                a1.completed = 0;
                a1.subDataComplex = '';
                if(mIdTerritory2Budget.containsKey(t1.Id)){
                    a1.allocation = mIdTerritory2Budget.get(t1.Id).PIT_Budget__c;
                    if(mIdTerritory2Budget.get(t1.Id).PIT_Allocation_Type__c == 'Territory'){
                                    a1.consumed = mIdTerritory2Budget.get(t1.Id).PIT_Consumed_Budget__c;
                                    a1.Adjustment=mIdTerritory2Budget.get(t1.Id).ZTS_US_Adjustment_Summary__c;
                                    a1.AdjBudget=mIdTerritory2Budget.get(t1.Id).ZTS_US_Adj_Bud__c;
                                    a1.Remaining=mIdTerritory2Budget.get(t1.Id).PIT_Remaining__c;
                                }
                }
                if(isAM){ 
                    if(mIdTerritory2Budget.containsKey(t1.Id)){
                        a1.completed = mIdTerritory2Budget.get(t1.Id).PIT_Completed_Orders_Value__c;
                        a1.consumed = mIdTerritory2Budget.get(t1.Id).PIT_Consumed_Budget__c;
                        a1.AdjBudget = mIdTerritory2Budget.get(t1.Id).ZTS_US_Adj_Bud__c;
                        a1.Adjustment = mIdTerritory2Budget.get(t1.Id).ZTS_US_Adjustment_Summary__c;
                    }
                }
                a1.alocId = t1.Id;
                if(isRSD){ 
                    if(t1.Territories__r != null && t1.Territories__r.size() > 0){
                        a1.subAllocs =  new list<AllocationSubentry>();      
                        Double i = 0;
                        for(ZTS_EU_Territory__c t11 : t1.Territories__r){
                            i++;
                            if(i != 1){                 
                                a1.subDataComplex = a1.subDataComplex + ', [';
                            } else {
                                a1.subDataComplex = '[[';
                            }
                            
                            ZTS_EU_Territory__c fullRec = mAllTrts.get(t11.Id);
                            if(fullRec.Positions__r != null && fullRec.Positions__r.size() > 0){
                                a1.subDataComplex = a1.subDataComplex + '"' + fullRec.Positions__r[0]. ZTS_EU_Employee__r.FirstName + '", ';
                                a1.subDataComplex = a1.subDataComplex + '"' + fullRec.Positions__r[0].ZTS_EU_Employee__r.LastName + '", ';
                            } else {             
                                a1.subDataComplex = a1.subDataComplex + '"-",'; 
                                a1.subDataComplex = a1.subDataComplex + '"-",';
                            }
                            
                            a1.subDataComplex = a1.subDataComplex + '"' + fullRec.Name + '",';
                            
                            AllocationSubentry sub = new AllocationSubentry();
                            sub.name = t11.Name; 
                            if(mIdTerritory2Budget.containsKey(t11.Id)){
                               a1.completed = a1.completed + mIdTerritory2Budget.get(t11.Id).PIT_Completed_Orders_Value__c;
                                sub.consumed = mIdTerritory2Budget.get(t11.Id).PIT_Consumed_Budget__c; 
                                sub.Remaining = mIdTerritory2Budget.get(t11.Id).PIT_Remaining__c;                           
                                sub.Adjustment= mIdTerritory2Budget.get(t11.Id).ZTS_US_Adjustment_Summary__c;
                                sub.AdjBudget= mIdTerritory2Budget.get(t11.Id).ZTS_US_Adj_Bud__c;
                                sub.allocation = mIdTerritory2Budget.get(t11.Id).PIT_Budget__c;
                                sub.completed = mIdTerritory2Budget.get(t11.Id).PIT_Completed_Orders_Value__c;
                                a1.allocBelow = a1.allocBelow + sub.allocation;
                                
                                a1.consumed = a1.consumed + sub.consumed;
                                a1.Adjustment=a1.Adjustment + sub.Adjustment;
                                a1.AdjBudget=a1.AdjBudget + sub.AdjBudget;
                                a1.Remaining=a1.Remaining + sub.Remaining;
                                 
                            } else {
                                sub.consumed = 0;
                                sub.allocation = 0;
                                sub.completed = 0; 
                                sub.Remaining = 0;
                                sub.Adjustment = 0;
                                sub.AdjBudget=0;
                            }
                             a1.subDataComplex = a1.subDataComplex + '' + sub.allocation + ',';
                            a1.subDataComplex = a1.subDataComplex + '' + sub.Adjustment + ',';
                            a1.subDataComplex = a1.subDataComplex + '' + sub.AdjBudget + ',';
                            a1.subDataComplex = a1.subDataComplex + '' + sub.consumed + ',';
                            a1.subDataComplex = a1.subDataComplex + '' + sub.remaining + '';
                            a1.subAllocs.add(sub);
                            a1.subDataComplex = a1.subDataComplex + ']';
                        }
                        a1.subDataComplex = a1.subDataComplex + ']';
                    }
                }
                AMs.add(a1);
            } 
        }
        return null;
    }
    
    public PageReference updateAllocs(){
        PIT_Budget_Allocation__c[] rec2ups = new PIT_Budget_Allocation__c[]{};
        for(AllocationEntry a1 : AMs){
            a1.selected = false;
            PIT_Budget_Allocation__c rec1 = new PIT_Budget_Allocation__c();
            //Name, PIT_Fiscal_Year__c, PIT_Allocation_Type__c, PIT_Budget__c, PIT_Consumed_Budget__c From PIT_Budget_Allocation__c where PIT_Territory__c = :curRec.ZTS_EU_Territory__c and PIT_Fiscal_Year__c = :iSelYear];
            rec1.Name = a1.position + ' - ' + selyear;            
            rec1.PIT_Fiscal_Year__c = Integer.valueOf(selyear);
            rec1.PIT_Territory__c = a1.territoryId;
            rec1.PIT_Responsible__c = a1.territoryRespId;
            rec1.PIT_Budget__c = a1.allocation;
            rec1.PIT_Allocation_Type__c = '';
            rec1.PIT_External_ID__c = String.valueOf(a1.territoryId) + selYear;
            rec1.PIT_Allocation_Type__c = (isRSD ? 'Area' : 'Territory');
            rec2ups.add(rec1);
        } 
        if(rec2ups.size() > 0){
            upsert rec2ups PIT_External_ID__c;
        }
        //added as part of SC-009697
        PageReference redirect = new PageReference('/apex/PIT_BudgetAllocation');
        redirect.setRedirect(true);
        return redirect;
        //return null;
    }
    
    public static Integer randomWithLimit(Integer upperLimit){
        Integer rand = Math.round(Math.random()*1000);
        return Math.mod(rand, upperLimit);
    }
       
}
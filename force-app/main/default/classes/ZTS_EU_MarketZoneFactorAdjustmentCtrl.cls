public with sharing class ZTS_EU_MarketZoneFactorAdjustmentCtrl{
    
    public boolean query {get; set;} // To avoid executing query two times
    public list<selectoption> businessUnit{get; set;}
    public list<selectOption> specie {get; set;}
    
    public string selectedBu {get; set;}
    public string selectedSpecie {get; set;}
    
    
    public list<selectOption> protocol {get; set;}
    public list<selectOption> accountType {get; set;}
    public string selectedProtocol {get; set;}
    public string selectedAccountType {get; set;}
    
    public boolean ca {get; set;}
    
    private map<string, string> buAbbrForSpecie;
    
    @testvisible private boolean intialLoad = true;
    
    @testVisible static final String EXCEPTION_ORIGIN_TYPE = 'ZTS_EU_MarketZoneFactorAdjustmentCtrl - Save: update potential brands';

    public ZTS_EU_MarketZoneFactorAdjustmentCtrl() {
        query = false;
        showFactors = false;       
        errorMessage = false;
        alphabit = 'All';
        ca = false;
        allPotentialProducts = new list<ZTS_EU_Potential_Brands__c>();
        sortField = 'Brand__r.name';
        sortDirection = 'ASC';
        hasNext = false;
        hasPrevious = false;
        
        businessUnit = new list<selectOption>();
        specie = new list<selectOption>();
        //id businessUnitRt = Schema.SObjectType.ZTS_EU_Species_Product__c.getRecordTypeInfosByDeveloperName().get('Business_Unit').getRecordTypeId();
        list<recordtype> recordtypeLst = new list<recordtype>();
        recordtypeLst = [select id from recordtype where developername='Business_Unit' and SobjectType='ZTS_EU_Species_Product__c'];
        list<user> usr = new list<user>([select id, ZTS_EU_Market__c from user where id=:userInfo.getUserId() AND ZTS_EU_Market__c != 'United States']);
        
        if(!usr.isEmpty() && usr[0].ZTS_EU_Market__c != null && usr[0].ZTS_EU_Market__c!= '' && !recordtypeLst.isEmpty() ){
            for(ZTS_EU_Species_Product__c bu : [select id, name from ZTS_EU_Species_Product__c where ZTS_EU_Market__c=:usr[0].ZTS_EU_Market__c and recordtypeId=:recordtypeLst[0].id order by name]){
                businessUnit.add(new selectOption(bu.id, bu.name));
            }
        }
        
        if(ApexPages.currentPage().getParameters().get('sp') != null && ApexPages.currentPage().getParameters().get('sp') != '' ){
            selectedSpecie = ApexPages.currentPage().getParameters().get('sp');
        }
        prepareSpecieList();
        if(ApexPages.currentPage().getParameters().get('pageNum') != null && ApexPages.currentPage().getParameters().get('pageNum') != '' ){
            pageNumber = Integer.valueOf(ApexPages.currentPage().getParameters().get('pageNum'));
        }else{
            pageNumber = 1;
        }
        if(ApexPages.currentPage().getParameters().get('query') != null && ApexPages.currentPage().getParameters().get('query') != '' ){
            query = boolean.valueOf(ApexPages.currentPage().getParameters().get('query'));
        }
        if(ApexPages.currentPage().getParameters().get('ca') != null && ApexPages.currentPage().getParameters().get('ca') != '' ){
            ca = boolean.valueOf(ApexPages.currentPage().getParameters().get('ca'));
        }
        if(ApexPages.currentPage().getParameters().get('selectedProtocol') != null && ApexPages.currentPage().getParameters().get('selectedProtocol') != '' ){
            selectedProtocol = ApexPages.currentPage().getParameters().get('selectedProtocol');
        }
        if(ApexPages.currentPage().getParameters().get('selectedAccountType') != null && ApexPages.currentPage().getParameters().get('selectedAccountType') != '' ){
            selectedAccountType = ApexPages.currentPage().getParameters().get('selectedAccountType');
        }
        
        /*Preparing Account type picklist */
        accountType = new list<selectOption>();
        for( Schema.PicklistEntry f : ZTS_EU_Potential_Brands__c.ZTS_EU_CA_Account_Type__c.getDescribe().getPicklistValues()){
	        accountType.add(new SelectOption(f.getLabel(), f.getValue()));
	    }   
        /*Preparing protocol picklist */
        protocol = new list<selectOption>();
        for( Schema.PicklistEntry f : ZTS_EU_Potential_Brands__c.Protocol_For_CA__c.getDescribe().getPicklistValues()){
	        protocol.add(new SelectOption(f.getLabel(), f.getValue()));
	    }  
        
        
    }
    
    public pageReference prepareSpecieList(){
    	
    	selectedProtocol  = null;
    	selectedAccountType = null;
        specie = new list<selectOption>();
        wrapperList=new List<WrapperClass>();
        buAbbrForSpecie = new map<string, string>();
        totalNumOfPages = 0;
        totalNumOfRecords = 0;
        pageNumber =1;
        hasPrevious= false;
        hasNext = false;
        showFactors = false;
        ca = false;
        if(intialLoad == true && ApexPages.currentPage().getParameters().get('bu') != null && ApexPages.currentPage().getParameters().get('bu') != ''){
            intialLoad = false;
            selectedBu = ApexPages.currentPage().getParameters().get('bu');
        }
        if(selectedBu != null && selectedBu != ''){
            for(ZTS_EU_Species__c sp : [select id, name,ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c from ZTS_EU_Species__c where ZTS_EU_Business_Unit__c=:selectedBu]){
                specie.add(new selectOption(sp.id, sp.name));
                buAbbrForSpecie.put(sp.id,sp.ZTS_EU_Business_Unit__r.ZTS_EU_Business_Unit_Abbr__c);
            }
        }
        return null;
        
    }
    
    public List<WrapperClass> getwrapperList() {
        if(query == true && ((ca == false && selectedSpecie != null && selectedSpecie != '' ) || (ca == true && selectedSpecie != null && selectedSpecie != '' && selectedProtocol != null &&  selectedAccountType != null))){
            query = false;
            wrapperList=new List<WrapperClass>();
            list<ZTS_EU_Potential_Brands__c> tmp = new list<ZTS_EU_Potential_Brands__c>();
            string qry = 'SELECT Id,ZTS_EU_CA_Account_Type__c,name,Protocol_For_CA__c,Brand__c,Brand__r.name,Adjustment_Factor__c,MPG_SKU_Mix__c,Annual_Number_of_treatments_Animal__c,Potential__c,Potential__r.name,Price_Doses_or_ml__c,Period_of_Use_Months__c,Number_of_Doses_per_SKU__c,Price_SKU__c,ZTS_EU_Adjustment_Factor_1__c,ZTS_EU_Dosage_1_Region_1__c, Number_of_Doses_per_Animal__c FROM ZTS_EU_Potential_Brands__c where';
            
            if(ca == true){
            	qry = qry + ' Protocol_For_CA__c=:selectedProtocol and ZTS_EU_CA_Account_Type__c=:selectedAccountType and';
            }
            
            if(alphabit != 'All'){
                qry = qry + ' Potential__c=:selectedSpecie and '+sortField+' like '+'\''+alphabit+'%'+'\''+ ' order by '+sortField+' '+sortDirection;
            }else{
                qry = qry + ' Potential__c=:selectedSpecie order by '+sortField+' '+sortDirection;
            }
            system.debug('>>>>>>>>>'+qry);
        
        
            allPotentialProducts = new list<ZTS_EU_Potential_Brands__c>();
            allPotentialProducts = database.query(qry); 
        
            if(!allPotentialProducts.isEmpty()){
                totalNumOfPages = allPotentialProducts.size()/recordsperPage;
                if(Math.mod(totalNumOfPages,recordsperPage) > 0){
                    totalNumOfPages = totalNumOfPages +1;
                }else {
                    totalNumOfPages = 1;
                }
                
                totalNumOfRecords = allPotentialProducts.size();
            }else{
                totalNumOfPages = 0;
                totalNumOfRecords = 0;
            }
            
            integer strt = (pageNumber-1)*recordsperPage;
            integer ed = pageNumber * recordsperPage; 
            if(allPotentialProducts.size() < ed){
                ed = allPotentialProducts.size();
            }
            
            for(integer i=strt;i<ed;i++){
                tmp.add(allPotentialProducts[i]);
            }
            
            if(pageNumber == 1){
                hasPrevious= false;
            }else{
                hasPrevious = true;
            }
            
            if(totalNumOfPages == pageNumber || allPotentialProducts.isEmpty()){
                hasNext = false;
            }else{
                hasNext = true;
            }
            
            
            for(ZTS_EU_Potential_Brands__c pb : tmp){
                 WrapperClass wp=new WrapperClass(pb, 'Adjustment Factor 1', 'Dosage Factor 1', pb.ZTS_EU_Adjustment_Factor_1__c, pb.ZTS_EU_Dosage_1_Region_1__c );
                 wrapperList.add(wp);
            }
        
        }
        return wrapperList;
    }
    
     
     public pageReference reLoad(){
        return null;
     }
     
     public pageReference changeSpecie(){
     	wrapperList=new List<WrapperClass>();
     	selectedProtocol  = null;
    	selectedAccountType = null;
    	if(selectedSpecie != null && selectedSpecie != ''){
     		if(buAbbrForSpecie.get(selectedSpecie) != null){
     			if(buAbbrForSpecie.get(selectedSpecie) == 'CA'){
     				ca = true;
     			}else{
     				ca = false;
     			}
     		}
     	}
     	sortList();
     	return null;
     }
     
     public pageReference sortList(){
        showFactors = false;
        return null;
     }
     
     public pageReference resetPageTable(){
        showFactors = false;
        pageNumber = 1;
        return null;
     }
     
    public decimal numberOfDosesPerSku { get; set; }
    public decimal productRotation { get; set; }
    public decimal numOfDosesPerMl { get; set; }
    public decimal annualNoOfTreatments { get; set; }
    public decimal mpgSKUMix { get; set; }
    public decimal adjustmentFactr { get; set; }
    public boolean showFactors { get; set; }
    public boolean errorMessage{ get; set; }
    public string alphabit{ get; set; }
   
    public integer totalNumOfPages {get;set;}
    public integer totalNumOfRecords {get;set;}
    public integer pageNumber {get; set;}
    
    integer recordsperPage = 10;
    public Boolean hasNext {get; set;}
    public Boolean hasPrevious {get; set;}
    
    
    Transient List<ZTS_EU_Potential_Brands__c> allPotentialProducts; 
    
    private String sortDirection = 'ASC';
    private String initialsortField = 'Brand__r.name';
    
    public String sortField{
        get {
            return initialsortField;
        }
        set{
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == initialsortField)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
                initialsortField = value;
        }
    }
    
    public String getSortDirection() {
        //if not column is selected 
        if (sortField == null || sortField == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value){  
        sortDirection = value;
    }
    
    public List<WrapperClass> wrapperList; 
    
   
    
    
    
    
    public PageReference Save() {
        try{
            list<ZTS_EU_Potential_Brands__c> pbLst = new list<ZTS_EU_Potential_Brands__c>();
            if(!wrapperList.isEmpty()){
                for(WrapperClass w : wrapperList){
                    if(w.selected == true){
                        if(adjustmentFactr != null && adjustmentFactr != 0){
                            w.pbObj.Adjustment_Factor__c = adjustmentFactr;
                        }
                        if(mpgSKUMix != null && mpgSKUMix !=0){
                            w.pbObj.MPG_SKU_Mix__c = mpgSKUMix;
                        }
                        if(annualNoOfTreatments != null&& annualNoOfTreatments != 0){
                            w.pbObj.Annual_Number_of_treatments_Animal__c = annualNoOfTreatments;
                        }
                        if(numOfDosesPerMl != null&& numOfDosesPerMl != 0){
                            w.pbObj.Number_of_Doses_per_Animal__c = numOfDosesPerMl;
                        }
                        if(productRotation != null&& productRotation != 0){
                            w.pbObj.Period_of_Use_Months__c = productRotation;
                        }
                        if(numberOfDosesPerSku != null&& numberOfDosesPerSku != 0){
                            w.pbObj.Number_of_Doses_per_SKU__c = numberOfDosesPerSku;
                        }
                    }
                    pbLst.add(w.pbObj);
                    w.selected = false;
                }
                if(!pbLst.isEmpty()){
                    update pbLst;
                    showFactors = false; 
                    emptyFactorFields();
                }
            }
        }catch(DmlException dex){
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(EXCEPTION_ORIGIN_TYPE);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, EXCEPTION_ORIGIN_TYPE);
        }
        pageReference pf = new pageReference('/apex/ZTS_EU_MarketZoneFactorAdjustment?pageNum='+pageNumber+'&bu='+selectedBu+'&sp='+selectedSpecie+'&query=true'+'&ca='+ca+'&selectedProtocol='+selectedProtocol+'&selectedAccountType='+selectedAccountType);
        pf.setRedirect(true);
        return pf;
    }
    
    
   
   
    public class WrapperClass{
        public Boolean selected{get;set;} 
        public ZTS_EU_Potential_Brands__c pbObj{get;set;}
        public String adjustmentFactorLabel {get;set;}
        public String adjustmentFactor {get;set;}
        public String dosageFactorLabel {get;set;}
        public String dosageFactor {get;set;}
        
        public WrapperClass(ZTS_EU_Potential_Brands__c pb, String adjustmentFactorLabel, 
            String dosageFactorLabel, String adjustmentFactor, String dosageFactor){ 
            this.selected=false; 
            this.pbObj=pb;
            this.adjustmentFactorLabel=adjustmentFactorLabel;
            this.dosageFactorLabel = dosageFactorLabel;
            this.adjustmentFactor= adjustmentFactor;
            this.dosageFactor = dosageFactor ;
            
        }
    }
     
    public PageReference setFactorsRedirect(){
        showFactors = false;
        
        for(WrapperClass pbObj : wrapperList) {
            if(pbObj.selected == true){
                showFactors = true;
                break;
            }
        }    
        
        
        if(showFactors != true){
            errorMessage = true;
        }else{
            errorMessage = false;
        }
        setFactorValues();
        return null;
    }
    
    public pageReference selection(){
        showFactors = false;
        setFactorValues();
        return null;
    }
    
    public void emptyFactorFields(){
        adjustmentFactr = null;
        mpgSKUMix = null;
        annualNoOfTreatments = null;
        numOfDosesPerMl = null;
        productRotation = null;
        numberOfDosesPerSku = null;
    }
    
    public void setFactorValues(){
        integer i = 0;
        if(!wrapperList.isEmpty()){
            for(WrapperClass pbObj : wrapperList) {
                if(pbObj.selected == true){
                    i++;
                }
            } 
            if(i == 1){
                for(WrapperClass w : wrapperList){
                    if(w.selected == true){
                        adjustmentFactr = w.pbObj.Adjustment_Factor__c;
                        mpgSKUMix = w.pbObj.MPG_SKU_Mix__c;
                        annualNoOfTreatments = w.pbObj.Annual_Number_of_treatments_Animal__c;
                        numOfDosesPerMl= w.pbObj.Number_of_Doses_per_Animal__c;
                        productRotation = w.pbObj.Period_of_Use_Months__c;
                        numberOfDosesPerSku = w.pbObj.Number_of_Doses_per_SKU__c;
                    }
                }
            }else{
                emptyFactorFields();
            }
        }
    }
    
    

    // returns the previous page of records
     public void previousPage() {
        showFactors = false;
        pageNumber = pageNumber - 1;
     }

     // returns the next page of records
     public pageReference nextPage() {
        showFactors = false;
        pageNumber = pageNumber + 1;
        return null;
     }

     


    // returns the first page of records
     public void firstPage() {
         showFactors = false;
         pageNumber = 1;
     }

     // returns the last page of records
     public void lastPage() {
        showFactors = false;
        pageNumber = totalNumOfPages;
     }

     
     
     public Integer fromRecords {
        get {
            return (((pageNumber - 1) * recordsperPage) +1);
        }
        set;
    }
    
    public Integer toRecords {
        get {
            integer tmp = pageNumber * recordsperPage;
            if(tmp > totalNumOfRecords){
                tmp = totalNumOfRecords;
            }
            return tmp;
        }
        set;
    }

    
    
    public void setwrapperList(List<WrapperClass> wl){
        wrapperList = wl;
    }
}
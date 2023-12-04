public with sharing class ZTS_EU_BU_AdminSetupController{
    public  String SelectedMarket{get;set;}
    public  List<String> SelectedTGGroups{get;set;}
    public  String SelectedBusinessUnit{get;set;}
    public  String SelectedSpecies{get;set;}
    public  List<String> SelectedBrandGroups{get;set;}
    public  String ZTS_EU_Market='';
    public List<BrandsCheckBoxWrapper> potentialBrandWrapperList{get;set;}
    public Boolean tGGroupFlag{get;set;}
    public Boolean businessGroupFlag{get;set;}
    public Boolean speciesFlag{get;set;}
    public Boolean brandFlag{get;set;}
    public Boolean marketFlag{get;set;}
    public Boolean setFactorsFlag{get;set;}
    public Boolean checkCAAnimal{get;set;}
    public List<SelectOption> tGGroupOptions{get;set;}
    public List<SelectOption> businessUnitOptions{get;set;}
    public List<SelectOption> selectedBrandOptions{get;set;}
    public List<SelectOption> speciesOptions{get;set;}
    public String businessUnit='';
    public String potentialLevel{get;set;}
    private ZTS_EU_SetAdjustmentFactorsController adjustmentController;
    public ZTS_EU_Potential_Brands__c[] potBrandsToUpsert {get;set;}
    public string selectedCAAccountType { get; set; }
    public string selectedProtocolForCA { get; set; }
    public ListCollection Paging {get;set;} 
    public List<SelectOption> cAAccountTypeOptions {set;}
    public  List<SelectOption> getcAAccountTypeOptions(){
    List<SelectOption> options =  new List<SelectOption>();      
        Schema.DescribeFieldResult fieldResult = ZTS_EU_Potential_Brands__c.ZTS_EU_CA_Account_Type__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new selectOption('',''));    
        for(Schema.picklistEntry f : ple)    
        {    
            options.add(new selectOption(f.getValue(),f.getValue()));                  
        }  

        return Options;   
   }
   
    public List<SelectOption> protocolForCAOptions {set;}
    public  List<SelectOption> getprotocolForCAOptions(){
    List<SelectOption> options =  new List<SelectOption>();      
        Schema.DescribeFieldResult fieldResult = ZTS_EU_Potential_Brands__c.Protocol_For_CA__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
         options.add(new selectOption('','')); 
        for(Schema.picklistEntry f : ple)    
        {    
            //options.add(new selectOption('--none--','--none--'));
            options.add(new selectOption(f.getValue(),f.getValue()));                  
        }  

        return Options;   
   }
    
    public ZTS_EU_BU_AdminSetupController(ZTS_EU_SetAdjustmentFactorsController controller) {
        adjustmentController = controller;
        List<User> userInfoList=[Select ZTS_EU_Market__c,ZTS_EU_Primary_Business_Unit__c from User where Id =: UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'];
        system.debug('userInfoList$$$$'+userInfoList);
        if(!userInfoList.isEmpty()){
            SelectedMarket=userInfoList[0].ZTS_EU_Market__c;
            //businessUnit = userInfoList[0].ZTS_EU_Primary_Business_Unit__c;
        }
        system.debug('market$$$$'+SelectedMarket);
        filterByMarket();
        setFactorsFlag=false;
        Paging = new ListCollection();

    }
    
    /**
    * Method used for Redirecting the Page to Potential Brand Creation Page
    *   @author Shefali Vinchurkar
    **/
    
    public PageReference setFactors(){ 
        setFactorsFlag=true;
        List<BrandsCheckBoxWrapper> selectedList =new List<BrandsCheckBoxWrapper>();
     
        
            for(BrandsCheckBoxWrapper bCheckWrapperInstance : potentialBrandWrapperList){
                if(bCheckWrapperInstance.brandSelect==true){
                    selectedList.add(bCheckWrapperInstance);
                    system.debug('####selected number of brands'+selectedList.size());
                    bCheckWrapperInstance.brandSelect=false;
                }      
            }
        
        
        Set<Id> selectedBrandIdSet =new Set<Id>();
        for(BrandsCheckBoxWrapper b : selectedList){
                selectedBrandIdSet.add(b.brand.Id);
       
        }
        
        List<ZTS_EU_Species__c> selectedSpeciesList =[Select Name,Id,ZTS_EU_Market__c from ZTS_EU_Species__c where Name =: SelectedSpecies AND ZTS_EU_Market__c = : SelectedMarket];
        system.debug('selectedSpeciesList#####'+selectedSpeciesList);
        Set<Id> selectedSpeciesIdSet =new Set<Id>();
        for(ZTS_EU_Species__c specie : selectedSpeciesList){
            selectedSpeciesIdSet.add(specie.Id);
        }
        Set<String> setKeys=new Set<String>();
        
        for(String spId: selectedSpeciesIdSet){
            for(String brId: selectedBrandIdSet){
                setKeys.add('' + spId +';'+ brId);
            }
        }
        system.debug('setKeys###...1..##'+setKeys);
        
        if(selectedSpeciesIdSet.isEmpty()){
            Apexpages.AddMessage(new ApexPages.Message(Apexpages.Severity.Info,'Please select a Specie', ''));
        } 
        if(selectedBrandIdSet.isEmpty()){
            Apexpages.AddMessage(new ApexPages.Message(Apexpages.Severity.Info,'Please select a Product', ''));
        }
       
        Set<String> insertSet =new Set<String>();
        List<ZTS_EU_Potential_Brands__c> listToUpdate =new List<ZTS_EU_Potential_Brands__c>();
        List<ZTS_EU_Potential_Brands__c> listToInsert =new List<ZTS_EU_Potential_Brands__c>();
        List<ZTS_EU_Potential_Brands__c> pBList = [Select Name,Id,Potential__c, Brand__c from ZTS_EU_Potential_Brands__c where Potential__c IN: selectedSpeciesIdSet];
        for(ZTS_EU_Potential_Brands__c pb1 : pbList){
            if(setKeys.contains('' + pb1.Potential__c + ';' + pb1.Brand__c)){
                listToUpdate.add(pb1);
                setKeys.remove('' + pb1.Potential__c + ';' + pb1.Brand__c);
            }
        }
        system.debug('setKeys###...2...##'+setKeys);
        Map<String,String> specieBrandMap =new Map<String,String>();
        for(String setId : setKeys){
            String [] specieBrandString =setId.split(';',2);
            specieBrandMap.put(setId,specieBrandString[1]);
        }
        system.debug('specieBrandMap#####'+specieBrandMap);
        for(String potSp : specieBrandMap.keySet()){
            ZTS_EU_Potential_Brands__c newPB =new ZTS_EU_Potential_Brands__c();
            newPB.Potential__c =potSp.split(';',2)[0];
            newPB.Brand__c=specieBrandMap.get(potSp);
            //newPB.ZTS_EU_Value_Region_1__c=1;
            //newPB.ZTS_EU_Value_Region_2__c=2;
           // newPB.ZTS_EU_Value_Region_3__c=3;
            //newPB.ZTS_EU_Value_Region_4__c=4;
            listToInsert.add(newPB);
        }
        system.debug('listToInsert####'+listToInsert);
        potBrandsToUpsert =new ZTS_EU_Potential_Brands__c[]{};
        potBrandsToUpsert.addAll(listToInsert);
        potBrandsToUpsert.addAll(listToUpdate);
        
        system.debug('pbupsert####'+potBrandsToUpsert);
        
        adjustmentController.potentialBrandsToUpsert = potBrandsToUpsert; 
        
         system.debug('pbupsert####'+adjustmentController.potentialBrandsToUpsert);
        
        //PageReference p=adjustmentController.goToSetAdjustmentFactors(); 
        if(selectedSpeciesIdSet.isEmpty() ||selectedBrandIdSet.isEmpty()){
            return null;
        }
        return null; 
    }
    
    /**
    * Method used to populate Markets picklist
    *   @author Shefali Vinchurkar
    **/
    
    public List<SelectOption> getOptions()    
     {    
        List<SelectOption> options =  new List<SelectOption>();      
        Schema.DescribeFieldResult fieldResult = User.ZTS_EU_Market__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
        for(Schema.picklistEntry f : ple)    
        {    
            options.add(new selectOption(f.getValue(),f.getValue()));  
             system.debug('*****options'+f.getLabel()+'>'+f.getValue());                   
        }  

        return Options;    
     }       
     
   /**
    *   Method used to populate Therapeutic Group picklist & Species picklist
    *   @author Shefali Vinchurkar
    **/
   
    public void filterByMarket(){
    
        ZTS_EU_Market=SelectedMarket;
        marketFlag=false;
        SelectedTGGroups=null;
        SelectedBusinessUnit=null;
        SelectedSpecies=null;
        SelectedBrandGroups=null;
        potentialBrandWrapperList=new List<BrandsCheckBoxWrapper>(); 
        tGGroupFlag=true;
        businessGroupFlag=true;
        brandFlag=false;
        speciesFlag=false;
        setFactorsFlag=false;
        checkCAAnimal=false;
        tGGroupOptions =  new List<SelectOption>(); 
        businessUnitOptions =  new List<SelectOption>(); 
        List<ZTS_EU_Species_Product__c> TGGroupList =[Select Name,  ZTS_EU_Market__c, ZTS_EU_Type__c from ZTS_EU_Species_Product__c where ZTS_EU_Market__c = :ZTS_EU_Market and ZTS_EU_Type__c= : 'Therapeutic Group'];
        List<ZTS_EU_Species_Product__c> businessList =[Select Name,  ZTS_EU_Market__c, ZTS_EU_Type__c,ZTS_EU_Business_Unit_Abbr__c  from ZTS_EU_Species_Product__c where ZTS_EU_Market__c = :ZTS_EU_Market and ZTS_EU_Type__c= : 'Business Unit'];
        system.debug('TGGroupList#####'+TGGroupList);
        for(ZTS_EU_Species_Product__c tg : TGGroupList)    
        {    
            tGGroupOptions.add(new selectOption(tg.Name,tg.Name));                    
        } 
        for(ZTS_EU_Species_Product__c bL: businessList)    
        {    
            businessUnitOptions.add(new selectOption(bL.ZTS_EU_Business_Unit_Abbr__c,bL.ZTS_EU_Business_Unit_Abbr__c));                    
        }  
       getCheckRegionOfMarket();
           
     } 

    public boolean getCheckRegionOfMarket(){
    
       if(MarketGeoMapping__c.getValues(SelectedMarket)!=null && MarketGeoMapping__c.getValues(SelectedMarket).Geo__c !=null && MarketGeoMapping__c.getValues(SelectedMarket).Geo__c=='CLAR')
         marketFlag=True;
        else
         marketFlag=False; 
      system.debug('>>>>>>>marketFlag'+marketFlag+'>>>>>'+SelectedMarket);
     return marketFlag;
    }  
    /**
    *   Method used to populate Brand Selection Table
    *   @author Shefali Vinchurkar, modified : Mamta Chintalapudi
    **/
    public void populateSpecies(){
    
         List<ZTS_EU_Species_Product__c> businessUnitList =[Select Id ,Name, ZTS_EU_Business_Unit_Abbr__c,ZTS_EU_Type__c from ZTS_EU_Species_Product__c where ZTS_EU_Type__c =: 'Business Unit' AND ZTS_EU_Business_Unit_Abbr__c =:SelectedBusinessUnit];
            system.debug('businessUnitList####'+businessUnitList);
            
           
               List<ZTS_EU_Species__c> SpeciesList =[Select Name,ZTS_EU_Market__c, ZTS_EU_Business_Unit__c from   ZTS_EU_Species__c where ZTS_EU_Business_Unit__c IN: businessUnitList AND ZTS_EU_Market__c =: SelectedMarket];
            system.debug('SpeciesList#####'+SpeciesList);
             speciesOptions =  new List<SelectOption>();  
            for(ZTS_EU_Species__c sp : SpeciesList)    
            {    
                speciesOptions.add(new selectOption(sp.Name,sp.Name));                    
            }
            speciesFlag=true;
          checkProtocolAccountTypeForCA();
    }
    public void populateBrands(){
       try{
             speciesFlag=false;
             selectedBrandOptions=null;
             SelectedBrandGroups=null;
             setFactorsFlag=false;
    
          if(potentialBrandWrapperList!=null && potentialBrandWrapperList.size()>0)
         {
           potentialBrandWrapperList.clear();
         }

         if(MarketGeoMapping__c.getValues(SelectedMarket)!=null && MarketGeoMapping__c.getValues(SelectedMarket).Product_Potential_Level__c!=null)
            {
                potentialLevel=MarketGeoMapping__c.getValues(SelectedMarket).Product_Potential_Level__c;
            }
           if(potentialLevel=='SKU')
           {
             brandFlag=true;
           }
           else
           {
            brandFlag=false;
           }
          system.debug('SelectedTGGroups#####'+SelectedTGGroups);
            potentialBrandWrapperList=new List<BrandsCheckBoxWrapper>();
            List<Id> tGGroupIdList =new List<Id>();
            List<ZTS_EU_Species_Product__c> TGGroupList2 =[Select Name, Id, ZTS_EU_Type__c,ZTS_EU_Budgeted_Price__c from ZTS_EU_Species_Product__c where ZTS_EU_Market__c = :ZTS_EU_Market AND ZTS_EU_Type__c= : 'Therapeutic Group' AND Name IN: SelectedTGGroups];
            for(ZTS_EU_Species_Product__c s : TGGroupList2){
                tGGroupIdList.add(s.Id);
            }
            System.debug('TGGroupList####'+TGGroupList2);
            List<ZTS_EU_Species_Product__c> brandList=[Select Name,ZTS_EU_Type__c,ZTS_EU_Parent_Species_Product__c,ZTS_EU_Budgeted_Price__c from ZTS_EU_Species_Product__c where ZTS_EU_Type__c =:'Brand' AND ZTS_EU_Parent_Species_Product__c IN : tGGroupIdList];
            
            system.debug('brandList>>>>'+brandList);
            if(!brandFlag)
            {
              for(ZTS_EU_Species_Product__c brands : brandList){
                BrandsCheckBoxWrapper bWObject = new BrandsCheckBoxWrapper();
                bWObject.brand=brands;
                bWObject.brandSelect=false;
                potentialBrandWrapperList.add(bWObject);
             }
           }
           else
            {
                selectedBrandOptions =  new List<SelectOption>();  
                system.debug('brandList>>>>'+brandList);
                for(ZTS_EU_Species_Product__c sp1 : brandList)    
                {    
                    selectedBrandOptions.add(new selectOption(sp1.Name,sp1.Name));                    
                }
                
                 
            } 
            system.debug('potentialBrandWrapperList>>>>'+potentialBrandWrapperList);
            
        }catch(Exception ex){
             System.debug('The following exception has occurred: ' + ex.getMessage());
        }
        
    }
   public void checkProtocolAccountTypeForCA(){
           checkCAAnimal=false;
           if(SelectedBusinessUnit=='CA')
            {
              checkCAAnimal=true;
            }
           
   }
   public void populateSKUs(){ 
       try{
        
         if(SelectedBrandGroups==null || SelectedBrandGroups.isEmpty()){
            Apexpages.AddMessage(new ApexPages.Message(Apexpages.Severity.Info,'Please select a Product', ''));
        } 
         if(SelectedBrandGroups==null || selectedBrandOptions.isEmpty()){
            Apexpages.AddMessage(new ApexPages.Message(Apexpages.Severity.Info,'There are no Products for this TG', ''));
        }
          List<Id> brandIdList =new List<Id>();
           List<ZTS_EU_Species_Product__c> brandList=[Select Name,ZTS_EU_Type__c,ZTS_EU_Parent_Species_Product__c from ZTS_EU_Species_Product__c where ZTS_EU_Type__c =:'Brand' AND  Name IN : SelectedBrandGroups];
            for(ZTS_EU_Species_Product__c s : brandList){
                brandIdList.add(s.Id);
            }
   List<ZTS_EU_Species_Product__c> mpgList=[Select Name,ZTS_EU_Type__c,ZTS_EU_Parent_Species_Product__c from ZTS_EU_Species_Product__c where ZTS_EU_Type__c =:'MPG' AND ZTS_EU_Parent_Species_Product__c IN : brandIdList AND ZTS_EU_Market__c =: SelectedMarket ];
   List<ZTS_EU_Species_Product__c> skuList=[Select Name,ZTS_EU_Type__c,ZTS_EU_Budgeted_Price__c,ZTS_EU_Parent_Species_Product__c from ZTS_EU_Species_Product__c where ZTS_EU_Type__c =:'SKU' AND ZTS_EU_Parent_Species_Product__c IN : mpgList AND ZTS_EU_Market__c =: SelectedMarket];
    populateSpecies();
            
   List<ZTS_EU_Species__c> selectedSpeciesList =[Select Name,Id,ZTS_EU_Market__c from ZTS_EU_Species__c where Name =: SelectedSpecies AND ZTS_EU_Market__c = : SelectedMarket];

   Set<Id> selectedSpeciesIdSet =new Set<Id>();
    
   for(ZTS_EU_Species__c specie : selectedSpeciesList){
            selectedSpeciesIdSet.add(specie.Id);
        }  
        List<ZTS_EU_Potential_Brands__c> potentialRecords= new List<ZTS_EU_Potential_Brands__c> ([Select id, Brand__c,Name,Potential__c from ZTS_EU_Potential_Brands__c where Potential__c IN: selectedSpeciesIdSet and Brand__c IN:skuList]);
         system.debug('skuList>>>>'+skuList +'specieIdset>>>'+selectedSpeciesIdSet+'potentialRecords>>>>'+potentialRecords);
         Map<id,ZTS_EU_Potential_Brands__c> productMap =new Map<id,ZTS_EU_Potential_Brands__c>();
         Map<id,ZTS_EU_Potential_Brands__c> specieMap =new Map<id,ZTS_EU_Potential_Brands__c>();  
         Map<id,ZTS_EU_Potential_Brands__c> caMap =new Map<id,ZTS_EU_Potential_Brands__c>(); 
         List<ZTS_EU_Potential_Brands__c> potentialRecordsCA= new List<ZTS_EU_Potential_Brands__c>();
        if(checkCAAnimal && (selectedCAAccountType!=null || selectedCAAccountType !='') && (selectedProtocolForCA !=null || selectedProtocolForCA!=''))    
         {
            potentialRecordsCA= new List<ZTS_EU_Potential_Brands__c> ([Select id, Brand__c,Name,Potential__c from ZTS_EU_Potential_Brands__c where Potential__c IN: selectedSpeciesIdSet and Brand__c IN:skuList and ZTS_EU_CA_Account_Type__c=:selectedCAAccountType  and Protocol_For_CA__c=:selectedProtocolForCA ]);
         }   
        if (potentialRecordsCA!=null && potentialRecordsCA.size()>0)
         {
             for(ZTS_EU_Potential_Brands__c products: potentialRecordsCA)
              {
                 caMap.put(products.Brand__c,products); 
              }
         } 
         
        if (potentialRecords!=null && potentialRecords.size()>0 && !checkCAAnimal)
        {
              for(ZTS_EU_Potential_Brands__c products: potentialRecords)
              {
                 productMap.put(products.Brand__c,products); 
                 specieMap.put(products.Potential__c,products);
              }
        
        }     
           potentialBrandWrapperList=new List<BrandsCheckBoxWrapper>(); 
            //Paging = new ListCollection();
            Paging.PageSize = 15;
                for(ZTS_EU_Species_Product__c brands : skuList){ 
                    BrandsCheckBoxWrapper bWObject = new BrandsCheckBoxWrapper();     
                        bWObject.brand=brands;
                        bWObject.brandSelect=false; 
                  for(ZTS_EU_Species__c specie:selectedSpeciesList) 
                    {
                      
                        if(!checkCAAnimal && productMap!=null && specieMap!=null && productMap.get(brands.id)!=null && specieMap.get(specie.id)!=null)
                         {
                           bWObject.potentialRecordPresent=System.Label.Yes;
                         }
                        else if(checkCAAnimal && caMap!=null && caMap.get(brands.id)!=null)
                        {
                          bWObject.potentialRecordPresent=System.Label.Yes;
                        }
                         else 
                         {
                           bWObject.potentialRecordPresent=System.Label.No;
                         }
                   } 
                  potentialBrandWrapperList.add(bWObject);  
                }
                Paging.wrapList=potentialBrandWrapperList;
                system.debug('potentialBrandWrapperList>>>>'+potentialBrandWrapperList);
                   
             
       }catch(Exception ex){
             System.debug('The following exception has occurred: ' + ex.getMessage());
       }
        }        
    public pageReference Cancel()
     {
         speciesFlag=false;
         selectedBrandOptions=null;
         SelectedBrandGroups=null;
         setFactorsFlag=false;

         PageReference pRef = null;
        try{
            pRef = new PageReference(System.Label.BU_Admin_Set_Up_Page_URL);
            pRef.setRedirect(true);
        }catch(Exception e){
            String error=e.getMessage();
        }
        return pRef;
     }
     
    

    /**
    *   Wrapper class to populate Brand Table with Checkbox
    *   @author Shefali Vinchurkar
    **/
    
    public class ListCollection extends Pageable {
        public List<BrandsCheckBoxWrapper> wrapList{get;set;}
        public override integer getRecordCount() {
            return (wrapList == null? 0 : wrapList.size());
      } 
    }
    public class BrandsCheckBoxWrapper{
        public ZTS_EU_Species_Product__c brand{get;set;}
        public boolean brandSelect {get;set;} 
        public String  potentialRecordPresent {get;set;} 
    }
    
     
}
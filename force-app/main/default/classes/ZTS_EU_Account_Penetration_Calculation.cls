/*************************************************************************************
* Name          :    ZTS_EU_Account_Penetration_Calculation.
* Description   :    Controller for ZTS_EU_AccountPenetrationCalculation page.
           It will having code to display the SKU/BRAND Potential and Penetration for selected account
           For EUAFME/CLAR region
* Author        :    Teresa
* Test class    :    ZTS_EU_Account_Penetration_Calcutn_Test
 
Modification Log 
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
04/09/2014       Teresa                    Created
03/13/2015       Pavan Kumar               Modified   - > Added code for CLAR region.

**************************************************************************************/
public with sharing class ZTS_EU_Account_Penetration_Calculation{
  
    /*********VARIABLES********************/
    public string appQueryString; // list of all account product potential fields
    public String product_Potential_Level{get;set;}  //R added/ Used to show product Potential Level as column name on VF page. 
    public String accountMarket {get;set;}   //R added/  Market of the account
    public String geoLevel{get;set;} //Geo location of current account
    public String accountId {get;set;}
    public String accountName {get;set;}
    public Integer potentialRegion {get;set;}
    public List<BusinessUnitWrapper> allUnitsSpeciesList{get;set;} // List of Table records in Business unit tab
    public List<BusinessUnitWrapper> allSpeciesList{get;set;} // List of records displaying in Specie Tab
    public List<businessUnitsCheckBoxWrapper> businessUnits{get;set;} // Business unit filter list
    public List<businessUnitsCheckBoxWrapper> species{get;set;} // list of specis 
    public List<businessUnitsCheckBoxWrapper> tgGroup{get;set;} // List of TG values using Business untit tab
    public List<businessUnitsCheckBoxWrapper> tgGroupSpecies{get;set;} // list of TG values using in specie tab
    public Double totalPotential{get;set;}
    public Double totalCYTDSales{get;set;}
    public Double totalPYTDSales{get;set;}
    public Double totalMAT{get;set;}
    public Double totalMATPriorSales{get;set;}  
    public String prodPotLevel {get;set;} 
    Map<String,Set<String>> allBrandBU = new Map<String,Set<String>>();
    Map<String,Set<String>> allBrandSpecies = new Map<String,Set<String>>();
    Map<String,ZTS_EU_Sales__c> brandNameSalesMap = new Map<String,ZTS_EU_Sales__c>();
    Map<String,double> speciesAnimalConsultMap = new Map<String,double>();
    Set<String> speciesIdSet   = new Set<String>();
    List<String> speciesIdList = new List<String>();
    List<BusinessUnitWrapper> bwObjList;
    
    map<string, string> uniqueIdBrandName; // This map will store, product id as key and brand name as value
    
    map<string, string> productUniqueIdRecordtype;//Used to store key as Products Unique Id and value as its recordtype. To verify    
    
      /***********
            * Description  : Constructor is being used to get all the data and
            * format them as per required by the UI.
            * Return Type  : None.
            * Parameters   : none.
      ***********/
    
    /*
    Constructor will prepare Business unit filter
                 TG filetr
                 Specie Fileter
                 Lists which are displaying in Business unit tab and Specie tab
    
    This consturcotr mainly diveided into two blocks
    one is EUAFME Blocks another is CLAR block          
    
    */
    public ZTS_EU_Account_Penetration_Calculation(ApexPages.StandardController controller) {
            
        try{
           pageNumBU =1;
           rowsPerPage = 10;
           pageNumSP =1;
          
           appQueryString = ZTS_EU_Constants.appFields; 
           productUniqueIdRecordtype = new map<string, string>();
          
           /* Getting parameters values */
           accountId = ApexPages.currentPage().getParameters().get('accountId');
            accountName = ApexPages.currentPage().getParameters().get('accountName');
            string potentialRegionParam = ApexPages.currentPage().getParameters().get('potentialRegion');
            
            if(potentialRegionParam != null && potentialRegionParam != ''){
              potentialRegion = Integer.valueOf(potentialRegionParam);
            }
            uniqueIdBrandName = new map<string, string>(); 
            
          
            Map<String,Double> brandPot = new Map<String,Double>();
            Map<String,String> brandCurrency = new Map<String,String>();
            Set<String> speciesIdSet   = new Set<String>();
            List<String> speciesIdList = new List<String>();
            tgGroup = new List<BusinessUnitsCheckBoxWrapper>();
            tgGroupSpecies = new List<BusinessUnitsCheckBoxWrapper>();
            businessUnits = new List<BusinessUnitsCheckBoxWrapper>();
            species = new List<BusinessUnitsCheckBoxWrapper>();
           
           
           
            Set<String> businessUnitsSet = new Set<String>();
            Set<String> tgGroupSet = new Set<String>();            
            allUnitsSpeciesList = new List<BusinessUnitWrapper>();
            allSpeciesList = new List<BusinessUnitWrapper>();
            
           // Fetch the Market from Existing Account //R added/
           if(accountId != null && accountId != ''){
             accountMarket = [select name,ZTS_EU_Market__c,Id from Account where Id =: accountId AND ZTS_EU_Market__c != 'United States'].ZTS_EU_Market__c;  
           }
           
            // Fetch the custom settings data for Potential Level //R added/ 
            if(string.isNotBlank(accountMarket)){
                MarketGeoMapping__c cusMarkets = MarketGeoMapping__c.getValues(accountMarket);
                if(cusMarkets != null){
                  prodPotLevel = cusMarkets.Product_Potential_Level__c;
                  geoLevel = cusMarkets.Geo__c;  
                  product_Potential_Level = cusMarkets.Product_Potential_Level__c;
                }
            }

            //Fetch Account Species Potential against account
            List<ZTS_EU_Account_Species_Potential__c> acctSpeciesPot = [SELECT ZTS_EU_Animal_Consultations_new__c, ZTS_EU_Animals_Consultations_actual__c, Account__c, ZTS_EU_Species_Potential__c, ZTS_EU_Species_Potential__r.Name,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name,ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__c FROM ZTS_EU_Account_Species_Potential__c WHERE Account__c = : accountId]; 
            
            for(ZTS_EU_Account_Species_Potential__c asp : acctSpeciesPot){
                speciesIdSet.add(asp.ZTS_EU_Species_Potential__c);
                if(speciesAnimalConsultMap.get(asp.ZTS_EU_Species_Potential__r.Name) != null){
                    speciesAnimalConsultMap.put(asp.ZTS_EU_Species_Potential__r.Name, (speciesAnimalConsultMap.get(asp.ZTS_EU_Species_Potential__r.Name) + asp.ZTS_EU_Animals_Consultations_actual__c));
                } else 
                    speciesAnimalConsultMap.put(asp.ZTS_EU_Species_Potential__r.Name,asp.ZTS_EU_Animals_Consultations_actual__c);
            }
            
           
            
            speciesIdList.addAll(speciesIdSet);
            
            
            
            
            List<ZTS_EU_Sales__c> salesList = [SELECT ZTS_EU_Product__r.Name,ZTS_EU_Total_MAT_Current_Sales__c, ZTS_EU_Total_CYTD_Sales__c, ZTS_EU_Total_PYTD_Sales__c, ZTS_EU_Total_MAT_Prior_Sales__c from ZTS_EU_Sales__c WHERE ZTS_EU_Account__c = : accountId];
            
            for (ZTS_EU_Sales__c sales : salesList)  {
                brandNameSalesMap.put(sales.ZTS_EU_Product__r.Name,sales);
            }
        
        
                
        //if(geoLevel.equalsIgnoreCase('EUAFME')){                
            // below codeis used to fetch potential for species.
      species = getSpeciesCheckboxList(speciesAnimalConsultMap);
      
      string qrystrng = 'select '+ZTS_EU_Constants.potentialPRoductFields+' FROM ZTS_EU_Potential_Brands__c'+
                ' WHERE Potential__c =: speciesIdList and Brand__r.ZTS_EU_Product_Potential_Level__c =: prodPotLevel ORDER BY Brand__r.Name';
            list<ZTS_EU_Potential_Brands__c> potBrands = new list<ZTS_EU_Potential_Brands__c>();
            potBrands = database.query(qrystrng);
            bwObjList = new list<BusinessUnitWrapper>();
            
            
            for(ZTS_EU_Potential_Brands__c pb : potBrands){
               //For Business Unit Checkboxes in BU tab
               // creates data for filter section of Business units
                if(!businessUnitsSet.contains(pb.Potential__r.ZTS_EU_Business_Unit__r.Name)){
                    BusinessUnitsCheckBoxWrapper bucWrap = new BusinessUnitsCheckBoxWrapper();
                    bucWrap.unitName = pb.Potential__r.ZTS_EU_Business_Unit__r.Name ;
                    bucWrap.unitSelect = true ;
                    businessUnits.add(bucWrap);
                }
                // creates data for filter section of TG group
                if(!TGgroupSet.contains(pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name)){
                    BusinessUnitsCheckBoxWrapper tgWrapForBU = new BusinessUnitsCheckBoxWrapper();
                    BusinessUnitsCheckBoxWrapper tgWrapForSpecies = new BusinessUnitsCheckBoxWrapper();
                    tgWrapForBU.unitName = pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name != null &&
                                      pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name != '' ?pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name:'--None--';
                    tgWrapForBU.unitSelect = true ;
                    tgWrapForSpecies.unitName = pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name != null &&
                                      pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name != '' ?pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name:'--None--';
                    tgWrapForSpecies.unitSelect = true ;
                    tgGroup.add(tgWrapForBU);
                    tgGroupSpecies.add(tgWrapForSpecies);
                }
                
            
                tgGroupSet.add(pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name);
                businessUnitsSet.add(pb.Potential__r.ZTS_EU_Business_Unit__r.Name );
                BusinessUnitWrapper bwObj = new BusinessUnitWrapper();
                bwObj.brandName = pb.Brand__r.Name;
                bwObj.speciesName = pb.Potential__r.Name;
                bwObj.currncy = pb.CurrencyIsoCode;
                bwObj.unitName = pb.Potential__r.ZTS_EU_Business_Unit__r.Name ;
               
                if(potentialRegion == 1)
                    bwObj.potential = speciesAnimalConsultMap.get(pb.Potential__r.Name) * pb.ZTS_EU_Value_Region_1__c;
                else if(potentialRegion == 2)
                    bwObj.potential = speciesAnimalConsultMap.get(pb.Potential__r.Name) * pb.ZTS_EU_Value_Region_2__c;
                else if(potentialRegion == 3)
                    bwObj.potential = speciesAnimalConsultMap.get(pb.Potential__r.Name) * pb.ZTS_EU_Value_Region_3__c;
                else if(potentialRegion == 4)
                    bwObj.potential = speciesAnimalConsultMap.get(pb.Potential__r.Name) * pb.ZTS_EU_Value_Region_4__c;
               
                bwObj.MAT = 0;
                bwObj.Penetration = 0;
                bwObjList.add(bwObj);
                
                Double potential = 0.0;
                if(brandPot.get( pb.Brand__r.Name) != null){
                    potential = bwObj.potential + brandPot.get( pb.Brand__r.Name);
                    if(pb.Brand__r.RecordType.DeveloperName == product_Potential_Level){
                      brandPot.put(pb.Brand__r.Name,potential);
                    }
                } else {
                  if(pb.Brand__r.RecordType.DeveloperName == product_Potential_Level){
                      brandPot.put(pb.Brand__r.Name,bwObj.potential);
                  }
                }
               
                brandCurrency.put(pb.Brand__r.Name,pb.CurrencyIsoCode);
                Set<String> bu = new Set<String>();
                if(allBrandBU.get(pb.Brand__r.Name) != null){
                    bu = allBrandBU.get(pb.Brand__r.Name);
                    bu.add( pb.Potential__r.ZTS_EU_Business_Unit__r.Name);
                    allBrandBU.put(pb.Brand__r.Name,bu);
                } else {
                    bu.add( pb.Potential__r.ZTS_EU_Business_Unit__r.Name);
                    allBrandBU.put(pb.Brand__r.Name,bu);
                }

                Set<String> speciesNames = new Set<String>();
                if(allBrandSpecies.get(pb.Brand__r.Name) != null){
                    speciesNames = allBrandSpecies.get(pb.Brand__r.Name);
                    speciesNames.add( pb.Potential__r.Name);
                    allBrandSpecies.put(pb.Brand__r.Name,speciesNames);
                } else {
                    speciesNames.add( pb.Potential__r.Name);
                    allBrandSpecies.put(pb.Brand__r.Name,speciesNames);
                }
            }
             
            List<String> sortAsPerBrandName = new List<String>();
            sortAsPerBrandName.addAll(brandPot.keySet());
            sortAsPerBrandName.sort();
            //so here you will get sorted as per brand name
      
      clearAllTotals();            

            for(String bName : sortAsPerBrandName){
                BusinessUnitWrapper brandUnitWrapper = new BusinessUnitWrapper();
                brandUnitWrapper.brandName = bName;
                brandUnitWrapper.potential = brandPot != null && brandPot.get(bName)!= null ?brandPot.get(bName):0;
                totalPotential = totalPotential+brandUnitWrapper.potential;
                brandUnitWrapper.MAT = brandNameSalesMap != null && brandNameSalesMap.get(bName) != null ? brandNameSalesMap.get(bName).ZTS_EU_Total_MAT_Current_Sales__c : 0;
                totalMAT = totalMAT+brandUnitWrapper.MAT;
                brandUnitWrapper.CYTD_Sales = brandNameSalesMap != null && brandNameSalesMap.get(bName) != null ? brandNameSalesMap.get(bName).ZTS_EU_Total_CYTD_Sales__c : 0;
                totalCYTDSales = totalCYTDSales+brandUnitWrapper.CYTD_Sales;
                brandUnitWrapper.PYTD_Sales = brandNameSalesMap != null && brandNameSalesMap.get(bName) != null ? brandNameSalesMap.get(bName).ZTS_EU_Total_PYTD_Sales__c : 0;
                totalPYTDSales = totalPYTDSales+brandUnitWrapper.PYTD_Sales;
                brandUnitWrapper.MAT_Prior_Sales = brandNameSalesMap != null && brandNameSalesMap.get(bName) != null ? brandNameSalesMap.get(bName).ZTS_EU_Total_MAT_Prior_Sales__c : 0;
                totalMATPriorSales = totalMATPriorSales+brandUnitWrapper.MAT_Prior_Sales;
                brandUnitWrapper.opportunityGap = brandUnitWrapper.potential - brandUnitWrapper.MAT;
                brandUnitWrapper.currncy = brandCurrency != null && brandCurrency.get(bName) != null ? brandCurrency.get(bName) : '';
                brandUnitWrapper.Penetration =Decimal.valueOf(brandUnitWrapper.MAT != null && brandPot.get(bName) != null && brandPot.get(bName) > 0 ? (brandUnitWrapper.MAT/brandPot.get(bName))*100 : 0).setScale(1);
                allUnitsSpeciesList.add(brandUnitWrapper);
                allSpeciesList.add(brandUnitWrapper);
            }
            system.debug('allUnitsSpeciesList>>'+allUnitsSpeciesList);
            system.debug('allSpeciesList>>>'+allSpeciesList);
       /*}else if(geoLevel.equalsIgnoreCase('CLAR')){   
              string qryString = 'select '+ appQueryString + 'from ZTS_EU_Account_Product_Potential__c where Account__c =:accountId order by Product_Hierarchy__r.Name';
             list<ZTS_EU_Account_Product_Potential__c> potAPB = new list<ZTS_EU_Account_Product_Potential__c>();
             potAPB = dataBase.query(qryString);
              businessUnitsSet = new Set<String>();
              tgGroupSet = new set<string>();
              set<string> speciesSet = new set<string>(); // to avaoid duplicates in species list
              system.debug('potAPB>>'+potAPB.size());
              if(!potAPB.isEmpty()){
                set<string> productUniqueIds = new set<string>();
                for(ZTS_EU_Account_Product_Potential__c Ap: potAPB){
                  for(integer i=1;i<=160;i++){
                    productUniqueIds.add((String)Ap.get('ZTS_EU_Product_ID_'+ i + '__c'));
                  }
                }
                
                
                if(!productUniqueIds.isEmpty()){
                  map<id, ZTS_EU_Species_Product__c> phMap = new map<id,ZTS_EU_Species_Product__c>([select id, ZTS_EU_Product_Unique_ID__c, RecordType.DeveloperName from ZTS_EU_Species_Product__c where ZTS_EU_Product_Unique_ID__c in:productUniqueIds]);
                  map<string, string> prodIdRecordtypeName = new map<string, string>();
                  for(ZTS_EU_Species_Product__c ph : phMap.values()){
                    prodIdRecordtypeName.put(ph.ZTS_EU_Product_Unique_ID__c, ph.RecordType.DeveloperName);
                  }
                  
                  
                  for(ZTS_EU_Species_Product__c prod: [select ZTS_EU_Product_Unique_ID__c,id, name,ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.name from ZTS_EU_Species_Product__c where ZTS_EU_Product_Unique_ID__c=:productUniqueIds]){
                    uniqueIdBrandName.put(prod.ZTS_EU_Product_Unique_ID__c,prod.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.name);
                  }
                  
                  
                  for(ZTS_EU_Account_Product_Potential__c Ap: potAPB){
                    for(integer i=1;i<=160;i++){ 
                      if(prodIdRecordtypeName.get((String)Ap.get('ZTS_EU_Product_ID_'+ i + '__c')) != null){
                        productUniqueIdRecordtype.put((String)Ap.get('ZTS_EU_Product_ID_'+ i + '__c'),prodIdRecordtypeName.get((String)Ap.get('ZTS_EU_Product_ID_'+ i + '__c')));
                      }
                    }
                  }
                }
                
                system.debug('>>productUniqueIdRecordtype>>'+productUniqueIdRecordtype);
                
                
                
                  for(ZTS_EU_Account_Product_Potential__c Ap: potAPB){
                      if(Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name != null && !businessUnitsSet.contains(Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name)){
                     BusinessUnitsCheckBoxWrapper bucWrap = new BusinessUnitsCheckBoxWrapper();
                      bucWrap.unitName = Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name;
                      bucWrap.unitSelect = true;
                      businessUnits.add(bucWrap);
                      businessUnitsSet.add(Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name);
                   }
                      if(Ap.Product_Hierarchy__r.name != null && !tgGroupSet.contains(Ap.Product_Hierarchy__r.Name)){
                        BusinessUnitsCheckBoxWrapper tgWrapForBU = new BusinessUnitsCheckBoxWrapper();
                        BusinessUnitsCheckBoxWrapper tgWrapForSpecies = new BusinessUnitsCheckBoxWrapper();
                        tgWrapForBU.unitName = Ap.Product_Hierarchy__r.Name ;
                        tgWrapForBU.unitSelect = true;
                        tgWrapForSpecies.unitName = Ap.Product_Hierarchy__r.Name ;
                        tgWrapForSpecies.unitSelect = true;
                        tgGroup.add(tgWrapForBU);
                        tgGroupSpecies.add(tgWrapForSpecies);
                        tgGroupSet.add(Ap.Product_Hierarchy__r.Name);
                    }  
                    if(Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.name != null && !speciesSet.contains(Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.name)){
                        BusinessUnitsCheckBoxWrapper tgWrap = new BusinessUnitsCheckBoxWrapper();
                        tgWrap.unitName = Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.name;
                        tgWrap.unitSelect = true;
                        species.add(tgWrap);
                        speciesSet.add(Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.name);
                    }
                  } // End of outer loop for potAPB
                  allUnitsSpeciesList = generateWapperList(potAPB);
              allSpeciesList.addAll(allUnitsSpeciesList);
              
              
              } // End of outer IF condition
            }//End of If for CLAR */
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }catch(Exception ex) {
                System.debug('The following exception has occurred: ' + ex.getMessage());
        }
    } // End of consturctor

    
    
    /*Below method is used to reRender the Therputic Group Checkboxes , when Business units are selected/Unselected   */
  public pageReference reRenderTGSectionInBUTab(){
    set<string> businessUnit = new set<string>(); // Selected BU will store in this set to query updated TG values
       for(businessUnitsCheckBoxWrapper bc : businessUnits){
         if(bc.unitSelect == true){
           businessUnit.add(bc.unitName); // Selected BU
         }
       }
       tgGroup.clear();
       Set<String> tgGroupSet = new Set<String>();
       
       string qryString = 'select '+ appQueryString + 'from ZTS_EU_Account_Product_Potential__c where Account__c =:accountId and'+
                 ' Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name =:businessUnit order by Product_Hierarchy__r.Name';
       
       list<ZTS_EU_Account_Product_Potential__c> tmp = new list<ZTS_EU_Account_Product_Potential__c>();
       tmp = dataBase.query(qryString);
       
       /* resetting TG filter values*/
       for(ZTS_EU_Account_Product_Potential__c Ap:tmp){
         if(!TGgroupSet.contains(Ap.Product_Hierarchy__r.Name) ){
               BusinessUnitsCheckBoxWrapper tgWrap = new BusinessUnitsCheckBoxWrapper();
               tgWrap.unitName = Ap.Product_Hierarchy__r.Name;
               tgWrap.unitSelect = true ;
               tgGroup.add(tgWrap);
               tgGroupSet.add(Ap.Product_Hierarchy__r.Name);
         }
       }
       
    return null; 
  }
  
  
  /*Below method is used to reRender the Therputic Group Checkboxes , when species are selected/Unselected   */
  public pageReference reRenderTGSectionInSpecieTab(){
    set<string> selectedSpecies = new set<string>(); // selecte species will store in this set to query updated TG values
       for(businessUnitsCheckBoxWrapper bc : species){
         if(bc.unitSelect == true){
           selectedSpecies.add(bc.unitName); // Selected Specie
         }
       }
       tgGroupSpecies.clear();
       Set<String> tgGroupSet = new Set<String>();
       
       string qryString = 'select '+ appQueryString + 'from ZTS_EU_Account_Product_Potential__c where Account__c =:accountId and'+
                 ' Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.name =:selectedSpecies order by Product_Hierarchy__r.Name';
       
       list<ZTS_EU_Account_Product_Potential__c> tmp = new list<ZTS_EU_Account_Product_Potential__c>();
       tmp = dataBase.query(qryString);
       /* resetting TG filter values*/
       for(ZTS_EU_Account_Product_Potential__c Ap:tmp){
         if(!TGgroupSet.contains(Ap.Product_Hierarchy__r.Name) ){
               BusinessUnitsCheckBoxWrapper tgWrap = new BusinessUnitsCheckBoxWrapper();
               tgWrap.unitName = Ap.Product_Hierarchy__r.Name;
               tgWrap.unitSelect = true ;
               tgGroupSpecies.add(tgWrap);
               tgGroupSet.add(Ap.Product_Hierarchy__r.Name);
         }
       }
    return null;
  }

  /*Start: Pagination related changes in Business unit Tab */  
  
  /*Varriable suffix with "BU" will be used in businees unit tab only */
  public integer pageNumBU; // Current page number
  public integer getpageNumBU(){ 
    return pageNumBU;
  }
  
  public integer totalNumOfPagesBU; // Total number of pages
  
  public integer gettotalNumOfPagesBU(){
    return totalNumOfPagesBU;
  }
  
  /* RecordsByBU will hold list of records, which are displaying on pageblock table   in business unit tab*/
  public List<BusinessUnitWrapper> getRecordsByBU(){
        List<BusinessUnitWrapper> rows = new List<BusinessUnitWrapper>();
        
        integer s = (pageNumBU-1)*rowsPerPage;
        integer e = pageNumBU * rowsPerPage;   
        totalNumOfPagesBU = (allUnitsSpeciesList .size()/10);
        
        if(Math.mod(allUnitsSpeciesList .size(),10) > 0){
            totalNumOfPagesBU = totalNumOfPagesBU +1;
        }
        if(allUnitsSpeciesList.size() < e){
            e = allUnitsSpeciesList.size();
        }
        for(integer i=s;i<e;i++){
            rows.add(allUnitsSpeciesList[i]);
        }
         
        return rows;

    }
    /* indicates whether previous link need to be highlighted as Link or not*/
    public boolean getshowPrevBU(){
      boolean showPrev;
      if(pageNumBU == 1){
            showPrev= false;
        }else{
            showPrev = true;
        }
        return showPrev;
    }
    /* indicates whether next link need to be highlighted as Link or not*/
    public boolean getshowNextBU(){
      boolean showNext;
      if(pageNumBU == totalNumOfPagesBU){
            showNext= false;
        }else if(allUnitsSpeciesList .size() != 0 ){
            showNext = true;
        }
        return showNext;
    }
  

  /*Will redirect to next page */
  public pageReference nextBU(){
    pageNumBU = pageNumBU +1;
    return null;
  }
  /*Will redirect to previous page */
  public pageReference previousBU(){
    pageNumBU = pageNumBU -1;
    return null;
  }
  /*Will redirect to first page */
  public pageReference goToFirstPageBU(){
    pageNumBU = 1;
    return null;
  }
  /*Will redirect to last page */
  public pageReference goToLastPageBU(){
    pageNumBU = totalNumOfPagesBU;
    return null;
  }
  
  
  
  /*End: Pagination related changes in Business unit Tab  */
  
  /*Start: Pagination related changes in Specie Tab  */
  /*Varriable suffix with "SP" will be used in specie tab only */
  public List<BusinessUnitWrapper> getRecordsBySP(){
        List<BusinessUnitWrapper> rows = new List<BusinessUnitWrapper>();
         
        integer s = (pageNumSP-1)*rowsPerPage;
        integer e = pageNumSP * rowsPerPage;   
        totalNumOfPagesSP = (allSpeciesList .size()/10);
        if(Math.mod(allSpeciesList .size(),10) > 0){
            totalNumOfPagesSP = totalNumOfPagesSP +1;
        }
        if(allSpeciesList.size() < e){
            e = allSpeciesList.size();
        }
        for(integer i=s;i<e;i++){
            rows.add(allSpeciesList[i]);
        }
        return rows;

    }
  
  public integer rowsPerPage; //To decide how many records need to be diplayed in page
  
  /*Will redirect to next page */
  public pageReference nextSP(){
    pageNumSP = pageNumSP +1;
    return null;
  }
  
  /*Will redirect to previous page */
  public pageReference previousSP(){
    pageNumSP = pageNumSP -1;
    return null;
  }
  /*Will redirect to first page */
  public pageReference goToFirstPageSP(){
    pageNumSP = 1;
    return null;
  }
  /*Will redirect to last page */
  public pageReference goToLastPageSP(){
    pageNumSP = totalNumOfPagesSP;
    return null;
  }
  
  public integer pageNumSP; // Current page number
  public integer getpageNumSP(){
    return pageNumSP;
  }
  
  public integer totalNumOfPagesSP; // total number of pages
  public integer gettotalNumOfPagesSP(){
    return totalNumOfPagesSP;
  }
  
  public boolean getshowPrevSP(){
      boolean showPrev;
      if(pageNumSP == 1){
            showPrev= false;
        }else{
            showPrev = true;
        }
        return showPrev;
    }
    
    public boolean getshowNextSP(){
      boolean showNext;
      if(pageNumSP == totalNumOfPagesSP){
            showNext= false;
        }else if(allSpeciesList .size() != 0){
            showNext = true;
        }
        return showNext;
    }

  /*End: Pagination related changes in Specie Tab  */
  
  
  /* Util method to clear below varriables */
    public void clearAllTotals(){
      totalPotential = 0.0;
        totalCYTDSales = 0.0;
        totalPYTDSales = 0.0;
        totalMAT  =  0.0;
        totalMATPriorSales = 0.0;
    }
    
    /*Redirect to EUAFME /CLAR code based on geo location */
    public void refreshData(){ 
      clearAllTotals();  
      //if(geoLevel.equalsIgnoreCase('EUAFME')){ 
        filterDataAll();
      //}else if(geoLevel.equalsIgnoreCase('CLAR')){
        //filterDataAllCLARBusinessUnitTab();
      //}
    }
    /*Redirect to EUAFME /CLAR code based on geo location */
    public void refreshSpeciesTab(){ 
      clearAllTotals();  
      //if(geoLevel.equalsIgnoreCase('EUAFME')){ 
        filterDataAll();
      //}else if(geoLevel.equalsIgnoreCase('CLAR')){
        //filterDataAllCLARSpeciesTab();
      //}
    }
    
    /* Filters SKU Potential and Penetration list (allSpeciesList) in specie tab */
    public pageReference filterDataAllCLARSpeciesTab(){
       try{        
           set<string> selectedSpecies = new set<string>();
           set<string> selectedTg = new set<string>();
           for(businessUnitsCheckBoxWrapper bc : species){
             if(bc.unitSelect == true){
               selectedSpecies.add(bc.unitName);
             }
           }
           
           for(BusinessUnitsCheckBoxWrapper bc : tgGroupSpecies){
             if(bc.unitSelect == true){
               selectedTg.add(bc.unitName);
             }
           }
           system.debug('selectedSpecies>>>'+selectedSpecies);
           system.debug('selectedTg>>>'+selectedTg);
           
           string qryString = 'select '+ appQueryString + 'from ZTS_EU_Account_Product_Potential__c where Account__c =:accountId'+
                     ' and Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.name In:selectedSpecies'+
                     ' and Product_Hierarchy__r.name In:selectedTg order by Product_Hierarchy__r.Name'; 
           
           list<ZTS_EU_Account_Product_Potential__c> potAPB = new list<ZTS_EU_Account_Product_Potential__c>();
           potAPB = dataBase.query(qryString);
      
      
      //allUnitsSpeciesList = new List<BusinessUnitWrapper>();
            allSpeciesList = new List<BusinessUnitWrapper>();
      if(!potAPB.isEmpty()){
        allSpeciesList = generateWapperList(potAPB);
      } 
      
       }catch(DmlException e) {
           System.debug('The following exception has occurred: ' + e.getMessage());
       }
       return null;
    }
    
    /* Filters SKU Potential and Penetration list (allUnitsSpeciesList) in business unit tab */
  public pageReference filterDataAllCLARBusinessUnitTab(){
       try{        
           set<string> selectedSpecies = new set<string>();
           set<string> selectedTg = new set<string>();
           for(businessUnitsCheckBoxWrapper bc : businessUnits){
             if(bc.unitSelect == true){
               selectedSpecies.add(bc.unitName);
             }
           }
           system.debug('tgGroup>>>'+tgGroup);
           for(BusinessUnitsCheckBoxWrapper bc : tgGroup){
             if(bc.unitSelect == true){
               selectedTg.add(bc.unitName);
             }
           }
           
           system.debug('selectedSpecies>:>>'+selectedSpecies);
           system.debug('selectedTg>>>'+selectedTg);
           
           string qryString = 'select '+ appQueryString + 'from ZTS_EU_Account_Product_Potential__c where Account__c =:accountId'+
                     ' and Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.ZTS_EU_Business_Unit__r.name In:selectedSpecies'+
                     ' and Product_Hierarchy__r.name In:selectedTg order by Product_Hierarchy__r.Name'; 
           
           list<ZTS_EU_Account_Product_Potential__c> potAPB = new list<ZTS_EU_Account_Product_Potential__c>();
           potAPB = dataBase.query(qryString);
      system.debug('potAPB>>>'+potAPB.size());
      allUnitsSpeciesList = new List<BusinessUnitWrapper>();
            //allSpeciesList = new List<BusinessUnitWrapper>();
      if(!potAPB.isEmpty()){
        allUnitsSpeciesList = generateWapperList(potAPB);
      } 
      
       }catch(DmlException e) {
           System.debug('The following exception has occurred: ' + e.getMessage());
       }
       return null;
    }
    
      /***********
            * Method Name  : filterData
            * Description  : Method is used filter data as per the Business Units/ Species
            * Return Type  : None.
            * Parameters   : none.
      ***********/
      
      
      
    public pageReference filterDataForTGSection(){
       try{
           String filterType = apexpages.currentpage().getparameters().get('businessUnit');
           system.debug('filterType>>'+filterType);
           if(filterType != null && filterType != ''){
             List<String> filterList = new List<String>();
             List<String> speciesList = new List<String>();
             List<String> tgGroupList = new List<String>();
             Set<String> tgGroupSet = new Set<String>();
             Map<String,Set<String>> brandBU = new Map<String,Set<String>>();
             system.debug('businessUnits>>'+businessUnits);
             system.debug('species>>'+species);
             for(businessUnitsCheckBoxWrapper bcbw : filterType.equals('businessUnit')?businessUnits:species){
                 system.debug('bcbw>>>'+bcbw);
                  if(bcbw.unitSelect){
                      filterList.add(filterType.equals('businessUnit')?bcbw.unitName:bcbw.unitName.substring(0,bcbw.unitName.IndexOf(' (')));
                      system.debug('In if condition');
                  }
              }
              speciesList.addAll(speciesAnimalConsultMap.keySet());
              string potentialQuery;
              if(filterType.equals('businessUnit')){
                tgGroup = new List<BusinessUnitsCheckBoxWrapper>();
               potentialQuery= 'SELECT Brand__c, Brand__r.Name, Brand__r.ZTS_EU_Parent_Species_Product__r.Name, Potential__r.Name, Potential__r.ZTS_EU_Business_Unit__r.Name, Potential__c FROM ZTS_EU_Potential_Brands__c WHERE Potential__r.ZTS_EU_Business_Unit__r.Name in:filterList ORDER BY Brand__r.Name';
              }else{
                tgGroupSpecies= new List<BusinessUnitsCheckBoxWrapper>();
                potentialQuery= 'SELECT Brand__c, Brand__r.Name, Brand__r.ZTS_EU_Parent_Species_Product__r.Name, Potential__r.Name, Potential__r.ZTS_EU_Business_Unit__r.Name, Potential__c FROM ZTS_EU_Potential_Brands__c WHERE Potential__r.Name in:filterList ORDER BY Brand__r.Name';
              }
              // below code is used to fetch potential for species
              list<ZTS_EU_Potential_Brands__c> potBrands = Database.query(potentialQuery);
               
              bwObjList = new List<BusinessUnitWrapper>();
              for(ZTS_EU_Potential_Brands__c pb : potBrands){
                  //For Business Unit Checkboxes in BU tab
                  // creates data for filter section of TG group
                  if(pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name != null && !TGgroupSet.contains(pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name)){
                      
                      BusinessUnitsCheckBoxWrapper tgWrap = new BusinessUnitsCheckBoxWrapper();
                      tgWrap.unitName = pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name ;
                      tgWrap.unitSelect = true;
                      if(filterType.equals('businessUnit')){
                    tgGroup.add(tgWrap);
                  }else{
                    tgGroupSpecies.add(tgWrap);
                  }
                  }
                  tgGroupSet.add(pb.Brand__r.ZTS_EU_Parent_Species_Product__r.Name);
               }
           }
        } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        } catch(Exception ex) {
                System.debug('The following exception has occurred: ' + ex.getMessage());
        }
        return null;
    }
    /***********
            * Method Name  : filterDataAll
            * Description  : Method is used filter data as per the Business Units/ Species
            * Return Type  : None.
            * Parameters   : none.
      ***********/
      
    public pageReference filterDataAll(){
       try{
           String filterType = apexpages.currentpage().getparameters().get('businessUnit');
           list<String> speciesList = new list<String>();
           Map<String,Double> brandPot = new Map<String,Double>();
           Map<String,String> brandCurrency = new Map<String,String>();
           List<String> filterList = new List<String>();
           List<String> tgGroupList = new List<String>();
           Map<String,Set<String>> brandBU = new Map<String,Set<String>>();
           for(businessUnitsCheckBoxWrapper bcbw : filterType.equals('businessUnit')?businessUnits:species){
                if(bcbw.unitSelect){
                    filterList.add(filterType.equals('businessUnit')?bcbw.unitName:bcbw.unitName.substring(0,bcbw.unitName.IndexOf(' (')));
                }
            }
            
            for(businessUnitsCheckBoxWrapper bcbw : filterType.equals('businessUnit')?tgGroup:tgGroupSpecies){
                if(!bcbw.unitSelect){
                    tgGroupList.add(bcbw.unitName);
                }
            }

            speciesList.addAll(speciesAnimalConsultMap.keySet());

            String potentialQuery = 'SELECT Brand__c, CurrencyIsoCode, Brand__r.Name, Brand__r.ZTS_EU_Parent_Species_Product__r.Name, Potential__r.Name, Potential__r.ZTS_EU_Business_Unit__r.Name, Potential__c,'+ 
            ' ZTS_EU_Value_Region_1__c, ZTS_EU_Value_Region_2__c, ZTS_EU_Value_Region_3__c, ZTS_EU_Value_Region_4__c'+
            ' FROM ZTS_EU_Potential_Brands__c WHERE ' + (filterType.equals('businessUnit') ?'Potential__r.Name IN :speciesList AND Potential__r.ZTS_EU_Business_Unit__r.Name ':'Potential__r.Name')+'  IN :filterList '+
             (tgGroupList.size()>0 ?' AND Brand__r.ZTS_EU_Parent_Species_Product__r.Name NOT IN :tgGroupList':'')+' and Brand__r.ZTS_EU_Product_Potential_Level__c =: prodPotLevel ORDER BY Brand__r.Name';

             system.debug('***********potentialQuery*****************'+potentialQuery);
            // below code is used to fetch potential for species
            List<ZTS_EU_Potential_Brands__c> potBrands = Database.query(potentialQuery);
            system.debug('***********potBrands*****************'+potBrands.size());
            bwObjList = new List<BusinessUnitWrapper>();
          
            for(ZTS_EU_Potential_Brands__c pb : potBrands){
            //For Business Unit Checkboxes in BU tab
                BusinessUnitWrapper bwObj = new BusinessUnitWrapper();
                bwObj.brandName = pb.Brand__r.Name;
                bwObj.speciesName = pb.Potential__r.Name;
                bwObj.currncy = pb.CurrencyIsoCode;
                bwObj.unitName = pb.Potential__r.ZTS_EU_Business_Unit__r.Name ;
                system.debug('*************1111111111111*****'+pb.Potential__r.ZTS_EU_Business_Unit__r.Name);
                system.debug('*************pb.Potential__r.Name*****'+pb.Potential__r.Name);
                if(potentialRegion == 1)
                    bwObj.potential = speciesAnimalConsultMap.get(pb.Potential__r.Name) * pb.ZTS_EU_Value_Region_1__c;
                else if(potentialRegion == 2)
                    bwObj.potential = speciesAnimalConsultMap.get(pb.Potential__r.Name) * pb.ZTS_EU_Value_Region_2__c;
                else if(potentialRegion == 3)
                    bwObj.potential = speciesAnimalConsultMap.get(pb.Potential__r.Name) * pb.ZTS_EU_Value_Region_3__c;
                else if(potentialRegion == 4)
                    bwObj.potential = speciesAnimalConsultMap.get(pb.Potential__r.Name) * pb.ZTS_EU_Value_Region_4__c;
                bwObj.MAT = 0; 
                bwObj.Penetration = 0;
                bwObjList.add(bwObj);
                 
                Set<String> bu = new Set<String>();
                if(brandBU != null && brandBU.get(pb.Brand__r.Name) != null){
                    bu = brandBU.get(pb.Brand__r.Name);
                    bu.add(filterType.equals('businessUnit')?pb.Potential__r.ZTS_EU_Business_Unit__r.Name:pb.Potential__r.Name);
                    brandBU.put(pb.Brand__r.Name,bu);
                } else {
                   bu.add(filterType.equals('businessUnit')?pb.Potential__r.ZTS_EU_Business_Unit__r.Name:pb.Potential__r.Name);
                   brandBU.put(pb.Brand__r.Name,bu);
                }
              
                Double potential = 0.0;
                if(brandPot.get( pb.Brand__r.Name) != null){
                    potential = bwObj.potential + brandPot.get( pb.Brand__r.Name);
                    brandPot.put(pb.Brand__r.Name,potential);
                } else {
                    brandPot.put(pb.Brand__r.Name,bwObj.potential);
                }
                brandCurrency.put(pb.Brand__r.Name,pb.CurrencyIsoCode);
                            
                  
            }
            ApexPages.Message myMsg;
            allUnitsSpeciesList = new List<BusinessUnitWrapper>();
            allSpeciesList = new List<BusinessUnitWrapper>();
            List<ZTS_EU_Sales__c> salesList = [SELECT ZTS_EU_Product__r.Name,ZTS_EU_Total_MAT_Current_Sales__c, ZTS_EU_Total_CYTD_Sales__c, ZTS_EU_Total_PYTD_Sales__c, ZTS_EU_Total_MAT_Prior_Sales__c from ZTS_EU_Sales__c WHERE ZTS_EU_Account__c = : accountId];
            for (ZTS_EU_Sales__c sales : salesList)  {
                System.debug('TotalSales' + sales.ZTS_EU_Total_MAT_Current_Sales__c);
                System.debug('ZTS_EU_Product__c' + sales.ZTS_EU_Product__r.Name);
                brandNameSalesMap.put(sales.ZTS_EU_Product__r.Name,sales);
            }
            System.debug('brandNameSalesMap*******************' + brandNameSalesMap);
            List<String> sortAsPerBrandName = new List<String>();
            sortAsPerBrandName.addAll(brandPot.keySet());
            sortAsPerBrandName.sort();
            //so here you will get sorted as per brand name
            
            clearAllTotals();
            
            for(String bName : sortAsPerBrandName){
                BusinessUnitWrapper brandUnitWrapper = new BusinessUnitWrapper();
                brandUnitWrapper.brandName = bName;
                brandUnitWrapper.potential = brandPot != null && brandPot.get(bName)!= null ?brandPot.get(bName):0;
                totalPotential = totalPotential+brandUnitWrapper.potential;
                brandUnitWrapper.MAT = brandNameSalesMap != null && brandNameSalesMap.get(bName) != null ? brandNameSalesMap.get(bName).ZTS_EU_Total_MAT_Current_Sales__c : 0;
                totalMAT = totalMAT+brandUnitWrapper.MAT;
                brandUnitWrapper.CYTD_Sales = brandNameSalesMap != null && brandNameSalesMap.get(bName) != null ? brandNameSalesMap.get(bName).ZTS_EU_Total_CYTD_Sales__c : 0;
                totalCYTDSales = totalCYTDSales+brandUnitWrapper.CYTD_Sales;
                brandUnitWrapper.PYTD_Sales = brandNameSalesMap != null && brandNameSalesMap.get(bName) != null ? brandNameSalesMap.get(bName).ZTS_EU_Total_PYTD_Sales__c : 0;
                totalPYTDSales = totalPYTDSales+brandUnitWrapper.PYTD_Sales;
                brandUnitWrapper.MAT_Prior_Sales = brandNameSalesMap != null && brandNameSalesMap.get(bName) != null ? brandNameSalesMap.get(bName).ZTS_EU_Total_MAT_Prior_Sales__c : 0;
                totalMATPriorSales = totalMATPriorSales+brandUnitWrapper.MAT_Prior_Sales;
                brandUnitWrapper.opportunityGap = brandUnitWrapper.potential - brandUnitWrapper.MAT;
                brandUnitWrapper.currncy = brandCurrency != null && brandCurrency.get(bName) != null ? brandCurrency.get(bName) : '';
                brandUnitWrapper.Penetration =Decimal.valueOf(brandUnitWrapper.MAT != null && brandPot.get(bName) != null && brandPot.get(bName) > 0 ? (brandUnitWrapper.MAT/brandPot.get(bName))*100 : 0).setScale(1);
                if(filterType.equals('businessUnit')){
                    allUnitsSpeciesList.add(brandUnitWrapper);
                    system.debug('*************allUnitsSpeciesList**2***'+allUnitsSpeciesList);
                                        
                    //updated if condition part of the defect INC 0436961
                    if(bName != null && brandBU != null && brandBU.get(bName) != null && allBrandBU != null && allBrandBU.get(bName) != null && !(brandBU.get(bName).containsAll(allBrandBU.get(bName)))){
                        system.debug('*******message in***********');
                        myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'Filter selection does not include all potential values for each brand shown. Potential calculation may be too positive for some Brands.');
                    }
                }
                else{
                    allSpeciesList.add(brandUnitWrapper);
                    system.debug('*************allUnitsSpeciesList***2*1*'+allUnitsSpeciesList);
                    if(!(brandBU.get(bName).containsAll(allBrandSpecies.get(bName)))){
                        system.debug('*******message in***********');
                        myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'The selection of filters does not include all potential values for each brand shown. Penetration calculation may be too positive for some these Brands.');
                       
                    }
                }
            }
            
              if(myMsg != null)
                ApexPages.addMessage(myMsg);
                system.debug('*************allUnitsSpeciesList***2**' + myMsg);
        } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        } catch(Exception ex) {
                System.debug('The following exception has occurred: ' + ex.getMessage());
        }
        return null;
    } 
   /***********
              * Method name  : getSpeciesCheckboxList
              * Description  : This will get the Business Unit name/Species available on UI for filtering.
              * Return Type  : List<BusinessUnitCheckBoxWrapper>.
              * Parameters   : Map<species,count>.
   ***********/ 
    public List<BusinessUnitsCheckBoxWrapper> getSpeciesCheckboxList(Map<String,double> speciesAnimalConMap){
        List<BusinessUnitsCheckBoxWrapper> speciesList = new List<BusinessUnitsCheckBoxWrapper>();
        try{
            for(String speciesLabel : speciesAnimalConMap.keySet()){
            
                 BusinessUnitsCheckBoxWrapper bucWrap = new BusinessUnitsCheckBoxWrapper();
                 if(speciesAnimalConMap.get(speciesLabel) != null){
                    bucWrap.unitName = speciesLabel + ' (' + String.valueOf(speciesAnimalConMap.get(speciesLabel)!=null?speciesAnimalConMap.get(speciesLabel).intValue() :0) + ')';
                    bucWrap.unitSelect = true ;
                    speciesList.add(bucWrap);
                 }
            }
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }catch(Exception ex) {
                System.debug('The following exception has occurred: ' + ex.getMessage());
        }
    
        return speciesList;
    }
    
    /***********
            * Class name  : BusinessUnitWrapper
            * Description  : This is the wrapper class maintaining the record details in the UI
            * Return Type  : none.
            * Parameters   : none.
   ***********/
    class BusinessUnitWrapper{
        public String brandName {get;set;}
        public String parentName {get;set;}
        public String currncy {get;set;}
        public double potential {get;set;}
        public double MAT {get;set;}
        public double CYTD_Sales {get;set;}
        public double PYTD_Sales {get;set;}
        public double MAT_Prior_Sales {get;set;}
        public double Penetration {get;set;}
        public double opportunityGap{get;set;}
        public String unitName {get;set;}
        public String speciesName {get;set;}
        
     }
     
     /***********
            * Class name  : BusinessUnitsCheckBoxWrapper
            * Description  : This is the wrapper class maintaining the filter section in the UI
            * Return Type  : none.
            * Parameters   : none.
      ***********/
     class BusinessUnitsCheckBoxWrapper{
        public String unitName {get;set;}
        public boolean unitSelect {get;set;}
     }
 
   //R added / Need to use single 
     class BusinessUnitCLRWrapper{
        public String brandName {get;set;}
        public double potential {get;set;}
        public String speciesName {get;set;}
        public double CYTD_Sales{get;set;}
        public double MAT {get;set;}
     }

     public List<BusinessUnitWrapper> generateWapperList(list<ZTS_EU_Account_Product_Potential__c> potAPB){
        clearAllTotals();
        List<BusinessUnitWrapper> tmp = new List<BusinessUnitWrapper>();
        for(ZTS_EU_Account_Product_Potential__c Ap: potAPB){
            for(integer i=1;i<=160;i++){
              string prodName = (String)Ap.get('ZTS_EU_Product_Name_'+ i + '__c');
              if(prodName != null && prodName != '' && productUniqueIdRecordtype.get((String)Ap.get('ZTS_EU_Product_ID_'+ i + '__c')) != null && productUniqueIdRecordtype.get((String)Ap.get('ZTS_EU_Product_ID_'+ i + '__c')) == product_Potential_Level){ 
                    BusinessUnitWrapper APPRecordField = new BusinessUnitWrapper();
                    APPRecordField.brandName = (String)Ap.get('ZTS_EU_Product_Name_'+ i + '__c');
                    APPRecordField.parentName = ((String)Ap.get('ZTS_EU_Product_Id_'+ i + '__c') != null && uniqueIdBrandName.get((String)Ap.get('ZTS_EU_Product_Id_'+ i + '__c')) != null) ?  uniqueIdBrandName.get((String)Ap.get('ZTS_EU_Product_Id_'+ i + '__c')) : '';
                    APPRecordField.potential = (Double)Ap.get('PAC_'+ i + '__c');
                    totalPotential = totalPotential+APPRecordField.potential;
          
                    APPRecordField.MAT =  brandNameSalesMap != null && brandNameSalesMap.get(Ap.Product_Hierarchy__r.Name) != null ? brandNameSalesMap.get(Ap.Product_Hierarchy__r.Name).ZTS_EU_Total_MAT_Current_Sales__c : 0;
                    totalMAT = totalMAT + APPRecordField.MAT;

                    APPRecordField.CYTD_Sales =  brandNameSalesMap != null && brandNameSalesMap.get(Ap.Product_Hierarchy__r.Name) != null ? brandNameSalesMap.get(Ap.Product_Hierarchy__r.Name).ZTS_EU_Total_CYTD_Sales__c : 0;
                    totalCYTDSales = totalCYTDSales + APPRecordField.CYTD_Sales;
                    
                    APPRecordField.PYTD_Sales = brandNameSalesMap != null && brandNameSalesMap.get(Ap.Product_Hierarchy__r.Name) != null ? brandNameSalesMap.get(Ap.Product_Hierarchy__r.Name).ZTS_EU_Total_PYTD_Sales__c : 0;
                    totalPYTDSales = totalPYTDSales + APPRecordField.PYTD_Sales;
                    
                    APPRecordField.MAT_Prior_Sales = brandNameSalesMap != null && brandNameSalesMap.get(Ap.Product_Hierarchy__r.Name) != null ? brandNameSalesMap.get(Ap.Product_Hierarchy__r.Name).ZTS_EU_Total_MAT_Prior_Sales__c : 0;
                    totalMATPriorSales = totalMATPriorSales + APPRecordField.MAT_Prior_Sales;
                    
                    APPRecordField.opportunityGap = APPRecordField.potential - APPRecordField.MAT;
                    
                    APPRecordField.currncy = Ap.CurrencyIsoCode != null ? Ap.CurrencyIsoCode : '';
                    
                    APPRecordField.Penetration = Decimal.valueOf(APPRecordField.MAT != null && APPRecordField.potential != null && APPRecordField.potential > 0 ? (APPRecordField.MAT/APPRecordField.potential)*100 : 0).setScale(1);
                    
                    APPRecordField.speciesName = Ap.Account_Species_Consultation__r.ZTS_EU_Species_Potential__r.Name;                          
                    
                    //allUnitsSpeciesList.add(APPRecordField);
                    tmp.add(APPRecordField);
              }
            }          
        }
        return tmp;
     }
}
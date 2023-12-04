/**
* File Name     :  AutoBundleDataCollector
* @description  :  A class to take data passed in from a vistex deal and associate all other data needed to create a CPQ bundle. 
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.  Date        Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0   09/09/2019	Cory Bartholomew @ ATG  Created the Class.
* 2.0   02/05/2020	Cory Bartholomew @ ATG  Added descriptions.
* 2.1	06/06/2020	Cesar Sandrigo @ ATG	Added Localization objects for the products related to the Material lines.
* 2.2   06/16/2020  Ramiro Alvarez @ ATG    CPQATG-881: Adding ProductCode to queryProduct 
* 2.3   09/11/2020  Ramiro Alvarez @ ATG    CPQATG-1118: Adding flexibleGroupSuffixMap to support multipiple dealLines in single flexibleGroup
**/

//A class to take data passed in from a vistex deal and associate all other data needed to create a CPQ bundle.  

public with sharing class AutoBundleDataCollector {
    public AutoBundleDataWrapper dealBundleData;
    public Vistex_Deal_Header__c deal;
    public Boolean excludeFromDealCreation = true;  //CPQATG-532
    public List<CPQ_VistexDealValidator.DealValidationResult> validationResults;
    
    public AutoBundleDataCollector() {
    }
    public AutoBundleDataCollector(Vistex_Deal_Header__c deal){
        this.deal = deal;
        this.validationResults = new List<CPQ_VistexDealValidator.DealValidationResult>();
    }
    // Worker method to call and collect all bundle/deal data needed to create a CPQ bundle
    public AutoBundleDataWrapper collectDealBundleData() {
         
        if(this.deal != null) {
             return collectDealBundleData(this.deal);
        }else {        
            return null;
        }
    }
    
    public AutoBundleDataWrapper collectDealBundleData(Vistex_Deal_Header__c dealToProcess) {         
        this.dealBundleData = new AutoBundleDataWrapper(dealToProcess);        
        //Map header info into our bundle data
        this.dealBundleData.bundleName = dealToProcess.DEALTXT__c; //CPQATG-602

        //Check if a parent product has already been created for this deal.  We can assume only 1 product was created
        if(dealToProcess.BundleWrapperProducts__r != null){
            if(dealToProcess.BundleWrapperProducts__r.size() > 0){
                this.dealBundleData.bundleParent = dealToProcess.BundleWrapperProducts__r[0];
            }
        }
        // Populate deal line wrappers
        populateDealLinesWrapperLists(this.dealBundleData.dealLines);
        //Get the Banner and Child Banners into a Map for use later
        //Get the deal text values for English - 'EN'
        processVistexBanners(dealToProcess.Id, 'EN', null);
        return this.dealBundleData;
    }     

    /**
     * @description
     * @param
     */
    private void populateDealLinesWrapperLists(List<Vistex_Deal_Line_E1KOMG__c> dealLines) {

        Map<String, Vistex_Deal_Line_E1KOMG__c> flexibleGroupLinesMap = new Map<String, Vistex_Deal_Line_E1KOMG__c>();
        Map<String, Vistex_Deal_Line_E1KOMG__c> materialLinesMap = new Map<String, Vistex_Deal_Line_E1KOMG__c>();
        Set<Id> materialAndFlexibleGroupLinesSet = new Set<Id>();
        
        Map<String,List<String>> flexibleGroupSuffixMap = new Map<String,List<String>> ();

        for (Vistex_Deal_Line_E1KOMG__c dealLine : dealLines) {
            
            if(dealLine.KSCHL__c.equals('ZDEV') || dealLine.KSCHL__c.equals('ZCON') || dealLine.KSCHL__c.equals('ZANC')) {
                if(!dealLine.KSCHL__c.equals('ZANC')){
                    //if there is a ZDEV or ZCON we want to create the bundle
                    this.excludeFromDealCreation = false;
                }

                // Add to the line set
                materialAndFlexibleGroupLinesSet.add(dealLine.Id);

                // Check if there's a material number associated
                if (!String.isBlank(dealLine.MATNR__c)) {
                    materialLinesMap.put(dealLine.MATNR__c, dealLine);
                }
                // Check if there's a flexible group number
                else if (!String.isBlank(dealLine.LIFNR__c)) {
                    flexibleGroupLinesMap.put(dealLine.LIFNR__c + dealLine.EBONU__c, dealLine);                    
                    // CPQATG-1118 populate flexibleGroupSuffixMap
                    if (!flexibleGroupSuffixMap.containsKey(dealLine.LIFNR__c)){
                        flexibleGroupSuffixMap.put(dealLine.LIFNR__c, new List<String> ());
                    }    
                    flexibleGroupSuffixMap.get(dealLine.LIFNR__c).add(dealLine.EBONU__c);
                    //Assume that if a flexible group exists we want to create the bundle
                    this.excludeFromDealCreation = false; 
                }
            }
            //refactor to remove above unecessary duplicate code
            if(dealLine.KSCHL__c.equals('ZTER')){
                //There is the potential to have multiple ZTER lines.   The assumption is that they would all have the same Term for the Deal
                if(this.dealBundleData.dealTerm == null) {
                    if (dealLine.EKKOA__c != null && dealLine.EKKOA__c.isNumeric()) {
                        this.dealBundleData.dealTerm = Integer.valueOf(dealLine.EKKOA__c);
                    }
                    else {
                        this.dealBundleData.dealTerm = 12; // FIXME: Define a default value!
                    }
                }
            }
            if(dealLine.KSCHL__c.equals('ZEL4')){
                parseVaKey(dealLine.VAKEY__c);
            }

        }
        

        // Query flexible groups and create a map of all the materials for each Flexible Group
        //Map<String, Flexible_Group__c> flexibleGroupMap = queryFlexGroups(flexibleGroupLinesMap.keySet());
        Map<String, Flexible_Group__c> flexibleGroupMap = queryFlexGroups(flexibleGroupSuffixMap.keySet());
        Map<String, Set<String>> flexibleGroupMaterialMap = getFlexibleGroupMaterialNumberMap(flexibleGroupMap.values());

        // Create a set with all the material numbers involved in this bundle
        Set<String> materialNumberSet = new Set<String>();

        // Add materials from Material lines
        materialNumberSet.addAll(materialLinesMap.keySet());

        // Add all the materials related to the Flexible Group (if there's any)
        for (Set<String> flexibleGroupMaterialSet : flexibleGroupMaterialMap.values()) {
            materialNumberSet.addAll(flexibleGroupMaterialSet);
        }

        // Query all the Products
        Map<String, Product2> materialNumberProductMap = queryProducts(materialNumberSet);

        // Query the line conditions objects
        Map<Id, Condition_Header_E1KONH__c> dealLineConditionsMap = queryConditionsForDealLines(materialAndFlexibleGroupLinesSet);

        List<AutoBundleMaterialLineWrapper> materialLineWrapperList = new List<AutoBundleMaterialLineWrapper>();
        List<AutoBundleFlexibleGroupLineWrapper> flexGroupLineWrapperList = new List<AutoBundleFlexibleGroupLineWrapper>();

        for (Vistex_Deal_Line_E1KOMG__c dealLine : materialLinesMap.values()) {
            
            
            AutoBundleMaterialLineWrapper matWrapper = new AutoBundleMaterialLineWrapper(
                dealLine,                                   // Deal Line
                dealLineConditionsMap.get(dealLine.Id),     // Deal Line Condition
                materialNumberProductMap.get(dealLine.MATNR__c) // Product
            );
            this.validationResults.addAll(matWrapper.validationResults);
            materialLineWrapperList.add(matWrapper);
        }

        for (String flexGroupNumber : flexibleGroupSuffixMap.keySet()) {

            //CPQATG-1118 Loop into all suffix with same flexibleGroup
            for (String suffix : flexibleGroupSuffixMap.get(flexGroupNumber)){

                Vistex_Deal_Line_E1KOMG__c dealLine = flexibleGroupLinesMap.get(flexGroupNumber + suffix);
                
                AutoBundleFlexibleGroupLineWrapper flxWrapper = new AutoBundleFlexibleGroupLineWrapper(
                        // Deal Line
                        dealLine,
                        // Deal Line Condition
                        dealLineConditionsMap.get(dealLine.Id),     
                        // Products related with the Flexible Group
                        getProductListFromMaterialProductMap(materialNumberProductMap, flexibleGroupMaterialMap.get(flexGroupNumber))
                    );
                this.validationResults.addAll(flxWrapper.validationResults);    
                flexGroupLineWrapperList.add(flxWrapper);
            }
        }

        System.debug('AutoBundleDataCollector - Material Lines: ' + materialLineWrapperList);
        System.debug('AutoBundleDataCollector - FlexGroup Lines: ' + flexGroupLineWrapperList);

        dealBundleData.FlexibleGroupLines = flexGroupLineWrapperList;
        dealBundleData.MaterialLines = materialLineWrapperList;

        this.validationResults.addAll(CPQ_VistexDealValidator.oneZConFlxGrpPerSuffix(flexGroupLineWrapperList, materialLineWrapperList));
    }    
     /**
     * @description : Takes in a string for VA key and parses out relevant information for use in creating the bundle structure
                      VAKEY is a value only present on the ZEL4 deal line and there should only be 1 ZEL4 line per deal
     * @param : vaKey : the string to parse from the deal line
     */
    public void parseVaKey(String vaKey){
        if(vaKey != null){        
            try{
                System.debug('VAKEY length: ' + VaKey.length());
                this.dealBundleData.dealNumber = vaKey.substring(0,10); //Set as the product code of the parent bundle product
                this.dealBundleData.salesOrganization = vaKey.substring(10,14); //Determines which currencies create standard pricebook entries for
                this.dealBundleData.distributionChannel = vaKey.substring(14,16);
                this.dealBundleData.eligibilityFilter = vaKey.substring(16,vaKey.length());  //Required for integration purposes
            }catch(Exception e){
                ErrorLogUtil.log(e);
                System.debug('VAKEY substring parsing error: ' + e);
            }
        }
    }
    /**
     * @description
     * @param
     * @return
     */
    private static Map<String, Set<String>> getFlexibleGroupMaterialNumberMap(List<Flexible_Group__c> flexibleGroupList) {
        
        Map<String, Set<String>> flexibleGroupMaterialNumberMap = new Map<String, Set<String>>();

        // Add all the materials related to the Flexible Group (if there's any)
        for (Flexible_Group__c flexGroup : flexibleGroupList) {

            if (!flexibleGroupMaterialNumberMap.containsKey(flexGroup.Flexible_Group_Number__c)) {
                flexibleGroupMaterialNumberMap.put(flexGroup.Flexible_Group_Number__c, new Set<String>());
            }

            for (Flexible_Group_Item__c flexGroupItem : flexGroup.Flexible_Group_Items__r) {
                flexibleGroupMaterialNumberMap.get(flexGroup.Flexible_Group_Number__c).add(flexGroupItem.SAP_Material_Number__c);
            }
        }

        return flexibleGroupMaterialNumberMap;
    }

    /**
     * @description
     * @param
     * @return
     */
    private static List<Product2> getProductListFromMaterialProductMap(Map<String, Product2> materialNumberProductMap, Set<String> materialNumberSet) {
        
        System.debug('Entering getProductListFromMaterialProductMap...');
        System.debug('MaterialNumberProductMap: ' + materialNumberProductMap);
        System.debug('materialNumberSet: ' + materialNumberSet);

        List<Product2> productList = new List<Product2>();

        if (materialNumberSet == null || materialNumberSet.isEmpty()){
            return productList;
        }

        for (String materialNumber : materialNumberSet) {
            System.debug('MaterialNumber in loop: ' + materialNumber);

            if (materialNumberProductMap.containsKey(materialNumber)) {
                productList.add(materialNumberProductMap.get(materialNumber));
            }
        }

        return productList;
    }

    /**
     * 
     */
    private static Map<Id,Condition_Header_E1KONH__c> queryConditionsForDealLines(Set<Id> dealLineIds) {

        List<Condition_Header_E1KONH__c> conditionsList = [SELECT Id, DATAB__c, DATBI__c, KNUMA_AG__c, KNUMH__c, E1KOMG_Ext_Id__c,
                                                            (
                                                                SELECT Id, Ship_By__c, ZCOMMIT_QTY__c, ZCOMMIT_TERM__c,
                                                                    ZCOMMIT_VALUE__c, ZCOMMITQTY_UOM__c,Commitment_Change_Approval_Required__c,
                                                                    Aggregate_Commitment_Type__c
                                                                FROM Vistex_ZO2C_E1KONP_CPQ__r
                                                            )
                                                            FROM Condition_Header_E1KONH__c
                                                            WHERE E1KOMG_Ext_Id__c IN :dealLineIds];

        Map<Id, Condition_Header_E1KONH__c> dealLineConditionsMap = new Map<Id, Condition_Header_E1KONH__c>();

        for (Condition_Header_E1KONH__c cond : conditionsList) {
            dealLineConditionsMap.put(cond.E1KOMG_Ext_Id__c, cond);
        }

        return dealLineConditionsMap;
    }

    /**
     * @description Method to query products with matching SAP Material Numbers.
     * @param sapProductNumbers Set of Material numbers.
     * @returns A Map with the Material number as the key and the related Product2 record as the value.
     */
    private Map<String, Product2> queryProducts(Set<String> sapProductNumbers) {

        Map<String, Product2> productMap = new Map<String, Product2>();
        
        List<Product2> products = [SELECT Id, Name, SAP_Product_Number__c, CPQ_Material_Type__c, CPQ_Material_Type_Group__c,ProductCode,
                                    (
                                        SELECT SBQQ__APIName__c, SBQQ__Language__c, SBQQ__Text__c
                                        FROM SBQQ__Localizations__r
                                        WHERE SBQQ__APIName__c = 'Name'
                                    )      
                                   FROM Product2
                                   WHERE SAP_Product_Number__c IN :sapProductNumbers];
        
        for(Product2 product : products) {
            if(!productMap.containsKey(product.SAP_Product_Number__c)){
                productMap.put(product.SAP_Product_Number__c, product);
            }
        } 

        return productMap;
    }

    /**
     * @description Queries Flexible Groups and Flexible Group Items.
     * @param flexGroupNums Set of Flexible Group numbers to be retrieved.
     * @returns A Map with Flexible Group number as the key and the Flexible Group record as the value.
     */
    private Map<String, Flexible_Group__c> queryFlexGroups(Set<String> flexGroupNums) {

        System.debug('Flexible Group Numbers to query: ' + flexGroupNums);

        List<Flexible_Group__c> flexibleGroupList = 
            [SELECT Id, Flexible_Group_Number__c,
                    (SELECT 
                        Id, SAP_Material_Number__c, Flexible_Group_Number__c, Quantity__c, SAP_Material__c
                    FROM Flexible_Group_Items__r ORDER BY Item_Number__c)
                FROM Flexible_Group__c
                WHERE Flexible_Group_Number__c IN :flexGroupNums
            ];
        
        Map<String, Flexible_Group__c> flexibleGroupMap = new Map<String,Flexible_Group__c>();

        for (Flexible_Group__c flexGroup : flexibleGroupList) {
            flexibleGroupMap.put(flexGroup.Flexible_Group_Number__c, flexGroup);
        }

        return flexibleGroupMap;
    }

     /**
     * @description : get the vistex banners for the deal and concat the deal text for stamping to the bundle header product
     * @param dealId : The salesforce Id for the deal
     * @param languageCode : The Language code sourced from TSSPRASS__c
     */
    public void processVistexBanners(String dealId, String languageCode, List<Vistex_Banner_E1EDKT1__c> banners){
        if(banners == null){
            //In the auto bundle process we only want to get 1 deal at a time.  
            banners = queryVistexBannersByDealId(new List<String>{dealId},new Set<String>{languageCode});
        }
        this.dealBundleData.bannerMap = buildBannerMap(banners);
        for(String textTypeId : this.dealBundleData.bannerMap.keySet()){
            Vistex_Banner_E1EDKT1__c banner = this.dealBundleData.bannerMap.get(textTypeId);
            System.debug('textTypeId *** ' + textTypeId);
            //process the banner children and map them to the text type id field in the dealBundleData.
            if(banner != null){
                String concatText = concatVistexChildBanners(banner.Vistex_Child_Banner__r);
                System.debug('concatText *** '+ concatText);
                switch on textTypeId {
                    when 'ZPRM' {
                        this.dealBundleData.zprmText = concatText;
                    }
                    when 'ZTER' {
                        this.dealBundleData.zterText = concatText;
                    }
                    when 'ZPRQ' {
                        this.dealBundleData.zprqText = concatText;
                    }
                    when 'ZCPQ' {
                        this.dealBundleData.zcpqText = concatText;
                    }
                }
            }
        }
        //Section added by Sourav Mitra @ CTS to get a summary of all the banners available and to put it in Product Object - TPDEV-1637
        String summaryBanner = '';
        
        if(this.dealBundleData.zprmText != null){
            
            summaryBanner = this.dealBundleData.zprmText;
        }
        
        if(this.dealBundleData.zterText != null){
            if(summaryBanner != ''){
            summaryBanner += '\n' + this.dealBundleData.zterText;
            }else{
                summaryBanner = this.dealBundleData.zterText;
            }
        }
        
        if(this.dealBundleData.zprqText != null){
            if(summaryBanner != ''){
            summaryBanner += '\n' + this.dealBundleData.zprqText;
            }else{
                summaryBanner = this.dealBundleData.zprqText;
            }
        }
        
        if(this.dealBundleData.zcpqText != null){
            if(summaryBanner != ''){
            summaryBanner += '\n' + this.dealBundleData.zcpqText;
            }else{
                summaryBanner = this.dealBundleData.zcpqText;
            }
        }
        this.dealBundleData.promoSummary = summaryBanner;
    } 



    //Build a map of vistex banner grouped by the text type indicator
    //There will only be 1 banner per text type indicator which needs to have the child banner text concatenated.
    private Map<String,Vistex_Banner_E1EDKT1__c> buildBannerMap(List<Vistex_Banner_E1EDKT1__c> banners){
        Map<String,Vistex_Banner_E1EDKT1__c> bannerMap = new Map<String,Vistex_Banner_E1EDKT1__c>();
        for(Vistex_Banner_E1EDKT1__c banner : banners){
            if(!bannerMap.containsKey(banner.TDID__c)){            
                bannerMap.put(banner.TDID__c, banner);                                                           
            } 
        }
        System.Debug('Vistex BannerMap: ' + bannerMap);
        return bannerMap;
    }

    //Query Vistex Banners and child banners to parse contract or other deal text that needs to be displayed to users. 
    public List<Vistex_Banner_E1EDKT1__c> queryVistexBannersByDealId(List<String> dealIds, Set<String> languageCodes){
        return [
            SELECT Id, Name, DEALK01_Ext_Id__c, E1EDKT1_Ext_Id__c, TDID__c, TDOBJECT__c, TDOBNAME__c, TSSPRAS__c, DEALK01_Ext_Id__r.DEALNUM__c,
                (
		            SELECT Name, E1EDKT1_Ext_Id__c, E1EDKT2_Ext_Id__c, TDFORMAT__c, TDLINE__c
		            FROM Vistex_Child_Banner__r 
                    ORDER BY E1EDKT2_Ext_Id__c ASC
                ) 
            FROM Vistex_Banner_E1EDKT1__c 
            WHERE DEALK01_Ext_Id__c IN :dealIds
        ];
        
        /*
         * AND TSSPRAS__c IN :languageCodes - this section has been removed
         * to care of banners that are of different language - TPDEV-1637
         */
    }
    //Query Vistex Banners and child banners to parse contract or other deal text that needs to be displayed to users. 
    public List<Vistex_Banner_E1EDKT1__c> queryVistexBannersByDealNum(List<String> dealNums, Set<String> languageCodes){
        System.debug('Deal Nums for query: ' + dealNums);
        System.debug('Lang codes for query: ' + languageCodes);
        return [
            SELECT Id, Name, DEALK01_Ext_Id__c, E1EDKT1_Ext_Id__c, TDID__c, TDOBJECT__c, TDOBNAME__c, TSSPRAS__c, DEALK01_Ext_Id__r.DEALNUM__c,
                (
		            SELECT Name, E1EDKT1_Ext_Id__c, E1EDKT2_Ext_Id__c, TDFORMAT__c, TDLINE__c
                    FROM Vistex_Child_Banner__r 
                    ORDER BY E1EDKT2_Ext_Id__c ASC
                ) 
            FROM Vistex_Banner_E1EDKT1__c 
            WHERE DEALK01_Ext_Id__r.DEALNUM__c IN :dealNums AND TSSPRAS__c IN :languageCodes
        ];
        
    }

    //Iterate through the child banners and concatenate the text for desired formatted output.
    public String concatVistexChildBanners(List<Vistex_Child_Banner_E1EDKT2__c> childBanners){
        String returnText = '';
        for(Vistex_Child_Banner_E1EDKT2__c child : childBanners){
            
            if(returnText == ''){
                returnText = child.TDLINE__c; 
            }else if(child.TDLINE__c != null){
                //if TD format contains a star, we want a line break before the new text, otherwise we want a space before the new text.
                if(child.TDFORMAT__c == '*' ){
                    returnText += ' \n' + child.TDLINE__c;
                }else{
                    returnText += ' ' + child.TDLINE__c;                 
                }
            }
        }
        return returnText;
    }
    
   

    
}
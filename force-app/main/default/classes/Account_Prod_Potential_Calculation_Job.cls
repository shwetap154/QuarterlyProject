/*
    @@ Puropose: To Query All Potential Product Records. On completion of this batch, 
                 It will call "Account_Product_Potential_Job" Class.
                     
    @@ Author: Pavan Kumar
    @@ Date : 02- Feb-2015
    @@Test Class : Account_Prod_Potential_Calculation_Test
*/
/*
    @@ Sample Script to run batch
        set<string> markets = new set<string>();
        markets.add('Ireland');
        markets.add('Canada');
        Account_Prod_Potential_Calculation_Job a = new Account_Prod_Potential_Calculation_Job(markets); 
        database.executeBatch(a,2000);
*/
global class Account_Prod_Potential_Calculation_Job implements Database.Batchable<sObject>,Database.Stateful{
   string businessUnit;
   list<ZTS_EU_Species_Product__c> prodHierarcy; /* Will Contain product hierarchy records, whose Type is SKU*/
   set<string> markets; /* Will store markets which are passed to construcotr as parameter*/
   
   list<ZTS_EU_Potential_Brands__c> potentialProdList;
   map<id, map<id,list<ZTS_EU_Potential_Brands__c>>> speciePotentialProducts;
   
   Map<Id, List<ZTS_EU_Potential_Brands__c>> potentialProductsBySpecie; 
   
   
   set<id> SKU_Ids;
   global Account_Prod_Potential_Calculation_Job(set<string> markets, string businessUnit){
    
        potentialProductsBySpecie = new Map<Id, List<ZTS_EU_Potential_Brands__c>>();
        this.businessUnit = businessUnit;
        this.markets = markets;
        prodHierarcy = new list<ZTS_EU_Species_Product__c>();
        potentialProdList = new list<ZTS_EU_Potential_Brands__c>();
        speciePotentialProducts = new map<id, map<id,list<ZTS_EU_Potential_Brands__c>>>();
        SKU_Ids = new set<id>();
        
        string PRODUCT_HIERARCHY_LIST_OF_FIELDS_USED = PotentialCalculatorEngine.PRODUCT_HIERARCHY_LIST_OF_FIELDS_USED; // will contain Prod hierarchy fields
        string prodHirerchyQry = 'select id,ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c  from ZTS_EU_Species_Product__c where ZTS_EU_Type__c = \'SKU\' and ZTS_EU_Market__c in:markets';
        /* string prodHirerchyQry = 'select ' + PRODUCT_HIERARCHY_LIST_OF_FIELDS_USED+' id,ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c from ZTS_EU_Species_Product__c where ZTS_EU_Type__c = \'SKU\''; */
        prodHierarcy = dataBase.query(prodHirerchyQry);
        
        system.debug('prodHierarcy>>>'+prodHierarcy);
        
        /* preparing TG ids set and SKU ids.*/
        for(ZTS_EU_Species_Product__c sp : prodHierarcy){
            SKU_Ids.add(sp.id);
        }
   }    
    

   global Database.QueryLocator start(Database.BatchableContext BC){
        //string POTENTIAL_PRODUCT_LIST_OF_FIELDS_USED = PotentialCalculatorEngine.POTENTIAL_PRODUCT_LIST_OF_FIELDS_USED ;
        //string qry = 'select id,(select id,Potential__c,z.Brand__r.ZTS_EU_Parent_Species_Product__c,z.Brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,z.Brand__r.RecordType.developerName,'+POTENTIAL_PRODUCT_LIST_OF_FIELDS_USED+' from Potential_Brands__r z where Brand__c in :SKU_Ids) from ZTS_EU_Species__c';
        string qry = 'select id from ZTS_EU_Species__c';
        return database.getQueryLocator(qry);
   }

   global void execute(Database.BatchableContext BC, List<ZTS_EU_Species__c> scope){
        //try{
            //potentialProdList.addAll(scope); // Preparing list of potential brand records.
            
            list<ZTS_EU_Potential_Brands__c>  potentialBrandrecordsPerSpecie = new list<ZTS_EU_Potential_Brands__c>();
            map<id, list<ZTS_EU_Potential_Brands__c>> potentialBrandrecordsPerSpecieMp = new map<id, list<ZTS_EU_Potential_Brands__c>>();
            if(!scope.isEmpty()){
            
                set<id> specieIds = new set<id>();
                for(ZTS_EU_Species__c sp:scope){
                    specieIds.add(sp.id);
                }
                
                string POTENTIAL_PRODUCT_LIST_OF_FIELDS_USED = PotentialCalculatorEngine.POTENTIAL_PRODUCT_LIST_OF_FIELDS_USED ;
                string pbQry = 'select id,Potential__c,z.Brand__r.ZTS_EU_Parent_Species_Product__c,z.Brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c,z.Brand__r.RecordType.developerName,'+POTENTIAL_PRODUCT_LIST_OF_FIELDS_USED+' from ZTS_EU_Potential_Brands__c z where Brand__c in :SKU_Ids and Potential__c=:specieIds';
                potentialBrandrecordsPerSpecie = database.query(pbQry);
                for(ZTS_EU_Potential_Brands__c pb : potentialBrandrecordsPerSpecie){
                    list<ZTS_EU_Potential_Brands__c> tmp  = new list<ZTS_EU_Potential_Brands__c>();
                    tmp.add(pb);
                    if(potentialBrandrecordsPerSpecieMp.get(pb.Potential__c) != null){
                        tmp.addAll(potentialBrandrecordsPerSpecieMp.get(pb.Potential__c));   
                    }
                    potentialBrandrecordsPerSpecieMp.put(pb.Potential__c,tmp);
                }
                
            }
            
            for(ZTS_EU_Species__c sp:scope){
                    
               if(potentialBrandrecordsPerSpecieMp.get(sp.id) != null){
                    map<id, list<ZTS_EU_Potential_Brands__c>> tgProductsTemp = new map<id, list<ZTS_EU_Potential_Brands__c>>();
                    
                    for(ZTS_EU_Potential_Brands__c pb : potentialBrandrecordsPerSpecieMp.get(sp.id)){
                        boolean brandRT = false;
                        boolean skuRt = false;
                        if(pb.Brand__r.recordtype.Developername != 'SKU'){
                            //NC for now, we will only process the SKU products
                            continue;
                            /*brandRT = true;
                        }else{
                            skuRt = true;*/
                        }
                        
                        /**
                        * NC 05/03/2015
                        * Adding list of potential brands grouped by TGs in question
                        */
                        Id tg = pb.Brand__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c;
                        
                        List<ZTS_EU_Potential_Brands__c> brandWithTGList = tgProductsTemp.get(tg);
                        if(brandWithTGList == null) {
                            brandWithTGList = new List<ZTS_EU_Potential_Brands__c>();
                            tgProductsTemp.put(tg, brandWithTGList);
                        }
                        brandWithTGList.add(pb);
                        
          
                        /*Preparing Potential products by specie*/
                        /*list<ZTS_EU_Potential_Brands__c> potBrands = new list<ZTS_EU_Potential_Brands__c>();
                        potBrands.add(pb1);
                        if(potentialProductsBySpecie.get(pb1.Potential__c) != null){
                            potBrands.addAll(potentialProductsBySpecie.get(pb1.Potential__c));
                        }
                        potentialProductsBySpecie.put(pb1.Potential__c, potBrands);*/
                    }
                    if(tgProductsTemp.size() > 0){
                            speciePotentialProducts.put(sp.id,tgProductsTemp);
                    }
                 }   
                
            }
            
            system.debug('speciePotentialProducts Size ::'+speciePotentialProducts.size());
            system.debug('speciePotentialProducts ::'+speciePotentialProducts);
            
        /*}catch(Exception e){
            System.debug('++++Exception  :'+e.getMessage());
        }*/
   }

   global void finish(Database.BatchableContext BC){
        /* Executing Account_Product_Potential_Job Batch
        Parameters:
        1. markets ---> Set of markets
        2. speciePotentialProducts ---> Map<SPecie, Map<Ther Group, List<Potential_Brand__c>>> of all potential product records
        3. prodHierarcy ---> All product hierarchy records, whose type is "SKU"
        */
        
        //Added batch limit using custom setting, to make it dynamic --Pavan
   		if(Acc_Prod_Pot_Markets__c.getValues('Account_Product_Potential_Job') != null){
			Acc_Prod_Pot_Markets__c bl = Acc_Prod_Pot_Markets__c.getValues('Account_Product_Potential_Job');
			Account_Product_Potential_Job accProdPotentialJob = new Account_Product_Potential_Job(markets,speciePotentialProducts,prodHierarcy,potentialProductsBySpecie,businessUnit);
       		database.executeBatch(accProdPotentialJob,integer.valueOf(bl.Batch_Limit__c));
		}
        
           
   }
}
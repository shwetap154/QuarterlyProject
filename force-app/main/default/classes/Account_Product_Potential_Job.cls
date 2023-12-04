/*
    @@ Puropose: To Calculate Account potential
    @@ Author: Pavan Kumar
    @@ Date : 29- Jan-2015
    @@Test Class : Account_Prod_Potential_Calculation_Test
*/
/*
    @@Parameters:
        1. markets ---> Set of markets
        2. potentialProdList ---> List of all potential product records
        3. prodHierarcy ---> All product hierarchy records, whose type is "SKU"
*/
/*
    @@Legends :
    TG : Theraputic Group
    PH : Product Hierarchy
    SP : Specie Product
*/

global class Account_Product_Potential_Job implements Database.Batchable<sObject>,Database.Stateful{

   string businessUnit;
   list<ZTS_EU_Species_Product__c> prodHierarcy; /* Will Contain product hierarchy records, whose Type is SKU*/
   map<id,list<ZTS_EU_Species_Product__c>> tGroupSpecieProd; /*  Will Contain key as TG id and value as list of SKU records*/
   map<id,ZTS_EU_Species_Product__c> tGrouprecords; /*  Will Contain list of all TG records , where ket as TG id and value as TG record*/
   set<string> markets; /* Will store markets which are passed to construcotr as parameter*/

   map<id, map<id,list<ZTS_EU_Potential_Brands__c>>> speciePotentialProd;
   Map<Id, List<ZTS_EU_Potential_Brands__c>> potentialProductsBySpecie;
   global Account_Product_Potential_Job(set<string> markets,map<id, map<id,list<ZTS_EU_Potential_Brands__c>>> potentialProdList, list<ZTS_EU_Species_Product__c> prodHierarcyLst,Map<Id, List<ZTS_EU_Potential_Brands__c>> potentialProductsBySpecieTemp,string businessUnit){

        this.businessUnit = businessUnit;
        potentialProductsBySpecie = new Map<Id, List<ZTS_EU_Potential_Brands__c>>();
        potentialProductsBySpecie = potentialProductsBySpecieTemp;
        this.markets = markets;
        tGrouprecords = new map<id,ZTS_EU_Species_Product__c>();
        prodHierarcy = new list<ZTS_EU_Species_Product__c>();
        set<id> TGIds = new set<id>();
        tGroupSpecieProd = new map<id,list<ZTS_EU_Species_Product__c>>();

        speciePotentialProd = new map<id, map<id,list<ZTS_EU_Potential_Brands__c>>>();

        if(!potentialProdList.isEmpty()){
            speciePotentialProd.putAll(potentialProdList);
        }
        if(!prodHierarcyLst.isEmpty()){
            prodHierarcy.addAll(prodHierarcyLst);
        }
        system.debug('prodHierarcy>>>'+prodHierarcy);

        /* preparing TG ids set*/
        for(ZTS_EU_Species_Product__c sp : prodHierarcy){
            if(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c != null){
                TGIds.add(sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c);
            }
        }

        if(TGIds.size() > 0){
            list<ZTS_EU_Species_Product__c> tmp = new list<ZTS_EU_Species_Product__c>();
            string tGQry = 'select id from ZTS_EU_Species_Product__c where id in:TGIds';
            tmp = dataBase.query(tGQry);
            for(ZTS_EU_Species_Product__c sp : tmp){
                tGrouprecords.put(sp.id, sp);
            }
        }
        system.debug('tGrouprecords>>>>>>: : :'+tGrouprecords);
        /* Preapring map, It Will Contain key as TG id and value as list of SKU records*/
        for(Id i : TGIds){
            list<ZTS_EU_Species_Product__c> tmpLst = new list<ZTS_EU_Species_Product__c>();
            for(ZTS_EU_Species_Product__c sp: prodHierarcy){
                if(i == sp.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__r.ZTS_EU_Parent_Species_Product__c){
                    tmpLst.add(sp);
                }
            }
            if(!tmpLst.isEmpty()){
                tGroupSpecieProd.put(i,tmpLst);
            }
        }
   }


   global Database.QueryLocator start(Database.BatchableContext BC){
        string buAbbrWhereClause = (businessUnit != null && businessUnit != '') ? ' where ZTS_EU_BU_Abbr__c like \'%' + businessUnit + '%\'' : '';
        string ACCOUNT_LIST_OF_FIELDS_USED = PotentialCalculatorEngine.ACCOUNT_LIST_OF_FIELDS_USED;
        string ACCOUNT_CONSULTATION_LIST_OF_FIELDS_USED  = PotentialCalculatorEngine.ACCOUNT_CONSULTATION_LIST_OF_FIELDS_USED;  /* Will contain fields which needs to be query from Account specie Consultation object */
        /*Pavan
        Added Key Account Product Price fields in below query */
        string qry = 'select id, '+ACCOUNT_LIST_OF_FIELDS_USED+',name,(select id,'+ ACCOUNT_CONSULTATION_LIST_OF_FIELDS_USED +' from Account_Species_Potentials__r' + buAbbrWhereClause + '),(select id, Price__c,Product__c,Account__c from Key_Account_Product_Price__r) from account where ZTS_EU_Account_Status__c = \'Active\' and ZTS_EU_Market__c in:markets';
        return database.getQueryLocator(qry);
   }

   global void execute(Database.BatchableContext BC, List<Account> scope){
        //try{
            system.debug('<<markets>'+markets);
            PotentialCalculatorEngine potentialCalObj = new PotentialCalculatorEngine(markets);
            potentialCalObj.productsPerTherGroup =tGroupSpecieProd;
            potentialCalObj.potentialProductsBySpecie = potentialProductsBySpecie;
            potentialCalObj.speciePotentialProd = speciePotentialProd;
            list<ZTS_EU_Account_Product_Potential__c> accProdPotential = new list<ZTS_EU_Account_Product_Potential__c>();
            for(Account acc: scope){ 
                if(acc.Account_Species_Potentials__r.size() > 0){
                    //NC REVIEW This is fine but can you - for readability purposes - split this into 2 lines where in the first one
                    //you are calling the potential method and in the second one you are adding all of the returned records to the
                    //accProdPotential list
                    //Passing key acocunts as parametr - Pavan
                    list<ZTS_EU_Account_Product_Potential__c> tmpList = potentialCalObj.calculatePotential(acc,acc.Account_Species_Potentials__r,acc.Key_Account_Product_Price__r);
                    accProdPotential.addAll(tmpList);
                }
            }
            if(!accProdPotential.isEmpty()){
                insert accProdPotential;
            }

        /*}catch(Exception e){
            System.debug('++++Exception  :'+e.getMessage());
        }*/
   }

   global void finish(Database.BatchableContext BC){
   }

}
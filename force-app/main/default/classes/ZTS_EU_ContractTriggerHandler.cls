/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_ContractTriggerHandler.cls
   Description: Helper class for Trigger ZTS_EU_CopyProductAssociationFromContractTemplate_Trigger
                to fetch the inserted Contracts and copy the associated Product Associations
                from the related Contract Template.
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   13-10-2014   1.0     Bimba               Initial Version       
   12-11-2014   1.1     Bimba               Added new method 'defaultValuesOnContract' to default the Type,Business Unit and Contract template 
                                            fields before inserting the Contract record
   14-11-2014   1.2     Bimba               Updated 'defaultValuesOnContract' method to copy date and Fiscal year values on the Contract    
   17-11-2014   1.3     Bimba               Added Discount Type field to be copied from Template to Contract
   3-APR-2015	1.4	Srinivas	            Apply to Group field checked Copies the contract and inserted on list of accounts which contains same VetSave HO ID	
------------------------------------------------------------------------------------------------------------------------ */
public class ZTS_EU_ContractTriggerHandler{
    
    /**********************************************************************************************************************
    * author: Bimba
    * Date: 13-OCT-2014
    * Param: List<Contracts> New Contracts
    * Return: void
    * Description: Copies the Product from the Contract Template and creates a Product Contract Association on the Contract
    * Summary of Changes : Bimba 27/11/2014 : Changes added to add an error message for the Discount. 
                            
    **********************************************************************************************************************/ 
    public static void copyProductsOnInsert(List<Contract> newContracts){
        
        /*** Declarations ***/
        Set<Id> CTIdSet = new Set<Id>();
        List<Product_Contract_Template_Association__c> PCTAList = new List<Product_Contract_Template_Association__c>();
        List<Product_Contract_Association__c> pcaToInsertList = new List<Product_Contract_Association__c>();
        /***Query for the Product Contract Template Association records ***/
        PCTAList = [SELECT Id,ZTS_EU_Contract_Template__c,
                            ZTS_EU_Product_Hierarchy__c
                            FROM Product_Contract_Template_Association__c];
        /*** Iterate on each record of Inserted contract ***/
        for(Contract conRec : newContracts){
            CTIdSet.add(conRec.Id);
            /***Iterate on each record of queried PCTA record ***/                
            for(Product_Contract_Template_Association__c pcta : PCTAList ){
                /*** If you find the Contract with its matching PCTA, then clone the record and create a new PCA record ***/
                if(pcta.ZTS_EU_Contract_Template__c == conRec.ZTS_EU_Related_Contract_Template__c){
                    Product_Contract_Association__c clonedPCA = new Product_Contract_Association__c();
                    clonedPCA.ZTS_EU_Product__c = pcta.ZTS_EU_Product_Hierarchy__c;
                    clonedPCA.ZTS_EU_Contract__c = conRec.Id;
                    
                    pcaToInsertList.add(clonedPCA);
                }
            }
        }    
        /*** Insert the newly created PCA record ***/
        database.insert(pcaToInsertList,false);
        //Bimba 27/11/2014 Changes to add error and show the discount set on the template to the user
        List<ZTS_EU_ContractTemplate__c> conTemplList = [Select Id,ZTS_EU_Discount__c from ZTS_EU_ContractTemplate__c];        
        //For every Contract that is cloned from the Template
        for(Contract conRec1 : newContracts){
            for(ZTS_EU_ContractTemplate__c conTemp1 : conTemplList) {
                if(conRec1.ZTS_EU_Related_Contract_Template__c == conTemp1.Id){
                    //Check if the Discount type is Fixed or threshold
                    if(conRec1.ZTS_EU_Discount_Type__c == System.Label.ZTS_EU_fixedDiscount && conRec1.ZTS_EU_Discount_Type__c != null){
                        if(conRec1.ZTS_EU_Discount__c != conTemp1.ZTS_EU_Discount__c){
                            conRec1.addError(System.Label.ZTS_EU_fixedDiscountMsgPart1+' '+conTemp1.ZTS_EU_Discount__c+'%'+' '+','+System.Label.ZTS_EU_fixedDiscountMsgPart2+System.Label.ZTS_EU_fixedDiscountMsgPart3);
                        }
                    }
                    //Check if the discount set on the Contract follows the Discount type set on the Template
                    else if(conRec1.ZTS_EU_Discount_Type__c == System.Label.ZTS_EU_thresholdDiscount && conRec1.ZTS_EU_Discount_Type__c != null){
                        if(conRec1.ZTS_EU_Discount__c > conTemp1.ZTS_EU_Discount__c){
                            conRec1.addError(System.Label.ZTS_EU_thresDiscountMsgPart1+' '+conTemp1.ZTS_EU_Discount__c+'%.'+' '+System.Label.ZTS_EU_thresDiscountMsgPart2);   
                        }
                    }
                }
            }
            
        }
        
        
        
    }
    /**********************************************************************************************************************
    * author: Bimba
    * Date: 13-OCT-2014
    * Param: List<Contracts> New Contracts
    * Return: void
    * Description: If a User tries to update the Contract Template lookup on the Contract, an error is shown
    * Summary of Changes : 
    **********************************************************************************************************************/ 
    public static void AddErrorOnUpdateOfContractTemplate(List<Contract> newContractsList,Map<Id,Contract> oldContractsMap){
        /*** Iterate over every Contract Record that is updated, if Contract Template field is changed, add an error ***/
        for(Contract newConRec : newContractsList){
            if(oldContractsMap.containsKey(newConRec.Id)){
                  Contract oldContract = oldContractsMap.get(newConRec.Id); 
                  if((oldContract.ZTS_EU_Related_Contract_Template__c != newConRec.ZTS_EU_Related_Contract_Template__c)
                        &&(newConRec.ZTS_EU_Related_Contract_Template__c != null)){
                        newConRec.addError(System.Label.ZTS_EU_ContractUpdateError);
                  }
            }
            
        }   
    }
    
    /**********************************************************************************************************************
    * author: Bimba
    * Date: 12-NOV-2014
    * Param: List<Contracts> New Contracts
    * Return: void
    * Description: Before a Contract Record is inserted, populate the Type,Business Unit and Contract Template fields
    * Summary of Changes : 
    **********************************************************************************************************************/
    public static void defaultValuesOnContract(List<Contract> newContracts){
    
    /*** Get the related Contract Template and copy the CTName,BU and Type fields ***/
        List<Contract> contractsToInsertList = new List<Contract>();
        List<ZTS_EU_ContractTemplate__c> relatedConTemList = new List<ZTS_EU_ContractTemplate__c>();
        relatedConTemList = [SELECT Id, ZTS_EU_CTBusiness_Unit__c,ZTS_EU_Type__c,
                                    ZTS_EU_Start_Date__c,
                                    ZTS_EU_End_Date__c,
                                    ZTS_EU_Fiscal_Year__c,
                                    ZTS_EU_Discount_Type__c
                                FROM ZTS_EU_ContractTemplate__c];
                        
        for(Contract conRec : newcontracts){
            system.debug('Contract in loop--->'+conRec);
            for(ZTS_EU_ContractTemplate__c conTempl : relatedConTemList){
                system.debug('Contract Template in loop ---->'+conTempl);
                if(conRec.ZTS_EU_Related_Contract_Template__c == conTempl.Id){
                    system.debug('Found a match between them--');
                    conRec.ZTS_EU_Type__c = conTempl.ZTS_EU_Type__c;
                    conRec.ZTS_EU_BusinessUnit__c = conTempl.ZTS_EU_CTBusiness_Unit__c;
                    conRec.StartDate = conTempl.ZTS_EU_Start_Date__c;
                    conRec.ZTS_EU_End_Date__c = conTempl.ZTS_EU_End_Date__c;
                    conRec.ZTS_EU_Fiscal_Year__c = conTempl.ZTS_EU_Fiscal_Year__c;
                    conRec.ZTS_EU_Discount_Type__c = conTempl.ZTS_EU_Discount_Type__c;
                    
                    contractsToInsertList.add(conRec);
                    
                }
            }
        }
        system.debug('Contracts getting inserted--->'+contractsToInsertList);
    }
    
    /**********************************************************************************************************************
    * author: Srinivas
    * Date: 3-APR-2015
    * Param: List<Contracts> New Contracts
    * Return: void
    * Description: if 'Apply to Group' field checked Copies the contract and inserted on list of accounts which contains same VetSave HO ID
    * Summary of Changes : 
    **********************************************************************************************************************/
    public static void copyContractsOnInsertUpdate(List<Contract> newContracts){
        
        
        set<id> accSet=new set<Id>();
        
        Map<string,List<account>> accHOIDMap=new Map<string,List<account>>();
        Map<string, contract> accContractMap = new Map<string, contract>();
        
        for(Contract cont:newContracts){            
            if(cont.Apply_to_Group__c==true){
                accSet.add(cont.accountId);
            }           
        }   
        
        if(!accSet.isEmpty()){
            map<id, account> TempaccMap = new map<id, account> ([select id, ZTS_EU_Vetsave_HO_ID__c from account where Id=:accSet AND ZTS_EU_Market__c != 'United States']);
            set<string> HoIdset= new set<string>();
            for(Account acc:TempaccMap.values()){
                if(acc.ZTS_EU_Vetsave_HO_ID__c!=null)
                HoIdset.add(acc.ZTS_EU_Vetsave_HO_ID__c);
                
            }
            map<id, account> accMap = new map<id, account> ([select id, ZTS_EU_Vetsave_HO_ID__c from account where ZTS_EU_Vetsave_HO_ID__c in:HoIdset AND ZTS_EU_Market__c != 'United States']);
            system.debug('accMap===========>'+accMap);
            for(Contract cont:newContracts){ 
                system.debug('cont.AccountId===>'+cont.AccountId);
                //system.debug('accMap.get(cont.accountId).Id======>'+accMap.get(cont.accountId).Id);
                if(cont.Apply_to_Group__c==true && accMap.get(cont.accountId) != null){
                    system.debug('accMap.containsKey(cont.AccountId)====>'+accMap.containsKey(cont.AccountId));
                    
                      accContractMap.put(accMap.get(cont.accountId).ZTS_EU_Vetsave_HO_ID__c,cont);
                    
                }           
            } 
            system.debug('accContractMap======>'+accContractMap);
            
            for(account acc : accMap.values()){
                list<account> tmp = new list<account>();
                tmp.add(acc);
                if(accHOIDMap.get(acc.ZTS_EU_Vetsave_HO_ID__c) != null){
                    tmp.addAll(accHOIDMap.get(acc.ZTS_EU_Vetsave_HO_ID__c));
                }
                accHOIDMap.put(acc.ZTS_EU_Vetsave_HO_ID__c,tmp);
                
            }
            list<contract> contractsToInsert = new list<contract>();
            system.debug('accHOIDMap=====>'+accHOIDMap);
            system.debug('accContractMap=====>'+accContractMap);
            for(string s: accHOIDMap.keySet()){
               
                system.debug('Key=====>'+s);
                for(Account acc: accHOIDMap.get(s)){
                    system.debug('acc.ZTS_EU_Vetsave_HO_ID__c=====>'+acc.ZTS_EU_Vetsave_HO_ID__c);
                    if(accContractMap.get(acc.ZTS_EU_Vetsave_HO_ID__c) != null && accContractMap.get(acc.ZTS_EU_Vetsave_HO_ID__c).accountId!=acc.id){
                        Contract con  = accContractMap.get(acc.ZTS_EU_Vetsave_HO_ID__c).clone(false, false, false, false);
                        
                        con.accountId = acc.id;
                        con.Status= 'Draft';
                        system.debug('con=======>'+con);
                        system.debug('acc.id=======>'+acc.id);
                        contractsToInsert.add(con);
                    }
                    
                }
            }
            system.debug('contractsToInsert=====>'+contractsToInsert);
            if(!contractsToInsert.isEmpty()){
                UtilityService.AffUpdateRun=false;
                  system.debug('UtilityService.AffUpdateRun===========>'+UtilityService.AffUpdateRun);
                insert contractsToInsert;
                
            }           
        }
    }

    
}
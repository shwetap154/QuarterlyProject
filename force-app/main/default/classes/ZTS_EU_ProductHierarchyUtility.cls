/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_ProductHierarchyUtility
* Description   :  This is the utility class for the Product Hierarchy object                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     1st-Jun-15   Shreyas             Created the class.

********************************************************************************************************************************************/
public class ZTS_EU_ProductHierarchyUtility {


    /*
        Name: populateBuFromBrandOnTG
        Purpose: populate the field 'BU From Brand' on TG records for Spain
        arguments: none
        return type: none
    */
    public static void populateBuFromBrandOnTG(List<ZTS_EU_Species_Product__c> brandList, boolean isUpdate){
    
        map<string, Set<string>> brandBUSetMap = new map<string, Set<string>>();
        map<string, Set<string>> tgBUSetMap = new map<string, Set<string>>();
        Set<string> buSetOnBrand = new Set<string>();
        
        List<string> tgIdList = new List<string>();
        List<string> currentBrandIdList = new List<string>();
        List<ZTS_EU_Species_Product__c> otherbrandList = new List<ZTS_EU_Species_Product__c>();
        List<ZTS_EU_Species_Product__c> tgList = new List<ZTS_EU_Species_Product__c>();
        List<ZTS_EU_Species_Product__c> tgUpdateList = new List<ZTS_EU_Species_Product__c>();
        
        
        
        for(ZTS_EU_Species_Product__c brand: brandList){
            
            tgIdList.add(brand.ZTS_EU_Parent_Species_Product__c);
            if(isUpdate){
                if(brand.ZTS_EU_Business_Units__c != null){
                    buSetOnBrand.addAll(brand.ZTS_EU_Business_Units__c.split(' '));
                    tgBUSetMap.put(brand.ZTS_EU_Parent_Species_Product__c, buSetOnBrand);
                    buSetOnBrand = new Set<string>();
                }
            }
            
            currentBrandIdList.add(brand.Id);
            
        }
        
        otherbrandList = [Select Id, ZTS_EU_Parent_Species_Product__c, ZTS_EU_Business_Units__c from ZTS_EU_Species_Product__c where ZTS_EU_Parent_Species_Product__c IN: tgIdList AND Id Not IN: currentBrandIdList];
        for(ZTS_EU_Species_Product__c brand: otherbrandList){
        
            brandBUSetMap = new map<string, Set<string>>();
            if(brand.ZTS_EU_Business_Units__c != null){
                buSetOnBrand.addAll(brand.ZTS_EU_Business_Units__c.split(' '));
                if(tgBUSetMap.containskey(brand.ZTS_EU_Parent_Species_Product__c)){
                    tgBUSetMap.get(brand.ZTS_EU_Parent_Species_Product__c).addAll(buSetOnBrand);
                }
                else{
                    tgBUSetMap.put(brand.ZTS_EU_Parent_Species_Product__c, buSetOnBrand);
                }
             
                buSetOnBrand = new Set<string>();
            }
            
        }
        
        tgList = [select Id, ZTS_EU_All_BUs_From_Brands_Underneath__c from ZTS_EU_Species_Product__c where Id IN: tgIdList];
        
        for(ZTS_EU_Species_Product__c tg: tgList){
            
            string buFromBrandUnderneath = '';
            set<string> newBuFromBrandList = new set<string>();
            set<string> uniqueBuSet = new set<string>();
            
            newBuFromBrandList = tgBUSetMap.get(tg.Id);
            if(newBuFromBrandList != null){
                for(string s: newBuFromBrandList){
                    uniqueBuSet.add(s);
                }
                
                for(string s: uniqueBuSet){
                    
                    if(buFromBrandUnderneath == ''){
                        buFromBrandUnderneath = s + ' ' ;
                    }
                    else{
                        buFromBrandUnderneath = buFromBrandUnderneath + s + ' ';
                    }
                }
            }
            
            tg.ZTS_EU_All_BUs_From_Brands_Underneath__c = buFromBrandUnderneath;
            tgUpdateList.add(tg);
        }
        
        update tgUpdateList;
        
        
    }
    

}
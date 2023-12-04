/**
* File Name     :  CPQ_VistexDealValidator
* @description  :  Returns results of deal validity based on numerous criteria. 
If any invalid results are returned, the should be stamped to the vistex deal header and that deal should be excluded from further batch runs.
Initial implementation executed in the AutoBundleBatchable class. Also be used in the "Create Bundle" button on vitex deal header.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/8/2020      Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020      Cory Bartholomew @ ATG     Added descriptions.
* 3.0     09/15/2020    Ramiro Alvarez @ ATG       Adding pre-validations for CPQATG-877
* 3.1     01/25/2023    Mila Imas                  limit selection to validate prices
**/

public class CPQ_VistexDealValidator {
    public static Boolean debug = true;
    
    public class VistexDealValidationException extends Exception{}

    public class DealValidationResult {
        public Boolean isValid; //indicator of the result being valid
        public String invalidReason; //The string returned from the invalidation
        public Id invalidRecordId; //returned if a specific record other than the deal itself has an error    
    }    
    
    /**
     * @description runs specified validations before any bundle data is gathered.
     * @param deal The vistex deal to validate
     * @param dealLines the vistex deal lines to validate
     */
    public static List<DealValidationResult> runPreValidations(Vistex_Deal_Header__c deal,List<Vistex_Deal_Line_E1KOMG__c> dealLines){
        List<DealValidationResult> results = new List<DealValidationResult>();   
        
        //get Materials
        
        Map<String,SAP_Material__c> matMap = getMaterialMap(dealLines);        
        results.add(operationalLeaseIncludesRentalFee(dealLines, matMap));
        results.addAll(bulkValidateDealLines(dealLines));
        results.addAll(specificOrAggregate(dealLines));
        results.addAll(getWarrantyAndDeviceLines(dealLines,matMap));
        

        // CPQATG-877
        //Check Deal Line.Flexible Group (LIFNR) against Flexible Group.Flexible_Group_Number__c
        results.addAll(validateFlexibleGroup(dealLines));
        //Check Deal Line.Material Number (MATNR) against SAP Materials.SAP_Product_Number__c and check if material reference has CPQ Material Type
        results.addAll(validateSAPMaterial(dealLines, matMap));
        //Check Deal Line.Material Number (MATNR) against SAP Materials.SAP_Product_Number__c
        results.addAll(validateSapPriceEntry(dealLines, matMap,deal.ORGID__c));

        if(debug){
            System.debug('PreValidation results: ' + results);
        }

        return results;
    }

    public static List<DealValidationResult> validateSAPMaterial(List<Vistex_Deal_Line_E1KOMG__c> dealLines, Map<String,SAP_Material__c> materialMap) {

        List<DealValidationResult> results = new List<DealValidationResult>();
        for (Vistex_Deal_Line_E1KOMG__c dealLine : dealLines){
            if (!materialMap.containsKey(dealLine.MATNR__c) && dealLine.MATNR__c != null) {
                results.add(createResult('- Pre-validation: there is no SAP Material Number: ' + dealLine.MATNR__c + ' committed in Salesforce.',false,null));
            }
            if (materialMap.containsKey(dealLine.MATNR__c) && dealLine.MATNR__c != null && materialMap.get(dealLine.MATNR__c).CPQ_Material_Type__c == null) {
                results.add(createResult('- Pre-validation: SAP Material Number: ' + dealLine.MATNR__c + ' has not a CPQ_Material_Type_c populated.',false,null));
            }

        }
        return results;
    }

    public static List<DealValidationResult> validateSapPriceEntry(List<Vistex_Deal_Line_E1KOMG__c> dealLines, Map<String,SAP_Material__c> materialMap, string salesorg) {

        List<DealValidationResult> results = new List<DealValidationResult>();
        Set<String> dealMaterialNumberSet = new Set<String> ();
        Map<String,SAP_Price_Entry__c> sapPriceEntryMap = new Map<String,SAP_Price_Entry__c>();

        for (Vistex_Deal_Line_E1KOMG__c dealLine : dealLines){
            dealMaterialNumberSet.add(dealLine.MATNR__c);
        }
        List<SAP_Price_Entry__c> sapPriceEntryList = [SELECT Id, SAP_Product_Number__c, SAP_Sales_Org_Id__c
                        FROM SAP_Price_Entry__c WHERE SAP_Product_Number__c IN :dealMaterialNumberSet and SAP_Sales_Org_Id__c = :salesorg ];

        for (SAP_Price_Entry__c sapPriceEntry : sapPriceEntryList) {
            sapPriceEntryMap.put(sapPriceEntry.SAP_Product_Number__c + sapPriceEntry.SAP_Sales_Org_Id__c, sapPriceEntry);
        }
// mi
        for (Vistex_Deal_Line_E1KOMG__c dealLine : dealLines){
            if (!sapPriceEntryMap.containsKey(dealLine.MATNR__c + dealLine.DEALK01_Ext_Id__r.ORGID__c) && dealLine.MATNR__c != null) {
                results.add(createResult('- Pre-validation: there is no SAP Price Entry for Material Number: ' + dealLine.MATNR__c + ' Sales Org: ' +
                 dealLine.DEALK01_Ext_Id__r.ORGID__c + ' committed in Salesforce.',false,null));
            }
        }

        System.debug('validateSapPriceEntry: ' + results);

        return results;
    }


    public static List<DealValidationResult> validateFlexibleGroup(List<Vistex_Deal_Line_E1KOMG__c> dealLines){
        List<DealValidationResult> results = new List<DealValidationResult>();       
        Set<String> flexibleGroupNumberSet = new Set<String> ();
        
        for(Vistex_Deal_Line_E1KOMG__c line : dealLines) {            
           if(line.LIFNR__c != null) {
               flexibleGroupNumberSet.add(line.LIFNR__c);                               
           }
        }

        if (flexibleGroupNumberSet.isEmpty()){
            return results;
        }

        List<Flexible_Group__c> existingFlexibleGroup = [SELECT Id, Flexible_Group_Number__c
                                                            FROM Flexible_Group__c
                                                            WHERE Flexible_Group_Number__c IN :flexibleGroupNumberSet];

        Map<String, Flexible_Group__c> existingFlexibleGroupMap = new Map<String, Flexible_Group__c>();
        for (Flexible_Group__c flexibleGroup : existingFlexibleGroup){
            existingFlexibleGroupMap.put(flexibleGroup.Flexible_Group_Number__c,flexibleGroup);
        }

        for (Vistex_Deal_Line_E1KOMG__c line : dealLines){
            if (!existingFlexibleGroupMap.containsKey(line.LIFNR__c) && line.LIFNR__c != null) {
                results.add(createResult('- Pre-validation: there is no Flexible Group Number: ' + line.LIFNR__c + ' committed in Salesforce.',false,null));
            }
        }       
        if(debug){
            System.debug('validateFlexibleGroup results: ' + results);
        }

        return results;
    }



    /**
     * @description : Only one consumable flexible group can have an aggregate commitment per suffix. 
     * This method should be implemented in the autobBundleDataCollector class where we populate the wrappers.
     * @param flxGroupWrappers : The felxible group lines gathered in the auto bundle process
     * @param materialWrappers : The Material lines gathered in the auto bundle process
     * @return results : The list of deal validation results indicating if a problem was found 
     */
    //CPQATG-649
    public static List<DealValidationResult> oneZConFlxGrpPerSuffix(List<AutoBundleFlexibleGroupLineWrapper> flxGroupWrappers, List<AutoBundleMaterialLineWrapper> materialWrappers){
        List<DealValidationResult> results = new List<DealValidationResult>();   
        List<AutoBundleFlexibleGroupLineWrapper> zconCommitFlxGrpWrappers = new List<AutoBundleFlexibleGroupLineWrapper>();
        List<AutoBundleFlexibleGroupLineWrapper> zdevFlxGrpWrappers = new List<AutoBundleFlexibleGroupLineWrapper>();
        Set<String> wrapperSuffixes = new Set<String>();
       
        //Go through the flexible groups and get the devices and consumable groups
        for(AutoBundleFlexibleGroupLineWrapper wrapper : flxGroupWrappers){
            if (wrapper.dealLine.KSCHL__c == 'ZCON' && wrapper.IsAggregateCommitment){
                zconCommitFlxGrpWrappers.add(wrapper);
                if(!String.isBlank(wrapper.DealLine.EBONU__c)){
                    wrapperSuffixes.add(wrapper.DealLine.EBONU__c);
                }
            }else if(wrapper.dealLine.KSCHL__c == 'ZDEV'){
                zdevFlxGrpWrappers.add(wrapper);
            }
        }

        // If there were more than a single consumable flexible group we need to validate        
        if(zconCommitFlxGrpWrappers.size() > 1){
            for(String zconSuffix : wrapperSuffixes){
                Integer suffixAggCommitLines = 0;
                Integer suffixDevices = 0;
                //Count devices in the suffix
                for(AutoBundleMaterialLineWrapper materialWrapper : materialWrappers){
                    if(materialWrapper.DealLine.KSCHL__c == 'ZDEV' && materialWrapper.DealLine.EBONU__c == zconSuffix){
                        suffixDevices ++;
                    }
                }
                for(AutoBundleFlexibleGroupLineWrapper zdevFlxGrpWrapper : zdevFlxGrpWrappers){
                    if(zdevFlxGrpWrapper.DealLine.EBONU__c == zconSuffix){
                        suffixDevices ++;
                    }
                }

                //Continue validation if the suffix has a device
                /*if(suffixDevices > 0){
                    for(AutoBundleFlexibleGroupLineWrapper zconWrapper : zconCommitFlxGrpWrappers){
                        if(zconWrapper.dealLine.EBONU__c == zconSuffix){
                            suffixAggCommitLines ++;
                        }
                    }
                    //If more than one commitment for aggregate consumables, throw a validation
                    if (suffixAggCommitLines > 1){
                        results.add(createResult('- Suffix group ' + zconSuffix + 
                        ' has more than one consumable aggregate commitment level.  It should have only one commitment level at the flexible group line child condition.',
                         false, null));
                    }
                }*/
            }
        }
        return results;
    }   
    
    
    /**
     * @description : If more than one device is included in the offer and the offer includes at least one extended warranty, 
        the device and its related extended warranty should be linked via the suffix. 
     * @param dealLines : The deal lines to validate
     * @param matMap : The Materials realted to deal lines with the SAP product number as the key
     * @return results : The list of deal validation results indicating if a problem was found 
     */
    //CPQATG-639 
    public static  List<DealValidationResult> getWarrantyAndDeviceLines(List<Vistex_Deal_Line_E1KOMG__c> dealLines, Map<String,SAP_Material__c> matMap){
        List<DealValidationResult> results = new List<DealValidationResult>();           
        List<Vistex_Deal_Line_E1KOMG__c> warrantyLines = new List<Vistex_Deal_Line_E1KOMG__c>();
        List<Vistex_Deal_Line_E1KOMG__c> deviceLines = new List<Vistex_Deal_Line_E1KOMG__c>();   
        
        //Get the device and warranty lines
        for(Vistex_Deal_Line_E1KOMG__c line : dealLines){            
            if(matMap.containsKey(line.MATNR__c)){
                SAP_Material__c material = matMap.get(line.MATNR__c);
                if(material.CPQ_Material_Type_Grouping__c == 'Warranty'){
                    warrantyLines.add(line);
                }
            }
            if(line.KSCHL__c == 'ZDEV'){                
                deviceLines.add(line);
            }                     
        }
        //If more than one device is included in the offer, and the offer includes at least one extended warranty,
        // the device and its related extended warranty should be linked via the suffix.
        if(warrantyLines.size() > 0 && deviceLines.size() > 1){
            results.addAll(checkWarrantyLinkedToDevice(deviceLines,warrantyLines));
        }
        return results;
    }

    /**
     * @description : if there is more than 1 device on a deal and the deal has a warranty, the warranty shuould be linked to a device via the suffix
     * @param devices : The device deal lines
     * @param warranties : The warranty deal lines
     * @return results : The list of deal validation results indicating if a problem was found 
     */
    private static List<DealValidationResult> checkWarrantyLinkedToDevice(List<Vistex_Deal_Line_E1KOMG__c> devices, List<Vistex_Deal_Line_E1KOMG__c> warranties){
        List<DealValidationResult> results = new List<DealValidationResult>();
        for(Vistex_Deal_Line_E1KOMG__c warrantyLine : warranties){
                if(warrantyLine.EBONU__c == null){
                    results.add(createResult('- There is more than one device included in this deal and warranty line ' + warrantyLine.Id +
                     ' was not linked to a device with a suffix.', false, warrantyLine.Id));
                }else{
                    Integer warrantyDeviceCount = 0;
                    for(Vistex_Deal_Line_E1KOMG__c deviceLine : devices){
                        if(deviceLine.EBONU__c == warrantyLine.EBONU__c ){
                            warrantyDeviceCount ++;
                        }
                    }
                    if(warrantyDeviceCount != 1){
                        results.add(createResult('- Suffix group ' + warrantyLine.EBONU__c + ' has ' + warrantyDeviceCount +
                         ' devices.  It is expected that it will have only 1 device linked with warranty line ' + warrantyLine.Id, false, warrantyLine.Id));
                    } 
                }                
            }
            return results;
    }

    /**
     * @description : A deal can only have a specific or aggregate commitment, not both.  If a commitment is present the deal must also have a ZTER deal line
     * @param dealLines : The vistex deal lines to validate
     * @return results : The list of deal validation results indicating if a problem was found 
     */
    public static List<DealValidationResult> specificOrAggregate(List<Vistex_Deal_Line_E1KOMG__c> dealLines){
        System.debug('Specific or Aggregate');
        List<DealValidationResult> results = new List<DealValidationResult>();    
        Boolean hasFlxGrpCommit = false;
        Boolean hasSpecificCommit = false;
        Boolean hasZterWithValue = false;  
        
        Set<Id> flexGrpLineIds = new Set<Id>();
        Set<Id> nonflexGrpLineIds = new Set<Id>();
        for(Vistex_Deal_Line_E1KOMG__c line : dealLines){
            if(line.LIFNR__c != null){                
                flexGrpLineIds.add(line.Id);
            }else{
                nonflexGrpLineIds.add(line.Id);
            }
            //CPQATG-642
            if(line.KSCHL__c == 'ZTER' && line.EKKOA__c != null){
                hasZterWithValue = true;
            }
        }
        System.debug('flexGrpLineIds: ' + flexGrpLineIds);
        System.debug('nonflexGrpLineIds: ' + nonflexGrpLineIds);        

        if(flexGrpLineIds.size() > 0){
            List<Vistex_ZO2C_E1KONP_CPQ__c> specificCommitRecs = queryChildConditionsFromDealLines(nonflexGrpLineIds);
            List<Vistex_ZO2C_E1KONP_CPQ__c> aggregateCommitRecs = queryChildConditionsFromDealLines(flexGrpLineIds);

            if(specificCommitRecs.size() > 0){
                for(Vistex_ZO2C_E1KONP_CPQ__c rec : specificCommitRecs){ 
                    hasSpecificCommit = hasCommit(rec);
                    if(hasSpecificCommit){
                        break;
                    }                     
                }
            }

            //If no specific commit then we dont need to check for agg commit
            if(aggregateCommitRecs.size() > 0){
                for(Vistex_ZO2C_E1KONP_CPQ__c rec : aggregateCommitRecs){                     
                    hasFlxGrpCommit = hasCommit(rec);
                    if(hasFlxGrpCommit){
                        break;
                    }                        
                }                                        
            }
        }
               
        //CPQATG-643
        if(hasFlxGrpCommit && hasSpecificCommit){
            results.add(createResult('- This deal has both an aggregate commitment (specified by a flexible group) ' 
            + ' and a specific commitment identified. ', false, null));  
        } 
        //CPQATG-642  If there is a commitment specified the deal must have a term.
        if((hasFlxGrpCommit || hasSpecificCommit) && !hasZterWithValue){
             results.add(createResult('- This deal has either an aggregate commitment (specified by a flexible group) ' 
            + ' or a specific commitment identified, but there is no ZTER deal line with an EKKOA value.', false, null));
        }      

        if(debug){
            System.debug('specificOrAggregate result: ' + results);
        } 
        return results;
    }

    /**
     * @description : Check if a child condition record has a commitment value or quantity
     * @param rec : The Vistex_ZO2C_E1KONP_CPQ__c child condition record to validate
     * @return result : true or false if the record has a commitment or not 
     */
    public static Boolean hasCommit(Vistex_ZO2C_E1KONP_CPQ__c rec){
        Boolean result = false;
        if(!String.isBlank(rec.ZCOMMIT_QTY__c)){
            if(Double.valueOf(rec.ZCOMMIT_QTY__c) != 0){
               result = true;
            }
       }
       if(!String.isBlank(rec.ZCOMMIT_VALUE__c)){
           if(Double.valueOf(rec.ZCOMMIT_VALUE__c) != 0){
                result = true;
           }
       }     
       return result;   
    }    
   
    /**
     * @description : Offers with an operational lease should also include a rental fee.  
     * Rental fee materials have:  SAP Item Category Group = Z012 and CPQ Material Type = Service Item with Billing Plan
     * @param dealLines : The deal lines to validate
     * @param matMap : The Materials realted to deal lines with the SAP product number as the key
     * @return result : The deal validation result indicating if a problem was found  
     */
    //CPQATG-636
    public static DealValidationResult operationalLeaseIncludesRentalFee(List<Vistex_Deal_Line_E1KOMG__c> dealLines, Map<String, SAP_MAterial__c> matMap){
        DealValidationResult result = new DealValidationResult();
        result.isValid = true;

        Integer numOfOpLeases = 0;
        Integer numOfBillingPlans = 0;
        for(Vistex_Deal_Line_E1KOMG__c line: dealLines){            
            if(matMap.containsKey(line.MATNR__c)){
                SAP_Material__c mat = matMap.get(line.MATNR__c);            
                if(mat.CPQ_Material_Type__c == 'Operational Lease'){
                    numOfOpLeases++;
                }
                if(mat.CPQ_Material_Type__c == 'Service Item with Billing Plan'){
                    numOfBillingPlans++;
                }
            }
        }
        System.debug('Opertl Leases: ' + numOfOpLeases + ' Billing Plans: ' + numOfBillingPlans);
        if((numOfOpLeases > 0)  && numOfOpLeases > numOfBillingPlans){
            result.isValid = false;
            result.invalidReason = '- There is no rental fee material item included for at least one operatonal Lease item in this deal.';
            result.invalidRecordId = null;
        } 
        if(debug){
            System.debug('operationalLeaseIncludesRentalFee result: ' + result);
        } 
        return result;
    }
    

    /**
     * @description : Get a map of SAP Material with the SAP Product Number as the Key 
     * Rental fee materials have:  SAP Item Category Group = Z012 and CPQ Material Type = Service Item with Billing Plan
     * @param dealLines : The deal lines to get materials from
     * @return matMap : The Materials with the SAP product number as the key 
     */
    public static Map<String, SAP_MAterial__c> getMaterialMap(List<Vistex_Deal_Line_E1KOMG__c> dealLines){
        Set<String> materialNumbers = ApexUtils.pluckStringSet(dealLines, Schema.Vistex_Deal_Line_E1KOMG__c.MATNR__c);
        List<SAP_Material__c> materials = [
                SELECT Id, CPQ_Material_Type__c,SAP_Product_Number__c, CPQ_Material_Type_Grouping__c FROM SAP_Material__c 
                WHERE SAP_Product_Number__c IN :materialNumbers 
            ];
        Map<String, SAP_MAterial__c> matMap = new Map<String, SAP_MAterial__c>();
        for(SAP_Material__c material : materials){
            matMap.put(material.SAP_Product_Number__c,material);
        }
        return matMap;
    }    

     /**
     * @description : Handle multiple deal line validations in a single iteration
     * Assumptions:
     *  1. There should only be one eligibility record (ZEL4) per deal header - CPQATG-637
     *  2. Flexible groups are either associated to a device (ZDEV) or consumable (ZCON) deal type line (not on ZTER, ZANC etc). CPQATG-638
     * Rental fee materials have:  SAP Item Category Group = Z012 and CPQ Material Type = Service Item with Billing Plan
     * @param dealLines : The deal lines to validate
     * @return matMap : The list of deal validation results indicating if a problem was found 
     */
    public static List<DealValidationResult> bulkValidateDealLines(List<Vistex_Deal_Line_E1KOMG__c> dealLines){
        List<DealValidationResult> results = new List<DealValidationResult>();
        Integer zel4Count = 0;        
        for(Vistex_Deal_Line_E1KOMG__c line : dealLines){
            switch on line.KSCHL__c {
                when 'ZEL4'{
                    zel4Count++;
                }
            }            
           if(line.LIFNR__c != null && line.KSCHL__c != 'ZCON' && line.KSCHL__c != 'ZDEV'){
                results.add(createResult('- Flexible group' + line.LIFNR__c + ' is not associated to a decive or consumable line.',false,null));
           }
        }
        //There should only be one eligibility record (ZEL4) per deal header
        if(zel4Count == 0){
            results.add(createResult('- There is no ZEL4 deal line. A deal should only include a single ZEL4.',false,null));            
        }else if(zel4Count > 1){
            results.add(createResult('- There is more than one ZEL4 deal line. A deal should only include a single ZEL4.',false,null));           
        }
        if(debug){
            System.debug('bulkValidateDealLines results: ' + results);
        } 
        return results;
    }

    /**
     * @description : Create an output string of all messages separated by a new line
        This is originally intended for stamping error messages to the vistex deal header 
     * Rental fee materials have:  SAP Item Category Group = Z012 and CPQ Material Type = Service Item with Billing Plan
     * @param dealLines : The deal lines to validate
     * @return matMap : The list of deal validation results indicating if a problem was found 
     */
    public static String concatValidationResults(List<DealValidationResult> results){
        String output = '';
        for (DealValidationResult result: results){
            if(result.invalidReason != null && result.invalidReason != '' ){
                output += result.invalidReason + '\r\n';
            }            
        }
        return output;
    }

    /**
     * @description : Loop through a list of results to determine if there was a failed use case
     * @param results : The list of validation results to check for failures
     * @return isValid : true or false depending on the validation results 
     */
    public static Boolean isDealValid(List<DealValidationResult> results){
        Boolean isValid = true;
        for(DealValidationResult result : results){
            if(result.isValid == false){
                isValid = false;
                break;
            }
        }
        if(debug){
            System.debug('IsDealValid() results: ' + isValid);
        }
        return isValid;
    } 
    
    /**
     * @description : create a deal validation result
     * @param invalidReason : The reason this deal is invalid or not
     * @param isValid : true/false if the deal is valid
     * @return isValid : true or false depending on the validation results 
     */
    public static DealValidationResult createResult(String invalidReason, Boolean isValid, Id recordId){
        DealValidationResult result = new DealValidationResult();
        result.isValid = isValid;
        result.invalidReason = invalidReason;
        result.invalidRecordId = recordId;
        return result;
    }

     /**
     * @description : Query the child 
     * @param invalidReason : The reason this deal is invalid or not
     * @param isValid : true/false if the deal is valid
     * @return isValid : true or false depending on the validation results 
     */
    private static List<Vistex_ZO2C_E1KONP_CPQ__c> queryChildConditionsFromDealLines(Set<Id> dealLineRecordIds){
        return [
                SELECT Id, ZCOMMIT_QTY__c, ZCOMMIT_VALUE__c, E1KONH_Ext_Id__r.E1KOMG_Ext_Id__r.Id
                FROM Vistex_ZO2C_E1KONP_CPQ__c
                WHERE E1KONH_Ext_Id__r.E1KOMG_Ext_Id__r.Id IN :dealLineRecordIds
                ];
    }
}
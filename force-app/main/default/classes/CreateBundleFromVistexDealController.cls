/**
* File Name     :  CreateBundleFromVistexDealController
* @description  :  Controller for the aura component button to create a CPQ bundle from a vistex deal header record.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     1/28/2020		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020		Cory Bartholomew @ ATG     Added descriptions.
* 2.1     08/05/2020    Ramiro Alvarez @ ATG       Added custom setting to include replace CPQ bundle
* 2.2     09/15/2020    Ramiro Alvarez @ ATG       Fixing pre-validations in order to return processing
**/

global class CreateBundleFromVistexDealController {
    private static final String STATUS_OK = 'OK';
    private static final String STATUS_WARN = 'Warn';
    private static final String STATUS_ERR = 'Error';
    private static final String GENERIC_CREATE_BUNDLE_ERROR = 'There was an error creating the bundle. Please contact a Zoetis Administrator.';     
    
    /**
     * @description Inner class that is sent as the response to the aura component
     */
    global class CreateBundleResponse {
        
        @AuraEnabled
        public String Status { get; set; }

        @AuraEnabled
        public String Message { get; set; }

        @AuraEnabled
        public String AdditionalErrorInfo { get; set; }

        @AuraEnabled
        public List<CPQ_VistexDealValidator.DealValidationResult> validationResults { get; set; }

        CreateBundleResponse(){
            Status = STATUS_OK;
            Message = '';
        }
    }    
    
    
    /**
     * @description runs the code to create the deal and pass any error messages back to the component while also updaing the deal header
     * @param dealId The record id of the deal sourced from the page where the button is clicked
     */
    @AuraEnabled  
    public static CreateBundleResponse processDeal(String dealId){
        CreateBundleResponse response = new CreateBundleResponse();
        List<CPQ_VistexDealValidator.DealValidationResult> validationResults = new List<CPQ_VistexDealValidator.DealValidationResult>();
        try{
            //Get custom setting to check if CPQ Bundle updates is enable
            CPQBundleUpdates__c param = CPQBundleUpdates__c.getInstance();
            Boolean doReplace = (Boolean) param.isEnableBundleUpdate__c;

            Vistex_Deal_Header__c deal = queryDeal(dealId);
            if(deal.Exclude_From_Batch__c){
                validationResults.add(CPQ_VistexDealValidator.createResult('- This deal is already marked for exclusion.  No processing will occur.', false, deal.Id));
            }
            if (!doReplace) {
                if(deal.BundleWrapperProducts__r.size() > 0) {
                    validationResults.add(CPQ_VistexDealValidator.createResult('- This deal already has a bundle created. No processing will happen.', false, deal.Id));
                }
            }
            
            //Make assertions about this deal before we do anything else           
            validationResults.addAll(CPQ_VistexDealValidator.runPreValidations(deal, deal.Vistex_Deal_Line__r));	
            
            // *** IF PRE VALIDATIONS RESULTS IS NOT EMPTY HERE, SET ERROR AND STOP PROCESS ***            
            if(!CPQ_VistexDealValidator.isDealValid(validationResults)) {
                System.debug('Entering to pre-validation results');
                deal.Exclude_From_Batch__c = true;
                deal.Deal_Validity_Issues__c = CPQ_VistexDealValidator.concatValidationResults(validationResults);
                try{
                    System.debug('Invalid deal: ' + CPQ_VistexDealValidator.concatValidationResults(validationResults));
                    update deal;
                    System.debug('Deal to be updated: ' + deal);
                    response.Status = STATUS_ERR;
                    response.validationResults = validationResults;
                    response.Message = 'There were errors PRE processing the Vistex Deal. Please reference the "Deal Validity Issues" field on this record.';
                    response.AdditionalErrorInfo = CPQ_VistexDealValidator.concatValidationResults(validationResults);
                    return response;
                }catch (Exception preEx){
                    System.debug('Error trying to update Deal on preVal:' + preEx.getMessage() + ' Trace: ' + preEx.getStackTraceString());                    
                }
            }
            
            AutoBundleDataCollector collector = new AutoBundleDataCollector(deal);            
            //Get the data for the deal				
            AutoBundleDataWrapper dealData = collector.collectDealBundleData();
            //Add validation results from data collector
            validationResults.addAll(collector.validationResults);

            System.debug('ValidationResults after dealData: ' + validationResults);	
            
            //Check the validation results again.  We only want to create the bundle if there were no issues with the bundle structure
            if(!collector.excludeFromDealCreation && CPQ_VistexDealValidator.isDealValid(validationResults)) {
                //Build the bundle for this deal
                if(dealData != null){
                    System.debug('Call to AutoBundleBuilder...' + dealData);
                    AutoBundleBuilder builder = new AutoBundleBuilder(dealData);
                    builder.createBundle();
                }
            }	      

            if(collector.excludeFromDealCreation || !CPQ_VistexDealValidator.isDealValid(validationResults)){
                if(collector.excludeFromDealCreation){
                    validationResults.add(CPQ_VistexDealValidator.createResult('- The Deal was marked for exlusion because it does not contain either a device, consumable or flexible group.', false, deal.Id));
                }                	
                //If there was no ZDev or ZCon we donb't want the deal to be created.  Update the exclusion indicator so the batch will not pick it up in the future
                deal.Exclude_From_Batch__c = true;
                if(!CPQ_VistexDealValidator.isDealValid(validationResults)){                    
                    deal.Deal_Validity_Issues__c = CPQ_VistexDealValidator.concatValidationResults(validationResults);
                }
                try{
                update deal;
                } catch(exception e) {
                    System.debug('There was an error while trying to update the excusion indicator: ' + deal.DEALNUM_EXT__c + ' Ex: ' + e.getMessage());
                }
            }
        }catch(Exception ex){
            response.Status = STATUS_ERR;
            response.AdditionalErrorInfo = ex.getMessage();
            System.debug('ERROR: ' + ex.getMessage() + ' line: ' + ex.getLineNumber() + ' trace: ' + ex.getStackTraceString());
        }finally{
            if(!CPQ_VistexDealValidator.isDealValid(validationResults)){
                response.Status = STATUS_ERR;
                response.validationResults = validationResults;
                response.Message = 'There were errors processing the Vistex Deal.  Please reference the "Deal Validity Issues" field on this record.';
                response.AdditionalErrorInfo = CPQ_VistexDealValidator.concatValidationResults(validationResults);
            } 
        }
        return response;   
    } 

    /**
     * @description Query the necessary deal information to run in the auto-bundle code.
     * @param dealId The record id of the deal sourced from the page where the button is clicked
     */
    private static Vistex_Deal_Header__c queryDeal(String dealId){
        return [
            SELECT Id, Name, BOART_AG__c, Commitment_Indicator__c, CURRENCY__c, DEALK01_Ext_Id__c, DEALNUM__c, DEALNUM_EXT__c, DEALTXT__c, ORGID__c, 
                QULAF__c, Transaction_Type_CPQ__c, VALID_FROM__c, VALID_TO__c, CPQ_Transaction_Type_Text__c, Exclude_From_Batch__c,
                Is_Third_Party_Lease_Default__c,Add_Cash_Back_Bundle__c,Add_Competitive_Buy_Out_Bundle__c,Add_Internal_Buy_Out_Bundle__c,
                Add_Consumables_Ancillaries_Available__c,
                ( 
                    SELECT Id, Name, DEALK01_Ext_Id__c, LOEVM_KO__c, E1KOMG_Ext_Id__c, EBONU__c, EKKOA__c, 
                    KOTBNR__c, KSCHL__c, LIFNR__c, MATNR__c, VAKEY__c, DEALK01_Ext_Id__r.ORGID__c
                    FROM Vistex_Deal_Line__r 
                    WHERE LOEVM_KO__c = NULL OR LOEVM_KO__c = ''
                ), 
                ( 
                    SELECT Id, ProductCode 
                    FROM BundleWrapperProducts__r )
            FROM Vistex_Deal_Header__c
            WHERE Id =: dealId
        ];
    }				
		
			
}
/**
* File Name     :  CreateQuoteController
* @description  :  Controller class for 'CreateQuote' lightning component.
* @author       :  Facundo Castello @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0     12/2019       Facundo Castello @ ATG     Created the Class.
* 1.1     1/2020        Cory Bartholomew @ ATG     Updated class to enhance sold to address functionality.
* 1.2     7/2020        Ramiro Alvarez @ ATG       CPQATG-620 Query Account_Market_Eligibility__c to get program eligibility
* 1.3     3/11/21       Ramiro Alvarez @ ATG       CPQATG-1299 Deprecate Distributor and Leasing Agents
* 1.4     12/15/22      Mila Imas                  populate install date with default value
* 1.5 	  3/29/23		Mila Imas   			   Updated method getSoldToAddress for handling setting up of Address data with blank oppSapAccountIdand active flg
* 1.6     04/11/23      Indranil Deria             populate opportunity customer language value on quote and update opportunity while creating Quote
* 1.5 	  3/29/23		Mila Imas   
* 1.6     10/17/23		Rahul @Deloitte			   Added Doctor_Contact__c in getOpportunityData method for TPDEV 2121 
*/

global without sharing class CreateQuoteController {
    private static final String STATUS_OK = 'OK';
    private static final String STATUS_WARN = 'Warn';
    private static final String STATUS_ERR = 'Error';
    private static final String GENERIC_CREATE_QUOTE_ERROR = 'There was an error creating the quote. Please contact a Zoetis Administrator.';

    global class CreateQuoteResponse {
        @AuraEnabled
        public String Status { get; set; }

        @AuraEnabled
        public String Message { get; set; }

        @AuraEnabled
        public String AdditionalErrorInfo { get; set; }

        @AuraEnabled
        public Opportunity opportunity { get; set; }

        @AuraEnabled
        public Address__c soldToAddress { get; set; }

        public CreateQuoteResponse() {
            Status = STATUS_OK;
            Message = '';
        }
    }

    /**
     * @description Get needed information to render initial quote values on lightning component.
     * @param opportunityId Id of the Opportunity.
     * @return A CreateQuoteResponse with messages and status to say what's the result.
     */
    @AuraEnabled
    public static CreateQuoteResponse getOpportunityData(String opportunityId) {
        CreateQuoteResponse result = new CreateQuoteResponse();
        Boolean error = false;

        try {
            Opportunity opportunity = [
                SELECT
                    AccountId, //Distributor_Add__c,
                    Id,
                    SBQQ__QuotePricebookId__c,
                    Account.ZTS_EU_Primary_Address__c,
                    Account.ZTS_EU_Primary_Address__r.ZTS_US_Source_Account_Number__c,
                    Account.ZTS_EU_SAP_Customer_ID__c,
                    Market__c,Customer_Language__c,Country1__c,Internet_Speed_Available__c,
                    Market__r.Change_Language_Flag__c,Market__r.Change_Customer_Language__c,
                	Doctor_Contact__c,Market__r.Authorized_Zoetis_Signature_for_VR__c
                FROM Opportunity
                WHERE Id = :opportunityId
            ];
            result.opportunity = opportunity;
            result.soldToAddress = getSoldToAddress(opportunity.AccountId, opportunity.Account.ZTS_EU_SAP_Customer_ID__c);

            return result;
        } catch (exception ex) {
            error = true;
            result.AdditionalErrorInfo = ex.getMessage();
            result.Status = STATUS_ERR;
            System.debug('ERROR: ' + ex.getMessage() + ' trace: ' + ex.getStackTraceString());
        }

        if (error) {
            result.Message = GENERIC_CREATE_QUOTE_ERROR;
        }

        // Commit error logs
        ErrorLogUtil.commitLogs();

        return result;
    }

    /**
     * @description Create a quote with the data from the lighting component and get it related eligibility.
     * @param primary primary field on Quote.
     * @param opportunityId Id of the Opportunity.
     * @param startDate startDate of the Quote.
     * @param accountId Id of the account.
     * @param addressId Id of the sold to address.
     * @param leasingAgentAddressId Id of the leasing agent Address.
     * @param distributorAddressId Id of the distributor Address.
     * @return A CreateQuoteResponse with messages and status to say what's the result.
     * @update opportunity while creating new Quote.
     */
    @AuraEnabled
    public static CreateQuoteResponse createQuote(
        Boolean primary,
        Id opportunityId,
        Date startDate,
        Id accountId,
        Id addressId,
        string language,
        string intSpeed
    ) {
        CreateQuoteResponse result = new CreateQuoteResponse();
        Boolean error = false;
        String message = '';

        // Validate Address
        Address__c soldToAddress = [SELECT Id, ZTS_EU_Account__c, ZTS_US_Source_Account_Number__c FROM Address__c WHERE Id = :addressId];
        if (soldToAddress.ZTS_EU_Account__c != accountId) {
            result.Message = 'The selected address is not related with the account';
            result.Status = STATUS_ERR;
            return result;
        }

        try {
            Opportunity opp = [SELECT Id, Market__c, Market__r.Sales_Org__c, SAP_Account_ID__c,Estimated_Installation_Date__c,Customer_Language__c,Internet_Speed_Available__c FROM Opportunity WHERE Id = :opportunityId];
            date reqInstallDate = Date.today() + 30;    
            if (opp.Estimated_Installation_Date__c != null) {reqInstallDate = opp.Estimated_Installation_Date__c; } 
            SBQQ__Quote__c quote = new SBQQ__Quote__c(
                SBQQ__Primary__c = primary,
                SBQQ__Opportunity2__c = opportunityId,SBQQ__StartDate__c = Date.today(),
                Requested_Installation_Date__c = reqInstallDate ,SBQQ__Account__c = accountId, Address__c = addressId,
                Customer_Language__c = language, Internet_Speed_Available__c = intSpeed,
               /* CPQATG-1299 Deprecate Distributor and Leasing Agent
                Distributor_Add__c = distributorId, 
                Leasing_Agent_Add__c = leasingAgentId,*/
                //CPQATG-660 If a leasing agent was specified map these two addresses to this value, otherwise map to Sold-To Address
                Bill_To_Address__c = addressId,Payer_Address__c = addressId, Ship_To_Address__c = addressId,
                Sales_Org_Market__c = opp.Market__c
            );
            
            //String customerNumber = opp.SAP_Account_ID__c;
            String customerNumber = soldToAddress.ZTS_US_Source_Account_Number__c;
            String salesOrg = opp.Market__r.Sales_Org__c;

            if (salesOrg == '1436') { // CPQATG-1287 - Only populate eligible/ineligible for United States

                // List for inelible Programs
                List<String> eligibleList = new List<String> ();

                //CPQATG-620 Account_Market_Elegibility__c is being populated from Heroku transformation
                List<Account_Market_Eligibility__c> accountMarketElegibility = [
                    SELECT Customer_Number__c, Eligible_Programs__c, Sales_Organization__c
                    FROM Account_Market_Eligibility__c
                    WHERE Customer_Number__c = :customerNumber AND Sales_Organization__c = :salesOrg
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                System.debug('CreateQuoteController > accountMarketElegibility: ' + accountMarketElegibility);
                
                if (!accountMarketElegibility.isEmpty()) {
                    //quote.Eligible_Programs__c = accountMarketElegibility[0].Eligible_Programs__c;                
                    quote.Eligible_Programs__c = traduceProgramFilters(accountMarketElegibility[0].Eligible_Programs__c);
                    eligibleList = accountMarketElegibility[0].Eligible_Programs__c.split(',');
                } else {
                    quote.Eligible_Programs__c = 'NoEligiblePrograms'; // CPQATG-1287 if no results in query, stamp 'NoEligiblePrograms' in the Eligible Program field
                    eligibleList.add('NoEligiblePrograms');
                }

                System.debug('CreateQuoteController > eligibleList: ' + eligibleList);

                //Look for market name
                List<Market__c> marketList = [SELECT Id, Name
                                            FROM Market__c
                                            WHERE Sales_Org__c = :salesOrg];
                
                String market = !marketList.isEmpty() ? marketList[0].Id : '';

                System.debug('CreateQuoteController > market: ' + market);

                //CPQATG-1243 Look for inelible Programs
                List<Product2> inelibleProducts = [SELECT Id, IsActive, ZTS_EU_Market__c,
                                                Program_Eligibility_Filter__c
                                                FROM Product2
                                                WHERE IsActive = TRUE
                                                AND Market__c = : market
                                                AND Program_Eligibility_Filter__c NOT IN :eligibleList];

                System.debug('CreateQuoteController > inelibleProducts: ' + inelibleProducts);
                
                Map<String,String> inelibleOffersMap = new Map<String,String> ();
                for (Product2 product : inelibleProducts) {
                    inelibleOffersMap.put(product.Program_Eligibility_Filter__c,product.Program_Eligibility_Filter__c);
                }

                if (!inelibleOffersMap.isEmpty()) {
                    String inelibleOffersString = String.join(inelibleOffersMap.values(),',');
                    System.debug('CreateQuoteController > inelibleOffersString: ' + inelibleOffersString);

                    //quote.Ineligible_Programs__c = inelibleOffersString;
                    quote.Ineligible_Programs__c = traduceProgramFilters(inelibleOffersString);
                }
            }

            insert quote;

            SBQQ__Quote__c quoteWithName = [SELECT Name,Customer_Language__c,Internet_Speed_Available__c FROM SBQQ__Quote__c WHERE Id = :quote.Id];
            if(quoteWithName.Customer_Language__c != null || quoteWithName.Customer_Language__c != ''){
                opp.Customer_Language__c = quoteWithName.Customer_Language__c;
                update opp;
            }
            if(quoteWithName.Internet_Speed_Available__c != null || quoteWithName.Internet_Speed_Available__c != ''){
                opp.Internet_Speed_Available__c = quoteWithName.Internet_Speed_Available__c;
                update opp;
            }
            result.Message = 'Quote ' + quoteWithName.Name + ' has been added.';
            return result;
        } catch (exception ex) {
            error = true;
            ErrorLogUtil.log(ex);
            result.AdditionalErrorInfo = ex.getMessage();
            message = ex.getMessage();
            result.Status = STATUS_ERR;
        }

        if (error) {
            result.Status = STATUS_ERR;
            result.Message = message == '' ? GENERIC_CREATE_QUOTE_ERROR : message;
        }

        // Commit error logs
        ErrorLogUtil.commitLogs();

        return result;
    }

    @AuraEnabled
    public static Address__c getSoldToAddress(Id accountId, String oppSapAccountId) {
        Address__c soldToAddress = new Address__c();

        //Query all addresses associated to the opp account
        //MI added active flag Is_Active__c = true and 
        system.debug('method getSoldToAddress ===> '+ oppSapAccountId) ;
        List<Address__c> addresses = [
            SELECT Id, ZTS_US_Source_Account_Number__c, Length_of_Source_Account_Number__c
            FROM Address__c
            WHERE Is_Active__c = true and ZTS_EU_Account__c = :accountId AND Length_of_Source_Account_Number__c = 10 order by ZTS_US_Source_Account_Number__c
        ];
// should be Is_Active__c = true  
        List<Address__c> soldToAddresses = new List<Address__c>();
        //Get any related Sold To Addresses
        for (Address__c address : addresses) {
            //SAP Account Id that starts with 1 indicates a sold to address
            //MI
            if (!String.isBlank(address.ZTS_US_Source_Account_Number__c)) {
                //shipto could be used for billing
                if (address.ZTS_US_Source_Account_Number__c.left(1) == '1' || address.ZTS_US_Source_Account_Number__c.left(1) == '2' ) {
                    soldToAddresses.add(address);
                }
            }
        }
        System.debug('Sold To Addresses: ' + soldToAddresses);
        if (soldToAddresses.size() == 1) {
            //If there is a single sold to address, return that address.
            soldToAddress.Id = soldToAddresses[0].Id;
        } else if (soldToAddresses.size() > 1) {
            //check for a sold To that has the Source account of the opp account.
            //Check if the opp account SAP number starts with 2 to indicate this quote started via a Ship-To account
            //User will have to pick the sold To Address - return null

            //09152020 - FIX for oppSapAccountId = null
            if (oppSapAccountId != null && oppSapAccountId != '') {
                //commented by MI
                /*if (oppSapAccountId.left(1) == '2') {
                   // return null; 
                } else {
                    //If the opp account is not a ship to check for an address that matches the SAP Account Id
                    for (Address__c addr : soldToAddresses) {
                        if (addr.ZTS_US_Source_Account_Number__c == oppSapAccountId) {
                            soldToAddress.Id = addr.Id;
                        }
                    }
                } */
                for (Address__c addr : soldToAddresses) {
                    if (addr.ZTS_US_Source_Account_Number__c == oppSapAccountId) {
                        soldToAddress.Id = addr.Id;
                    }
                }

            }else{
                //This section of code added by Mila Imas for handling blank oppSapAccountId
                for (Address__c addr : soldToAddresses) {
                    if (addr.ZTS_US_Source_Account_Number__c.left(1) == '1' || addr.ZTS_US_Source_Account_Number__c.left(1) == '2'){
                        if(addr.ZTS_US_Source_Account_Number__c.left(1) == '1'){
                            soldToAddress.Id = addr.Id;
                            break;
                        }
                        soldToAddress.Id = addr.Id;
                    }
                }
            }
        }
        return soldToAddress;
    }

    private static String traduceProgramFilters(String programOffers) {
        System.debug('traduceProgramFilters, before: ' + programOffers);
        List<String> programList = programOffers.split(',');
        List<String> traducedProgramList = new List<String> ();
        for (String program : programList) {
            traducedProgramList.add('CPQ-' + program + '-CPQ');
        }
        String translatedProgramOffer = String.join(traducedProgramList,',');
        System.debug('traduceProgramFilters, after: ' + translatedProgramOffer);
        return translatedProgramOffer;
    }
    
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(String opportunityId){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Market__c.Change_Customer_Language__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }
}
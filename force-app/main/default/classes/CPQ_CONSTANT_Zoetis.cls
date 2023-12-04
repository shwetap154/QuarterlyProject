/**
* @description       : Constants For CPQ Apex Classes
* @author            : Rahul Kumar @Deloitte
* @test class        : 

* Modifications Log
* Ver   Date         Author                       Modification
* 1.0   07-26-2023   Rahul Kumar @Deloitte        Initial Version
**/

public class CPQ_CONSTANT_Zoetis {
    
    
    /*---------------------------------- CPQ General Constants----------------------------------*/
    public static final String STRING_QUOTE = 'Quote';
    public static final String STRING_QUOTE_LINE_NUMBER = 'Quote Line Number';
    public static final String STRING_MATERIAL_NUMBER = 'Material Number';
    public static final String STRING_MATERIAL_TYPE = 'Material Type';
    public static final String STRING_MATERIAL_TYPE_GROUPING = 'Material Type Grouping';
    public static final String STRING_LEASE_TYPE = 'Lease Type';
    public static final String STRING_AGGR_CMT_LINE = 'Is Aggregate Commitment Line';
    public static final String STRING_AGGR_SPREAD_LINE = 'Is Aggregate Spread Line';
    public static final String STRING_SPC_CMT = 'Is Specific Commitment';
    public static final String STRING_AUTO_SHIP = 'Auto-Ship?';
    public static final String STRING_NET_PRICE = 'Net price';
    public static final String STRING_SUPPLIER = 'Supplier';
    public static final String STRING_INSTALLMENT = 'Installment';
    public static final String STRING_COLON = ': ';
    public static final String STRING_ADDRESS_ACC_ERROR = 'Ship to Address is not within the account hierarchy. Please select a valid address. \r\n';
    public static final String STRING_NO = 'No';
    public static final String STRING_NOT_STARTED = 'Not Started';
    public static final String STRING_PRIMARY_QUOTE_APPROVAL_ERROR = 'Please mark the quote as Primary prior to submitting it for approval';
    public static final String STRING_PRICEBOOK_ERROR =  'A price book entry is missing for one or more quote lines. ' + 'Either remove these product(s) from your quote, or contact your Salesforce Administrator to have this price book entry added.';
    public static final String STRING_QUOTE_API_NAME = 'SBQQ__Quote__c';
    public static final String STRING_QUOTELINE_API_NAME = 'SBQQ__QuoteLine__c';
    
    
    
    /*---------------------------------- CPQ Order Item Constants----------------------------------*/
    public static final String STRING_ERROR_MSG_NULL_MATERIAL_TYPE = 'Not able to determine Usage Type or Item Category for Order Product: Material Type NOT set.';
    public static final String STRING_ANCILLARY = 'Ancillary';
    public static final String STRING_SERVICE_TEAM = 'VR Service Item';
    public static final String STRING_DISTRIBUTOR = 'Distributor';
    public static final String STRING_ZOETIS = 'Zoetis';
    public static final String STRING_DEVICE_LEASE = 'Device Sale/Third Party Lease';
    public static final String STRING_SALES_LEASE = 'Sales Type Lease';
    public static final String STRING_OPERATING_LEASE = 'Operating Lease';
    public static final String STRING_BUY_OUT = 'Buy Out';
    public static final String STRING_BUY_OUT_EQP_RET = 'Buy Out - Equipment Return';
    public static final String STRING_CASH_BACK = 'Cash Back';
    public static final String STRING_CONTRACT_CHARGE = 'Contract Charge';
    public static final String STRING_PT_RES_PARA = 'PT - Residual Parameter';
    public static final String STRING_PT_CONTRACT_CHARGE = 'PT - Contract Charge';
    public static final String STRING_PT_TRANS_BET_CON = 'PT - Transfer Device Between Contracts';
    public static final String STRING_CO_SOURCE = 'Co-Sourced';
    public static final String STRING_ERROR_MSG_NOT_DETERMINE = 'Not able to determine the Type of the Program Charge Material. ';
    public static final String STRING_PRG_CHARGE_MAT_MSG = 'Make sure the "Program Charge Material" configuration in Custom Settings is properly set.';
    public static final String STRING_CONSUMABLE = 'Consumable';
    public static final String STRING_DEVICE = 'Device';
    public static final String STRING_SER_ITEM_BILL_PLAN = 'Service Item with Billing Plan';
    public static final String STRING_PRG_CHARGE = 'Program Charge';
    public static final String STRING_WARRANTY = 'Warranty';
    public static final String STRING_STANDARD_WARRANTY = 'Standard Warranty';
    public static final String STRING_SER_EXTND_WARRANTY = 'Service for Extended Warranty Items';
    public static final String STRING_EXTND_WARRANTY = 'Extended Warranty';
    
    /****** Quote Line Trigger Handler ********/
    public static final String STRING_AGGR_CMNT_SER = 'Aggregate Commitment Service Item';
    public static final String STRING_PROGRAMS = 'Programs';
    
    
}
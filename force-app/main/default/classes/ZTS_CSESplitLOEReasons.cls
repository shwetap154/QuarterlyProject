/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_CSESplitLOEReasons
 * Description  : All  Logic for ZTS_CSESplitLOEReasons class.
 * Created By   : Slalom(Neil Kapoor) 
 * Created Date : 09/27/2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Neil Kapoor		  		    09/27/2021			  Created    
*****************************************************************************************************************************************/

public class ZTS_CSESplitLOEReasons 
{
    public static final String MISSING_ID_ERROR = 'Missing Case Product Id';

    @AuraEnabled
    public static List<String> getLoeReasons( Id caseProductId )
    {
        // if the case product id passed in is null, lets throw an exception
        if ( caseProductId == null )
        {
            throw new AuraHandledException( MISSING_ID_ERROR );
        }

        // lets query the related product 
        ZTS_US_Case_Product__c caseProduct = [ SELECT Id, 
                                                      ZTS_US_PVW_Product__c, 
                                                      ZTS_US_PVW_Product__r.ZTS_US_LOE_Reason__c 
                                                FROM ZTS_US_Case_Product__c
                                                WHERE Id = :caseProductId ];

        if ( String.isNotBlank( caseProduct.ZTS_US_PVW_Product__r.ZTS_US_LOE_Reason__c ) )
        {
            return caseProduct.ZTS_US_PVW_Product__r.ZTS_US_LOE_Reason__c.split( ',' );
        }
        else 
        {
            // we need to use generic loe reasons if we don't have any non generic ones
            List<String> picklistValues = new List<String>();

            Schema.DescribeFieldResult loeFieldDescribe = ZTS_US_PVW_Product__c.ZTS_US_Generic_LOE_Reasons__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = loeFieldDescribe.getPicklistValues();
            
            for ( Schema.PicklistEntry aPicklistEntry : picklistEntries )
            {
                picklistValues.add( aPicklistEntry.getLabel() );
            }

            return picklistValues;
        }
    }

    @AuraEnabled
    public static List<String> getReasonsForUse( Id caseProductId )
    {
        // if the case product id passed in is null, lets throw an exception
        if ( caseProductId == null )
        {
            throw new AuraHandledException( MISSING_ID_ERROR );
        }

        // lets query the related product 
        ZTS_US_Case_Product__c caseProduct = [ SELECT Id, 
                                                      ZTS_US_PVW_Product__c, 
                                                      ZTS_US_PVW_Product__r.ZTS_US_Reason_For_Use__c 
                                                FROM ZTS_US_Case_Product__c
                                                WHERE Id = :caseProductId ];

        if ( String.isNotBlank( caseProduct.ZTS_US_PVW_Product__r.ZTS_US_Reason_For_Use__c ) )
        {
            return caseProduct.ZTS_US_PVW_Product__r.ZTS_US_Reason_For_Use__c.split( ',' );
        }
        else 
        {
            // we need to use generic loe reasons if we don't have any non generic ones
            List<String> picklistValues = new List<String>();

            Schema.DescribeFieldResult reasonForUseFieldDescribe = ZTS_US_PVW_Product__c.ZTS_US_Generic_Reasons_for_Use__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = reasonForUseFieldDescribe.getPicklistValues();
            
            for ( Schema.PicklistEntry aPicklistEntry : picklistEntries )
            {
                picklistValues.add( aPicklistEntry.getLabel() );
            }

            return picklistValues;
        }
    }

    @AuraEnabled
    public static void updateRelatedCaseProduct( Id caseProductId, String loeReason, String reasonForUse )
    {
        if ( caseProductId == null || ( loeReason == null && reasonForUse == null ) )
        {
            return;
        }

        ZTS_US_Case_Product__c caseProductToUpdate = new ZTS_US_Case_Product__c(
            Id = caseProductId
        );

        if ( String.isNotBlank( loeReason ) )
        {
            caseProductToUpdate.ZTS_US_LOE_Reason__c = loeReason;
        }

        if ( String.isNotBlank( reasonForUse ) )
        {
            caseProductToUpdate.ZTS_US_Reason_For_Use__c = reasonForUse;
        }

        try 
        {
            update caseProductToUpdate;
        }
        catch ( Exception e )
        {
            throw new LOEReasonException( e.getMessage() );
        }
    }

    public class LOEReasonException extends Exception {}
    
}
/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_CSESplitLOEReasonsTest
 * Description  : All Unit Test Logic for ZTS_CSESplitLOEReasons class.
 * Created By   : Slalom(Neil Kapoor) 
 * Created Date : 10/28/2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Neil Kapoor		  		    10/28/2021			  Created    
*****************************************************************************************************************************************/

@IsTest
private class ZTS_CSESplitLOEReasonsTest 
{
    static final String LOE_REASON_A = 'loeA';
    static final String LOE_REASON_B = 'loeB';
    static final String LOE_REASON_C = 'loeC';
    static final String LOE_REASON_D = 'loeD';

    static final String REASON_FOR_USE_A = 'reasonA';
    static final String REASON_FOR_USE_B = 'reasonB';
    static final String REASON_FOR_USE_C = 'reasonC';
    static final String REASON_FOR_USE_D = 'reasonD';

    static final String ANIMAL_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Animal_Support' ).getRecordTypeId(); 

    static final Set<String> LOE_REASONS = new Set<String>{ LOE_REASON_A, LOE_REASON_B, LOE_REASON_C, LOE_REASON_D };
    static final Set<String> REASONS_FOR_USE = new Set<String>{ REASON_FOR_USE_A, REASON_FOR_USE_B, REASON_FOR_USE_C, REASON_FOR_USE_D };

    @TestSetup
    public static void setupData()
    {
        Case testCase = new Case(Subject = 'Test Case',
        Status = 'New',
        Origin = 'Email',
        Type = 'Animal Complaint',
        RecordTypeId = ANIMAL_RECORD_TYPE_ID);
        insert testCase;

        String loeString = String.join( new List<String>( LOE_REASONS ), ',' );
        String reasonsForUseString = String.join( new List<String>( REASONS_FOR_USE ), ',' );

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_PVW_Product__c
            (  
                ZTS_US_MAH_Country__c = 'US',
                ZTS_US_Active_Product__c = 'Yes',
                ZTS_US_LOE_Reason__c = loeString,
                ZTS_US_Reason_For_Use__c = reasonsForUseString
            )
        ,   true
        );


        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Case_Product__c
            (    ZTS_US_Administered_By__c   = 'Other',
                 ZTS_US_Dose_Unit__c = 'Bolus',
                 ZTS_US_Dose__c = 1,
                 ZTS_US_Product_problem_type__c = 'Ecotoxicity',
                 ZTS_US_Product_Used_Correctly__c = 'Yes',
                 ZTS_US_Case__c = testCase.id,
                 ZTS_US_PVW_Product__c = testProduct.id
            )
        ,   true
        );

    }

    @IsTest
    static void test_getLOEReasons_Postive()
    {
        ZTS_US_Case_Product__c caseProduct = [ SELECT Id FROM ZTS_US_Case_Product__c ];

        Test.startTest();
            List<String> loeReasons = ZTS_CSESplitLOEReasons.getLoeReasons( caseProduct.Id );
        Test.stopTest();

        System.assertNotEquals( null, loeReasons, 'We expect to have retrieved a list of loe reasons.' );
        System.assert( !loeReasons.isEmpty(), 'We expect to have retrieved a list of loe reasons, not an empty list.' );
        
        for ( String loeReason : loeReasons )
        {
            System.assert( LOE_REASONS.contains( loeReason ), 'We expect to have returned loe reasons from the pvw product record. ' );

        }
    }

    @IsTest
    static void test_getLOEReasons_negative_exception()
    {
        Boolean didThrowException = false; 

        try 
        {
            List<String> loeReasons = ZTS_CSESplitLOEReasons.getLoeReasons( null );
        }
        catch ( Exception e )
        {
            didThrowException = true;
        }

        System.assert( didThrowException, 'We expect to throw an exception when no case product id is passed to the method.' );
        
    }

    @IsTest
    static void test_getReasonsForUse_Postive()
    {
        ZTS_US_Case_Product__c caseProduct = [ SELECT Id FROM ZTS_US_Case_Product__c ];

        Test.startTest();
            List<String> reasonsForUseList = ZTS_CSESplitLOEReasons.getReasonsForUse( caseProduct.Id );
        Test.stopTest();

        System.assertNotEquals( null, reasonsForUseList, 'We expect to have retrieved a list of loe reasons.' );
        System.assert( !reasonsForUseList.isEmpty(), 'We expect to have retrieved a list of loe reasons, not an empty list.' );
        
        for ( String reasonForUse : reasonsForUseList )
        {
            System.assert( REASONS_FOR_USE.contains( reasonForUse ), 'We expect to have returned loe reasons from the pvw product record. ' );

        }
    }

    @IsTest
    static void test_getReasonsForUse_negative_exception()
    {
        Boolean didThrowException = false; 

        try 
        {
            List<String> reasonsForUseList = ZTS_CSESplitLOEReasons.getReasonsForUse( null );
        }
        catch ( Exception e )
        {
            didThrowException = true;
        }

        System.assert( didThrowException, 'We expect to throw an exception when no case product id is passed to the method.' );
        
    }

    @IsTest
    static void test_updateRelatedCaseProduct_positive_loereason()
    {
        ZTS_US_Case_Product__c caseProduct = [ SELECT Id FROM ZTS_US_Case_Product__c ];

        Test.startTest();
            ZTS_CSESplitLOEReasons.updateRelatedCaseProduct( caseProduct.Id, LOE_REASON_A, null );
        Test.stopTest();
        
        ZTS_US_Case_Product__c queriedCaseProduct = [ SELECT Id,
                                                      ZTS_US_LOE_Reason__c,
                                                      ZTS_US_Reason_For_Use__c    
                                                FROM ZTS_US_Case_Product__c 
                                                WHERE Id = :caseProduct.Id ];

        System.assertEquals( LOE_REASON_A, queriedCaseProduct.ZTS_US_LOE_Reason__c, 'We expect the case product record to be updated with the selected LOE reason.' );

    }

    @IsTest
    static void test_updateRelatedCaseProduct_positive_reasonForUse()
    {
        ZTS_US_Case_Product__c caseProduct = [ SELECT Id FROM ZTS_US_Case_Product__c ];

        Test.startTest();
            ZTS_CSESplitLOEReasons.updateRelatedCaseProduct( caseProduct.Id, null, REASON_FOR_USE_A );
        Test.stopTest();
        
        ZTS_US_Case_Product__c queriedCaseProduct = [ SELECT Id,
                                                      ZTS_US_LOE_Reason__c,
                                                      ZTS_US_Reason_For_Use__c    
                                                FROM ZTS_US_Case_Product__c 
                                                WHERE Id = :caseProduct.Id ];

        System.assertEquals( REASON_FOR_USE_A, queriedCaseProduct.ZTS_US_Reason_For_Use__c, 'We expect the case product record to be updated with the selected reason for use.' );

    }

    @IsTest
    static void test_updateRelatedCaseProduct_negative_nocaseproduct()
    {
        ZTS_US_Case_Product__c caseProduct = [ SELECT Id FROM ZTS_US_Case_Product__c ];

        Test.startTest();
            ZTS_CSESplitLOEReasons.updateRelatedCaseProduct( null, null, REASON_FOR_USE_A );
        Test.stopTest();
        
        ZTS_US_Case_Product__c queriedCaseProduct = [ SELECT Id,
                                                      ZTS_US_LOE_Reason__c,
                                                      ZTS_US_Reason_For_Use__c    
                                                FROM ZTS_US_Case_Product__c 
                                                WHERE Id = :caseProduct.Id ];

        System.assertNotEquals( REASON_FOR_USE_A, queriedCaseProduct.ZTS_US_Reason_For_Use__c, 'We expect the case product record to be updated with the selected reason for use.' );

    }

    @IsTest
    static void test_getGenericLOEReasons()
    {
        Case testCase = [ SELECT Id FROM Case ];

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_PVW_Product__c
            (  
                ZTS_US_MAH_Country__c = 'US',
                ZTS_US_Active_Product__c = 'Yes'
            )
        ,   true
        );

        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Case_Product__c
            (    ZTS_US_Administered_By__c   = 'Other',
                 ZTS_US_Dose__c = 1
            ,    ZTS_US_Dose_Unit__c = 'Bolus'
            ,    ZTS_US_Product_problem_type__c = 'Ecotoxicity'
            ,    ZTS_US_Product_Used_Correctly__c = 'Yes'
            ,    ZTS_US_Case__c = testCase.Id
            ,    ZTS_US_PVW_Product__c = testProduct.Id
            )
        ,   true
        );


        Test.startTest();
        List<String> loeReasons = ZTS_CSESplitLOEReasons.getLoeReasons( caseProduct.Id );
        Test.stopTest();

        System.assertNotEquals( null, loeReasons, 'We expect to have retrieved a list of loe reasons.' );
        System.assert( !loeReasons.isEmpty(), 'We expect to have retrieved a list of loe reasons, not an empty list.' );
        
        for ( String loeReason : loeReasons )
        {
            System.assert( String.isNotBlank( loeReason ), 'We expect to have non null values for generic loe reasons' );
            System.assert( !LOE_REASONS.contains( loeReason ), 'We expect to have returned generic loe reasons from the pvw product record. ' );

        }
    }

    @IsTest
    static void test_getGenericReasonsForUse()
    {
        Case testCase = [ SELECT Id FROM Case ];

        ZTS_US_PVW_Product__c testProduct = (ZTS_US_PVW_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_PVW_Product__c
            (  
                ZTS_US_MAH_Country__c = 'US',
                ZTS_US_Active_Product__c = 'Yes'
            )
        ,   true
        );

        ZTS_US_Case_Product__c caseProduct = (ZTS_US_Case_Product__c) SL_TestDataFactory.createSObject
        (   new ZTS_US_Case_Product__c
            (    ZTS_US_Administered_By__c   = 'Other',
                 ZTS_US_Dose__c = 1
            ,    ZTS_US_Dose_Unit__c = 'Bolus'
            ,    ZTS_US_Product_problem_type__c = 'Ecotoxicity'
            ,    ZTS_US_Product_Used_Correctly__c = 'Yes'
            ,    ZTS_US_Case__c = testCase.Id
            ,    ZTS_US_PVW_Product__c = testProduct.Id
            )
        ,   true
        );


        Test.startTest();
        List<String> reasonsForUse = ZTS_CSESplitLOEReasons.getReasonsForUse( caseProduct.Id );
        Test.stopTest();

        System.assertNotEquals( null, reasonsForUse, 'We expect to have retrieved a list of reasons for use.' );
        System.assert( !reasonsForUse.isEmpty(), 'We expect to have retrieved a list of reasons for use, not an empty list.' );
        
        for ( String reasonForUse : reasonsForUse )
        {
            System.assert( String.isNotBlank( reasonForUse ), 'We expect to have non null values for generic reasons for use' );
            System.assert( !REASONS_FOR_USE.contains( reasonForUse ), 'We expect to have returned generic reasons for use from the pvw product record. ' );

        }
    }

}
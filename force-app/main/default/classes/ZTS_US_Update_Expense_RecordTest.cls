/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Update_Expense_RecordTest
* Description   :  Test class for ZTS_US_Update_Expense_Record
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Keshika         Created the Class.

***************************************************************************************************************/
@isTest
public class ZTS_US_Update_Expense_RecordTest{

    static final String EXPENSES_INST_ERROR_ORIGIN = 'ZTS_US_Update_Expense_RecordTest - validate_ZTS_US_Update_Expense_RecordTest(): insert Expenses ';
    
    @isTest
    static void validate_ZTS_US_Update_Expense_RecordTest(){

        Integer counter = 1;
        date d = Date.today();
        List <ZTS_US_Expenses__c > expList = new List <ZTS_US_Expenses__c>();
        
        Test.startTest();
        List<ZTS_Events__c> eveList = ZTS_DataUtilityTest.createEvents(counter);
        eveList[0].ZTS_EU_Market__c = 'United Kingdom';
        eveList[0].ZTS_US_Event_Category__c = 'CPAC';
        insert eveList;
        
        try{
            ZTS_US_Expenses__c  exp = new ZTS_US_Expenses__c(ZTS_US_Events__c=eveList[0].Id,ZTS_US_Expense_Date__c=d,ZTS_US_Type__c='Entertainment',ZTS_US_Event_Category__c='Educational Meeting',ZTS_US_Cost__c = 50,ZTS_US_Unit__c = 1,ZTS_US_Payment_Method__c ='Check');
            expList.add(exp);
            
            insert expList;
        }
        catch(DmlException dex)
		{
			String errorMessages = '';
			for (Integer i = 0; i < dex.getNumDml(); i++) {
				System.debug(EXPENSES_INST_ERROR_ORIGIN);
				System.debug('DML Message: ' + dex.getDmlMessage(i));
				errorMessages += dex.getDmlMessage(i) + '\n';
			}
			errorMessages.removeEnd('\n');
			ZTS_EU_Logger.notify = true;
			ZTS_EU_Logger.error(errorMessages,null, EXPENSES_INST_ERROR_ORIGIN);
            System.assert(false,'No error should occur: '+errorMessages);
        }
        List<EntitySubscription> entitySubsList = [SELECT Id, ParentId FROM EntitySubscription];
        System.assert(!entitySubsList.isEmpty(),'Entity subscriptions should be created');
        System.assertEquals(entitySubsList[0].ParentId, expList[0].Id, 'The expected value of EntitySub parentId should be expense Id inserted'); 
        expList[0].ZTS_US_Cost__c=60;
        update expList;
        delete expList;
        Test.stopTest();
    }
    
  
}
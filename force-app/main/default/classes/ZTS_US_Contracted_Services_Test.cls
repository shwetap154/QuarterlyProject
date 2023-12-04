@IsTest
public class ZTS_US_Contracted_Services_Test {

    
	@testVisible static final String CONTRACTED_SERVICES_INSERT_EXCP_ORIGIN = 'ZTS_US_Contracted_Services_Test - testContractedServices(): insert and update ZTS_US_Contracted_Services__c ';

    @isTest
    static void testContractedServices(){
        
        User usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        Test.starttest();
        
        System.runAs(usr){
            try{
                //create account 
                List<Account> accountRecord = ZTS_DataUtilityTest.createAccountRecord(1,6);
                insert accountRecord;
                                    
                //create opportunity
                Id rtId = null;
                if(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('People_First') != null){
                    rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('People_First').getRecordTypeId();        
                }
                
                Opportunity opp = new Opportunity();
                opp.AccountId = accountRecord[0].Id;
                opp.name = 'PeopleFirst Opportunity Test';    
                date today= date.today();   
                opp.CloseDate= today.addDays(7);
                opp.StageName= 'Prospecting';   
                opp.Type='PeopleFirst';
                opp.RecordTypeid=rtId ;
                opp.Service_Contract__c='PeopleFirst - LCP Enrollment';
                insert opp;  
    
                // Amitabh code for coverage
                ZTS_US_Contracted_Services__c cs = new ZTS_US_Contracted_Services__c();
                cs.ZTS_US_Account_Name__c = accountRecord[0].id;
                cs.ZTS_US_Status__c = 'Active';
                cs.ZTS_US_Opportunity__c=opp.id;
                
                insert cs;
            }
            catch(DmlException dex)
            {
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(CONTRACTED_SERVICES_INSERT_EXCP_ORIGIN);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, CONTRACTED_SERVICES_INSERT_EXCP_ORIGIN);
            }
        }

        System.debug('...Contract CREATED IN TEST....');
         
        Test.stoptest();

        List<Opportunity> opptyList = [SELECT Id, Contracted_Services__c FROM Opportunity];
        List<ZTS_US_Contracted_Services__c> csList = [SELECT Id FROM ZTS_US_Contracted_Services__c];
        System.assertEquals(opptyList[0].Contracted_Services__c, csList[0].Id, 'The expected value of the Contracted_Services__c reference on Oppty should be same as the Contracted_Services__c record inserted');

    }

}
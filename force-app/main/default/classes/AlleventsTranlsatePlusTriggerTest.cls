/****************************************************************************************************************************************** 
* Class Name   : AlleventsTranlsatePlusTriggerTest
* Description  : This is Test class for All Evnts Batch class transaltion and Event Trigger class DEF-001251.     
* Created By   : CloudSense(Sohil Shah) 
* Created Date : 4th June, 2015
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sohil Shah           06/04/2015          Created 
* Allister McKenzie    10/23/2020          Added assertions
*****************************************************************************************************************************************/
@isTest
public class AlleventsTranlsatePlusTriggerTest
{
    @isTest
    static void TestAlleventsTranlsate()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Recordtype recordType = [select Id, Name from Recordtype where Name = 'Activated Account'];
            Account acc = new Account(recordTypeId = recordType.id, Name='Test',Type='Analyst',ZTS_EU_Market__c = 'United States', Practice_Management_Software__c = 'Animana', ZTS_EU_Zip_Postal_Code__c = '12345', BillingPostalCode = '12345', BillingCity = 'Boca Raton', BillingState = 'Florida', BillingStreet = 'Elm Lane');
            insert acc;
            Call__c call = new Call__c(ZTS_EU_Account__c = acc.id,ZTS_EU_Sub_Type__c = 'Account Call',ZTS_EU_Start_Date_Time__c=datetime.newInstance(2014, 9, 15, 12, 30, 0));
            insert call;
            
            List<Event> eveList = new List<event>();
            Set<String> subTypeSet = new Set<String>{
                'Account Call with Speaker', 
                    'Advisory / Diagnostic visit', 
                    'Clinical - Seedings initial',
                    'Demonstration / PPE',
                    'ICP / DMA visit',
                    'Loyalty / VAS visit', 
                    'PBC Call',
                    'Practice Discussion Group'
                    };  
                        
                        for(String s : subTypeSet) {
                            eveList.add(
                                new Event(Sub_Type__c = s, CallRecordId__c = call.id,WhatId = call.id,DurationInMinutes=60,ActivityDateTime=datetime.newInstance(2014, 9, 15, 12, 30, 0))
                            );
                        }
            
            insert eveList;
            String query = 'Select Id, Sub_Type__c,CallRecordId__c from event where CallRecordId__c !=: nullValue and IsChild = False AND ZTS_EU_Market__c = \'United States\'';
            Test.startTest();
            ZTS_EU_Batch_eventsTranslation c = new ZTS_EU_Batch_eventsTranslation(query);        
            Database.executeBatch(c);
            eventUpdate.updatEventOnInsert(eveList);
            Test.stopTest();
            
            Set<String> updatedSubTypes = new Set<String>();
            for(Event ev : [SELECT Id, Sub_Type__c FROM Event]){
                updatedSubTypes.add(ev.Sub_Type__c);
            }
            System.assert( !subTypeSet.equals(updatedSubTypes), 'Subtypes were not translated' );
        }
        
    }   
}
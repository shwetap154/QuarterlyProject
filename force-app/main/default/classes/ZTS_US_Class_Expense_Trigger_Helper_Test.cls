/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Class_Expense_Trigger_Helper_Test 
* Description   :  Test class for ZTS_US_Class_Expense_Trigger_Helper
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.

***************************************************************************************************************/



@isTest
public class ZTS_US_Class_Expense_Trigger_Helper_Test {
    
    public static testMethod void TestprocessExpenseRecord(){
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            //ZTS_DataUtilityTest.activateTriggerSettings();
            ZTS_US_TypeChargeCodeCS__c Charge = new ZTS_US_TypeChargeCodeCS__c
                (
                    ZTS_US_Category__c ='CPAC',
                    ZTS_US_Cost_Center__c ='67102',
                    ZTS_US_Project_Code__c='SAMSUMMIT',
                    ZTS_US_Sub_Account__c ='2999',
                    ZTS_US_Type__c = 'Entertainment',
                    Name = 'CHC25'
                    
                );
            
            insert charge;
            
            Integer counter = 1;
            date d = Date.today();
            List <ZTS_US_Expenses__c > expList= new List <ZTS_US_Expenses__c>();
            Test.startTest();
            List<ZTS_Events__c> eveList=ZTS_DataUtilityTest.createEvents(counter);
            //adding market segmenting not equal to United States
            eveList[0].ZTS_EU_Market__c = 'United Kingdom';
            eveList[0].ZTS_US_Event_Category__c = 'CPAC';
            eveList[0].ZTS_US_Type__c = 'Entertainment';
            eveList[0].ZTS_US_Status__c = 'Pending Approval';
            insert eveList;
            
            ZTS_US_Expenses__c  exp = new ZTS_US_Expenses__c(ZTS_US_Events__c=eveList[0].Id,
                                                             ZTS_US_Expense_Date__c=d,ZTS_US_Type__c='Entertainment',
                                                             ZTS_US_Event_Category__c='CPAC',ZTS_US_Cost__c = 50,
                                                             ZTS_US_Unit__c = 1,ZTS_US_Payment_Method__c ='Check');
            expList.add(exp);
            
            insert expList;
            List<ZTS_US_Expenses__c> updatedExpense = [Select ZTS_US_Expenses_Cost_Center__c, ZTS_US_Expenses_Project_Code__c, ZTS_US_Expenses_Sub_Account__c 
                                                       From ZTS_US_Expenses__c];
            if(updatedExpense.size()>0){
                System.assertEquals('67102', updatedExpense[0].ZTS_US_Expenses_Cost_Center__c, 'Failed to update cost center');
                System.assertEquals('SAMSUMMIT', updatedExpense[0].ZTS_US_Expenses_Project_Code__c, 'Failed to update project code');
                System.assertEquals('2999', updatedExpense[0].ZTS_US_Expenses_Sub_Account__c, 'Failed to update sub account');
            }
            expList[0].ZTS_US_Cost__c=60;
            update expList;
            
            try{
                delete expList;
            }
            
            catch(exception e)
            {
                List<ZTS_US_Expenses__c> expenses = [Select Id From ZTS_US_Expenses__c];
                System.assert(expenses.size() > 0, 'Failed to prevent deletion of expense');
            }

            Test.stopTest();
        }
    }
    
    public static testMethod void updateSpeaker_Test() {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            test.starttest();
            List<Contact> Con = ZTS_DataUtilityTest.createContactRecord(1);
            Con[0].ZTS_US_Speaker_Flag__c = true;
            Con[0].ZTS_EU_Market__c = 'United Kingdom';
            Insert Con;
            ZTS_EU_KOL__c kolSpeaker = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[0].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
            insert kolSpeaker;        
            List<ZTS_Events__c> Eventspeaker =  ZTS_DataUtilityTest.createEvents(1);
            Eventspeaker[0].ZTS_US_End_Date__c = system.today().addDays(20);
            Eventspeaker[0].ZTS_US_Event_Category__c = 'Field Day';
            insert Eventspeaker ;
            ZTS_US_Speaker__c USSpeaker = new  ZTS_US_Speaker__c();
            USSpeaker.ZTS_US_Speaker_Fee__c = 500;
            USSpeaker.ZTS_US_Contact__c=Con[0].id;
            USSpeaker.ZTS_US_Event__c= Eventspeaker[0].id;
            USSpeaker.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
            USSpeaker.ZTS_US_Speaking_Date__c = system.today().addDays(1);
            USSpeaker.ZTS_US_Therapeutic_Area_Experience__c = '1';
            Insert USSpeaker;
            List<ZTS_US_Speaker__c> recSpeaker = new List<ZTS_US_Speaker__c>();
            recSpeaker.add(USSpeaker);
            USZTS_US_Class_Expense_Trigger_Helper.createExpenseRecord(recSpeaker);
            USZTS_US_Class_Expense_Trigger_Helper.updateExpenseRecord(recSpeaker); 
            list<id>Speakerid = new list<id>();
            Speakerid.add(USSpeaker.id);       
            ZTS_US_Class_Expense_Trigger_Helper.deleteSpeakerExpense(Speakerid);
            test.stoptest();
        }
    }    
    
    public static testMethod void createExpenseTest() {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            List<ZTS_Events__c> Eventspeaker =  ZTS_DataUtilityTest.createEvents(1);
            Eventspeaker [0].ZTS_US_Status__c = 'Complete';
            Eventspeaker [0].ZTS_EU_Market__c = 'United Kingdom';
            Eventspeaker [0].ZTS_US_Accomplishment__c  = 'Test Accomplishment';
            Eventspeaker [0].ZTS_US_Start_Date__c = Date.today().addDays(-1);
            Eventspeaker [0].ZTS_US_End_Date__c = Date.today();    
            Eventspeaker [0].ZTS_US_Event_Category__c = 'CPAC';
            insert Eventspeaker ;
            
            List<ZTS_US_Expenses__c> expenseList = new List<ZTS_US_Expenses__c>();
            ZTS_US_Expenses__c exp = new ZTS_US_Expenses__c
                (ZTS_US_Payment_Method__c = 'Check',
                 ZTS_US_Type__c ='Other',
                 ZTS_US_Unit__c = 5,
                 ZTS_US_Cost__c = 12,
                 ZTS_US_Event_Category__c='Educational Meeting',
                 ZTS_US_Events__c = Eventspeaker[0].id,
                 ZTS_US_Payment_Status__c = 'Paid',
                 ZTS_US_Expense_Date__c = System.today()
                );
            expenseList.add(exp);
            test.starttest();
            ZTS_US_Class_Expense_Trigger_Helper.createExpense(expenseList);
            test.stoptest();
        }
        
    }
    
    public static testMethod void updateExpenseRecordTest() {
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            test.starttest();
            List<Contact> Con = ZTS_DataUtilityTest.createContactRecord(1);
            Con[0].ZTS_US_Speaker_Flag__c = true;
            Con[0].ZTS_EU_Market__c = 'United Kingdom';
            Insert Con;
            ZTS_EU_KOL__c kolSpeaker = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[0].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
            insert kolSpeaker;        
            List<ZTS_Events__c> Eventspeaker =  ZTS_DataUtilityTest.createEvents(1);
            Eventspeaker[0].ZTS_US_End_Date__c = system.today().addDays(20);
            Eventspeaker[0].ZTS_US_Event_Category__c ='CPAC';
            insert Eventspeaker ;
            ZTS_US_Speaker__c USSpeaker = new  ZTS_US_Speaker__c();
            USSpeaker.ZTS_US_Speaker_Fee__c = 500;
            USSpeaker.ZTS_US_Contact__c=Con[0].id;
            USSpeaker.ZTS_US_Event__c= Eventspeaker[0].id;
            USSpeaker.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
            USSpeaker.ZTS_US_Speaking_Date__c = system.today().addDays(1);
            USSpeaker.ZTS_US_Therapeutic_Area_Experience__c = '1';
            Insert USSpeaker;
            List<ZTS_US_Speaker__c> recSpeaker = new List<ZTS_US_Speaker__c>();
            recSpeaker.add(USSpeaker);
            ZTS_US_Class_Expense_Trigger_Helper.createExpenseRecord(recSpeaker);
            ZTS_US_Class_Expense_Trigger_Helper.updateExpenseRecord(recSpeaker); 
            test.stoptest();
        }
        
    }
    
}
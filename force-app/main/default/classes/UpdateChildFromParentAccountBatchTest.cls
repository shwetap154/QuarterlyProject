@IsTest
public class UpdateChildFromParentAccountBatchTest { 

    testMethod static void setup(){
        /*Account parentAcc = new Account(Name='Im the parent', parentid=null,ZTS_EU_Account_Status__c='Active',ZTS_US_NARC_Id__c='142252',MZR_Account__c=true,MZR_Status__c='Active',MZR_Enrollment_Start_Date__c=System.today(),
                                       MZR_Enrollment_Date__c=System.today(),ZTS_US_MVP_Account__c=true,ZTS_US_MVP_BIOS__c='On Contract',MZR_BIOS_Enrollment_Date__c=System.today(),
                                       MZR_PARAs_Account__c=true,MZR_PARAs_Tier__c='25,000',MZR_PARAs_Enrollment_Date__c=System.today(),MZR_Account_data_change__c=true,MZR_End_Date__c=System.today(),
                                       MZR_PARAs_Accepted_T_C_Date__c=System.today(),MZR_BIOS_Accepted_T_C_Date__c=System.today(),MZR_Accepted_Declined_Date__c=System.today(),
                                       MZR_Decline_Additional_Notes__c='test',MZR_Enrollment_Experience__c='test',MZR_Reason_for_Not_Enrolling__c='test reason', ZTS_EU_Market__c = 'United States');
        */
        
        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        Account parentAcc = testAccts[0];
        parentAcc.Name='Im the parent';
        parentAcc.parentid=null;
        parentAcc.ZTS_EU_Account_Status__c='Active';
        parentAcc.ZTS_US_NARC_Id__c='142252';
        parentAcc.MZR_Account__c=true;
        parentAcc.MZR_Status__c='Active';
        parentAcc.MZR_Enrollment_Start_Date__c=System.today();
        parentAcc.MZR_Enrollment_Date__c=System.today();
        parentAcc.ZTS_US_MVP_Account__c=true;
        parentAcc.ZTS_US_MVP_BIOS__c='On Contract';
        parentAcc.MZR_BIOS_Enrollment_Date__c=System.today();
        parentAcc.MZR_PARAs_Account__c=true;
        parentAcc.MZR_PARAs_Tier__c='25,000';
        parentAcc.MZR_PARAs_Enrollment_Date__c=System.today();
        parentAcc.MZR_Account_data_change__c=true;
        parentAcc.MZR_End_Date__c=System.today();
        parentAcc.MZR_PARAs_Accepted_T_C_Date__c=System.today();
        parentAcc.MZR_BIOS_Accepted_T_C_Date__c=System.today();
        parentAcc.MZR_Accepted_Declined_Date__c=System.today();
        parentAcc.MZR_Decline_Additional_Notes__c='test';
        parentAcc.MZR_Enrollment_Experience__c='test';
        parentAcc.MZR_Reason_for_Not_Enrolling__c='test reason';
        parentAcc.ZTS_EU_Market__c = 'United States';
        
        insert parentAcc;
        
        /*Account childAcc = new Account(Name='Im the Child', parentid=parentAcc.Id, ZTS_US_NARC_Id__c='55555',MZR_Account__c=false,MZR_Status__c='Declined',MZR_Enrollment_Start_Date__c=System.today()+1,
                                       MZR_Enrollment_Date__c=System.today()+1,ZTS_US_MVP_Account__c=false,ZTS_US_MVP_BIOS__c='On Contract2',MZR_BIOS_Enrollment_Date__c=System.today()+1,
                                       MZR_PARAs_Account__c=false,MZR_PARAs_Tier__c='5,000',MZR_PARAs_Enrollment_Date__c=System.today()+1, ZTS_EU_Market__c = 'United States');
		*/
        
        List<Account> testAccts2 = ZTS_DataUtilityTest.createAccountRecord(1);
        Account childAcc = testAccts2[0];
        childAcc.Name='Im the Child';
        childAcc.parentid=parentAcc.Id;
        childAcc.ZTS_US_NARC_Id__c='55555';
        childAcc.MZR_Account__c=false;
        childAcc.MZR_Status__c='Declined';
        childAcc.MZR_Enrollment_Start_Date__c=System.today()+1;
        childAcc.MZR_Enrollment_Date__c=System.today()+1;
        childAcc.ZTS_US_MVP_Account__c=false;
        childAcc.ZTS_US_MVP_BIOS__c='On Contract2';
        childAcc.MZR_BIOS_Enrollment_Date__c=System.today()+1;
        childAcc.MZR_PARAs_Account__c=false;
        childAcc.MZR_PARAs_Tier__c='5,000';
        childAcc.MZR_PARAs_Enrollment_Date__c=System.today()+1;
        childAcc.ZTS_EU_Market__c = 'United States';
        insert childAcc;
        
    }
    testMethod static void testMZRBiosParaschanges(){
        setup();
        Test.startTest();
        Database.executeBatch(new UpdateChildFromParentAccountBatch());
        Test.stopTest();
        Account parent = [Select Id,ZTS_US_NARC_ID__c,ZTS_US_MVP_Account__c from Account where ZTS_US_NARC_Id__c='142252' AND ZTS_EU_Market__c = 'United States' limit 1];
        Account child = [Select Id,ZTS_US_NARC_ID__c,ZTS_US_MVP_Account__c from Account where ZTS_US_NARC_Id__c='55555' AND ZTS_EU_Market__c = 'United States' limit 1];
        System.debug(parent.ZTS_US_MVP_Account__c + '..........' + child.ZTS_US_MVP_Account__c);
        System.assert(child.ZTS_US_MVP_Account__c == true);
    }
}
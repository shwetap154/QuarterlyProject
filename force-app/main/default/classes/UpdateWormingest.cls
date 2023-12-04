@istest

Public Class UpdateWormingest{

   static testmethod void testmethod1(){
   
      
                String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Animal__c' and Name = 'Horse'].Id;
                Animal__c anm = new Animal__c();
                anm.AnimalChipID__c = 'dsDsdd22qwws';
                anm.RecordTypeId= strRecordTypeId ;
                insert anm;
                
                Worming__c worm = new Worming__c();
                worm.Animal__c = anm.id;
                worm.Date_of_Worming__c = System.today();
                worm.Due_date__c= System.today();
                
                insert worm;
                
                 Test.startTest();

            UpdateWormingRegister obj = new UpdateWormingRegister ();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    

                
                
                }
}
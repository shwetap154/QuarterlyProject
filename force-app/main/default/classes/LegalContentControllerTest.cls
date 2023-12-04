@isTest
public class LegalContentControllerTest {
       
    @IsTest
    static void testLegalContentController() { 
    
       Id p = [select id from profile where name='Distributor Community User'].id;
       
        Account acc = new Account() ;
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Country__c='Albania';
        acc.Applicable_Product_Lines__c='Advocin';
        acc.Applicable_Countries__c = 'TZA';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        insert acc;
        
        ContentVersion contentRecord = new ContentVersion();
        contentRecord.title = 'Test';
        contentRecord.versiondata = EncodingUtil.base64Decode('This is a test attachement');
        contentRecord.PathOnClient = 'Test';
        contentRecord.Library_File_Type__c = 'Legal';
        contentRecord.Applicable_Distributors__c = acc.id;
        contentRecord.Applicable_Markets__c = ' ';
        insert contentRecord;       
        
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id);
        con.ZTS_EU_Market__c = 'ALPHA';
        insert con;  
                  
        User user = new User(alias = 'test123', email='cvtest123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United Kingdom',IsActive =true,
                ContactId = con.Id,Applicable_Countries__c='TZA',
                timezonesidkey='America/Los_Angeles', username='cvbntester@noemail.com', ZTS_EU_Market__c = 'ALPHA');
               
       insert user;
             
       System.runAs(user){
       
         
       Test.startTest();
                            
        LegalContentController legalContentCtrl = new LegalContentController();        
        List<ContentVersion> lstContentVersions = LegalContentController.retrieveContentRecords();
        
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument];
           
        System.assertEquals(0, documents.size(), 'The expected value of lstContentVersions should be empty list');
           
        System.assertNotEquals(1, documents.size(), 'The expected value of lstContentVersions should be same as returned');
        
        //delete documents;
        
        //undelete documents;

        Test.stopTest();
                
        //System.assertNotEquals(0, documents.size(), 'The expected size of documents is at least 1 after undelete');
           
           }
         
    }
    
    @IsTest
    static void getBaseURLTest() {
       
        String returnString = LegalContentController.getBaseURL();
        System.assert(returnString != null, 'Return String is blank');
            
    }
       
   }
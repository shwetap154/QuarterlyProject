@istest
private class googleauthclass_Test{
   
    public static final string CLIENT_SECRET='RAIpAmMXex5vXtZ4bZx5sYRY';//Fill as per your registered app settings in google console
    public static final string CLIENT_ID='196048821117-8ogisjtr345j39o7cf8j0aoj3lis0d2h.apps.googleusercontent.com';//Fill as per your registered app settings in google console
    public static final string REDIRECT_URL='https://pramodreddy-dev-ed--c.ap4.visual.force.com/apex/google';
    public Attachment myfile;
    public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
    public static final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';
    
    public static final string GRANT_TYPE='grant_type=authorization_code';
    public static final string filename='test';
    public static final string filetype='test';
    //public static final string filetype='test';
    public static final string bodyEncoded='test';
    public static final string close_delim='test';
    public static final string delimiter='test';
    //Scope URL as per oauth 2.0 guide of the google 
    //public static final string SCOPE='https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile';
    public static final string SCOPE= 'https://www.googleapis.com/auth/drive.file';
    public static final string STATE='/profile';
    
    //Approval Prompt Constant
    public static final string APPROVAL_PROMPT='force';

    @IsTest
    static void test_getmyfile_UseCase1(){
        PageReference pageRef = Page.google;
        pageRef.getParameters().put('code','test');
        Test.setCurrentPage(pageRef);
        googleauthclass obj01 = new googleauthclass();
        obj01.authtoken = 'test data';
        obj01.refereshtoken = 'test data';
        obj01.bodyprint = 'test data';
        obj01.accessToken = 'test data';
        obj01.myfile = new Attachment();
        obj01.folderid = '01p90000006uk2w';
        
        Attachment myfile;
        Test.startTest();
            myfile = obj01.getmyfile();
        Test.stopTest();

        System.assert(myfile != null);
    }

    @IsTest
    static void test_connect_UseCase1(){
        PageReference pageRef = Page.google;
        pageRef.getParameters().put('code','test');
        Test.setCurrentPage(pageRef);
        googleauthclass obj01 = new googleauthclass();
        obj01.authtoken = 'test data';
        obj01.refereshtoken = 'test data';
        obj01.bodyprint = 'test data';
        obj01.accessToken = 'test data';
        obj01.myfile = new Attachment();
        obj01.folderid = '01p90000006uk2w';
        
        PageReference myPage;
        Test.startTest();
            myPage = obj01.connect();
        Test.stopTest();

        System.assert(myPage != null);
    }

    @IsTest
    static void test_showtoken_UseCase1(){
        PageReference pageRef = Page.google;
        pageRef.getParameters().put('code','test');
        Test.setCurrentPage(pageRef);
        googleauthclass obj01 = new googleauthclass();
        obj01.authtoken = 'test data';
        obj01.refereshtoken = 'test data';
        obj01.bodyprint = 'test data';
        obj01.accessToken = 'test data';
        obj01.myfile = new Attachment();
        obj01.folderid = '01p90000006uk2w';
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new testcalssweb());
            obj01.showtoken();
        Test.stopTest();

        System.assert(obj01.accessToken != null);
    }

    @IsTest
    static void test_save_UseCase1(){
        PageReference pageRef = Page.google;
        pageRef.getParameters().put('code','test');
        Test.setCurrentPage(pageRef);
        googleauthclass obj01 = new googleauthclass();
        obj01.authtoken = 'test data';
        obj01.refereshtoken = 'test data';
        obj01.bodyprint = 'test data';
        obj01.accessToken = 'test data';
        String jsonStr = 'test';
        //Account acct2 = [SELECT Id FROM Account WHERE Name='TestAcct1' AND ZTS_EU_Market__c != 'United States' LIMIT 1];
        /*attachment att = new attachment(); 
           att=[SELECT id,name,body FROM attachment where id='00P6F000021VAlJ'];
       obj01.myfile = att;
        obj01.folderid = '01p90000006uk2w';*/

        Account objAcc = new Account(Name='Test Acc 1', ZTS_EU_Market__c='United Kingdom',
                Practice_Management_Software__c = 'Other',
                Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                ZTS_EU_Zip_Postal_Code__c = '12345',
                BillingPostalCode = '12345',
                BillingCity = 'Boca Raton',
                BillingState = 'Florida',
                BillingStreet = 'Elm Lane');

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert objAcc;
        }


         Blob b = Blob.valueOf('Test Data');
          
        Attachment attachment = new Attachment();
        attachment.ParentId = objAcc.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        insert(attachment);         
        obj01.myfile = attachment;

		Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new testcalssweb2());   
        obj01.save();
        
        Test.stopTest();
        System.assertEquals(UserInfo.getUserId(), obj01.folderid, 'Wrong Folder ID');
    }
}
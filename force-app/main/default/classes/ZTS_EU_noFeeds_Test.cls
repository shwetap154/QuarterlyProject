@isTest (SeeAlldata = False)

public class ZTS_EU_noFeeds_Test{
    
    
    
    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            list<Account> accountList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert accountList;
            List<FeedItem> feedItmList = new List<FeedItem>();
            list<FeedComment> feedcommList = new list<FeedComment>();
            
            
            User userObj = [select id from user where id =: userinfo.getuserId() AND ZTS_EU_Market__c != 'United States'];
            FeedItem fdcomm;
            for(Integer i=0;i<=2;i++){
                fdcomm = new FeedItem();
                fdcomm.Type = 'PollPost';
                fdcomm.ParentId = accountList[0].id;
                fdcomm.body = 'This is test for feedItem';
                feedItmList.add(fdcomm);
            }
            insert feedItmList;
            
            FeedComment feedcomm;
            for(Integer j = 0;j<=2;j++){
                feedcomm = new FeedComment();
                feedcomm.commentBody = 'This is test data for Feed comment';
                feedcomm.FeedItemId = feedItmList[0].id;
                feedcommList.add(feedcomm);
            }
            insert feedcommList;
            
            ZTS_EU_noFeeds.nofeedComments(feedcommList);     
            ZTS_EU_noFeeds.nofeedItems(feedItmList);  
        }    
    }
    
    @isTest static void testFeedItemUpdate() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            list<Account> accountList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert accountList;
            List<FeedItem> feedItmList = new List<FeedItem>();
            list<FeedComment> feedcommList = new list<FeedComment>();
            
            
            User userObj = [select id from user where id =: userinfo.getuserId() AND ZTS_EU_Market__c != 'United States'];
            FeedItem fdcomm;
            for(Integer i=0;i<=2;i++){
                fdcomm = new FeedItem();
                fdcomm.Type = 'PollPost';
                fdcomm.ParentId = accountList[0].id;
                fdcomm.body = 'This is test for feedItem';
                feedItmList.add(fdcomm);
            }
            insert feedItmList;
            
            FeedComment feedcomm;
            for(Integer j = 0;j<=2;j++){
                feedcomm = new FeedComment();
                feedcomm.commentBody = 'This is test data for Feed comment';
                feedcomm.FeedItemId = feedItmList[0].id;
                feedcommList.add(feedcomm);
            }
            insert feedcommList;
            
            String bodyTitleUpdate = 'Body update';
            feedcommList[0].CommentBody  = bodyTitleUpdate;
            Test.startTest();
            	update feedcommList;
            	update feedItmList;
            Test.stopTest();
            
            List<FeedComment> actualFeedComments = [SELECT CommentBody FROM FeedComment WHERE CommentBody = :bodyTitleUpdate];
            System.assertEquals(1,actualFeedComments.size(),'One feed comment should be updated');
            
        }
    }
    
    @isTest static void testFeedItemDelete() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            list<Account> accountList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert accountList;
            List<FeedItem> feedItmList = new List<FeedItem>();
            list<FeedComment> feedcommList = new list<FeedComment>();
            
            
            User userObj = [select id from user where id =: userinfo.getuserId() AND ZTS_EU_Market__c != 'United States'];
            FeedItem fdcomm;
            for(Integer i=0;i<=2;i++){
                fdcomm = new FeedItem();
                fdcomm.Type = 'PollPost';
                fdcomm.ParentId = accountList[0].id;
                fdcomm.body = 'This is test for feedItem';
                feedItmList.add(fdcomm);
            }
            insert feedItmList;
            
            FeedComment feedcomm;
            for(Integer j = 0;j<=2;j++){
                feedcomm = new FeedComment();
                feedcomm.commentBody = 'This is test data for Feed comment';
                feedcomm.FeedItemId = feedItmList[0].id;
                feedcommList.add(feedcomm);
            }
            insert feedcommList;
            
            Test.startTest();
            	delete feedcommList;
            	delete feedItmList;
            Test.stopTest();
            
            System.assertEquals(0,[SELECT count() FROM FeedComment WHERE Id IN :feedcommList],'Feed comments should be deleted');
            System.assertEquals(0,[SELECT count() FROM FeedItem WHERE Id IN :feedItmList],'Feed items should be deleted');
        }
    }
}
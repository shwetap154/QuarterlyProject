/**
* @description       :Created as part of TPDEV-707 inorder to get Attachments from Order Agreements
* @author            : Sai Saranya Siruvuri @ Zoetis Inc
* @group             :
* @Created on  : 09-04-2023
* @last modified by  : 
* Ver   Date         Author                       Modification
* 1.0   10-5-2023    Sweta Kumari              Created a test class of AttachmentsSelector Apex class
* */

@isTest
public class AttachmentsSelectorTest {
    @isTest
    public static void Test1(){
        account acc = new account();
        acc.name = 'test acc';
        insert acc;
        Order testOrder = new Order();
        testOrder.Accountid = acc.id;
        testOrder.EffectiveDate = Date.today();
        testOrder.Status='Submitted';
        insert testOrder;
        echosign_dev1__SIGN_Agreement__c testAgreement = new echosign_dev1__SIGN_Agreement__c();
        testAgreement.Order__c = testOrder.Id;
        insert testAgreement;
        
        Attachment testAttachment = new Attachment(
            ParentId = testAgreement.Id,
            Name = 'TestAttachment - Signed.pdf',
            Body = Blob.valueOf('Test Attachment Content')
        );
        insert testAttachment;
        List<Attachment> resultAttachment = AttachmentsSelector.getAgreementAttachment(testOrder.Id);
        System.assertNotEquals(null, resultAttachment, 'Attachment should not be null');
        System.assertEquals(testAttachment.Id, resultAttachment[0].Id, 'Attachment Ids should be equal');

        
    }
}
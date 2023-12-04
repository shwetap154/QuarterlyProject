/**
 * @description       :Created as part of TPDEV-707 inorder to get Attachments from Order Agreements
 * @author            : Sai Saranya Siruvuri @ Zoetis Inc
 * @group             :
 * @Created on  : 09-04-2023
 * @last modified by  : Kalyan Nayak
 * Ver   Date         Author                       Modification
 * 59    10/26/23     Saranya                     Changed getAgreementAttachment to return List<Attachment> and removed LIMIT 1
 * 
 * */

public class AttachmentsSelector {
    public static List<Attachment> getAgreementAttachment(Id orderId) {
        return [
            SELECT Id, Name, Body
            FROM Attachment
            WHERE ParentId IN (
                SELECT Id
                FROM echosign_dev1__SIGN_Agreement__c
                WHERE Order__c = :orderId
            )
            AND Name LIKE '%- Signed.pdf'
        ];
    }


}
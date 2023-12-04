/**
 * @description       : Interface for EchoSignSignAgreementSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-18-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
**/
public interface IEchoSignSignAgreementSelector extends fflib_ISObjectSelector {
    List<echosign_dev1__SIGN_Agreement__c> selectByOrderIdQuery(List<Id> orderIds);
    void setEnforceSecurity(boolean enforceSecurity);
}
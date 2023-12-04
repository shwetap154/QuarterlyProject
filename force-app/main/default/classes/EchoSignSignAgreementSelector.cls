/**
 * @description       : Main Query Class for Agreement (echosign_dev1__SIGN_Agreement__c)
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-18-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
**/
public inherited sharing class EchoSignSignAgreementSelector extends fflib_SObjectSelector implements IEchoSignSignAgreementSelector {
    private boolean enforceSecurity = true;

    public static IEchoSignSignAgreementSelector newInstance() {
        return (IEchoSignSignAgreementSelector)Application.Selector.newInstance(
            echosign_dev1__SIGN_Agreement__c.SObjectType
        );
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            echosign_dev1__SIGN_Agreement__c.Id
        };
    }

    public Schema.SObjectType getSObjectType() {
        return echosign_dev1__SIGN_Agreement__c.sObjectType;
    }

    public void setEnforceSecurity(boolean enforceSecurity) {
        this.enforceSecurity = enforceSecurity;
    }

    public List<echosign_dev1__SIGN_Agreement__c> selectByOrderIdQuery(List<Id> orderIds) {
        return Database.query(
            newQueryFactory(this.enforceSecurity, this.enforceSecurity, true).
            setCondition('Order__c in: orderIds').
            toSOQL()
        );
    }
  
}
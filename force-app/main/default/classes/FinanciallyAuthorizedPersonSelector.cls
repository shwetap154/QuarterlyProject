/**
 * @description       : Main Query Class for NOA_Financially_Authorized_Person__c
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             :
 * @last modified on  : 07-17-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-17-2023   Padma Nerella @ Zoetis Inc     Add selectByLeadId method
 * 1.1   07-17-2023   Ethan Hirsch @ Zoetis Inc      Update selectByLeadId to Order by Id so both the logic that sends
 *                                                   the PDF and generates the PDF are ordered the same
 * 1.2   08-29-2023   Padma Nerella @ Zoetis Inc     Add Primary__c field to retrieve from Financially Authorized Person TPDEV-1865
 **/
public inherited sharing class FinanciallyAuthorizedPersonSelector {

    /**
     * Retrieve FinanciallyAuthorizedPerson by the LeadIdSet
     * @param LeadIdSet 
     * @return  `List<NOA_Financially_Authorized_Person__c>`
     */
    public static List<NOA_Financially_Authorized_Person__c> selectByLeadId(Set<Id> leadIdSet){
        List<NOA_Financially_Authorized_Person__c> noaFinanciallyAuthPersonList = [Select First_Name__c,Last_Name__c,
                                                                                  Email__c,Phone_Number__c,
                                                                                  Financial_Resp_Other_Zoetis_Accounts__c,
                                                                                  Additional_Responsible_Accounts__c,
                                                                                  Lead__c,Primary__c From NOA_Financially_Authorized_Person__c
                                                                                  where Lead__c=:leadIdSet
                                                                                  ORDER BY Id];
        return noaFinanciallyAuthPersonList;
    }
}
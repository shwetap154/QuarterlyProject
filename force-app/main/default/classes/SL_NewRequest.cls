public with sharing class SL_NewRequest 
{
    public String strURLLocation                    {  get; set;   }
    
    public SL_NewRequest(ApexPages.StandardSetController controller)
    {
        strURLLocation = '';
    }
    public void fetchNewTemplate()
    {
        String strName = '';
        String strUserId = UserInfo.getUserId();
        String strCurrentUserName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        
        Id parentObjectId = apexpages.currentpage().getparameters().get('id');
        
        strName = parentObjectId.getSObjectType().getDescribe().getName() == 'ZTS_EU_Affiliations__c' ? 'AccountContactAffiliation' : parentObjectId.getSObjectType().getDescribe().getName();

        List<RecordType> lstRecordType = new List<RecordType>();
        
        lstRecordType = [SELECT Id FROM RecordType where SObjectType = 'ZTS_EU_Request__c' AND Name =: strName LIMIT 1];
        
        
        if(strName == 'Account')
        {
            Account objAccount = [Select Name From Account Where Id =: parentObjectId AND ZTS_EU_Market__c != 'United States'];
            String strEncodeURL = EncodingUtil.urlEncode(objAccount.Name,'UTF-8');
            strURLLocation = '/a01/e?CF00NF000000CM8An='+strEncodeURL+'&CF00NF000000CM8An_lkid='+objAccount.Id+'&retURL='+objAccount.Id+'&RecordType='+lstRecordType[0].Id+'&CF00NF000000CM8Ar='+strCurrentUserName+'&CF00NF000000CM8Ar_lkid='+strUserId+''; 
        }
        else if(strName == 'Contact')
        {
            Contact objContact = [Select Id, Name From Contact Where Id =: parentObjectId AND ZTS_EU_Market__c != 'United States'];
            String strEncodeURL = EncodingUtil.urlEncode(objContact.Name,'UTF-8');
            strURLLocation = '/a01/e?CF00NF000000CM8Ap='+strEncodeURL+'&CF00NF000000CM8Ap_lkid='+objContact.Id+'&retURL='+objContact.Id+'&RecordType='+lstRecordType[0].Id+'&CF00NF000000CM8Ar='+strCurrentUserName+'&CF00NF000000CM8Ar_lkid='+strUserId+''; 
        }
        else if(strName == 'AccountContactAffiliation')
        {
            ZTS_EU_Affiliations__c objAfiliation = [Select Id, Name From ZTS_EU_Affiliations__c Where Id =: parentObjectId AND ZTS_EU_Market_from_Parent__c != 'United States'];
            String strEncodeURL = EncodingUtil.urlEncode(objAfiliation.Name,'UTF-8');
            strURLLocation = '/a01/e?CF00NF000000CM8Am='+strEncodeURL+'&CF00NF000000CM8Am_lkid='+objAfiliation.Id+'&retURL='+objAfiliation.Id+'&RecordType='+lstRecordType[0].Id+'&CF00NF000000CM8Ar='+strCurrentUserName+'&CF00NF000000CM8Ar_lkid='+strUserId+''; 
            
        }
    }
}
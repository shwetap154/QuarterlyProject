//************************************************************************************* 
// Name: ViewHierarchyUtility 
// Description: Helper class to create Account group hierarchy DEF-000051
// Created By: Sohil Shah (CloudSense)
// Created: September 05 2014 
// 
// ************************Version Updates******************************************** 
// 
// Updated By         Updated Date      Update Comments 
// Sohil Shah       October 21 2014     In order to handle the FLS for logged in USer
// ************************************************************************************ 
public with Sharing class ViewHierarchyController
{
    public final ID accountid;
    public List<ViewHierarchyUtility.AccountNode> accountNodeList{get;set;}

    Public String ParentAccountName {get;set;}
    Public String currentAccountId {get;set;}
    Public boolean code{get;set;}
    Public boolean city{get;set;}
   
    public ViewHierarchyController(Apexpages.StandardController a)
    {
        code = false;
        city =  false;
        System.debug('UserInfo.getProfileID()--------'+UserInfo.getProfileID());
        if((UserInfo.getProfileID().contains('00eF0000000i1nj')) || (UserInfo.getProfileID().contains('00eF0000000i1oD')) || (UserInfo.getProfileID().contains('00eF0000000i1oc')))
        {
            code = true;
            city = true;
        }
        accountid = ApexPages.currentPage().getParameters().get(Label.accountid);
        currentAccountId = accountid;
        searchAllChildAndParentAccount();
        if(accountNodeList.size()>0){
            ParentAccountName = accountNodeList[0].account.Name;
        }
       
        
    
    }
    /*
    This method will search for the child and parent account of the selected Account
    */
    public void searchAllChildAndParentAccount()
    {
        ViewHierarchyUtility zUtil= new ViewHierarchyUtility();
        //ID rootId=getRootId(accountid);  
        accountNodeList= zUtil.getAcxcountHierarchy(accountid);
       
      
    }    
}
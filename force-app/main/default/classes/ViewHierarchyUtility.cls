//************************************************************************************* 
// Name: ViewHierarchyUtility 
// Description: Helper class to create Account group hierarchy 
// Created By: Sohil Shah (CloudSense)
// Created: September 05 2014 
// 
// ************************Version Updates******************************************** 
// 
// Updated By         Updated Date      Update Comments   
// 
// ************************************************************************************ 
public class ViewHierarchyUtility 
{
    private final String strQuery='select ParentId,ID,Name,ZTS_EU_Address_Line_1__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Main_Phone__c,ZTS_EU_Vetsave_HO_ID__c,ZTS_EU_Vetsave_ID__c,ZTS_EU_Market__c,ZTS_EU_VAT_Code__c,ZTS_EU_City__c from Account where ZTS_EU_Market__c != \'United States\' AND ParentId in '; 
    private final Integer SPAN_PADDING=25;
    private  List<AccountNode> accountNodeList= new List<AccountNode>();
    public List<AccountNode> getAcxcountHierarchy(Id currentAccountId)
    {       
    try{
        ID rootId=getRootID(currentAccountId);       
        AccountNode rootAccountNode = new AccountNode([Select ParentId,ID,Name,ZTS_EU_Address_Line_1__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Main_Phone__c,ZTS_EU_Vetsave_HO_ID__c,ZTS_EU_Vetsave_ID__c,ZTS_EU_Market__c,ZTS_EU_VAT_Code__c,ZTS_EU_City__c from Account where Id  =:rootId AND ZTS_EU_Market__c != 'United States' LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
        createChildAccountsNodes(new AccountNode[]{rootAccountNode});
        // Create list of Hierarchy nodes and add root node
        // and its children with one indent level
        //accountNodeList= new List<AccountNode>();
        rootAccountNode.spanPadding = 0;
        accountNodeList.add(rootAccountNode);
        addChildNodes(rootAccountNode,1);
        }catch(Exception e){ 
            System.debug('Error Message' + e.getMessage());
        }
        return accountNodeList;           
    }
    /*
    *This method will add the child nodes to the current parent node
    *
    */
    public void addChildNodes(AccountNode currentNode,Integer indentLevel) 
    {
        Integer spanPadding = 0;
        for (Integer level = 0; level < indentLevel; level++){
            spanPadding += SPAN_PADDING;
        }
        if (currentNode.childAccountsNodes.size() == 0){
            return;
        }        
        /* ASSOCIATED ACCOUNT of given node has children Accounts */
        // Process children nodes of given node
        for (AccountNode node : currentNode.childAccountsNodes) 
        {
            node.spanPadding = spanPadding;
            accountNodeList.add(node);            
            // Add children nodes of current child node with one more indent level
            addChildNodes(node,indentLevel + 1);                            
         }          
    }
    /*
    *This method will fetch the root partent Id
    * Based on the conditions retutn paths are different.
    */
    public  ID getRootID(Id currentAccountId) 
    {
        try
        {
            // Get parent accounts' ids of current account upto fifth level
             Account currentAccount = 
                                [select ParentId, Parent.ParentId, Parent.Parent.ParentId,
                                Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId,
                                Parent.Parent.Parent.Parent.Parent.ParentId 
                                from Account 
                                where id = :currentAccountId 
                                AND ZTS_EU_Market__c != 'United States' 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
        
        // Check parent accounts' ids in desending order of level
        ID rootAccountId = currentAccount.Parent.Parent.Parent.Parent.Parent.ParentId;
        if (rootAccountId != null){
            // If fifth level parent account id exists
            // then check if current account has more upper level of parents
            return getRootId(rootAccountId);
        }        
        rootAccountId = currentAccount.Parent.Parent.Parent.Parent.ParentId;
        if (rootAccountId != null){
            return rootAccountId;
        }       
        rootAccountId = currentAccount.Parent.Parent.Parent.ParentId;
        if (rootAccountId != null){
            return rootAccountId;
        }        
        rootAccountId = currentAccount.Parent.Parent.ParentId;
        if (rootAccountId != null){
            return rootAccountId;
        }       
        rootAccountId = currentAccount.Parent.ParentId;
        if (rootAccountId != null){
            return rootAccountId;
        }        
        rootAccountId = currentAccount.ParentId;
        if (rootAccountId != null){
            return rootAccountId;
        }
      }
      catch(Exception e){
            System.debug('Error Message'+ e.getMessage());
        }  
        // If there is not any parent account
        // then current account is root Account
        return currentAccountId;       
    }
    /*
    *This method will create the node to add child nodes  
    *
    */
    public void createChildAccountsNodes(List<AccountNode> parentNodes)
    {
       try{
        // Set of ids of parent accounts
        Set<ID> parentAccountIds = new Set<ID>();
        // Map from account id to List of children nodes
        Map<ID, List<AccountNode>> childrenAccountsNodesMap =
                new Map<ID, List<AccountNode>>();
        
        for (AccountNode node : parentNodes) 
        {
            parentAccountIds.add(node.account.id);
            childrenAccountsNodesMap.put(node.account.id, node.childAccountsNodes);
        }        
        // Process children accounts
         string queryString=strQuery+ ':parentAccountIds order by Name';
        for (List<Account> childrenAccounts : Database.query(queryString))
         {
            for (Account childrenAccount : childrenAccounts) 
            {
                // Add current account to corresponding List of children nodes
                childrenAccountsNodesMap.get(childrenAccount.ParentId).add(new AccountNode(childrenAccount));
            }
        }        
        // Create lower level of children Accounts' nodes
        for (List<AccountNode> childrenAccountsNodes : childrenAccountsNodesMap.values()) {
            // Recursive call only if there are children accounts
            if (childrenAccountsNodes.size() > 0){
                createChildrenAccountsNodes(childrenAccountsNodes);
            }
        }
       }catch(Exception e){
            System.debug('Error Message:'+e.getmessage());
       }

    }   
    /*
        this method will create children accounts nodes 
    */
     public void createChildrenAccountsNodes(List<AccountNode> parentNodes) {
        // Set of ids of parent accounts
        Set<ID> parentAccountIds = new Set<ID>();
        // Map from account id to List of children nodes
        Map<ID, List<AccountNode>> childrenAccountsNodesMap =
                new Map<ID, List<AccountNode>>();
        
        for (AccountNode node : parentNodes) {
            parentAccountIds.add(node.account.id);
            childrenAccountsNodesMap.put(node.account.id, node.childAccountsNodes);
        }       
        // Process children accounts
        string queryString=strQuery+ ':parentAccountIds order by Name';
         
        for (List<Account> childrenAccounts : Database.query(queryString)) {
            for (Account childrenAccount : childrenAccounts) {
                // Add current account to corresponding List of children nodes
                childrenAccountsNodesMap.get(childrenAccount.ParentId).add(
                        new AccountNode(childrenAccount));
            }
        }
       
        // Create lower level of children Accounts' nodes
        for (List<AccountNode> childrenAccountsNodes : childrenAccountsNodesMap.values()) {
            // Recursive call only if there are children accounts
            if (childrenAccountsNodes.size() > 0){
                createChildrenAccountsNodes(childrenAccountsNodes);
            }
        }
    }   
    public class AccountNode
    {
        PUBLIC ACCOUNT account {get; private set;}        
        public List<AccountNode> childAccountsNodes {get; private set;}
        public Integer spanPadding {public get; public set;}
        public AccountNode(Account account) 
        {
        this.account = account;
            childAccountsNodes = new List<AccountNode>();
        }
    }
}
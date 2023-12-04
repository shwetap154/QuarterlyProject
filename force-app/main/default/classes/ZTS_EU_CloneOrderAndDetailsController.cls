/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_CloneOrderAndDetailsController
* Description   :  This is the controller of the vf page: ZTS_EU_CloneOrderAndDetails.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     24th-Jul-15   Shreyas             Created the class.
********************************************************************************************************************************************/
public class ZTS_EU_CloneOrderAndDetailsController
{
    public string orderId;
    public static boolean cloneFlag;
    public String clonedRecordId        {   get; set;   }
    
    public ZTS_EU_CloneOrderAndDetailsController()
    {
        orderId = ApexPages.currentPage().getParameters().get('orderId');
        cloneFlag = Boolean.valueOf(true); 
    }
    
    /*
        Name: cloneOrderAndOrderDetails
        Purpose: clone the fetched order and order details.
        arguments: none
        return type: none
    */
    public pageReference cloneOrderAndOrderDetails(){
    
        string orderQuery = '';
        string orderAPIName = 'Orders__c'; 
        string orderWhereCondition = 'Id =: orderId';
        orderQuery = getCreatableFieldsSOQL(OrderAPIName, orderWhereCondition);
        
        Orders__c orderToBeCloned = new Orders__c();
        orderToBeCloned = database.query(orderQuery);
        
        Orders__c newOrder = orderToBeCloned.clone(false, true);
        insert newOrder;
        string newOrderId = newOrder.Id;

        
        string orderDetailQuery = '';
        string orderDetailAPIName = 'Order_Detail__c'; 
        string orderDetailWhereCondition = 'ZTS_EU_Order__c =: orderId';
        orderDetailQuery = getCreatableFieldsSOQL(orderDetailAPIName, orderDetailWhereCondition);
        
        List<Order_Detail__c> newOrderDetailList = new List<Order_Detail__c>();
        List<Order_Detail__c> orderDetailsToBeCloned = new List<Order_Detail__c>();
        orderDetailsToBeCloned = database.query(orderDetailQuery);
        
        for(Order_Detail__c od: orderDetailsToBeCloned ){
        
            Order_Detail__c newOrderDetail = new Order_Detail__c();
            newOrderDetail = od.clone(false, true);
            newOrderDetail.ZTS_EU_Order__c = newOrderId;
            newOrderDetailList.add(newOrderDetail);
        }
        insert newOrderDetailList;

        pagereference pg = new pagereference('/' + newOrderId + '/e?retURL=/' + newOrderId);
        
        clonedRecordId = newOrderId;
        return pg;
    }
    
    /*
        Name: getCreatableFieldsSOQL
        Purpose: Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
        arguments: String objectName, String whereClause
        return type: string
    */
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    
    /*
        Name: cloneOrderAndOrderDetails
        Purpose: clone the fetched order and order details.
        arguments: String orderId
        return type: String Clone Order Id
    */
    @auraEnabled
    public static String cloneOrderAndOrderDetails(String orderId)
    {
        string orderQuery = '';
        string orderAPIName = 'Orders__c'; 
        string orderWhereCondition = 'Id =: orderId';
        orderQuery = getCreatableFieldsSOQL(OrderAPIName, orderWhereCondition);
        
        Orders__c orderToBeCloned = new Orders__c();
        orderToBeCloned = database.query(orderQuery);
        
        Orders__c newOrder = orderToBeCloned.clone(false, true);
        insert newOrder;
        string newOrderId = newOrder.Id;

        
        string orderDetailQuery = '';
        string orderDetailAPIName = 'Order_Detail__c'; 
        string orderDetailWhereCondition = 'ZTS_EU_Order__c =: orderId';
        orderDetailQuery = getCreatableFieldsSOQL(orderDetailAPIName, orderDetailWhereCondition);
        
        List<Order_Detail__c> newOrderDetailList = new List<Order_Detail__c>();
        List<Order_Detail__c> orderDetailsToBeCloned = new List<Order_Detail__c>();
        orderDetailsToBeCloned = database.query(orderDetailQuery);
        
        for(Order_Detail__c od: orderDetailsToBeCloned ){
        
            Order_Detail__c newOrderDetail = new Order_Detail__c();
            newOrderDetail = od.clone(false, true);
            newOrderDetail.ZTS_EU_Order__c = newOrderId;
            newOrderDetailList.add(newOrderDetail);
        }
        insert newOrderDetailList;
        return newOrderId;
    }
}
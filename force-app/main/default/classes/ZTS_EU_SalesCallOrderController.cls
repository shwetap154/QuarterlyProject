/*************************************************************************************
* Description   :    Controller for a New Call component dealing with Orders.
* Author        :    Ilirjana

Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
23/9/2014        Ilirjana          Created(T-14040 Order)
**************************************************************************************/
public with sharing class ZTS_EU_SalesCallOrderController{
    //Ilirjana T-14040 23/09/2014 SalesCallOrder
    public decimal listPrice{get; set;}
    private List<Orders__c> orders{get;set;}
    public boolean addOrderClicked{get; set;}
    public Orders__c newOrder{get;set;}
    public Id selectedOrderId{get;set;}
    
    //Ilirjana T-14040 23/09/2014 SalesCallOrder
    public ZTS_EU_SalesCallOrderController(){
        addOrderClicked = false;
        newOrder = new Orders__c();
    }
    
    //Ilirjana 23/9/2014 Show orders for call T-14040
    public void addOrderRow(){
        this.addOrderClicked = true;   
        system.debug('ordeer entry'+this.addOrderClicked );
   }
   
    //Ilirjana 23/9/2014 Show orders for call T-14040
    public List<Orders__c> getOrders(){
        //list all orders already on this call
        orders = new List<Orders__c>([select id, name, CurrencyIsoCode, Call__c, ZTS_EU_Dealer_Distributor__c,  List_Price__c, 
                                                    ZTS_EU_Fulfillment_Date__c, Product__c, Sales_Price__c, Total__c, Quantity__c
                                             from Orders__c 
                                             where Call__c = :ApexPages.currentPage().getParameters().get('id')
                                               AND ZTS_EU_Market__c != 'United States'
                                             order by ZTS_EU_Fulfillment_Date__c, name]);  
        system.debug('orders=====>' + orders);
        return orders;
   }
    
    //Ilirjana 23/9/2014 Show orders for call T-14040
    public PageReference getListPriceForProduct(){
        List<ZTS_EU_Species_Product__c> listPriceOnProduct = new List<ZTS_EU_Species_Product__c>(
            [select ZTS_EU_Standard_Price__c from ZTS_EU_Species_Product__c where Id = :newOrder.Product__c]);
        system.debug('listPriceOnProduct====' + listPriceOnProduct);
        if (!listPriceOnProduct.isEmpty())
            this.listPrice = listPriceOnProduct[0].ZTS_EU_Standard_Price__c;
        else 
            this.listPrice = Decimal.valueOf(0);
        return null;
    }  
    
    //Ilirjana 23/9/2014 Show orders for call T-14040
    //Luka 17/08/2015 added ZTS_EU_Account__c
    public void addNewOrder(){   
        system.debug('inside add new order===');
        setOrderCurrencyByUser();        
        newOrder.Call__c = ApexPages.currentPage().getParameters().get('id');
        system.debug('newOrder.Call__c' + newOrder.Call__c);
        List<Call__c> call = new List<Call__c>([select ZTS_EU_Account__c from Call__C where id=:newOrder.Call__c AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']);
        newOrder.ZTS_EU_Account__c = call[0].ZTS_EU_Account__c;
         system.debug('  newOrder.ZTS_EU_Account__c' +   newOrder.ZTS_EU_Account__c);
        try{
            upsert newOrder;
            system.debug('newOrder====' + newOrder);
            clearOrder();
        }
        catch(Exception e){
            system.debug('Exception on order: '+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
        }
    }
    
    //Ilirjana 23/9/2014 Show orders for call T-14040
    public void setOrderCurrencyByUser(){
        List<User> currentUser = new List<User>([select CurrencyIsoCode, DefaultCurrencyIsoCode from User where Id = :UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States']);
        if (currentUser[0].CurrencyIsoCode != null)
            newOrder.CurrencyIsoCode = currentUser[0].CurrencyIsoCode;
        else
            newOrder.CurrencyIsoCode = currentUser[0].DefaultCurrencyIsoCode;
    }
    
    //Ilirjana 23/9/2014 Show orders for call T-14040
    public void clearOrder(){
        newOrder = new Orders__c();
        this.listPrice = Decimal.valueOf(0); 
        addOrderClicked = false;
    }
    
    //Ilirjana 23/9/2014 Show orders for call T-14040
    public PageReference removeOrder(){
        if(selectedOrderId!= null){
            Orders__c orderToDelete = new Orders__c(id=selectedOrderId);
            try{ 
                delete orderToDelete;
            }
            catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
        return null;
    }
    
    //Ilirjana 23/9/2014 Show orders for call T-14040
    public PageReference editOrder(){
        if(selectedOrderId!= null){
            clearOrder();
            this.addOrderClicked = true;  
            try{
                List<Orders__c> orderToEdit = new List<Orders__c> ([select id, name, CurrencyIsoCode, Call__c, ZTS_EU_Dealer_Distributor__c,  List_Price__c, 
                                                                       ZTS_EU_Fulfillment_Date__c, Product__c, Sales_Price__c, Total__c, Quantity__c
                                                                from Orders__c 
                                                                where Id = :selectedOrderId
                                                                  AND ZTS_EU_Market__c != 'United States'
                                                                limit 1]);
                newOrder = orderToEdit[0];
                getListPriceForProduct();
            }
            catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getMessage()));
            }
        }
        return null;
    }
}
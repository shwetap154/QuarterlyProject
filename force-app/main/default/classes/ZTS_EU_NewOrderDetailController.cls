/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_NewOrderDetailController
* Description   :  This is the controller of the vf page: ZTS_EU_NewOrderDetail

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     13th-Apr-15   Shreyas             Created the class.

********************************************************************************************************************************************/

public class ZTS_EU_NewOrderDetailController {

    public string orderId;
    
    public string market;
    public List<ZTS_EU_Species_Product__c> skuList = new List<ZTS_EU_Species_Product__c>();
    public List<skuWrapper> skuWrapperList {get; set;}
    public string orderName {get; set;}
    public boolean showDiscount {get; set;}
    //Added by Mayukh as Brazil Historical Order System Change
    public boolean showModPrice {get; set;}
    //Added by Abir to implement the Edit functionality
    public string buttonText {get; set;}
    private string edit;
    
    public ZTS_EU_NewOrderDetailController(){
        
        orderId = ApexPages.currentPage().getParameters().get('orderId');
        edit = ApexPages.currentPage().getParameters().get('edit');
        if(edit == '0'){
            buttonText = 'Update Order';
        }else{
            buttonText = 'Add Product';
        }
        
        Orders__c order = new Orders__c();
        order = [Select Id, Name, ZTS_EU_Account__r.ZTS_EU_Market__c, (SELECT Id, Name, ZTS_EU_Order__c, ZTS_EU_Species_Product__c,  ZTS_EU_Species_Product__r.Name,ZTS_EU_Species_Product__r.Id,ZTS_EU_Species_Product__r.ZTS_EU_Unit_Points__c , ZTS_EU_Quantity__c, ZTS_EU_Discount_Price__c,Total_Line_Points__c, ZTS_BR_Modified_Price__c  FROM Order_Details__r) OrderDetails from Orders__c where Id =: orderId AND ZTS_EU_Market__c != 'United States' limit 1];
        if(order != null){
            market = order.ZTS_EU_Account__r.ZTS_EU_Market__c;
            orderName = order.Name;
        }
        
         skuWrapperList = new List<skuWrapper>();
        
        //Loop through Order details for edit operation
        if(edit == '0'){
            ZTS_EU_Species_Product__c objSku;
            for(Order_Detail__c ordDetail : order.Order_Details__r){
                objSku = new ZTS_EU_Species_Product__c();
                objSku.Id = ordDetail.ZTS_EU_Species_Product__r.Id;
                objSku.Name = ordDetail.ZTS_EU_Species_Product__r.Name;
                objSku.ZTS_EU_Unit_Points__c = ordDetail.ZTS_EU_Species_Product__r.ZTS_EU_Unit_Points__c;
                decimal totalPoints = 0;
                if(ordDetail.ZTS_EU_Species_Product__r.ZTS_EU_Unit_Points__c != null){
                    totalPoints =  ordDetail.ZTS_EU_Species_Product__r.ZTS_EU_Unit_Points__c * ordDetail.ZTS_EU_Quantity__c;
                }
                skuWrapperList.add(new skuWrapper(objSku, ordDetail.ZTS_EU_Quantity__c,totalPoints,ordDetail.ZTS_EU_Discount_Price__c, ordDetail.ZTS_BR_Modified_Price__c, ordDetail));
            }
            
            
        
        }else{
            skuList = [Select Id, Name, ZTS_EU_Unit_Points__c from ZTS_EU_Species_Product__c 
                   where ZTS_EU_Market__c =: market AND ZTS_EU_Type__c = 'SKU' 
                   AND ZTS_EU_Is_Active__c = True AND ZTS_EU_Is_Orderable__c = True 
                   order by Name];
            for(ZTS_EU_Species_Product__c sku: skuList){ 
                //string totalPoints = string.valueOf(sku.ZTS_EU_Unit_Points__c);
                skuWrapperList.add(new skuWrapper(sku, '0'));
            }
        }
              
        
        if (Schema.sObjectType.Order_Detail__c.fields.ZTS_EU_Discount_Price__c.isAccessible()){
            showDiscount = true;
        }
        else{
            showDiscount = false;
        }
        
        //Added by Mayukh as Brazil Historical Order System Change
        if (Schema.sObjectType.Order_Detail__c.fields.ZTS_BR_Modified_Price__c.isAccessible()){
            showModPrice = true;
        }
        else{
            showModPrice = false;
        }
    }
    
    /*
    Name: addProduct
    Purpose: to create a order detail record.
    Arguments: null
    Return type: pagereference
    */
    public pagereference addProduct(){
    
        List<Order_Detail__c> newOrderDetailList = new List<Order_Detail__c>();
        for(skuWrapper sku: skuWrapperList){
            
            if(sku.checkBox == true){
				Order_Detail__c detail;
				if(edit == '0'){
					detail = sku.orderDetails;
				}else{
					detail = new Order_Detail__c();
					detail.ZTS_EU_Order__c = orderId;
				}                 
                
                detail.ZTS_EU_Species_Product__c = sku.skuRecord.Id;
                detail.ZTS_EU_Quantity__c = sku.quantity;
                detail.ZTS_EU_Discount_Price__c = sku.discountPrice;
                //Added by Mayukh as Brazil Historical Order System Change
                detail.ZTS_BR_Modified_Price__c = sku.modifiedPrice;
                if(sku.skuRecord.ZTS_EU_Unit_Points__c != null){
                    detail.Total_Line_Points__c = sku.quantity * sku.skuRecord.ZTS_EU_Unit_Points__c;
                }
                newOrderDetailList.add(detail);
            }
        }
        
        string url = '/' + orderId;
        // if(edit == '0'){
            // //update newOrderDetailList;
            // //return new PageReference(url);
			// system.debug('##newOrderDetailList: ' + newOrderDetailList);
			// return null;
        // }
        
        try{
            upsert newOrderDetailList;
        }
        catch(exception e){
            string strErrorMessage = e.getmessage();
            if(strErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                strErrorMessage = strErrorMessage.substring(strErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 35);
            }
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,strErrorMessage);
            ApexPages.addMessage(msg);               
        }
        
		if(edit != '0'){        
			for(skuWrapper sku: skuWrapperList){
				sku.checkBox = false;
			}
			url = '/'+ 'apex/ZTS_EU_NewOrderDetail?orderId=' + orderId;
		}        
       
        pagereference pg = new pagereference(url);
        return pg;
    }
    
    /*
    Name: returnToOrder
    Purpose: to get back to the order record
    Arguments: null
    Return type: pagereference
    */
    public pagereference returnToOrder(){
    
        pagereference pg = new pagereference('/'+ orderId);
        return pg;
    }

    // inner class
    public class skuWrapper{
    
        public boolean checkBox {get; set;}
        public ZTS_EU_Species_Product__c skuRecord {get; set;}
        public decimal quantity {get; set;}
        public string totalPoints {get; set;}
        public decimal discountPrice {get; set;}
        //Added by Mayukh as Brazil Historical Order System Change
        public decimal modifiedPrice {get; set;}
        public Order_Detail__c orderDetails {get; set;}
                
        public skuWrapper(ZTS_EU_Species_Product__c sku, string total) {
            skuRecord = sku; 
            quantity = 0;
            totalPoints = total;
            discountPrice  = 0;
            //Added by Mayukh as Brazil Historical Order System Change
            modifiedPrice = 0;
            checkBox = false;           
        }
        
        public skuWrapper(ZTS_EU_Species_Product__c sku, decimal qty, decimal total, decimal discount, decimal modPrice, Order_Detail__c ord) {
            skuRecord = sku; 
            quantity = qty;
            totalPoints = string.valueOf(total);
            discountPrice  = discount;
            //Added by Mayukh as Brazil Historical Order System Change
            modifiedPrice = modPrice;
            checkBox = true;
            if(ord != null){
                this.orderDetails =  ord;
            }   
        }
    
    }




}
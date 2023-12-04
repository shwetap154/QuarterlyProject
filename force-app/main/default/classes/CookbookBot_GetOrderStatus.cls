public with sharing class CookbookBot_GetOrderStatus {

  public class OrderOutput {
    @InvocableVariable(required=true)
    public String sOrderStatus;
  }

  public class OrderInput {
    @InvocableVariable(required=true)
    public String sOrderNumber;
  }

  @InvocableMethod(label='Get Order Status')
  public static List<OrderOutput> getOrderStatus(List<OrderInput> orderInputs) {
   /* Set<String> orderNumbers = new Set<String>(); 

    // Get the order numbers from the input
    for (OrderInput orderInput : orderInputs) {
      orderNumbers.add(orderInput.sOrderNumber);
    }

    // Get the order objects from the set of order numbers
    List<Account> accts = 
      [SELECT Name FROM Account where Name in :orderNumbers];
      
    // Create a map of order numbers and order status values
    Map<String, String> mapNameStatus = new Map<String, String>(); 
    if (accts.size() > 0) {
        for (Account order : accts) {
          mapNameStatus.put(order.Name, order.Name);
        }
    }*/
    
    // Build a list of order status values for the output
    List<OrderOutput> orderOutputs = new List<OrderOutput>();
    for (OrderInput orderInput : orderInputs) {
      OrderOutput orderOutput = new OrderOutput();
    /*  
      // Do we have a status for this order number?
      if (mapNameStatus.containsKey(orderInput.sOrderNumber)) {
          // If so, then add the status
          orderOutput.sOrderStatus = mapNameStatus.get(orderInput.sOrderNumber);
      } else {
          // If not, then add an unknown status value
          orderOutput.sOrderStatus = 'Order not found';
      }*/
      orderOutputs.add(orderOutput);
    }

      
    return orderOutputs;    
  }
}
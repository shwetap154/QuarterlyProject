/***********
* Class name : GregSalesWrapper
* Description : This is wrapper class which is used to return multiple maps for Gregorian Calendar wise Sales Data.
* Return Type : None.
* Parameters : None.
***********/
public class GregSalesWrapper{
    public Map<String, List<Decimal>> monthValueMapGreg;
    public List<String> monthListYTDGreg;
	public List<String> monthNameListYTDGreg;
	public List<Decimal> oaccntSalesData2total;
    Public List<Decimal> oaccntSalesData2;
    Public List<Decimal> totUnitSales;
    
     public GregSalesWrapper(Map<String, List<Decimal>> monthValueMapGreg,List<String> monthListYTDGreg,List<String> monthNameListYTDGreg,List<Decimal> oaccntSalesData2total){
               this.monthValueMapGreg = monthValueMapGreg;
               this.monthListYTDGreg = monthListYTDGreg;
               this.monthNameListYTDGreg = monthNameListYTDGreg;
               this.oaccntSalesData2total = oaccntSalesData2total;
         	   this.oaccntSalesData2 = oaccntSalesData2total;
         	   this.totUnitSales = oaccntSalesData2total;
            }
     
   
     }
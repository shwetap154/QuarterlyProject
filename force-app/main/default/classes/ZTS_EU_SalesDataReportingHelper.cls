/*************************************************************************************
    * Name          :    ZTS_EU_SalesDataReportingHelper
    * Description   :    Helper Class for ZTS_EU_salesDataReportingController
    * Created By    :    Aritra
    * Created Date  :    01-11-2017 
     
    Modification Log
    ---------------------------------------------------------------------------------------
    Developer           Date             Modification ID        Comments
    ---------------------------------------------------------------------------------------
    Aritra             1-Nov-17                                Created
   
    **************************************************************************************/
public class ZTS_EU_SalesDataReportingHelper {
   
    /*********
        * Method Name   : getGregorianYTDTotalSalesData
        * Description   : This method used to return Gregorian month wise Sales Figures for Total Sales
        * Return Type   : GregSalesWrapper object
        * Parameters    : monthNameMap, monthValueMap
        * Author        : Aritra
    *********/
    public static GregSalesWrapper getGregorianYTDTotalSalesData(Map<String,String> monthNameMap,Map<String, List<Decimal>> monthValueMap)
    {
        List<Decimal> oaccntSalesData2total = new List<Decimal>();
        GregSalesWrapper oGregSalesWrapper;
        List<String> monthNameListYTDGreg = new List<String>();
        List<String> monthListYTDGreg = new List<String>();
        Map<String, List<Decimal>> monthValueMapGreg = new Map<String, List<Decimal>>();
        Decimal CYTDSales =0;
        Decimal PYTDSales =0;
        Decimal DiffSales =0;
        Decimal PDiffSales =0;
        Integer maxmonth =0;
        Decimal CYTDVal;
        Decimal PYTDVal;
        for(String s: monthValueMap.keyset())
        {
             if(s!=null && s!= 'AP-1')
             {
                 if(s.contains('-')){
                    String[] maxap = s.split('-');
               		Integer tmp = Integer.valueOf(maxap[1]);
                    if(tmp>maxmonth){maxmonth=tmp;}
                 }
               monthListYTDGreg.add(s);
               monthNameListYTDGreg.add(monthNameMap.get(s));
               monthValueMapGreg.put(s, monthValueMap.get(s));
               List<Decimal> salesValues = monthValueMap.get(s);
                if(salesValues.size()>0)
                {
                 CYTDVal = salesValues[0];
                 PYTDVal = salesValues[1];
                 if(CYTDVal!=null){CYTDSales = CYTDSales + CYTDVal;}
                 if(PYTDVal!=null){PYTDSales = PYTDSales + PYTDVal;}
                }
              }
       }
       DiffSales = CYTDSales - PYTDSales;
       if(PYTDSales!=0){PDiffSales = (DiffSales/PYTDSales)*100;}
       if(PDiffSales!=0){PDiffSales = PDiffSales.round();}
       oaccntSalesData2total.add(CYTDSales);
       oaccntSalesData2total.add(PYTDSales);
       oaccntSalesData2total.add(DiffSales);
       oaccntSalesData2total.add(PDiffSales);
       for(Integer i=maxmonth+1; i<=12;i++)
       {
           String remainingmonth = 'AP-'+String.valueOf(i);
           monthListYTDGreg.add(remainingmonth);   
           monthNameListYTDGreg.add(monthNameMap.get(remainingmonth));
           monthValueMapGreg.put(remainingmonth,new List<Decimal>());
       }
       monthListYTDGreg.add('AP-1');
       monthNameListYTDGreg.add(monthNameMap.get('AP-1'));
       monthValueMapGreg.put('AP-1',new List<Decimal>());
       oGregSalesWrapper = new GregSalesWrapper(monthValueMapGreg,monthListYTDGreg,monthNameListYTDGreg,oaccntSalesData2total);
       return oGregSalesWrapper;
    }
     
    /*********
        * Method Name   : getGregorianYTDProductSalesData
        * Description   : This method used to return Gregorian month wise Sales Figures for Product Sales
        * Return Type   : GregSalesWrapper object
        * Parameters    : monthNameMap, monthValueMap,Prodindex
        * Author        : Aritra
    *********/ 
    public static GregSalesWrapper getGregorianYTDProductSalesData(Map<String,String> monthNameMap,Map<String, List<Decimal>> monthValueMap,Integer prodindex)
    {
        List<Decimal> oaccntSalesData2 = new List<Decimal>();
        GregSalesWrapper oGregSalesWrapper;
        List<String> monthNameListYTDGreg = new List<String>();
        List<String> monthListYTDGreg = new List<String>();
        Map<String, List<Decimal>> monthValueMapGreg = new Map<String, List<Decimal>>();
        Decimal CYTDSales =0;
        Decimal PYTDSales =0;
        Decimal DiffSales =0;
        Integer maxmonth =0;
        Decimal CYTDVal;
        Decimal PYTDVal;
        Decimal DiffSalesVal;
        for(String s: monthValueMap.keyset())
        {
             if(s!=null && s!= 'AP-1')
             {
               if(s.contains('-')){
                    String[] maxap = s.split('-');
               		Integer tmp = Integer.valueOf(maxap[1]);
                    if(tmp>maxmonth){maxmonth=tmp;}
                 }
               monthListYTDGreg.add(s);
               monthNameListYTDGreg.add(monthNameMap.get(s));
               monthValueMapGreg.put(s, monthValueMap.get(s));
               List<Decimal> salesValues = monthValueMap.get(s);
               //system.debug('In helper class -->>salesValues-->>'+salesValues);
               if(salesValues.size()>0)
                {
                 CYTDVal = salesValues[prodindex];
                 PYTDVal = salesValues[prodindex+1];
                 DiffSalesVal = salesValues[prodindex+2];
                 //system.debug('In helper class -->>AP Name-->>CYTDString,PYTDString-->>'+s+'-->>'+CYTDString+','+PYTDString);
                 if(CYTDVal!=null){CYTDSales = CYTDSales + CYTDVal;}
                 if(PYTDVal!=null){PYTDSales = PYTDSales + PYTDVal;}
                 if(DiffSalesVal!=null){DiffSales = DiffSales + DiffSalesVal;}
                 //system.debug('In helper class -->>AP Name-->>CSales,PSales-->>'+s+'-->>'+CYTDSales+','+PYTDSales);
                }
             }
       }
       
       oaccntSalesData2.add(CYTDSales);
       oaccntSalesData2.add(PYTDSales);
       oaccntSalesData2.add(DiffSales);
       //system.debug('In helper class -->>Unit Sales-->>oaccntSalesData2-->>'+oaccntSalesData2);
       for(Integer i=maxmonth+1; i<=12;i++)
       {
           String remainingmonth = 'AP-'+String.valueOf(i);
           monthListYTDGreg.add(remainingmonth);   
           monthNameListYTDGreg.add(monthNameMap.get(remainingmonth));
           monthValueMapGreg.put(remainingmonth,new List<Decimal>());
       }
       monthListYTDGreg.add('AP-1');
       monthNameListYTDGreg.add(monthNameMap.get('AP-1'));
       monthValueMapGreg.put('AP-1',new List<Decimal>());
       oGregSalesWrapper = new GregSalesWrapper(monthValueMapGreg,monthListYTDGreg,monthNameListYTDGreg,oaccntSalesData2);
       return oGregSalesWrapper;
    }
    
    /*********
        * Method Name   : getGregorianYTDUnitSalesData
        * Description   : This method used to return Gregorian month wise Sales Figures for Unit Sales
        * Return Type   : GregSalesWrapper object
        * Parameters    : monthNameMap, monthValueMap,Prodindex
        * Author        : Aritra
    *********/
    public static GregSalesWrapper getGregorianYTDUnitSalesData(Map<String,String> monthNameMap,Map<String, List<Decimal>> monthValueMap,Integer prodindex)
    {
        List<Decimal> oaccntSalesData2 = new List<Decimal>();
        GregSalesWrapper oGregSalesWrapper;
        List<String> monthNameListYTDGreg = new List<String>();
        List<String> monthListYTDGreg = new List<String>();
        Map<String, List<Decimal>> monthValueMapGreg = new Map<String, List<Decimal>>();
        Integer maxmonth =0;
        Decimal CYTDSales =0;
        Decimal PYTDSales =0;
        Decimal CYTDval;
        Decimal PYTDval;
        for(String s: monthValueMap.keyset())
        {
             if(s!=null && s!= 'AP-1')
             {
               if(s.contains('-')){
                    String[] maxap = s.split('-');
               		Integer tmp = Integer.valueOf(maxap[1]);
                    if(tmp>maxmonth){maxmonth=tmp;}
                 }
               monthListYTDGreg.add(s);
               monthNameListYTDGreg.add(monthNameMap.get(s));
               monthValueMapGreg.put(s, monthValueMap.get(s));
               List<Decimal> salesValues = monthValueMap.get(s);
               if(salesValues.size()>0)
                {
                 CYTDval = salesValues[prodindex];
                 PYTDval = salesValues[prodindex+1];
                 if(CYTDval!=null){CYTDSales = CYTDSales + CYTDval;}
                 if(PYTDval!=null){PYTDSales = PYTDSales + PYTDval;}
                }
             }
       }
       //system.debug('maxmonth->'+maxmonth);
       /*oaccntSalesData2.add(String.valueOf(CYTDSales));
       oaccntSalesData2.add(String.valueOf(PYTDSales));*/
       oaccntSalesData2.add(CYTDSales);
       oaccntSalesData2.add(PYTDSales);
       for(Integer i=maxmonth+1; i<=12;i++)
       {
           String remainingmonth = 'AP-'+String.valueOf(i);
           monthListYTDGreg.add(remainingmonth);   
           monthNameListYTDGreg.add(monthNameMap.get(remainingmonth));
           monthValueMapGreg.put(remainingmonth,new List<Decimal>());
       }
       monthListYTDGreg.add('AP-1');
       monthNameListYTDGreg.add(monthNameMap.get('AP-1'));
       monthValueMapGreg.put('AP-1',new List<Decimal>());
       oGregSalesWrapper = new GregSalesWrapper(monthValueMapGreg,monthListYTDGreg,monthNameListYTDGreg,oaccntSalesData2);
       return oGregSalesWrapper;
    }
    /*********
        * Method Name   : getUnitTotSalesYTDGreg
        * Description   : This method used to return Gregorian month wise All Products Total Sales Figures for Unit Sales tab
        * Return Type   : GregSalesWrapper object
        * Parameters    : monthNameMap, monthValueMap
        * Author        : Aritra
    *********/
    public static GregSalesWrapper getUnitTotSalesYTDGreg(Map<String,String> monthNameMap,Map<String, List<Decimal>> monthValueMap)
    {
        List<Decimal> totUnitSales;
        List<String> monthNameListYTDGreg = new List<String>();
        List<String> monthListYTDGreg = new List<String>();
        Map<String, List<Decimal>> monthValueMapGreg = new Map<String, List<Decimal>>();
        Integer maxmonth =0;
        GregSalesWrapper oGregSalesWrapper;
        Decimal CYTDTotSales =0;
        Decimal PYTDTotSales =0;
        Decimal CYTDVal;
        Decimal PYTDVal;
        for(String s: monthValueMap.keyset())
        {
             if(s!=null && s!= 'AP-1')
             {
               if(s.contains('-')){
                    String[] maxap = s.split('-');
               		Integer tmp = Integer.valueOf(maxap[1]);
                    if(tmp>maxmonth){maxmonth=tmp;}
                 }
               monthListYTDGreg.add(s);
               monthNameListYTDGreg.add(monthNameMap.get(s));
               monthValueMapGreg.put(s, monthValueMap.get(s));
			   List<Decimal> salesValues = monthValueMap.get(s);
               system.debug('In helper class -->>salesValues-->>'+salesValues);
               if(salesValues.size()>0)
                {
                 CYTDVal = salesValues[0];
                 PYTDVal = salesValues[1];
                 //system.debug('In helper class -->>AP Name-->>CYTDString,PYTDString-->>'+s+'-->>'+CYTDString+','+PYTDString);
                 if(CYTDVal!=null){CYTDTotSales = CYTDTotSales + CYTDVal;}
                 if(PYTDVal!=null){PYTDTotSales = PYTDTotSales + PYTDVal;}
                 //system.debug('In helper class -->>AP Name-->>CSales,PSales-->>'+s+'-->>'+CYTDTotSales+','+PYTDTotSales);
                }
             }
       }
       
       totUnitSales = new List<Decimal>{CYTDTotSales,PYTDTotSales};
       for(Integer i=maxmonth+1; i<=12;i++)
       {
           String remainingmonth = 'AP-'+String.valueOf(i);
			monthListYTDGreg.add(remainingmonth);   
            monthNameListYTDGreg.add(monthNameMap.get(remainingmonth));
            monthValueMapGreg.put(remainingmonth,new List<Decimal>());
       }
       system.debug('In helper class -->>Unit Sales-->>totUnitSales-->>'+totUnitSales);
       monthListYTDGreg.add('AP-1');
       monthNameListYTDGreg.add(monthNameMap.get('AP-1'));
       monthValueMapGreg.put('AP-1',new List<Decimal>());
       oGregSalesWrapper = new GregSalesWrapper(monthValueMapGreg,monthListYTDGreg,monthNameListYTDGreg,totUnitSales);
       return oGregSalesWrapper;
    }
     /*********
        * Method Name   : getProdTotSalesYTDGreg
        * Description   : This method used to return Gregorian month wise All Products Total Sales Figures for Product Sales tab
        * Return Type   : GregSalesWrapper object
        * Parameters    : monthNameMap, monthValueMap
        * Author        : Aritra
    *********/
    public static GregSalesWrapper getProdTotSalesYTDGreg(Map<String,String> monthNameMap,Map<String, List<Decimal>> monthValueMap)
    {
        List<Decimal> totUnitSales;
        List<String> monthNameListYTDGreg = new List<String>();
        List<String> monthListYTDGreg = new List<String>();
        Map<String, List<Decimal>> monthValueMapGreg = new Map<String, List<Decimal>>();
        GregSalesWrapper oGregSalesWrapper;
        Decimal CYTDTotSales =0;
        Decimal PYTDTotSales =0;
        Integer maxmonth =0;
        Decimal DiffsalesVal;
        Decimal CYTDVal;
        Decimal PYTDVal;
        for(String s: monthValueMap.keyset())
        {
             if(s!=null && s!= 'AP-1')
             {
               if(s.contains('-')){
                    String[] maxap = s.split('-');
               		Integer tmp = Integer.valueOf(maxap[1]);
                    if(tmp>maxmonth){maxmonth=tmp;}
                 }
               monthListYTDGreg.add(s);
               monthNameListYTDGreg.add(monthNameMap.get(s));
               monthValueMapGreg.put(s, monthValueMap.get(s));
			   List<Decimal> salesValues = monthValueMap.get(s);
               system.debug('In helper class -->>salesValues-->>'+salesValues);
               if(salesValues.size()>0)
                {
                 CYTDVal = salesValues[0];
                 PYTDVal = salesValues[1];
                 
                 if(CYTDVal!=null){CYTDTotSales = CYTDTotSales + CYTDVal;}
                 if(PYTDVal!=null){PYTDTotSales = PYTDTotSales + PYTDVal;}
                 //system.debug('In helper class -->>AP Name-->>CSales,PSales-->>'+s+'-->>'+CYTDTotSales+','+PYTDTotSales);
                }
             }
       }
       DiffsalesVal = CYTDTotSales - PYTDTotSales;
       totUnitSales = new List<Decimal>{CYTDTotSales,PYTDTotSales,DiffsalesVal};
       //system.debug('In helper class -->>Unit Sales-->>totUnitSales-->>'+totUnitSales);
       for(Integer i=maxmonth+1; i<=12;i++)
       {
           String remainingmonth = 'AP-'+String.valueOf(i);
			monthListYTDGreg.add(remainingmonth);   
            monthNameListYTDGreg.add(monthNameMap.get(remainingmonth));
            monthValueMapGreg.put(remainingmonth,new List<Decimal>());
       }
       monthListYTDGreg.add('AP-1');
       monthNameListYTDGreg.add(monthNameMap.get('AP-1'));
       monthValueMapGreg.put('AP-1',new List<Decimal>());
       oGregSalesWrapper = new GregSalesWrapper(monthValueMapGreg,monthListYTDGreg,monthNameListYTDGreg,totUnitSales);
       return oGregSalesWrapper;
    }
}
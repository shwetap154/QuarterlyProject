/*********Developed by Pankaj*********/
//Ilirjana 30/9/2014 Moved class from inner class in ZTS_EU_SalesCallController to new apex class.
public class wrapProdBarrior{
    public ZTS_EU_Product_Adoption_Profile__c pALis {get; set;}
    public string prodBarrier {get; set;}
    public string prodCompetitor{get; set;}
    public string brandIndication{get; set;}
    public integer index{get; set;}
    public List<SelectOption> barriers{get; set;}
    public List<SelectOption> brands{get; set;}
    public List<SelectOption> Comps{get; set;}
    public boolean displaySave {get;set;}

    public wrapProdBarrior(ZTS_EU_Product_Adoption_Profile__c pAList, string prodB, string pCompetitor, string brndInd, integer i, List<Selectoption> lst,List<Selectoption> lstbrands,List<Selectoption> lstComps, boolean showSave){
        system.debug('****pCopetitor*****'+pCompetitor);           
        pALis = PAList;
        prodCompetitor = pCompetitor;
        brandIndication = brndInd;
        index = i;
        prodBarrier = prodB;            
        barriers = lst;
        brands = lstbrands;
        Comps = lstComps;
        displaySave = showSave;
        system.debug('lstbrandssize****'+lstbrands.size()); 
    }
}
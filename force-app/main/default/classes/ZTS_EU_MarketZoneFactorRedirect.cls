public with sharing class ZTS_EU_MarketZoneFactorRedirect {

	public pageReference redirectToPotentialFactorAdjustment(){
		pageReference pf = new pageReference('/apex/ZTS_EU_MarketZoneFactorAdjustment?pageNum=1');
		pf.setRedirect(true);
		return pf;
	}
}
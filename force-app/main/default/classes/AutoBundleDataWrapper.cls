/**
* File Name     :  AutoBundleDataWrapper
* @description  :  Data definition class for the information we want to get from the vistex deal
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     9/10/2019		Cory Bartholomew @ ATG     Created the Class.
* 2.0     2/5/2020		Cory Bartholomew @ ATG     Added descriptions.

**/
public virtual class AutoBundleDataWrapper {
    /**
     * Large offer threshold configuration. It holds the maximum number of lines an offer
     * should have to not be considered a 'large offer'.
     */
    private static Integer largeOfferThresholdConfig;

    /**
     * Gets the Large Offer Threshold configuration from the Custom Settings.
     */
    @TestVisible
    private Integer LargeOfferThreshold {
        get {
            if (largeOfferThresholdConfig == null) {
                CPQBundleUpdates__c autobundlerConfig = CPQBundleUpdates__c.getOrgDefaults();
                largeOfferThresholdConfig = autobundlerConfig.Large_Offer_Threshold__c != null
                    ? (Integer) autobundlerConfig.Large_Offer_Threshold__c
                    : 1000;
            }

            System.debug('AutoBundleDataWrapper > LargeOfferThreshold: ' + largeOfferThresholdConfig);

            return largeOfferThresholdConfig;
        }
    }

    /**
     * @description
     */
    public List<AutoBundleFlexibleGroupLineWrapper> FlexibleGroupLines { get; set; }

    /**
     * @description
     */
    public List<AutoBundleMaterialLineWrapper> MaterialLines { get; set; }

    //Vistex Deal Information
    public Vistex_Deal_Header__c dealHeader { get; set; } //The deal header to create the bundle from
    public List<Vistex_Deal_Line_E1KOMG__c> dealLines { get; set; } //The deal lines brought in from the batch query
    public List<Vistex_Banner_E1EDKT1__c> dealBanners { get; set; } //The Deal Banner and included child banners brought in from query
    public Integer dealTerm { get; set; } //The term from the ZTER Deal Line in this deal
    public String dealNumber { get; set; } //Parsed from VAKEY Field
    public String salesOrganization { get; set; } //Parsed from VAKEY Field
    public String distributionChannel { get; set; } //Parsed from VAKEY Field
    public String eligibilityFilter { get; set; } //Parsed from VAKEY Field
    public Map<String, Vistex_Banner_E1EDKT1__c> bannerMap { get; set; } //Vistex banners grouped by the text type indicator
    public String zprmText { get; set; } //Promo concat from vistex banner and banner children
    public String zterText { get; set; } //Terms and Conditions concat from vistex banner and banner children
    public String zprqText { get; set; } //concat from vistex banner and banner children
    public String zcpqText { get; set; } //concat from vistex banner and banner children
    public String promoSummary {get; set; } //concat and summarize all the banners and banner children added by Sourav Mitra @ CTS - TPDEV-1637

    //product information
    public String bundleName { get; set; } // The text name of this bundle from the vistex deal
    public Product2 bundleParent { get; set; }

    /**
     * Indicates if the offer is considered a large offer on not,
     * based on the amount of Materials and Flexible Group lines.
     */
    public Boolean IsLargeOffer {
        get {
            Integer totalOfferLines = 0;

            List<AutoBundleDealLineWrapper> generidDealLines = new List<AutoBundleDealLineWrapper>();

            if (this.MaterialLines != null) {
                generidDealLines.addAll(MaterialLines);
            }

            if (this.FlexibleGroupLines != null) {
                generidDealLines.addAll(FlexibleGroupLines);
            }

            for (AutoBundleDealLineWrapper genericLine : generidDealLines) {
                totalOfferLines += genericLine.getNumberOfProductOptions();
            }

            System.debug('AutoBundleDataWrapper > IsLargeOffer > totalOfferLines: ' + totalOfferLines);
            return totalOfferLines > largeOfferThreshold;
        }
    }

    public AutoBundleDataWrapper() {
        FlexibleGroupLines = new List<AutoBundleFlexibleGroupLineWrapper>();
        MaterialLines = new List<AutoBundleMaterialLineWrapper>();
    }

    public AutoBundleDataWrapper(Vistex_Deal_Header__c dealHeader) {
        this.dealHeader = dealHeader;
        if (dealHeader.Vistex_Deal_Line__r.size() > 0) {
            this.dealLines = new List<Vistex_Deal_Line_E1KOMG__c>(dealHeader.Vistex_Deal_Line__r);
        }
        if (dealHeader.Vistex_Banner__r.size() > 0) {
            this.dealBanners = new List<Vistex_Banner_E1EDKT1__c>(dealHeader.Vistex_Banner__r);
        }

        FlexibleGroupLines = new List<AutoBundleFlexibleGroupLineWrapper>();
        MaterialLines = new List<AutoBundleMaterialLineWrapper>();
    }

    public void debugDeal() {
        System.debug(this.dealHeader);
        System.debug('Deal header bundle wrapper product');

        if (this.dealHeader.BundleWrapperProducts__r != null && !this.dealHeader.BundleWrapperProducts__r.isEmpty()) {
            System.debug(this.dealHeader.BundleWrapperProducts__r[0]);
        }

        System.Debug('Deal Number: ' + this.dealNumber);
        System.Debug('Sales Organization: ' + this.salesOrganization);
        System.Debug('Distribution Channel: ' + this.distributionChannel);
        System.Debug('Eligibility Filter: ' + this.eligibilityFilter);
        System.Debug('Deal Term: ' + this.dealTerm);
    }

    public void debugFlexibleGroups() {
        System.debug('Flexible Groups: ' + this.FlexibleGroupLines);
    }

    public void debugProducts() {
        System.debug('Material Lines: ' + this.MaterialLines);
    }

    public void debugBannerText() {
        System.debug('ZPRM - Promo Text');
        System.debug(this.zprmText);
        System.debug('ZTER - Terms Text');
        System.debug(this.zterText);
        System.debug('ZPRQ - Text');
        System.debug(this.zprqText);
        System.debug('ZCPQ - Text');
        System.debug(this.zcpqText);
        System.debug('Promo Summary');
        System.debug(this.promoSummary);
    }
}
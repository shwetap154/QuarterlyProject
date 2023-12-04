/**************************************************************************************************
* File Name     :   FeatureOptionsGroupTest 
* Description   :   Represent a group of Deal Lines. A group can be represented by a Feature or a Sub-bundle.
* @author       :   Cesar Sandrigo @ ATG
* Modification Log
===================================================================================================
* Ver.  Date       Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   01/11/19   Cesar Sandrigo      Created the class. Added Support for Feature grouping.
* 1.1   01/24/19   Cesar Sandrigo      Added Support for Sub-bundle grouping.
**************************************************************************************************/
public with sharing class FeatureOptionsGroup {
    /**
     * @description Name of the Group.
     */
    public String Name { get; private set; }

    /**
     * @description Indicates if the feature should be Wrapped in a sub-bundle
     */
    public String Suffix { get; set; }

    /**
     * @description List of Deal Lines that belongs to the group.
     */
    private List<AutoBundleDealLineWrapper> dealLines;

    /**
     * @description List of Deal Lines that belongs to the group.
     */
    private Product2 parentBundleProduct;

    /**
     * @description Indicates if there should be one or more options selected within the group.
     */
    private Boolean selectionMandatory;

    /**
     * @description Number of the group for ordering purposes
     */
    private Integer groupNumber;

    /**
     * @description Holds the names of the group translated. Lang -> Name
     */
    private Map<String, String> translatedNameMap;

    /**
     * Indicates if the offer is considered a large offer on not,
     * based on the amount of Materials and Flexible Group lines.
     */
    private Boolean IsLargeOffer { get; set; }

    /**
     * Constructor
     */
    public FeatureOptionsGroup(String featureName, Integer featureNumber, Product2 parentBundle) {
        this(featureName, featureNumber, parentBundle, false, false);
    }

    /**
     * Constructor
     */
    public FeatureOptionsGroup(String featureName, Integer featureNumber, Product2 parentBundle, Boolean mandatory) {
        this(featureName, featureNumber, parentBundle, mandatory, false);
    }

    /**
     * Constructor
     */
    public FeatureOptionsGroup(String featureName, Integer featureNumber, Product2 parentBundle, Boolean mandatory, Boolean largeOffer) {
        Name = featureName;
        parentBundleProduct = parentBundle;
        groupNumber = featureNumber;
        dealLines = new List<AutoBundleDealLineWrapper>();
        Suffix = null;
        selectionMandatory = mandatory;
        translatedNameMap = new Map<String, String>();
        IsLargeOffer = largeOffer;
    }

    /**
     * Create and returns a new instance of the Product Feature related to this group of offer lines.
     */
    public SBQQ__ProductFeature__c getProductFeature(Id overrideParentId, String parentProductCode) {
        System.debug('FeatureOptionsGroup > getProductFeature: ' + Name + ' - Override parent: ' + (overrideParentId != null));

        return new SBQQ__ProductFeature__c(
            Name = Name,
            SBQQ__ConfiguredSKU__c = overrideParentId != null ? overrideParentId : parentBundleProduct.Id,
            SBQQ__MinOptionCount__c = selectionMandatory ? 1 : 0,
            SBQQ__Number__c = groupNumber,
            Unique_Key__c = parentProductCode + '-' + Name
        );
    }

    public void addTranslatedName(String langCode, String translatedName) {
        translatedNameMap.put(langCode, translatedName);
    }

    public void addTranslatedName(Map<String, String> translatedNames) {
        translatedNameMap.putAll(translatedNames);
    }

    public Map<String, String> getTranslations() {
        return translatedNameMap;
    }

    public Boolean isEmpty() {
        return dealLines.isEmpty();
    }

    public Boolean hasLines() {
        return !dealLines.isEmpty();
    }

    public List<AutoBundleDealLineWrapper> getLines() {
        return dealLines;
    }

    public void addDealLine(AutoBundleDealLineWrapper dealLine) {
        dealLines.add(dealLine);
    }

    public void addDealLines(List<AutoBundleDealLineWrapper> dealLineList) {
        dealLines.addAll(dealLineList);
    }

    /**
     * Create and returns a list of Product Options related to this group of offer lines.
     */
    public List<SBQQ__ProductOption__c> getProductOptions(Product2 nestedBundleParent) {
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();

        for (Integer i = 0; i < dealLines.size(); i++) {
            productOptions.addAll(
                dealLines[i]
                    .getRelatedProductOptions(
                        nestedBundleParent == null ? parentBundleProduct : nestedBundleParent,
                        (groupNumber + i * 10),
                        IsLargeOffer
                    )
            );
        }

        return productOptions;
    }
}
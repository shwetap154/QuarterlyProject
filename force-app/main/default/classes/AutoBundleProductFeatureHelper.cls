/**************************************************************************************************
* File Name     :   AutoBundleProductFeatureHelper 
* Description   :   Class that contains helper methods related to the creation of Product Features inside of the CPQ bundles
*                   for Automatic Bundles.
* @author       :   Cesar Sandrigo @ ATG
* Modification Log
===================================================================================================
* Ver.  Date        Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   11/15/19    Cesar Sandrigo      Created the class.
* 1.1   06/02/20    Cesar Sandrigo      Added support for multi-languages
* 1.2   07/03/20    Ramiro Alvarez      CPQATG-787 - spacing by 1000 flexibleGroupFeatureNumber
* 1.3   08/21/20    Ramiro Alvarez      CPQATG-1008/13 Adding translations
**************************************************************************************************/
public class AutoBundleProductFeatureHelper {
    /**
     * @description
     */
    public static final String NO_SUFFIX = 'Z_NO_SUFFIX'; // Z is because of ordering ;)

    /**
     * @description the product2 record that serves as the bundle parent
     */
    private Product2 ParentProduct { get; set; }

    /**
     * @description Lines relates
     */
    private List<AutoBundleDealLineWrapper> DealLines { get; set; }

    /**
     * @description Holds the relationship between the Deal Line Suffix --> Bundle Name
     */
    public Map<String, String> SuffixWrapperBundleNameMap { get; private set; }

    /**
     * @description Holds the relationship between the Deal Line Suffix --> Bundle Name
     */
    public Map<String, Map<String, String>> SuffixWrapperBundleNameTranslationMap { get; private set; }

    /**
     * Indicates if the offer is considered a large offer on not,
     * based on the amount of Materials and Flexible Group lines.
     */
    private Boolean IsLargeOffer { get; set; }

    /**
     * Constructor
     */
    public AutoBundleProductFeatureHelper(Product2 parentProduct, List<AutoBundleDealLineWrapper> dealLines) {
        this(parentProduct, dealLines, false);
    }

    /**
     * Constructor
     */
    public AutoBundleProductFeatureHelper(Product2 parentProduct, List<AutoBundleDealLineWrapper> dealLines, Boolean largeOffer) {
        this.ParentProduct = parentProduct;
        this.DealLines = dealLines;
        this.SuffixWrapperBundleNameMap = new Map<String, String>();
        this.SuffixWrapperBundleNameTranslationMap = new Map<String, Map<String, String>>();
        this.IsLargeOffer = largeOffer;
    }

    /**
     * @description
     */
    public List<FeatureOptionsGroup> getProductFeatures() {
        Map<String, List<AutoBundleDealLineWrapper>> suffixLineTypeMap = new Map<String, List<AutoBundleDealLineWrapper>>();

        for (AutoBundleDealLineWrapper dealLine : DealLines) {
            String suffix = String.isBlank(dealLine.Suffix) ? NO_SUFFIX : dealLine.Suffix;

            if (!suffixLineTypeMap.containsKey(suffix)) {
                suffixLineTypeMap.put(suffix, new List<AutoBundleDealLineWrapper>());
            }

            suffixLineTypeMap.get(suffix).add(dealLine);
        }

        System.debug('AutoBundleProductFeatureHelper.getProductFeatures - suffixLineTypeMap keys: ' + suffixLineTypeMap.keySet());

        // Result list
        List<FeatureOptionsGroup> featureOptionsGroupList = new List<FeatureOptionsGroup>();

        // Get the list of keys
        List<String> keyList = new List<String>(suffixLineTypeMap.keySet());

        // No explicit grouping
        if (keyList.size() == 1) {
            featureOptionsGroupList.addAll(ProcessNoExplicitGrouping(suffixLineTypeMap.get(keyList[0])));
        } else if (keyList.size() > 1) {
            // Sort the list to get the suffixes sorted
            keyList.sort();

            for (Integer i = 1; i <= keyList.size(); i++) {
                // Get the suffix
                String suffix = keyList[i - 1];

                // Process the explicit grouping
                ExplicitGroupingProcessResult result = ProcessExplicitGrouping(suffixLineTypeMap.get(suffix), i, suffix);

                // Add the groups to the list
                featureOptionsGroupList.addAll(result.Groups);

                // Is this group has to be wrapped in a bundle, add it in the map
                if (result.WrapInBundle) {
                    System.debug('AutoBundleProductFeatureHelper > Suffix [' + suffix + '] to be wrapped in bundle: ' + result.BundleName);
                    SuffixWrapperBundleNameMap.put(suffix, result.BundleName);
                    SuffixWrapperBundleNameTranslationMap.put(suffix, result.BundleNameTranslations);
                }
            }
        }

        return featureOptionsGroupList;
    }

    /**
     * @description for deal lines that have EBONU__c populated gorup them based on matching values
     */
    private ExplicitGroupingProcessResult ProcessExplicitGrouping(
        List<AutoBundleDealLineWrapper> dealLines,
        Integer groupIndex,
        String suffix
    ) {
        System.debug('AutoBundleProductFeatureHelper, Entering ProcessExplicitGrouping...');

        List<AutoBundleDealLineWrapper> deviceLines = new List<AutoBundleDealLineWrapper>();
        List<AutoBundleDealLineWrapper> consumableLines = new List<AutoBundleDealLineWrapper>();
        List<AutoBundleDealLineWrapper> warrantyLines = new List<AutoBundleDealLineWrapper>();
        List<AutoBundleDealLineWrapper> ancillaryLines = new List<AutoBundleDealLineWrapper>();
        List<AutoBundleDealLineWrapper> others = new List<AutoBundleDealLineWrapper>();

        Integer flexibleGroupFeatureNumber = groupIndex * 1000;

        // List to store devices names, for naming the product options
        List<String> deviceNamesList = new List<String>();

        List<FeatureOptionsGroup> featureGroupList = new List<FeatureOptionsGroup>();

        List<FeatureOptionsGroup> flexibleGroupLines = new List<FeatureOptionsGroup>();

        for (AutoBundleDealLineWrapper dealLine : dealLines) {
            // Consumables inside Flexible Group (Aggregate Commitment or Rebate consumables)
            if (dealLine instanceof AutoBundleFlexibleGroupLineWrapper) {
                System.debug('AutoBundleProductFeatureHelper, Consumables inside Flexible Group');

                flexibleGroupFeatureNumber += 10;

                // Cast generic Deal line into a Flexible Group line
                AutoBundleFlexibleGroupLineWrapper flexGroupLine = (AutoBundleFlexibleGroupLineWrapper) dealLine;

                System.debug('AutoBundleProductFeatureHelper, flexGroupLine' + flexGroupLine);

                // Get the product feature for the flexible group
                flexibleGroupLines.addAll(processFlexibleGrop(flexGroupLine, flexibleGroupFeatureNumber, String.valueOf(groupIndex)));

                System.debug('AutoBundleProductFeatureHelper, featureGroupList' + featureGroupList);
            } else {
                System.debug('AutoBundleProductFeatureHelper, material line');

                AutoBundleMaterialLineWrapper materialLine = (AutoBundleMaterialLineWrapper) dealLine;

                switch on materialLine.MaterialTypeGroup {
                    when 'Device' {
                        deviceLines.add(dealLine);
                        deviceNamesList.add(materialLine.ProductName); // For getting the name of the nested bundle product
                    }
                    when 'Consumable' {
                        consumableLines.add(dealLine);
                    }
                    when 'Warranty' {
                        warrantyLines.add(dealLine);
                    }
                    when 'Ancillary' {
                        ancillaryLines.add(dealLine);
                    }
                    when else {
                        others.add(dealLine);
                    }
                }
            }
        }

        String featureName;
        String featureNameFR;
        String featureNameBR;
        String featureNameES;
        String featureNameES_MX;
        String featureNameIT;
        String featureNameDE;
        String featureNameJA;

        // Devices
        if (!deviceLines.isEmpty()) {
            featureName = 'Device Group ' + groupIndex;
            featureNameFR = 'Groupe Instrument ' + groupIndex;
            featureNameBR = 'Grupo de dispositivos ' + groupIndex;
            featureNameES = 'Categoria de equipo ' + groupIndex;
            featureNameES_MX = 'Grupo del Dispositivo ' + groupIndex;
            featureNameIT = 'Strumenti Gruppo ' + groupIndex;
            featureNameDE = 'Gerätegruppe ' + groupIndex;
            featureNameJA = '機器グループ ' + groupIndex;

            // Device with Consumables
            if (!consumableLines.isEmpty()) {
                featureName += ' with Consumables';
                featureNameFR += ' avec consommables';
                featureNameBR += ' com consumíveis';
                featureNameES += ' con consumibles';
                featureNameES_MX += ' con Consumibles';
                featureNameIT += ' con Consumabili';
                featureNameDE += ' mit Verbrauchsmaterial';
                featureNameJA += 'と消耗品';

                // Device with Consumables and Warranties
                if (!warrantyLines.isEmpty()) {
                    featureName += ' and Warranties';
                    featureNameFR += ' et garanties';
                    featureNameBR += ' e garantias';
                    featureNameES += ' y garantía';
                    featureNameES_MX += ' y Garantías';
                    featureNameIT += ' e Garanzia';
                    featureNameDE += ' und Garantie';
                    featureNameJA += 'と保証';
                }
            } else if (!warrantyLines.isEmpty()) {
                // Device with Warranties
                featureName += ' with Warranties';
                featureNameFR += ' avec garanties';
                featureNameBR += ' com garantias';
                featureNameES += ' con garantía';
                featureNameES_MX += ' con garantía';
                featureNameIT += ' con Garanzia';
                featureNameDE += ' mit Garantie';
                featureNameJA += 'と保証';
            } else if (!ancillaryLines.isEmpty()) {
                // Device with Ancillaries
                featureName += ' with Ancillaries';
                featureNameFR += ' avec accessoires';
                featureNameBR += ' com acessórios';
                featureNameES += ' con anexo';
                featureNameES_MX += ' con Auxiliares';
                featureNameIT += ' con Supplementi ausiliari';
                featureNameDE += ' mit Zusatzartikeln';
                featureNameJA += 'と付属品';
            }
        } else if (!consumableLines.isEmpty()) {
            // Consumables
            featureName = 'Consumables';
            featureNameFR += 'Consommables';
            featureNameBR += 'Consumíveis';
            featureNameES += 'Consumibles';
            featureNameES_MX += 'Consumibles';
            featureNameIT += 'Consumabili';
            featureNameDE += 'Verbrauchsmaterial';
            featureNameJA += '消耗品';

            // Consumables and Warranties
            if (!warrantyLines.isEmpty()) {
                featureName += ' and Warranties';
                featureNameFR += ' et garanties';
                featureNameBR += ' e garantias';
                featureNameES += ' y garantía';
                featureNameES_MX += ' y Garantías';
                featureNameIT += ' e Garanzia';
                featureNameDE += ' und Garantie';
                featureNameJA += 'と保証';
            }
        } else if (!warrantyLines.isEmpty()) {
            // Warranties
            featureName = AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES;
            featureNameFR = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
            );
            featureNameBR = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
            );
            featureNameES = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
            );
            featureNameES_MX = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
            );
            featureNameIT = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
            );
            featureNameDE = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
            );
            featureNameJA = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
            );
        } else if (!ancillaryLines.isEmpty()) {
            // Ancillaries
            featureName = AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY;
            featureNameFR = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
            );
            featureNameBR = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
            );
            featureNameES = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
            );
            featureNameES_MX = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
            );
            featureNameIT = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
            );
            featureNameDE = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
            );
            featureNameJA = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
            );
        } else if (!others.isEmpty()) {
            featureName = 'Additional Offerings';
            featureNameFR = 'Offres additionnelles';
            featureNameBR = 'Ofertas Adicionais';
            featureNameES = 'Oferta adicional';
            featureNameES_MX = 'Ofertas Adicionales';
            featureNameIT = 'Offerte addizionali';
            featureNameDE = 'Weitere Angebote';
            featureNameJA = '追加の提案';
        }

        System.debug('AutoBundleProductFeatureHelper > [' + suffix + ']-en: ' + featureName);
        System.debug('AutoBundleProductFeatureHelper > [' + suffix + ']-fr: ' + featureNameFR);
        System.debug('AutoBundleProductFeatureHelper > [' + suffix + ']-br: ' + featureNameBR);
        System.debug('AutoBundleProductFeatureHelper > [' + suffix + ']-es: ' + featureNameES);
        System.debug('AutoBundleProductFeatureHelper > [' + suffix + ']-esMX: ' + featureNameES_MX);
        System.debug('AutoBundleProductFeatureHelper > [' + suffix + ']-IT: ' + featureNameIT);
        System.debug('AutoBundleProductFeatureHelper > [' + suffix + ']-DE: ' + featureNameDE);

        Map<String, String> featureNameTranslated = new Map<String, String>();

        if (
            !deviceLines.isEmpty() ||
            !consumableLines.isEmpty() ||
            !warrantyLines.isEmpty() ||
            !ancillaryLines.isEmpty() ||
            !others.isEmpty()
        ) {
            FeatureOptionsGroup feature = new FeatureOptionsGroup(featureName, groupIndex * 1000, this.ParentProduct);

            feature.addDealLines(deviceLines);
            feature.addDealLines(consumableLines);
            feature.addDealLines(warrantyLines);
            feature.addDealLines(ancillaryLines);
            feature.addDealLines(others);
            feature.addTranslatedName(AutoBundleLocalizationHelper.FR_LANG_CODE, featureNameFR);
            feature.addTranslatedName(AutoBundleLocalizationHelper.PT_BR_LANG_CODE, featureNameBR);
            feature.addTranslatedName(AutoBundleLocalizationHelper.ES_LANG_CODE, featureNameES);
            feature.addTranslatedName(AutoBundleLocalizationHelper.ES_MX_LANG_CODE, featureNameES_MX);
            feature.addTranslatedName(AutoBundleLocalizationHelper.IT_LANG_CODE, featureNameIT);
            feature.addTranslatedName(AutoBundleLocalizationHelper.DE_LANG_CODE, featureNameDE);
            feature.addTranslatedName(AutoBundleLocalizationHelper.JA_LANG_CODE, featureNameJA);

            featureGroupList.add(feature);

            featureNameTranslated = new Map<String, String>{
                AutoBundleLocalizationHelper.EN_LANG_CODE => featureName,
                AutoBundleLocalizationHelper.FR_LANG_CODE => featureNameFR,
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE => featureNameBR,
                AutoBundleLocalizationHelper.ES_LANG_CODE => featureNameES,
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE => featureNameES_MX,
                AutoBundleLocalizationHelper.IT_LANG_CODE => featureNameIT,
                AutoBundleLocalizationHelper.DE_LANG_CODE => featureNameDE,
                AutoBundleLocalizationHelper.JA_LANG_CODE => featureNameJA
            };
        }

        //featureGroupList.add(flexibleGroupList);
        featureGroupList.addAll(flexibleGroupLines);

        // Set the suffix for all the lines in this group
        for (FeatureOptionsGroup featureGroup : featureGroupList) {
            featureGroup.Suffix = suffix;
        }

        /*Map<String, String> featureNameTranslated = new Map<String, String> {
            AutoBundleLocalizationHelper.EN_LANG_CODE => featureName,
            AutoBundleLocalizationHelper.FR_LANG_CODE => featureNameFR,
            AutoBundleLocalizationHelper.PT_BR_LANG_CODE => featureNameBR,
            AutoBundleLocalizationHelper.ES_LANG_CODE => featureNameES,
            AutoBundleLocalizationHelper.ES_MX_LANG_CODE => featureNameES_MX,
            AutoBundleLocalizationHelper.IT_LANG_CODE => featureNameIT,
            AutoBundleLocalizationHelper.DE_LANG_CODE => featureNameDE,
            AutoBundleLocalizationHelper.JA_LANG_CODE => featureNameJA
        };*/

        // Build the result object
        //System.debug('AutoBundleProductFeatureHelper > feature: ' + feature);

        ExplicitGroupingProcessResult result = new ExplicitGroupingProcessResult();
        //result.WrapInBundle = feature.hasLines();
        result.WrapInBundle = true;
        result.BundleName = getBundleName(featureName, deviceNamesList, featureGroupList, String.valueOf(groupIndex));
        result.Groups = featureGroupList;

        //result.BundleNameTranslations = getTranslatedBundleNames(featureNameTranslated, deviceLines);
        result.BundleNameTranslations = getTranslatedBundleNames(
            featureNameTranslated,
            deviceLines,
            featureGroupList,
            String.valueOf(groupIndex)
        );

        System.debug('AutoBundleProductFeatureHelper result.WrapInBundle: ' + result.WrapInBundle);
        System.debug('AutoBundleProductFeatureHelper result: ' + result);
        System.debug('AutoBundleProductFeatureHelper result.BundleNameTranslations: ' + result.BundleNameTranslations);

        return result;
    }

    private String getBundleName(
        String featureName,
        List<String> deviceNameList,
        List<FeatureOptionsGroup> featureGroupList,
        String GroupNumber
    ) {
        if (featureName != null) {
            return featureName + (deviceNameList.isEmpty() ? '' : ' / ' + String.join(deviceNameList, ', '));
        }
        // featureGroupList only contains Flexible Groups
        String deviceGroupName;
        String consumablesGroupName;
        for (FeatureOptionsGroup featureGroup : featureGroupList) {
            if (featureGroup.getLines()[0].LineType == 'ZDEV') {
                deviceGroupName = AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP + ' ' + GroupNumber;
                break;
            }
            if (!String.isNotblank(consumablesGroupName) && featureGroup.getLines()[0].LineType == 'ZCON') {
                consumablesGroupName = AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT + ' ' + GroupNumber;
            }
        }
        return String.isNotBlank(deviceGroupName) ? deviceGroupName : consumablesGroupName;
    }

    /**
     * @description
     */
    private List<FeatureOptionsGroup> ProcessNoExplicitGrouping(List<AutoBundleDealLineWrapper> dealLines) {
        System.debug('AutoBundleProductFeatureHelper, Entering ProcessNoExplicitGrouping...');

        Integer flexibleGroupFeatureNumber = 200;

        List<AutoBundleDealLineWrapper> deviceLines = new List<AutoBundleDealLineWrapper>();
        List<AutoBundleDealLineWrapper> consumableLines = new List<AutoBundleDealLineWrapper>();
        List<AutoBundleDealLineWrapper> warrantyLines = new List<AutoBundleDealLineWrapper>();
        List<AutoBundleDealLineWrapper> ancillaryLines = new List<AutoBundleDealLineWrapper>();
        List<AutoBundleDealLineWrapper> others = new List<AutoBundleDealLineWrapper>();

        List<FeatureOptionsGroup> featureGroupList = new List<FeatureOptionsGroup>();

        for (AutoBundleDealLineWrapper dealLine : dealLines) {
            // Consumables inside Flexible Group (Aggregate Commitment or Rebate consumables)
            if (dealLine instanceof AutoBundleFlexibleGroupLineWrapper) {
                flexibleGroupFeatureNumber += 1000;

                // Cast generic Deal line into a Flexible Group line
                AutoBundleFlexibleGroupLineWrapper flexGroupLine = (AutoBundleFlexibleGroupLineWrapper) dealLine;

                // Get the product feature for the flexible group
                featureGroupList.addAll(processFlexibleGrop(flexGroupLine, flexibleGroupFeatureNumber, ''));
            } else {
                AutoBundleMaterialLineWrapper materialLine = (AutoBundleMaterialLineWrapper) dealLine;

                switch on materialLine.MaterialTypeGroup {
                    when 'Device' {
                        deviceLines.add(dealLine);
                    }
                    when 'Consumable' {
                        consumableLines.add(dealLine);
                    }
                    when 'Warranty' {
                        warrantyLines.add(dealLine);
                    }
                    when 'Ancillary' {
                        ancillaryLines.add(dealLine);
                    }
                    when else {
                        others.add(dealLine);
                    }
                }
            }
        }

        if (!deviceLines.isEmpty()) {
            FeatureOptionsGroup devices = new FeatureOptionsGroup(
                AutoBundleLocalizationHelper.FEATURE_NAME_DEVICES,
                100,
                this.ParentProduct
            );
            devices.addDealLines(deviceLines);

            //French
            devices.addTranslatedName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICES
                )
            );

            //Portuguese - BR
            devices.addTranslatedName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICES
                )
            );

            //Spanish - ES
            devices.addTranslatedName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICES
                )
            );

            //Spanish - MX
            devices.addTranslatedName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICES
                )
            );

            //Italian - IT
            devices.addTranslatedName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICES
                )
            );

            //German - DE
            devices.addTranslatedName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICES
                )
            );

            //Japanese - JA
            devices.addTranslatedName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICES
                )
            );

            featureGroupList.add(devices);
        }

        if (!consumableLines.isEmpty()) {
            FeatureOptionsGroup consumables = new FeatureOptionsGroup(
                AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES,
                1000,
                this.ParentProduct
            );
            consumables.addDealLines(consumableLines);
            consumables.addTranslatedName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES
                )
            );
            consumables.addTranslatedName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES
                )
            );
            consumables.addTranslatedName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES
                )
            );
            consumables.addTranslatedName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES
                )
            );
            consumables.addTranslatedName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES
                )
            );
            consumables.addTranslatedName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES
                )
            );
            consumables.addTranslatedName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES
                )
            );

            featureGroupList.add(consumables);
        }

        if (!warrantyLines.isEmpty()) {
            FeatureOptionsGroup warranties = new FeatureOptionsGroup(
                AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES,
                50000,
                this.ParentProduct
            );
            warranties.addDealLines(warrantyLines);
            warranties.addTranslatedName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
                )
            );
            warranties.addTranslatedName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
                )
            );
            warranties.addTranslatedName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
                )
            );
            warranties.addTranslatedName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
                )
            );
            warranties.addTranslatedName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
                )
            );
            warranties.addTranslatedName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
                )
            );
            warranties.addTranslatedName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_WARRANTIES
                )
            );
            featureGroupList.add(warranties);
        }

        if (!ancillaryLines.isEmpty()) {
            FeatureOptionsGroup ancillaries = new FeatureOptionsGroup(
                AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY,
                60000,
                this.ParentProduct
            );
            ancillaries.addDealLines(ancillaryLines);
            ancillaries.addTranslatedName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
                )
            );
            ancillaries.addTranslatedName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
                )
            );
            ancillaries.addTranslatedName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
                )
            );
            ancillaries.addTranslatedName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
                )
            );
            ancillaries.addTranslatedName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
                )
            );
            ancillaries.addTranslatedName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
                )
            );
            ancillaries.addTranslatedName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ANCILLARY
                )
            );
            featureGroupList.add(ancillaries);
        }

        if (!others.isEmpty()) {
            FeatureOptionsGroup otherOfferings = new FeatureOptionsGroup(
                AutoBundleLocalizationHelper.FEATURE_NAME_ADDITIONAL_OFFERINGS,
                70000,
                this.ParentProduct
            );
            otherOfferings.addDealLines(others);
            otherOfferings.addTranslatedName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDITIONAL_OFFERINGS
                )
            );
            otherOfferings.addTranslatedName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDITIONAL_OFFERINGS
                )
            );
            otherOfferings.addTranslatedName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDITIONAL_OFFERINGS
                )
            );
            otherOfferings.addTranslatedName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDITIONAL_OFFERINGS
                )
            );
            otherOfferings.addTranslatedName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDITIONAL_OFFERINGS
                )
            );
            otherOfferings.addTranslatedName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDITIONAL_OFFERINGS
                )
            );
            otherOfferings.addTranslatedName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_ADDITIONAL_OFFERINGS
                )
            );
            featureGroupList.add(otherOfferings);
        }

        return featureGroupList;
    }

    /**
     * @description
     */
    private List<FeatureOptionsGroup> processFlexibleGrop(
        AutoBundleFlexibleGroupLineWrapper flexGroupLine,
        Integer flexibleGroupFeatureNumber,
        String groupName
    ) {
        List<FeatureOptionsGroup> featureGroupList = new List<FeatureOptionsGroup>();

        String additionalFeatureName = String.isBlank(groupName) ? '' : (' - Group ' + groupName);
        String additionalFeatureNameFr = String.isBlank(groupName) ? '' : (' - Groupe ' + groupName);
        String additionalFeatureNameBr = String.isBlank(groupName) ? '' : (' - Grupo ' + groupName);
        String additionalFeatureNameEs = String.isBlank(groupName) ? '' : (' - Categoría ' + groupName);
        String additionalFeatureNameEsMx = String.isBlank(groupName) ? '' : (' - Grupo ' + groupName);
        String additionalFeatureNameIt = String.isBlank(groupName) ? '' : (' - Gruppo ' + groupName);
        String additionalFeatureNameDe = String.isBlank(groupName) ? '' : (' - Gruppe ' + groupName);
        String additionalFeatureNameJa = String.isBlank(groupName) ? '' : (' - グループ ' + groupName);

        // Rebate consumables
        if (flexGroupLine.LineType == 'ZDEV') {
            System.debug('AutoBundleProductFeatureHelper, flexGroupLine.LineType == ZDEV ' + flexGroupLine);

            FeatureOptionsGroup rebateConsumables = new FeatureOptionsGroup(
                AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP + additionalFeatureName,
                flexibleGroupFeatureNumber,
                this.ParentProduct,
                true
            );
            rebateConsumables.addDealLine(flexGroupLine);
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                ) + additionalFeatureNameFr
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                ) + additionalFeatureNameBr
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                ) + additionalFeatureNameEs
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                ) + additionalFeatureNameEsMx
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                ) + additionalFeatureNameIt
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                ) + additionalFeatureNameDe
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                ) + additionalFeatureNameJa
            );
            featureGroupList.add(rebateConsumables);
        } else if (flexGroupLine.IsRebate) {
            System.debug('AutoBundleProductFeatureHelper, flexGroupLine.IsRebate ' + flexGroupLine);

            FeatureOptionsGroup rebateConsumables = new FeatureOptionsGroup(
                AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE + additionalFeatureName,
                flexibleGroupFeatureNumber,
                this.ParentProduct
            );
            rebateConsumables.addDealLine(flexGroupLine);
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE
                ) + additionalFeatureNameFr
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE
                ) + additionalFeatureNameBr
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE
                ) + additionalFeatureNameEs
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE
                ) + additionalFeatureNameEsMx
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE
                ) + additionalFeatureNameIt
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE
                ) + additionalFeatureNameDe
            );
            rebateConsumables.addTranslatedName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE
                ) + additionalFeatureNameJa
            );
            featureGroupList.add(rebateConsumables);
        } else if (flexGroupLine.IsAggregateCommitment) {
            System.debug('AutoBundleProductFeatureHelper, flexGroupLine.IsAggregateCommitment ' + flexGroupLine);

            FeatureOptionsGroup aggregateCommitment = new FeatureOptionsGroup(
                AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT + additionalFeatureName,
                flexibleGroupFeatureNumber,
                this.ParentProduct,
                false,
                this.IsLargeOffer
            );
            aggregateCommitment.addDealLine(flexGroupLine);
            aggregateCommitment.addTranslatedName(
                AutoBundleLocalizationHelper.FR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.FR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                ) + additionalFeatureNameFr
            );
            aggregateCommitment.addTranslatedName(
                AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.PT_BR_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                ) + additionalFeatureNameBr
            );
            aggregateCommitment.addTranslatedName(
                AutoBundleLocalizationHelper.ES_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                ) + additionalFeatureNameEs
            );
            aggregateCommitment.addTranslatedName(
                AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.ES_MX_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                ) + additionalFeatureNameEsMx
            );
            aggregateCommitment.addTranslatedName(
                AutoBundleLocalizationHelper.IT_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.IT_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                ) + additionalFeatureNameIt
            );
            aggregateCommitment.addTranslatedName(
                AutoBundleLocalizationHelper.DE_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.DE_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                ) + additionalFeatureNameDe
            );
            aggregateCommitment.addTranslatedName(
                AutoBundleLocalizationHelper.JA_LANG_CODE,
                AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                    AutoBundleLocalizationHelper.JA_LANG_CODE,
                    AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                ) + additionalFeatureNameJa
            );
            featureGroupList.add(aggregateCommitment);
        }

        return featureGroupList;
    }

    /**
     * @description Adds the translated device names to the feature name
     */
    private Map<String, String> getTranslatedBundleNames(
        Map<String, String> featureNameTranslated,
        List<AutoBundleDealLineWrapper> deviceLines,
        List<FeatureOptionsGroup> featureGroupList,
        String GroupNumber
    ) {
        Map<String, String> translatedFeatureNameWithDevices = new Map<String, String>();

        if (!featureNameTranslated.isEmpty()) {
            // Get the English bundle name as default
            String defaultFeatureName = featureNameTranslated.get(AutoBundleLocalizationHelper.EN_LANG_CODE);

            for (String langCode : AutoBundleLocalizationHelper.LANG_CODES) {
                // Get the feature name
                String featureName = featureNameTranslated.containsKey(langCode) ? featureNameTranslated.get(langCode) : defaultFeatureName;

                for (AutoBundleDealLineWrapper dealLine : deviceLines) {
                    // Cast to the specific line
                    AutoBundleMaterialLineWrapper deviceLine = (AutoBundleMaterialLineWrapper) dealLine;

                    // Get the Product Name for the active language, if it's not set, use the english product name.
                    String deviceName = deviceLine.TranslatedProductName.containsKey(langCode)
                        ? deviceLine.TranslatedProductName.get(langCode)
                        : deviceLine.ProductName;

                    if (!translatedFeatureNameWithDevices.containsKey(langCode)) {
                        translatedFeatureNameWithDevices.put(langCode, featureName + ' / ' + deviceName);
                    } else {
                        translatedFeatureNameWithDevices.put(langCode, translatedFeatureNameWithDevices.get(langCode) + ', ' + deviceName);
                    }
                }
            }
        } else {
            //Only flexible group
            String translatedFlexibleGroupDevName;
            String translatedConsumablesGroupName;
            for (String langCode : AutoBundleLocalizationHelper.LANG_CODES) {
                for (FeatureOptionsGroup featureGroup : featureGroupList) {
                    if (featureGroup.getLines()[0].LineType == 'ZDEV') {
                        //deviceGroupName = AutoBundleLocalizationHelper. + ' ' + GroupNumber;
                        translatedFlexibleGroupDevName = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                                langCode,
                                AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                            ) != ''
                            ? AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                                  langCode,
                                  AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP
                              ) +
                              ' ' +
                              GroupNumber
                            : AutoBundleLocalizationHelper.FEATURE_NAME_DEVICE_GROUP + ' ' + GroupNumber;
                        break;
                    }
                    if (!String.isNotblank(translatedConsumablesGroupName) && featureGroup.getLines()[0].LineType == 'ZCON') {
                        translatedConsumablesGroupName = AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                                langCode,
                                AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                            ) != ''
                            ? AutoBundleLocalizationHelper.getTranslationForGenericFeatureName(
                                  langCode,
                                  AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT
                              ) +
                              ' ' +
                              GroupNumber
                            : AutoBundleLocalizationHelper.FEATURE_NAME_AGGREGATE_COMMITMENT + ' ' + GroupNumber;
                    }
                }
                if (translatedFlexibleGroupDevName != null) {
                    translatedFeatureNameWithDevices.put(langCode, translatedFlexibleGroupDevName);
                } else {
                    translatedFeatureNameWithDevices.put(langCode, translatedConsumablesGroupName);
                }
            }
        }

        return translatedFeatureNameWithDevices;
    }

    private class ExplicitGroupingProcessResult {
        public Boolean WrapInBundle { get; set; }
        public String BundleName { get; set; }
        public List<FeatureOptionsGroup> Groups { get; set; }
        public Map<String, String> BundleNameTranslations { get; set; }
    }
}
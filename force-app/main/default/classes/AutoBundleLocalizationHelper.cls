/**************************************************************************************************
* File Name     :   AutoBundleLocalizationHelper 
* Description   :   Class that contains helper methods related to the creation of CPQ Localization records
                    related to the records created by AutoBundle process.
* @author       :   Cesar Sandrigo @ ATG
* Modification Log
===================================================================================================
* Ver.  Date       Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   05/21/20   Cesar Sandrigo      Created the class.
* 1.1   08/21/20   Ramiro Alvarez      CPQATG-1008/13 Adding translations
*
**************************************************************************************************/
public class AutoBundleLocalizationHelper {

    public static final Set<String> LANG_CODES = new Set<String> {
        'en_US','fr','da','de','es','fi','it','ja','ko','nl_NL','no','pt_BR','ru','th','zh_TW','zh_CN', 'es_MX'
    };

    public static final String FR_LANG_CODE = 'fr';
    public static final String EN_LANG_CODE = 'en_US';
    public static final String PT_BR_LANG_CODE = 'pt_BR';
    public static final String ES_LANG_CODE = 'es';
    public static final String ES_MX_LANG_CODE = 'es_MX';
    public static final String IT_LANG_CODE = 'it';
    public static final String DE_LANG_CODE = 'de';
    public static final String JA_LANG_CODE = 'ja';        

    // Generic feature names
    public static final String FEATURE_NAME_DEVICES = 'Devices';
    public static final String FEATURE_NAME_DEVICE_GROUP = 'Device Group';
    public static final String FEATURE_NAME_CONSUMABLES = 'Consumables';
    public static final String FEATURE_NAME_ANCILLARY = 'Ancillary';
    public static final String FEATURE_NAME_WARRANTIES = 'Warranties';
    public static final String FEATURE_NAME_ADDITIONAL_OFFERINGS = 'Additional Offerings';
    //public static final String FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS = 'Additional Contract Considerations';
    public static final String FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS = 'Cash Back/Buyout'; //CPQATG-1241
    public static final String FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE = 'Consumables Eligible for Rebate';
    public static final String FEATURE_NAME_AGGREGATE_COMMITMENT = 'Aggregate Commitment';

    /**
     * @description Map that contains the languages and the translations to the original feature names.
     *              This can be later changed by a custom object to support adding translation by the admins
     */
    private static final Map<String, Map<String, String>> FEATURE_NAME_TRANSLATIONS =
        new Map<String, Map<String, String>> {
            // French translations for generic feature names
            FR_LANG_CODE => new Map<String, String> {
                FEATURE_NAME_DEVICES => 'Instruments',
                FEATURE_NAME_DEVICE_GROUP => 'Groupe Instrument', 
                FEATURE_NAME_CONSUMABLES => 'Consommables',
                FEATURE_NAME_ANCILLARY => 'Accessoires',
                FEATURE_NAME_WARRANTIES => 'Garanties',
                FEATURE_NAME_ADDITIONAL_OFFERINGS => 'Offres additionnelles',
                FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS => 'Options Contrat supplémentaires',
                FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE => 'Consommables éligibles pour remise',
                FEATURE_NAME_AGGREGATE_COMMITMENT => 'Engagement total'}
            ,
            PT_BR_LANG_CODE => new Map<String, String> {
                FEATURE_NAME_DEVICES => 'Dispositivos',
                FEATURE_NAME_DEVICE_GROUP => 'Grupo de dispositivos', 
                FEATURE_NAME_CONSUMABLES => 'Consumíveis',
                FEATURE_NAME_ANCILLARY => 'Auxiliar',
                FEATURE_NAME_WARRANTIES => 'Garantias',
                FEATURE_NAME_ADDITIONAL_OFFERINGS => 'Ofertas Adicionais',
                FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS => 'Considerações adicionais do contrato',
                FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE => 'Consumíveis elegíveis para reembolso',
                FEATURE_NAME_AGGREGATE_COMMITMENT => 'Compromisso agregado'
                }
            ,
            ES_LANG_CODE => new Map<String, String> {
                FEATURE_NAME_DEVICES => 'Equipos',
                FEATURE_NAME_DEVICE_GROUP => 'Categoria de equipo', 
                FEATURE_NAME_CONSUMABLES => 'Consumibles',
                FEATURE_NAME_ANCILLARY => 'Anexo',
                FEATURE_NAME_WARRANTIES => 'Garantía',
                FEATURE_NAME_ADDITIONAL_OFFERINGS => 'Oferta adicional',
                FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS => 'Consideraciones adicionales al contrato',
                FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE => 'Consumibles a reembolsar',
                FEATURE_NAME_AGGREGATE_COMMITMENT => 'Agregado al compromiso'
                }
            ,
            ES_MX_LANG_CODE => new Map<String, String> {
                FEATURE_NAME_DEVICES => 'Dispositivos',
                FEATURE_NAME_DEVICE_GROUP => 'Grupo del Dispositivo', 
                FEATURE_NAME_CONSUMABLES => 'Consumibles',
                FEATURE_NAME_ANCILLARY => 'Auxiliar',
                FEATURE_NAME_WARRANTIES => 'Garantías',
                FEATURE_NAME_ADDITIONAL_OFFERINGS => 'Ofertas Adicionales',
                FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS => 'Consideraciones Adicionales del Contrato',
                FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE => 'Consumibles Seleccionables para Reembolso',
                FEATURE_NAME_AGGREGATE_COMMITMENT => 'Compromiso Total'
                }
            ,
            IT_LANG_CODE => new Map<String, String> {
                FEATURE_NAME_DEVICES => 'Strumenti',
                FEATURE_NAME_DEVICE_GROUP => 'Gruppo di strumenti', 
                FEATURE_NAME_CONSUMABLES => 'Consumabili',
                FEATURE_NAME_ANCILLARY => 'Supplemento ausiliario',
                FEATURE_NAME_WARRANTIES => 'Garanzia',
                FEATURE_NAME_ADDITIONAL_OFFERINGS => 'Offerte addizionali',
                FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS => 'Considerazioni Conrtrattuali Aggiuntive',
                FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE => 'Consumabili con sconto posticipato',
                FEATURE_NAME_AGGREGATE_COMMITMENT => 'Impegno d\'acquisto per gruppo di prodotto'
                }
            ,
            DE_LANG_CODE => new Map<String, String> {
                FEATURE_NAME_DEVICES => 'Geräte',
                FEATURE_NAME_DEVICE_GROUP => 'Gerätegruppe', 
                FEATURE_NAME_CONSUMABLES => 'Verbrauchsmaterial',
                FEATURE_NAME_ANCILLARY => 'Zusatzartikel',
                FEATURE_NAME_WARRANTIES => 'Garantie',
                FEATURE_NAME_ADDITIONAL_OFFERINGS => 'Weitere Angebote',
                FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS => 'Weitere Vertragsinformationen',
                FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE => 'Verbrauchsmaterial mit Rabattmöglichkeit',
                FEATURE_NAME_AGGREGATE_COMMITMENT => 'Verpflichtung'
                }
            ,
            JA_LANG_CODE => new Map<String, String> {
                FEATURE_NAME_DEVICES => '機器',
                FEATURE_NAME_DEVICE_GROUP => '機器グループ', 
                FEATURE_NAME_CONSUMABLES => '消耗品',
                FEATURE_NAME_ANCILLARY => '付属品',
                FEATURE_NAME_WARRANTIES => '保証',
                FEATURE_NAME_ADDITIONAL_OFFERINGS => '追加の提案',
                FEATURE_NAME_ADDL_CONTRACT_CONSIDERATIONS => '追加の契約に関する考慮点',
                FEATURE_NAME_CONSUMABLES_ELIGILBLE_FOR_REBATE => 'リベート対象の消耗品',
                FEATURE_NAME_AGGREGATE_COMMITMENT => '決定'
                }
    };
    
        

    /**
     * 
     */
    public static String getTranslationForGenericFeatureName(String langCode, String genericFeatureName) {

        if (!FEATURE_NAME_TRANSLATIONS.containsKey(langCode)) {
            System.debug(LoggingLevel.WARN, 'AutoBundleLocalizationHelper > getTranslationForGenericFeatureName: Language not registered - ' + langCode);
            return '';
        }

        if (!FEATURE_NAME_TRANSLATIONS.get(langCode).containsKey(genericFeatureName)) {
            System.debug(LoggingLevel.WARN, 'AutoBundleLocalizationHelper > getTranslationForGenericFeatureName: No translation found for [' + langCode + '] - ' + genericFeatureName);
            return '';
        }

        return FEATURE_NAME_TRANSLATIONS.get(langCode).get(genericFeatureName);
    }

    private List<ProductFeatureTranslation> translations;

    public AutoBundleLocalizationHelper() {
        translations = new List<ProductFeatureTranslation>();
    }

    public void addTranslations(Product2 product, string translatedName, string languageCode) {
        addTranslations(product, new Map<String, String> { languageCode => translatedName});
    }

    public void addTranslations(SBQQ__ProductFeature__c feature, string translatedName, string languageCode) {
        addTranslations(feature, new Map<String, String> { languageCode => translatedName});
    }

    public void addTranslations(Product2 product, Map<String, String> languageNameMap) {
        ProductFeatureTranslation translation = new ProductFeatureTranslation();
        translation.Product = product;
        translation.LanguageNameMap = languageNameMap;

        translations.add(translation);
    }

    public void addTranslations(SBQQ__ProductFeature__c feature, Map<String, String> languageNameMap) {
        ProductFeatureTranslation translation = new ProductFeatureTranslation();
        translation.Feature = feature;
        translation.LanguageNameMap = languageNameMap;

        translations.add(translation);
    }


    public void commitLocalizations() {

        List<SBQQ__Localization__c> localizationsToInsert = new List<SBQQ__Localization__c>();

        for (ProductFeatureTranslation translation : translations) {
            
            for (String langCode : translation.LanguageNameMap.keySet()) {

                System.debug('AutoBundleLocalizationHelper > Creating localization [' + langCode + '] ' + translation.LanguageNameMap.get(langCode));

                localizationsToInsert.add(
                    new SBQQ__Localization__c(
                            SBQQ__APIName__c = 'Name', //'Name',
                            SBQQ__Label__c = 'Name', //'Feature Name', 
                            SBQQ__Language__c = langCode, // 'fr',
                            SBQQ__ProductFeature__c = translation.Feature != null ? translation.Feature.Id : null,
                            SBQQ__Product__c = translation.Product != null ? translation.Product.Id : null,
                            SBQQ__Text__c = translation.LanguageNameMap.get(langCode),
                            SBQQ__UserDefined__c = false
                        )
                    );
            }
        }

        try {
            System.debug('AutoBundleLocalizationHelper > commitLocalizations: Inserting ' + localizationsToInsert.size());
            insert localizationsToInsert;
        }
        catch(Exception ex) {
            System.debug('AutoBundleLocalizationHelper - Error on creating CPQ Localization objects: ' + ex.getMessage());
            ErrorLogUtil.log('Error on creating CPQ Localization objects.', ex);
        }
    }

    private class ProductFeatureTranslation {
        public  SBQQ__ProductFeature__c Feature { get; set; }
        public Product2 Product { get; set; }
        public Map<String, String> LanguageNameMap { get; set; }
    }
}
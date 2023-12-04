public with sharing class FieldForceSettingsService {
    
    public static final String FIELD_FORCE_DIAGNOSTICS = getMapByDevName().get('DSC').Field_Force_Name__c;
    public static final String FIELD_FORCE_INSIDE_SALES_DIAGNOSTICS = getMapByDevName().get('ISDX').Field_Force_Name__c;
    public static final String FIELD_FORCE_DIAGNOSTICS_TECH = getMapByDevName().get('DTS').Field_Force_Name__c;
    public static final String FIELD_FORCE_DIAGNOSTICS_REGIONAL_TECH = getMapByDevName().get('RDTS').Field_Force_Name__c;

    private static Map<String, FieldForceSetting__mdt> fieldForceSettingsMap;
    
    public static Map<String, FieldForceSetting__mdt> getMapByDevName(){
        if(fieldForceSettingsMap == null){
            fieldForceSettingsMap = new Map<String, FieldForceSetting__mdt>();
            for(FieldForceSetting__mdt setting : FieldForceSettingsSelector.selectAll()){
                fieldForceSettingsMap.put(setting.DeveloperName,setting);
            }
        }
        return fieldForceSettingsMap;
    }
}
public without sharing class FieldForceSettingsSelector {
    public static List<FieldForceSetting__mdt> selectAll(){
        List<FieldForceSetting__mdt> ffSettings = [
            SELECT 
                Id,
                MasterLabel,
                DeveloperName,
                Field_Force_Name__c 
            FROM FieldForceSetting__mdt
        ];

        return ffSettings;
    }
}
/**
* @ClassName    : SL_MetadataFileGeneratorTest 
* @CreatedOn    : 08/25/2020
* @CreatedBy    : Mohamed Seliman
* @ModifiedBy   : 
* @Description  : Test class for SL_MetadataFileGenerator.
*/
@isTest
public class SL_MetadataFileGeneratorTest 
{
    @TestSetup
    static void makeData(){
        Field_Trip__Object_Analysis__c ft = new Field_Trip__Object_Analysis__c(
            Name = 'test ft',
            Field_Trip__Object_Name__c = 'zts_eu_sales_presets__c',
            Field_Trip__Records__c = 0  
        );

        insert ft;

        Field_Trip__Field_Analysis__c fa = new Field_Trip__Field_Analysis__c(
            Name = 'test fa',
            Field_Trip__Object_Analysis__c = ft.Id,
            Field_Trip__Label__c = 'Sales Presets'
        );

        insert fa;
    }
    
    @isTest
    public static void testgenerateMetadataFilesForOrg() 
    {
        List<ContentVersion> preGenerateFiles = new List<ContentVersion>();
        for( ContentVersion file : [SELECT Id, Title from ContentVersion ])
            preGenerateFiles.add(file);
        
        Test.startTest();
       
        SL_MetadataFileGenerator.createFileForType('zts_eu_sales_presets__c');
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('ZTS_EU_Sales_Presets__c').getDescribe().fields.getMap();
        Map<String, String> fieldReferences = SL_MetadataFileGenerator.getFieldReferences(fieldMap);
        
        Test.stopTest();
        
        List<ContentVersion> generateFiles = new List<ContentVersion>();
        for( ContentVersion file : [SELECT Id, Title from ContentVersion ])
            generateFiles.add(file);
        
        system.assertEquals(1, generateFiles.size() - preGenerateFiles.size(), 'Files were not generated properly');
        
    }

}
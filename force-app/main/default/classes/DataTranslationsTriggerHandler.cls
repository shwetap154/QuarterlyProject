/**
* @description       : 
* @author            : Suprabha Acharya @ Zoetis Inc
* @group             : 
* @last modified on  : 02-13-2023 
* @last modified by  : Suprabha Acharya @ Zoetis Inc
* Ver   Date                     Author                      Modification
* 1.0  02-13-2023     Suprabha Acharya @ Zoetis Inc  Added DataTranslationsTriggerHandler method
**/

public With Sharing class DataTranslationsTriggerHandler  extends TriggerHandler {
    /**     * @Description This methode will call service class upon Insertion of a record      
* @Author      Suprabha Acharya @ Zoetis Inc | 02-13-2023 
* @param       DataTranslations record
*/
    public override void beforeInsert() {
        DataTranslationsService.dataTransValidations(trigger.new,null); 
    } 
    
    /**     * @Description This methode will call service class upon Updation of a record      
* @Author     Suprabha Acharya @ Zoetis Inc | 02-13-2023 
* @param       DataTranslations record
*/
    public override void beforeUpdate()
    {
        DataTranslationsService.dataTransValidations(trigger.new,(map<Id,Data_Translation__c>)trigger.oldMap);
    }
    
}
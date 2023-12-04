/**
Trigger Name	: DataTranslations
Description	    : This is a Trigger for the Data_Translation__c object. 
Created By		: Acharya,Suprabha
Created Date	: 02-13-2023
Modification Log:

----------------------------------------------------------------------------
Developer	           Date		   Description
Acharya,Suprabha    02-13-2023    TPDEV-168:Block Creation of Duplicate Data Translations for the same Language/Comp/Skill Combo
----------------------------------------------------------------------------

*/
trigger DataTranslations on Data_Translation__c (before insert,before update) {
    new DataTranslationsTriggerHandler().run();
}
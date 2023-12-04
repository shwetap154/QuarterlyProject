/******************************************************************************************************************************************
* Class Name   : TrackTranscriptVariables
* Description  : This class allows for tracking variables from the pre-chat into the bot layer
* Created By   : Slalom Consulting/Christopher Hale
* Created Date : August 26, 2022
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Christopher Hale                    08/26/2022           Created
*****************************************************************************************************************************************/
public without sharing class TrackTranscriptVariables {
    @AuraEnabled
    public static string updateTranscriptWithContextVariables(String transcriptId, String contextParam){
        LiveChatTranscript lct = new LiveChatTranscript(
            Id = transcriptId,
            ContextParam__c = contextParam
        );

        update lct;

        return 'called apex';
    }
}
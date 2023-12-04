/*
Class Name		: ContentDocumentLinkService
Description	    : Service Class Class as part of TPDEV-554 for the ContentDocumentLink object. 
Created By		: Nayak, Kalyan
Created Date	: 06-22-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
1.0   Nayak, Kalyan			 06-22-2023   	 To Update ShareType to I if the file os linked to Knowledge Article only.
1.1   Sweta Kumari           09-26-2023     file Visibility to all attached documents related to object 

*/
public With Sharing class ContentDocumentLinkService {

    public static void updateContentDocumentShareType(MAP<Id,ContentDocumentLink> newMap){
        List<ContentDocumentLink> listUpdateCDL = new List<ContentDocumentLink>();
        for(ContentDocumentLink cdl : newMap.values()){
            String cdlPrefix = cdl.LinkedEntityId.getsobjecttype().getDescribe().getKeyPrefix();
            if(cdlPrefix == System.Label.Knowledge_Article_PreFix){
                ContentDocumentLink objcdl = new ContentDocumentLink();
                objcdl.id = cdl.Id;
                objcdl.ShareType = 'I';
                listUpdateCDL.add(objcdl);	 
            }
        }
        if(!listUpdateCDL.isEmpty()){
           update listUpdateCDL;
        }
    }

    public static void setVisibleToAllUsersForOrders(List<ContentDocumentLink> newList) {
        for (ContentDocumentLink cdl : newList) {
            if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Order') {
            	cdl.Visibility = 'AllUsers';
            }
        }
    }
}
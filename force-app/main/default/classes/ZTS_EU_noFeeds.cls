/*************************************************************************************************************************
  Class Name     : ZTS_EU_noFeeds
  Description    : This class is called from trigger written to restrict the Feeds on Account and Contact records
  Created By     : Chandra
  Created On     : 05/16/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Deloitte Constulting/Chandra    05/16/2014              Created

***************************************************************************************************************************/
public class ZTS_EU_noFeeds {

    public static void nofeedComments(List <FeedComment> lstfC) {
    
   // User usr = new User();

   //     Set<Id> useIds = new Set<id>(); 
        Set<Id> parentid = new Set<Id>();   
        for(FeedComment fComm : lstfC){
    //    useIds.add(fItem.createdbyId);
        parentid.add(fComm.ParentId);
        
        }
 //   System.debug('>>>>useIds>>>>>'+useIds);
 //      Map<Id,User> mpUsers = new Map<Id,User>([SELECT Id, Country, ZTS_EU_Market__c FROM User WHERE ZTS_EU_Market__c = 'Poland' and Id IN : useIds ]);
       Map<Id,Account> mpAccount = new Map<Id,Account>([SELECT Id, ZTS_EU_Market__c FROM Account WHERE ZTS_EU_Market__c = 'Poland' and Id IN : parentid]);       
       Map<Id,Contact> mpContact = new Map<Id,Contact>([SELECT Id, ZTS_EU_Market__c FROM Contact WHERE ZTS_EU_Market__c = 'Poland' and Id IN : parentid]);       
       for(FeedComment fC : lstfC){
           if(/*mpUsers.containskey(fI.createdByid) || */mpAccount.containskey(fC.parentid) || mpContact.containskey(fC.parentid)){

       fC.addError('No free text comments allowed on this account/contact');
        }
   }
    
    }

    public static void nofeedItems(List <FeedItem> lstfI) {
    
  //  User usr = new User();

   //     Set<Id> useIds = new Set<id>(); 
        Set<Id> parentid = new Set<Id>();   
        for(FeedItem fItem : lstfI){
    //    useIds.add(fItem.createdbyId);
        parentid.add(fItem.ParentId);
        
        }
 //   System.debug('>>>>useIds>>>>>'+useIds);
 //      Map<Id,User> mpUsers = new Map<Id,User>([SELECT Id, Country, ZTS_EU_Market__c FROM User WHERE ZTS_EU_Market__c = 'Poland' and Id IN : useIds ]);
       Map<Id,Account> mpAccount = new Map<Id,Account>([SELECT Id, ZTS_EU_Market__c FROM Account WHERE ZTS_EU_Market__c = 'Poland' and Id IN : parentid]);       
       Map<Id,Contact> mpContact = new Map<Id,Contact>([SELECT Id, ZTS_EU_Market__c FROM Contact WHERE ZTS_EU_Market__c = 'Poland' and Id IN : parentid]);       
       for(FeedItem fI : lstfI){
           if(/*mpUsers.containskey(fI.createdByid) || */mpAccount.containskey(fI.parentid) || mpContact.containskey(fI.parentid)){

       fI.addError('No free text comments allowed on this account/contact');
        }
   }
    
    }

}
/**
* @ClassName    : SL_ZTS_Account_PositionTriggerHandler 
* @JIRATicket   : ZETM-16
* @CreatedOn    : 21st November,2018
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Handler for the trigger ZTS_Account_PositionTrigger on the after insert, update functionality for the object ZTS_EU_Account_Position__c.
*/

public with sharing class SL_ZTS_Account_PositionTriggerHandler 
{
	/***********  
     * Method name  : onBeforeInsertUpdate
     * Description  : create the ZTS_EU_Account_Position__c record with required fields.
     * Return Type  : N.A.
     * Parameters   : trigger parameters
     ***********/
	public void onBeforeInsertUpdate(List<ZTS_EU_Account_Position__c> lstAccountPositionNew, Map<Id, ZTS_EU_Account_Position__c> oldMap)
	{
		for (ZTS_EU_Account_Position__c ap: lstAccountPositionNew) {
			if (oldMap == null || (ap.ZTS_NotificationUser__c != oldMap.get(ap.Id).ZTS_NotificationUser__c || ap.ZTS_Employee_ID__c != oldMap.get(ap.Id).ZTS_Employee_ID__c)) {
				ap.ZTS_NotificationUser__c = ap.ZTS_Employee_ID__c;
			}			
			if (oldMap == null || (ap.ZTS_EU_Active__c && (ap.ZTS_EU_Account__c != oldMap.get(ap.Id).ZTS_EU_Account__c || ap.ZTS_EU_Position__c != oldMap.get(ap.Id).ZTS_EU_Position__c))) {
				ap.ZTS_AccountUserTerrUniqueKey__c=(ap.ZTS_EU_Account__c!=null && ap.ZTS_EU_Position__c!=null)?ap.ZTS_EU_Account__c+':'+ap.ZTS_EU_Position__c:null;
			}
        }
	}

	/************  
     * Method name  : onAfterUpdate
     * Description  : update the Account record fields based on the user territory.
     * Return Type  : N.A.
     * Parameters   : trigger parameters
     ***********
	//Teja- Commented the whole method since this functionality is not existing in INTL.
	public void onAfterUpdate(List<ZTS_EU_Account_Position__c> lstAccountPositionNew)
	{
		Map<ID, Account> parentOpps = new Map<ID, Account>();
	    List<ID> listIds = new List<ID>();
	    List<String> userIds = new List<String>();
	    Set<Account> accts = new Set<Account>();
	    Map<Id, Account> sobMap = new Map<Id, Account>();

	    for (ZTS_EU_Account_Position__c aps : lstAccountPositionNew) {
            listIds.add(aps.ZTS_EU_Account__c);  
            userIds.add(aps.ZTS_EU_Position__c);
      	}

	    parentOpps = new Map<Id, Account>([SELECT id,MZR_Program_Owner__c,MZR_Program_Owner_email__c,VGP_Program_Owner_email__c,VGP_Program_Owner__c,
	    											(SELECT  id,name,ZTS_NotificationUser__c,ZTS_NotificationUser__r.email FROM Account_Positions__r) 
	    									FROM Account WHERE ID IN :listIds AND ZTS_EU_Market__c != 'United States']);
	    List<ZTS_EU_Position__c> usrs = new List<ZTS_EU_Position__c>([SELECT id,ZTS_EU_Employee__r.email from ZTS_EU_Position__c where id IN:userIds]);
	    Map<id,string> usermap = new Map<id,String>();

       	for(ZTS_EU_Position__c usr:usrs)
          	usermap.put(usr.id,usr.ZTS_EU_Employee__r.email);

		for (ZTS_EU_Account_Position__c quote: lstAccountPositionNew)
		{
		  	Account acnt = parentOpps.get(quote.ZTS_EU_Account__c);
		  	if(quote.VGP_Program_Owner__c=='Primary' && acnt.VGP_Program_Owner__c!=quote.ZTS_EU_Employee__c)
		  	{
		  		Optimization done for the if iteration
		     	if(acnt.VGP_Program_Owner__c!=quote.ZTS_EU_Employee__c)
		     	{
			        acnt.VGP_Program_Owner__c= quote.ZTS_EU_Employee__c;
			        acnt.VGP_Program_Owner_email__c=usermap.get(quote.ZTS_EU_Position__c);
		       	//}
		  	}
		    if(quote.MZR_Program_Owner__c=='Primary' && acnt.MZR_Program_Owner__c!=quote.ZTS_EU_Employee__c)
		    {
		    	/******Optimization done for the if iteration******/
		     	/*if((acnt.MZR_Program_Owner__c!=quote.ZTS_EU_Employee__c))
		     	{
			        acnt.MZR_Program_Owner__c= quote.ZTS_EU_Employee__c;
			        acnt.MZR_Program_Owner_email__c=usermap.get(quote.ZTS_EU_Position__c);
		       	//}
		  	}
		    sobMap.put(acnt.id,acnt); 
		}
	        
      	if(!sobMap.Values().isEmpty())
         	update sobMap.Values();
	}*/

	/***********  
     * Method name  : onAfterInsertAutoFollow
     * Description  : Create/Update the EntitySubscription record.
     * Return Type  : N.A.
     * Parameters   : trigger parameters
     ***********/
	public void onAfterInsertAutoFollow(List<ZTS_EU_Account_Position__c> lstAccountPositionNew)
	{
		//autofollow account records and account position records for changes
        List < EntitySubscription > subscribes = new List < EntitySubscription > ();
        for (ZTS_EU_Account_Position__c acc_pos: lstAccountPositionNew) 
        {
            subscribes.add(new EntitySubscription(ParentId = acc_pos.id, SubscriberId = acc_pos.ZTS_NotificationUser__c)); //follow AP records
            subscribes.add(new EntitySubscription(ParentId = acc_pos.ZTS_EU_Account__c, SubscriberId = acc_pos.ZTS_NotificationUser__c)); //follow account records
        }

        List < Database.Upsertresult > results = Database.upsert(subscribes, false);
        ZTS_Logger.error(results, 'ZTS_Account_PositionTrigger -EntitySubscription Upsert');
	}

	/***********  
     * Method name  : onAfterUpdateAutoFollow
     * Description  : Create new EntitySubscription record and delete the old EntitySubscription record.
     * Return Type  : N.A.
     * Parameters   : trigger parameters
     ***********/
	public void onAfterUpdateAutoFollow(List<ZTS_EU_Account_Position__c> lstAccountPositionNew, Map<Id, ZTS_EU_Account_Position__c> mapAccountPositionOld)
	{
		List < EntitySubscription > subscribes = new List < EntitySubscription > ();
        List < EntitySubscription > unsubscribes = new List < EntitySubscription > ();

        Set < Id > unsubscribersIds = new Set < Id > ();
        Set < Id > entity_Ids = new Set < Id > ();

        for (ZTS_EU_Account_Position__c acc_pos: lstAccountPositionNew) 
        {
            if (acc_pos.ZTS_NotificationUser__c != null && mapAccountPositionOld.get(acc_pos.id).ZTS_NotificationUser__c != null 
                && acc_pos.ZTS_NotificationUser__c != mapAccountPositionOld.get(acc_pos.id).ZTS_NotificationUser__c) 
            {
                subscribes.add(new EntitySubscription(ParentId = acc_pos.id, SubscriberId = acc_pos.ZTS_NotificationUser__c)); //follow AP records
                subscribes.add(new EntitySubscription(ParentId = acc_pos.ZTS_EU_Account__c, SubscriberId = acc_pos.ZTS_NotificationUser__c)); //follow account records   

                unsubscribersIds.add(mapAccountPositionOld.get(acc_pos.id).ZTS_NotificationUser__c);
                entity_Ids.add(acc_pos.id);
                entity_Ids.add(acc_pos.ZTS_EU_Account__c);
            }
        }

		List < EntitySubscription > unfollow_subscriptions = [SELECT Id, ParentId, SubscriberId 
																FROM EntitySubscription 
																WHERE SubscriberId = : unsubscribersIds AND ParentId IN: entity_Ids LIMIT 1000];
        if(Test.isRunningTest()){
        if (!unfollow_subscriptions.isEmpty()) {List < Database.DeleteResult > delResults = Database.delete(unfollow_subscriptions, false);
            ZTS_Logger.error(delResults, 'ZTS_Account_PositionTrigger -EntitySubscription delete');
        }


        if (!subscribes.isEmpty()) {
            List < Database.Saveresult > results = Database.insert(subscribes, false);
            ZTS_Logger.error(results, 'ZTS_Account_PositionTrigger -EntitySubscription Insert-afterUpdate');
        }
        }	
	}
}
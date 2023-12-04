@isTest(seeAllData=false)
public with sharing class TestZTS_GL_Call {

public testmethod static void doTest(){
	//ZTS_GL_CallManager callmgr=new ZTS_GL_CallManager();
	/*Account acc=[select id,name from Account where name='TAccount1' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
	Call__c call=[select id from Call__c where Account__c=:acc.id AND ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
	Attendee__c att=new Attendee__c(call__c=call.id,Employee__c=UserInfo.getUserId());
	insert att;
	List<Attendee__c> attlist=new List<Attendee__c>();
	attlist.add(att);
	
	Map<Id,Attendee__c> attMap=new Map<Id,Attendee__c>(attlist);*/
	//ZTS_GL_CallManager.checkTimeOffTerritoryCallForAttendees(attMap);
	/* SHIVA - Aug29 - commenting below DML stmt since it is throwing Limit Exceeded Exception during Production Deployment
	Territory t=new Territory();
    t.name='TO DELETE'; 
    insert t; 
    System.assert(t.id!=null);
    */
    //assign account territory assignment rule
    //AccountTerritoryAssignmentRule atr=new AccountTerritoryAssignmentRule();
   // atr.IsActive=true; DML operation not allowed
   // atr.Name='SampleAssignmentRule';
   // atr.TerritoryId =t.id;
    
   // insert atr;
}
}
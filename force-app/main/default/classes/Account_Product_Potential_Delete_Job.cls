/*
    @@ Puropose: To delete all records from Account_Product_Potential__c object
    @@ Author: Pavan Kumar
    @@ Date : 29- Jan-2015
    @@Test Class : Account_Prod_Potential_Calculation_Test    
*/
/*
    @@ Sample Script to run batch
        Account_Product_Potential_Delete_Job a = new Account_Product_Potential_Delete_Job(); 
        database.executeBatch(a);
        
        	(OR)
        	
         Account_Product_Potential_Delete_Job a = new Account_Product_Potential_Delete_Job('Business Unit'); 
         database.executeBatch(a);
*/

global class Account_Product_Potential_Delete_Job implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
	
	global void execute(SchedulableContext ctx) {
   		Account_Product_Potential_Delete_Job a = new Account_Product_Potential_Delete_Job(); 
        database.executeBatch(a);
   	}	 
	
   set<string> market;	
   string businessUnit;
   String whereClause = '';
   global Account_Product_Potential_Delete_Job(){
   	    market = new set<string>();
   	    string marketLst;
   	    date knownSunday =Date.newInstance(2000, 1, 2); // This is static day, And it is sunday. To Calculate name of the weekday
		date todayDay = system.today();
		System.debug('>'+knownSunday);
		System.debug('>>todayDay>>'+todayDay);
		integer diff = knownSunday.daysBetween(todayDay);
		System.debug('>>Difference>>'+diff);
		integer weekDayNumber = Math.mod(diff,7);
		System.debug('>>weekDayNumber>>'+weekDayNumber);
		map<string, integer> daysMap = new map<string, integer>();
		daysMap.put('Sunday',0);
		daysMap.put('Monday',1);
		daysMap.put('Tuesday',2);
		daysMap.put('Wednesday',3);
		daysMap.put('Thursday',4);
		daysMap.put('Friday',5);
		daysMap.put('Saturday',6);
		List<Acc_Prod_Pot_Markets__c> accMarketsPerDay = new list<Acc_Prod_Pot_Markets__c>();
		accMarketsPerDay = Acc_Prod_Pot_Markets__c.getall().values();
		for(Acc_Prod_Pot_Markets__c ap : accMarketsPerDay){
			if(daysMap.get(ap.name) != null){
				if(weekDayNumber == daysMap.get(ap.name)){
					//system.debug('>>>>>>>: : '+ap.name);
					//system.debug('>>>>>>>: : '+ap.markets__c);
					marketLst = ap.markets__c;
				}	
			}
		}
		if(marketLst != null && marketLst != ''){
			market.addAll(marketLst.split(','));
		}
		system.debug('market>>>'+market);
		whereClause = ' where Account__r.ZTS_EU_Market__c in:market';
   }	
   
   global Account_Product_Potential_Delete_Job(String businessUnit){
   		this.businessUnit  = businessUnit;
   	    market = new set<string>();
   	    string marketLst;
   	    date knownSunday =Date.newInstance(2000, 1, 2); // This is static day, And it is sunday. To Calculate name of the weekday
		date todayDay = system.today();
		System.debug('>'+knownSunday);
		System.debug('>>todayDay>>'+todayDay);
		integer diff = knownSunday.daysBetween(todayDay);
		System.debug('>>Difference>>'+diff);
		integer weekDayNumber = Math.mod(diff,7);
		System.debug('>>weekDayNumber>>'+weekDayNumber);
		map<string, integer> daysMap = new map<string, integer>();
		daysMap.put('Sunday',0);
		daysMap.put('Monday',1);
		daysMap.put('Tuesday',2);
		daysMap.put('Wednesday',3);
		daysMap.put('Thursday',4);
		daysMap.put('Friday',5);
		daysMap.put('Saturday',6);
		List<Acc_Prod_Pot_Markets__c> accMarketsPerDay = new list<Acc_Prod_Pot_Markets__c>();
		accMarketsPerDay = Acc_Prod_Pot_Markets__c.getall().values();
		for(Acc_Prod_Pot_Markets__c ap : accMarketsPerDay){
			if(daysMap.get(ap.name) != null){
				if(weekDayNumber == daysMap.get(ap.name)){
					//system.debug('>>>>>>>: : '+ap.name);
					//system.debug('>>>>>>>: : '+ap.markets__c);
					marketLst = ap.markets__c;
				}	
			}
		}
		if(marketLst != null && marketLst != ''){
			market.addAll(marketLst.split(','));
		}
		system.debug('market>>>'+market);
		whereClause = ' where Account__r.ZTS_EU_Market__c in:market and Account_Species_Consultation__r.ZTS_EU_BU_Abbr__c like :buAbbr';
   }	

   global Database.QueryLocator start(Database.BatchableContext BC){
   		/* Querying all fields form account product potentail obect */
		string qry = '';
		/*if(businessUnit != null && businessUnit != ''){
			qry = 'select id,Account__r.ZTS_EU_Market__c from ZTS_EU_Account_Product_Potential__c where Account__r.ZTS_EU_Market__c in:market and ZTS_EU_Business_Unit_Abbr__c  =:businessUnit';
		}else{
			qry = 'select id,Account__r.ZTS_EU_Market__c from ZTS_EU_Account_Product_Potential__c where Account__r.ZTS_EU_Market__c in:market';	
		}*/
		string buAbbr = '%'+businessUnit+'%';
		qry = 'select id,Account__r.ZTS_EU_Market__c from ZTS_EU_Account_Product_Potential__c' + whereClause;
        return Database.getQueryLocator(qry);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   		try{
   			if(!scope.isEmpty()){
   				delete scope;
   				system.debug('Scope>>>'+scope);
   			}
   		}catch(Exception e){System.debug('++++Exception  :'+e.getMessage());}
   }

   global void finish(Database.BatchableContext BC){
   		//Added batch limit using custom setting, to make it dynamic --Pavan
   		if(Acc_Prod_Pot_Markets__c.getValues('Account_Prod_Potential_Calculation_Job') != null){
			Acc_Prod_Pot_Markets__c bl = Acc_Prod_Pot_Markets__c.getValues('Account_Prod_Potential_Calculation_Job');
			Account_Prod_Potential_Calculation_Job a = new Account_Prod_Potential_Calculation_Job(market,businessUnit); 
      		database.executeBatch(a,integer.valueOf(bl.Batch_Limit__c));
		}
   }
}
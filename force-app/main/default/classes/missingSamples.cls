global class missingSamples implements Database.Batchable<SObject>
{
    global Database.queryLocator start(Database.BatchableContext bc) 
    {
         List<Id> productsIds = new List<Id>{'a0oF000000DYsfw','a0oF000000DYsg7','a0oF000000DYsgA','a0oF000000DYsg4','a0oF000000DYsgD','a0oF000000DYsgO','a0oF000000DYsgX','a0oF000000DYsgj','a0oF000000DYsgg','a0oF000000DYsgk','a0oF000000DYsgh','a0oF000000DYsgi','a0oF000000DYsgl','a0oF000000DYsgn','a0oF000000DYsgv','a0oF000000DYsgN','a0oF000000DYsh8','a0oF000000DYshF','a0oF000000DYshK','a0oF000000DYshQ','a0oF000000DYshn','a0oF000000DYsi0','a0oF000000DYsiD','a0oF000000DYsiM','a0oF000000DYsiN','a0oF000000DYsiR','a0oF000000DYsiT','a0oF000000DYsiV','a0oF000000DYsiO','a0oF000000DYsiq','a0oF000000DYsir','a0oF000000DYsjB','a0oF000000DYsjI','a0oF000000DYsjM','a0oF000000DYsjW','a0oF000000DYsjY','a0oF000000FmCUq','a0oF000000DYskB','a0oF000000DYskE','a0oF000000DYskH','a0oF000000DYskZ','a0oF000000DYske','a0oF000000DYskg','a0oF000000DYskh','a0oF000000DYskm','a0oF000000DYskp','a0oF000000DYskq','a0oF000000DYskw','a0oF000000DYsky','a0oF000000DYsli','a0oF000000DYslm','a0oF000000FmCUp','a0oF000000DYsls','a0oF000000DYsmF','a0oF000000DYsmG','a0oF000000DYsmK','a0oF000000DYsmL','a0oF000000DYsmN','a0oF000000DYsmP','a0oF000000DYsmS','a0oF000000DYsmE','a0oF000000DYsmQ','a0oF000000DYsmn','a0oF000000DYsn1','a0oF000000DYsn5','a0oF000000DYsn9','a0oF000000DYsnD','a0oF000000DYsnH','a0oF000000DYsnL','a0oF000000DYsfj','a0oF000000FmCUz','a0oF000000FmCV1','a0oF000000DYsnc','a0oF000000DYsne'};
         String query = 'Select Id,ZTS_EU_Contact__c,ZTS_EU_Product__c from ZTS_EU_Sample__c where ZTS_EU_Product__c IN: productsIds' ;      
         return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<ZTS_EU_Sample__c> scope)
     {              
            List<Contact> allContactList = new List<Contact>();
            allContactList = [Select Id from Contact where ZTS_EU_Contact_type__c = 'Veterinarian' and ZTS_EU_Market__c = 'Italy'];
            System.debug('allContactList-Size---'+allContactList.Size());

            Map<ID,List<Id>> productVsContacts = new Map<Id,List<Id>>(); 
            for(ZTS_EU_Sample__c samples : scope)
            {
                List<Id> tempList = productVsContacts.get(samples.ZTS_EU_Product__c);
                 if (tempList == null)
                {
                    productVsContacts.put(samples.ZTS_EU_Product__c, new List<ID>{samples.ZTS_EU_Contact__c});
                }   
                 else
                {
                    tempList.add(samples.ZTS_EU_Contact__c);              
                }
            }
            System.debug('productVsContacts----'+productVsContacts);

            String ContactsIds = '';
            String CompleteId = '';
            Map<Id,String> myMap = new Map<Id,String>();
            for(Id prod : productVsContacts.keySet())
            {
                List<Id> limitedContactsList = productVsContacts.get(prod);
                for(Contact con1 : allContactList)
                {
                    for(Id con2 : limitedContactsList)
                    {
                        try
                        {
                            if(con1.id != con2)
                            {
                                ContactsIds = ContactsIds + con1.id;
                            }
                        }Catch(Exception e)
                        {
                        
                        }
                    }
                }
                CompleteId = CompleteId + 'Product: ' + prod + 'Contacts: ' + ContactsIds;              
                myMap.put(prod,CompleteId);
                ContactsIds = '';
                CompleteId = '';
            }
            System.debug('ContactsIds----'+ContactsIds);
            System.debug('CompleteId----'+CompleteId);
            System.debug('myMap----'+myMap);
                                        
    }
      global void finish(Database.BatchableContext bc) 
     {
        
     }
}
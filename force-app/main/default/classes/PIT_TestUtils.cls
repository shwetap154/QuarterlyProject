@isTest
public class PIT_TestUtils {

     public static void  activateTriggerSettings(){
        List<TriggerActivation__c> taList=new List<TriggerActivation__c>();
        List<String> names=new List<String>{'PIT_STOMPtrigger',
                                    'PIT_TestOrderedTrigger'};
        for(String name:names)  {
            TriggerActivation__c ta=new TriggerActivation__c(name=name,isActive__c=true);
            taList.add(ta);
        }   
        
        upsert talist;                  
     }
     
}
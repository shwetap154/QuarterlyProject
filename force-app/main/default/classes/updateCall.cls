public class updateCall
{
    public static void callUpdate(List<Attendee__c> newAttendeeList)
    {
        List<Attendee__c> attendeeList = new List<Attendee__c>();
        attendeeList = [Select Id, Name,ZTS_EU_call__c from Attendee__c where id IN:newAttendeeList AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        System.debug('attendeeList------'+attendeeList);
        Set<Id> callId = new Set<Id>();
        String contactName = '';
        for(Attendee__c att : attendeeList)
        {
            callId.add(att.ZTS_EU_call__c);
            contactName = contactName + att.Name;
        }
        System.debug('callId------'+callId);
        System.debug('contactName------'+contactName);
        List<Call__c> callList = new List<Call__c>();
        List<Call__c> callListToUpodate = new List<Call__c>();
        callList = [Select Id, Name,contact_Employee__c from Call__c where id=:callId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        
        List<Attendee__c> existingAttedeeList = new List<Attendee__c>();
        existingAttedeeList = [Select id,Name,ZTS_EU_call__c from Attendee__c where ZTS_EU_call__c =: callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        System.debug('existingAttedeeList------'+existingAttedeeList);
        System.debug('existingAttedeeList--Size----'+existingAttedeeList.Size());
        
        String allContactName = '';
        
        //String callContact = '';
        integer i=1;
        for(Attendee__c att : existingAttedeeList)
        {
            if(i != existingAttedeeList.Size())
            {
                allContactName = allContactName + att.Name + ';';
            }
            if(i == existingAttedeeList.Size())
            {
                allContactName = allContactName + att.Name;
            }
            i++;
        }
        System.debug('allContactName------'+allContactName);    
        for(Call__c call: callList)
        {
            System.debug('call.Contact_Employee__c--------'+call.Contact_Employee__c);
            
            call.Contact_Employee__c = allContactName ;
            callListToUpodate.add(call);
        }
        System.debug('callListToUpodate------'+callListToUpodate);
        System.debug('callListToUpodate--Size----'+callListToUpodate.Size());
        
        update callListToUpodate;
    }
    public static void callUpdateOnAttendeeDelete(List<Attendee__c> oldAttendeeList)
    {
        List<Attendee__c> attendeeList = new List<Attendee__c>();
        attendeeList = [Select Id, Name,ZTS_EU_call__c from Attendee__c where id IN:oldAttendeeList AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        System.debug('attendeeList------'+attendeeList);
        Set<Id> callId = new Set<Id>();
        String contactName = '';
        for(Attendee__c att : attendeeList)
        {
            callId.add(att.ZTS_EU_call__c);
            contactName = contactName + att.Name;
        }
                
        System.debug('callId------'+callId);
        System.debug('contactName------'+contactName);
        List<Call__c> callList = new List<Call__c>();
        List<Call__c> callListToUpodate = new List<Call__c>();
        callList = [Select Id, Name,Contact_Employee__c,Discussion_Item_Count__c,Discussion_Item__c from Call__c where id=:callId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        String callEmployee = '';   
        List<String> stringList = new List<String>();   
        List<String> stringList2 = new List<String>();
        List<String> stringList3 = new List<String>();
        
        for(Call__c call: callList)
        {   
            
            callEmployee = call.Contact_Employee__c;
            //callEmployee = callEmployee.replaceAll( '\\s+', '');
            System.debug('callEmployee-1---'+callEmployee);
            if(callEmployee != null)
            {
                stringList = callEmployee.split(';');
                stringList2.addAll(stringList);
                System.debug('stringList--2-------'+stringList2);
                System.debug('stringList2--size-------'+stringList2.Size());
                for(integer j=0;j<stringList2.Size();j++)
                {
                    System.debug('j------'+j);
                    System.debug('stringList[j]------'+stringList2[j]);
                    /*if(stringList2[j] == contactName)
                    {
                         System.debug('matched--------');
                         stringList.remove(j);                                              
                    }*/
                    if(stringList2[j] != contactName)
                    {
                        System.debug('not matched--------');
                        stringList3.add(stringList2[j]);
                    }           
                }
                
                integer i =1;
                callEmployee = '';
                System.debug('stringList--3-------'+stringList3);
                for(String str: stringList3)
                {
                    if(i != stringList3.Size())
                    {
                        callEmployee = callEmployee + str + ';';
                    }
                    if(i == stringList3.Size())
                    {
                        callEmployee = callEmployee + str;
                    }
                    i++;
                }
                System.debug('callEmployee-2---'+callEmployee);
                if(callEmployee == '')
                {
                    call.Discussion_Item__c = '';
                    call.Discussion_Item_Count__c = 0;
                }
                call.Contact_Employee__c = callEmployee;
                
                System.debug('call.Contact_Employee__c------'+call.Contact_Employee__c);                    
                callListToUpodate.add(call);
            }
            
        }
        System.debug('callListToUpodate------'+callListToUpodate);
        System.debug('callListToUpodate--Size----'+callListToUpodate.Size());
        
        update callListToUpodate;
    }
}
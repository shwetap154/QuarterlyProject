/*************************************************************************************************************************
      Class Name     : ZTS_EU_Account_Segmentation_Rating
      Description    : This class is called from trigger on Account_Segmentation_threshold__c for implementing populating of the minimum threshold value for the threshold range.
                       as per business rule
      Created By     : Shefali Vinchurkar
      Created On     : 02/09/2014
                                                               
***************************************************************************************************************************/
public class ZTS_EU_Account_Segmentation_Rating{

    public static void validateRating(List<Account_Segmentation_threshold__c> TriggerRecords, boolean isInsert, boolean isUpdate){
        ZTS_EU_Constants.SegmentationTriggerFlag = true;
        Set<String> setKeyMaxASTMArket =new Set<String>();
        Set<String> setKey=new Set<String>();
        Set<String> marketsSet =new Set<String>();
        Set<String> bUnitSet =new Set<String>();
       
       for(Account_Segmentation_threshold__c ts : TriggerRecords){ 
            marketsSet.add(''+ts.ZTS_EU_Market__c);
            bUnitSet.add(''+ts.BU_Abbrv__c);
        }
       
        List<Account_Segmentation_threshold__c> existingThresholdRecordsList =[Select Id, BU_Abbrv__c,
                            ZTS_EU_Market__c,ZTS_EU_Segmentation_Rating__c, ZTS_EU_Threshold_Maximum_Value_Potential__c,
                            ZTS_EU_Threshold_Minimum_Value_Potential__c from Account_Segmentation_threshold__c 
                            where ZTS_EU_Market__c IN: marketsSet AND BU_Abbrv__c IN: bUnitSet];
        
        // Storing unique key values for market, Business Unit and Maximum value for a particular threshold
        for(Account_Segmentation_threshold__c astRecord : existingThresholdRecordsList){
            setKeyMaxASTMArket.add(''+astRecord.ZTS_EU_Market__c+';'+astRecord.BU_Abbrv__c +';'+astRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c);
        }
        system.debug('####existingThresholdRecordsList#####'+existingThresholdRecordsList);
        List<Account_Segmentation_threshold__c> updateList = new List<Account_Segmentation_threshold__c>(); 
        try{
        if(!existingThresholdRecordsList.isEmpty()){
            for(Account_Segmentation_threshold__c tRecord : TriggerRecords){
            /*    if(setKeyMaxASTMArket.contains(''+tRecord.ZTS_EU_Market__c+';'+tRecord.BU_Abbrv__c +';'+tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c) && ((isInsert && !isUpdate) ||(isUpdate && !isInsert))){
                        //NC REVIEW this kind of messages to the user needs to be extracted from the code and we need to use
                        // a custom label. This would then allow us to translate it.
                        tRecord.addError(System.Label.ZTS_EU_ExistingMaximumThreshold);
                   
                }else{
            */         
                        setKey.add(''+tRecord.ZTS_EU_Market__c+';'+tRecord.BU_Abbrv__c);  
                        Map<String, List<Account_Segmentation_threshold__c>> finalMap = new Map<String, List<Account_Segmentation_threshold__c>>();
                        finalMap = createSortedMap(setKey,existingThresholdRecordsList);
                        system.debug('finalMap#####'+finalMap);
                        // Finding the records from which the values to be updated need to be fetched(previous and next records)
                        if(!finalMap.get(''+tRecord.ZTS_EU_Market__c+';'+tRecord.BU_Abbrv__c).isEmpty()){
                            Integer listSize=finalMap.get(''+tRecord.ZTS_EU_Market__c+';'+tRecord.BU_Abbrv__c).size();
                            List<Account_Segmentation_threshold__c> mapValues = new List<Account_Segmentation_threshold__c>();
                            mapValues = finalMap.get(''+tRecord.ZTS_EU_Market__c+';'+tRecord.BU_Abbrv__c);
                            
                            for(Integer i=0; i<listSize;i++){ 
                            
                                if(isInsert && !isUpdate){
                                
                                    if( (tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c < mapValues[0].ZTS_EU_Threshold_Minimum_Value_Potential__c) ){
                                        tRecord.ZTS_EU_Threshold_Minimum_Value_Potential__c = 0;
                                        mapValues[0].ZTS_EU_Threshold_Minimum_Value_Potential__c = tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c;
                                        updateList.add(mapValues[0]);
                                        break;
                                    }
                                    else if( (tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c > mapValues[0].ZTS_EU_Threshold_Minimum_Value_Potential__c) && (tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c < mapValues[0].ZTS_EU_Threshold_Maximum_Value_Potential__c) ){
                                        tRecord.ZTS_EU_Threshold_Minimum_Value_Potential__c = mapValues[0].ZTS_EU_Threshold_Minimum_Value_Potential__c;
                                        mapValues[0].ZTS_EU_Threshold_Minimum_Value_Potential__c = tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c;
                                        updateList.add(mapValues[0]);
                                        break;
                                    }
                                    
                                    else if(  (tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c > mapValues[listSize-1].ZTS_EU_Threshold_Maximum_Value_Potential__c) ){
                                        //NC REVIEW Please put this break to the next line
                                        tRecord.ZTS_EU_Threshold_Minimum_Value_Potential__c = mapValues[listSize-1].ZTS_EU_Threshold_Maximum_Value_Potential__c;                      
                                        break;
                                    }
                                    else if( (tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c < mapValues[i].ZTS_EU_Threshold_Maximum_Value_Potential__c) && (tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c > mapValues[i].ZTS_EU_Threshold_Minimum_Value_Potential__c)  ){
                                        tRecord.ZTS_EU_Threshold_Minimum_Value_Potential__c = mapValues[i-1].ZTS_EU_Threshold_Maximum_Value_Potential__c;
                                        mapValues[i].ZTS_EU_Threshold_Minimum_Value_Potential__c = tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c;
                                        updateList.add(mapValues[i]);
                                        break;
                                    }
                                }else if(!isInsert && isUpdate){
                                    if(tRecord.ZTS_EU_Threshold_Minimum_Value_Potential__c == mapValues[i].ZTS_EU_Threshold_Minimum_Value_Potential__c){
                                        if(mapValues[i+1].ZTS_EU_Threshold_Maximum_Value_Potential__c != null ){
                                            if(tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c<mapValues[i+1].ZTS_EU_Threshold_Maximum_Value_Potential__c){
                                                mapValues[i+1].ZTS_EU_Threshold_Minimum_Value_Potential__c =tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c;
                                                updateList.add(mapValues[i+1]);
                                                break;
                                            }else{
                                                tRecord.addError(System.Label.ZTS_EU_InvalidMaximumValue+ mapValues[i+1].ZTS_EU_Threshold_Maximum_Value_Potential__c);
                                            }
                                        }else{
                                            mapValues[i+1].ZTS_EU_Threshold_Minimum_Value_Potential__c =tRecord.ZTS_EU_Threshold_Maximum_Value_Potential__c;
                                            updateList.add(mapValues[i+1]);
                                            break;
                                        }   
                                    }
                                
                                }else if(!isInsert && !isUpdate){
                                    if(tRecord.ZTS_EU_Threshold_Minimum_Value_Potential__c == mapValues[i].ZTS_EU_Threshold_Minimum_Value_Potential__c && (i+1 <listSize)){
                                        //NC REVIEW Won't work in case this is the last one in the list. Add check if (i+1 < listSize) to the above if
                                        mapValues[i+1].ZTS_EU_Threshold_Minimum_Value_Potential__c =tRecord.ZTS_EU_Threshold_Minimum_Value_Potential__c;
                                        updateList.add(mapValues[i+1]);
                                        break;
                                    }
                                }
                            
                            } 
                        }
                        system.debug('updateList##1##'+updateList);
                        //NC REVIEW This is a bug as it will not work as you are only updating one record here?updateList[0] so
                        //only the first in the list?
                                                                  
                //}
                
            }
            if(!updateList.isEmpty()){
                            
                            database.update(updateList);
                        }
        }
        }catch(Exception e){
            system.debug('Exception'+e.getMessage());
        }
        system.debug('updateList##2##'+updateList);
    }
    
    /**
    *   @Description : method to create a Map with sorted Records List per combination 
    *                    of Business Unit and Market.
    *   @Author : Shefali Vinchurkar
    **/
    public static Map<String, List<Account_Segmentation_threshold__c>> createSortedMap(Set<String> setKeys,List<Account_Segmentation_threshold__c> existingThresholdRecordsList){
        Map<String, List<Account_Segmentation_threshold__c>> keysASTMap = new Map<String,List<Account_Segmentation_threshold__c>>();
        Map<String, List<Account_Segmentation_threshold__c>> keysASTFinalMap;
        if(!existingThresholdRecordsList.isEmpty()){
            for(Account_Segmentation_threshold__c ast : existingThresholdRecordsList){
                if(setKeys.contains(''+ast.ZTS_EU_Market__c+';'+ast.BU_Abbrv__c)){
                    List<Account_Segmentation_threshold__c> tempList = keysASTMap.get(''+ast.ZTS_EU_Market__c+';'+ast.BU_Abbrv__c);
                    if(null==tempList){
                        tempList = new List<Account_Segmentation_threshold__c>();   
                    }
                    tempList.add(ast);
                    keysASTMap.put(''+ast.ZTS_EU_Market__c+';'+ast.BU_Abbrv__c, tempList);                  
                }
            }
            keysASTFinalMap= new Map<String,List<Account_Segmentation_threshold__c>>();
            for(String key : keysASTMap.keySet()){
                Map<String, Account_Segmentation_threshold__c> thresholdSortMap = new Map<String, Account_Segmentation_threshold__c>(); 
                
                List<Decimal> sortThis = new List<Decimal>();
                
                //loop for sorting the List of threshold records according to Minimum values
                for(Account_Segmentation_threshold__c t : keysASTMap.get(key)){             
                   thresholdSortMap.put(String.valueOf(t.ZTS_EU_Threshold_Minimum_Value_Potential__c), t);
                   sortThis.add(t.ZTS_EU_Threshold_Minimum_Value_Potential__c);
                }
                system.debug('sortedList###111###'+sortThis);
                sortThis.sort();
                system.debug('sortedList###222###'+sortThis);
                List<Account_Segmentation_threshold__c> sortedThresholdList = new List<Account_Segmentation_threshold__c>();
                for(Decimal st : sortThis)
                {
                   String tempS =String.valueOf(st);
                   sortedThresholdList.add(thresholdSortMap.get(tempS));
                }
                keysASTFinalMap.put(key, sortedThresholdList);
                system.debug('sortedThresholdList#####'+sortedThresholdList);
            } 
            
        }
        system.debug('Sorted Map#####'+keysASTFinalMap);
        return  keysASTFinalMap;    
    }   
}
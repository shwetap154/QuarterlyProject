/*************************************************************************************************************************
  Class Name     : ZTS_Logger
  Description    : This class contains operation used for Logging
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Deloitte Constulting/Raghu          03/12/2014              Created

***************************************************************************************************************************/
public  class ZTS_Logger {
    
    private enum Level{
        TRACE,
        DEBUG,
        INFO,
        WARN,
        ERROR,
        FATAL
    }
    
    public static boolean notify{get;set;}
    private static void log(String message,Level level,String statusCode,String logtype){
        boolean notifyAdmin=false;
        if(notify!=null && notify){
            notifyAdmin=true;
        }
        Integer MSG_LIMIT_SIZE=32768;
        //CHECK FOR MSG SIZE LIMIT
        if(message.length()>=MSG_LIMIT_SIZE){
            message=message.substring(0, MSG_LIMIT_SIZE-1);
            
        }
        
        ZTS_EU_Error_Log__c log_obj=new ZTS_EU_Error_Log__c(ZTS_EU_Message__c=message,ZTS_EU_Log_level__c=level.name(),ZTS_EU_Origin_Type__c=logtype,ZTS_EU_Notify_Admin__c=notifyAdmin);
        log_obj.ZTS_EU_Status_Code__c=statusCode==null?'':statusCode;
        Database.insert(log_obj,false);
        
    }
    
    public static void error(String message,String statusCode,String logtype){
           log(message,Level.ERROR,statusCode,logtype);
    }
    
    @future
    public static void errorAsync(String message,String statusCode,String logtype){
           log(message,Level.ERROR,statusCode,logtype);
    }
    
    
    public static void warn(String message,String statusCode,String logtype){
                   log(message,Level.WARN,statusCode,logtype);
    }
    
    
    public static void info(String message,String statusCode,String logtype){
                   log(message,Level.INFO,statusCode,logtype);
    }
    
    
    public static void debug(String message,String statusCode,String logtype){
                   log(message,Level.DEBUG,statusCode,logtype);
    }
    
    
    public static void trace(String message,String statusCode,String logtype){
                   log(message,Level.TRACE,statusCode,logtype);
    }
    
    
    public static void addPageMessage(ApexPages.Message msg){
        ApexPages.addMessage(msg);
    }
    
    public static void addPageMessage(ApexPages.Severity severity,String msg){
        ApexPages.Severity serv_level=severity==null?ApexPages.Severity.INFO:severity;
        ApexPages.Message pgMsg=new ApexPages.Message(serv_level,msg);
         addPageMessage(pgMsg);
    }
    
    
    public static String toString(ZTS_EU_Error_Log__c log){
        String msg=log.ZTS_EU_Log_level__c + ' : '+log.ZTS_EU_Message__c;
        System.debug(LoggingLevel.Error,'## ZOETIS ERROR LOG : '+msg);
        return msg;
    }
    
    public static void error(List<Object> dmlResults,String origin ){
            
            //implement for merge results - others
            String msg=getDMLErrorMsg(dmlResults);
             if(!String.isBlank(msg)){
               ZTS_Logger.error(msg, null,origin);
              }
        }
        
    
    
     public static String getDMLErrorMsg(List<Object> dmlResults ){
        String msg='';
        
        if(dmlResults!=null && !dmlResults.isEmpty()){
            Object dmlResult=dmlResults[0];
                boolean isError=false;
            if(dmlResult instanceof Database.Saveresult ){
                //create error msg details for failed records
                for(Database.Saveresult res:(List<Database.Saveresult>)dmlResults){
                    if(!res.isSuccess()){
                    isError=true;
                    msg+=res.getErrors()[0];
                    }
                 }  
                    
            }
                
            
            else if(dmlResult instanceof Database.Upsertresult){
                //create error msg details for failed records
                    for(Database.Upsertresult res:(List<Database.Upsertresult>)dmlResults){
                    if(!res.isSuccess()){
                    isError=true;
                
                msg+=res.getErrors()[0];
              }
            }   
                
                
            }
            
            else if(dmlResult instanceof Database.DeleteResult){
                //create error msg details for failed records
                for(Database.DeleteResult res:(List<Database.DeleteResult>)dmlResults){
                    if(!res.isSuccess()){
                    isError=true;
                
                msg+=res.getErrors()[0];
              }
            }   
                
            }
            
            //implement for merge results - others
        
    }
    
                return msg;
     }
     
     
     
      public static String getDMLSuccessMsg(List<Object> dmlResults ){
        String msg='';
        Integer rec_count=0;
        if(dmlResults!=null && !dmlResults.isEmpty()){
            Object dmlResult=dmlResults[0];
                boolean isError=false;
            if(dmlResult instanceof Database.Saveresult ){
                //create error msg details for failed records
                for(Database.Saveresult res:(List<Database.Saveresult>)dmlResults){
                    if(res.isSuccess()){
                    msg+=res.getId() +',';
                    rec_count++;
                    }
                 }  
                    
            }
                
            
            else if(dmlResult instanceof Database.Upsertresult){
                //create error msg details for failed records
                    for(Database.Upsertresult res:(List<Database.Upsertresult>)dmlResults){
                    if(res.isSuccess()){
                    msg+=res.getId() +',';
                    rec_count++;
                    }          
                    
                     }  
                
                
            }
            
            else if(dmlResult instanceof Database.DeleteResult){
                //create error msg details for failed records
                for(Database.DeleteResult res:(List<Database.DeleteResult>)dmlResults){
                if(res.isSuccess()){
                    msg+=res.getId() +',';
                    rec_count++;
                    }          
                     }  
                
            }
            
            //implement for merge results - others
        
    }
    
                return msg +'\n Total records success : '+rec_count;
     }
    
    @future
    public static void errorAsync(String msg,String origin){
        ZTS_Logger.error(msg, null,origin);
        
    } 
    //Created by chanbasha Noorbashsheik on 19-July-2021
    //This method is for to update the Assigned territory status field after std territory created
    @future(callout = true)
    public static void processAsyncUS() {
    
         ZTS_US_UnsyncTerritoryConsoleResults zc = new ZTS_US_UnsyncTerritoryConsoleResults();
         zc.updateCustomTerrAssignedStatus();
    
    }
   
}
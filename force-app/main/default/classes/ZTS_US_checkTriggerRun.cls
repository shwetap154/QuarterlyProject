/*************************************************************************************
* Name          :    ZTS_US_checkTriggerRun
* Description   :    Class to prevent trigger exceed limit for after insert on Account.
* Author        :    Akanksha
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
06/03/2014       Akanksha                  Created

**************************************************************************************/
public class ZTS_US_checkTriggerRun{

    private static boolean flag = true;
    public static boolean runOnce(){
    if(flag){
     flag=false;
     return true;
    }else{
        return flag;
    }
    }
    public static void resetAll(){
     flag = true;
} 
}
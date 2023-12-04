/*************************************************************************************************************************
  Class Name     : USGlobalVariablesService
  Description    : This class contains global environment variable used by several service classes.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/17/2014
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Fayas Mansoor    01/17/2014              Created

***************************************************************************************************************************/
global class USGlobalVariablesService {


    public static boolean isCallUpdatingEvent   = false;
    public static boolean isEventUpdatingCall   = false;
    
    public static boolean isCallDeletingEvent   = false;
    public static boolean isEventDeletingCall   = false;
    
    public static boolean isCallProgressEvent   = true;
}
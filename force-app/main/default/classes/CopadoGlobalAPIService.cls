/**
 * @description       : Class for checking, removing, and assigning licenses
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-28-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   03-09-2022   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   06-01-2022   Ethan Hirsch @ Zoetis Inc      Minor code cleanup and add special test logic to avoid errors
 * 1.2   07-01-2022   Ethan Hirsch @ Zoetis Inc      Update checkLicense so that Users with Admin Copado licenses are identified as Active Users.
 *                                                   Make it clearer that methods only modify CCM access to Copado.
 *                                                   Update modifyUserLicense so that it does not impact license assignments other than CCM
 * 1.3   07-27-2022   Ethan Hirsch @ Zoetis Inc      Add a catch around create license. A hard error is thrown if a 
 *                                                   license is assigned without any available.
 *                                                   Fix an issue with revoking a license returning a false positive by deleting and recreating a license if needed.
 * 1.4   07-28-2022   Ethan Hirsch @ Zoetis Inc      Change license assignment to always delete and recreate licenses to
 *                                                   avoid permission errors.
 **/
public with sharing class CopadoGlobalAPIService {

    // Copado license information:
    // CCMenabled -> User has an active user license to Copado (Copado User license)
    // CopadoEnabled -> User has a Copado Admin license
    // CADEnabled -> User has a Copado Plan license. They can access planning functionality, but can't do commits
    // CCHEnabled -> User has Compliance Hub Access to enforce security and deployment restrictions
    // CTSenabled -> ? possibly Selenium license
    private static Map<Id, copado.GlobalAPI.UserLicense> userToLicenseMap;
    private static LicenseOperationResult result;
    @testVisible private static boolean forceModifyLicenseError = false;

    /**
    * @description Retrieves a map of Copado Licenses by User Id
    * @author Morgan Marchese @ Zoetis Inc | 03-09-2022 
    * @return Map<Id, copado.GlobalAPI.UserLicense> 
    **/
    @TestVisible
    private static Map<Id, copado.GlobalAPI.UserLicense> getUserIdToLicenseMap(){
        // Singleton Pattern for Re-Use
        if(userToLicenseMap != null){
            return userToLicenseMap;
        }

        userToLicenseMap = new Map<Id, copado.GlobalAPI.UserLicense>();
        copado.GlobalAPI copadoGlobalAPI = new copado.GlobalAPI();
        for(copado.GlobalAPI.UserLicense license : copadoGlobalAPI.listCopadoLicenses()){
            userToLicenseMap.put(license.userId,license);
        }

        return userToLicenseMap;
    }

    /**
    * @description Retrieve a map of Copado Licenses where isCCMenabled is true by User Id
    * @author Morgan Marchese @ Zoetis Inc | 03-09-2022 
    * @return Map<Id, copado.GlobalAPI.UserLicense> 
    **/
    @TestVisible
    private static Map<Id, copado.GlobalAPI.UserLicense> getActiveCCMLicensesByUserIdMap(){
        copado.GlobalAPI.UserLicense license;
        Map<Id, copado.GlobalAPI.UserLicense> activeLicenseByUserIdMap = new Map<Id, copado.GlobalAPI.UserLicense>();
        for(Id key : getUserIdToLicenseMap().keySet()){
            license = getUserIdToLicenseMap().get(key);
           
            if(license.isCCMenabled){
                activeLicenseByUserIdMap.put(license.userId,license);
            }
        }
        
        return activeLicenseByUserIdMap;
    }

    /**
    * @description Sets isCCMenabled on a User's Copado License to true or false as specified
    * @author Morgan Marchese @ Zoetis Inc | 03-09-2022 
    * @param userId 
    * @param isCCMEnabled 
    * @return copado.GlobalAPI.LicenseOperationResult 
    **/
    private static LicenseOperationResult modifyUserLicense(Id userId,Boolean isCCMEnabled){
        Map<Id, copado.GlobalAPI.UserLicense> userIdToLicenseMap = getUserIdToLicenseMap();
        
        // If the User has a current Copado License record, use that. Otherwise create a new instance of a License.
        // This prevents this logic from modifying anything other than CCM Access
        copado.GlobalAPI.UserLicense UL;
        Boolean existingLicense = false;
        if (userIdToLicenseMap.containsKey(userId)) {
            UL = userToLicenseMap.get(userId);
            existingLicense = true;
        }
        else {
            UL = new copado.GlobalAPI.UserLicense();
            UL.userId = userId;
        }

        UL.isCCMenabled = isCCMEnabled;

        copado.GlobalAPI copadoGlobalAPI = new copado.GlobalAPI();

        LicenseOperationResult result;
        Savepoint sp = Database.setSavePoint();
        try{
            // Force an exception in a Unit Test for code coverage
            if (Test.isRunningTest() && forceModifyLicenseError) {
                integer y = 1/0;
            }

            // Don't actually assign or revoke licenses in Unit Tests due to some sandboxes not having Copado licenses
            if (!Test.isRunningTest()) {
                // Users without the Customize Application Permission cannot update an existing license.
                // To avoid issues, the existing license will always be deleted. It will be recreated if the User has any remaining permissions
                if (existingLicense) {
                    result = createLicenseOperationResult(copadoGlobalAPI.deleteCopadoLicense(userId));
                }

                // Create, or recreate, the license if this is a new license or the deletion was a success
                // and there is at least one permission enabled.
                if ((!existingLicense || result.isSuccess) && 
                    (UL.isCADEnabled || UL.isCCHEnabled || UL.isCCMEnabled || UL.isCopadoEnabled || UL.isCSTEnabled)) {
                    result = createLicenseOperationResult(copadoGlobalAPI.upsertCopadoLicense(UL)?.isSuccess);
                }
            }
            else {
                userToLicenseMap.put(userId, UL);

                result = createLicenseOperationResult(true);
            }
        }
        catch (Exception e) {
            result = createLicenseOperationResult(false); 
        }

        // Rollback if something failed. Copado Global API still uses DML behind the scenes, so this can revert a partial save
        if (!result.isSuccess) {
            Database.rollback(sp);
        }
        
        return result;
    }
    
    /**
    * @description Returns the maximum number of Licenses that can be assigned before one should be released
    * @author Ethan Hirsch @ Zoetis Inc | 06-01-2022 
    * @return integer 
    **/
    private static integer getMaximumReleaseLicenseThreshold() {
        Decimal licenseThreshold = Copado_Global_API_Service_Setting__mdt.getInstance('DEFAULT')?.Release_License_Threshold__c;
        // If no Thereshold is specified or the Custom Metadata doesn't exist, return a default value of 10
        if (licenseThreshold == null) {
            return 10;
        }

        return licenseThreshold.intValue();
    }

    /**
    * @description Checks if the current User has an active Copado License where isCCMEnabled (Copado User) or
    *   isCopadoEnabled (Copado Admin) is true
    * @author Morgan Marchese @ Zoetis Inc | 03-09-2022 
    * @param userId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean checkLicense(Id userId){
        if(userId == null) return false;
        copado.GlobalAPI.UserLicense license = getUserIdToLicenseMap().get(userId);
        
        if(license != null){
            // Return true if the current user's license is enabled as a Copado User (isCCMEnabled)
            // or Admin User (isCopadoEnabled)
            if(license.isCCMEnabled || license.isCopadoEnabled){
                return true;
            }
        }
        return false;
    }

    /**
    * @description Revokes the Copado CCM license of an active Copado User.
    *  The User whose license is revoked is the User who was assigned a license the earliest.
    * @author Morgan Marchese @ Zoetis Inc | 03-09-2022 
    * @param userId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean releaseLicense(Id userId){
        Map<Id, copado.GlobalAPI.UserLicense> ccmLicensesByUserId = getActiveCCMLicensesByUserIdMap();
        if(ccmLicensesByUserId.size() <= getMaximumReleaseLicenseThreshold()){
            return true;
        }else {
            // Get oldest User by Copado License Assignment
            List<User> users = [
                                SELECT Id,Copado_Assignment_DateTime__c 
                                FROM User 
                                WHERE Id =: ccmLicensesByUserId.keySet() 
                                AND Copado_Persistent_License__c = false 
                                ORDER BY Copado_Assignment_DateTime__c,CreatedDate NULLS FIRST
                                LIMIT 1
            ];
            // Remove Oldest License since we're at capacity
            if (users[0].Copado_Assignment_DateTime__c != null) {
                users[0].Copado_Assignment_DateTime__c = null;
                update users[0];
            }
            
            result = modifyUserLicense(users[0].Id, false);
            if(result == null){
                return false;
            }

            return result.isSuccess;
        }
    }

    /**
    * @description Assigns the passed in User a CCM license for Copado
    * @author Morgan Marchese @ Zoetis Inc | 03-09-2022 
    * @param userId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean assignLicense(Id userId){

        // Assign License
        result = modifyUserLicense(userId, true);

        if (result.isSuccess) {
            User usr = new User(
                Id = userId,
                Copado_Assignment_DateTime__c = System.now()
            );

            update usr;
        }

        if(result == null){
            return false;
        }
        
        return result.isSuccess;
    }

    /**
        * @description Returns a LicenseOperationResult or null if null is passed in. 
                       This method simulates Copado returning a null and allows Unit Tests to return 
                       their own License Operation Result without using the Copado API
        * @author Ethan Hirsch @ Zoetis Inc | 06-01-2022 
        * @param result 
        * @return LicenseOperationResult 
    **/
    private static LicenseOperationResult createLicenseOperationResult(Boolean isSuccess) {
        if (isSuccess != null) {
            return new LicenseOperationResult(isSuccess);
        }

        return null;
    }

    // Override the License Operation Result for Unit Tests
    private class LicenseOperationResult {
        public Boolean isSuccess {get; private set;}

        public LicenseOperationResult(Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }
    }
}
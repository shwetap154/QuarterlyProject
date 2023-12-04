/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-15-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   07-01-2021   Morgan Marchese @ Zoetis Inc   Initial Version
**/
global class DistributorJITHandler implements Auth.SamlJitHandler {
    private final Integer maxUsernameLength = 80;
    private List<Contact> contactRecords;
    private List<User> userRecords;
    private Boolean hasContactId = false;
    private class JitException extends Exception{}
    private void handleUser(boolean create, User u, Map<String, String> attributes,
        String federationIdentifier, boolean isStandard) {
        String userFirstName;
        String userLastName;

        // All Distributor Users should be Content Users
        // Fixes issues with loading Content and Legal & Regulatory Files from Libraries
        u.UserPermissionsSFContentUser = true;
        
        if(attributes.containsKey('User.ProfileId')) {
            String profileId = attributes.get('User.ProfileId');
            Profile p = [SELECT Id FROM Profile WHERE Id=:profileId];
            u.ProfileId = p.Id;
        }
        if(attributes.containsKey('User.UserRoleId')) {
            String userRole = attributes.get('User.UserRoleId');
            UserRole r = [SELECT Id FROM UserRole WHERE Id=:userRole];
            u.UserRoleId = r.Id;
        }
        if(attributes.containsKey('User.Phone')) {
            u.Phone = attributes.get('User.Phone');
        }
        if(attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        }
        if(attributes.containsKey('User.FirstName')){
            userFirstName = attributes.get('User.FirstName');
            u.FirstName = userFirstName;
        }
        if(attributes.containsKey('User.LastName')){
            userLastName = attributes.get('User.LastName');
            u.LastName = userLastName;
        }

        if(create) {
            if(attributes.containsKey('User.Contact')) {
                String contactId = attributes.get('User.Contact');
                this.contactRecords = [SELECT Id,ZTS_EU_Market__c FROM Contact WHERE Id=:contactId];
                this.userRecords = [SELECT Id FROM User WHERE ContactId =: contactId];
            }
            // If there was a Matching User Record Found based on Contact, Update it with Federation Info instead.
            if(!this.userRecords.isEmpty()){
                u.Id = this.userRecords[0].Id;
            }else{
                u.ContactId = this.contactRecords[0].Id;
            }

            if(attributes.containsKey('User.Username')){
                String username = attributes.get('User.Username');
                username = generateUsername(username);
                u.Username = username;    
            }
            if(attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
            if(u.Id == null){
                u.LocaleSidKey = 'en_US';
                u.TimeZoneSidKey = 'GMT';
                u.LanguageLocaleKey = 'en_US';
                u.EmailEncodingKey = 'UTF-8';
                u.Alias = userFirstName.length() > 8 ? userFirstName.substring(0,7) : userFirstName;
            }
            
            if(!this.contactRecords.isEmpty()){
                u.ZTS_EU_Market__c = this.contactRecords[0].ZTS_EU_Market__c;
            }
        }

        if(create && u.Id == null){
            insert(u);
        }else if(create && u.Id != null){
            update(u);
        }else if(!create){
            update(u);
        }
    }
 
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        if(communityId != null || portalId != null) {
            //String account = handleAccount(create, u, attributes);
            //handleContact(create, account, u, attributes);
            handleUser(create, u, attributes, federationIdentifier, false);
        } else {
            handleUser(create, u, attributes, federationIdentifier, true);
        }
    }
 
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        System.debug('CreateUser');
        System.debug('samlProviderId: ' + samlSsoProviderId + ' commId: ' + communityId + ' portalId: ' + portalId + ' federationId: ' + federationIdentifier + ' attributes: ' + attributes + ' assertion: ' + assertion);
        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
        return u;
    }
 
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        System.debug('UpdateUser');
        System.debug('userId: ' + userId + ' samlProviderId: ' + samlSsoProviderId + ' commId: ' + communityId + ' portalId: ' + portalId + ' federationId: ' + federationIdentifier + ' attributes: ' + attributes + ' assertion: ' + assertion);
        User u = [SELECT Id FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
    }

    private String generateUsername(String username){
        Integer usernameLength = username.length();
        Integer remainingUsernameLength = this.maxUsernameLength - usernameLength;
        String[] usernameSplit = username.split('@');
        if(remainingUsernameLength >= 4){
            username = usernameSplit[0]+'+DST@'+usernameSplit[1];
        }
        return username;    
    }
}
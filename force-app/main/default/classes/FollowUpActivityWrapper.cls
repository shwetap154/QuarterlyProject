public with sharing class FollowUpActivityWrapper {
    @AuraEnabled
        public List<LookupSearchResultWrapper> owner {get;set;} // should only be a list of one, needs to be list for lookup lwc even with only a single entry
		public List<LookupSearchResultWrapper> followup {get;set;} // should only be a list of one, needs to be list for lookup lwc even with only a single entry
        @AuraEnabled
        public Id taskId {get;set;}

        @AuraEnabled
        public String subject {get;set;}

        @AuraEnabled
        public Date activityDate {get;set;}

        @AuraEnabled
        public String priority {get;set;}

        @AuraEnabled
        public String status {get;set;}
    
       

        public FollowUpActivityWrapper(Task t) {
            taskId = t.Id;
            subject = t.Subject;
            activityDate = t.ActivityDate;
            priority = t.Priority;
            status = t.Status;
            owner = new List<LookupSearchResultWrapper>();//Added for SC-008868
            followup = new List<LookupSearchResultWrapper>();//Added for SC-008868
            
        }
}
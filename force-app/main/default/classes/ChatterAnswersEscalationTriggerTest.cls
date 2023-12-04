@isTest
private class ChatterAnswersEscalationTriggerTest {
    
    @testVisible static final String QUESTION_UPD_INST_ERROR_ORIGIN = 'ChatterAnswersEscalationTriggerTest - validateQuestionEscalation(): insert and update Question';
    static testMethod void validateQuestionEscalation() {
        
        String questionTitle = 'questionTitle';
        String questionBody = 'questionBody';
        Community[] c = [SELECT Id from Community];
        // We cannot create a question without a community
        if (c.size() == 0) { return; }
        String communityId = c[0].Id;
        Question q = new Question();
        q.Title = questionTitle;
        q.Body = questionBody;
        q.CommunityId = communityId;
        insert(q);
        q.Priority = 'high';
        update(q);
        List<Case> cases = [SELECT Origin, CommunityId, Subject, Description from Case where QuestionId =: q.Id];
        System.assert(cases.size()>0,'A question should be escalated');
        Case ca = cases[0];
        // Test that escaltion trigger correctly escalate the question to a case
        System.assertEquals(questionTitle, ca.Subject,'Case subject should match question title');
        System.assertEquals(questionBody, ca.Description,'Case description should match question body');
        System.assertEquals('Chatter Answers', ca.Origin,'Case origin should be set from trigger');
        System.assertEquals(communityId, ca.CommunityId,'Case community should match question community');
        
        
    }
    
    @isTest
    static void testQuestionDeletion() {
        String questionTitle = 'questionTitle';
        String questionBody = 'questionBody';
        Community[] c = [SELECT Id from Community];
        // We cannot create a question without a community
        if (c.size() == 0) { return; }
        String communityId = c[0].Id;
        Question q = new Question();
        q.Title = questionTitle;
        q.Body = questionBody;
        q.CommunityId = communityId;
        insert(q);
        
        Test.startTest();
        	delete q; 
        Test.stopTest();
        
        List<Question> actualQuestion = [SELECT Id FROM Question WHERE Id = :q.Id];
        System.assertEquals(0, actualQuestion.size(), 'No question should be returned');
    }
    
    @isTest
    static void testQuestionDeletion_Failure() {
        String questionTitle = 'questionTitle';
        String questionBody = 'questionBody';
        Community[] c = [SELECT Id from Community];
        // We cannot create a question without a community
        if (c.size() == 0) { return; }
        String communityId = c[0].Id;
        Question q = new Question();
        q.Title = questionTitle;
        q.Body = questionBody;
        q.CommunityId = communityId;
        insert q;
        q.Priority = 'high';
        
        Integer invocationsBefore = Limits.getEmailInvocations();
        Test.startTest();
        	QuestionTriggerService.forceFailure = true;
        	update q;
       		Integer invocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();
        
        
        System.assertEquals(1, invocationsAfter-invocationsBefore, 'An email invocation should be called');
    }
}
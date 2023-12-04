/**
 * An apex page controller that exposes the site forgot password functionality
 */
@IsTest 
public with sharing class ForgotPasswordControllerTest {
	  
	@IsTest
	static void testForgotPasswordController() {
		Test.startTest();
    	// Instantiate a new controller with all parameters in the page
    	ForgotPasswordController controller = new ForgotPasswordController();
    	controller.username = 'test@salesforce.com';     	
    
		System.assertEquals(controller.forgotPassword(),null); 
		
		Test.stopTest();
    }
}
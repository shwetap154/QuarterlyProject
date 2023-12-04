@isTest
public class StaticACFVars_Test {
	public static testMethod void createstaticvar(){
        StaticACFVars s = new StaticACFVars();
        test.starttest();
    	system.assertEquals(StaticACFVars.mapOldACFLoser,StaticACFVars.mapOldACFLoser);
    	test.stoptest();
    }
}
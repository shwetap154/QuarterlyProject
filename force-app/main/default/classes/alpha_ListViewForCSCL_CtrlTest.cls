@isTest
public class alpha_ListViewForCSCL_CtrlTest {
    @isTest
    static void testMe(){
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Country__c='United Kingdom';
        acc.ZTS_EU_Zip_Postal_Code__c = '11111';
        insert acc;
        
        
        alpha_ListViewForCSCL_Ctrl.getIndustry();
        alpha_ListViewForCSCL_Ctrl.getMonth();
        alpha_ListViewForCSCL_Ctrl.getYear();
        alpha_ListViewForCSCL_Ctrl.filterOrds('7','2021',string.valueof(acc.id),'Draft');
        
    }

}
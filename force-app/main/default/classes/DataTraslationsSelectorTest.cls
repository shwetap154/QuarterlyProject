@istest
public class DataTraslationsSelectorTest {
    @istest
        private static void selectDataTransBySkill(){
                    List<Data_Translation__c> Dtlist = new List<Data_Translation__c>();
                    Data_Translation__c DataTraslations = new Data_Translation__c();
            DataTraslations.name='test';
            Dtlist.add(DataTraslations);
            insert DataTraslations;
       

            
        }

}
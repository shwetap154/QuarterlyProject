public class AccountProductPotentialHelper{
/*
 * Description  : This is used to calculate Account Product Potential
                  Product Account Potential= Product Potential * (Actual No. Of animals)from Account Species Consultation.
                  
                  It also sums up all the Product Account Potential to a field "Sum Of Product Account Potential"   
 * Created By   : Mamta Chintalapudi
 * Created Date : 2nd Feb 2015
 *
*/
   

 
 
  public static void calculateAndSumAccountProductPotential(List<ZTS_EU_Account_Product_Potential__c> accProdPotentialList,set<Id> ascIdList)
    
   { 
    
         Decimal prodPot;
         Decimal prodPotOld;
         
         //used Custom Label to store the no.of SKUs(Products) stamped on Account Product Potential
         Integer countOfSKUsStamped=Integer.valueOf(System.Label.No_of_SKUs_stamped_on_Account_Product_Potential);

         system.debug('******* List of Account Product Potential records taken from trigger******'+accProdPotentialList);
         
          // getting the actual #of animals from Account Species Consultation
         Map<Id, ZTS_EU_Account_Species_Potential__c> accountSpeciesMap = new Map<Id, ZTS_EU_Account_Species_Potential__c> ([select id,ZTS_EU_Animals_Consultations_actual__c from ZTS_EU_Account_Species_Potential__c where id = :ascIdList]);


         for(ZTS_EU_Account_Product_Potential__c app: accProdPotentialList)
         {
              //NC 17/02 changed re-initializing the sum to each APP record
              Decimal sumOfPotential=0.00;    
              for(integer i=1; i<=countOfSKUsStamped; i++)
                    {
                       //using sObject.get method and type casting it to get the Product Potential Value
                       prodPot=(Decimal)app.get('ZTS_EU_Product_Potential_'+i+'__c');
  
                       //using sObject.put method to put the multiplied value in Product Account Potential 
                       if(prodPot!=null && accountSpeciesMap!=null && accountSpeciesMap.get(app.Account_Species_Consultation__c)!=null && accountSpeciesMap.get(app.Account_Species_Consultation__c).ZTS_EU_Animals_Consultations_actual__c!=null)
                         {
                           app.put('PAC_'+i+'__c',prodPot*accountSpeciesMap.get(app.Account_Species_Consultation__c).ZTS_EU_Animals_Consultations_actual__c);
                         }
                       else if(prodPot==null)
                         {
                           app.put('PAC_'+i+'__c',null);
                         }
                        //summing up all the Product Account Potential_i if they are not null
                        if((Decimal)app.get('PAC_'+i+'__c')!=null)   
                         {
                           sumOfPotential = sumOfPotential+(Decimal)app.get('PAC_'+i+'__c');      
                         }
                    }
                 // using Sobject.put to put sum in ZTS_EU_Sum_Of_Product_Account_Potential__c field
                 if(sumOfPotential !=null)   
                  {
                   app.put('ZTS_EU_Sum_Of_Product_Account_Potential__c',sumOfPotential); 
                  } 
            } 
        }  
      }
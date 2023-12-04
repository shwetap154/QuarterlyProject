global class ZTS_EU_AccountRatingBatchWebservice
{
    webservice static void scheduleBatch() 
    { 
         ZTS_EU_BatchAccountRatingUpdate batchApex = new ZTS_EU_BatchAccountRatingUpdate();
         ID batchprocessId = Database.executeBatch(batchApex,100);
    }
}
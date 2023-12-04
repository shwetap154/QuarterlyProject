global class ZTS_EU_AccountRatPotClearBatchWebservice
{
    webservice static void scheduleBatch() 
    { 
         ZTS_EU_BatchAccountRatPotClear batchApex = new ZTS_EU_BatchAccountRatPotClear();
         ID batchprocessId = Database.executeBatch(batchApex,200);
    }
}
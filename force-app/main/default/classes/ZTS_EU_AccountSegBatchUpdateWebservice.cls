global class ZTS_EU_AccountSegBatchUpdateWebservice
{
    webservice static void UpdateBatch() 
    { 
        ZTS_EU_BatchASUpdate batchApex = new ZTS_EU_BatchASUpdate();
        ID batchprocessId = Database.executeBatch(batchApex,200);
    }
}
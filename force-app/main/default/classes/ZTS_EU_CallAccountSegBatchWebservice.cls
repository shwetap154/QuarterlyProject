global class ZTS_EU_CallAccountSegBatchWebservice
{
    webservice static void scheduleBatch() 
    { 
         ZTS_EU_BatchAccountSegmentationUpdate batchApex = new ZTS_EU_BatchAccountSegmentationUpdate();
         ID batchprocessId = Database.executeBatch(batchApex,200);
         
    }
}
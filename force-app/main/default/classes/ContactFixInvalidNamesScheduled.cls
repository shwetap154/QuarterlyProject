public Class ContactFixInvalidNamesScheduled implements Schedulable{
    /**
     * @description calling the execute method of batch process 
     * @param sc
     */
    public void execute(SchedulableContext sc) 
    {
      System.debug('Executing ContactFixInvalidNamesScheduled--->');
      ContactFixInvalidNamesBatch batch = new ContactFixInvalidNamesBatch();
      database.executebatch(batch);
    }
}
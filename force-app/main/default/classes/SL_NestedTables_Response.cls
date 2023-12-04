public class SL_NestedTables_Response
{
  public SL_NestedTables_ResponseWrapper[] recs;
  public SL_NestedTables_FieldObject[] fieldMap;
  public String sortDir;
  public String sortFld;
  public String errMsg;
  public Boolean createAccess;
  public String titledObjectName;

  public SL_NestedTables_Response(
      SL_NestedTables_ResponseWrapper[] recs,
      SL_NestedTables_FieldObject[] fieldMap,
      String sortDir,
      String sortFld,
      String errMsg,
      Boolean createAccess,
      String titledObjectName
  ) {
    this.recs = recs;
    this.fieldMap = fieldMap;
    this.sortDir = sortDir;
    this.sortFld = sortFld;
    this.errMsg = errMsg;
    this.createAccess = createAccess;
    this.titledObjectName = titledObjectName;
  }
}
public class SL_NestedTables_FieldObject
{
  public String label;
  public String apiName;
  public String fieldType;
  public Boolean isRef;
  public String lkupRelAPI;
  public String lookupFieldName;
  public String invalidField;

  public SL_NestedTables_FieldObject(
      String apiName,
      String label,
      String fieldType,
      Boolean isRef,
      String lkupRelAPI,
      String lookupFieldName,
      String invalidField
  ) {
    this.apiName = apiName;
    this.label = label;
    this.fieldType = fieldType;
    this.isRef = isRef;
    this.lkupRelAPI = lkupRelAPI;
    this.lookupFieldName = lookupFieldName;
    this.invalidField = invalidField; 
  }
}
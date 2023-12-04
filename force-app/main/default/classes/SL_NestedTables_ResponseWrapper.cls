/**
* Created by jerridkimball on 2018-06-07.
*/

public class SL_NestedTables_ResponseWrapper {
    SObject record;
    Integer relSize;
    
    public SL_NestedTables_ResponseWrapper(
        SObject record,
        Integer relLength ) {
            this.record = record;
            this.relSize = relLength;
        }
}
public class PaginationComponentController{

    public List<sObject> idList{get;set;}
    public List<String> SobjFieldList{get;set;}
  
    public List<sObject> getIdListRecords() {
       List<sObject> IdListRecrds =idList;
       return IdListRecrds;
    }
    
    public ApexPages.StandardSetController setOfRecords{
        get{
            if(setOfRecords == null){
            setOfRecords = new ApexPages.StandardSetController(getIdListRecords());
            setOfRecords.setPageSize(10);
        }  
        return setOfRecords;
        }set;
    }
    
    public List<sObject> getSObjectRecs(){
        List<sObject> sObjList = New List<sObject>();
        for(sObject SObj :(List<sObject>)setOfRecords.getRecords())
            sObjList.add(SObj); 
        return  sObjList ;   
    }
   
    public List<String> FieldList{
       get{
           List<String> FieldList = New List<string>();
           FieldList = getSobjtFieldList();
           return FieldList;
       }set;
    }
   
    
    
    public List<string> getSobjtFieldList() {
       List<String> FieldList = SobjFieldList;
       return FieldList ;
    }

}
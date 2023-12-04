public class USAccountWrapper{
    public Account account{get;set;}
    public Boolean isSelected {get;set;}
    
    public USAccountWrapper(Account acc, Boolean isSelected){
        this.account = acc;
        this.isSelected = isSelected;
    }
}
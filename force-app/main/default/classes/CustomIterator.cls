/*
    @@ Puropose: Custom Iterator for displaying AccountWrapper records in table with pagination. 
    @@ Author: Ilirjana Predojević
*/
public class CustomIterator implements Iterator<list<AccountWrapper>>
{ 
   private list<AccountWrapper> InnerList = new list<AccountWrapper>(); 
   public list<AccountWrapper> ListRequested{get; set;}

   public Integer i {get; set;} 
   public Integer pageSize {get; set;} 

   public CustomIterator(List<AccountWrapper> lstAccWr)
   {
       ListRequested = new list<AccountWrapper>();     
       InnerList = lstAccWr;
       pageSize = 10;
       i = 0; 
   }   

   public boolean hasNext(){ 
       try{
           if(i >= InnerList.size()) {
               return false; 
           } else {
               return true; 
           }
       }
       catch(exception e){
           system.debug('exMessage from hasNext '+e.getMessage());
           return null;
       }
   } 
   
   public boolean hasPrevious(){
       try{
           if(i <= pageSize) {
               return false; 
           } else {
               return true; 
           }
       }
       catch(exception e){
           system.debug('exMessage from hasPrevious '+e.getMessage());
           return null;
       }
   }   

   public list<AccountWrapper> next(){  
       ListRequested = new list<AccountWrapper>();
       try{
           integer startNumber;
           integer size = InnerList.size();
           if(hasNext())
           {  
               if(size <= (i + pageSize))
               {
                   startNumber = i;
                   i = size;
               }
               else
               {
                   i = (i + pageSize);
                   startNumber = (i - pageSize);
               }
               
               for(integer start = startNumber; start < i; start++)
               {
                   ListRequested.add(InnerList[start]);
               }
           } 
       }
       catch(exception e){
           system.debug('exMessage from next '+e.getMessage());
       }
       return ListRequested;
   } 
   
   public list<AccountWrapper> previous(){
       ListRequested = new list<AccountWrapper>(); 
       try{
           integer size = InnerList.size(); 
           if(i == size)
           {
               if(math.mod(size, pageSize) > 0)   
                   i = size - math.mod(size, pageSize);
               else
                   i = (size - pageSize);
           }
           else
               i = (i - pageSize);
           
           for(integer start = (i - pageSize); start < i; ++start)
           {
               ListRequested.add(InnerList[start]);
           } 
       }
       catch(exception e){
           system.debug('exMessage from previous '+e.getMessage());
       }
       return ListRequested;
   }   
    
   public list<AccountWrapper> first(){
       ListRequested = new list<AccountWrapper>(); 
       try{
           integer startNumber;
           integer size = InnerList.size(); 
           startNumber = 0;
           if(size <= pageSize)
               i = size;
           else
               i = pageSize;
           
           for(integer start = 0; start < i; start++)
           {
               ListRequested.add(InnerList[start]);
           }
       }
       catch(exception e){
           system.debug('exMessage from first '+e.getMessage());
       }
       return ListRequested;
   }
    
  public list<AccountWrapper> last(){ 
      ListRequested = new list<AccountWrapper>(); 
      try{
          integer startNumber;
          integer size = InnerList.size(); 
          i = size;
          
          if(size <= pageSize)
              startNumber = 0;
          
          else if (math.mod(size, pageSize) != 0) 
              startNumber = i - math.mod(size, pageSize);
          
          else
              startNumber = i - pageSize;
          
          for(integer start = startNumber; start < i; start++)
          {
              ListRequested.add(InnerList[start]);
          }
      }
      catch(exception e){
           system.debug('exMessage from last '+e.getMessage());
      }
      return ListRequested;
   } 
}
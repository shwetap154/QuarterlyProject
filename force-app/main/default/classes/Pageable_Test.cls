/*
    @@ Puropose: Test class for Pageable 
    @@ Author: Pavan Kumar
*/
@isTest 
public class Pageable_Test {
 
	//Test method for Pageable Class
	public static testMethod void Pageable_Test(){
		Pageable pg = new Pageable();
		integer PageIndex = pg.PageIndex;
		integer RecordCount=pg.getRecordCount();
		integer PageCount1 = pg.getPageCount();
		integer RecordCount1 = pg.RecordCount;
		integer PageCount = pg.PageCount;
		integer Offset = pg.Offset;
		integer LNumber = pg.LNumber;
		integer UNumber = pg.UNumber;
		boolean AllowMoveNext = pg.AllowMoveNext;
		boolean AllowMovePrev = pg.AllowMovePrev;
		pg.movePrev();
		pg.moveNext();
		pg.moveLast();
		pg.moveFirst();
	}
}
public class PDFGenCtrl {
 public String pdfFile {get; set;}
 public String benchmarkUrl {get; set;}
 
 public PageReference loadPageData(){
  //  HttpRequest req = new HttpRequest();
  //  HttpResponse res = new HttpResponse();
  //  Http http = new Http();
  //  req.setEndpoint('http://demo3599847.mockable.io/pdf-data');
  //  req.setMethod('GET');
  //  req.setHeader('Content-Type', 'application/json');
  //  try {
  //    res = http.send(req);
  //  } 
  //  catch(System.CalloutException e) {
  //    System.debug('Callout error: '+ e);
  //  }
  // pageData = getData();
   return null;
 }

 public void savePDF() {
    Id benchmarkId = [SELECT ID FROM Benchmark__c LIMIT 1].Id;
    Attachment objAttachment = new Attachment();
    objAttachment.Name = 'Test.pdf';
    objAttachment.parentId = benchmarkId;
    objAttachment.Body = Blob.valueOf(pdfFile);

    insert objAttachment;

    benchmarkUrl = new Pagereference(String.format('/{0}', new List<Object> {benchmarkId})).getUrl();
 }

  // Return a list of data points for a chart
// The actual chart data; needs to be static to be
// called by a @RemoteAction method
public static List<Data> getChartData() {
    List<Data> data = new List<Data>();
    data.add(new Data('Jan', 30, 90, 55));
    data.add(new Data('Feb', 44, 15, 65));
    data.add(new Data('Mar', 25, 32, 75));
    data.add(new Data('Apr', 74, 28, 85));
    data.add(new Data('May', 65, 51, 95));
    data.add(new Data('Jun', 33, 45, 99));
    data.add(new Data('Jul', 92, 82, 30));
    data.add(new Data('Aug', 87, 73, 45));
    data.add(new Data('Sep', 34, 65, 55));
    data.add(new Data('Oct', 78, 66, 56));
    data.add(new Data('Nov', 80, 67, 53));
    data.add(new Data('Dec', 17, 70, 70));
    return data;
}

// Wrapper class
public class Data {
    public String name { get; set; }
    public Integer data1 { get; set; }
    public Integer data2 { get; set; }
    public Integer data3 { get; set; }
    public Data(String name, Integer data1, Integer data2, Integer data3) {
        this.name = name;
        this.data1 = data1;
        this.data2 = data2;
        this.data3 = data3;
    }
}
}
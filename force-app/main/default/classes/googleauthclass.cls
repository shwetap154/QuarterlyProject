public class googleauthclass{
public Attachment myfile;
    public Attachment getmyfile() {
    myfile = new Attachment();
    return myfile;
    }
    public id folderid;
public string authtoken{get;set;}
public string refereshtoken{get;set;}
public string bodyprint{get;set;}
public string accessToken{get;set;}

//Settings needed on the google cloud console.One can store this securely in custom settings or an object.

public static final string CLIENT_SECRET='RAIpAmMXex5vXtZ4bZx5sYRY';//Fill as per your registered app settings in google console
public static final string CLIENT_ID='196048821117-8ogisjtr345j39o7cf8j0aoj3lis0d2h.apps.googleusercontent.com';//Fill as per your registered app settings in google console
public static final string REDIRECT_URL='https://pramodreddy-dev-ed--c.ap4.visual.force.com/apex/google';

public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
public static final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';

public static final string GRANT_TYPE='grant_type=authorization_code';

//Scope URL as per oauth 2.0 guide of the google 
//public static final string SCOPE='https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile';
public static final string SCOPE= 'https://www.googleapis.com/auth/drive.file';
public static final string STATE='/profile';

//Approval Prompt Constant
public static final string APPROVAL_PROMPT='force';




   public pagereference connect(){
   
     String x=OAUTH_CODE_END_POINT_URL+'?scope='+EncodingUtil.urlEncode(SCOPE,'UTF-8')+'&state='+EncodingUtil.urlEncode(STATE,'UTF-8')+'&redirect_uri='+EncodingUtil.urlEncode(REDIRECT_URL,'UTF-8')+'&response_type=code&client_id='+CLIENT_ID+'&approval_prompt='+APPROVAL_PROMPT;
     
     pagereference p=new pagereference(x);
          
     return p;
     
   }
   
    public pagereference showtoken(){
   
   string codeparam=apexpages.currentpage().getparameters().get('code');

      
            // Instantiate a new http object
    Http h = new Http();
    
    String body='code='+codeparam+'&client_id='+CLIENT_ID+'&client_secret='+CLIENT_SECRET+'&redirect_uri='+REDIRECT_URL+'&'+GRANT_TYPE;
    
// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(OAUTH_TOKEN_URL);
    req.setHeader('Content-Type','application/x-www-form-urlencoded');
    req.setMethod('POST');
    req.setBody(body);
    
    system.debug('REQUEST BODY'+body);

// Send the request, and return a response
    HttpResponse res = h.send(req);
    
    system.debug('body'+res.getbody());
    
    map<String,String> bodyprint=(map<String,String>) JSON.deserialize(res.getBody(), MAP<String,String>.CLASS);
        accessToken= bodyprint.get('access_token');
                 return null;   
   }
    
   public  void save(){
    folderid=UserInfo.getUserId();
   Blob file=myfile.Body;
   String fileName=myfile.Name;
   String fileType='myfile.type'; 
   String boundary = '----------9889464542212';
   String delimiter = '\r\n--' + boundary +'\r\n';
   String close_delim = '\r\n--' + boundary + '--';
   String bodyEncoded = EncodingUtil.base64Encode(file);
   String body=delimiter+'Content-Type: application/json\r\n\r\n'+'{ "title" : "'+ filename+'",'+' "mimeType" : "'+ filetype+ '", "parents" : [{"id" : "'+folderid+'"}]}'+delimiter+'Content-Type: ' + filetype + '\r\n'+'Content-Transfer-Encoding: base64\r\n'+'\r\n'+bodyEncoded+close_delim;
   System.debug('body' + body);
   Http http = new Http();
   HttpRequest req = new HttpRequest();
   req.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=media');
   req.setHeader('Authorization', 'Bearer ' +accessToken);
   req.setHeader('Content-Type', 'image/jpeg');
   req.setHeader('Content-length', String.valueOf(body.length()));
   req.setBody(body);
   req.setMethod('POST');
   HttpResponse resp = http.send(req);
   string body1=resp.getbody();
    system.debug('Body1----------> '+body1);
   }
  
}
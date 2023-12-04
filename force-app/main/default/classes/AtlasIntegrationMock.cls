/****************************************************************************************************************************************** 
 * Class Name : AtlasIntegrationMock
 * Description  : All Trigger Test Logic for AtlasIntegrationHelper.
 * Created By   : Slalom(Neil Kapoor) 
 * Created Date : 28th October, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Neil Kapoor          10/28/2021             Created 
 
*****************************************************************************************************************************************/
@IsTest
global class AtlasIntegrationMock implements HttpCalloutMock
{
    private static final String CREATE_PET_OWNER_URI = '/2.0/third-party/identities/';
    private static final String CREATE_PET_URI = '/2.0/third-party/pets/';
    protected String body;
    protected Integer statusCode;
    
    global AtlasIntegrationMock( Integer statusCode, String body )
    {
        this.body = body;
        this.statusCode = statusCode;
    }

    global HttpResponse respond( HttpRequest theRequest )
    {
        HttpResponse theResponse = new HttpResponse();
        theResponse.setHeader( 'Content-Type', 'application/json' );
        theResponse.setStatusCode( this.statusCode );

        theResponse.setBody( this.body );

        return theResponse;
    }
}
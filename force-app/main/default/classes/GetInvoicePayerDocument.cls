/**
* File Name     :  GetInvoicePayerDocument
* Description   :           
* @author       :  Sourav Mitra @ CTS - Cognizant Technology Solutions
				   Indranil Deria @ CTS - Cognizant Technology Solutions
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     4/26/2023     Sourav Mitra     	    Created the Class and added methods.
*/

public class GetInvoicePayerDocument {
    
public static String doRequest(GetInvoiceRequest reqObject) {
		
		// Get configuration from Custom setting
    	Vistex_Configuration__c invoiceDoc = Vistex_Configuration__c.getOrgDefaults();
    	   
    	Http http = new Http();
		HttpRequest request = new HttpRequest();

		/* Apply configuration from: 
		 *  - Named Createntials: root endpoint, authorization header (method and credentials) and certificate
		 *  - Custom Setting: endpoint relative path, timeout, retries
		 */
		
    	request.setEndpoint('callout:Zoetis_SAP_PI_Endpoint/' + invoiceDoc.Invoice_Endpoint_Relative_Path__c);
    	
    	request.setTimeout(invoiceDoc.Response_time_out__c.intValue());
		request.setMethod('POST');
		//System.debug('DEBUG Endpoint ***'+invoiceDoc.Invoice_Endpoint_Relative_Path__c);
		// Set json object payload
		request.setHeader('Accept', 'application/json');
    	System.debug('Request Sent ***' + request);
		request.setBody(JSON.serialize(reqObject));
  		System.debug('Request Sent ***' + reqObject);
		System.debug('Invoice Request: ' + request);
	
        HttpResponse response;
		Integer attempt = 0;
		Integer retryLimit = invoiceDoc.Retry_Times__c.intValue();
		
		while (attempt < retryLimit) {
			
			try {
				attempt++;
				System.debug('GetInvoicePayerDocument - Attempt: ' + attempt + ' of ' + retryLimit);

				// Perform callout and set response
				response = http.send(request);

				System.debug('GetInvoicePayerDocumentResponse - Vistex Response: ' + response);

				// check response 
				if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && !String.isBlank(response.getBody())) {
           			System.debug('Invoice Response Body *** ' + response.getBody());
                    return response.getBody();
				}
				else {
					System.debug(LoggingLevel.WARN, 'GetInvoicePayerDocumentCallout - Callout failed. Status: ' + response.getStatusCode() + ' - ' + response.getStatus());
					response.setBody('');
                    ErrorLogUtil.log('GetInvoicePayerDocumentCallout > Callout failed. Status: ' + response.getStatusCode() + ' - ' + response.getStatus(), new List<String>{ 'Request payload: ' + JSON.serialize(reqObject) });
                    System.debug('Sending response for error ***'+response.getBody());
                    return response.getBody();
				}
			}
			catch (Exception e) {
				System.debug(LoggingLevel.ERROR, 'An error has occurred on GetInvoice Callout: ' + e.getMessage());
				ErrorLogUtil.log('GetInvoicePayerDocumentCallout > An error has occurred on GetInvoice Callout. Attempt ' + attempt + ' of ' + retryLimit, e);
			}
		
		}

		ErrorLogUtil.commitLogs();

		System.debug(LoggingLevel.WARN, 'GetInvoicePayerDocumentCallout - Retry limit was reached: ' + retryLimit);
		return '';
    }
   
}
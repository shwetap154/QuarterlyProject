/**
* File Name     :  VistexPricingServiceCallout
* Description   :           
* @author       :  Cesar Sandrigo @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/19         Cesar Sandrigo @ ATG     Created the Class.
* 1.1	  7/01		   Cesar Sandrigo @ ATG 	Removed method related to debugging.
*/
public class VistexPricingServiceCallout {
	
	/**
	 * @description Main method. Does the HTTP call to Vistex using confired values.
	 * @param requestObj request object to be converted to JSON and passed in the request payload.
	 * @returns Response JSON String.
	 */
    public static String doRequest(VistexPricingRequest requestObj) {

		// Get configuration from Custom setting
		Vistex_Configuration__c vistexConfig = Vistex_Configuration__c.getOrgDefaults();

		System.debug('VistexPricingServiceCallout - Configuration: ' + vistexConfig);

    	Http http = new Http();
		HttpRequest request = new HttpRequest();

		/* Apply configuration from: 
		 *  - Named Createntials: root endpoint, authorization header (method and credentials) and certificate
		 *  - Custom Setting: endpoint relative path, timeout, retries
		 */
		request.setEndpoint('callout:Zoetis_SAP_PI_Endpoint/' + vistexConfig.Endpoint_Relative_Path__c);
		request.setTimeout(vistexConfig.Response_time_out__c.intValue());
		request.setMethod('POST');

		// Set json object payload
		request.setHeader('Accept', 'application/json');
		request.setBody(JSON.serialize(requestObj));
		
		System.debug('Vistex Request: ' + request);
	
        HttpResponse response;
		Integer attempt = 0;
		Integer retryLimit = vistexConfig.Retry_Times__c.intValue();

		while (attempt < retryLimit) {
			
			try {
				attempt++;
				System.debug('VistexPricingServiceCallout - Attempt: ' + attempt + ' of ' + retryLimit);

				// Perform callout and set response
				response = http.send(request);

				System.debug('VistexPricingServiceCallout - Vistex Response: ' + response);

				// check response 
				if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && !String.isBlank(response.getBody())) {
					return response.getBody();
				}
				else {
					System.debug(LoggingLevel.WARN, 'VistexPricingServiceCallout - Callout failed. Status: ' + response.getStatusCode() + ' - ' + response.getStatus());
					ErrorLogUtil.log('VistexPricingServiceCallout > Callout failed. Status: ' + response.getStatusCode() + ' - ' + response.getStatus(), new List<String>{ 'Request payload: ' + JSON.serialize(requestObj) });
				}
			}
			catch (Exception e) {
				System.debug(LoggingLevel.ERROR, 'An error has occurred on Vistex Callout: ' + e.getMessage());
				ErrorLogUtil.log('VistexPricingServiceCallout > An error has occurred on Vistex Callout. Attempt ' + attempt + ' of ' + retryLimit, e);
			}
			/* HACK:
			 *  - Wait before to retry, increase the time on each iteration
			*/	
		}

		ErrorLogUtil.commitLogs();

		System.debug(LoggingLevel.WARN, 'VistexPricingServiceCallout - Retry limit was reached: ' + retryLimit);
		return '';
    }

	private static void checkVistexConfiguration(Vistex_Configuration__c vistexConfig) {
	}
}
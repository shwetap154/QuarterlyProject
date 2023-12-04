hideShowInit(); // calling function to hide/show input box
var initESW = function(gslbBaseURL) {
	
	embedded_svc.settings.displayHelpButton = true; //Or false
	embedded_svc.settings.language = 'en-US'; //For example, enter 'en' or 'en-US'

	embedded_svc.settings.defaultMinimizedText = 'Chat with us'; //(Defaults to Chat with an Expert)
	// use 'https://site endpoint + /resource/*static resource number*/*static resource name*';
	embedded_svc.settings.chatbotAvatarImgURL = 'https://zoetis-us.secure.force.com/zoey/resource/BotIcon40px';


	//embedded_svc.settings.disabledMinimizedText = '...'; //(Defaults to Agent Offline)

	//embedded_svc.settings.loadingText = ''; //(Defaults to Loading)
	//embedded_svc.settings.storageDomain = 'yourdomain.com'; //(Sets the domain for your deployment so that visitors can navigate subdomains during a chat session)

	// Settings for Chat
	//embedded_svc.settings.directToButtonRouting = function(prechatFormData) {
		// Dynamically changes the button ID based on what the visitor enters in the pre-chat form.
		// Returns a valid button ID.
	//};
	//embedded_svc.settings.prepopulatedPrechatFields = {}; //Sets the auto-population of pre-chat form fields
	//embedded_svc.settings.fallbackRouting = []; //An array of button IDs, user IDs, or userId_buttonId
	//embedded_svc.settings.offlineSupportMinimizedText = '...'; //(Defaults to Contact Us)

	embedded_svc.settings.enabledFeatures = ['LiveAgent'];
	embedded_svc.settings.entryFeature = 'LiveAgent';

	embedded_svc.init(
			'https://touchpointeca.my.salesforce.com',
			'https://zoetis-us.secure.force.com/zoey',
			gslbBaseURL,
			'00DF00000005zmy',
			'Zoey_Embedded_Service_Deployment',
			{
				baseLiveAgentContentURL: 'https://c.la3-c1-ia5.salesforceliveagent.com/content',
				deploymentId: '5724z0000004D2f',
				buttonId: '5734z0000004DIW',
				baseLiveAgentURL: 'https://d.la3-c1-ia5.salesforceliveagent.com/chat',
				eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I4z0000008OItEAM_1838bf85b4c',
				isOfflineSupportEnabled: false
			}
		);
	};

	if (!window.embedded_svc) {
		var s = document.createElement('script');
		s.setAttribute('src', 'https://touchpointeca.my.salesforce.com/embeddedservice/5.0/esw.min.js');
		s.onload = function() {
			initESW(null);
		};
		document.body.appendChild(s);
	} else {
		initESW('https://service.force.com');
	}
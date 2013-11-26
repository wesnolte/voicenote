// Landing page to try and identify the caller.

public class TwilioLandingController {
	
	public static Map<String, String> params;
	public static Twilio_Call__c twiCall;
	public static string BASE_URL = getHttpsSalesforceBaseURL();


	public TwilioLandingController() {
		params = System.ApexPages.CurrentPage().getParameters();
	}


	/* 
	initTwiml()
	Called by apex:page action. Creates a updates/creates a Twilio_Call__c record. 
	*/
	public static void initTwiml() {
		//get call log
		if(params.containsKey('CallSid')) {
			List<Twilio_Call__c> callLi = [SELECT Id, Caller__c, CallSid__c, Input__c, Status__c, User__c, User_First_Name__c, User_Last_Name__c
											FROM Twilio_Call__c
											WHERE CallSid__c = :params.get('CallSid')];

			if(callLi.isEmpty()) {
				twiCall = initTwilioCall(params);

			} else if (callLi.size() == 1) {
				twiCall = callLi[0];
				// make sure it has latest info...
				updateTwilioCall(params);

			} else {
				//hmmm something went wrong - CallSid should always be unique. 
				// handling tbd.
			}
		} else {
			// something else went wrong - call should always have a CallSid;
			// handling tbd.
		}
	}




	/* 
	getTwiml()
	Renders XML document on page, based on supplier 'status' parameter (passed as query param in url) 
	*/	
	public string getTwiml() {

		TwilioTwiML.Response r = new TwilioTwiML.Response();
		

		/****** Initial Greeting ********/

		if(!params.keySet().contains('status')) {
			if(twiCall.User__c != null) {
				return TwilioResponseBuilder.initKnownCaller(r, twiCall);
			} else {
				return TwilioResponseBuilder.initUnknownCaller(r);
			}
		}


		/****** Known Caller Actions: ********/

		if (params.get('status') == TwilioResponseBuilder.INIT_KNOWN_CALLER) {
			return TwilioResponseBuilder.optionKnownCaller(r);
		} 

		if(params.get('status') == TwilioResponseBuilder.KNOWN_CALLER_OPTION_CHOOSER) {
			
			if(twiCall.Input__c == '1') {
				return TwilioResponseBuilder.taskVoiceNote(r);
			} else if (twiCall.Input__c == '2') {
				return TwilioResponseBuilder.storyTime(r, twiCall);
			} else {
				return TwilioResponseBuilder.optionError(r, twiCall);
			}

		} 


		/****** Uknown Caller Actions: ********/

		if(params.get('status') == TwilioResponseBuilder.UNKNOWN_CALLER_OPTION_CHOOSER) {
			if(twiCall.Input__c == '1') {
				return TwilioResponseBuilder.manualUserIdentify(r);
			} else {
				return TwilioResponseBuilder.optionError(r, twiCall);

			}

		} 

		if(params.get('status') == TwilioResponseBuilder.MANUAL_IDENTIFY_USER){

			if(twiCall.User__c != null) {
				//found user, ask them to confirm
				return TwilioResponseBuilder.confirmIdentity(r, twiCall);
			} else {
				return TwilioResponseBuilder.unableToIdentifyError(r);
			}

		} 

		if(params.get('status') == TwilioResponseBuilder.CONFIRM_IDENTITY_OPTION_CHOOSER) {

			if(twiCall.Input__c == '1') {
				return TwilioResponseBuilder.optionKnownCaller(r);
			} else {
				return TwilioResponseBuilder.unableToIdentifyError(r);
			}

		} else {
			return null;
		}

	}



	/****** Helpers ********/
	// tbd - put in util class

	private static Twilio_Call__c initTwilioCall(Map<String,String> incParams) {
		
		Twilio_Call__c newTwiCall = new Twilio_Call__c();		
		newTwiCall.CallSid__c = incParams.get('CallSid');
		newTwiCall.Status__c = 'initial';
		if(incParams.containsKey('Caller')) { 
			newTwiCall.Caller__c = incParams.get('Caller');
			// try and link to User
			List<User> userLi = [SELECT Id, Name, FirstName, LastName, Phone FROM User WHERE Phone = :params.get('Caller')];
			if(!userLi.isEmpty() && userLi.size() == 1) {
				newTwiCall.User_Name__c = userLi[0].Name;
				newTwiCall.User_First_Name__c = userLi[0].FirstName;
				newTwiCall.User_Last_Name__c = userLi[0].LastName;
				newTwiCall.User__c = userLi[0].Id;
			}
		}

		try { 
			insert newTwiCall;
			return newTwiCall;
		} catch (Exception e) {
			System.debug('Error inserting Twilio_Call__c from initTwilioCall: ' + e);
			return null;
		}
	}


	private static Twilio_Call__c updateTwilioCall(Map<String, String> incParams) {

		if(params.containsKey('Digits')) { twiCall.Input__c = params.get('Digits'); }

		if(params.containsKey('status')) { 
			twiCall.Status__c = params.get('status'); 
			if(twiCall.Status__c == TwilioResponseBuilder.MANUAL_IDENTIFY_USER) {
				// try and link to user
				linkToUserFromInput();
			}
		}

		//tbd make more intelligent so only updates if there has been change.
		update twiCall;
		return twiCall;

	}

	private static Twilio_Call__c linkToUserFromInput() {

		List<User> userLi = [SELECT Id, Name, FirstName, LastName 
							 FROM User 
							 WHERE NameToKeypad__c = :twiCall.Input__c]; // bit sloppy. assuming this is only called at correct point. not versatile.
		if(!userLi.isEmpty() && userLi.size() == 1) {
			twiCall.User_Name__c = userLi[0].Name;
			twiCall.User_First_Name__c = userLi[0].FirstName;
			twiCall.User_Last_Name__c = userLi[0].LastName;
			twiCall.User__c = userLi[0].Id;
		}

		return twiCall;

	}

  //by default the url is returned with http not https. twilio only accepts https.
   private static String getHttpsSalesforceBaseURL(){
      String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
      if (baseURL.startsWith('http:')){
        baseURL = baseURL.replaceFirst('http:', 'https:');
      } 
      return baseURL;
    }

}
// Landing page to try and identify the caller.

public class TwilioLandingController {
	
	public static Map<String, String> params;
	public static  User caller;
	public static string BASE_URL = getHttpsSalesforceBaseURL();


	public TwilioLandingController() {
		params = System.ApexPages.CurrentPage().getParameters();
		caller = identifyCaller(params);

		/***for debug only***/
		for(String key : params.keySet()) {
			System.debug(key + '-->' + params.get(key));
		}
		/********************/
	}
		

	public string getTwiml() {

		System.debug('STATUS: ' + params.get('status'));

		TwilioTwiML.Response r = new TwilioTwiML.Response();


		// INITIAL GREETING
		if(!params.keySet().contains('status')) {
			if(caller != null) {
				return TwilioResponseBuilder.initKnownCaller(r, caller);
			} else {
				return TwilioResponseBuilder.initUnknownCaller(r);
			}
		}



		// KNOWN CALLER ACTIONS
		if (params.get('status') == TwilioResponseBuilder.INIT_KNOWN_CALLER) {
			return TwilioResponseBuilder.optionKnownCaller(r);
		} 

		if(params.get('status') == TwilioResponseBuilder.KNOWN_CALLER_OPTION_CHOOSER) {
			String input = params.get('Digits');

			if(input == '1') {
				return TwilioResponseBuilder.taskVoiceNote(r, caller);
			} else if (input == '2') {
				return TwilioResponseBuilder.storyTime(r, caller);
			} else {
				return TwilioResponseBuilder.optionError(r, caller, input, params.get('status'));
			}

		} 


		// UNKNOWN CALLER ACTIONS

		if(params.get('status') == TwilioResponseBuilder.UNKNOWN_CALLER_OPTION_CHOOSER) {
			String input = params.get('Digits');
			if(input == '1') {
				return TwilioResponseBuilder.manualUserIdentify(r);
			} else {
				return TwilioResponseBuilder.optionError(r, caller, input, params.get('status'));
			}

		} 

		if(params.get('status') == TwilioResponseBuilder.MANUAL_IDENTIFY_USER){
			
			//System.debug('entered manual identify');
			String input = params.get('Digits');
			//try and find user
			caller = manualIdentifyCaller(input);
			//System.debug('this is the user:' + caller);

			if(caller != null) {
				//found user, ask them to confirm
				System.debug('calling confirm user');
				return TwilioResponseBuilder.confirmIdentity(r, caller);
			} else {
				return TwilioResponseBuilder.unableToIdentifyError(r);
			}

		} 

		if(params.get('status') == TwilioResponseBuilder.CONFIRM_IDENTITY_OPTION_CHOOSER) {

			System.debug('entered confirm identity');

			String input = params.get('Digits');
			System.debug('Digits: ' + params.get('Digits'));
			System.debug('Caller: ' + caller);

			if(input == '1') {
				if()
				//return TwilioResponseBuilder.initKnownCaller(r, caller);
				return TwilioResponseBuilder.optionKnownCaller(r);
			} else {
				return TwilioResponseBuilder.unableToIdentifyError(r);
			}
		

		} else {
			return null;
		}

	}



	// Helpers //

	private static User identifyCaller(Map<String, String> incparams){
	    if(params.containsKey('Caller') && (params.get('Caller') != null)) {
	        List<User> userLi = [SELECT Id, Name, FirstName, Phone FROM User WHERE Phone = :params.get('Caller')];
	        if(userLi.size() == 1) {
	          return userLi[0];
	        } else {
	          return null;
	        }
	    } else {
	      return null;
	    }
	}

	private static User manualIdentifyCaller(String input) {

		// searches user based on custom formula field that has alread
		// performed the translation from text to numbers
		List<User> userLi = [SELECT Id, Name, FirstName FROM User WHERE NameToKeypad__c = :input];
        if(userLi.size() == 1) {
          return userLi[0];
        } else {
          return null;
        }
	}
  

  //by default the url is returned with http not https. twilio only accepts https.
   public static String getHttpsSalesforceBaseURL(){
      String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
      if (baseURL.startsWith('http:')){
        baseURL = baseURL.replaceFirst('http:', 'https:');
      } 
      return baseURL;
    }


}
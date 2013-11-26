@RestResource(urlMapping = '/transcriptionhandler')

global class TranscriptionHandler {

	// POST	//
	@HttpPost

	global static void doPost() {

		System.debug('doPost');

		Map<String, String> params = RestContext.request.params;
		


		/* debug only */
		for(String s : params.keySet()) {
			System.debug(s + ' -> ' + params.get(s));
		}
		/**************/

		RestResponse res = RestContext.response;

		try { 
		 	createTask(params);
		} catch (Exception e) {
			res.responseBody = Blob.valueOf(e.getMessage());
		}

		res.responseBody = Blob.valueOf('OK');


	}

	private static void createTask(Map<String, String> params) {

		User u = [SELECT Id FROM User WHERE Phone = :params.get('Caller')];

		Task t = new Task();
		t.OwnerId = u.Id;
		t.Description = params.get('TranscriptionText') + '\n\n Click here to listen to the call: https://api.twilio.com/2010-04-01/Accounts/' + params.get('AccountSid') + '/Recordings/' + params.get('RecordingSid');
		//t.Phone = params.get('Caller');
		t.Subject = 'Voice recording from Twilio at ' + datetime.now();

		try {
			insert t;
		} catch(Exception e) {
			System.debug('Error inserting Twilio transcription task: ' + e);
		}

	}






}
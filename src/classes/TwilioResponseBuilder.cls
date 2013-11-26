public class TwilioResponseBuilder {


	public static string STATUS = '?status=';
	public static string INIT_KNOWN_CALLER = 'init_knowncaller';
	public static string INIT_UNKNOWN_CALLER = 'init_unknowncaller';
	public static string KNOWN_CALLER_OPTION_CHOOSER = 'known_option_chooser';
	public static string UNKNOWN_CALLER_OPTION_CHOOSER = 'unknown_option_chooser';
	public static string MANUAL_IDENTIFY_USER = 'manual_identify_user';
	public static string CONFIRM_IDENTITY_OPTION_CHOOSER = 'confirm_identity_option_chooser';


	public static String initKnownCaller(TwilioTwiML.Response r, User caller) {
		r.append(new TwilioTwiML.Say('Hello ' + caller.Name));
		TwilioTwiML.Redirect redirect = new TwilioTwiML.Redirect(TwilioLandingController.BASE_URL+STATUS+INIT_KNOWN_CALLER);
		r.append(redirect);
		return r.toXML();
	}

	public static String initUnknownCaller(TwilioTwiML.Response r) {
		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setNumDigits(1);
		g.setAction(TwilioLandingController.BASE_URL+STATUS+UNKNOWN_CALLER_OPTION_CHOOSER);
		g.append(new TwilioTwiML.Say('I do not recognise the number you are calling from. Press 1 to try and identify yourself, otherwise please hang up.'));
		r.append(g);

		return r.toXML();	
	}

	public static String optionKnownCaller(TwilioTwiML.Response r) {
		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setNumDigits(1);
		g.setAction(TwilioLandingController.BASE_URL+STATUS+KNOWN_CALLER_OPTION_CHOOSER);
		g.append(new TwilioTwiML.Say('Press 1 to record a voice note. Press 2 to hear a story.'));
		r.append(g);
		return r.toXML();
	}


	public static String manualUserIdentify(TwilioTwiML.Response r) {

		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setFinishOnKey('#');
		g.setAction(TwilioLandingController.BASE_URL+STATUS+MANUAL_IDENTIFY_USER);
		g.append(new TwilioTwiML.Say('Ok, lets do this! Please type in your name on the numeric keypad, in the same way you would type an SMS message. Press the hash key when you are finished.'));
		r.append(g);
		return r.toXML();

	}

	public static String confirmIdentity(TwilioTwiML.Response r, User caller) {

		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setNumDigits(1);
		g.setAction(TwilioLandingController.BASE_URL+STATUS+CONFIRM_IDENTITY_OPTION_CHOOSER);//+USERID+caller.Id);
		g.append(new TwilioTwiML.Say('I have identified you as ' + caller.Name +'. If this is correct, press 1, otherwise, please press 2'));
		r.append(g);

		return r.toXML();

	}

	public static String taskVoiceNote(TwilioTwiML.Response r, User caller) {

		TwilioTwiML.Record rec = new TwilioTwiML.Record();
		rec.setMaxLength(120); // sets to 120 seconds - the maximum length for transcription
		rec.setTranscribe(true);
		rec.setTranscribeCallback(TwilioLandingController.BASE_URL+'/services/apexrest/transcriptionhandler');
		rec.setMethod('POST');

		r.append(new TwilioTwiML.Say('Please leave a message after the beep. When finished, you may hang up.'));
		r.append(rec);
		return r.toXML();

	}

	public static String storyTime(TwilioTwiML.Response r, User caller) {
		r.append(new TwilioTwiML.Say(caller.FirstName + ', I don\'t have time to tell a story right now. Don\'t you have better things to be doing? Goodbye'));
		return r.toXML();
	}

	public static String optionError(TwilioTwiML.Response r, User caller, String invalidChoice, String currentStatus) {

		r.append(new TwilioTwiML.Say(caller.FirstName + ', ' + invalidChoice + ' was not an option. Returning you to the previous menu.'));

		if(currentStatus == KNOWN_CALLER_OPTION_CHOOSER) {
			return optionKnownCaller(r);
		} else if (currentStatus == UNKNOWN_CALLER_OPTION_CHOOSER) {
			return null;
		} else {
			return null;
		}
	}


	public static String unableToIdentifyError(TwilioTwiML.Response r) {

		r.append(new TwilioTwiML.Say('Sorry, I am unable to identify you. Please hang up'));
		return r.toXML();
	}

}
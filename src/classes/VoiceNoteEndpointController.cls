public with sharing class VoiceNoteEndpointController {


  private Map<String, String> statusCallback;
  private Static String CALL_DURATION = 'CallDuration';
  private Static String CALL_SID = 'CallSid';
  public Static User theCaller;

  
	public VoiceNoteEndpointController() {
    statusCallback = System.ApexPages.CurrentPage().getParameters();
    for(String key: statusCallback.keyset()){
      System.debug(key + '::' + statusCallback.get(key));
    }

    theCaller = identifyCaller(statusCallback);

	}


  public String getTwiml() {

    TwilioTwiML.Response r = new TwilioTwiML.Response();

    if(theCaller == null) {
      r.append(new TwilioTwiML.Say('Hello Stranger. Unfortunately I do not know who you are, so you are unable to leave a message.'));
    } else {
      TwilioTwiML.Record rec = new TwilioTwiML.Record();
      rec.setMaxLength(120); // sets to 120 seconds - the maximum length for transcription
      rec.setTranscribe(true);
      rec.setTranscribeCallback(getHttpsSalesforceBaseURL()+'/services/apexrest/transcriptionhandler');
      
      rec.setMethod('POST');

      r.append(new TwilioTwiML.Say('Hello ' + theCaller.Name + '. Please leave a recording.'));
      r.append(rec);
    }
    System.debug(r.toXML());
    return r.toXML();
  } 



  private static User identifyCaller(Map<String, String> statusCallback){

    if(statusCallback.containsKey('Caller') && (statusCallback.get('Caller') != null)) {
        List<User> userLi = [SELECT Id, Name FROM User WHERE Phone = :statusCallback.get('Caller')];
        if(userLi.size() == 1) {
          return userLi[0];
        } else {
          return null;
        }
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
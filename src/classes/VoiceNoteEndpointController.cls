public with sharing class VoiceNoteEndpointController {
  private Map<String, String> statusCallback;
  private Static String CALL_DURATION = 'CallDuration';
  private Static String CALL_SID = 'CallSid';
  
	public VoiceNoteEndpointController() {
    statusCallback = System.ApexPages.CurrentPage().getParameters();
    for(String key: statusCallback.keyset()){
      System.debug(key + '::' + statusCallback.get(key));
    }		
	}

  public String getTwiml() {
    TwilioTwiML.Response r = new TwilioTwiML.Response();
    r.append(new TwilioTwiML.Say('Hello Tom'));
    System.debug(r.toXML());
    return r.toXML();
  }  
}
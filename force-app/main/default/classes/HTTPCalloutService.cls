/**
* @File Name:   HTTPCalloutService.cls
* @Description: Integration base service class
* @Author:      Yutian Zheng
* @Group:       Apex
* @Last Modified by:   Yutian Zheng
* @Last Modified time: 2019-12-08
* @Modification Log :
*-------------------------------------------------------------------------------------
* Ver       Date        Author      Modification
* 1.0       2019-12-08  Yutian      Created Class
*/
public virtual inherited sharing class HTTPCalloutService {
    public Boolean calloutSucceeded{get;protected set;}
    protected Exception error;
    Payload_Operation__mdt calloutMetadata;
    String endpointURL, requestMethod, requestBody;
    protected String opsName, param;
    Integer requestTimeout;
    protected PayloadTransaction payloadTransaction{get; protected set;}//keep the payload transaction

    //call web service
    //TODO create generic send method, read endpoint, method, prams through metadata
    public virtual void callout(){
        try{
            initiateTransaction(opsName);
            processTransaction();
            handleResponse(payloadTransaction.response);
            onFinalize();
        } catch(exception e) {            
            payloadTransaction.err = e;
            System.debug(e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }

    private void initiateTransaction(String opsName){
        calloutMetadata = [SELECT HTTP_Method__c, Endpoint__c, Params__c FROM Payload_Operation__mdt WHERE DeveloperName =:opsName];
        if(calloutMetadata != null) {
            if(param != null)
                calloutMetadata.Params__c = param;
            payloadTransaction = new PayloadTransaction(calloutMetadata);
        }
    }

    private void processTransaction() {
        payloadTransaction.response = new Http().send(payloadTransaction.request);
    }
    /*
    public virtual Boolean callout(){
        String payload = constructPayload();
        //String token = OM_JWTToken.getToken(correlationId, workordernumber);
        Map<String, Object> options = new Map<String, Object>
            { 
            'headers' => new Map<String, String>{
                'Content-Type' => 'application/json'
                }
            };
        if(httpMethod == 'GET')
            this.PayloadTransaction = TransmitUtils.makeGetCallout(endpoint);
        this.handleResponse(PayloadTransaction.response);

        return this.IsSuccess;
    }
    */


    //handle http response
    private void handleResponse(HttpResponse response){
        payloadTransaction.endTimeMilliseconds = System.currentTimeMillis();
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
            calloutSucceeded = true;
        }
        else{
            calloutSucceeded = false;
            String errMsg = 'Callout Failed - ' + 
                (response == null ? 'Response is null' : response.toString());
            //this.error = new BaseServiceException(errMsg);
        }
    }

    //to construct payload
    protected virtual String constructPayload(){return '';}

    //handle success
    protected virtual void onSuccess(){}

    //handle failure
    protected virtual void onFailure(){}

    protected virtual void onFinalize(){
        try{
            if(calloutSucceeded)
                onSuccess();
            else
                onFailure();
        }catch(Exception e){
            calloutSucceeded = false;//set the flag to indicate the service encounter errors
            error = e;
            
        }finally{
            if(error != null && payloadTransaction != null){
                //this.payloadTransaction.addError(this.error); //add error to transaction
            }
            
            payloadTransaction.saveLog();//save the log
            
        }
        
    }

     /**
    * @Name          addError
    * @Description   Add error to service
    * @Author        Fan Yang
    * @CreatedDate   2018-04-03
    * @Param         Exception e
    * @Return        void
    */
    protected void addError(Exception e){
        error = e;
        calloutSucceeded = false;
    }

    /**
    * @Name          getError
    * @Description   get error message
    * @Author        Fan Yang
    * @CreatedDate   2018-04-04
    * @Return        void
    */
    public String getError(){
        return error == null ? '' : error.getMessage() + ' StackTrace:' + error.getStackTraceString();
    }
    public String getErrorMessage(){
        return error == null ? '' : error.getMessage();
    }




    public class BaseServiceException extends Exception{}

}
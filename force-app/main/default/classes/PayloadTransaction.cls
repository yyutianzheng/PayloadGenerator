/**
* @File Name:	PayloadTransaction.cls
* @Description: Manages HTTP REST API Callouts
* @Author:   	Fan Yang
* @Group:   	Apex
* @Last Modified by:   Yutian Zheng
* @Last Modified time: 2019-12-08
* @Modification Log	:
*-------------------------------------------------------------------------------------
* Ver       Date        Author      Modification
* 1.0       2019-04-03  Fan Yang    Created the file/class
* 2.0       2019-12-08  Yutian      Refactor
*/
global inherited sharing class PayloadTransaction
{
    public String endPoint;
    public String httpMethod;
    public String requestBody;
    public HttpRequest request = new HttpRequest();
    public HTTPResponse response = new HTTPResponse();
    public Exception err;
    public Long startTimeMilliseconds;
    public Long endTimeMilliseconds;
    public Integer  requestTimeout;
    public Boolean hasException { get { return null != this.err; } }
    public String  textResponse { get { return
        this.hasException ? 'Error: ' + this.err.getMessage() : this.response.getBody();
    }}

    public PayloadTransaction(Payload_Operation__mdt op){
        this.startTimeMilliseconds = System.currentTimeMillis();
        this.endPoint = formEndPoint(op);        
        this.httpMethod = op.HTTP_Method__c;
        this.request = formHTTPRequest();
    }

    private String formEndPoint(Payload_Operation__mdt op){
        String endPoint = op.Endpoint__c;
        if(endPoint.contains('{id}') && String.isNotEmpty(op.Params__c)){
            endPoint = endPoint.replace('{id}', op.Params__c);
        }
        return endPoint;
    }

    private HTTPRequest formHTTPRequest() {
        //addHeaderParameters();
        HTTPRequest request = new HTTPRequest();
        if(String.isNotEmpty(endPoint)) {
            request.setEndpoint(endPoint);
        }
        if(String.isNotEmpty(httpMethod)) {
            request.setMethod(httpMethod);
        }
        if(String.isNotEmpty(requestBody)) {
            request.setBody(requestBody);
        }
        if(requestTimeout!=null) {
            request.setTimeout(requestTimeout);
        }
        return request;
    }


    public Exception getError(){
        return this.err;
    }

    //fanxyang 040318
    public void addError(Exception e){
        this.err = e;
    }

    public PayloadTransaction(){}

        /**
    * @author Fan Yang
    * @date 4/4/2018
    * @description Persist log to Salesforce
    */
    public PayloadTransaction saveLog(){
        PayloadLog.createSystemLog(
            new PayloadLog(this.request, this.response, this.err, this.startTimeMilliseconds, this.endTimeMilliseconds)
        );//dml 
        return this;
    }

}
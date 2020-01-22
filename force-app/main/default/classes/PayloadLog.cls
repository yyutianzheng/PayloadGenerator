/**
* @File Name:   PayloadLog.cls
* @Description:
* @Author:      Fan yang, fanxyang@deloitte.ca
* @Group:       Apex
* @Last Modified by:   Fan Yang
* @Last Modified time: 2018-05-20 16:04:30
* @Modification Log :
*-------------------------------------------------------------------------------------
* Ver       Date        Author      Modification
* 1.0       2017-12-12  Fan yang    Created the file/class
* 2.0       2019-12-10  Yutian Zheng Refactor
*/
public with sharing class PayloadLog {
    public enum enumStatus {Failure, Success}
    public String OutgoingJSONPayload {get;set;}
    public String IncomingJSONPayload {get;set;}
    public Exception ExceptionObj {get;set;}
    public String HTTPMethod{get;set;}
    public String Status {get;set;}
    public Integer StatusCode {get;set;}
    public String Endpoint {get;set;}
    public Long startTimeMilliseconds {get;set;}
    public Long endTimeMilliseconds {get;set;}

    /**
    * @author JF Guilbert
    * @date 12/01/2017
    * @description Payload log consturctor for REST
    * @param OM_PayloadOperation info, Operation instance to use for mappings
    * @param HttpRequest  request, REST request to consider
    * @param HttpResponse response, REST response to consider
    * @param Exception e, Exception to consider
    */

    //TODO Refactor
    public PayloadLog(HttpRequest request, HttpResponse response, Exception e, Long startTimeMilliseconds, Long endTimeMilliseconds)
    {
        init(request, response, e,startTimeMilliseconds,endTimeMilliseconds);
    }


    /**
    * @Name          init
    * @Description   Initialize payload log
    * @Author        Yutian
    * @CreatedDate   2019-12-10
    * @Param         OM_PayloadOperation info
    * @Param         HttpRequest request
    * @Param         HttpResponse response
    * @Param         Exception e
    * @Return        void
    */
    private void init(HttpRequest request, HttpResponse response, Exception e,Long startTimeMilliseconds, Long endTimeMilliseconds){
        this.ExceptionObj = e;
        this.startTimeMilliseconds = startTimeMilliseconds;
        this.endTimeMilliseconds = endTimeMilliseconds;
        if (request != null){ 
            this.Endpoint = request.getEndpoint();
            this.HTTPMethod = request.getMethod();
            this.OutgoingJSONPayload = request.getBody();
            //if(request.getHeader('traceabilityid') != null){
        }
        if (response != null){
            Integer sc = response.getStatusCode();  
            this.Status = (sc < 300 && sc >= 100 ? enumStatus.Success.Name() : enumStatus.Failure.Name());
            this.StatusCode = response.getStatusCode();
            this.IncomingJSONPayload = response.getBody();
        } else {
            this.Status = enumStatus.Failure.Name();
        }
    }
    
    /**
    * @Name          createSystemLog
    * @Description   Initialize payload log
    * @Author        Yutian Zheng
    * @CreatedDate   2019-12-10
    * @Return        void
    */
    public static void createSystemLog(PayloadLog syLog) {
        try{
            Payload_Log__c log = new Payload_Log__c();
            log.Remote_Endpoint__c = syLog.Endpoint;
            log.Status__c = syLog.Status;
            log.HTTP_Method__c = syLog.HTTPMethod;
            log.Incoming_Payload__c = syLog.IncomingJSONPayload;
            log.Outgoing_Payload__c = syLog.OutgoingJSONPayload;
            insert log;
        } catch(exception e) {            
            System.debug(e.getMessage() + ' - ' + e.getStackTraceString());
        }

    }

}
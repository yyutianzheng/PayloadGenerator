/**
* @File Name:   UserSearchService.cls
* @Description:   
* @Author:      Yutian
* @Group:       Apex
* @Modification Log :
*-------------------------------------------------------------------------------------
* Ver       Date        Author      Modification
* 1.0       2019-04-25  Yutian      Created the file/class
*/
public with sharing class  UserSearchService extends HTTPCalloutService{
    public  UserSearchService(){
        this.opsName = 'getUser';
    }

    public UserSearchService(String UserId){
        this.opsName = 'getUser';
        this.param = UserId;
    }


    public String getUserInfo(){
        String jsonResponse = '';
        callout();
        if(calloutSucceeded){
            jsonResponse = payloadTransaction.response.getBody();
        } else if(payloadTransaction.response.getStatusCode() == 404){
            jsonResponse = payloadTransaction.response.getStatus();
        }
            
        System.debug('final result' + jsonResponse);

        return jsonResponse;
    }

}
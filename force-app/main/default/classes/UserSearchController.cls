public with sharing class UserSearchController {
    public UserSearchController() {
        
    }

    @AuraEnabled
    public static String getUserInfo(String searchKey) {
        UserSearchService sev = new UserSearchService(searchKey);
        String jsonString = sev.getUserInfo();
        return jsonString;
    }


}

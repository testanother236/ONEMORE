public with sharing class messer_HomePageServerController { 
       
    @AuraEnabled
    public static Boolean AuthenticatedUser() {
        Boolean authentic = false;
        try {
            String gStatus = 'Guest';
            String userStatus = UserInfo.getUserType();
            if(userStatus == gStatus){
                authentic = true;
            }
        }
        catch (QueryException e) {
            throw new AuraHandledException('There has been an error: ' + ' ' + e.getStackTraceString()+ ' ' + e.getMessage());
        }
        return authentic;
    }
    @AuraEnabled
    public static String getUserName() {
        String userName = '' ;
        try{
            userName =  UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        }
        catch (QueryException e) {
            throw new AuraHandledException('There has been an error: ' + ' ' + e.getStackTraceString()+ ' ' + e.getMessage());
        }
        return userName;
        
    }
    @AuraEnabled
    public static List<User> getUserInfo(){
        List<User> currUser = new List<User>();  
        try{
            currUser = [SELECT FirstName,
                        LastName,
                        Title,                              
                        CompanyName,
                        Street, 
                        City, 
                        State, 
                        PostalCode, 
                        Country,  
                        Email,
                        Profile.Name
                        FROM User 
                        WHERE Id =: UserInfo.getUserId()]; 
            
        }catch(QueryException e){
            throw new AuraHandledException('There has been an error: ' + ' ' + e.getStackTraceString()+ ' ' + e.getMessage());
        }
        return currUser; 
        
    }
    public class cartDataValues{
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public String skuData {get; set;}        
        @AuraEnabled public String qty {get;set;}
    }
    
    @AuraEnabled
    public static List<cartDataValues> getCartValues()
    {
        messer_HomePageServerController con = new messer_HomePageServerController();
        List<cartDataValues> cDVal= new List<cartDataValues>();
        try {
            List<ccrz__E_Cart__c> tempCart = [SELECT Id, ccrz__EncryptedId__c, ccrz__EffectiveAccountID__c, LastModifiedDate FROM ccrz__E_Cart__c WHERE OwnerId=:UserInfo.getUserId() AND ccrz__CartType__c = 'cart' AND ccrz__CartStatus__c = 'open' WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC ];
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'messer_HomePageServerController.getCartValues', tempCart);
            
            String encID;
            if (!tempCart.isEmpty()) {
                encID = tempCart[0].ccrz__EncryptedId__c;
                cDVal = con.getCartValuesHelper(encID);                
                ccrz.ccLog.log(System.LoggingLevel.INFO, 'messer_HomePageServerController.getCartValues', cDVal);
            }
        }
        catch (QueryException e) {
            throw new AuraHandledException('There has been an error: ' + ' ' + e.getStackTraceString()+ ' ' + e.getMessage());
        }
        return cDVal;
    }
    
    public List<cartDataValues> getCartValuesHelper(String encID) {
        List<cartDataValues> cDVal= new List<cartDataValues>();
        String english ='en_CA';
        String french ='fr_CA';
        List<String> skuList = new List<String>();
        Map<String,String> proskuMap = new Map<String,String>();
        List<ccrz__E_CartItem__c> cartItems = [SELECT Id, ccrz__Product__c,ccrz__Product__r.Name,ccrz__Product__r.ccrz__SKU__c,ccrz__Quantity__c,ccrz__Cart__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c=:encID WITH SECURITY_ENFORCED];
        if(UserInfo.getLocale() == english)
        {
            cartDataValues cDV;
            for(ccrz__E_CartItem__c Items :cartItems)
            {
                cDV= new cartDataValues();
                cDV.productName = Items.ccrz__Product__r.Name;
                cDV.skuData = String.ValueOf(Items.ccrz__Product__r.ccrz__SKU__c);
                cDv.qty = String.ValueOf(Items.ccrz__Quantity__c);
                cDVal.add(cDv);
            }
        }
        else if(UserInfo.getLocale() == french) {
            for(ccrz__E_CartItem__c Items :cartItems)
            {
                skuList.add(String.ValueOf(Items.ccrz__Product__r.ccrz__SKU__c));
            }
            for( ccrz__E_ProductItemI18N__c prodObj : [SELECT Id, Name,ccrz__SKU__c,ccrz__Product__c FROM ccrz__E_ProductItemI18N__c
                                                       WHERE ccrz__Locale__c = : UserInfo.getLocale() AND ccrz__SKU__c IN: skuList WITH SECURITY_ENFORCED])
            {
                proskuMap.put(String.ValueOf(prodObj.ccrz__SKU__c),prodObj.Name);    
            }
            for(ccrz__E_CartItem__c Items1 :cartItems)
            {
                cartDataValues cDV= new cartDataValues();
                cDV.productName = proskuMap.get(String.ValueOf(Items1.ccrz__Product__r.ccrz__SKU__c));
                cDV.skuData = String.ValueOf(Items1.ccrz__Product__r.ccrz__SKU__c);
                cDv.qty = String.ValueOf(Items1.ccrz__Quantity__c);
                cDVal.add(cDv);
            }
            
        }
        return cDVal;
    }
    
    @AuraEnabled
    public static AggregateResult CartItemCount() {
        AggregateResult itemCount = null;
        try {
            List<ccrz__E_Cart__c> tempCart = [SELECT Id, ccrz__EncryptedId__c, ccrz__EffectiveAccountID__c, LastModifiedDate FROM ccrz__E_Cart__c WHERE OwnerId=:UserInfo.getUserId() AND ccrz__CartType__c = 'cart' AND ccrz__CartStatus__c = 'open' WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
            if (!tempCart.isEmpty()) {
                itemCount = [SELECT SUM(ccrz__Quantity__c), ccrz__Cart__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c=:tempCart[0].ccrz__EncryptedId__c WITH SECURITY_ENFORCED GROUP BY ccrz__Cart__c];
            }
        }
        catch (QueryException e) {
            throw new AuraHandledException('There has been an error: ' + ' ' + e.getStackTraceString()+ ' ' + e.getMessage());
        }
        return itemCount;
    }
    
    @AuraEnabled
    public static String ChangeLang(string langString){
        
        String completed;
        try {
            Id currentUserId = UserInfo.getUserId();
            if (currentUserId == null) {
                completed = 'Failed';
            } else {
                
                User currentUserInfo = [SELECT LocaleSidKey, LanguageLocaleKey FROM User WHERE Id = :currentUserId WITH SECURITY_ENFORCED LIMIT 1 ];

                currentUserInfo.LocaleSidKey = langString;
                currentUserInfo.LanguageLocaleKey = langString;
                
                if (!Schema.sObjectType.User.fields.LocaleSidKey.isUpdateable() || !Schema.sObjectType.User.fields.LanguageLocaleKey.isUpdateable()) {
throw new AuraHandledException('Fields not updateable.');
}

                update currentUserInfo;
                
                completed = 'Completed';
            }
        }catch (QueryException e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }catch (DMLException e) {
            throw new AuraHandledException('Error updating language: ' + e.getMessage());
        }
        return completed;
    } 
    
    @AuraEnabled
    public static String getUserLocale(){        
        String retValue;
        try{
            Id userId = UserInfo.getUserId();
            Boolean guestUser = messer_HomePageServerController.AuthenticatedUser();
            
            User newUser = new User();
            if(userId != null && !guestUser){
                    newUser = [Select LanguageLocaleKey from User where Id = :userId WITH SECURITY_ENFORCED LIMIT 1];
                    retValue = JSON.serialize(newUser);
                
            }else{
                retValue = 'This is a guest User. They do not have a locale.';
            }
        }
        catch (QueryException e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
        return retValue;
    }
    
    public class cartData{
        
        @AuraEnabled public String cartEncId {get;set;}
        @AuraEnabled public String effAccId {get; set;}        
        @AuraEnabled public String userLocale {get;set;}
    }
    
    @AuraEnabled
    public static cartData getActiveCartOrCreate() {
        try{
            return new cartData();
        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }
    
    //Custom alert notification for homepage
    @AuraEnabled
    public static List<String> NotificationStatus() {
        List<String> infoToComponent= New List<string>();
        try{
            MesserWebshopNotifications__c isEnabled = MesserWebshopNotifications__c.getValues('WebshopNotification');
            Boolean notificationStatus =  isEnabled.Enable_Notification__c;
            String enNotification = isEnabled.EN_Translation__c;
            String frNotification = isEnabled.FR_Translation__c;
            infoToComponent.add(String.valueOf(notificationStatus));
            if(notificationStatus == true){
                infoToComponent.add(enNotification);
                infoToComponent.add(frNotification);
            }
        }
        catch (QueryException e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
        return infoToComponent;
    }
    
    public static void abc() {
        Account a = new Account(Id='123');
        
        if (Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.isUpdateable() && Account.Test__c.getDescribe().isUpdateable()) {
            update a;
        }   
    }
    
    // public static void abc1(Id someId) {
    //   Account accToUpdate = new Account(Id = someId, Test__c = 'value');
        
    //     if (Schema.sObjectType.Account.isUpdateable() && Account.Test__c.getDescribe().isUpdateable() && Schema.sObjectType.User.fields.Test__c.isUpdateable()) {
    //     update accToUpdate;
    //     }
    // }
    
    public static void abc2(Id id) {
        Account a = new Account(Id = id, Test__c = 'value');
        if (!Schema.sObjectType.Account.fields.Test__c.isUpdateable()) {
            throw new NoAccessException('FLS violation');
        }
        update a;
    }
    
    public static void abc3(Id id) {
        if (!Schema.sObjectType.Account.isUpdateable()) {
            throw new NoAccessException('Account не доступен для обновления');
        }
    
        Boolean canUpdateTest = Schema.sObjectType.Account.fields.getMap().get('Test__c').getDescribe().isUpdateable();
        if (!canUpdateTest) {
            throw new NoAccessException('Поле Test__c недоступно для обновления');
        }
    
        Account a = new Account(Id = id, Test__c = 'value');
        update a;
        
    }
    
    public static void abc4(Id id) {
       
        if (!Schema.sObjectType.Account.isUpdateable() || !Schema.sObjectType.Account.fields.Test__c.isUpdateable()) {
            throw new NoAccessException('FLS violation');
        }
        Account a = new Account(Id = id, Test__c = 'value');
        update new Account(Id = id, Test__c = 'value');
    }


}
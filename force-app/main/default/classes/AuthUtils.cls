public with sharing class AuthUtils {
    public static String fixBaseURL(String endpoint, String orgURL) {
        if (endpoint.indexOf('https://test.salesforce.com') > -1) {
            endpoint = endpoint.replace('https://test.salesforce.com', orgURL);
        }
        if (endpoint.indexOf('https://login.salesforce.com') > -1) {
            endpoint = endpoint.replace('https://login.salesforce.com', orgURL);
        }
        return endpoint;
    }

    public static Credentials__c getOrgDefaultsCredentials() {
        Credentials__c credentials = (Credentials__c.getOrgDefaults() != null &&
            Credentials__c.getOrgDefaults().id != null)
            ? Credentials__c.getOrgDefaults()
            : new Credentials__c();
        return credentials;
    }

    public static CredDetails getDefaultCreds() {
        return getDefaultCreds(null);
    }

    public static CredDetails getDefaultCreds(String organisationId) {
        CredDetails credDetail = new CredDetails();
        Credentials__c credentials = AuthUtils.getOrgDefaultsCredentials();

        Credentials_External_Client_App__c credentialsExtClientApp = (Credentials_External_Client_App__c.getOrgDefaults() !=
            null &&
            Credentials_External_Client_App__c.getOrgDefaults().id != null)
            ? Credentials_External_Client_App__c.getOrgDefaults()
            : new Credentials_External_Client_App__c();
        if (credentialsExtClientApp.App_Name__c != null) {
            credDetail = new CredDetails(credentialsExtClientApp);
        } else {
            credDetail = new CredDetails(credentials);
        }

        List<Organisation__c> orgLi = [
            SELECT Id, Username__c, Name
            FROM Organisation__c
            WHERE Id = :organisationId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (orgLi.isEmpty()) {
            return credDetail;
        }
        List<Authorization_Details__c> detailLi = [
            SELECT
                AuthorisedUser__c,
                Name,
                AccessToken__c,
                RefreshToken__c,
                InstanceURL__c,
                Connected_App_Type__c,
                Consumer_Key__c,
                Certificate_Name__c,
                Audience_URL__c,
                Consumer_Secret__c,
                Callback_URL__c
            FROM Authorization_Details__c
            WHERE AuthorisedUser__c = :orgLi[0].Username__c
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (detailLi.isEmpty()) {
            return credDetail;
        }
        if (detailLi[0].Connected_App_Type__c == FlosumConstants.EXTERNAL_CLIENT_AUTH) {
            credDetail.consumerKey = detailLi[0].Consumer_Key__c;
            credDetail.consumerSecret = detailLi[0].Consumer_Secret__c;
            credDetail.callbackURL = detailLi[0].Callback_URL__c;
        }
        return credDetail;
    }

    public static Map<Id, CredDetails> getListDefaultCreds(List<String> organisationId) {
        CredDetails credDetail = new CredDetails();
        Map<Id, CredDetails> credDetailMap = new Map<Id, CredDetails>();
        Map<String, String> orgIdsMap = new Map<String, String>();
        List<String> orgUsers = new List<String>();

        Credentials__c credentials = AuthUtils.getOrgDefaultsCredentials();

        Credentials_External_Client_App__c credentialsExtClientApp = (Credentials_External_Client_App__c.getOrgDefaults() !=
            null &&
            Credentials_External_Client_App__c.getOrgDefaults().id != null)
            ? Credentials_External_Client_App__c.getOrgDefaults()
            : new Credentials_External_Client_App__c();
        if (credentialsExtClientApp.App_Name__c != null) {
            credDetail = new CredDetails(credentialsExtClientApp);
        } else {
            credDetail = new CredDetails(credentials);
        }

        for (String orgId : organisationId) {
            credDetailMap.put(orgId, credDetail.clone());
        }

        List<Organisation__c> orgLi = [
            SELECT Id, Username__c, Organisation_ID__c
            FROM Organisation__c
            WHERE Id IN :organisationId
            WITH SECURITY_ENFORCED
            LIMIT 100
        ];
        if (orgLi.isEmpty()) {
            return credDetailMap;
        }
        for (Organisation__c org : orgLi) {
            orgIdsMap.put(org.Organisation_ID__c, org.Id);
            orgUsers.add(org.Username__c);
        }
        List<Authorization_Details__c> detailLi = [
            SELECT
                AuthorisedUser__c,
                Name,
                AccessToken__c,
                RefreshToken__c,
                InstanceURL__c,
                Connected_App_Type__c,
                Consumer_Key__c,
                Certificate_Name__c,
                Audience_URL__c,
                Consumer_Secret__c,
                Callback_URL__c
            FROM Authorization_Details__c
            WHERE AuthorisedUser__c IN :orgUsers
            WITH SECURITY_ENFORCED
            LIMIT 100
        ];

        if (detailLi.isEmpty()) {
            return credDetailMap;
        }
        for (Authorization_Details__c detail : detailLi) {
            if (detail.Connected_App_Type__c == FlosumConstants.EXTERNAL_CLIENT_AUTH) {
                credDetailMap.get(orgIdsMap.get(detail.Name)).consumerKey = detail.Consumer_Key__c;
                credDetailMap.get(orgIdsMap.get(detail.Name)).consumerSecret = detail.Consumer_Secret__c;
                credDetailMap.get(orgIdsMap.get(detail.Name)).callbackURL = detail.Callback_URL__c;
            }
        }
        return credDetailMap;
    }

    public static Model.AuthDetails getAuthDetails(AuthenticateDetails authDetails) {
        Model.AuthDetails auth = new Model.AuthDetails();
        auth.instanceUrl = authDetails.details.InstanceURL__c;
        auth.accessToken = authDetails.details.AccessToken__c;
        auth.grantType = 'refresh_token';
        auth.refreshToken = authDetails.details.RefreshToken__c;

        auth.clientId = authDetails.consumerKey;
        auth.clientSecret = authDetails.consumerSecret;
        return auth;
    }

    public static AuthenticateDetails authenticateAnOrg(String organisationId) {
        return authenticateAnOrg(organisationId, null, false);
    }

    public static AuthenticateDetails authenticateAnOrg(String organisationId, String Permission_Type) {
        return authenticateAnOrg(organisationId, Permission_Type, false);
    }

    //  @param  isForcedAuth    :   Allows auth without "Org_Permissions" under "RELEASE_MANAGER" but fills possible "errorMessage" (Latest Components feature)
    public static AuthenticateDetails authenticateAnOrg(
        String organisationId,
        String Permission_Type,
        Boolean isForcedAuth
    ) {
        AuthenticateDetails authResult = new AuthenticateDetails();
        authResult.isSuccess = false;
        authResult.needToUpdateDetails = false;
        authResult.hasOrgAuthPermission = false; //  used with "isForcedAuth" to determine if the current user has "Org_Permissions" (Latest Components feature)
        authResult.accessType = 'None';

        CredDetails creds = AuthUtils.getDefaultCreds(organisationId);
        authResult.consumerKey = creds.consumerKey;
        authResult.consumerSecret = creds.consumerSecret;

        List<Organisation__c> orgLi = [
            SELECT Id, Username__c, Name
            FROM Organisation__c
            WHERE Id = :organisationId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (orgLi.isEmpty()) {
            authResult.errorMessage = 'Exception: missing Organisation';
            return authResult;
        }
        if (VeevaService.checkVeevaOrg(orgLi[0].Id)) {
            authResult.errorMessage = VeevaConstants.VEEVA_NOT_SUPPORTED_EXCEPTION;
            return authResult;
        }
        Boolean hasRetrievePermission = false;
        Boolean hasDeployPermission = false;
        Boolean hasValidatePermission = false;
        Boolean hasViewOnlyPermission = false;
        Boolean hasAuditPermission = false;

        if (String.isNotBlank(Permission_Type)) {
            if (Permission_Type == FlosumConstants.DEVELOPER) {
                hasRetrievePermission = FlosumSecurity.checkRetrievePermission(orgLi[0].Id);
                if (!hasRetrievePermission) {
                    authResult.errorMessage = FlosumConstants.RETRIEVE_PERMISSION_DENIED;
                }
            } else if (Permission_Type == FlosumConstants.RELEASE_MANAGER) {
                hasDeployPermission = FlosumSecurity.checkDeployPermission(orgLi[0].Id);
                if (!hasDeployPermission) {
                    authResult.errorMessage = FlosumConstants.DEPLOY_PERMISSION_DENIED;
                }
            } else if (Permission_Type == FlosumConstants.READONLY) {
                hasViewOnlyPermission = FlosumSecurity.checkViewOnlyPermission(orgLi[0].Id);
                if (!hasViewOnlyPermission) {
                    authResult.errorMessage = FlosumConstants.PERMISSION_DENIED;
                }
            } else if (Permission_Type == FlosumConstants.VALIDATE_ONLY) {
                hasValidatePermission = FlosumSecurity.checkValidatePermission(orgLi[0].Id);
                if (!hasValidatePermission) {
                    authResult.errorMessage = FlosumConstants.VALIDATE_PERMISSION_DENIED;
                }
            }
            if (!String.isBlank(authResult.errorMessage) && !isForcedAuth) {
                return authResult;
            }

            if (Permission_Type == FlosumConstants.AUDIT_ONLY) {
                hasAuditPermission = true;
            }
        } else {
            Permission_Type = FlosumConstants.RELEASE_MANAGER;
            hasRetrievePermission = true;
            hasDeployPermission = true;
            hasValidatePermission = true;
            hasViewOnlyPermission = true;
            hasAuditPermission = true;
        }

        Boolean hasOrgAuthPermission =
            hasRetrievePermission ||
            hasDeployPermission ||
            hasValidatePermission ||
            hasViewOnlyPermission ||
            hasAuditPermission;
        authResult.hasOrgAuthPermission = hasOrgAuthPermission;

        if (!hasOrgAuthPermission && !isForcedAuth) {
            authResult.errorMessage = 'Exception: missing hasRetrievePermission and hasDeployPermission and hasValidatePermission and hasViewOnlyPermission and hasAuditPermission';
            return authResult;
        }

        List<Authorization_Details__c> detailLi = [
            SELECT
                AuthorisedUser__c,
                Name,
                AccessToken__c,
                RefreshToken__c,
                InstanceURL__c,
                Connected_App_Type__c,
                Consumer_Key__c,
                Certificate_Name__c,
                Audience_URL__c,
                Consumer_Secret__c,
                Callback_URL__c
            FROM Authorization_Details__c
            WHERE AuthorisedUser__c = :orgLi[0].Username__c
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (detailLi.isEmpty()) {
            authResult.errorMessage = 'Exception: missing Authorization Details';
            return authResult;
        }

        Permission_Type = isForcedAuth ? FlosumConstants.RELEASE_MANAGER : Permission_Type;
        try {
            //Authentication with access token.
            String endpoint = detailLi[0].InstanceURL__c + '/services/data/v51.0/';

            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(endpoint);
            httpReq.setHeader('Authorization', 'Bearer ' + detailLi[0].AccessToken__c);
            httpReq.setMethod('GET');
            httpReq.setTimeout(120000);
            Http pipe = new Http();
            HttpResponse res = pipe.send(httpReq);
            if (res.getStatusCode() == 200) {
                String response = res.getBody();
                Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(response);
                if (params.containsKey('Error')) {
                    //Authentication Failed.
                    authResult.errorMessage = 'Exception: contains Error :' + params.get('Error') + '\n';
                } else {
                    //Return in case of success.
                    authResult.isSuccess = true;
                    authResult.details = detailLi[0];
                    authResult.accessType = Permission_Type;
                }
            }
            if (!authResult.isSuccess && detailLi[0].Connected_App_Type__c == FlosumConstants.JWT_AUTH) {
                Auth.JWT jwt = new Auth.JWT();
                jwt.setSub(detailLi[0].AuthorisedUser__c);
                jwt.setAud(detailLi[0].Audience_URL__c);
                jwt.setIss(detailLi[0].Consumer_Key__c);
                DateTime dt = System.now().addYears(2);
                Integer expireTime = Integer.valueOf(dt.getTime() / 1000);
                jwt.setValidityLength(expireTime);
                //Create the object that signs the JWT bearer token
                Auth.JWS jws = new Auth.JWS(jwt, detailLi[0].Certificate_Name__c);
                String tokenEndpoint = detailLi[0].InstanceURL__c + '/services/oauth2/token';
                Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
                //Get the access token
                detailLi[0].AccessToken__c = bearer.getAccessToken();
                authResult.details = detailLi[0];
                authResult.isSuccess = true;
                authResult.needToUpdateDetails = true;
                authResult.accessType = Permission_Type;
            } else if (!authResult.isSuccess) {
                //Authentication with refresh token.
                endpoint =
                    detailLi[0].InstanceURL__c +
                    '/services/oauth2/token?grant_type=refresh_token' +
                    '&refresh_token=' +
                    detailLi[0].RefreshToken__c;
                endpoint += '&client_id=' + creds.consumerKey + '&client_secret=' + creds.consumerSecret;
                httpReq = new HttpRequest();
                httpReq.setEndpoint(endpoint);
                httpReq.setMethod('POST');
                httpReq.setTimeout(120000);
                pipe = new Http();
                res = new HttpResponse();
                res = pipe.send(httpReq);
                if (res.getStatusCode() == 200) {
                    String response = res.getBody();
                    if (response != null && response != '') {
                        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(response);
                        if (params.containsKey('access_token') && params.get('access_token') != null) {
                            detailLi[0].AccessToken__c = (String) params.get('access_token');
                            authResult.details = detailLi[0];
                            authResult.isSuccess = true;
                            authResult.needToUpdateDetails = true;
                            authResult.accessType = Permission_Type;
                        } else {
                            authResult.errorMessage += '\n Exception: responce not contains access_token';
                        }
                    } else {
                        authResult.errorMessage += '\n Exception: StatusCode with 200 but not Body';
                    }
                } else {
                    if (authResult.errorMessage == null) {
                        authResult.errorMessage =
                            FlosumConstants.SESSION_EXPIRE +
                            ' StatusCode = ' +
                            res.getStatusCode();
                    } else {
                        authResult.errorMessage +=
                            FlosumConstants.SESSION_EXPIRE +
                            ' StatusCode = ' +
                            res.getStatusCode();
                    }
                }
            }
        } catch (Exception ex) {
            authResult.errorMessage = 'Exception: ' + ex.getMessage();
        }

        if (authResult.isSuccess) {
            authResult.infoMessage = FlosumConstants.AUTHENTICATION_SUCCESSFUL;
        } else if (authResult.errorMessage == null) {
            authResult.errorMessage = FlosumConstants.SESSION_EXPIRE;
        }
        return authResult;
    }

    public static AuthenticateDetails authenticateAnOrg(
        String organisationId,
        String organisationUsername,
        String Permission_Type,
        CredDetails creds
    ) {
        AuthenticateDetails authResult = new AuthenticateDetails();
        authResult.isSuccess = false;
        authResult.needToUpdateDetails = false;
        authResult.accessType = 'None';

        authResult.consumerKey = creds.consumerKey;
        authResult.consumerSecret = creds.consumerSecret;

        if (organisationId != null && organisationUsername != null) {
            Boolean hasRetreivePermission = false;
            Boolean hasDeployPermission = false;
            Boolean hasValidatePermission = false;
            if (Permission_Type == FlosumConstants.DEVELOPER) {
                hasRetreivePermission = FlosumSecurity.checkRetrievePermission(organisationId);
                if (!hasRetreivePermission) {
                    authResult.errorMessage = FlosumConstants.RETRIEVE_PERMISSION_DENIED;
                    return authResult;
                }
            } else if (Permission_Type == FlosumConstants.RELEASE_MANAGER) {
                hasDeployPermission = FlosumSecurity.checkDeployPermission(organisationId);
                if (!hasDeployPermission) {
                    authResult.errorMessage = FlosumConstants.DEPLOY_PERMISSION_DENIED;
                    return authResult;
                }
            } else if (Permission_Type == FlosumConstants.VALIDATE_ONLY) {
                hasValidatePermission = FlosumSecurity.checkValidatePermission(organisationId);
                if (!hasValidatePermission) {
                    authResult.errorMessage = FlosumConstants.VALIDATE_PERMISSION_DENIED;
                    return authResult;
                }
            }
            if (hasRetreivePermission || hasDeployPermission || hasValidatePermission) {
                List<Authorization_Details__c> detailLi = [
                    SELECT
                        AuthorisedUser__c,
                        Name,
                        AccessToken__c,
                        RefreshToken__c,
                        InstanceURL__c,
                        Connected_App_Type__c,
                        Consumer_Key__c,
                        Certificate_Name__c,
                        Audience_URL__c,
                        Consumer_Secret__c,
                        Callback_URL__c
                    FROM Authorization_Details__c
                    WHERE AuthorisedUser__c = :organisationUsername
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (detailLi != null && detailLi.size() > 0) {
                    try {
                        //Authentication with access token.
                        String endpoint = detailLi[0].InstanceURL__c + '/services/data/v51.0/';
                        HttpRequest httpReq = new HttpRequest();
                        httpReq.setEndpoint(endpoint);
                        httpReq.setHeader('Authorization', 'Bearer ' + detailLi[0].AccessToken__c);
                        httpReq.setMethod('GET');
                        httpReq.setTimeout(120000);
                        Http pipe = new Http();
                        HttpResponse res = pipe.send(httpReq);
                        if (res.getStatusCode() == 200) {
                            String response = res.getBody();
                            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(response);
                            if (params.containsKey('Error')) {
                                //Authentication Failed.
                                authResult.errorMessage = 'Exception: contains Error :' + params.get('Error') + '\n';
                            } else {
                                //Return in case of success.
                                authResult.isSuccess = true;
                                authResult.details = detailLi[0];
                                authResult.accessType = Permission_Type;
                            }
                        }
                        if (!authResult.isSuccess && detailLi[0].Connected_App_Type__c == FlosumConstants.JWT_AUTH) {
                            Auth.JWT jwt = new Auth.JWT();
                            jwt.setSub(detailLi[0].AuthorisedUser__c);
                            jwt.setAud(detailLi[0].Audience_URL__c);
                            jwt.setIss(detailLi[0].Consumer_Key__c);
                            DateTime dt = System.now().addYears(2);
                            Integer expireTime = Integer.valueOf(dt.getTime() / 1000);
                            jwt.setValidityLength(expireTime);
                            //Create the object that signs the JWT bearer token
                            Auth.JWS jws = new Auth.JWS(jwt, detailLi[0].Certificate_Name__c);
                            String tokenEndpoint = detailLi[0].InstanceURL__c + '/services/oauth2/token';
                            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
                            //Get the access token
                            detailLi[0].AccessToken__c = bearer.getAccessToken();
                            authResult.details = detailLi[0];
                            authResult.isSuccess = true;
                            authResult.needToUpdateDetails = true;
                            authResult.accessType = Permission_Type;
                        } else if (!authResult.isSuccess) {
                            //Authentication with refresh token.
                            endpoint =
                                detailLi[0].InstanceURL__c +
                                '/services/oauth2/token?grant_type=refresh_token' +
                                '&refresh_token=' +
                                detailLi[0].RefreshToken__c;
                            endpoint += '&client_id=' + creds.consumerKey + '&client_secret=' + creds.consumerSecret;
                            httpReq = new HttpRequest();
                            httpReq.setEndpoint(endpoint);
                            httpReq.setMethod('POST');
                            httpReq.setTimeout(120000);
                            pipe = new Http();
                            res = new HttpResponse();
                            res = pipe.send(httpReq);
                            if (res.getStatusCode() == 200) {
                                String response = res.getBody();
                                if (response != null && response != '') {
                                    Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
                                        response
                                    );
                                    if (params.containsKey('access_token') && params.get('access_token') != null) {
                                        detailLi[0].AccessToken__c = (String) params.get('access_token');
                                        authResult.details = detailLi[0];
                                        authResult.isSuccess = true;
                                        authResult.needToUpdateDetails = true;
                                        authResult.accessType = Permission_Type;
                                    }
                                }
                            }
                        }
                    } catch (Exception ex) {
                        authResult.errorMessage = 'Exception: ' + ex.getMessage();
                    }
                }
            }
        }
        if (authResult.isSuccess) {
            authResult.infoMessage = FlosumConstants.AUTHENTICATION_SUCCESSFUL;
        } else if (authResult.errorMessage == null) {
            authResult.errorMessage = FlosumConstants.SESSION_EXPIRE;
        }
        return authResult;
    }

    public class AuthenticateDetails {
        public Boolean needToUpdateDetails;
        public Boolean isSuccess { get; set; }
        public Boolean hasOrgAuthPermission;
        public String errorMessage;
        public String infoMessage;
        public String accessType;
        public String consumerKey;
        public String consumerSecret;
        public Authorization_Details__c details { get; private set; }
    }

    public static String getValue(String response, String key) {
        if (response != null) {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(response);
            return (String) params.get(key);
        } else {
            return null;
        }
    }

    public class CredDetails {
        public String consumerKey;
        public String consumerSecret;
        public String callbackURL;
        public String manualCallbackURL;
        public Boolean isClientCredentialsFlowEnabled = false;

        public CredDetails() {
        }

        public CredDetails(Credentials_External_Client_App__c credentialsExtClientApp) {
            this.consumerKey = credentialsExtClientApp.Consumer_Key__c;
            this.consumerSecret = credentialsExtClientApp.Consumer_Secret__c;
            this.callbackURL = credentialsExtClientApp.Redirect_URL__c;
            this.isClientCredentialsFlowEnabled = credentialsExtClientApp.Is_Client_Credentials_Flow_Enabled__c;
        }

        public CredDetails(Credentials__c credentials) {
            this.consumerKey = credentials.ConsumerKey__c;
            this.consumerSecret = credentials.ConsumerSecret__c;
            this.callbackURL = credentials.Redirect_URL_Auto__c;
            this.manualCallbackURL = credentials.Redirect_URL__c;
            this.isClientCredentialsFlowEnabled = credentials.Is_Client_Credentials_Flow_Enabled__c;
        }

        public CredDetails(Authorization_Details__c detail) {
            this.consumerKey = detail.Consumer_Key__c;
            this.consumerSecret = detail.Consumer_Secret__c;
            this.callbackURL = detail.Callback_URL__c;
        }
    }
}
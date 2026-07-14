public with sharing class CustomPermissionManagement
{
    public static Boolean doesRunningUserHavePermission(String apiName,String prefixName)
    {
        Set<Id> accessiblePermissionIds = new Set<Id>();
        for (SetupEntityAccess access : [
                SELECT SetupEntityId FROM SetupEntityAccess
                WHERE SetupEntityType = 'CustomPermission' AND ParentId IN (
                    SELECT PermissionSetId FROM PermissionSetAssignment
                    WHERE AssigneeId = :UserInfo.getUserId()
                )
            ]){ 
            
            accessiblePermissionIds.add(access.SetupEntityId);
        }
        
        return 0 < [SELECT count() FROM CustomPermission WHERE Id IN :accessiblePermissionIds AND DeveloperName = :apiName AND NameSpacePrefix = :prefixName];
    }
}
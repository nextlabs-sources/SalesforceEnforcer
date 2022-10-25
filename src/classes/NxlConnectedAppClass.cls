global class NxlConnectedAppClass extends Auth.ConnectedAppPlugin
{
    global override boolean authorize(Id userId, Id connectedAppId, boolean isAdminApproved, Auth.InvocationContext context) 
    {
        System.debug('NxlConnectedApp authorize Begin.');
        return NxlCommonGlobal.CheckAppResource(userId, connectedAppId);
    }
}
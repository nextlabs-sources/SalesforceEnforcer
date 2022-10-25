global class NxlFutureCall
{
    @future(callout=true)
	public static void CallEnforcerEvaluation(integer userInd)
    {
        DateTime now = DateTime.now();
        NxlCommonGlobal.CheckUserObligation(userInd);               
        System.Debug('CallEnforcerEvaluation spent time(ms):' + string.valueOf(DateTime.now().getTime() - now.getTime()));      
    }
}
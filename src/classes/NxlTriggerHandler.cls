global class NxlTriggerHandler 
{  
    public static string TriggerDoEvalution(NxlCERequest.EvalAction action, List<SObject> listSObjs, List<boolean> listResults)
    {
        System.debug('NxlTriggerHandler TriggerDoEvalution action:' + string.valueOf(action));
        string alertMsg = '';
        try
        {
        	integer count = listSObjs.size();
            if(listSObjs != null && count > 0)
            {
            	string recordType = listSObjs[0].getSObjectType().getDescribe().getName();
                string strAction = NxlTranformModule.ConvertEvalAction(action);
        		string userId = string.valueOf(UserInfo.getUserId());               
            	for(integer i = 0; i < count; i++)
            	{   
                    SObject sobj = listSObjs[i];
                    string recordId = string.valueOf(sobj.get('Id'));
                    string ownerId = '';
                    try
                    {
                    	ownerId = string.valueOf(sobj.get('OwnerId'));
                    }
                    catch(Exception exp)
                    {
                    	ownerId = ''; // When it not existed 'OwnerId', use empty string.
                    }
                    if(userId.equalsIgnoreCase(ownerId))
                    {
                    	listResults[i] = true; // Always permit 'allow' to owner.
                    }
                    else
                    {
        				boolean bResult = NxlCommonGlobal.GetEnforceResult(userId, recordType, recordId, strAction);
                		listResults[i] = bResult;
                    }
            	}
            	alertMsg = NxlCommonGlobal.GetAlertMessage(userId, recordType, strAction);
            }
        }
        catch(Exception exp)
        {
        	NxlCommonGlobal.bException = true;
            System.debug('TriggerHandler::TriggerDoEvalution Exception: ' + exp.getMessage());
        }                 
        return alertMsg;
    }
    
    global static void executeTrigger() 
    {
    	NxlCommonGlobal.bException = false;
        List<boolean> bListEvalResult = new List<boolean>();
        NxlCERequest.EvalAction action = NxlCERequest.EvalAction.CreateAction;
        List<SObject> listSObjs = null;
        if(Trigger.isBefore) 
        {
            if(Trigger.isInsert) 
            {
                action = NxlCERequest.EvalAction.CreateAction;
                listSObjs = Trigger.new;                
            }
            else if(Trigger.isUpdate) 
            {
                action = NxlCERequest.EvalAction.EditAction;
                listSObjs = Trigger.old;
            }
            else if(Trigger.isDelete) 
            {
                action = NxlCERequest.EvalAction.DeleteAction;
                listSObjs = Trigger.old;                
            }
        } 
        else
        {
            if(Trigger.isUndelete) 
            {
                action = NxlCERequest.EvalAction.CreateAction;
                listSObjs = Trigger.new;                
            }
        }
        List<boolean> listResults = new boolean[listSObjs.size()];
        string denyMsg = TriggerDoEvalution(action, listSObjs, listResults);
        if(string.isEmpty(denyMsg))
        {
        	denyMsg = NxlUISetting.GetDenyMessage(NxlCommonGlobal.bException);
        }
        for(Integer i = 0; i < listResults.size(); i++)
        {
            if(listResults[i] == null || !listResults[i]) // Result is null or false, it need deny access.
            {
                try
                {
                    if(Trigger.isDelete)
                    {
                        Trigger.old[i].addError(denyMsg);
                    }
                    else
                    {
                    	Trigger.new[i].addError(denyMsg);                                
                    }
                }
                catch(Exception exp)
                {
                    System.debug('TriggerHandler::addError Exception: ' + exp.getMessage());
                }
           }
        }
    }
}
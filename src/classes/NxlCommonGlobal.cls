// Include common functions and static members.
public class NxlCommonGlobal 
{
    public static boolean bException = false; 
    public static Integer UsersEvalLimited = 100;
    public static string ConnectedApp = 'connectedapplication';
    public class EvaluationData
    {
        public EvaluationData()
        {
            UserId = null;
            Action = null;
            RecordType = null;
            AlertMessage = null; 
            ListQueryString = null;
            ListField = null;
        }
        
        public EvaluationData(Id inputUserId, string inputType, string inputAction)
        {
            UserId = inputUserId;
            Action = inputAction;
            RecordType = inputType;
            AlertMessage = null;
            ListQueryString = null;
            ListField = null;
        }
        public Id UserId;
        public string Action;
        public string RecordType;
        public string AlertMessage;
        public List<string> ListQueryString;
        public List<string> ListField;
    }
    
    /*public static void StartEnforceSchedule(DateTime startTime, integer intervalHours)
    {
        System.debug('NxlCommonGlobal StartEnforceSchedule startTime:' + string.valueOf(startTime) + ', intervalHours:' + intervalHours);
        String cronString = startTime.second() + ' ' + startTime.minute() + ' ' + startTime.hour() 
            + ' ' + startTime.day() + ' ' + startTime.month() + ' ? ' + startTime.year(); 
        System.schedule(NxlEnforcerJob.class.getName() + '-' + startTime.format(), cronString, new NxlEnforcerJob(intervalHours));
    }
    
    public static void StopEnforceSchedule()
    {
        System.debug('NxlCommonGlobal StopEnforceSchedule');
        string matchName = NxlEnforcerJob.class.getName() + '%';
        try
        {
        	List<CronTrigger> cronJobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE :matchName];
        	for(CronTrigger cronJob : cronJobs)
        	{
            	System.abortJob(cronJob.Id);
        	}
        }
        catch(Exception exp)
        {
            System.debug('NxlCommonGlobal StopEnforceSchedule Exception: ' + exp.getMessage());           
        }
    }*/
    
    public static boolean CheckAppResource(Id userId, Id appId)
    {
        boolean bEvalResult = true;
        try
        {
            string accessAction = NxlTranformModule.ConvertEvalAction(NxlCERequest.EvalAction.AccessAction);
            bEvalResult = GetEnforceResult(string.valueOf(userId), ConnectedApp, string.valueOf(appId), accessAction);
            System.debug('NxlCommonGlobal CheckAppResource result:' + bEvalResult);
        }
        catch(Exception exp)
        {
            System.debug('NxlCommonGlobal checkAppResource Exception: ' + exp.getMessage());           
        }
        return bEvalResult;
    }

	public static Map<string, string> GetAttributesBySObject(SObject sobj)
    {
        Map<string, string> mapAttrs = new Map<string, string>();
        if(sobj != null)
        {
            Map<String, Object> mapFields  = sobj.getPopulatedFieldsAsMap();
            for(string fieldKey : mapFields.keySet())
            {
                Object fieldObj = mapFields.get(fieldKey);
                string fieldvalue = string.valueOf(fieldObj);
                if(string.isNotEmpty(fieldvalue))
                {
                    mapAttrs.put(fieldKey, fieldvalue);
                }
            } 
        }
        return mapAttrs;
    }
    
    public static boolean CheckFieldsIsValid(string recordType, List<string> listField, List<string> listFieldInvalid)
    {
    	boolean bValid = true;
    	List<string> selectedFields = NxlUISetting.GetSelectedRecordFields(recordType);
    	
    	for(string field : listField)    	
    	{
    		boolean bFind = false;
    		for(string selectField : selectedFields)
    		{
    			if(field.equalsIgnoreCase(selectField))
    			{
    				bFind = true;
    				break;
    			}    			
    		}
    		if(!bFind)
    		{
    			bValid = false;
    			listFieldInvalid.add(field);
    		}
    	}
    	return bValid;
    }
	
	public static boolean GetEnforceResult(string userId, string recordType, string recordId, string action)
	{
        System.debug('NxlCommonGlobal GetEnforceResult action:' + action);
		boolean bResult = false;
        try
        {
			if(NxlUISetting.CheckRecordType(recordType))
			{
                string recordAction = GetRecordAction(recordType, action);
				string queryContent = NxlUISetting.GetQueryContent(userId);
				if(string.isNotEmpty(queryContent))
				{
					List<EvaluationData> listEvalData = (List<EvaluationData>)JSON.deserialize(queryContent, List<EvaluationData>.class);                
					for(EvaluationData evalData : listEvalData)
					{
						if(evalData.Action.equalsIgnoreCase(action) && evalData.RecordType.equalsIgnoreCase(recordType))
						{
							List<string> listObligation = evalData.ListQueryString;
							List<string> listFieldInvalid = new List<string>(); 
							if(evalData.ListField != null && !CheckFieldsIsValid(recordType, evalData.ListField, listFieldInvalid))
							{
								System.debug(LoggingLevel.ERROR, 'Error: GetEnforceResult CheckFieldsIsValid False, invalid fields: ' + string.join(listFieldInvalid, ';'));
							}
							else if(listObligation != null)
							{
                        		bResult = NxlQueryObligation.CheckResultById(recordId, recordType, listObligation);
							}
							break;
						}
					}
				}
			}
			else
			{
				return true; // ignore, this record type don't need to do enforcement.
			}
        }
        catch(Exception exp)
        {
        	bException = true;
            System.debug('GetEnforceResult Exception: ' + exp.getMessage());           
        }
        System.debug('NxlCommonGlobal GetEnforceResult result:' + bResult);
		return bResult;
	}
        
    public static string GetAlertMessage(string userId, string recordType, string action)
    {
    	string alertMsg = '';
    	string queryContent = NxlUISetting.GetQueryContent(userId);
		if(string.isNotEmpty(queryContent))
		{
			List<EvaluationData> listEvalData = (List<EvaluationData>)JSON.deserialize(queryContent, List<EvaluationData>.class);                
			for(EvaluationData evalData : listEvalData)
			{
				if(evalData.Action.equalsIgnoreCase(action) && evalData.RecordType.equalsIgnoreCase(recordType))
				{
					alertMsg = evalData.AlertMessage;
				}
			}
		}
		return alertMsg;
    }
    
	public static Map<Id, Map<string, string>> GetAllUserIds(List<string> userFields, integer limitNum, integer offsetNum)
	{
		Map<Id, Map<string, string>> mapUserIds = new Map<Id, Map<string, string>>();
		string selectFields = string.join(userFields, ', ');
        string queryString = 'select ' + selectFields + ' from User limit :limitNum offset :offsetNum';
		List<User> users = DataBase.query(queryString);
		for(User selectUser : users)
		{
			mapUserIds.put(selectUser.Id, GetAttributesBySObject(selectUser));
		}
		return mapUserIds;
	}
     
    public static string GetRecordAction(string recordType, string action)
	{
		return (recordType + '_' + action).toUpperCase();
	}

    public static void CheckUserObligation()
	{
        System.debug('NxlCommonGlobal CheckUserObligation');
        string queryString = 'select Id from User';
		List<User> listUser = DataBase.query(queryString);
        integer userCount = listUser.size();
        if(NxlEnforceModule.CheckJPCAndAuthHost())
        {
        	for(integer i = 0; i < userCount; i+= UsersEvalLimited)
        	{
           		NxlFutureCall.CallEnforcerEvaluation(i);
        	}
        }
    }
    
    public static boolean CheckUserObligation(integer offsetNum)
    {
        System.debug('NxlCommonGlobal CheckUserObligation offset:' + offsetNum);
        try
        {
			List<string> listRecordType = NxlUISetting.GetSelectedRecordTypes();
			Map<string, NxlViewModels.EntityModel> mapRecordFieldModels = new Map<string, NxlViewModels.EntityModel>();
			for(string recordType : listRecordType)
			{
				mapRecordFieldModels.put(recordType, NxlUISetting.GetSelectedRecordModel(recordType));
			}
			List<string> userFields = NxlUISetting.GetSelectedUserFields();
			if(userFields.size() == 0)
			{
				userFields.add('Id');	// If user don't care user attributes. we just get 'id' to avoid exception.
			}
			Map<Id, Map<string, string>> mapUserIds = GetAllUserIds(userFields, UsersEvalLimited, offsetNum);
			string createAction = NxlTranformModule.ConvertEvalAction(NxlCERequest.EvalAction.CreateAction);
			string readAction = NxlTranformModule.ConvertEvalAction(NxlCERequest.EvalAction.ReadAction);
			string editAction = NxlTranformModule.ConvertEvalAction(NxlCERequest.EvalAction.EditAction);
			string deleteAction = NxlTranformModule.ConvertEvalAction(NxlCERequest.EvalAction.DeleteAction);
			string accessAction = NxlTranformModule.ConvertEvalAction(NxlCERequest.EvalAction.AccessAction);
			List<EvaluationData> listData = new List<EvaluationData>();
			List<NxlCERequest.CERequest> listCERequest = new List<NxlCERequest.CERequest>();
			string resoureName = URL.getSalesforceBaseUrl().toExternalForm();
			for(Id userId: mapUserIds.keySet())
			{
				Map<string, string> userAttrs = mapUserIds.get(userId);
				string userEmail = userAttrs.get('Email');
				for(string recordType : listRecordType)
				{						
					if(recordType.equalsIgnoreCase(ConnectedApp))
					{
						SetEvaluationData(userId, recordType, accessAction, resoureName, userEmail, userAttrs, listData, listCERequest);
					}
					else
					{
						//SetEvaluationData(userId, recordType, createAction, resoureName, userEmail, userAttrs, listData, listCERequest);
						//SetEvaluationData(userId, recordType, readAction, resoureName, userEmail, userAttrs, listData, listCERequest);
						SetEvaluationData(userId, recordType, editAction, resoureName, userEmail, userAttrs, listData, listCERequest);
						SetEvaluationData(userId, recordType, deleteAction, resoureName, userEmail, userAttrs, listData, listCERequest);
					}
				}
			}
			
			List<List<NxlCERequest.CEObligation>> listObligations = new List<List<NxlCERequest.CEObligation>>();
			List<boolean> listResults = new List<boolean>();
			boolean bEvalResult = NxlEnforceModule.DoMultipleEvalution(listCERequest, listResults, listObligations);
			if(bEvalResult)
			{
				Map<string, NxlSettings__c> mapNxlSet = NxlUISetting.GetAllQueryNxlSet();
				Map<Id, List<EvaluationData>> userEvalDatas = new Map<Id, List<EvaluationData>>();
				for(integer i = 0; i < listResults.size(); i++)
				{
					boolean bPolicyResult = listResults[i];
                    EvaluationData evalData = listData[i];
					Id evalUserId = evalData.UserId;
                    List<NxlCERequest.CEObligation> listObs = listObligations[i];
					if(bPolicyResult)
					{
						if(listObs.size() > 0)
						{
							NxlViewModels.EntityModel recordModel = mapRecordFieldModels.get(evalData.RecordType);
							List<string> listField = new List<string>();
							string recordAction = GetRecordAction(evalData.RecordType, evalData.Action);
        					List<string> listQueryString = NxlQueryObligation.DecodePermitObligations(listObs, listField, recordModel);
							evalData.ListQueryString = listQueryString;
							evalData.ListField = listField;
						}
						else
						{	
							List<string> listQueryString = new List<string>();
							listQueryString.add(NxlCERequest.AlwaysAllow);
							evalData.ListQueryString = listQueryString;
						}
					}
					else
					{
						evalData.AlertMessage = NxlQueryObligation.DecodeAlertMessageObligations(listObs);
					}
                    if(userEvalDatas.containsKey(evalUserId))
					{
						userEvalDatas.get(evalUserId).add(evalData);
					}
					else
					{
						List<EvaluationData> listEvalData = new List<EvaluationData>();
						listEvalData.add(evalData);
						userEvalDatas.put(evalUserId, listEvalData);
					}
				}
            
				for(Id userId : userEvalDatas.keySet())
				{
					string userIdStr = string.valueOf(userId);
					List<EvaluationData> listEvalData = userEvalDatas.get(userId);
					if(listEvalData != null && listEvalData.size() > 0)
					{
                		string queryContent = JSON.serialize(listEvalData); 
                		NxlUISetting.SetQueryContent(userIdStr, queryContent, mapNxlSet);
					}
					else if(mapNxlSet.containsKey(userIdStr))
					{
						NxlSettings__c nxlSet = mapNxlSet.get(userIdStr);
						delete nxlSet;
					}
				}
			}
            return bEvalResult;
        }
		catch(Exception exp)
        {
            System.debug('DoEvalution Exception: ' + exp.getMessage());           
        }
		return false;
	}

	public static void SetEvaluationData(Id userId, string recordType, string action,
                    string resoureName, string userEmail, Map<string, string> userAttrs,                      
					List<EvaluationData> listData, List<NxlCERequest.CERequest> listCERequest)
	{
		string recordAction = GetRecordAction(recordType, action);
		Map<string, string> resourceAttrs = new Map<string, string>();
        
		EvaluationData evalData = new EvaluationData(userId, recordType, action);
		NxlCERequest.CERequest ceRequest = NxlEnforceModule.CreateCEReqest(recordAction, string.valueOf(userId), userEmail, resoureName, userAttrs, resourceAttrs);
		listData.add(evalData);
        listCERequest.add(ceRequest);
	}    		 
}
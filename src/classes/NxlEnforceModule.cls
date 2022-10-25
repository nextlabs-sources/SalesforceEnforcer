public class NxlEnforceModule
{   
    public static boolean CheckJPCAndAuthHost(string strJPCHost, string strOAuthHost, string strClientId, string strClientSecure)
    {
        NxlCERequest.CERequest ceRequest = CreateCEReqest('VIEW', '123456', 'Test@nextlabs.com', 'MyTest', new Map<string, string>(), new Map<string, string>());
        List<NxlCERequest.CEObligation> listObligation = new List<NxlCERequest.CEObligation>();
        CEEnforcer obCEEnforcer = new CEEnforcer(strJPCHost, strOAuthHost, strClientId, strClientSecure);
		NxlCERequest.QueryStatus statusResult = obCEEnforcer.CheckResource(ceRequest, listObligation);
		if(statusResult == NxlCERequest.QueryStatus.S_OK)
		{
            System.debug('NxlEnforceModule CheckJPCAndAuthHost Success.');
            return true;
        }
        System.debug('NxlEnforceModule CheckJPCAndAuthHost Faild.');
        return false;
    }
    
    public static boolean CheckJPCAndAuthHost()
    {
        NxlUISetting.GeneralSettingModel generalSet = NxlUISetting.GetNxlSetting();
		string strJPCHost = NxlUISetting.GetPCUrl(generalSet);
        string strOAuthHost = NxlUISetting.GetAuthUrl(generalSet);
        string strClientId = generalSet.clientid;
        string strClientSecure = generalSet.clientkey;
		return CheckJPCAndAuthHost(strJPCHost, strOAuthHost, strClientId, strClientSecure);        
    }
    
	private static NxlCERequest.CEAttres ConvertMapToCEAttres(Map<string, string> mapAttrs)
	{
		NxlCERequest.CEAttres obAttrs = new NxlCERequest.CEAttres();
		for(string strKey : mapAttrs.keySet())
		{
			obAttrs.addAttribute(strKey, mapAttrs.get(strKey), NxlCERequest.CEAttributeType.XACML_String);
		}

		return obAttrs;
	}
	
	public static NxlCERequest.CERequest CreateCEReqest(string strAction, string userId, string userEmail, 
			string resoureName, Map<string, string> userAttrs, Map<string, string> resourceAttrs)
    {		
        NxlCERequest.CERequest obRequest = new NxlCERequest.CERequest();
        obRequest.SetAction(strAction);

        obRequest.SetUser(userId, userEmail, ConvertMapToCEAttres(userAttrs));
        obRequest.SetSource(resoureName, 'fso', ConvertMapToCEAttres(resourceAttrs));
		obRequest.SetNameAttributes('dont-care-acceptable', 'yes', NxlCERequest.CEAttributeType.XACML_String);
		obRequest.SetApp('Salesforce', '', '', new NxlCERequest.CEAttres());
		obRequest.setNoiseLevel(NxlCERequest.CENoiseLevel.CE_NOISE_LEVEL_USER_ACTION);
            
        return obRequest;
    }

	public static boolean DoSingleEvalution(NxlCERequest.CERequest ceRequest, List<NxlCERequest.CEObligation> listObligation)
	{
		boolean evalResult = false;
        NxlUISetting.GeneralSettingModel generalSet = NxlUISetting.GetNxlSetting();
		string strJPCHost = NxlUISetting.GetPCUrl(generalSet);
        string strOAuthHost = NxlUISetting.GetAuthUrl(generalSet);
        string strClientId = generalSet.clientid;
        string strClientSecure = generalSet.clientkey;
        CEEnforcer obCEEnforcer = new CEEnforcer(strJPCHost, strOAuthHost, strClientId, strClientSecure);
		NxlCERequest.QueryStatus statusResult = obCEEnforcer.CheckResource(ceRequest, listObligation);
		if(statusResult == NxlCERequest.QueryStatus.S_OK)
		{
			if(obCEEnforcer.EnforcePolicyResult == NxlCERequest.PolicyResult.Allow)
			{
				evalResult = true;
			}
		}
		return evalResult;
	}    

	public static boolean DoMultipleEvalution(List<NxlCERequest.CERequest> ceListRequests, 
           List<boolean> listResults, List<List<NxlCERequest.CEObligation>> listObligations)
	{
        boolean queryResult = false;
        System.debug('NxlEnforceModule DoMultipleEvalution: size = ' + ceListRequests.size());
        NxlUISetting.GeneralSettingModel generalSet = NxlUISetting.GetNxlSetting();
		string strJPCHost = NxlUISetting.GetPCUrl(generalSet);
        string strOAuthHost = NxlUISetting.GetAuthUrl(generalSet);
        string strClientId = generalSet.clientid;
        string strClientSecure = generalSet.clientkey;
        NxlCERequest.QueryStatus statusResult = NxlCERequest.QueryStatus.E_Failed;
        try
        {
			CEEnforcer obCEEnforcer = new CEEnforcer(strJPCHost, strOAuthHost, strClientId, strClientSecure);
			List<NxlCERequest.PolicyResult> listPcResults = new List<NxlCERequest.PolicyResult>();
			statusResult = obCEEnforcer.CheckMultipleResources(ceListRequests, listPcResults, listObligations);
			if(statusResult == NxlCERequest.QueryStatus.S_OK)
			{
                queryResult = true;
				for (NxlCERequest.PolicyResult pcResult : listPcResults)
				{
					if(pcResult == NxlCERequest.PolicyResult.Allow)
					{
						listResults.add(true);
					}
					else
					{
						listResults.add(false);
					}
				}
			}
        }
        catch(Exception exp)
        {
            System.debug('NxlEnforceModule DoMultipleEvalution Exception: ' + exp.getMessage());
        }
        return queryResult;
	}

    public class CEEnforcer
    {
        private integer m_mulLimited;
        private string m_strJavaPcHost;
        private string m_strOAuthServiceHost;
        private string m_strAccount;
        private string m_strPassword;
		private HttpResponse m_response;
		private NxlCERequest.PolicyResult m_policyResult;
        private string m_strToken;
        private integer m_nExpiresIn;
        
        public integer MultipleLimited
        {
            set { m_mulLimited = value; }
        }

		public NxlCERequest.PolicyResult EnforcePolicyResult
        {
			get { return m_policyResult; }
        }

        /// <param name='strPCHost'>Policy control host name, for example 'http://jpc.crm.nextlabs.solutions:58080/'</param>
        /// <param name='strOAuthServiceHost'>OAUTH server  host name, for example 'https://cc.crm.nextlabs.solutions/'</param>
        /// <param name='strClientId'>Client ID, for example 'apiuser'</param>
        /// <param name='strClientSecret'>Client secret number, for example '123456'</param>
        public CEEnforcer(string strPCHost, string strOAuthServiceHost, string strClientId, string strClientSecret)
        {
            m_mulLimited = 100; // Set '100' as deafult limited number.
            m_strJavaPcHost = NxlTranformModule.GetJPCHostUrl(strPCHost);
            m_strOAuthServiceHost = NxlTranformModule.GetAuthHostUrl(strOAuthServiceHost);
            m_strAccount = strClientId;
            m_strPassword = strClientSecret;
			m_strToken = null;
            m_nExpiresIn = 10 * 60;
        }
	
        public NxlCERequest.QueryStatus CheckResource(NxlCERequest.CERequest ceRequest, List<NxlCERequest.CEObligation> listObligation)
        {
            NxlCERequest.QueryStatus statusResult = NxlCERequest.QueryStatus.E_Failed;
			Map<string, string> mapHeaders = new Map<string, string>();
            m_policyResult = NxlCERequest.PolicyResult.DontCare;
            try
            {
				mapHeaders.put(NxlCERequest.ContentType, NxlCERequest.ContentType_JSON);
				mapHeaders.put(NxlCERequest.Service, NxlCERequest.Service_Eval);
				mapHeaders.put(NxlCERequest.Version, NxlCERequest.Version_1_0);
				if(m_strToken == null)
				{
					RefreshToken();
				}
				mapHeaders.put(NxlCERequest.Authorization, m_strToken);
				NxlTranformModule tranformModule = new NxlTranformModule();
                NxlJPCRestRequest.RestRequest restRequest = tranformModule.TransformToSingleRequest(ceRequest);
                string strRestRequest = Json.serialize(restRequest);
		
                if (string.isNotEmpty(strRestRequest) && string.isNotEmpty(m_strToken))
                {
                    statusResult = SendDataAndGetResponse(NxlCERequest.Method_Post, strRestRequest, mapHeaders, m_strJavaPcHost);
					if(statusResult.Equals(NxlCERequest.QueryStatus.E_Unauthorized))
					{
						RefreshToken();
						statusResult = SendDataAndGetResponse(NxlCERequest.Method_Post, strRestRequest, mapHeaders, m_strJavaPcHost);
					}
                    if (statusResult.Equals(NxlCERequest.QueryStatus.S_OK))
                    {
						NxlJPCRestRequest.RestResponse restResponse = (NxlJPCRestRequest.RestResponse)JSON.deserialize(m_response.getbody(), NxlJPCRestRequest.RestResponse.class);
                        if (restResponse != null && restResponse.Response != null && restResponse.Response.Result != null && restResponse.Response.Result.size() > 0)
                        {
                            NxlJPCRestRequest.ResultNode restResult = restResponse.Response.Result[0];
                            if (restResult.Status != null && string.isNotEmpty(restResult.Status.StatusMessage) && restResult.Status.StatusCode != null && string.isNotEmpty(restResult.Status.StatusCode.Value))
                            {
                                string strStatusCode = restResult.Status.StatusCode.Value;
                                statusResult = NxlTranformModule.StatusMsgToPcResult(strStatusCode);
                                if (statusResult.Equals(NxlCERequest.QueryStatus.S_OK))
                                {                                    
                                    m_policyResult = NxlTranformModule.stringToPolicyResult(restResult.Decision);
                                    NxlTranformModule.TransformToCEObligation(restResult, listObligation);
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception exp)
            {
                System.debug('NxlEnforceModule CheckResource Exception: ' + exp.getMessage());
                statusResult = NxlCERequest.QueryStatus.E_Failed;
            }
            System.debug('NxlEnforceModule CheckResource status result:' + statusResult);
            return statusResult;
        }

        public NxlCERequest.QueryStatus CheckMultipleResources(List<NxlCERequest.CERequest> ceListRequests, 
              List<NxlCERequest.PolicyResult> listPcResults, List<List<NxlCERequest.CEObligation>> listObligations)
        {
            System.debug('NxlEnforceModule CheckMultipleResources requests size:' + ceListRequests.size());
            NxlCERequest.QueryStatus statusResult = NxlCERequest.QueryStatus.E_Failed;
            if (ceListRequests == null && ceListRequests.size() == 0)
            {
                return statusResult;
            }
            integer i = 0;
            integer count = ceListRequests.size();
            while(i < count)
            {
                List<NxlCERequest.PolicyResult> listResults = new List<NxlCERequest.PolicyResult>();
                List<List<NxlCERequest.CEObligation>> lsObligations = new List<List<NxlCERequest.CEObligation>>();
                List<NxlCERequest.CERequest> limitedRequests = new List<NxlCERequest.CERequest>();
                if (count > i + m_mulLimited)
                {
					for(integer j = i; j < i + m_mulLimited; j++)
					{
						limitedRequests.add(ceListRequests.get(j));
					}                   
                }
                else
                {
					for(integer j = i; j < count; j++)
					{
						limitedRequests.add(ceListRequests.get(j));
					}
                }
                statusResult = CheckLimitMultipleResources(limitedRequests, listResults, lsObligations);
                if (statusResult != NxlCERequest.QueryStatus.S_OK)
                {
                    break;
                }
                else
                {
                    listPcResults.AddAll(listResults);
                    listObligations.AddAll(lsObligations);
                }
                i += m_mulLimited; 
            }
            return statusResult;
        }

        private NxlCERequest.QueryStatus CheckLimitMultipleResources(List<NxlCERequest.CERequest> ceListRequests,
                List<NxlCERequest.PolicyResult> listPcResults, List<List<NxlCERequest.CEObligation>> listObligations)
        {
			NxlCERequest.QueryStatus statusResult = NxlCERequest.QueryStatus.E_Failed;
			Map<string, string> mapHeaders = new Map<string, string>();
            m_policyResult = NxlCERequest.PolicyResult.DontCare;
            try
            {
				mapHeaders.put(NxlCERequest.ContentType, NxlCERequest.ContentType_JSON);
				mapHeaders.put(NxlCERequest.Service, NxlCERequest.Service_Eval);
				mapHeaders.put(NxlCERequest.Version, NxlCERequest.Version_1_0);
				if(m_strToken == null)
				{
					RefreshToken();
				}
				mapHeaders.put(NxlCERequest.Authorization, m_strToken);
				NxlTranformModule tranformModule = new NxlTranformModule();
                NxlJPCRestRequest.RestMultipleRequest restRequest = tranformModule.TransformMultipleRequests(ceListRequests);
                string strRestRequest = Json.serialize(restRequest);
                if (string.isNotEmpty(strRestRequest) && string.isNotEmpty(m_strToken))
                {
                    statusResult = SendDataAndGetResponse(NxlCERequest.Method_Post, strRestRequest, mapHeaders, m_strJavaPcHost);
					if(statusResult.Equals(NxlCERequest.QueryStatus.E_Unauthorized))
					{
						RefreshToken();
						statusResult = SendDataAndGetResponse(NxlCERequest.Method_Post, strRestRequest, mapHeaders, m_strJavaPcHost);
					}
                    if (statusResult.Equals(NxlCERequest.QueryStatus.S_OK))
                    {
						NxlJPCRestRequest.RestResponse restResponse = (NxlJPCRestRequest.RestResponse)JSON.deserializeStrict(m_response.getbody(), NxlJPCRestRequest.RestResponse.class);
                        if (restResponse != null && restResponse.Response != null && restResponse.Response.Result != null && restResponse.Response.Result.size() > 0)
                        {
							for (NxlJPCRestRequest.ResultNode restResult : restResponse.Response.Result)
							{
                                NxlCERequest.PolicyResult pcResult = NxlCERequest.PolicyResult.DontCare; 
								List<NxlCERequest.CEObligation> listObs = new List<NxlCERequest.CEObligation>();

								if (restResult.Status != null && string.isNotEmpty(restResult.Status.StatusMessage) && restResult.Status.StatusCode != null && string.isNotEmpty(restResult.Status.StatusCode.Value))
								{
									string strStatusCode = restResult.Status.StatusCode.Value;
									statusResult = NxlTranformModule.StatusMsgToPcResult(strStatusCode);
									if (statusResult.Equals(NxlCERequest.QueryStatus.S_OK))
									{
										pcResult = NxlTranformModule.stringToPolicyResult(restResult.Decision);
										NxlTranformModule.TransformToCEObligation(restResult, listObs);
                                    }
								}

                                listPcResults.add(pcResult);
								listObligations.add(listObs);
							}
                        }
                    }
                }
            }
            catch (Exception exp)
            {
                System.debug('NxlEnforceModule CheckLimitMultipleResources Exception: ' + exp.getMessage());
                statusResult = NxlCERequest.QueryStatus.E_Failed;
            }
            System.debug('NxlEnforceModule CheckLimitMultipleResources status result: ' + statusResult);
            return statusResult;
        }
              
        private void RefreshToken()
        {
            NxlCERequest.QueryStatus authorResult = NxlCERequest.QueryStatus.E_Unauthorized;
            Map<string, string> mapHeaders = new Map<string, string>();
            mapHeaders.put(NxlCERequest.ContentType, NxlCERequest.ContentType_X_WWW_From_Urlencoded);
            
            List<string> strList = new string[]{m_strAccount , m_strPassword, string.valueOf(m_nExpiresIn)};
        	string strBody = string.format(NxlCERequest.AuthBodyFormat, strList); 
            authorResult = SendDataAndGetResponse(NxlCERequest.Method_Post, strBody, mapHeaders, m_strOAuthServiceHost);
            if (authorResult.Equals(NxlCERequest.QueryStatus.S_OK))
            {
                NxlJPCRestRequest.TokenResponse tokenResult = (NxlJPCRestRequest.TokenResponse)JSON.deserialize(m_response.getbody(), NxlJPCRestRequest.TokenResponse.class);
				m_strToken = tokenResult.token_type + ' ' + tokenResult.access_token;
            }
        }
        
        private NxlCERequest.QueryStatus SendDataAndGetResponse(string strMethod, string strBody, Map<string, string> mapHeaders, string strUrl)
        {
            System.Debug('NxlEnforceModule SendDataAndGetResponse Url:' + strUrl);
			NxlCERequest.QueryStatus authorResult = NxlCERequest.QueryStatus.E_Unauthorized;
			HttpRequest request = new HttpRequest();
			if(string.isNotEmpty(strBody))
			{
				Blob blobBody = Blob.valueof(strBody);
                request.setBody(strBody);
            	mapHeaders.put(NxlCERequest.ContentLength, string.valueOf(blobBody.size()));
			}
			request.setEndpoint(strUrl);
			request.setMethod(strMethod);
			for(string strKey : mapHeaders.keySet())
			{
				request.setHeader(strKey, mapHeaders.get(strKey));
			}

			Http httpModule = new Http();
			m_response = httpModule.send(request);
			NxlTranformModule tranformModule = new NxlTranformModule();
			authorResult = NxlTranformModule.ConvertStatusCodeToPcResult(m_response.getStatusCode());
			System.Debug('NxlEnforceModule SendDataAndGetResponse response status:' + m_response.getStatusCode());
			return authorResult;            
        }
    }     
}
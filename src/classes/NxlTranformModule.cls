public class NxlTranformModule 
{
    public static string GetJPCHostUrl(string strJPCHost)
    {
        if(!strJPCHost.endsWith(NxlCERequest.HttpSeparator))
        {
            strJPCHost += NxlCERequest.HttpSeparator;
        }
        string strJPCHostUrl = strJPCHost + NxlCERequest.JavaPCPDPSuffix;
        return strJPCHostUrl;
    }
    
    public static string GetAuthHostUrl(string strAuthHost)
    {
        if(!strAuthHost.endsWith(NxlCERequest.HttpSeparator))
        {
            strAuthHost += NxlCERequest.HttpSeparator;
        }
        string strAuthHostUrl = strAuthHost + NxlCERequest.JavaPCOauthSuffix;
        return strAuthHostUrl;
    }
    
    public static string ConvertEvalAction(NxlCERequest.EvalAction action)
    {
        string strAction = 'VIEW';
        if(action == NxlCERequest.EvalAction.CreateAction)
        {
            strAction = 'CREATE';
        }
        else if(action == NxlCERequest.EvalAction.EditAction)
        {
            strAction = 'EDIT';
        }
        else if(action == NxlCERequest.EvalAction.DeleteAction)
        {
            strAction = 'DELETE';
        }
        else if(action == NxlCERequest.EvalAction.AccessAction)
        {
            strAction = 'ACCESS';
        }
        return strAction;
    }
    
    public static NxlCERequest.PolicyResult stringToPolicyResult(string strRestResponse)
    {
        NxlCERequest.PolicyResult result = NxlCERequest.PolicyResult.DontCare;
        if (strRestResponse.equalsIgnoreCase(NxlCERequest.Deny))
        {
            result = NxlCERequest.PolicyResult.Deny;
        }
        else if (strRestResponse.equalsIgnoreCase(NxlCERequest.Allow))
        {
            result = NxlCERequest.PolicyResult.Allow;
        }
        return result;
    }
    	
    public static NxlCERequest.QueryStatus ConvertStatusCodeToPcResult(integer intCode)
    {
        NxlCERequest.QueryStatus statusResult = NxlCERequest.QueryStatus.E_Failed;
		if(intCode == 200)
		{
			statusResult = NxlCERequest.QueryStatus.S_OK;
		}
        else if(intCode == 400)
		{
			statusResult = NxlCERequest.QueryStatus.E_BadRequest;
		}
		else if(intCode == 401)
		{
			statusResult = NxlCERequest.QueryStatus.E_Unauthorized;
		}
		else if(intCode == 500)
		{
			statusResult = NxlCERequest.QueryStatus.E_ServiceUnavailable;
		}

        return statusResult;
    }

	public static NxlCERequest.QueryStatus StatusMsgToPcResult(string strStatusMessage)
    {
        if(strStatusMessage.equalsIgnoreCase(NxlCERequest.Status_Ok))
        {
            return NxlCERequest.QueryStatus.S_OK;
        }
        else if(strStatusMessage.equalsIgnoreCase(NxlCERequest.Status_MissAttributes))
        {
            return NxlCERequest.QueryStatus.E_MissAttributes;
        }
        else
        {
            return NxlCERequest.QueryStatus.E_Failed;
        }

    }

	public static void TransformToCEObligation(NxlJPCRestRequest.ResultNode restResult, List<NxlCERequest.CEObligation> listObligation)
	{
		if (restResult.Obligations != null && restResult.Obligations.size() > 0)
		{
			for (NxlJPCRestRequest.ObligationsNode restObligation : restResult.Obligations)
			{
				string strObligationName = restObligation.Id;
				NxlCERequest.CEAttres ceAttres = new NxlCERequest.CEAttres();
				if (restObligation.AttributeAssignment != null && restObligation.AttributeAssignment.size() > 0)
				{
					for (NxlJPCRestRequest.AttributeAssignmentNode attributeNode : restObligation.AttributeAssignment)
					{
						string strAttrName = attributeNode.AttributeId;
						string strAttributeValue = string.Join(attributeNode.Value, ';');
						ceAttres.addAttribute(strAttrName, strAttributeValue, NxlCERequest.CEAttributeType.XACML_String);
					}

				}
				NxlCERequest.CEObligation ceOblitaion = new NxlCERequest.CEObligation(strObligationName, ceAttres, 'Sorry, javaPC can not get policy name at this version.');
				listObligation.add(ceOblitaion);
			}
		}
	}
    
    public static string ceAttributeTypeToString(NxlCERequest.CEAttributeType ceAttributeType)
    {
        string strResult = null;

        if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_AnyURI)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#anyURI';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_Base64Binary)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#base64Binary';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_Boolean)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#boolean';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_Date)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#date';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_DateTime)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#dateTime';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_DayTimeDuration)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#dayTimeDuration';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_DnsName)
        {
            strResult = 'urn:oasis:names:tc:xacml:2.0:data-type:dnsName';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_Double)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#double';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_HexBinary)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#hexBinary';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_Integer)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#integer';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_IpAddress)
        {
            strResult = 'urn:oasis:names:tc:xacml:2.0:data-type:ipAddress';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_Rfc822Name)
        {
            strResult = 'urn:oasis:names:tc:xacml:1.0:data-type:rfc822Name';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_String)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#string';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_Time)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#time';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_X500Name)
        {
            strResult = 'urn:oasis:names:tc:xacml:1.0:data-type:x500Name';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_XpathExpression)
        {
            strResult = 'urn:oasis:names:tc:xacml:3.0:data-type:xpathExpression';
        }
        else if(ceAttributeType ==  NxlCERequest.CEAttributeType.XACML_YearMonthDuration)
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#yearMonthDuration';
        }
        else
        {
            strResult = 'http://www.w3.org/2001/XMLSchema#string';
        }
        return strResult;
    }
    
    public NxlJPCRestRequest.RestRequest TransformToSingleRequest(NxlCERequest.CERequest ceRequest)
    {
        NxlJPCRestRequest.RestRequest restModel = new NxlJPCRestRequest.RestRequest();

        restModel.Request = new NxlJPCRestRequest.RequestNode();
        restModel.Request.ReturnPolicyIdList = 'true';
        restModel.Request.Category = new List<NxlJPCRestRequest.CategoryNode>();

        NxlCERequest.CEHost ceHost = ceRequest.getHost();
        if(ceHost != null)
        {
            NxlJPCRestRequest.CategoryNode categoryHost = new NxlJPCRestRequest.CategoryNode();
            categoryHost.CategoryId = NxlCERequest.Host_Host;
            categoryHost.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            SetCEHost(ceHost, categoryHost.Attribute);
            restModel.Request.Category.Add(categoryHost);
        }

        NxlCERequest.CEUser ceUser = ceRequest.getUser();
        if (ceUser != null)
        {
            NxlJPCRestRequest.CategoryNode categorySubject = new NxlJPCRestRequest.CategoryNode();
            categorySubject.CategoryId = NxlCERequest.Subject_Access_Subject;
            categorySubject.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            SetCEUser(ceUser, false, categorySubject.Attribute);
            restModel.Request.Category.Add(categorySubject);
        }

        NxlCERequest.CEUser ceRecpient = ceRequest.getRecipient();
        List<string> listRecipients=ceRequest.getRecipients();
        if (ceRecpient != null)
        {
            NxlJPCRestRequest.CategoryNode categorySubject = new NxlJPCRestRequest.CategoryNode();
            categorySubject.CategoryId = NxlCERequest.Recipient_Recipient_Subject;
            categorySubject.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            SetCEUser(ceRecpient, true, categorySubject.Attribute);
            restModel.Request.Category.Add(categorySubject);
        }
        else if(listRecipients!=null)
        {
            NxlJPCRestRequest.CategoryNode categorySubject = new NxlJPCRestRequest.CategoryNode();
            restModel.Request.Category.Add(categorySubject);
            categorySubject.CategoryId = NxlCERequest.Recipient_Recipient_Subject;
            categorySubject.Attribute = new List<NxlJPCRestRequest.AttributeNode>();

            NxlJPCRestRequest.AttributeNode attributeOther = new NxlJPCRestRequest.AttributeNode();
            categorySubject.Attribute.Add(attributeOther);
            attributeOther.AttributeId = NxlCERequest.Recipient_Email;
            attributeOther.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
            attributeOther.IncludeInResult = false;
            for (string strRecipient : listRecipients)
            {
                attributeOther.Value.Add(strRecipient);
            }
        }

        NxlCERequest.CEResource ceSource = ceRequest.getSource();
        if (ceSource != null)
        {
            NxlJPCRestRequest.CategoryNode categorySource = new NxlJPCRestRequest.CategoryNode();
            categorySource.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            categorySource.CategoryId = NxlCERequest.Resource_Resource;
            SetCEResource(ceSource, NxlCERequest.Resource_Dimension_From, categorySource.Attribute);
            restModel.Request.Category.Add(categorySource);
        }

        NxlCERequest.CEResource ceDest = ceRequest.getDest();
        if (ceDest != null)
        {
            NxlJPCRestRequest.CategoryNode categorySource = new NxlJPCRestRequest.CategoryNode();
            categorySource.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            categorySource.CategoryId = NxlCERequest.Resource_Resource;
            SetCEResource(ceSource, NxlCERequest.Resource_Dimension_To, categorySource.Attribute);
            restModel.Request.Category.Add(categorySource);
        }

        string strAction = ceRequest.getAction();
        if (string.isNotEmpty(strAction))
        {
            NxlJPCRestRequest.CategoryNode categoryAction = new NxlJPCRestRequest.CategoryNode();
            restModel.Request.Category.Add(categoryAction);
            categoryAction.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            categoryAction.CategoryId = NxlCERequest.Action_Action;
            NxlJPCRestRequest.AttributeNode attributeAction = new NxlJPCRestRequest.AttributeNode();
            categoryAction.Attribute.Add(attributeAction);
            attributeAction.AttributeId = NxlCERequest.Action_Action_Id;
            attributeAction.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
            attributeAction.IncludeInResult = false;
            attributeAction.Value.Add( strAction);
        }

        NxlCERequest.CEApp ceApp = ceRequest.getApp();
        if (ceApp != null)
        {
            NxlJPCRestRequest.CategoryNode categoryApplication = new NxlJPCRestRequest.CategoryNode();
            categoryApplication.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            categoryApplication.CategoryId =NxlCERequest.Application;
            SetCEApp(ceApp, categoryApplication.Attribute);
            restModel.Request.Category.Add(categoryApplication);                
        }

        NxlCERequest.CEAttres ceNameAttribute = ceRequest.getNameAttributes();
        if (ceNameAttribute != null)
        {
            NxlJPCRestRequest.CategoryNode categoryNameAttributes = new NxlJPCRestRequest.CategoryNode();
            restModel.Request.Category.Add(categoryNameAttributes);
            categoryNameAttributes.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            categoryNameAttributes.CategoryId = NxlCERequest.Environment;
            SetCEAttrsToList(ceNameAttribute, NxlCERequest.Enviroment_Prefix, categoryNameAttributes.Attribute);
        }

        return restModel;
    }
    
    public NxlJPCRestRequest.RestMultipleRequest TransformMultipleRequests(List<NxlCERequest.CERequest> ceListRequests)
    {
        NxlJPCRestRequest.RestMultipleRequest restModel = new NxlJPCRestRequest.RestMultipleRequest();
        restModel.Request = new NxlJPCRestRequest.RequestMultipleNode();
        restModel.Request.CombinedDecision = false;
        restModel.Request.ReturnPolicyIdList = false;
        restModel.Request.XPathVersion = 'http://www.w3.org/TR/1999/REC-xpath-19991116';
        restModel.Request.Category = new List<NxlJPCRestRequest.CategoryMultipleNode>();
        restModel.Request.Subject = new List<NxlJPCRestRequest.CategoryMultipleNode>();
        restModel.Request.Action = new List<NxlJPCRestRequest.CategoryMultipleNode>();
        restModel.Request.Resource = new List<NxlJPCRestRequest.CategoryMultipleNode>();
        restModel.Request.MultiRequests = new NxlJPCRestRequest.ReferenceNode();
        restModel.Request.MultiRequests.RequestReference = new List<NxlJPCRestRequest.ReferenceIdNode>();

        Map<string, string> mapCEHostId = new Map<string, string>();
        Map<string, string> mapCEUserId = new Map<string, string>();
        Map<string, string> mapRecipentId = new Map<string, string>();
        Map<string, string> mapResourceId = new Map<string, string>();
        Map<string, string> mapActionId = new Map<string, string>();
        Map<string, string> mapAppId = new Map<string, string>();
        Map<string, string> mapEnvironmentId = new Map<string, string>();

        // Just set one Environment.
        SetMultipleEnvironment(restModel, ceListRequests[0]);

        for (NxlCERequest.CERequest ceRequest : ceListRequests)
        {
            NxlCERequest.CEReferenceId referenceId = new NxlCERequest.CEReferenceId();
            // Host
            SetMultipleHost(restModel, ceRequest, referenceId, mapCEHostId);

            // User
            SetMultipleUser(restModel, ceRequest, referenceId, mapCEUserId);

            // Recipent
            SetMultipleRecipent(restModel, ceRequest, referenceId, mapRecipentId);

            // Resource
            SetMultipleResource(restModel, ceRequest, referenceId, mapResourceId);

            // Action
            SetMultipleAction(restModel, ceRequest, referenceId, mapActionId);

            // App
            SetMultipleApp(restModel, ceRequest, referenceId, mapAppId);                

            SetReferenceId(restModel.Request.MultiRequests.RequestReference, referenceId);
        }

        return restModel;
    }
    
	private void SetCEHost(NxlCERequest.CEHost ceHost, List<NxlJPCRestRequest.AttributeNode> listAttribute)
	{
        if (string.isNotEmpty(ceHost.IPAddress))
        {
            NxlJPCRestRequest.AttributeNode attributeIPAddress = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeIPAddress);
            attributeIPAddress.AttributeId = NxlCERequest.Host_Inet_Address;
            attributeIPAddress.Value.add(ceHost.IPAddress);
            attributeIPAddress.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_IpAddress);
            attributeIPAddress.IncludeInResult = false;
        }
        if (string.isNotEmpty(ceHost.Name))
        {
            NxlJPCRestRequest.AttributeNode attributeName = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeName);
            attributeName.AttributeId = NxlCERequest.Host_Name;
            attributeName.Value.add(ceHost.Name);
            attributeName.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
            attributeName.IncludeInResult = false;
        }
        if (ceHost.Attres != null)
        {
            SetCEAttrsToList(ceHost.Attres, NxlCERequest.Host_Prefix, listAttribute);
        }
    }

    private void SetCEUser(NxlCERequest.CEUser ceUser, boolean bRecipent, List<NxlJPCRestRequest.AttributeNode> listAttribute)
    {
        if (string.isNotEmpty(ceUser.Sid))
        {
            NxlJPCRestRequest.AttributeNode attributeSid = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeSid);
            attributeSid.AttributeId = bRecipent ? NxlCERequest.Recipient_Id : NxlCERequest.Subject_Subejct_Id;
            attributeSid.Value.add(ceUser.Sid);
            attributeSid.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
            attributeSid.IncludeInResult = false;
        }
        if (string.isNotEmpty(ceUser.Name))
        {
            NxlJPCRestRequest.AttributeNode attributeName = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeName);
            attributeName.AttributeId = bRecipent ? NxlCERequest.Recipient_Name : NxlCERequest.Subject_Subject_Name;
            attributeName.Value.add(ceUser.Name);
            attributeName.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
            attributeName.IncludeInResult = false;
        }
        if (ceUser.Attres != null)
        {
            string strPrefix = bRecipent ? NxlCERequest.Recipient_Prefix : NxlCERequest.Subject_Prefix;
            SetCEAttrsToList(ceUser.Attres, strPrefix, listAttribute);
        }
    }

    private void SetCEResource(NxlCERequest.CEResource ceSource, string srcType, List<NxlJPCRestRequest.AttributeNode> listAttribute)
    {
        if (string.isNotEmpty(ceSource.SourceName))
        {
            NxlJPCRestRequest.AttributeNode attributeSoueceId = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeSoueceId);
            attributeSoueceId.AttributeId = NxlCERequest.Resource_Resource_Id;
            attributeSoueceId.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_AnyURI);
            attributeSoueceId.IncludeInResult = false;
            attributeSoueceId.Value.add(ceSource.SourceName);
        }
        if (string.isNotEmpty(ceSource.SourceType))
        {
            NxlJPCRestRequest.AttributeNode attributeSourceType = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeSourceType);
            attributeSourceType.AttributeId = NxlCERequest.Resource_Resource_Type;
            attributeSourceType.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_AnyURI);
            attributeSourceType.IncludeInResult = false;
            attributeSourceType.Value.add(ceSource.SourceType);
        }
        {
            NxlJPCRestRequest.AttributeNode attributeSourceDimension = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeSourceDimension);
            attributeSourceDimension.AttributeId = NxlCERequest.Resource_Resource_Dimension;
            attributeSourceDimension.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_AnyURI);
            attributeSourceDimension.IncludeInResult = false;
            attributeSourceDimension.Value.add(srcType);
        }
        if (ceSource.Attres != null)
        {
            SetCEAttrsToList(ceSource.Attres, NxlCERequest.Resource_Prefix, listAttribute);
        }
    }
       
    private void SetCEApp(NxlCERequest.CEApp ceApp, List<NxlJPCRestRequest.AttributeNode> listAttribute)
    {
        if (string.isNotEmpty(ceApp.Name))
        {
            NxlJPCRestRequest.AttributeNode attributeAppId = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeAppId);
            attributeAppId.AttributeId = NxlCERequest.Application_Application_Id;
            attributeAppId.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
            attributeAppId.IncludeInResult = false;
            attributeAppId.Value.add(ceApp.Name);
        }

        if (string.isNotEmpty(ceApp.Path))
        {
            NxlJPCRestRequest.AttributeNode attributeAppName = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeAppName);
            attributeAppName.AttributeId = NxlCERequest.Application_Application_Name;
            attributeAppName.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
            attributeAppName.IncludeInResult = false;
            attributeAppName.Value.add(ceApp.Path);
        }
        if (string.isNotEmpty(ceApp.Url))
        {
            NxlJPCRestRequest.AttributeNode attributeAppUrl = new NxlJPCRestRequest.AttributeNode();
            listAttribute.add(attributeAppUrl);
            attributeAppUrl.AttributeId = NxlCERequest.Application_Application_Url;
            attributeAppUrl.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
            attributeAppUrl.IncludeInResult = false;
            attributeAppUrl.Value.add(ceApp.Url);
        }
        if (ceApp.Attres != null)
        {
            SetCEAttrsToList(ceApp.Attres, NxlCERequest.Application_Application_Prefix, listAttribute);
        }
    }

    private void SetCEAttrsToList(NxlCERequest.CEAttres ceAttrs, string strPrefix, List<NxlJPCRestRequest.AttributeNode> listAttribute)
    {
        Map<string, NxlJPCRestRequest.AttributeNode> mapAttrs = new Map<string, NxlJPCRestRequest.AttributeNode>(); 
        List<NxlCERequest.CEAttribute> listAttrs = ceAttrs.getAttributes();
        for (NxlCERequest.CEAttribute ceAttr : listAttrs)
        {
            string strName = ceAttr.Name.toLowerCase();
            string strValue = ceAttr.Value; 
            NxlCERequest.CEAttributeType ceAttributeType = ceAttr.Type;
                    
            if (string.isNotEmpty(strName) && string.isNotEmpty(strValue))
            {                        
                NxlJPCRestRequest.AttributeNode attributeNode = null;
                if (mapAttrs.ContainsKey(strName))
                {
                    attributeNode = mapAttrs.get(strName);
                }
                else
                {
                    attributeNode = new NxlJPCRestRequest.AttributeNode();
                    attributeNode.AttributeId = strPrefix + strName;
                    attributeNode.DataType = ceAttributeTypeToString(ceAttributeType);
                    attributeNode.IncludeInResult = false;                            
                    listAttribute.add(attributeNode);
                    mapAttrs.put(strName, attributeNode);
                }
                attributeNode.Value.add(strValue);                                                                                              
            }
        }
	}    
    
    private void SetMultipleHost(NxlJPCRestRequest.RestMultipleRequest restModel, NxlCERequest.CERequest ceRequest,
        NxlCERequest.CEReferenceId referenceId, Map<string, string> mapCEHostId)
    {
        NxlCERequest.CEHost ceHost = ceRequest.getHost();
        if (ceHost != null)
        {
            string ipAddr = ceHost.IPAddress;
            if (string.isEmpty(ipAddr))
            {
                ipAddr = 'UnknowHost' + string.valueOf(mapCEHostId.size());
            }
            if (mapCEHostId.ContainsKey(ipAddr))
            {
                referenceId.Host = mapCEHostId.get(ipAddr);
            }
            else
            {
                NxlJPCRestRequest.CategoryMultipleNode categoryHost = new NxlJPCRestRequest.CategoryMultipleNode();
                categoryHost.CategoryId = NxlCERequest.Host_Host;
                categoryHost.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
                SetCEHost(ceHost, categoryHost.Attribute);
                restModel.Request.Category.Add(categoryHost);
                string id = 'Host' + string.valueOf(mapCEHostId.size());
                mapCEHostId.put(ipAddr, id);
                referenceId.Host = id;
                categoryHost.Id = id;
            }
        }
    }

    private void SetMultipleUser(NxlJPCRestRequest.RestMultipleRequest restModel, NxlCERequest.CERequest ceRequest,
        NxlCERequest.CEReferenceId referenceId, Map<string, string> mapCEUserId)
    {
        NxlCERequest.CEUser ceUser = ceRequest.getUser();
        if (ceUser != null)
        {
            string sid = ceUser.Sid;
            if (string.isEmpty(sid))
            {
                sid = 'UnknowUser' + string.valueOf(mapCEUserId.size());
            }
            if (mapCEUserId.ContainsKey(sid))
            {
                referenceId.Subject = mapCEUserId.get(sid);
            }
            else
            {
                NxlJPCRestRequest.CategoryMultipleNode categorySubject = new NxlJPCRestRequest.CategoryMultipleNode();
                restModel.Request.Subject.Add(categorySubject);                    
                categorySubject.CategoryId = NxlCERequest.Subject_Access_Subject;
                categorySubject.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
                SetCEUser(ceUser, false, categorySubject.Attribute);
                string id = 'User' + string.valueOf(mapCEUserId.size());
                mapCEUserId.put(sid, id);
                referenceId.Subject = id;
                categorySubject.Id = id;
            }
        }
    }

    private void SetMultipleRecipent(NxlJPCRestRequest.RestMultipleRequest restModel, NxlCERequest.CERequest ceRequest,
        NxlCERequest.CEReferenceId referenceId, Map<string, string> mapRecipentId)
    {
        NxlCERequest.CEUser ceRecpient = ceRequest.getRecipient();
        List<string> listRecipients = ceRequest.getRecipients();
        if (ceRecpient != null)
        {
            string sid = ceRecpient.Sid;
            if (string.isEmpty(sid))
            {
                sid = 'UnknowRecpient' + string.valueOf(mapRecipentId.size());
            }
            if (mapRecipentId.ContainsKey(sid))
            {
                referenceId.AdditionalData = mapRecipentId.get(sid);
            }
            else
            {
                NxlJPCRestRequest.CategoryMultipleNode categorySubject = new NxlJPCRestRequest.CategoryMultipleNode();
                categorySubject.CategoryId = NxlCERequest.Recipient_Recipient_Subject;
                categorySubject.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
                SetCEUser(ceRecpient, true, categorySubject.Attribute);
                restModel.Request.Category.Add(categorySubject);
                string id = 'Recipent' + string.valueOf(mapRecipentId.size());
                mapRecipentId.put(sid, id);
                referenceId.AdditionalData = id;
                categorySubject.Id = id;
            }
        }
        else if (listRecipients != null && listRecipients.size() > 0)
        {
            string emails = string.join(listRecipients, ';');
            if (string.isEmpty(emails))
            {
                emails = 'UnknowRecpients' + string.valueOf(mapRecipentId.size());
            }
            if (mapRecipentId.ContainsKey(emails))
            {
                referenceId.AdditionalData = mapRecipentId.get(emails);
            }
            else
            {
                NxlJPCRestRequest.CategoryMultipleNode categorySubject = new NxlJPCRestRequest.CategoryMultipleNode();
                restModel.Request.Category.Add(categorySubject);
                categorySubject.CategoryId = NxlCERequest.Recipient_Recipient_Subject;
                categorySubject.Attribute = new List<NxlJPCRestRequest.AttributeNode>();

                NxlJPCRestRequest.AttributeNode attributeOther = new NxlJPCRestRequest.AttributeNode();
                categorySubject.Attribute.Add(attributeOther);
                attributeOther.AttributeId = NxlCERequest.Recipient_Email;
                attributeOther.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
                attributeOther.IncludeInResult = false;
                for (string strRecipient : listRecipients)
                {
                    attributeOther.Value.Add(strRecipient);
                }
                string id = 'Recipents' + string.valueOf(mapRecipentId.size());
                mapRecipentId.put(emails, id);
                referenceId.AdditionalData = id;
                categorySubject.Id = id;
            }
        }            
    }

    private void SetMultipleResource(NxlJPCRestRequest.RestMultipleRequest restModel, NxlCERequest.CERequest ceRequest,
        NxlCERequest.CEReferenceId referenceId, Map<string, string> mapResourceId)
    {
        NxlCERequest.CEResource ceResource = ceRequest.getSource();
        if (ceResource != null)
        {
            string srcName = ceResource.SourceName;
            if (string.isEmpty(srcName))
            {
                srcName = 'UnknowResource' + string.valueOf(mapResourceId.size());
            }
            if (mapResourceId.ContainsKey(srcName))
            {
                referenceId.Resource = mapResourceId.get(srcName);
            }
            else
            {
                NxlJPCRestRequest.CategoryMultipleNode categorySource = new NxlJPCRestRequest.CategoryMultipleNode();
                categorySource.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
                categorySource.CategoryId = NxlCERequest.Resource_Resource;
                SetCEResource(ceResource, NxlCERequest.Resource_Dimension_From, categorySource.Attribute);
                restModel.Request.Resource.Add(categorySource);
                string id = 'Resource' + string.valueOf(mapResourceId.size());
                mapResourceId.put(srcName, id);
                referenceId.Resource = id;
                categorySource.Id = id;
            }
        }
    }
        
    private void SetMultipleAction(NxlJPCRestRequest.RestMultipleRequest restModel, NxlCERequest.CERequest ceRequest,
        NxlCERequest.CEReferenceId referenceId, Map<string, string> mapActionId)
    {
        string strAction = ceRequest.getAction();
        if (string.isNotEmpty(strAction))
        {
            if (mapActionId.ContainsKey(strAction))
            {
                referenceId.Action = mapActionId.get(strAction);
            }
            else
            {
                NxlJPCRestRequest.CategoryMultipleNode categoryAction = new NxlJPCRestRequest.CategoryMultipleNode();
                restModel.Request.Action.Add(categoryAction);
                categoryAction.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
                categoryAction.CategoryId = NxlCERequest.Action_Action;
                NxlJPCRestRequest.AttributeNode attributeAction = new NxlJPCRestRequest.AttributeNode();
                categoryAction.Attribute.Add(attributeAction);
                attributeAction.AttributeId = NxlCERequest.Action_Action_Id;
                attributeAction.DataType = ceAttributeTypeToString(NxlCERequest.CEAttributeType.XACML_String);
                attributeAction.IncludeInResult = false;
                attributeAction.Value.Add(strAction);
                string id = 'Action' + string.valueOf(mapActionId.size());
                mapActionId.put(strAction, id);
                referenceId.Action = id;
                categoryAction.Id = id;
            }
        }
    }

    private void SetMultipleApp(NxlJPCRestRequest.RestMultipleRequest restModel, NxlCERequest.CERequest ceRequest,
        NxlCERequest.CEReferenceId referenceId, Map<string, string> mapAppId)
    {
        NxlCERequest.CEApp ceApp = ceRequest.getApp();
        if (ceApp != null)
        {
            string appName = ceApp.Name;
            if (string.isEmpty(appName))
            {
                appName = 'UnknowApp' + string.valueOf(mapAppId.size());
            }
            if (mapAppId.ContainsKey(appName))
            {
                referenceId.App = mapAppId.get(appName);
            }
            else
            {
                NxlJPCRestRequest.CategoryMultipleNode categoryApplication = new NxlJPCRestRequest.CategoryMultipleNode();
                categoryApplication.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
                categoryApplication.CategoryId = NxlCERequest.Application;
                SetCEApp(ceApp, categoryApplication.Attribute);
                restModel.Request.Category.Add(categoryApplication);
                string id = 'App' + string.valueOf(mapAppId.size());
                mapAppId.put(appName, id);
                referenceId.App = id;
                categoryApplication.Id = id;
            }
        }
    }

    private void SetMultipleEnvironment(NxlJPCRestRequest.RestMultipleRequest restModel, NxlCERequest.CERequest ceRequest)
    {
        NxlCERequest.CEAttres ceNameAttribute = ceRequest.getNameAttributes();
        if (ceNameAttribute != null)
        {
            NxlJPCRestRequest.CategoryMultipleNode categoryNameAttributes = new NxlJPCRestRequest.CategoryMultipleNode();
            restModel.Request.Category.Add(categoryNameAttributes);
            categoryNameAttributes.Attribute = new List<NxlJPCRestRequest.AttributeNode>();
            categoryNameAttributes.CategoryId = NxlCERequest.Environment;
            categoryNameAttributes.Id = 'Environment';
            SetCEAttrsToList(ceNameAttribute, NxlCERequest.Enviroment_Prefix, categoryNameAttributes.Attribute);                
        }           
    }

    private void SetReferenceId(List<NxlJPCRestRequest.ReferenceIdNode> listReferenceId, NxlCERequest.CEReferenceId referenceId)
    {
        NxlJPCRestRequest.ReferenceIdNode referenceIdNode = new NxlJPCRestRequest.ReferenceIdNode();
        referenceIdNode.ReferenceId = new List<string>();
        if (string.isNotEmpty(referenceId.Subject))
        {
            referenceIdNode.ReferenceId.Add(referenceId.Subject);            
        }
        if (string.isNotEmpty(referenceId.Action ))
        {
            referenceIdNode.ReferenceId.Add(referenceId.Action);
        }
        if (string.isNotEmpty(referenceId.Resource ))
        {
            referenceIdNode.ReferenceId.Add(referenceId.Resource);
        }
        if (string.isNotEmpty(referenceId.App ))
        {
            referenceIdNode.ReferenceId.Add(referenceId.App);
        }
        if (string.isNotEmpty(referenceId.Host ))
        {
            referenceIdNode.ReferenceId.Add(referenceId.Host);
        }
        if (string.isNotEmpty(referenceId.AdditionalData ))
        {
            referenceIdNode.ReferenceId.Add(referenceId.AdditionalData);
        }

        listReferenceId.Add(referenceIdNode);
    }   
}
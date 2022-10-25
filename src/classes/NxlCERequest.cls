public class NxlCERequest 
{   
    public static string JavaPCPDPSuffix = 'dpc/authorization/pdp';
    public static string JavaPCOauthSuffix = 'cas/token';

    public static integer MaxConnect = 32;
    public static string Method_Post = 'POST';
    public static string Service_Eval = 'EVAL';
    public static string Service = 'Service';
    public static string Version = 'Version';
    public static string Authorization = 'Authorization';
    public static string Version_1_0 = '1.0';
    public static integer TimeOut = 60000;

    public static string ContentType = 'content-type';
    public static string ContentLength = 'content-length';
    public static string ContentType_Unknow = 'application/Unknow';
    public static string ContentType_JSON = 'application/json';
    public static string ContentType_XML = 'application/xml';
    public static string ContentType_X_WWW_From_Urlencoded = 'application/x-www-form-urlencoded';

    public static string Endcoding_UTF_8 = 'UTF-8';
    public static string HttpSeparator = '/';
    public static string AlwaysAllow = 'AlwaysAllow';

    public static string X_WWW_From_Urlencoded_Data_Format = 'username={0}&password={1}';
    public static string X_WWW_From_Urlencoded_Service = 'service={0}';
    public static string UrlParameter_Getting_Authentication_Cookie = '{0}?ticket={1}';
    public static string AuthBodyFormat = 'grant_type=client_credentials&client_id={0}&client_secret={1}&expires_in={2}';
    public static string Header_Key_Location = 'Location';

    public static string Status_Ok = 'urn:oasis:names:tc:xacml:1.0:status:ok';
    public static string Status_MissAttributes = 'urn:oasis:names:tc:xacml:1.0:status:missing-attribute';

    public static string Deny = 'Deny';
    public static string Allow = 'Permit';

    public static string Subject_Access_Subject = 'urn:oasis:names:tc:xacml:1.0:subject-category:access-subject';
    public static string Subject_Subejct_Id = 'urn:oasis:names:tc:xacml:1.0:subject:subject-id';
    public static string Subject_Subject_Name = 'urn:oasis:names:tc:xacml:1.0:subject:name';
    public static string Subject_Prefix = 'urn:oasis:names:tc:xacml:1.0:subject:';

    public static string Host_Host = 'urn:nextlabs:names:evalsvc:1.0:attribute-category:host';
    public static string Host_Inet_Address = 'urn:nextlabs:names:evalsvc:1.0:host:inet_address';
    public static string Host_Name = 'urn:nextlabs:names:evalsvc:1.0:host:name';
    public static string Host_Prefix = 'urn:nextlabs:names:evalsvc:1.0:host:';

    public static string Recipient_Recipient_Subject= 'urn:oasis:names:tc:xacml:1.0:subject-category:recipient-subject';
    public static string Recipient_Id = 'urn:nextlabs:names:evalsvc:1.0:recipient:id';
    public static string Recipient_Name = 'urn:nextlabs:names:evalsvc:1.0:recipient::name';
    public static string Recipient_Prefix = 'urn:nextlabs:names:evalsvc:1.0:recipient:';
    public static string Recipient_Email = 'urn:nextlabs:names:evalsvc:1.0:recipient:email';

    public static string Resource_Resource = 'urn:oasis:names:tc:xacml:3.0:attribute-category:resource';
    public static string Resource_Resource_Id = 'urn:oasis:names:tc:xacml:1.0:resource:resource-id';
    public static string Resource_Resource_Type = 'urn:nextlabs:names:evalsvc:1.0:resource:resource-type';
    public static string Resource_Resource_Dimension = 'urn:nextlabs:names:evalsvc:1.0:resource:resource-dimension';
    public static string Resource_Dimension_From = 'from';
    public static string Resource_Dimension_To = 'to';
    public static string Resource_Prefix = 'urn:nextlabs:names:evalsvc:1.0:resource:';

    public static string Action_Action = 'urn:oasis:names:tc:xacml:3.0:attribute-category:action';
    public static string Action_Action_Id = 'urn:oasis:names:tc:xacml:1.0:action:action-id';

    public static string Application = 'urn:nextlabs:names:evalsvc:1.0:attribute-category:application';
    public static string Application_Application_Id = 'urn:nextlabs:names:evalsvc:1.0:application:application-id';
    public static string Application_Application_Name = 'urn:nextlabs:names:evalsvc:1.0:application:name';
    public static string Application_Application_Url = 'urn:nextlabs:names:evalsvc:1.0:application:url';
    public static string Application_Application_Prefix = 'urn:nextlabs:names:evalsvc:1.0:application:application:';

    public static string Environment = 'urn:oasis:names:tc:xacml:3.0:attribute-category:environment';
    public static string Enviroment_Prefix = 'urn:oasis:names:tc:xacml:1.0:environment:';
    
    public enum EvalAction
    {
        CreateAction,
        ReadAction, 
        EditAction,
        DeleteAction,
        AccessAction
    }
    
    public enum CEResourceType
    {
        Source,
        Destination,
        NameAttributes
    }
    
    // Noise level
    public enum CENoiseLevel
    {
        CE_NOISE_LEVEL_MIN,
        CE_NOISE_LEVEL_SYSTEM,
        CE_NOISE_LEVEL_APPLICATION,
        CE_NOISE_LEVEL_USER_ACTION,
        CE_NOISE_LEVEL_MAX
    }

    /// Query policy result: policy allow, policy deny, do not care (no policy matched)
    public enum PolicyResult
    {
        Deny,
        Allow,
        DontCare
    }

    public enum CEAttributeType
    {
        XACML_String,
        XACML_Boolean,
        XACML_Integer,
        XACML_Double,
        XACML_Time,
        XACML_Date,
        XACML_DateTime,
        XACML_DayTimeDuration,
        XACML_YearMonthDuration,
        XACML_AnyURI,
        XACML_HexBinary,
        XACML_Base64Binary,
        XACML_Rfc822Name,
        XACML_X500Name,
        XACML_IpAddress,
        XACML_DnsName,
        XACML_XpathExpression
    }

    public enum QueryStatus
    {
        S_OK,
        E_Failed,
        E_Unauthorized,
        E_BadRequest,        
        E_ServiceUnavailable,
		E_MissAttributes
    }

    public class CEApp
    {
        public CEApp() { }
        public CEApp(string strName, string strPath, string strUrl, CEAttres attres)
        {
            Name = strName;
            Path = strPath;
            Url = strUrl;
            Attres = attres;
        }
        public string Name { get; set; }
        public string Path { get; set; }
        public string Url { get; set; }
        public CEAttres Attres { get; set; }
    }
    
    public class CEUser
    {
        public CEUser() { }
        public CEUser(string strSid, string strName, CEAttres attres)
        {
            Sid = strSid;
            Name = strName;
            Attres = attres;
        }
        public string Sid { get; set; }
        public string Name { get; set; }
        public CEAttres Attres { get; set; }
    }
    
    public class CEHost
    {
        public CEHost() { }
        public string IPAddress { get; set; }
        public string Name { get; set; }
        public CEAttres Attres { get; set; }
        public CEHost(string strName, string strIPAddress, CEAttres attres)
        {
            Name = strName;
            IPAddress = strIPAddress;
            Attres = attres;
        }
    }
    
    public class CEResource
    {
        public CEResource() { }
        public CEResource(string strName, string strType, CEAttres attres)
        {
            SourceName = strName;
            SourceType = strType;
            Attres = attres;
        }
        public string SourceName { get; set; }
        public string SourceType { get; set; }
        public CEAttres Attres { get; set; }
    }

    public class CEReferenceId
    {
        public CEReferenceId() 
        {
        }
        public CEReferenceId(string strSubject, string strResource, string strAction, string strApp, string strHost, string strAdditionalData)
        {
            Subject = strSubject;
            Resource = strResource;
            Action = strAction;
            App = strApp;
            Host = strHost;
            AdditionalData = strAdditionalData;
        }
        public string Subject { get; set; }
        public string Resource { get; set; }
        public string Action { get; set; }
        public string App { get; set; }
        public string Host { get; set; }
        public string AdditionalData { get; set; }
    }

    public class CEAttribute
    {
        public string Name { get; set; }
        public string Value { get; set; }
        public CEAttributeType Type { get; set; }

        public CEAttribute(string strName, string strValue, CEAttributeType emAttributeType)
        {
            Name = strName;
            Value = strValue;
            Type = emAttributeType;
        }
    }

    public class CEAttres
    {
        private List<CEAttribute> m_lisKeyValuePair;

        public CEAttres()
        {
            m_lisKeyValuePair = new List<CEAttribute>();
        }

        public void addAttribute(string strName, string strValue, CEAttributeType emAttributesType)
        {
            CEAttribute pair = new CEAttribute(strName, strValue, emAttributesType);
            m_lisKeyValuePair.Add(pair);
        }

        public List<CEAttribute> getAttributes()
        {
            return m_lisKeyValuePair;
        }
    }

    public class CERequest
    {
        private string m_strAction;
        private CEApp m_ceApp;
        private CENoiseLevel m_emNotiseLevel;
        private CEUser m_ceUser;
        private CEHost m_ceHost;
        private CEResource m_ceSource;
        private CEResource m_ceDest;
        private CEAttres m_ceNameAttributes;
        private CEUser m_ceRecipient;
        private List<string> m_lsRecipients;

        public CERequest()
        {

        }

        public void setAction(string strAction)
        {
            m_strAction = strAction;
        }

        public void setApp(string strName, string strPath, string strUrl, CEAttres ceAttres)
        {
            if (m_ceApp == null)
            {
                m_ceApp = new CEApp();
            }
            m_ceApp.Name = strName;
            m_ceApp.Path = strPath;
            m_ceApp.Url = strUrl;
            m_ceApp.Attres = ceAttres;
        }

        public void setNoiseLevel(CENoiseLevel emNoiseLevel)
        {
            m_emNotiseLevel = emNoiseLevel;
        }

        public void setUser(string strSid, string strName, CEAttres ceAttres)
        {
            if (m_ceUser == null)
            {
                m_ceUser = new CEUser();
            }
            m_ceUser.Sid = strSid;
            m_ceUser.Name = strName;
            m_ceUser.Attres = ceAttres;
        }

        public void setHost(string strName, string strIPAddress, CEAttres ceAttres)
        {
            if (m_ceHost == null)
            {
                m_ceHost = new CEHost();
            }
            m_ceHost.Name = strName;
            m_ceHost.IPAddress = strIPAddress;
            m_ceHost.Attres = ceAttres;
        }

        public void setSource(string strSourceName, string strSourceType, CEAttres ceAttres)
        {
            if (m_ceSource == null)
            {
                m_ceSource = new CEResource();
            }
            m_ceSource.SourceName = strSourceName;
            m_ceSource.SourceType = strSourceType;
            m_ceSource.Attres = ceAttres;
        }

        public void setDest(string strDestName, string strDestType, CEAttres ceAttres)
        {
            if (m_ceDest == null)
            {
                m_ceDest = new CEResource();
            }
            m_ceDest.SourceName = strDestName;
            m_ceDest.SourceType = strDestType;
            m_ceDest.Attres = ceAttres;
        }

        public void setNameAttributes(string strName, string strValue, CEAttributeType emAttributeType)
        {
            if (m_ceNameAttributes == null)
            {
                m_ceNameAttributes = new CEAttres();
            }
            m_ceNameAttributes.addAttribute(strName, strValue, emAttributeType);
        }

        public void setRecipient(string strSid, string strName, CEAttres ceAttres)
        {
            if (m_ceRecipient == null)
            {
                m_ceRecipient = new CEUser();
            }
            m_ceRecipient.Sid = strSid;
            m_ceRecipient.Name = strName;
            m_ceRecipient.Attres = ceAttres;
        }

        public void setRecipient(string[] szStrEmailAddresses)
        {
            if (m_lsRecipients == null)
            {
                m_lsRecipients = new List<string>();
            }
            for (string strEmailAddress : szStrEmailAddresses)
            {
                m_lsRecipients.Add(strEmailAddress);
            }
        }

        public string getAction()
        {
            return m_strAction;
        }
        
        public CEApp getApp()
        {
            return m_ceApp;
        }
        
        public CENoiseLevel getnoiseLevel()
        {
            return m_emNotiseLevel;
        }
        
        public CEUser getUser()
        {
            return m_ceUser;
        }
        
        public CEHost getHost()
        {
            return m_ceHost;
        }
        
        public CEResource getSource()
        {
            return m_ceSource;
        }
        
        public CEResource getDest()
        {
            return m_ceDest;
        }
        
        public CEAttres getNameAttributes()
        {
            return m_ceNameAttributes;
        }
        
        public CEUser getRecipient()
        {
            return m_ceRecipient;
        }
        
        public List<string> getRecipients()
        {
            return m_lsRecipients;
        }
    }

    public class CEObligation
    {
        private CEAttres m_CEAttres;
        private string m_strObligationName;
        private string m_strPolicyName;

        public CEObligation(string strObligationnName, CEAttres ceAttres, string strPolicyName)
        {
            m_CEAttres = ceAttres;
            m_strObligationName = strObligationnName;
            m_strPolicyName = strPolicyName;
        }

        public CEAttres GetCEAttres()
        {
            return m_CEAttres;
        }

        public string getName()
        {
            return m_strObligationName;
        }

        public string getPolicyName()
        {
            return m_strPolicyName;
        }
    }    
}
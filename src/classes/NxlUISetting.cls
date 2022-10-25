public class NxlUISetting 
{
	public static string QueryStringSplit = ';'; 
	public static string ExceptionMessage = 'System Error: you are not authorized to operate on the record. Please contact your administrator for further help.';
	public static string DefaultMessage = 'Warning: you are not authorized to operate on the record. Please contact your administrator for further help.';
	public class GeneralSettingModel
	{
		public string pchost;
		public string pcport;
		public boolean pchttps;
		public string oauthhost;
		public string oauthport;
		public string clientid;
		public string clientkey;
		public string policydecision;
		public string policymsg;
		public string policydefaultmsg;
		public string cacheInterval;
	}

    public static string GetDenyMessage(boolean bException)
    {
        string denyMsg = '';
		GeneralSettingModel generalSet = GetNxlSetting();
        if(generalSet != null)
        {
        	if(bException)
        	{
				denyMsg = string.isEmpty(generalSet.policymsg) ? ExceptionMessage : generalSet.policymsg;
        	}
        	else
        	{
        		denyMsg = string.isEmpty(generalSet.policydefaultmsg) ? DefaultMessage : generalSet.policydefaultmsg;
        	}           
        }
		return denyMsg;        
    }
    
	public static string GetPCUrl(GeneralSettingModel genenalSet)
    {
        return GetPCUrl(genenalSet.pchost, genenalSet.pcport, genenalSet.pchttps);
    }
    
    public static string GetPCUrl(string host, string port, boolean bHttps)
	{
		string pcUrl = null;
		if(port == '443')
		{
			pcUrl = 'https://' + host;
		}
		else if(bHttps)
		{
			pcUrl = 'https://' + host + ':' + port;  
		}
		else
		{
			pcUrl = 'http://' + host + ':' + port; 
		}
		return pcUrl;
	}
    
   	public static string GetAuthUrl(GeneralSettingModel genenalSet)
    {
        return GetAuthUrl(genenalSet.oauthhost, genenalSet.oauthport);
    }

	public static string GetAuthUrl(string host, string port)
	{
		string authUrl = null;
		if(port == '443')
		{
			authUrl = 'https://' + host;  
		}
		else
		{
			authUrl = 'https://' + host + ':' + port; 
		}
		return authUrl;
	}
  
	public static boolean CheckRecordType(string inputRecordType)
	{
		List<string> listRecordType = GetSelectedRecordTypes();
		for(string recordType : listRecordType)
		{
			if(recordType.equalsIgnoreCase(inputRecordType))
			{
				return true;
			}
		}
		return false;
	}

	public static GeneralSettingModel GetNxlSetting()
	{
		GeneralSettingModel generalSet = null;
		string dataType = NxlConstants.GENERAL_SETTING_TYPE;
		try
        {		
			NxlSettings__c nxlSet = [select content__c from NxlSettings__c where datatype__c = :dataType AND enabled__c = true];
			generalSet = (GeneralSettingModel)JSON.deserialize(nxlSet.content__c, GeneralSettingModel.class);
		}
        catch(Exception exp)
		{
            System.debug('NxlUISetting GetNxlSetting Exception:' + exp);
        }
		return generalSet;
	}

	public static List<string> GetSelectedRecordTypes()
	{
		string dataType = NxlConstants.SECURE_ENTITY_TYPE;
		List<string> listRecordTypes = new List<string>();
        try
        {		
            List<NxlSettings__c> listNxlSet = [select Name from NxlSettings__c where datatype__c = :dataType AND enabled__c = true];
			for(NxlSettings__c nxlSet : listNxlSet)
			{
				listRecordTypes.add(nxlSet.Name.toLowerCase());
			}
		}
        catch(Exception exp)
		{
            System.debug('NxlUISetting GetSelectedRecordTypes Exception:' + exp);
        }
		return listRecordTypes;
	}

	public static List<string> GetSelectedRecordFields(string recordType)
	{
		List<string> listRecordField = new List<string>();
        try
        {
			NxlSettings__c nxlSet = [select content__c from NxlSettings__c where Name = :recordType AND enabled__c = true];
			NxlViewModels.EntityModel recordModel = (NxlViewModels.EntityModel)JSON.deserialize(nxlSet.content__c, NxlViewModels.EntityModel.class);
			for(NxlViewModels.AttributeModel attrModel : recordModel.attributes)
			{
				listRecordField.add(attrModel.name.toLowerCase());
			}
		}
        catch(Exception exp)
		{
            System.debug('NxlUISetting GetSelectedRecordFields Exception:' + exp);
        }
		return listRecordField;
	}
	
	public static NxlViewModels.EntityModel GetSelectedRecordModel(string recordType)
	{
		NxlViewModels.EntityModel recordModel = null;
        try
        {
			NxlSettings__c nxlSet = [select content__c from NxlSettings__c where Name = :recordType AND enabled__c = true];
			recordModel = (NxlViewModels.EntityModel)JSON.deserialize(nxlSet.content__c, NxlViewModels.EntityModel.class);
		}
        catch(Exception exp)
		{
            System.debug('NxlUISetting GetSelectedRecordModel Exception:' + exp);
        }
		return recordModel;
	}

	public static List<string> GetSelectedUserFields()
	{
		string dataType = NxlConstants.USER_ATTRIBUTE_TYPE;
		List<string> listUserField = new List<string>();
        try
        {
            NxlSettings__c nxlSet = [select content__c from NxlSettings__c where datatype__c = :dataType AND enabled__c = true];
			List<NxlViewModels.AttributeModel> userAttrModel = (List<NxlViewModels.AttributeModel>)JSON.deserialize(nxlSet.content__c, List<NxlViewModels.AttributeModel>.class);
			for(NxlViewModels.AttributeModel attrModel : userAttrModel)
			{
				listUserField.add(attrModel.name.toLowerCase());
			}
		}
        catch(Exception exp)
		{
            System.debug('NxlUISetting GetSelectedUserFields Exception:' + exp);
        }

		return listUserField;
	}
    
    public static Map<string, NxlSettings__c> GetAllQueryNxlSet()
	{
        string dataType = NxlConstants.OBLIGATION_QUERY_TYPE;
        Map<string, NxlSettings__c> mapNxlSet = new Map<string, NxlSettings__c>();
        try
        {
			List<NxlSettings__c> nxlListSet = [select Name, datatype__c, enabled__c, content__c from NxlSettings__c where datatype__c = :dataType];
            for(NxlSettings__c nxlSet : nxlListSet)
            {
            	mapNxlSet.put(nxlSet.Name, nxlSet);
            }
        }
        catch(Exception exp)
		{
            System.debug('NxlUISetting GetAllQueryNxlSet Exception:' + exp);
        }
		return mapNxlSet;
	}
   
	public static string GetQueryContent(string queryName)
	{
        string queryContent = '';
		string dataType = NxlConstants.OBLIGATION_QUERY_TYPE;
		List<string> listUserField = new List<string>();
        try
        {
			NxlSettings__c nxlSet = [select content__c from NxlSettings__c where datatype__c = :dataType AND enabled__c = true AND name = :queryName];
			queryContent = nxlSet.content__c;
        }
        catch(Exception exp)
		{
            System.debug('NxlUISetting GetQueryString Exception:' + exp);
        }
		return queryContent;
	}

	public static boolean SetQueryContent(string queryName, string queryString, Map<string, NxlSettings__c> mapNxlSet)
	{
        if(string.isEmpty(queryName) || string.isEmpty(queryString))
        {
            return false;
        }
	
        System.debug('NxlUISetting SetQueryString queryName:' + queryName + ', queryString:' + queryString);
        if(mapNxlSet.containsKey(queryName))
        {
            NxlSettings__c nxlSet = mapNxlSet.get(queryName);
            if(!nxlSet.content__c.equalsIgnoreCase(queryString))
            {
                nxlSet.content__c = queryString;
				update nxlSet;
            }
        }
        else
        {
            try
            {
				NxlSettings__c nxlSet = new NxlSettings__c();
				nxlSet.Name = queryName;
				nxlSet.enabled__c = true;
				nxlSet.datatype__c = NxlConstants.OBLIGATION_QUERY_TYPE;
				nxlSet.content__c = queryString;
                mapNxlSet.put(queryName, nxlSet);
				insert nxlSet;
            }
            catch(Exception newExp)
            {
                System.debug('NxlUISetting SetQueryString Exception:' + newExp);
                return false;
            }
        }

		return true;
	}
}
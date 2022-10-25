public class NxlQueryObligation 
{
    public static string PermitName = 'record_filter';
    public static string PermitKey = 'field';
    public static string PermitOperator = 'oper';
    public static string PermitValue = 'value';
    public static string PermitValuesJoin = ', ';
    public static string PermitValueSplit = ';';
    public static string PermitValueWildCard = '**';
    public static string PermitReplaceWildCard = '%';
    public static string PermitAnd = ' AND ';
    public static string PermitOr = ' OR ';
    public static string PermitNotEqual = '!=';
    public static string PermitIn = 'IN';
    public static string PermitNotIn = 'NOT IN';
    public static string PermitLike = 'LIKE';
       
    public static string AlertMessage = 'AlertMsg';
    public static string Message = 'Msg';
    public static List<string> StringTypes = new string[]{'combobox', 'email', 'encryptedString', 'multiPicklist', 'phone', 'picklist', 'string', 'textarea', 'url', 'id'};
    public static List<string> CompareTypes = new string[]{'integer', 'double', 'currency', 'date', 'datetime', 'time', 'percent'};
    public static string NoRowException = 'List has no rows for assignment to SObject';
    public static string InvalidOperator = '(InvalidOperator)';
    		
	public class PermitQuery
    {
        public PermitQuery()
        {
            Field = null;
            Operator = null;
            Value = null;
            FieldType = null;
        }
        public PermitQuery(string inputField, string inputOperator, string inputValue, string inputFieldType)
        {
            Field = inputField;
            Operator = inputOperator;
            Value = inputValue;
            FieldType = inputFieldType;
        }
        public string Field;
        public string Operator;
        public string Value;
        public string FieldType;
    }

    public static List<string> DecodePermitObligations(List<NxlCERequest.CEObligation> listObligation, List<string> listField, NxlViewModels.EntityModel recordModel)
	{
		List<string> listQueryString = new List<string>();
		for(NxlCERequest.CEObligation obligation : listObligation)
		{
			string queryString = DecodePermitObligation(obligation, listField, recordModel);
            if(string.isNotEmpty(queryString))
            {
				listQueryString.add(queryString);
            }
		}
		return listQueryString;
	}

    public static string DecodePermitObligation(NxlCERequest.CEObligation obligation, List<string> listField, NxlViewModels.EntityModel recordModel)
    {
        string queryString = '';
        if(obligation.getName().equalsIgnoreCase(PermitName))
        {
            List<NxlCERequest.CEAttribute> ceAttrs = obligation.GetCEAttres().getAttributes();
			List<PermitQuery> listPermQuery = new List<PermitQuery>();
            for(integer i = 0; i < (ceAttrs.size() / 3); i++)
            {
				string field = null;
				string Operator = null;
				string value = null;
				boolean bString = false;
				for(NxlCERequest.CEAttribute attribute : ceAttrs)
				{
					if(attribute.Name.containsIgnoreCase(string.valueOf(i)))
					{
						if(attribute.Name.containsIgnoreCase(PermitKey))
						{
							field = attribute.Value;
						}
						else if(attribute.Name.containsIgnoreCase(PermitOperator))
						{
							operator = attribute.Value;
						}
						else if(attribute.Name.containsIgnoreCase(PermitValue))
						{
							value = attribute.Value;
						}
					}
				}
				if(string.isNotEmpty(field) && string.isNotEmpty(operator))
				{
					string fieldType = GetSelectedRecordFieldType(recordModel, field);
					if(string.isNotEmpty(fieldType)) // Check the field is selected in setting.
					{
						listField.add(field);
						listPermQuery.add(new PermitQuery(field, operator, value, fieldType));
					}
					else
					{
						System.debug(LoggingLevel.ERROR, 'Error: Check field selected in Secure Entities setting, invalid field: ' + field);
					}
				}    					                   
            }
			queryString = DecodePermitQueryString(listPermQuery);
        }
        return queryString;
	}
	
	public static boolean CheckFieldTypeIsString(string fieldType)
	{	
		boolean bString = false;
		for(string stringType : StringTypes)
		{
			if(stringType.equalsIgnoreCase(fieldType))
			{
				bString = true;
				break;
			}
		}
		
		return bString;
	}
	
	// Check the field type to support operator '>, <, >=, <='.	
	public static boolean CheckFieldTypeIsCompareType(string fieldType)
	{	
		boolean bCompare = false;
		for(string compareType : CompareTypes)
		{
			if(compareType.equalsIgnoreCase(fieldType))
			{
				bCompare = true;
				break;
			}
		}
		
		return bCompare;
	}
	
	public static string GetSelectedRecordFieldType(NxlViewModels.EntityModel recordModel, string field)
	{	
		string fieldType = '';
		if(recordModel != null && string.isNotEmpty(field))
		{			
			for(NxlViewModels.AttributeModel attrModel : recordModel.attributes)
			{
				if(field.equalsIgnoreCase(attrModel.name))
				{
					fieldType = attrModel.datatype;
					break;
				}
			}
		}
		return fieldType;
	}
	
	public static string DecodeAlertMessageObligations(List<NxlCERequest.CEObligation> listObligation)
	{
		string msgString = '';
		if(listObligation != null && listObligation.size() > 0)
		{
            for(NxlCERequest.CEObligation obligation : listObligation)
            {
				msgString = DecodeAlertMessageObligation(obligation);
                if(string.isNotEmpty(msgString))
                {
                    break;
                }
            }
		}
		return msgString;
	}
	
	public static string DecodeAlertMessageObligation(NxlCERequest.CEObligation obligation)
    {
    	string msgString = '';
        if(obligation.getName().equalsIgnoreCase(AlertMessage))
        {
        	List<NxlCERequest.CEAttribute> ceAttrs = obligation.GetCEAttres().getAttributes();
        	for(NxlCERequest.CEAttribute attribute : ceAttrs)
        	{
        		if(attribute.Name.containsIgnoreCase(Message))
				{
					msgString = attribute.Value;
				}
        	}
        }
        return msgString;
    }
	    
    public static string DecodePermitQueryString(List<PermitQuery> listPermQuery)
    {
        string queryString = '';
        try
        {
			if(listPermQuery.size() > 0)
			{
			    List<string> listCellQuery = new List<string>();
				boolean bMultipleFields = listPermQuery.size() > 1 ? true : false;
                string formatCondition = bMultipleFields ? '({0} {1} {2})' : '{0} {1} {2}';

				for(PermitQuery permQuery : listPermQuery)
				{
					string field = permQuery.Field;
					string value = permQuery.Value;
					string operator = ConvertOperator(permQuery.FieldType, permQuery.Operator, field, value);
					value = ConvertFieldValue(permQuery.FieldType, value, permQuery.Operator);
					if(string.isNotEmpty(field) && string.isNotEmpty(operator) && string.isNotEmpty(value))
					{
						string cellQuery = string.format(formatCondition, new string[]{field, operator, value});
						listCellQuery.add(cellQuery);
					}                        
				}
				if(bMultipleFields)
				{
					queryString = string.join(listCellQuery, PermitAnd);
				}
				else
				{
					queryString = listCellQuery[0];
				}
            }
        }
        catch(Exception exp)
        {
            System.debug('NxlQueryObligation DecodePermitQueryString Exception: ' + exp.getMessage());
        }
        return queryString;
    }

    public static string ConvertFieldValue(string fieldType, string value, string operator)
	{
		string finalValue = value;
		boolean bString = CheckFieldTypeIsString(fieldType);
		if(operator.equalsIgnoreCase('is null') || operator.equalsIgnoreCase('is not null'))
		{
			finalValue = 'null';
		}
		else if(string.isNotEmpty(value))
		{
			finalValue = value.trim();
			if(finalValue.contains('\\'))
			{
				finalValue = finalValue.replace('\\', '\\\\');
			}
			if(finalValue.contains('\''))
			{
				finalValue = finalValue.replace('\'', '\\\'');
			}
			if(bString)
			{
				finalValue = '\'' + finalValue + '\'';
			}
			if(finalValue.containsIgnoreCase(PermitValueWildCard))
			{
				if(finalValue.contains('_'))
				{
					finalValue = finalValue.replace('_', '\\_');
				}
				if(finalValue.contains('%'))
				{
					finalValue = finalValue.replace('%', '\\%');
				}
				finalValue = finalValue.replace(PermitValueWildCard, PermitReplaceWildCard);
			}
		}
		return finalValue;
	}
    
    public static string ConvertOperator(string fieldType, string operator, string field, string value)
    {
        string queryOp = '';
        if(operator.equalsIgnoreCase('is'))
        {
            queryOp = '=';
            if(string.isNotEmpty(value) && value.contains(PermitValueWildCard))
        	{
        		queryOp = PermitLike;
        	}
        }
        else if(operator.equalsIgnoreCase('is null')) 
        {
            queryOp = '=';
        }
        else if(operator.equalsIgnoreCase('is not') || operator.equalsIgnoreCase('is not null')) 
        {
            queryOp = '!=';
        }
        else
        {
        	if(operator.equalsIgnoreCase('greater than'))
        	{
            	queryOp = '>';
        	}
        	else if(operator.equalsIgnoreCase('greater than or equals to'))
        	{
            	queryOp = '>=';
        	}
        	else if(operator.equalsIgnoreCase('less than'))
        	{
            	queryOp = '<';
        	}
        	else if(operator.equalsIgnoreCase('less than or equals to'))
        	{
            	queryOp = '<=';
        	}
            if(!CheckFieldTypeIsCompareType(fieldType))
            {
            	queryOp = InvalidOperator + queryOp;
                System.debug(LoggingLevel.ERROR, 'Error: This field not support the operator, field: ' + field + ', oprator:' + operator + ', fieldType:' + fieldType);
            }
        }
        return queryOp;
    }

    public static boolean CheckResultById(string recordId, string recordType, List<string> listQueryString)
	{
		boolean bResult = false;
		string formatQuery = 'select id from {0} where {1}';
		string queryData = '';
		for(string queryString : listQueryString)
		{
			if(string.isEmpty(queryString))
            {
                continue;
            }
			else if(queryString.equals(NxlCERequest.AlwaysAllow))
			{
				return true;
			}
			else if(queryString.contains(InvalidOperator))
            {
            	System.debug(LoggingLevel.ERROR, 'Error: Existed invalid operator query: ' + queryString);
            	NxlCommonGlobal.bException = true;
            	return false;
            }
			queryData = string.format(formatQuery, new string[]{recordType, queryString});
			System.debug('CheckResultById Query: ' + queryData);
            try
            {
				List<SObject> listIds = Database.query(queryData);
				if(listIds != null)
				{
            		for(SObject idObj : listIds)
            		{
                    	if(recordId.equalsIgnoreCase(string.valueOf(idObj.get('Id'))))
                    	{
                    		bResult = true;
                		}
            		}
				}
            }
            catch(QueryException exp)
        	{
        		if(!NxlCommonGlobal.bException && !exp.getMessage().Contains(NoRowException))
        		{	
        			System.debug(LoggingLevel.ERROR, 'Error: NxlQueryObligation CheckResultById Exception: ' + exp.getMessage());
        			NxlCommonGlobal.bException = true;
        			return false;
        		}
        	}
		}
		return bResult;
	}    
}
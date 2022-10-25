global class NxlSettingsController {
	
    static private boolean saveSetting(string sName, boolean bIsEnabled, string sDataType, string sContent) {
        
        boolean bRet = true;
        
        try {
            
            NxlSettings__c setting = [select Name, enabled__c, datatype__c, content__c from NxlSettings__c where Name = :sName];
            
            setting.Name = sName;
            setting.enabled__c = bIsEnabled;
            setting.datatype__c = sDataType;
            setting.content__c = sContent;
            
            update setting;
            
        } catch(System.Exception e) {
            
            try{
           		NxlSettings__c setting = new NxlSettings__c();
                
				setting.Name = sName;
                setting.enabled__c = bIsEnabled;
            	setting.datatype__c = sDataType;
            	setting.content__c = sContent;
                
                insert setting;
            } catch(System.DmlException error) {
                bRet = false;
            }
        }
        
        return bRet;
    }
    
    static private NxlSettings__c getSettingByName(string sName) {
    	
        NxlSettings__c setting = null;
        
        try {
            
			setting = [select Name, enabled__c, datatype__c, content__c from NxlSettings__c where Name = :sName];
            
        } catch(System.DmlException e) {
            System.debug(String.format('getSettingByName failed, msg: {0}', new String[]{ e.getMessage() }));
        } catch(System.Exception e) {
            System.debug(String.format('getSettingByName failed, msg: {0}', new String[]{ e.getMessage() }));
        }
        
        return setting;
    }
    
    static private List<NxlSettings__c> getSettingByType(string sType) {
        
        NxlSettings__c[] settings = null;
        
        try {
            
            settings = [select Name, enabled__c, content__c, datatype__c from NxlSettings__c where datatype__c = :sType];
            
        } catch(System.DmlException e) {
            
            System.debug(String.format('getSettingByType failed, msg: {0}', new String[]{ e.getMessage() }));
            
        } catch(System.Exception e) {
            
            System.debug(String.format('getSettingByType failed, msg: {0}', new String[]{ e.getMessage() }));
            
        }
        
        return settings;
    }
    
    static private string[] GetTriggerableEntities() {
        return new String[] { 'Contract','Order','OrderItem','Campaign','CampaignMember','Account','Contact','Lead','Opportunity','OpportunityLineItem','Attachment','Product2','Asset','Case','CaseComment','Solution','ContentVersion','ContentDocument','ContentDocumentLink','ContentDistribution','Note','FeedItem','FeedComment','CollaborationGroup','CollaborationGroupMember','Task','Event','Topic','TopicAssignment','User','EmailMessage','Pricebook2','Idea','IdeaComment','Macro','CollaborationGroupRecord','StreamingChannel','DandBCompany','UserProvisioningRequest','UserProvisioningLog','UserProvMockTarget','UserProvAccount','UserProvAccountStaging','DuplicateRecordSet','DuplicateRecordItem','AssetRelationship'};
    }
    
    static private boolean IsTriggerable(string sName) {
                
        for(String s: GetTriggerableEntities()) {
            if(s.equals(sName)) {
                return true;
            }
        }
        
        return false;
    }
    
    static private boolean IsFieldSupported(Schema.DescribeFieldResult dfr) {
    	
    	boolean bSupported = false;
    	string fieldName = dfr.getName();
        // Support query 'where', not support 'address' type.
        if(dfr.isFilterable() && dfr.getType() != DisplayType.address)
        {
        	bSupported = true;              
        }
        // Not Support relation multiple entities.
        if(bSupported && dfr.isIdLookup() && string.isNotEmpty(dfr.getRelationshipName()) && dfr.isNamePointing())
        {
            bSupported = false;
        }
    	
    	return bSupported;
    }
    
    static public NxlModels.MetaEntityModel getConnectedApplicationEntity() {
        NxlModels.MetaEntityModel entity = new NxlModels.MetaEntityModel();
        Schema.DescribeSObjectResult objDescResults = ConnectedApplication.sObjectType.getDescribe();
        
        entity.id = objDescResults.getName();
        entity.name = objDescResults.getName();
        entity.displayName = objDescResults.getLabelPlural();
        
        return entity;
    }
    
    static public List<NxlModels.MetaAttributeModel> getConnectedApplicationAttributes() {
        
        Schema.DescribeSObjectResult objDescResults = ConnectedApplication.sObjectType.getDescribe();
        List<Schema.SObjectField> objFields = objDescResults.fields.getMap().values();
        List<NxlModels.MetaAttributeModel> attrs = new List<NxlModels.MetaAttributeModel>();
        
        for(Schema.SObjectField f: objFields) {
            Schema.DescribeFieldResult fieldDesc = f.getDescribe();
            NxlModels.MetaAttributeModel attr = new NxlModels.MetaAttributeModel();
            attr.id = fieldDesc.getName();
            attr.name = fieldDesc.getName();
            attr.displayName = fieldDesc.getLabel();
            attr.datatype = fieldDesc.getType().name();
            attrs.add(attr);
        }
        
        return attrs;   
    }
    
    @RemoteAction
    static global string GetGeneralSettings() {
        
        string result = '';
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        
		NxlSettings__c gs = NxlSettingsController.getSettingByName(NxlConstants.GENERAL_SETTINGS);
        
        if(gs != null) {
            payload.status = 200;
            payload.response = gs.content__c;
        } else {
            payload.status = 200;
            payload.response = '{}';
        }
        
        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction
    static global string SaveGeneralSettings(string sName, boolean bIsEnabled, string sDataType, string sContent) {
        
        string result = '';
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        
        if(!String.isEmpty(sName)) {
            
			boolean isSaved = NxlSettingsController.saveSetting(sName, bIsEnabled, sDataType, sContent);
            
            if(isSaved) {
                payload.status = 200;
                payload.response = 'OK';
            } else {
                payload.status = 500;
                payload.error = String.format('server error: save setting failed', new String[]{});                
            }
            
        } else {
			payload.status = 400;
            payload.error = String.format('setting name must be specified', new String[]{});
        }
        
        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction
    static global string GetEntityMetadata(string entityName) {
    	string result = '';
        NxlViewModels.SpecificMetaEntityResponse payload = new NxlViewModels.SpecificMetaEntityResponse();
        Map<String, Schema.SObjectType> sObjMap = Schema.getGlobalDescribe();
        
        try {
        	
        	Schema.SObjectType sobj = sObjMap.get(entityName);
        	Schema.DescribeSObjectResult entityDesc = sobj.getDescribe();
        	NxlModels.MetaEntityModel entity = new NxlModels.MetaEntityModel();
        	
        	entity.id = entityDesc.getName();
        	entity.name = entityDesc.getName();
        	entity.displayName = entityDesc.getLabelPlural();
        	entity.description = '';
        	
        	payload.status = 200;
        	payload.response = entity;
        	
        } catch(System.Exception e) {
        	payload.status = 500;
        	payload.error = e.getMessage();
        }
        
        result = JSON.serialize(payload);
        
        return result;
    }    
    
    @RemoteAction
    static global string GetEntitiesMetadata() {
        
        string result = '';
        //string response = '{ "status":200, "response":[{"id":"Account","name":"Account","displayName":"Accounts","description":"Companies that you have a relationship with"},{"id":"Lead","name":"Lead","displayName":"Leads","description":"people interested in your products, but have not purchased yet"},{"id":"Opportunity","name":"Opportunity","displayName":"Opportunities","description":"deal that have greate potential to let you generate revenue util deals close"},{"id":"Contact","name":"Contact","displayName":"Contacts","description":"people in Accounts that may matter to your business"}]}';
        NxlViewModels.MetaEntityResponse payload = new NxlViewModels.MetaEntityResponse();
        List<NxlModels.MetaEntityModel> entities = new List<NxlModels.MetaEntityModel>();
        List<Schema.SObjectType> metas = Schema.getGlobalDescribe().values();
        
        for(Schema.SObjectType obj: metas) {
            
            NxlModels.MetaEntityModel entity = new NxlModels.MetaEntityModel();
            Schema.DescribeSObjectResult meta = obj.getDescribe();
            
            if(!IsTriggerable(meta.getName())) {
                continue;
            }            
            
            entity.id = meta.getName();
            entity.name = meta.getName();
            entity.displayName = meta.getLabelPlural();
            entity.description = null;
            
            entities.add(entity);
        }
        
        entities.add(getConnectedApplicationEntity());
        
        payload.status = 200;
        payload.response = entities;
        
        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction
    static global string GetEnforcedEntities() {
        
        string result = '';
        NxlViewModels.EnforcedEntityResponse payload = new NxlViewModels.EnforcedEntityResponse();
        List<NxlSettings__c> settings = null;
        List<NxlViewModels.EntityModel> entities = new List<NxlViewModels.EntityModel>();
        //string response = '{ "status":200, "response":[{"id":"Account","name":"Account","displayName":"Accounts","description":"Companies that you have a relationship with","attributes":[{"id":"id","name":"id","displayName":"Account ID","datatype":"id","description":"mock data"},{"id":"Name","name":"Name","displayName":"Account Name","datatype":"string","description":"mock data"},{"id":"Type","name":"Type","displayName":"Account Type","datatype":"picklist","description":"mock data","options":[{"label":"Prospect","value":"Prospect","defaultValue":false},{"label":"Customer - Direct","value":"Customer - Direct","defaultValue":false}]}]},{"id":"Lead","name":"Lead","displayName":"Leads","description":"people interested in your products, but have not purchased yet","attributes":[{"id":"id","name":"id","displayName":"Lead ID","datatype":"id","description":"mock data"},{"id":"LastName","name":"LastName","displayName":"Last Name","datatype":"string","description":"mock data"},{"id":"FirstName","name":"FirstName","displayName":"First Name","datatype":"string","description":"mock data"},{"id":"Name","name":"Name","displayName":"Full Name","datatype":"string","description":"mock data"}]},{"id":"Opportunity","name":"Opportunity","displayName":"Opportunities","description":"deal that have greate potential to let you generate revenue util deals close","attributes":[{"id":"id","name":"id","displayName":"Opportunity ID","datatype":"id","description":"mock data"},{"id":"AccountId","name":"AccountId","displayName":"Account ID","datatype":"reference","description":"mock data"},{"id":"IsPrivate","name":"IsPrivate","displayName":"Private","datatype":"boolean","description":"mock data"}]}]}';
		
        settings = getSettingByType(NxlConstants.SECURE_ENTITY_TYPE);
        
        if(settings != null) {
            
            try {
                
                for(NxlSettings__c s: settings) {
                    if(s.enabled__c) {
                        NxlViewModels.EntityModel entity = (NxlViewModels.EntityModel)JSON.deserialize(s.content__c, NxlViewModels.EntityModel.class);
                        if(entity != null) {
                            entities.add(entity);
                        }                        
                    }
                }
                
                payload.status = 200;
                payload.response = entities;
                
            } catch(System.Exception e) {
                payload.status = 500;
                payload.error = String.format('server error: {0}', new String[]{ e.getMessage() });
            } 
            
        } else {
            payload.status = 500;
            payload.error = 'server error, get enforced entities failed';
        }
        
        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction
    static global string SaveEntity(string sName, boolean bIsEnabled, string sDataType, string sContent) {
        
        string result = '';
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        
        boolean isSaved = saveSetting(sName, bIsEnabled, sDataType, sContent);
        
        system.debug(String.format('**** {0}: {1} ****', new String[] { sName, sContent }));
        
        if(isSaved) {
            
            payload.status = 200;
            payload.response = 'OK';
            
        } else {
            payload.status = 500;
            payload.error = 'server error: save entities failed';
        }
        
        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction
    static global string GetEntityMetaAttributes(string sEntityId) {
        
        
        string result = '';
        NxlViewModels.MetaAttributeResponse payload = new NxlViewModels.MetaAttributeResponse();
        /*
        string accountResponse = '{"status": 200, "response": [{"id":"id","name":"id","displayName":"Account ID","datatype":"id","description":"mock data"},{"id":"Name","name":"Name","displayName":"Account Name","datatype":"string","description":"mock data"},{"id":"Type","name":"Type","displayName":"Account Type","datatype":"picklist","description":"mock data","options":[{"label":"Prospect","value":"Prospect","defaultValue":false},{"label":"Customer - Direct","value":"Customer - Direct","defaultValue":false}]},{"id":"BillingState","name":"BillingState","displayName":"Billing State/Province","datatype":"string","description":"mock data"},{"id":"NumberOfEmployees","name":"NumberOfEmployees","displayName":"Employees","datatype":"int","description":"mock data"}]}';
        string contactResponse = '{ "status": 200, "response": [{"id":"id","name":"id","displayName":"Contact ID","datatype":"id","description":"mock data"},{"id":"LastName","name":"LastName","displayName":"Last Name","datatype":"string","description":"mock data"},{"id":"FirstName","name":"FirstName","displayName":"First Name","datatype":"string","description":"mock data"},{"id":"Name","name":"Name","displayName":"Full Name","datatype":"string","description":"mock data"},{"id":"Title","name":"Title","displayName":"Title","datatype":"string","description":"mock data"},{"id":"IsEmailBounced","name":"IsEmailBounced","displayName":"Is Email Bounced","datatype":"boolean","description":"mock data"}] }';
        string leadResponse = '{"status": 200, "response": [{"id":"id","name":"id","displayName":"Lead ID","datatype":"id","description":"mock data"},{"id":"LastName","name":"LastName","displayName":"Last Name","datatype":"string","description":"mock data"},{"id":"FirstName","name":"FirstName","displayName":"First Name","datatype":"string","description":"mock data"},{"id":"Name","name":"Name","displayName":"Full Name","datatype":"string","description":"mock data"},{"id":"IsDeleted","name":"IsDeleted","displayName":"Deleted","datatype":"boolean","description":"mock data"},{"id":"OwnerId","name":"OwnerId","displayName":"Owner ID","datatype":"reference","description":"mock data"}]}';
        string oppoResponse = '{"status": 200, "response": [{"id":"id","name":"id","displayName":"Opportunity ID","datatype":"id","description":"mock data"},{"id":"AccountId","name":"AccountId","displayName":"Account ID","datatype":"reference","description":"mock data"},{"id":"IsPrivate","name":"IsPrivate","displayName":"Private","datatype":"boolean","description":"mock data"},{"id":"TrackingNumber__c","name":"TrackingNumber__c","displayName":"Tracking Number","datatype":"string","description":"mock data"},{"id":"MainCompetitors__c","name":"MainCompetitors__c","displayName":"Main Competitor(s)","datatype":"string","description":"mock data"}]}';
        
        if(sEntityId == 'Account') {
            response = accountResponse;
        } else if(sEntityId == 'Lead') {
            response = leadResponse;
        } else if(sEntityId == 'Contact') {
            response = contactResponse;
        } else if(sEntityId == 'Opportunity') {
            response = oppoResponse;
        }
		*/
        
        if(!String.isEmpty(sEntityId)) {
            
            try {
                
                Schema.SObjectType entity = Schema.getGlobalDescribe().get(sEntityId);
                Schema.DescribeSObjectResult meta = entity.getDescribe();
                List<NxlModels.MetaAttributeModel> attrs = new List<NxlModels.MetaAttributeModel>();
                
                for(Schema.sObjectField field: meta.fields.getMap().values()) {
                    Schema.DescribeFieldResult metaField = field.getDescribe();
                    
                    if(metaField == null || !IsFieldSupported(metaField)) {
                    	continue;
                    } 
                       
                    NxlModels.MetaAttributeModel attr = new NxlModels.MetaAttributeModel();

                    string relationName = metaField.getRelationshipName();
                    
                    if(metaField.getType() == displaytype.Reference && string.isNotEmpty(relationName))
                    {
                    	attr.name = relationName; 
                    }
                    else
                    {
                    	attr.name = metaField.getName();
                    }
		    attr.id = attr.name;
                    attr.displayName = metaField.getLabel();
                    attr.datatype = metaField.getType().name();
                    attr.isRef = false;
                    
                    // Set relation entity for 'reference' type.
                    List<Schema.SObjectType> refTables = metaField.getReferenceTo();
                    if(refTables != null && refTables.size() > 0)
                    {
				    	attr.refTable = refTables[0].getDescribe().getName();
                    }
                    attrs.add(attr);
                }
                
                payload.response = attrs;
                payload.status = 200;
                
            } catch(System.Exception e) {
                
                if(sEntityId == 'ConnectedApplication') {
                    payload.status = 200;
                    payload.response = getConnectedApplicationAttributes();                    
                } else {
                    payload.status = 500;
                    payload.error = String.format('server error: {0}', new String[]{ e.getMessage() });                    
                }
            }
            
        } else {
            payload.status = 400;
            payload.error = String.format('entity id must be specified', new String[]{});
        }

        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction
    static global string GetMetaUserAttributes() {
        
        string result = '';
        string USER = 'User';
        
		result = GetEntityMetaAttributes(USER);        
        
        return result;
    }
    
    @RemoteAction
    static global string GetEnforcedUserAttributes() {
        
        string result = '';
        NxlViewModels.UserAttributeResponse payload = new NxlViewModels.UserAttributeResponse();
        
        NxlSettings__c setting = null;
        List<NxlSettings__c> settings = getSettingByType(NxlConstants.USER_ATTRIBUTE_TYPE);
        
        if(settings == null || settings.size() == 0) {
			payload.status = 200;
			payload.response = new List<NxlViewModels.AttributeModel>();                
        } else if(settings.size() > 1) {
        	payload.status = 500;
            payload.error = 'server error: more than 1 setting of user attribute found';            
        } else {
            try {
				setting = settings[0];
                
                List<NxlViewModels.AttributeModel> attrs = (List<NxlViewModels.AttributeModel>)JSON.deserialize(setting.content__c, List<NxlViewModels.AttributeModel>.class);
                
                if(attrs.size() == 0) {
                    payload.response = new List<NxlViewModels.AttributeModel>();
                } else {
                    payload.response = attrs;
                }
                
				payload.status = 200;
                
            } catch(System.Exception e) {
                payload.status = 500;
                payload.error = String.format('server error: {0}', new String[] { e.getMessage() });                
            }            
        }
        
        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction 
    static global string SaveUserAttributes(string sName, boolean bIsEnabled, string sDataType, string sContent) {
        
        string result = '';
		result = SaveEntity(sName, bIsEnabled, sDataType, sContent);
        return result;
    }
    
    @RemoteAction
    static global string TestConnection(string sContent) {
        
        string result = '';
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        NxlModels.GeneralSettingModel gs = null;
        
        try {
            
            gs = (NxlModels.GeneralSettingModel)JSON.deserialize(sContent, NxlModels.GeneralSettingModel.class);
            
            string jpcHost = NxlUISetting.GetPCUrl(gs.pchost, gs.pcport, gs.pchttps);
            string oauthHost = NxlUISetting.GetAuthUrl(gs.oauthhost, gs.oauthport);
            
            if(NxlEnforceModule.CheckJPCAndAuthHost(jpcHost, oauthHost, gs.clientid, gs.clientkey)) {
 				payload.status = 200;
                payload.response = 'OK';
            } else {
                payload.status = 400;
                payload.error = 'test connection failed';
            }
            
        } catch(System.JSONException e) {
            payload.status = 500;
            payload.error = String.format('server error: {0}', new String[] { e.getMessage() });            
        }
        
        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction
    static global void UpdateNowHandler() {
        NxlCommonGlobal.CheckUserObligation();       
    }
    
    @RemoteAction
    static global string SaveCreatedTriggerInfos(string sName, boolean bIsEnabled, string sDataType, string sContent) {
        string result = '';
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        
        boolean isSaved = saveSetting(sName, bIsEnabled, sDataType, sContent);
        
        system.debug(String.format('**** {0}: {1} ****', new String[] { sName, sContent }));
        
        if(isSaved) {
            
            payload.status = 200;
            payload.response = 'OK';
            
        } else {
            payload.status = 500;
            payload.error = 'server error: save created triggers info failed';
        }
        
        result = JSON.serialize(payload);
        
        return result;   
    }
    
    @RemoteAction
    static global string GetCreatedTriggerInfos() {
        string result = '';
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        NxlSettings__c triggers = getSettingByName(NxlConstants.TRIGGERS);
        
        if(triggers != null) {
            
            payload.status = 200;
            payload.response = triggers.content__c;
            
        } else {
            payload.status = 200;
            payload.response = '[]';
        }
        
        result = JSON.serialize(payload);
        
        return result;   
    }
    
    @RemoteAction
    static global string SaveRemoteSiteSettings(string jpc, string cc) {

        string result = '';
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        
        try {
            
            if(!String.isEmpty(jpc) && !String.isEmpty(cc)) {
                
                MetadataService.RemoteSiteSetting jpcRSS = new MetadataService.RemoteSiteSetting();
                jpcRSS.fullName = NxlConstants.JPC_RSS;
                jpcRSS.description = '';
                jpcRSS.url = jpc;
                jpcRSS.isActive = true;
                jpcRSS.disableProtocolSecurity = false;
                
                MetadataService.RemoteSiteSetting ccRSS = new MetadataService.RemoteSiteSetting();
                ccRSS.fullName = NxlConstants.CC_RSS;
                ccRSS.description = '';
                ccRSS.url = cc;
                ccRSS.isActive = true;
                ccRSS.disableProtocolSecurity = false;                
                
                MetadataService.MetadataPort service = MetadataService.createService();
                MetadataService.UpsertResult[] results = service.upsertMetadata(new MetadataService.Metadata[]{ jpcRSS, ccRSS });
                
                payload.status = 200;
                payload.response = JSON.serialize(results);
                
                System.debug('******' + JSON.serialize(results));
                
            } else {
				payload.status = 400;
				payload.error = 'create remote site settings failed, invalid jpc or cc address';
            }        

        } catch(System.Exception e) {
            System.debug('SaveRemoteSiteSettings failed, error: ' + e.getMessage());
            payload.status = 500;
            payload.error = 'server error: ' + e.getMessage();            
        }
        
        result = JSON.serialize(payload);
        
        return result;
    }
    
    @RemoteAction
    static global string CreateTrigger(string table) {

        string result = '';
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        
        string triggerName = String.format('Nxl{0}Trigger', new String[]{ table });
        string triggerHead = String.format('trigger {0} on {1}', new String[]{ triggerName, table });
        string triggerBody = '(before delete, before update) {\r\n\tNextlabsSF.NxlTriggerHandler.executeTrigger();\n}';
        
        ToolingAPI tooling = new ToolingAPI();
        ToolingAPI.ApexTrigger tri = new ToolingAPI.ApexTrigger();        
        tri.name = triggerName;
        tri.body = String.format('{0} {1}', new String[]{ triggerHead, triggerBody });
        tri.tableEnumOrId = table;
        ToolingAPI.SaveResult sr = tooling.createSObject(tri);

        if(!String.isEmpty(sr.id)) {
            payload.status = 200;
            payload.response = 'OK';
        } else {
            payload.status = 500;
            payload.response = JSON.serialize(sr.errors);            
        }
        
        result = JSON.serialize(payload);
        
		return result;        
    }
    
    @RemoteAction
    static global string DeleteAllNxlTriggers() {
        string result = '';        
        string nxlPattern = String.format('{0}%', new String[]{ NxlConstants.NXL_PREFIX });
        NxlViewModels.GeneralResponse payload = new NxlViewModels.GeneralResponse();
        List<ApexTrigger> triggers;
        ToolingAPI tooling = new ToolingAPI();
        
        try {
            triggers = [select Id, Name from ApexTrigger where Name like :nxlPattern];
        } catch(System.DmlException e) {
            System.debug('no triggers starts with Nxl found');
        }
        
        if(triggers != null) {
            try {
                for(ApexTrigger t: triggers) {
                    tooling.deleteSObject(ToolingAPI.SObjectType.ApexTrigger, t.Id);   		       
                }

                payload.status = 200;
                payload.response = 'OK';
                
            } catch(System.Exception e) {
                
                System.debug('DeleteAllNxlTriggers failed, error: ' + e.getMessage());
                
                payload.status = 500;
                payload.error = e.getMessage();
            }         
        }
        
        result = JSON.serialize(payload);
		return result;        
    }
}
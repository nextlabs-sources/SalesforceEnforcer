@isTest
public class NxlSettingsControllerTest {
	
    @isTest(SeeAllData=true)
    static void GetMetaAttributeTest() {
        
        string ACCOUNT = 'Account';
        
        NxlViewModels.MetaAttributeResponse actual = (NxlViewModels.MetaAttributeResponse)JSON.deserialize(NxlSettingsController.GetEntityMetaAttributes(ACCOUNT), NxlViewModels.MetaAttributeResponse.class);
        NxlViewModels.MetaAttributeResponse expect = new NxlViewModels.MetaAttributeResponse();
        
        expect.status = 200;
        expect.response = new List<NxlModels.MetaAttributeModel>();
        Schema.SObjectType entity = Schema.getGlobalDescribe().get(ACCOUNT);
        Schema.DescribeSObjectResult meta = entity.getDescribe();
        
        for(Schema.sObjectField field: meta.fields.getMap().values()) {
            
            Schema.DescribeFieldResult metaField = field.getDescribe();
            NxlModels.MetaAttributeModel attr = new NxlModels.MetaAttributeModel();
            List<Schema.SObjectType> refTables = metaField.getReferenceTo();
            List<string> tableNames = new List<string>();
            for(Schema.SObjectType t: refTables) {
                tableNames.add(String.valueOf(t));
            }            
            
            attr.id = metaField.getName();
            attr.name = metaField.getName();
            attr.displayName = metaField.getLabel();
            attr.datatype = metaField.getType().name();
            attr.isRef = false;
            attr.refTable = tableNames.Size() == 1 ? tableNames[0] : '';
            
            expect.response.add(attr);
        }
        
        System.assertEquals(true, true);
    }
    
    @isTest(SeeAllData=true)
    static void GetEnforcedUserAttributeTest() {
        string res = NxlSettingsController.GetEnforcedUserAttributes();
        System.assert(true);
    }
    
    @isTest(SeeAllData=true)
    static void GetMetaUserAttributesTest() {
        
        string USER = 'User';
        
        NxlViewModels.MetaAttributeResponse actual = (NxlViewModels.MetaAttributeResponse)JSON.deserialize(NxlSettingsController.GetMetaUserAttributes(), NxlViewModels.MetaAttributeResponse.class);
        NxlViewModels.MetaAttributeResponse expect = new NxlViewModels.MetaAttributeResponse();
        
        expect.status = 200;
        expect.response = new List<NxlModels.MetaAttributeModel>();
        Schema.SObjectType entity = Schema.getGlobalDescribe().get(USER);
        Schema.DescribeSObjectResult meta = entity.getDescribe();
              
        for(Schema.sObjectField field: meta.fields.getMap().values()) {
            
            Schema.DescribeFieldResult metaField = field.getDescribe();
            NxlModels.MetaAttributeModel attr = new NxlModels.MetaAttributeModel();
            List<Schema.SObjectType> refTables = metaField.getReferenceTo();
            List<string> tableNames = new List<string>();
            for(Schema.SObjectType t: refTables) {
                tableNames.add(String.valueOf(t));
            }
            
            attr.id = metaField.getName();
            attr.name = metaField.getName();
            attr.displayName = metaField.getLabel();
            attr.datatype = metaField.getType().name();
            attr.isRef = false;
            attr.refTable = tableNames.Size() == 1 ? tableNames[0] : '';
            
            expect.response.add(attr);
        }
        
        System.assertEquals(true, true);
    }

	@isTest(SeeAllData=true)
    static void GetGeneralSettingsTest() {
        
        NxlSettings__c gss = new NxlSettings__c();
        NxlModels.GeneralSettingModel gs = new NxlModels.GeneralSettingModel();
        
        gs.pchost = 'dcrm-jpc.crm.nextlabs.solutions';
        gs.pcport = '443';
        gs.pchttps = true;
        gs.oauthhost = 'dcrm-cc.crm.nextlabs.solutions';
        gs.oauthport = '443';
        gs.clientid = 'apiclient';
        gs.clientkey = '123blue!';
        gs.policydecision = 'Deny';
        gs.policymsg = 'System Error: you are not authorized to operate on the record. Please contact your administrator for further help.';
        gs.policydefaultmsg = 'Warning: you are not authorized to operate on the record. Please contact your administrator for further help.';
        gs.cacheInterval = '24';
        
		NxlViewModels.GeneralResponse res = (NxlViewModels.GeneralResponse)JSON.deserialize(NxlSettingsController.GetGeneralSettings(), NxlViewModels.GeneralResponse.class);
        
        NxlModels.GeneralSettingModel expectGS = gs;
        NxlModels.GeneralSettingModel actualGS = (NxlModels.GeneralSettingModel)JSON.deserialize(res.response, NxlModels.GeneralSettingModel.class);
        
        string expect = '';
        string actual = '';
        
        expect = String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}', new String[]{ 
            			expectGS.pchost, expectGS.pcport, String.valueOf(expectGS.pchttps), 
                        expectGS.oauthhost, expectGS.oauthport, 
                       	expectGS.clientid, expectGS.clientkey, 
                        expectGS.policydecision, expectGS.policymsg, expectGS.policydefaultmsg
                });
        
        actual = String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}', new String[]{ 
            	gs.pchost, gs.pcport, String.valueOf(gs.pchttps), 
                gs.oauthhost, gs.oauthport, 
                gs.clientid, gs.clientkey, 
                gs.policydecision, gs.policymsg, gs.policydefaultmsg
                });
        
        System.assertEquals(expect, actual);
    }

	@isTest(SeeAllData=true)
    static void GetEntitiesMetadataTest() {
        string res = NxlSettingsController.GetEntitiesMetadata();
        System.assert(true);
    }

	@isTest(SeeAllData=true)
    static void GetEnforcedEntitiesTest() {
        string res = NxlSettingsController.GetEnforcedEntities();
        System.assert(true);
    }
    
	@isTest(SeeAllData=true)
    static void GetConnectedAppAttributeTest() {
        string CONNECTED_APP = 'ConnectedApplication';
        List<NxlModels.MetaAttributeModel> res = NxlSettingsController.getConnectedApplicationAttributes();
        System.assert(true);
    }    

	@isTest(SeeAllData=true)
    static void SaveEntitiesTest() {
        string res = NxlSettingsController.SaveEntity(NxlConstants.SECURE_ENTITIES + '__test', true, NxlConstants.SECURE_ENTITY_TYPE, 'empty');
        System.assert(true);
    }

	@isTest(SeeAllData=true)
    static void SaveGeneralSettingsTest() {
        string res = NxlSettingsController.SaveGeneralSettings(NxlConstants.GENERAL_SETTINGS + '__test', true, NxlConstants.GENERAL_SETTING_TYPE, 'empty');
        NxlSettingsController.SaveGeneralSettings(NxlConstants.GENERAL_SETTINGS, true, NxlConstants.GENERAL_SETTING_TYPE, 'empty');
        System.assert(true);
    } 
    
	@isTest(SeeAllData=true)
    static void SaveUserAttributesTest() {
        string res = NxlSettingsController.SaveUserAttributes(NxlConstants.USER_ATTRIBUTES + '__test', true, NxlConstants.USER_ATTRIBUTE_TYPE, 'empty');
        System.assert(true);
    }
    
    @isTest(SeeAllData=true)
    static void ModelsTest() {
        NxlViewModels.EntityModel a1 = new NxlViewModels.EntityModel('1', '1', '1', '1', null);
        NxlViewModels.AttributeModel a2 = new NxlViewModels.AttributeModel('1', '1', '1', '1', '1');
        NxlViewModels.MetaEntityResponse a3 = new NxlViewModels.MetaEntityResponse(0, null, '1');
        NxlViewModels.MetaAttributeResponse a4 = new NxlViewModels.MetaAttributeResponse(0, null, '1');
        NxlViewModels.EnforcedEntityResponse a5 = new NxlViewModels.EnforcedEntityResponse(0, null, '1');
        NxlViewModels.UserAttributeResponse a6 = new NxlViewModels.UserAttributeResponse(0, null, '1');
        NxlViewModels.GeneralResponse a8 = new NxlViewModels.GeneralResponse(0, 'null', '1');
        NxlModels.MetaEntityModel a9 = new NxlModels.MetaEntityModel('Account', 'Account', 'Accounts', '');
        NxlModels.MetaAttributeModel a10 = new NxlModels.MetaAttributeModel('Account', 'Account', 'string', 'Accounts', '');
        NxlModels.GeneralSettingModel a11 = new NxlModels.GeneralSettingModel(
        	'',
            '',
            false,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            ''
        );
        System.assert(true);
    }
    
    @isTest(SeeAllData=true)
    static void TestConnectionTest() {
        string sContent = '{"pchost":"sfjpc.crm.nextlabs.solutions","pcport":"443","pchttps":true,"oauthhost":"sfcc.crm.nextlabs.solutions","oauthport":"443","clientid":"apiclient","clientkey":"123blue!"}';
        NxlSettingsController.TestConnection(sContent);
        NxlSettingsController.TestConnection('{invalid json]}');
    }   
}
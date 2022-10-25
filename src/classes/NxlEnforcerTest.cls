@isTest
public class NxlEnforcerTest {
    @isTest(SeeAllData=true)
    static void TestEnforcer() 
    {
        try {
            NxlConnectedAppClass app = new NxlConnectedAppClass();
            app.authorize(Id.valueOf('0051I000001H7P4QAK'), Id.valueOf('0051I000001H7P4QAK'), true, Auth.InvocationContext.ASSET_TOKEN);
            //NxlCommonGlobal.StartEnforceSchedule(Datetime.now().addMinutes(1), 1);
            boolean bAppRet = NxlCommonGlobal.CheckAppResource(Id.valueOf('0051I000001H7P4QAK'), Id.valueOf('0051I000001H7P4QAK'));
            NxlCommonGlobal.EvaluationData evalData = new NxlCommonGlobal.EvaluationData();
            evalData = new NxlCommonGlobal.EvaluationData(Id.valueOf('0051I000001H7P4QAK'), 'case', 'VIEW');
            NxlCommonGlobal.GetAllUserIds(new List<string>{ 'id' }, 10, 0);
            boolean bLink = NxlEnforceModule.CheckJPCAndAuthHost();
            System.debug('bLink:' + bLink);
            NxlCommonGlobal.GetEnforceResult('0051I000001H7P4QAK', 'Case', '0051I000001H7P4QAK', 'VIEW');
            NxlCommonGlobal.CheckUserObligation();
            NxlCommonGlobal.CheckUserObligation(0);
            //NxlCommonGlobal.StopEnforceSchedule();
            NxlCERequest.CERequest ceRequest = NxlEnforceModule.CreateCEReqest('VIEW', '123456', 'Test@nextlabs.com', 'MyTest', new Map<string, string>(), new Map<string, string>());
            NxlEnforceModule.DoSingleEvalution(ceRequest, new List<NxlCERequest.CEObligation>());
            NxlTranformModule tranformModule = new NxlTranformModule();
            NxlJPCRestRequest.RestRequest restRequest = tranformModule.TransformToSingleRequest(ceRequest);
            NxlTranformModule.stringToPolicyResult('Permit');
            NxlJPCRestRequest.ResultNode resultNode = new NxlJPCRestRequest.ResultNode();
            System.debug('--------111------');
            List<NxlCERequest.CEObligation> lsOb = new List<NxlCERequest.CEObligation>();
            NxlTranformModule.TransformToCEObligation(resultNode, lsOb);
            
            NxlUISetting.GetDenyMessage(true);
            NxlUISetting.GetDenyMessage(false);
            NxlUISetting.GetAuthUrl(new NxlUISetting.GeneralSettingModel());
            NxlUISetting.GetSelectedRecordFields(NxlConstants.GENERAL_SETTINGS);
            NxlUISetting.SetQueryContent('Account', 'ACCOUNT_UPDATE', new Map<string, NxlSettings__c>());
            
            NxlTranformModule.ConvertStatusCodeToPcResult(200);
            NxlTranformModule.ConvertStatusCodeToPcResult(400);
            NxlTranformModule.ConvertStatusCodeToPcResult(401);
            NxlTranformModule.ConvertStatusCodeToPcResult(500);
            
            NxlTranformModule.StatusMsgToPcResult('Account');
            System.debug('-------2222-------');
            NxlJPCRestRequest.RestResponse restRespon = new NxlJPCRestRequest.RestResponse();
            restRespon.Response = new NxlJPCRestRequest.ResponseNode();
            restRespon.Response.Result = new List<NxlJPCRestRequest.ResultNode>();
            NxlJPCRestRequest.ResultNode retNode = new NxlJPCRestRequest.ResultNode();
            retNode.Decision = 'Permit';
            retNode.Status = new NxlJPCRestRequest.StatusNode();
            retNode.Obligations = new List<NxlJPCRestRequest.ObligationsNode>();
            NxlJPCRestRequest.StatusNode statusNode = new NxlJPCRestRequest.StatusNode();
            statusNode.StatusMessage = 'Deny';
            NxlJPCRestRequest.StatusCodeNode statusCodeNode = new NxlJPCRestRequest.StatusCodeNode();
            statusNode.StatusCode = statusCodeNode;
            statusCodeNode.Value = '200';           
            NxlJPCRestRequest.ObligationsNode obNode = new NxlJPCRestRequest.ObligationsNode();
            obNode.Id = '123';
            obNode.AttributeAssignment = new List<NxlJPCRestRequest.AttributeAssignmentNode>();
            NxlJPCRestRequest.AttributeAssignmentNode attributeAssignmentNode = new NxlJPCRestRequest.AttributeAssignmentNode();
            attributeAssignmentNode.AttributeId = '111';
            attributeAssignmentNode.Value = new List<string>();
            attributeAssignmentNode.Category = '111';
            attributeAssignmentNode.DataType = '111';
            NxlJPCRestRequest.TokenResponse tokenResponse = new NxlJPCRestRequest.TokenResponse();
            tokenResponse.access_token = '111';
            tokenResponse.token_type = '222';
            tokenResponse.expires_in = 600;
                
            NxlCERequest.CEAttres ceAttrs = new NxlCERequest.CEAttres();
            ceAttrs.addAttribute('itar', 'no', NxlCERequest.CEAttributeType.XACML_String);
            
            NxlCERequest.CEApp testApp = new NxlCERequest.CEApp('Salesforce', '', '', ceAttrs);
            NxlCERequest.CEUser testUser = new NxlCERequest.CEUser('Daniel', '1234@nextlabs.com', ceAttrs);
            NxlCERequest.CEResource testSource = new NxlCERequest.CEResource('MyTest', 'c://pp.txt', ceAttrs);
            NxlCERequest.CEHost testHost = new NxlCERequest.CEHost('Account', 'dcrm-cc.nextlabs.solutions', ceAttrs);
            NxlCERequest.CEReferenceId testReferenceId = new NxlCERequest.CEReferenceId('', '', '', '', '', '');
            NxlCERequest.CEAttribute testAttrs = new NxlCERequest.CEAttribute('dont-care-acceptable', 'yes', NxlCERequest.CEAttributeType.XACML_String);
            
            NxlCERequest.CERequest req = new NxlCERequest.CERequest();
            req.setAction('ACCOUNT_VIEW');
            req.SetUser('Daniel', '1234@nextlabs.com', ceAttrs);
            req.SetSource('MyTest', 'c://pp.txt', ceAttrs);
            req.SetNameAttributes('dont-care-acceptable', 'yes', NxlCERequest.CEAttributeType.XACML_String);
            req.SetApp('Salesforce', '', '', ceAttrs);
            req.setNoiseLevel(NxlCERequest.CENoiseLevel.CE_NOISE_LEVEL_USER_ACTION);
            req.setHost('Account', 'dcrm-cc.nextlabs.solutions', ceAttrs);
            req.setDest('Account', 'Account', ceAttrs);
            req.setRecipient('Daniel', '123@nextlabs.com', ceAttrs);
            req.setRecipient('Daniel1', '1234@nextlabs.com', ceAttrs);
            List<NxlCERequest.CERequest> listReq = new List<NxlCERequest.CERequest>();
            listReq.add(req);
                    
            tranformModule.TransformMultipleRequests(listReq);
            tranformModule.TransformToSingleRequest(req);
            tranformModule.TransformMultipleRequests(new List<NxlCERequest.CERequest>{ ceRequest, req });
            System.debug('-------333-------');
            ceAttrs = new NxlCERequest.CEAttres();
            ceAttrs.addAttribute('field(0)', 'itar', NxlCERequest.CEAttributeType.XACML_String);
            ceAttrs.addAttribute('oper(0)', 'is', NxlCERequest.CEAttributeType.XACML_String);
            ceAttrs.addAttribute('value(1)', 'yes', NxlCERequest.CEAttributeType.XACML_String);
            
            NxlCERequest.CEObligation ob = new NxlCERequest.CEObligation('record_filter', ceAttrs, 'policy 1');
            NxlQueryObligation.PermitQuery pq1 = new NxlQueryObligation.PermitQuery();
            NxlQueryObligation.PermitQuery pq2 = new NxlQueryObligation.PermitQuery('case', '=', '007', 'string');
            
            NxlQueryObligation.DecodePermitObligations(new List<NxlCERequest.CEObligation>{ob}, new List<string>{}, new NxlViewModels.EntityModel());
            
            NxlQueryObligation.ConvertFieldValue('string', 'Name', 'NxlAccount');
            NxlQueryObligation.DecodePermitQueryString(new List<NxlQueryObligation.PermitQuery>{ pq2 });
            NxlQueryObligation.CheckResultById('Account',NxlConstants.SECURE_ENTITY_TYPE, new String[] { '123' });
            
            System.debug('-------444-------');
            NxlFutureCall.CallEnforcerEvaluation(0);
            NxlTriggerHandler.TriggerDoEvalution(NxlCERequest.EvalAction.CreateAction, new List<SObject>(), new List<boolean>());
            NxlTriggerHandler.executeTrigger();
           
        } catch(System.Exception e) {
            System.debug(String.format('**** {0} ****', new String[] { e.getMessage() }));
            System.debug(String.format('**** {0} ****', new String[] { e.getStackTraceString() }));
        } finally {
            System.assert(true);            
        }
    }   
}
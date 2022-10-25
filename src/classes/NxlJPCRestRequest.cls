public class NxlJPCRestRequest
{
    public class RestRequest
    {
        public RequestNode Request { get; set; }
    }

    public class RestMultipleRequest
    {
        public RequestMultipleNode Request { get; set; }
    }

    public class RequestNode
    {
        public string ReturnPolicyIdList { get; set; }
        public List<CategoryNode> Category { get; set; }
    }

    public class RequestMultipleNode
    {
        public boolean CombinedDecision { get; set; }
        public boolean ReturnPolicyIdList { get; set; }
        public string XPathVersion { get; set; }

        public List<CategoryMultipleNode> Category { get; set; }
        public List<CategoryMultipleNode> Subject { get; set; }
        public List<CategoryMultipleNode> Action { get; set; }
        public List<CategoryMultipleNode> Resource { get; set; }
        public ReferenceNode MultiRequests { get; set; }
    }

    public class ReferenceNode
    {
        public List<ReferenceIdNode> RequestReference { get; set; }
    }

    public class ReferenceIdNode
    {
        public List<string> ReferenceId { get; set; }
    }

    public class CategoryNode
    {
        public string CategoryId { get; set; }

        //public string Id { get; set; }

        public List<AttributeNode> Attribute { get; set; }
    }

    public class CategoryMultipleNode
    {
        public string CategoryId { get; set; }

        public string Id { get; set; }

        public List<AttributeNode> Attribute { get; set; }
    }

    public class AttributeNode
    {
        public AttributeNode()
        {
            Value = new List<string>();
        }
        public string AttributeId { get; set; }

        public List<string> Value { get; set; }

        public string DataType { get; set; }

        public boolean IncludeInResult { get; set; }
    }

    public class RestResponse
    {
        public ResponseNode Response { get; set; }
    }
    
    public class ResponseNode
    {
        public List<ResultNode> Result { get; set; }
    }
    
    public class ResultNode
    {
        public string Decision { get; set; }

        public StatusNode Status { get; set; }

        public List<ObligationsNode> Obligations { get; set; }
    }

    public class StatusNode
    {
        public string StatusMessage { get; set; }
        public StatusCodeNode StatusCode { get; set; }
    }
    public class StatusCodeNode
    {
        public string Value { get; set; }
    }

    public class ObligationsNode
    {
        public string Id { get; set; }
        public List<AttributeAssignmentNode> AttributeAssignment { get; set; }
    }

    public class AttributeAssignmentNode
    {
        public string AttributeId { get; set; }
        public List<string> Value { get; set; }
        public string Category { get; set; }
        public string DataType { get; set; }
    }
    
    public class TokenResponse
    {
        public string access_token { get; set; }
        public string token_type { get; set; }
        public integer expires_in { get; set; }
    }        
}
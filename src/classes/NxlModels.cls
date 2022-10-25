public class NxlModels {
  
    public class MetaEntityModel {
        
        public string id;
        public string name;
        public string displayName;
        public string description;
        
        public MetaEntityModel(){}
        public MetaEntityModel(string sId, string sName, string sDisplayName, string sDesc) {
            this.id = sId;
            this.name = sName;
            this.displayName = sDisplayName;
            this.description = sDesc;
        }
    }
    
    public class MetaAttributeModel {
        public string id;
        public string name;
        public string datatype;
        public string displayName;
        public string description;
        public string refTable;
        public boolean isRef;        
        
        public MetaAttributeModel(){}
        public MetaAttributeModel(string sId, string sName, string sDataType, string sDisplayName, string sDesc) {
            this.id = sId;
            this.name = sName;
            this.datatype = sDataType;
            this.displayName = sDisplayName;
            this.description = sDesc;
            this.isRef = false;
            this.refTable = '';            
        }
        public MetaAttributeModel(string sId, string sName, string sDataType, string sDisplayName, string sDesc, boolean isRef, string refTable) {
            this.id = sId;
            this.name = sName;
            this.datatype = sDataType;
            this.displayName = sDisplayName;
            this.description = sDesc;
            this.isRef = isRef;
            this.refTable = refTable;
        }                
    }
    
	public class GeneralSettingModel {
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
        
        public GeneralSettingModel() {}
        public GeneralSettingModel(
            string sPCHost, 
            string sPCPort, 
            boolean bIsHttps, 
            string sOAuthHost, 
            string sOAuthPort, 
            string sClientId, 
            string sClientKey,
            string sDecision,
            string sMsg,
            string sDefaultMsg,
            string sInterval
        ) {
            this.pchost = sPCHost;
            this.pcport = sPCPort;
            this.pchttps = bIsHttps;
            this.oauthhost = sOAuthHost;
            this.oauthport = sOAuthPort;
            this.clientid = sClientId;
            this.clientkey = sClientKey;
            this.policydecision = sDecision;
            this.policymsg = sMsg;
            this.policydefaultmsg = sDefaultMsg;
            this.cacheInterval = sInterval;
        }
	}    
}
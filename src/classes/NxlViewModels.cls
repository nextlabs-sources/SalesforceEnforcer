public class NxlViewModels {
	
    public class EntityModel {
        
        public string id;
        public string name;
        public string displayName;
        public string description;
        public List<AttributeModel> attributes;
        
        public EntityModel(){}
        public EntityModel(string sId, string sName, string sDisplayName, string sDesc, List<AttributeModel>  lAttrs) {
            this.id = sId;
            this.name = sName;
            this.displayName = sDisplayName;
            this.description = sDesc;
            
            if(lAttrs == null) {
                this.attributes = new List<AttributeModel>();
            } else {
                this.attributes = lAttrs;
            }
        }
    }
    
    public class AttributeModel {
        public string id;
        public string name;
        public string datatype;
        public string displayName;
        public string description;
        public string refTable;
        public boolean isRef;
        
        public AttributeModel(){}
        public AttributeModel(string sId, string sName, string sDataType, string sDisplayName, string sDesc) {
            this.id = sId;
            this.name = sName;
            this.datatype = sDataType;
            this.displayName = sDisplayName;
            this.description = sDesc;
            this.isRef = false;
            this.refTable = '';
        }
        public AttributeModel(string sId, string sName, string sDataType, string sDisplayName, string sDesc, boolean isRef, string refTable) {
            this.id = sId;
            this.name = sName;
            this.datatype = sDataType;
            this.displayName = sDisplayName;
            this.description = sDesc;
            this.isRef = isRef;
            this.refTable = refTable;
        }                
    }
    
    public class SpecificMetaEntityResponse {
        
        public NxlModels.MetaEntityModel response;
        public integer status;
        public string error;
        
        public SpecificMetaEntityResponse(){}
        public SpecificMetaEntityResponse(integer nStatus, NxlModels.MetaEntityModel entity, string sError){
			this.status = nStatus;
			this.error = sError;

            if(entity == null) {
                this.response = new NxlModels.MetaEntityModel();
            } else {
                this.response = entity;
            }         
        }
    }

    public class MetaEntityResponse {
        
        public List<NxlModels.MetaEntityModel> response;
        public integer status;
        public string error;
        
        public MetaEntityResponse(){}
        public MetaEntityResponse(integer nStatus, List<NxlModels.MetaEntityModel> entities, string sError){
			this.status = nStatus;
			this.error = sError;

            if(entities == null) {
                this.response = new List<NxlModels.MetaEntityModel>();
            } else {
                this.response = entities;
            }         
        }
    } 
    
    public class MetaAttributeResponse {
        
        public List<NxlModels.MetaAttributeModel> response;
        public integer status;
        public string error;
        
        public MetaAttributeResponse(){}
        public MetaAttributeResponse(integer nStatus, List<NxlModels.MetaAttributeModel> entities, string sError) {
			this.status = nStatus;
			this.error = sError;

            if(entities == null) {
                this.response = new List<NxlModels.MetaAttributeModel>();
            } else {
                this.response = entities;
            }         
        }
    }    
    
    public class EnforcedEntityResponse {
        
        public List<EntityModel> response;
        public integer status;
        public string error;
        
        public EnforcedEntityResponse(){}
        public EnforcedEntityResponse(integer nStatus, List<EntityModel> entities, string sError) {
			this.status = nStatus;
			this.error = sError;

            if(entities == null) {
                this.response = new List<EntityModel>();
            } else {
                this.response = entities;
            }         
        }
    }
    
    public class UserAttributeResponse {
        
        public List<AttributeModel> response;
        public integer status;
        public string error;
        
        public UserAttributeResponse(){}
        public UserAttributeResponse(integer nStatus, List<AttributeModel> attrs, string sError) {
			this.status = nStatus;
			this.error = sError;

            if(attrs == null) {
                this.response = new List<AttributeModel>();
            } else {
                this.response = attrs;
            }         
        }
    }
    
    public class GeneralResponse {
        
        public string response;
        public integer status;
        public string error;
        
        public GeneralResponse (){}
        public GeneralResponse(integer nStatus, string sResponse, string sError) {
			this.status = nStatus;
            this.response = sResponse;
			this.error = sError;        
        }        
    }
}
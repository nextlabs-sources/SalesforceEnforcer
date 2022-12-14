; (function (win) {

    //var document = win.document
    var policyModelSortOrder = 0
    var OB_PARAM_FIELD_SHORTNAME_PREFIX = 'field'
    var OB_PARAM_OPERATOR_SHORTNAME_PREFIX = 'oper'
    var OB_PARAM_VALUE_SHORTNAME_PREFIX = 'value'

    var OB_PARAM_FIELD_NAME_PREFIX = 'Field'
    var OB_PARAM_OPERATOR_NAME_PREFIX = 'Operator'
    var OB_PARAM_VALUE_NAME_PREFIX = 'Value'

    var ACTION_SUFFIXES = ['EDIT', 'DELETE']//'VIEW', 'CREATE', 
    var CONNECT_APP_ACTION_SUFFIXES = ['ACCESS']
    var NUMBER_TYPE_IN_CC = ['integer', 'double', 'currency', 'date', 'datetime', 'time', 'percent']
    var CONNECT_APP_NAME = 'ConnectedApplication'

    win.nxl = win.nxl || {}
    win.nxl.util = win.nxl.util || {}

    var _u = win.nxl.util

    _u.$ = function (selector, scope) {
        if (!scope) {
            scope = document
        }
        return scope.querySelector(selector)
    }

    _u.$$ = function (selector, scope) {
        if (!scope) {
            scope = document
        }
        return scope.querySelectorAll(selector)
    }

    _u.parseFromString = function (xml) {

        var parser = new DOMParser()
        var doc = parser.parseFromString(xml, 'text/xml')

        return doc.documentElement
    }

    _u.objectify = function (element) {

        if (!element) {
            return undefined
        }

        var wrap = {}
        var nodeName = element.nodeName.trim().toLowerCase()

        //text node
        if (element.nodeType === 3) {
            wrap['$content'] = element.nodeValue
        }

        //element node
        if (element.nodeType === 1) {

            wrap[nodeName] = {}
            var target = wrap[nodeName]

            if (element.hasAttributes()) {

                var count = element.attributes.length

                for (var i = 0; i < count; i++) {

                    var attrName = element.attributes[i].name

                    if (typeof attrName === 'string') {
                        target[attrName] = element.attributes[i].value
                    }
                }
            }

            if (element.childNodes && element.childNodes.length > 0) {

                for (var j = 0; j < element.childNodes.length; j++) {

                    var curNode = element.childNodes[j]
                    var nodeName = curNode && curNode.nodeName
                    var childWrap = _u.objectify(curNode)

                    Object.keys(childWrap).map(function (prop) {
                        if (target[prop] == null) {
                            target[prop] = childWrap[prop]
                        }
                        else {
                            target[prop] = [].concat(target[prop])
                            target[prop].push(childWrap[prop])
                        }
                    })
                }
            }
        }

        return wrap
    }

    _u.format = function () {

        var result = ''
        var placeholderReg = /\{(\w+)\}/gi
        var args = Array.prototype.slice.call(arguments, 0)
        var template = args[0]

        if (typeof template === 'string') {
            result = template.replace(placeholderReg, function (value, num) {
                return args[Number(num) + 1]
            })
        }
        return result
    }

    _u.reloadPage = function () {
        win.location.reload(true)
    }

    /**
     * create an event
     * bug: click/mouse event should be typeof mouseevent
     * @param {string} evtName 
     * @param {boolean} canBubble 
     * @param {boolean} canCancel 
     * @returns 
     */
    _u.createEvent = function (evtName, canBubble, canCancel) {

        var evt = undefined

        if (typeof canBubble !== 'boolean') {
            canBubble = true
        }

        if (typeof canCancel !== 'boolean') {
            canCancel = true
        }

        if (evtName) {
            try {
                if ((evtName.indexOf('click') > -1) || evtName.indexOf('mouse') > -1) {
                    evt = new MouseEvent(evtName, { bubbles: canBubble, cancelable: canCancel })
                }
                else {
                    evt = new Event(evtName, { bubbles: canBubble, cancelable: canCancel })
                }
            }
            catch (e) {
                evt = document.createEvent('Event')
                evt.initEvent(evtName, canBubble, canCancel)
            }
        }
        else {
            throw new Error('event name must be specified')
        }

        return evt
    }

    _u.extend = Object.assign || function (target) {

        for (var i = 1; i < arguments.length; i++) {
            var source = arguments[i]
            for (var key in source) {
                if (Object.prototype.hasOwnProperty.call(source, key)) {
                    target[key] = source[key]
                }
            }
        }
        return target
    }

    _u.createDOMFromString = function (template) {

        var elReg = /\<([a-zA-Z]+)/gi
        var results = elReg.exec(template)

        var nodeName = results[1].trim().toLowerCase()

        var getMatchNode = function (nodeName, factory) {

            var curNode = factory.firstElementChild

            while (curNode) {

                if (curNode.nodeName.toLowerCase() === nodeName) {
                    return curNode
                }

                curNode = curNode.firstElementChild
            }

            return undefined
        }

        if (nodeName === 'th' || nodeName === 'tr' || nodeName === 'td' || nodeName === 'tbody' || nodeName === 'thead') {
            var factory = document.createElement('table')
            factory.innerHTML = template
            return getMatchNode(nodeName, factory)
        }
        else {
            var factory = document.createElement('div')
            factory.innerHTML = template
            return factory.firstElementChild
        }
    }

    /**
     * get the unicode code point of the charater.
     * - only bmp(ascii) supported. 
     * - eg: the unicode of '$' is '\u0024', the function will return '24'.
     * @return {string}
     */
    _u.getBMPCodePoint = function (char) {

        if (typeof char !== 'string') {
            throw new Error('only string type is supported')
        }

        if (char.length !== 1) {
            throw new Error('only one char is supported.')
        }

        return char.charCodeAt(0).toString(16)
    }

    /**
     * escape css selectors.
     * replace css reserved keywords with their unicode code point.
     * @return {string}
     */
    _u.escapeCSSSelector = function (value) {

        var reserveSelector = ["!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", "-", ".", "/", ":", "", "<", "=", ">", "?", "@", "[", "]", "^", "`", "{", "|", "}", "~"]

        if (typeof value !== 'string') {
            throw new Error('value must be string type.')
        }

        return value.replace(/./gi, function (char) {

            if (reserveSelector.indexOf(char) >= 0) {
                return _u.getBMPCodePoint(char)
            }
            else {
                return char
            }
        })
    }

    _u.escapeFormData = function (value) {

        var reserveSelector = ["\r", "\n", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", "-", ".", "/", ":", "", "<", "=", ">", "?", "@", "[", "]", "^", "`", "{", "|", "}", "~"]

        if (typeof value !== 'string') {
            throw new Error('value must be string type.')
        }

        return value.replace(/(?:.|\r|\n|\s)/gi, function (char) {
            if (char.charCodeAt(0) === 32) {
                return '+' //replace white-space with symbol '+'
            }
            else if (reserveSelector.indexOf(char) >= 0) {
                var hexStr = _u.getBMPCodePoint(char) //replace reserved-char with '%HH'
                return '%' + (Array(2).join('0') + hexStr).slice(-2) //fix 0 to the start if the length === 1, eg: fix %a with %0a
            }
            else {
                return char
            }
        })
    }

    _u.download = function (content, fileName, MIMEType) {
        if(!content || !fileName){
            return;
        }
    
        MIMEType = MIMEType || 'text/plain';
    
        if(window.navigator.msSaveBlob){
            var blob = new Blob([content], fileName);
            window.navigator.msSaveBlob(blob, fileName);
        }
        else{
            var anchor = document.createElement('a');
            anchor.style.visibility = 'hidden';
            document.body.appendChild(anchor);
            anchor.href = 'data:' + MIMEType + ',' + encodeURI(content);
            anchor.download = fileName;
            anchor.click();
        }
    }

    /**
     * @param {SE.PolicyModel.Entity[]} entities
     * @return {nxl.PM.Policy}
     */
    _u.getPolicyModel = function (entities) {

        var policyModels = getPolicyModels(entities)
        var components = []

        policyModels.forEach(function (pm) {
            components = components.concat(getComponents(pm.id, pm.actions))
        })

        return {
            policyModels: policyModels,
            components: components,
            policyTree: {},
            importedPolicyIds: [],
            overrideDuplicates: false,
            componentToSubCompMap: {}
        }
    }

    _u.isLightning = function() {
        return (window.sforce && window.sforce.one)
    }

    //#region - initialize policy model
    /**
     * @param {SE.PolicyModel.Entity[]} entities
     * @return {nxl.PM.PolicyModel[]}
     */
    function getPolicyModels(entities) {
        return entities.map(function (entity, index) {
            return {
                id: index,
                name: (entity.name.toLowerCase() === 'user') ? entity.displayName : 'SF_' + entity.displayName,
                shortName: (entity.name.toLowerCase() === 'user') ? entity.name.toLowerCase() : 'sf_' + entity.name.toLowerCase(),
                description: '',
                type: (entity.name.toLowerCase() === 'user') ? 'SUBJECT' : 'RESOURCE',
                status: 'ACTIVE',
                attributes: getAttributes(entity.attributes),
                actions: getActions(entity),
                obligations: getObligations(entity.attributes)
            }
        })
    }

    /**
                 * get policy model attributes
                 * @param {SE.ViewModel.Attribute[]} attrs
                 * @return {nxl.PM.Attribute[]}
                 */
    function getAttributes(attrs) {
        return attrs.map(function (attr, index) {
            return {
                id: index,
                name: attr.displayName,
                shortName: attr.name,
                sortOrder: index,
                dataType: getDatatype(attr.datatype),
                operatorConfigs: getAttributeOperators(getDatatype(attr.datatype))
            }
        })
    }

    /**
                 * get repective datatype in cc
                 * @param {string} datatype 
                 * @return {string}
                 */
    function getDatatype(datatype) {

        if(NUMBER_TYPE_IN_CC.indexOf(datatype.toLowerCase()) >= 0) {
            return 'NUMBER'
        } else {
            return 'STRING'
        }
    }

    /**
                 * @param {SE.PolicyModel.Entity} entity
                 * @return {nxl.PM.Action[]}
                 */
    function getActions(entity) {

        var actions = []

		if(entity.name === CONNECT_APP_NAME) {
	        actions = CONNECT_APP_ACTION_SUFFIXES.map(function (action, index) {
	            return {
	                id: index,
	                name: action,
	                shortName: _u.format('{0}_{1}', entity.name.toUpperCase(), action),
	                sortOrder: index
	            }
	        })			
		} else {
	        actions = ACTION_SUFFIXES.map(function (action, index) {
	            return {
	                id: index,
	                name: action,
	                shortName: _u.format('{0}_{1}', entity.name.toUpperCase(), action),
	                sortOrder: index
	            }
	        })		
		}

        return actions
    }

    /**
                 * 
                 * @param {string} datatype 
                 * @return {nxl.PM.Operator[]}
                 */
    function getAttributeOperators(datatype) {
        if(datatype === 'NUMBER') {
            return [
                {
                    id: 0,
                    key: '<',
                    label: '<',
                    dataType: 'NUMBER'
                },
                {
                    id: 1,
                    key: '<=',
                    label: '<=',
                    dataType: 'NUMBER'
                },
                {
                    id: 2,
                    key: '=',
                    label: '=',
                    dataType: 'NUMBER'
                },
                {
                    id: 3,
                    key: '>',
                    label: '>',
                    dataType: 'NUMBER'
                },
                {
                    id: 4,
                    key: '>=',
                    label: '>=',
                    dataType: 'NUMBER'
                },
                {
                    id: 5,
                    key: '!=',
                    label: '!=',
                    dataType: 'NUMBER'
                }
            ]
        }
        else {
            return [
                {
                    id: 0,
                    key: '=',
                    label: 'is',
                    dataType: 'STRING'
                },
                {
                    id: 1,
                    key: '!=',
                    label: 'is not',
                    dataType: 'STRING'
                }
            ]
        }
    }

    /**
                 * 
                 * @return {string[]}
                 */
    function getObligationOperators() {
        return [
            'is',
            'is not',
            'greater than',
            'greater than or equals to',
            'less than',
            'less than or equals to',
            'is null',
            'is not null'
        ]
    }

    /**
                 * @param {string} name
                 * @param {string} shortName
                 * @param {SE.ViewModel.Attribute[]} attrs
                 * @return {nxl.PM.ObligationNS.Obligation[]}
                 */
    function getObligations(attrs) {

        policyModelSortOrder = 0

        var fieldGroupCount = 5

        var asfOb = {
            name: 'Apply Security Filter',
            shortName: 'record_filter',
            runAt: 'PEP',
            sortOrder: ++policyModelSortOrder,
            parameters: getASFObligationParams(attrs, fieldGroupCount),
        }

        // var ownerAllowOb = {
        //     name: 'Always Allow Owner',
        //     shortName: 'OwnerAlwaysAllow',
        //     runAt: 'PEP',
        //     sortOrder: ++policyModelSortOrder,
        //     parameters: getOAAObligationParams(),
        // }

        var alertMsgOb = {
            name: 'Alert Message',
            shortName: 'AlertMsg',
            runAt: 'PEP',
            sortOrder: ++policyModelSortOrder,
            parameters: getAMObligationParams(),
        }

        return [asfOb, alertMsgOb] //ownerAllowOb, alertMsgOb
    }

    /**
                 * 
                 * @param {string} policyModelId 
                 * @param {nxl.PM.Action[]} actions
                 * @return {nxl.PM.Component[]}
                 */
    function getComponents(policyModelId, actions) {

        var components = []

        policyModelSortOrder = 0

        components = actions.map(function (action) {
            return {
                id: ++policyModelSortOrder,
                name: action.name,
                description: 'This is a system generated Action component. Deleting the same Action in policy model definition will delete this Action component',
                type: 'ACTION',
                category: 'COMPONENT',
                policyModel: { id: policyModelId },
                actions: [action.shortName],
                status: 'APPROVED'
            }
        })

        return components
    }

    /**
                 * get apply-security-filter obligation
                 * @param {SE.ViewModel.Attribute[]} attrs
                 * @param {string} fieldGroupCount
                 * @return {nxl.PM.ObligationNS.Param[]}
                 */
    function getASFObligationParams(attrs, fieldGroupCount) {

        policyModelSortOrder = 0

        var attrShortNames = attrs.map(function (attr) { return attr.name }).join(',')
        var params = []
        var operators = getObligationOperators().join(',')

        for (var i = 0; i < fieldGroupCount; i++) {

            var fieldParam = {
                name: _u.format('{0} {1}', OB_PARAM_FIELD_NAME_PREFIX, i + 1),
                shortName: _u.format('{0}{1}', OB_PARAM_FIELD_SHORTNAME_PREFIX, i + 1),
                type: 'LIST',
                defaultValue: null,
                listValues: attrShortNames,
                hidden: false,
                editable: true,
                mandatory: i === 0,
                sortOrder: ++policyModelSortOrder,
            }

            var operatorParam = {
                name: _u.format('{0}', OB_PARAM_OPERATOR_NAME_PREFIX),
                shortName: _u.format('{0}{1}', OB_PARAM_OPERATOR_SHORTNAME_PREFIX, i + 1),
                type: 'LIST',
                defaultValue: null,
                listValues: operators,
                hidden: false,
                editable: true,
                mandatory: false,
                sortOrder: ++policyModelSortOrder,
            }

            var valueParam = {
                name: _u.format('{0}', OB_PARAM_VALUE_NAME_PREFIX),
                shortName: _u.format('{0}{1}', OB_PARAM_VALUE_SHORTNAME_PREFIX, i + 1),
                type: 'TEXT_SINGLE_ROW',
                defaultValue: null,
                listValues: null,
                hidden: false,
                editable: true,
                mandatory: false,
                sortOrder: ++policyModelSortOrder,
            }

            params.push(fieldParam)
            params.push(operatorParam)
            params.push(valueParam)
        }

        return params
    }

    /**
                 * get owner-always-allow obligation params
                 * @return {nxl.PM.ObligationNS.Param[]}
                 */
    function getOAAObligationParams() {

        policyModelSortOrder = 0

        return [{
            name: 'Always Allow Owner',
            shortName: 'OwnerAlwaysAllow',
            type: 'LIST',
            defaultValue: 'True',
            listValues: 'True,False',
            hidden: false,
            editable: true,
            mandatory: false,
            sortOrder: ++policyModelSortOrder,
        }]
    }

    /**
                 * get alert-message obligation params
                 * @return {nxl.PM.ObligationNS.Param[]}
                 */
    function getAMObligationParams() {

        policyModelSortOrder = 0

        return [{
            name: 'Message',
            shortName: 'Msg',
            type: 'TEXT_MULTIPLE_ROW',
            defaultValue: null,
            listValues: null,
            hidden: false,
            editable: true,
            mandatory: false,
            sortOrder: ++policyModelSortOrder,
        }]
    }
    //#endregion

})(window)  
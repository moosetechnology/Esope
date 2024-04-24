Class {
	#name : #SyntaxJsonToIASTVisitor,
	#superclass : #SyntaxAbstractJsonVisitor,
	#instVars : [
		'f77sourcefile',
		'model',
		'entityStack'
	],
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'private - utilities' }
SyntaxJsonToIASTVisitor >> asCollection: anObject [
	anObject ifNil: [ ^#() ].
	anObject isCollection ifTrue: [ ^anObject ].
	^{ anObject }
]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> createEsopeCommand: anEsopeCommentNode [

	| data |
	data := self processEsopeComment: anEsopeCommentNode.
	^ IASTEsopeSegCommand new
		  sourceAnchor: (self makeIndexedAnchor: data second);
		  esopeCommand: data third;
		  entityName: data fourth;
		  yourself
]

{ #category : #accessing }
SyntaxJsonToIASTVisitor >> currentEsopeSegment [
	^entityStack top isEsopeSegment
		ifTrue: [ entityStack top ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
SyntaxJsonToIASTVisitor >> f77sourcefile [
	^f77sourcefile
]

{ #category : #initialization }
SyntaxJsonToIASTVisitor >> initialize [
	super initialize.
	model := OrderedCollection new.
	entityStack := Stack new
]

{ #category : #'private - utilities' }
SyntaxJsonToIASTVisitor >> isSpecialEsopeFunctionName: aString [
	aString isString ifFalse: [ ^false ].

	^{'d__' . 's__'} includes: aString
]

{ #category : #'private - utilities' }
SyntaxJsonToIASTVisitor >> makeIndexedAnchor: aPointPair [
	^IASTIndexedFileAnchor new
		  startLine: aPointPair first x ;
		  startColumn: aPointPair first y ;
		  endLine: aPointPair second x ;
		  endColumn: aPointPair second y ;
		  fileName: f77sourcefile;
		  yourself
]

{ #category : #accessing }
SyntaxJsonToIASTVisitor >> model [
	^ model
]

{ #category : #accessing }
SyntaxJsonToIASTVisitor >> model: aCollection [
	model := aCollection
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> onFile: aProgramFileNode [
	| programFile data |
	data := super onFile: aProgramFileNode.

	programFile := IASTProgramFile new
		filename: self f77sourcefile ;
		progUnits: data second ;
		yourself.
	self model add: programFile.
	^ programFile
		
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitArgument: anArgumentNode [
	"used for argument in subprogram calls and parameter in subprogram definition"

	| data arg |
	data := super visitArgument: anArgumentNode.
	data isCollection ifFalse: [ ^data ].
	data ifEmpty: [ ^nil ].
 
	arg := (data size = 1) ifTrue: [ data first ] ifFalse: [ data second ].
	arg ifNil: [ ^nil ].

	^arg
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitArguments: anArgumentList [
	^(super visitArguments: anArgumentList)
		reject: #isNil
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitAssign_expression: anAssignExpressionNode [
	| data |
	data := super visitAssign_expression: anAssignExpressionNode.

	"Fix assignement like this ptr.attr ... = ...."
	data second isCollection
		ifTrue:  [ data second allButFirst do: [ :each | each isWrite: true  ] ]
		ifFalse: [ data second class = IASTInvocation ifFalse: [ data second isWrite: true ] ].

	^(data third isCollection 
		ifTrue:  [ { data second } , data third ]
		ifFalse: [ { data second . data third } ]
	 )
	 reject: #isNil.

]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitBinary: anNode [

	| data |
	data := super visitBinary: anNode.

	^(self asCollection: data second) , (self asCollection: data fourth)
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitBlock_data: aBlockDataNode [
	| data |
	data := super visitBlock_data: aBlockDataNode.
	^IASTBlockData new
		sourceAnchor: data first ;
		entityName: data second ;
		body: data third ;
		yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitBody: aNode [

	^(super visitBody: aNode)
		reject: #isNil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitCallStatement: aCallNode [

	| astNode data |
	data := super visitCallStatement: aCallNode.

	astNode := (self isEsopeTransformation: data second)
		           ifTrue: [ IASTVarEso newFrom: data second ]
		           ifFalse: [ 
			           IASTInvocation new
				           entityName: data second;
				           yourself ].

	^ astNode
		  sourceAnchor: (self makeIndexedAnchor: data first);
		  arguments: data third;
		  yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitCommonGroup: aCommonGroupNode [
	| data |
	data := self visitCommonGroupName: (aCommonGroupNode at: 'name').
	^IASTVariable new
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		entityName: (data second) ;
		yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitCommonStatement: aCommonStatementNode [
	^self visitCommon_groups: (aCommonStatementNode at: 'common_groups')
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitConditions: aConditionList [
	| data |
	data := super visitConditions: aConditionList.
	^(data collect: #first) , (data collect: #second)
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitContinueStatement: aContinueStatementNode [
	^nil
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitData: aDataNode [
	self flag: #TODO.
	self shouldBeImplemented
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitDeclarationStatement: aDeclarationStatementNode [
	| data |

	data := super visitDeclarationStatement: aDeclarationStatementNode.
	data fourth do: [ :iastVar | iastVar typeSpec: data second ].
	
	^entityStack
		ifNotEmpty: [
			entityStack top addAllDeclarations: data fourth.
			nil
		]
		ifEmpty: [ data fourth ]

]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitDeclarator: aDeclaratorNode [
	^self visitDeclaratorVariable: (aDeclaratorNode at: 'variable')
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitDeclaratorVariable: aDeclaratorVariableNode [
	| data |
	data := super visitDeclaratorVariable: aDeclaratorVariableNode.

	^IASTVariable new
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		entityName: data second ;
		yourself
	
	
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitDeclarators: aDeclaratorsList [
	^(super visitDeclarators: aDeclaratorsList) second
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitDo: aDoNode [
	"#(span label do_spec target body end_label)"

	| data |
	data := (super visitDo: aDoNode).
	^data third , data fifth
	 
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitDo_spec: aDoSpecNode [
	| data |
	data := (super visitDo_spec: aDoSpecNode).
	^data allButFirst flattened reject: #isNil
	 
]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopeEndsegmentComment: anEsopeCommentNode [
	"updates end of current Esope segment"
	| span |
	span := (super visitEsopeEndsegmentComment: anEsopeCommentNode) first.

	entityStack pop sourceAnchor
		endLine: (span second x) ;
		endColumn: (span second y).
	^nil
]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopeIncludeComment: anEsopeIncludeCommentNode [

	| data |
	data := super visitEsopeIncludeComment: anEsopeIncludeCommentNode.
	^ IASTInclude new
		  sourceAnchor: (self makeIndexedAnchor: data second);
		  entityName: data fourth;
		  includeCommand: data third;
		  yourself
]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopePointeurComment: anEsopeCommentNode [
	| data |
	data := super visitEsopePointeurComment: anEsopeCommentNode.
	^IASTEsopePointer new
		sourceAnchor: (self makeIndexedAnchor: data second) ;
		entityName: data fourth ;
		yourself.

]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopeSegactComment: anEsopeCommentNode [

	^self createEsopeCommand: anEsopeCommentNode

]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopeSegadjComment: anEsopeCommentNode [

	^self createEsopeCommand: anEsopeCommentNode

]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopeSegdesComment: anEsopeCommentNode [

	^self createEsopeCommand: anEsopeCommentNode

]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopeSeginiComment: anEsopeCommentNode [

	^self createEsopeCommand: anEsopeCommentNode

]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopeSegmentComment: anEsopeCommentNode [
	"Source anchor for the segment is wrong,
	 endLine/endColumn will be updated in #visitEsopeEndsegmentComment:"

	| data seg |
	data := super visitEsopeSegmentComment: anEsopeCommentNode.
	seg := IASTEsopeSegment new
		sourceAnchor: (self makeIndexedAnchor: data second) ;
		entityName: data fourth ;
		declarations: (OrderedCollection new: 5) ;
		yourself.
	entityStack push: seg.
	^seg
]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitEsopeSegsupComment: anEsopeCommentNode [

	^self createEsopeCommand: anEsopeCommentNode

]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitExitStatement: anExitNode [

	^(super visitExitStatement: anExitNode) second
]

{ #category : #'visiting esope' }
SyntaxJsonToIASTVisitor >> visitExternalStatement: anExternalStatementNode [

	| data |
	data := super visitExternalStatement: anExternalStatementNode.

	^ data second do: [ :anAccess | anAccess annotations: 'external' ]
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitFortranComment: aFortranCommentNode [
	| data |
	data := super visitFortranComment: aFortranCommentNode.
	^IASTComment new
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		text: data second ;
		yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitFrom: aString [
	"start of a range for an implicit statement: a string of one character"

	^aString first
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitFunctionAsValue: aFunctionNode [
	^(super visitFunctionAsValue: aFunctionNode)
		second

]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitFunctionParameters: aParameterList [
	^super visitFunctionParameters: aParameterList
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitFunctionStatement: aFunctionNode [
	"for now assuming this is an ESOat/ar/sl function"
	| data fct fctName |
	data := super visitFunctionStatement: aFunctionNode.
	
	fctName := data second entityName.
	fct := (self isSpecialEsopeFunctionName: fctName)
		ifTrue: [ IASTVarEso newFrom: fctName ]
		ifFalse: 	[ IASTStFunction new  ].

	fct sourceAnchor: (self makeIndexedAnchor: data first).
	fct	isWrite: true.
	fct	entities: (data third reject: #isNil).

	^data fourth
		ifNil: [ { fct } ]
		ifNotNil: [ { fct . data fourth } ]
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitFunctionWithBlocks: aFunctionNode [
	| data |
	data := super visitFunctionWithBlocks: aFunctionNode.
	^IASTFunction new
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		entityName: data second ;
		returnType: data third ;
		parameters: data fourth ;
		body: data fifth ;
		yourself

]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitFunction_call: aFunctionCallNode [

	| astNode data functionName |
	data := super visitFunction_call: aFunctionCallNode.

	functionName := data second.
	astNode := (self isSpecialEsopeFunctionName: functionName)
		ifTrue: [
			(IASTVarEso newFrom: functionName)
				entities: data third ;
				yourself
		]
		ifFalse: 	[IASTInvocation new
			arguments: data third ;
			yourself
	].

	^astNode
		entityName: functionName ;
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitGotoStatement: aGotoStatementNode [

	^nil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitIf: anIfNode [
	"super visit keys: #(span label conditions blocks)"

	| data |
	data := super visitIf: anIfNode.

	^data third , data fourth
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitIf_logicalStatement: anIfNode [

	| data |
	data := super visitIf_logicalStatement: anIfNode.
	^data allButFirst
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitImplicitStatement: anImplicitStatementNode [

	| data implicit |
	data := super visitImplicitStatement: anImplicitStatementNode.

	implicit := IASTImplicit new
		            sourceAnchor: (self makeIndexedAnchor: data first);
		            yourself.
	data second ifNotNil: [ 
		implicit rules: data second ].

	^ implicit
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitImplicitStatementRange: anImplicitStatementRangeNode [
	| data |
	data := super visitImplicitStatementRange: anImplicitStatementRangeNode.

	^data third
		ifNil: [ { data second . data second } ]
		ifNotNil: [ { data second . data third } ]
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitInteger: anIntegerNode [
	^nil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitItems: anImplicitItemsNode [
	"'items' in implicit statement"

	| data |
	data := super visitItems: anImplicitItemsNode.

	^data
		ifNotNil: [
			data second collect: [ :ruleData |
				IASTImplicitTypingRule new
					sourceAnchor: (self makeIndexedAnchor: ruleData first) ;
					forType: ruleData second ;
					ranges: ruleData third
					yourself
			]
	]
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitMain: aMainProgramNode [
 	| data |
	data := super visitMain: aMainProgramNode.

	^IASTMainProgram new
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		entityName: data second ;
		body: data third ;
		yourself

]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitMiFilename: aString [
	f77sourcefile := aString
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitReal: aRealNode [
	^nil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitReturnStatement: aReturnStatementNode [
	| data |
	data := super visitReturnStatement: aReturnStatementNode.

	^data second
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitSingle: anArraySingleIndexNode [
	| data |
	data := super visitSingle: anArraySingleIndexNode.
	^data second

]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitSpanOf: aNode [
	^self makeIndexedAnchor: (self visitSpan: (aNode at: 'span'))
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitStatement: aStatementNode [
	"not interested in 'span' and 'label'
	so overwrite completely the super method"
	^(self isTaggedStatement: aStatementNode)
			ifTrue: [ self visitJsonTaggedStatement: aStatementNode ]
			ifFalse: [ self visitJsonElement: (aStatementNode at: 'statement') ]
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitSubroutine: aSubroutineNode [

	| data entity |
	data := super visitSubroutine: aSubroutineNode.

	entity := data second = '__$__'
		          ifTrue: [ IASTIncludedFile new ]
		          ifFalse: [ 
			          IASTSubroutine new
				          parameters: data third;
				          yourself ].
	^entity
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		entityName: data second ;
		body: data fourth ;
		yourself
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitSubscript: aSubscriptNode [

	| data |
	data := super visitSubscript: aSubscriptNode.
	^data second isArray
		ifTrue:  [
			"
			var.attr(l:u:s)
			data second third -> attr
			     indices --> (l:u:s)
			     dereferencedVariable --> var (MUST BE VISITED DURING SYMBOL RESOLUTION) 
			"
			data second third
				indices: data third ;
				dereferencedVariable: data second second;
				yourself
		]
		ifFalse: [
			data second
				indices: data third ;
				yourself
		]

]

{ #category : #'as yet unclassified' }
SyntaxJsonToIASTVisitor >> visitTo: aString [
	"end of a range for an implicit statement: a string of one character"

	^aString
		ifNil: [ nil ]
		ifNotNil: [ aString first ]
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitType: aTypeNode [
	| data |
	data := (super visitType: aTypeNode) reject: #isNil.

	^IASTTypeRef new
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		entityName: (data second) ;
		yourself
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitUnary: aUnaryNode [
	| data |
	data := super visitUnary: aUnaryNode.

	^data third ifNil: [ nil ] ifNotNil: [ :entity | entity ]
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitValue: aValueNode [

	| data |
	data := super visitValue: aValueNode.

	^ data second ifNil: [ nil ] ifNotNil: [ :var | 
		  (var isString or: [ var isArray ]) ifFalse: [ 
			  var
				  sourceAnchor: (self makeIndexedAnchor: data first);
				  yourself ] ]
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitVariable: aVariableNode [
	| data |
	data := super visitVariable: aVariableNode.
	self flag: #FIXME. "Adding sourceAnchor ? "
	^IASTVarAccess new
		isWrite: false ;
		entityName: data ;
		yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitWriteStatement: aWriteStatementNode [
	| data |
	data := super visitWriteStatement: aWriteStatementNode.

	^{ IASTInvocation new
		sourceAnchor: (self makeIndexedAnchor: data first) ;
		entityName: 'write' ;
		arguments: data third ;
		yourself }
]

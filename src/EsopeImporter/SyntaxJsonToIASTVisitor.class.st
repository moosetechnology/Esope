"
A visitor for JSON output of the Syntax parser to build an intermediary representation
"
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
SyntaxJsonToIASTVisitor >> isEsopeTransformation: aString [

	aString isString ifFalse: [ ^ false ].
	^ #( #d__ #s__ ) includes: aString
]

{ #category : #'private - utilities' }
SyntaxJsonToIASTVisitor >> makeIndexedAnchor: aNode [
	| start end |
	start := aNode at: #start_pos ifAbsent: [ 0@0 ].
	end := aNode at: #end_pos ifAbsent: [ 0@0 ].

	^IASTIndexedFileAnchor new
		startLine: start x ;
		startColumn: start y ;
		endLine: end x ;
		endColumn: end y ;
		fileName: f77sourcefile;
		yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> makeLoopControl: data [

	| init |
	init := (self newEntity: FASTFortranAssignmentExpression)
		        variable: (data at: #variable_name) ;
		        expression: (self variableNameOrExpression: (data at: #init)) ;
		        yourself.

	^ (self newEntity: FASTFortranLoopControlExpression)
		  init: init;
		  limit: (self variableNameOrExpression: (data at: #limit));
		  increment: (data at: #increment ifAbsent: [ nil ]);
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

{ #category : #'private - utilities' }
SyntaxJsonToIASTVisitor >> newEntity: anIASTClass withPosition: aNode [

	^anIASTClass new
		sourceAnchor: (self makeIndexedAnchor: aNode) ;
		yourself
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> onFile: aProgramFileNode [
	| programFile data |
	data := super onFile: aProgramFileNode.

	programFile := IASTProgramFile new
		filename: self f77sourcefile ;
		progUnits: (data at: #program_units) ;
		yourself.
	self model add: programFile.
	^ programFile
		
]

{ #category : #'private - utilities' }
SyntaxJsonToIASTVisitor >> variableNameOrExpression: anObject [
	"Scalar variables appear as Dictionary with a #name and a #start_pos,
	 otherwise, don't do anything"

	^anObject isDictionary
		ifTrue: [ (self newEntity: IASTVarAccess withPosition: anObject)
			entityName: (anObject at: #name) ;
			yourself ]
		ifFalse: [ anObject ]
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitArguments: anArgumentList [
	^(super visitArguments: anArgumentList)
		select: #isNotNil
		thenCollect: [ :each | self variableNameOrExpression: each ]
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitArithmeticIfStatement: aNode [

	^(super visitArithmeticIfStatement: aNode) at: #expression
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitArrayElementName: aNode [
	"name tag qualifiers_list"

	| data |
	data := super visitArrayElementName: aNode.

	^IASTVarAccess new
		  entityName: ((data at: 'name') at: #name) ;
		  indices: (data at: 'qualifiers_list');
		  yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitAssignmentStatement: aNode [
	"start_pos right left"

	| data |
	data := super visitAssignmentStatement: aNode.

	^{
		IASTVarAccess new
			entityName: ((data at: #left) at: #name) ;
			isWrite: true ;
			yourself
		.
		self variableNameOrExpression: (data at: #right)
	} flattened reject: #isNil
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitBinaryExpression: aNode [
	"expression lhs operator"

	| data |

	data := super visitBinaryExpression: aNode.

	^{ self variableNameOrExpression: (data at: 'lhs')
		.
		self variableNameOrExpression: (data at: 'rhs') }
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitBlockData: aNode [
	"start_pos prog_unit_parameters end_pos statement_list name tag"

	| data progUnit |
	data := super visitBlockData: aNode.

	progUnit := (self newEntity: IASTBlockData withPosition: data)
		entityName: ((data at: 'name') at: #name);
		body: (data at: 'statement_list');
		yourself.

	"self checkForComments: progUnit."

	^progUnit
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitBlockIfStatement: aNode [

	| data |
	data := super visitBlockIfStatement: aNode.
	
	^{ data at: #condition .
		data at: #then_statements .
		data at: #else_block }
			flattened reject: #isNil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitCallStatement: aNode [
	"start_pos tag name arguments"

	| data astNode name |
	data := super visitCallStatement: aNode.

	name := (data at: 'name') at: #name.

	astNode := (self isEsopeTransformation: name)
		ifTrue: [ IASTVarEso newFrom: name ]
		ifFalse: [ 
			IASTInvocation new
				entityName: name ;
				yourself ].

	^ astNode
		  sourceAnchor: (self makeIndexedAnchor: data);
		  arguments: (data at: 'arguments') ;
		  yourself
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitCharacterConstant: aNode [

	^nil
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitCharacterType: aNode [

	^'CHARACTER'
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitConstantSigned: aNode [

	^(super visitConstantSigned: aNode) at: #constant
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitContinueStatement: aContinueStatementNode [
	^nil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitDoStatement: aNode [

	| data |
	data := super visitDoStatement: aNode.

	^(data at: #loop_control) , (data at: #statement_list)
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitElseBlock: aNode [

	^(super visitElseBlock: aNode) at: #statement_list
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitFile: aFileName [

	f77sourcefile := aFileName
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitFunction: aNode [
	" name prog_unit_parameters return_type start_pos end_pos statement_list "

	| data progUnit |
	data := super visitFunction: aNode.

	progUnit := (self newEntity: IASTFunction withPosition: data)
		entityName: ((data at: 'name') at: #name);
		parameters: (data at: 'prog_unit_parameters');
		body: (data at: 'statement_list');
		returnType: (data at: 'return_type');
		yourself.

	"self checkForComments: progUnit."

	^progUnit
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitGotoStatement: aGotoStatementNode [

	^nil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitImplicitNoneStatement: aNode [

	^self newEntity: IASTImplicit withPosition: (super visitImplicitNoneStatement: aNode)
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitImplicitParameter: anImplicitParameter [
	"type implicit_elements"

	| data |
	data := super visitImplicitParameter: anImplicitParameter.

	^IASTImplicitTypingRule new
		forType: (data at: #type) ;
		ranges: (data at: #implicit_elements) ;
		yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitImplicitRange: aNode [
	"implicit_range_lower implicit_range_upper"

	| data lower upper |
	data := super visitImplicitRange: aNode.

	lower := data at: #implicit_range_lower.
	upper := data at: #implicit_range_upper.

	^upper
		ifNil: [ { lower . lower } ]
		ifNotNil: [ { lower . upper } ]
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitImplicitRangeLower: aString [
	
	^aString ifEmpty: [ nil ] ifNotEmpty: [ aString first ]
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitImplicitRangeUpper: aString [
	
	^aString ifEmpty: [ nil ] ifNotEmpty: [ aString first ]
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitImplicitStatement: aNode [
	"start_pos implicit_parameters"

	| data |
	data := super visitImplicitStatement: aNode.

	^(self newEntity: IASTImplicit withPosition: data)
		rules: (data at: #implicit_parameters) ;
		yourself
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitIncrement: aNode [

	^self variableNameOrExpression: (super visitIncrement: aNode)

]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitInit: aNode [
		
	^self variableNameOrExpression: (super visitInit: aNode)
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitIntegerType: aNode [

   ^'INTEGER'
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitIoList: aCollection [
 
   | data |
	data := super visitIoList: aCollection.

	^data
		select: #isNotNil
		thenCollect: [ :each |
			each isDictionary 
				ifTrue: [ (self newEntity: IASTVarAccess withPosition: each)
					entityName: (each at: #name) ;
					yourself
				]
				ifFalse: [ each ]
	]
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitLabeledStatement: aNode keys: keyCollection [
	"ignore labels"

	^self visitJsonMap: aNode keys: keyCollection

]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitLimit: aNode [

	^self variableNameOrExpression: (super visitLimit: aNode)
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitLiteralExpression: aNode [

	^nil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitLogicalIfStatement: aNode [

	| data |
	data := super visitLogicalIfStatement: aNode.
	^{ self variableNameOrExpression: (data at: #expression) .
		data at: #statement }
			flattened reject: #isNil
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitLogicalType: aNode [

	^'LOGICAL'
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitLoopControl: aNode [

	| data |
	data := super visitLoopControl: aNode.

	^#(variable_name init limit increment)
		collect: [ :key | data at: key ifAbsent: [ nil ] ]
		thenSelect: #isNotNil
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitMain: aMainProgramNode [
 	| data |
	data := super visitMain: aMainProgramNode.

	^(self newEntity: IASTMainProgram withPosition: data)
		entityName: ((data at: #name) at: #name) ;
		body: (data at: #statement_list) ;
		yourself

]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitProgUnitParameters: aCollection [ 

	^(self visitJsonArray: aCollection) collect: [ :parameter |
		(self newEntity: IASTParameter  withPosition: parameter)
			entityName: (parameter at: #name) ;
			yourself ]
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitQualifiersList: aNode [

	^(super visitQualifiersList: aNode)
		collect: [ :each |
		  self variableNameOrExpression: each ]
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitRealType: aNode [

	^'REAL'
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitReturnStatement: aNode [

	^nil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitStatementList: statementCollection [

	^(super visitStatementList: statementCollection)
		reject: #isNil
]

{ #category : #'visiting prog-unit' }
SyntaxJsonToIASTVisitor >> visitSubroutine: aSubroutineNode [

	| data name entity |
	data := super visitSubroutine: aSubroutineNode.

	"name is a #symbolic_name with a #position and a #name"
	name := (data at: #name) at: #name.

	entity := (name = '__$__')
		          ifTrue: [ IASTIncludedFile new ]
		          ifFalse: [ 
			          IASTSubroutine new
				          parameters: (data at: #prog_unit_parameters);
				          yourself ].
	^entity
		sourceAnchor: (self makeIndexedAnchor: data) ;
		entityName: name ;
		body: (data at: #statement_list) ;
		yourself
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitSymbolicName: aSymbolicName [

	^self visitJsonMap: aSymbolicName keys: #(start_pos name)
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitTypeReference: aNode [

	| data return |
	data := super visitTypeReference: aNode.

	return := IASTTypeRef new
		entityName: (data at: #name) ;
		yourself.
	data at: #len_specification ifPresent: [ :size | return length: size ].

	^return
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitUnconditionalGotoStatement: aNode [

	^nil
]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitUnsignedIntConstant: aNode [

	^nil
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitVariableDeclarationStatement: aNode [
	"start_pos tag declarators type"

	| data |
	data := super visitVariableDeclarationStatement: aNode.

	(data at: 'declarators') do: [ :iastVar | iastVar typeSpec: (data at: 'type') ].

	^entityStack
		ifNotEmpty: [
			entityStack top addAllDeclarations: (data at: 'declarators').
			nil
		]
		ifEmpty: [ data at: 'declarators' ]

]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitVariableDeclarator: aNode [
	"variable dimension_declarators expression

	1- not sure expression is possible in Fortran-77
	2- only interested in the `variable` as `dimension_declarator` must be a literal ?"

	| data |
	data := (super visitVariableDeclarator: aNode) at: #variable.

	^(self newEntity: IASTVariable withPosition: data)
		entityName: (data at: #name) ;
		yourself

]

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitVariableName: aNode [

	| data |
	data := super visitVariableName: aNode.

	^(self newEntity: IASTVarAccess withPosition: data)
		entityName: (data at: #name) ;
		yourself
]

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitWriteStatement: aNode [
    "start_pos control_info_list io_list"

	| data |
	data := super visitWriteStatement: aNode.

	^{ (self newEntity: IASTInvocation withPosition: data)
			entityName: 'WRITE' ;
			"ioParameters: (data at: #control_info_list) ;"
			arguments: (data at: #io_list) ;
			yourself }
]

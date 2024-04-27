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

{ #category : #'visiting statement' }
SyntaxJsonToIASTVisitor >> visitContinueStatement: aContinueStatementNode [
	^nil
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

{ #category : #'visiting expression' }
SyntaxJsonToIASTVisitor >> visitLiteralExpression: aNode [

	^nil
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitLogicalType: aNode [

	^'LOGICAL'
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

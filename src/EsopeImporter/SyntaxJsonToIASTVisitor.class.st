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

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitCharacterType: aNode [

	^'CHARACTER'
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

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitIntegerType: aNode [

   ^'INTEGER'
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

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitRealType: aNode [

	^'REAL'
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
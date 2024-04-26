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

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitCharacterType: aNode [

	self shouldNotImplement
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitFile: aFileName [

	f77sourcefile := aFileName
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitIntegerType: aNode [

   self shouldNotImplement 
]

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitLogicalType: aNode [

	self shouldNotImplement 
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

{ #category : #visiting }
SyntaxJsonToIASTVisitor >> visitRealType: aNode [

	self shouldNotImplement 
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

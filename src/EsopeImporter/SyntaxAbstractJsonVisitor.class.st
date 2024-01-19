Class {
	#name : #SyntaxAbstractJsonVisitor,
	#superclass : #Object,
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> generateMethod: aNode selector: selector [

	aNode isArray
		ifTrue: [
			^ selector , ' aNode
			      "comment"
			
			      self visitJsonArray: aNode' ].
		
	aNode isDictionary ifTrue: [
		| keys |
		keys := aNode keys reduce: [ :a :b | a , ' ' , b ].
		
		^ selector , ' aNode
    "comment"

    self visitJsonMap: aNode keys: #(' , keys , ')'.
		 ].	

	1 halt.
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitArithmetic_if_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos s1 s2 expression s3)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitAssignment_statement: aNode [
			      "comment"
			      1 halt.
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitBackspace_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitBlock_data: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters end_pos statement_list name)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitBlock_if_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos then_statements else_block expression)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitCall_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos name arguments)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitClose_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitComments: aComments [

	"ignore for the moment"
	
	^ #()
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitCommon_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitContinue_statement: aContinueStatement [
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitData_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitDimension_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos array_declarators)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitDo_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos statements_list loop_control statement_number)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEnd_pos: aEndPos [
	
	^ (aEndPos at: 'line') asInteger @ (aEndPos at: 'column') asInteger
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitEndfile_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitEntry_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(name start_pos parameters)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitEquivalence_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitExternal_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(proc_list start_pos)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitFormat_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(label specification)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitFunction: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters end_pos statement_list name)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitFunction_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters expression name)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitGoto_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(var start_pos labels type)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitImplicit_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitInquire_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitIntrinsic_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos fun_list)
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonArray: aCollection [
	^aCollection collect: [ :each | self visitJsonElement: each ]
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonElement: aNode [
	aNode ifNil: [ ^nil ].
	aNode isDictionary  ifTrue: [ ^self visitJsonMap: aNode ].
	aNode isArray  ifTrue: [ ^self visitJsonArray: aNode ].
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonMap: jsonDictionary [
	"If dicionary contains key 'tag', performs a visit of the whole node for this tag,
	otherwise, perform a visit of each value for their key
	'anno' key always ignored"

	jsonDictionary removeKey: 'anno' ifAbsent: [ "nothing" ].

	^ (jsonDictionary includesKey: 'tag')
		  ifTrue: [ self visitJsonTaggedElement: jsonDictionary ]
		  ifFalse: [
			  jsonDictionary associations collect: [ :assoc |
				  self visitKey: assoc key value: assoc value ] ]
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonMap: jsonDictionary keys: aCollection [
	"visit only the keys listed in aCollection in the jsonDictionary"

	^ aCollection collect: [ :key |
		  self visitJsonNode: jsonDictionary key: key
	]
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonNode: aJsonNode key: key [
	^self visitKey: key value: (aJsonNode at: key)
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonTaggedElement: jsonDictionary [
	"similar to #visitJsonNode: , but removes first the 'tag' key from the JsonDisctionary
	 so that it is not visited again (not sure this is needed ...?)"

	| key |
	key := jsonDictionary removeKey: 'tag'.
	^ self visitKey: key value: jsonDictionary
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonTaggedStatement: aStatementNode [
	"a statementNode containing a tagged element
	 Similar to #visitJsonTaggedElement: on the tagged element, but adds 'Statement' to the selector"

	| key value |
	value := aStatementNode at: 'statement' ifAbsent: [ aStatementNode ].
	key := value removeKey: 'tag'.
	^ self visitKey: key , 'Statement' value: value
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitKey: key value: aNode [

	| selector aClass abstrMethod implMethod |
	
	selector := ('visit' , key capitalized , ':') asSymbol.
	aClass := SyntaxAbstractJsonVisitor.
	(aClass selectors includes: selector)
		ifFalse: [
			abstrMethod := self generateMethod: aNode selector: selector. 
			
			implMethod := selector,' aNode
			      "comment"
			      1 halt'.
			
			"add method to both abstract and current visitor"
			aClass compile: abstrMethod.
			self class compile: implMethod.
		 ].
	
	 ^ self perform: selector with: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLeft: aNode [
			      "comment"
			
			      self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLogical_if_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(statement start_pos expression)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitMain: aMain [

	^ self visitJsonMap: aMain keys: #(start_pos statement_list end_pos name)  
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitName: aName [

	"^ aName at: 'name'"
    
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitOpen_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameter: aParameter [
	
	^ self subclassResponsibility
    
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitParameter_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameters: aParameters [
	
	^ aParameters isEmpty 
		ifTrue: [ #()]
		ifFalse: [ aParameters collect: [ :each | self visitParameter: each ] ]
    
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitPause_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos argument)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitPrint_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(format start_pos io_list)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitProgramFile: aProgramFile [
	"a program file containing comments, program units, tag (fortran_file) and file name. everything else than program units are ingonred for the moment"

	^ self visitJsonMap: aProgramFile keys: #(program_units) 
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitProgram_units: aProgramUnits [

	^ self visitJsonArray: aProgramUnits 
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitRead_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(format start_pos io_list control_info_list)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitRewind_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos parameters)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitRight: aNode [
			      "comment"
			
			      self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitSave_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos var_list)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStart_pos: aStartPos [
	
	^ (aStartPos at: 'line') asInteger @ (aStartPos at: 'column') asInteger
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStatement_list: aStatementList [

	^ aStatementList collect: [ :each | self visitJsonMap: each ]
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitStop_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitSubroutine: aSubroutine [
	 
	^ self visitJsonMap: aSubroutine keys: #(start_pos parameters end_pos statement_list name) 
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitSymbolic_name: aSymbolicName [

	^ aSymbolicName at: 'name'
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitType_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos declarators type)
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitWrite_statement: aNode [
    "comment"

    self visitJsonMap: aNode keys: #(start_pos control_info_list io_list)
]

Class {
	#name : #SyntaxAbstractJsonVisitor,
	#superclass : #Object,
	#classInstVars : [
		'aNode'
	],
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'method generation' }
SyntaxAbstractJsonVisitor >> abstractMethodForJsonArrayElement: selector [

	^ selector , ' aNode
   <generated>
 
   ^ self visitJsonArray: aNode'
]

{ #category : #'method generation' }
SyntaxAbstractJsonVisitor >> abstractMethodForJsonDictionaryElement: selector keys: keys [


	^ selector , ' aNode
    <generated>
	| result values keys |
	1 halt.
				
	keys := #( ' , (keys joinUsing: ' ') , ' ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result'.
]

{ #category : #'method generation' }
SyntaxAbstractJsonVisitor >> abstractMethodForJsonTaggedElement: selector [


	^ selector , ' aNode
   <generated>
	1 halt.
		
	^ self visitJsonTaggedElement: aNode'
]

{ #category : #'method generation' }
SyntaxAbstractJsonVisitor >> abstractMethodJsonElement:  selector [

^ selector , ' aNode
	<generated>
	
	1 halt.'
]

{ #category : #'method generation' }
SyntaxAbstractJsonVisitor >> createVisitSelector: key [

	^ ('visit' , ((('_' split: key) collect: [ :each | each capitalized ])
		   joinUsing: '') , ':') asSymbol
]

{ #category : #'method generation' }
SyntaxAbstractJsonVisitor >> generateAbstractMethod: aNode selector: selector [

	"array"
	aNode isArray ifTrue: [
		^ self abstractMethodForJsonArrayElement: selector ].

	"dictionary"
	aNode isDictionary ifTrue: [
		| keys |
		keys := aNode keys.

		(keys includes: 'tag')
			ifTrue: [
				((self createVisitSelector: (aNode at: 'tag')) = selector)
					ifTrue: [ ^ self abstractMethodForJsonDictionaryElement: selector keys: keys ]
					ifFalse: [ ^ self abstractMethodForJsonTaggedElement: selector] ]
			ifFalse: [
			^ self abstractMethodForJsonDictionaryElement: selector keys: keys ] ].

	"not array, not dictionary"
	^ self abstractMethodJsonElement: selector
]

{ #category : #'method generation' }
SyntaxAbstractJsonVisitor >> generateImplMethod: aNode selector: selector [

	| keys |
	aNode isDictionary
		ifTrue: [ keys := aNode keys joinUsing: ' ' ]
		ifFalse: [ keys := 'no keys in data' ].

	^ selector , ' aNode
			  		<generated>
					"', keys ,'"
					
					| data |    
					data := super ' , selector , 'aNode.
			      1 halt.
					^ data'
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitArgumentWithReturnSpecifier: aNode [

	<generated>
	| result values keys |
	keys := #( start_pos return_specifier argument ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitArguments: aNode [
		<generated>
			
			^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitArithmeticExpression: aNode [
	"generated"

	^ self visitJsonMap: aNode keys: #( expression )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitArithmeticIfStatement: aNode [
   <generated>
	| result values keys |
	1 halt.
				
	"keys := #( start_pos s1 s3 s2 expression tag ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result"
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitArrayElementName: aNode [
    <generated>
	| result values keys |
				
	keys := #( name qualifiers_list ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitAssignmentStatement: aNode [

	| result values keys |

	keys := #( start_pos right left ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitAsterisk: aNode [

	^ aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitBinaryExpression: aNode [

	<generated>
	| result values keys |
	keys := #( rhs lhs operator ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitBlockIfStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos then_statements else_block expression ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitCallStatement: aNode [
   <generated>
	| result values keys |
				
	keys := #( start_pos name arguments ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitCharacterConstant: aNode [
   <generated>
	| result values keys |
				
	keys := #( start_pos value ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitCharacterExpression: aNode [

	<generated>
	| result values keys |
	
	keys := #( expression ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitCharacterType: aNode [

	| result values keys |
	keys := #( len_specification ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitComments: aComments [

	"ignore for the moment"
	
	^ #()
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitConstant: aNode [
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitConstantSigned: aNode [
   <generated>
	| result values keys |
				
	keys := #( sign constant ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitContinueStatement: aNode [
   <generated>
	| result values keys |
			
	keys := #( start_pos label).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDeclarators: aNode [

	<generated>
	^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDimensionDeclarators: aNode [
		<generated>
			
			^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitElseBlock: aNode [
    <generated>
	| result values keys |
				
	keys := #( else_statements end_if ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitElseStatements: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEndIf: aNode [
 
	| result values keys |
				
	keys := #( label ).
	values := (self visitJsonMap: aNode keys: keys).
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEndPos: aEndPos [
	
	^ (aEndPos at: 'line') asInteger @ (aEndPos at: 'column') asInteger
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitExpression: aNode [
				"generated"
		
		^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitFunction: aNode [

	<generated>
	| result values keys |
	keys := #( start_pos parameters end_pos statement_list return_type
	           name ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitFunctionReference: aNode [
   <generated>
	| result values keys |
				
	keys := #( name ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitIntegerType: aNode [

   self subclassResponsibility
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonArray: aCollection [

	^ aCollection collect: [ :each | self visitJsonElement: each ]
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonElement: aNode [

	aNode ifNil: [ ^ nil ].
	aNode isDictionary ifTrue: [ ^ self visitJsonMap: aNode ].
	aNode isArray ifTrue: [ ^ self visitJsonArray: aNode ]
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

	^ self visitKey: key value: (aJsonNode at: key)
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonTaggedElement: jsonDictionary [
	"similar to #visitJsonNode: , but removes first the 'tag' key from the JsonDisctionary
	 so that it is not visited again (not sure this is needed ...?)"

	| key |
	key := jsonDictionary at: 'tag'.
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
	
	selector := self createVisitSelector: key.
	aClass := SyntaxAbstractJsonVisitor.
	(aClass selectors includes: selector) ifFalse: [
		abstrMethod := self generateAbstractMethod: aNode selector: selector.

		implMethod :=  self generateImplMethod: aNode selector: selector.
		
		"add method to both abstract and current visitor"
		aClass compile: abstrMethod.
		self class compile: implMethod ].

	^ self perform: selector with: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLabel: aNode [
	<generated>

	^ aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLeft: aNode [

	^ (self visitJsonArray: aNode) first
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLenSpecification: aNode [
    <generated>
	| result values keys |
	
	1 halt.
	keys := #( asterisk ).
	values := (self visitJsonMap: aNode keys: keys).
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLhs: aNode [

	^ self visitJsonElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLiteral: aNode [
				"generated"
		
		^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLiteralExpression: aNode [
	"generated"

	^ self visitJsonMap: aNode keys: #( literal )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLogicalConstant: aNode [

	^ (self visitJsonMap: aNode keys: #( value )) first
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLogicalExpression: aNode [

	^ (self visitJsonMap: aNode keys: #( expression )) first
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLogicalFactor: aNode [
	"TODO should visit negated as well"

	^ (self visitJsonMap: aNode keys: #( expression )) first
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLogicalPrimary: aNode [

	^ (self visitJsonMap: aNode keys: #( expression )) first
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLogicalType: aNode [

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLowerBound: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitMain: aNode [
   <generated>
	| result values keys |
				
	keys := #( start_pos parameters end_pos statement_list name ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitName: aName [

	aName class = ByteString ifTrue: [ ^ aName ].

	^ self visitJsonTaggedElement: aName
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitOperator: aNode [

	^ aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameter: aParameter [
	
	^ self subclassResponsibility
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameters: aParameters [
	
	^ aParameters isEmpty 
		ifTrue: [ #()]
		ifFalse: [ aParameters collect: [ :each | self visitParameter: each ] ]
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitProgramFile: aProgramFile [
	"a program file containing comments, program units, tag (fortran_file) and file name. everything else than program units are ingonred for the moment"

	^ self visitJsonMap: aProgramFile keys: #(program_units) 
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitProgramUnits: aNode [

	^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitQualifiersList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitRealType: aNode [

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitReturnSpecifier: aNode [
	<generated>
	
	1 halt.
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitReturnType: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitRhs: aNode [

	^ self visitJsonElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitRight: aNode [
	
	^ (self visitJsonArray: aNode) first
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitSign: aNode [

	^ aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStartPos: aStartPos [
	"generated"

	^ (aStartPos at: 'line') asInteger
	  @ (aStartPos at: 'column') asInteger
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStatementList: aStatementList [
	"generated"

	^ aStatementList collect: [ :each | self visitJsonMap: each ]
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitSubroutine: aSubroutine [
	"generated"

	^ self
		  visitJsonMap: aSubroutine
		  keys: #( start_pos parameters end_pos statement_list
		     name )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitSymbolicName: aSymbolicName [
	
	^ aSymbolicName at: 'name'
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitTag: aNode [
	<generated>
	
	1 halt.
	"if you are here, you forgot to remove tag from the list of keys to visit"
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitThenStatements: aNode [
		<generated>
			
			^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitType: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitTypeReference: aNode [
    "generated"

	^ self visitKey: ((aNode at: 'name') asLowercase capitalized , 'Type') value: aNode.
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitTypeStatement: aNode [

	| result values keys |
	keys := #( start_pos declarators type ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitUnaryExpression: aNode [

	| result values keys |
	keys := #( expression operator ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitUnsignedIntConstant: aNode [

	| result values keys |
	keys := #( start_pos value ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitUnsignedRealConstant: aNode [

	| result values keys |
	keys := #( start_pos value ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitUpperBound: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitValue: aNode [

	^ aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitVariable: aNode [
   <generated>
	| result values keys |
				
	keys := #( start_pos name ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitVariableDeclarationStatement: aNode [

	| result values keys |
	keys := #( start_pos declarators type ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitVariableDeclarator: aNode [

	| result values keys |
	keys := #( variable dimension_declarators ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitVariableExpression: aNode [
    <generated>
	| result values keys |
				
	keys := #( variable ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

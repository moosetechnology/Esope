Class {
	#name : #SyntaxAbstractJsonVisitor,
	#superclass : #Object,
	#classInstVars : [
		'aNode'
	],
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> createVisitSelector: key [

	^ ('visit' , ((('_' split: key) collect: [ :each | each capitalized ])
		   joinUsing: '') , ':') asSymbol
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> generateAbstractMethod: aNode selector: selector [

	aNode isArray ifTrue: [
		^ selector , ' aNode
		<generated>
			
			^ self visitJsonArray: aNode' ].

	aNode isDictionary ifTrue: [
		| keys |
		keys := aNode keys.
		(keys includes: 'tag')
			ifTrue: [
				^ selector , ' aNode
   <generated>
	| result values keys |
	1 halt.
				
	"keys := #( ' , (keys joinUsing: ' ') , ' ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result"
		
	^ self visitJsonTaggedElement: aNode' ]
			
			ifFalse: [
				^ selector , ' aNode
    <generated>
	| result values keys |
	1 halt.
				
	keys := #( ' , keys joinUsing: ' ' , ' ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result' ] ].

	"not array, not dictionary"
	^ selector , ' aNode
	<generated>
	
	1 halt.'
]

{ #category : #'visiting reflectivity' }
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitArithmeticExpression: aNode [
	"generated"

	^ self visitJsonMap: aNode keys: #( expression )
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitCharacterExpression: aNode [

	<generated>
	| result values keys |
	
	keys := #( expression ).
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitConstant: aNode [
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitDeclarators: aNode [
		"generated"
			
			^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitDimensionDeclarators: aNode [
		"generated"
			
			^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEndPos: aEndPos [
	
	^ (aEndPos at: 'line') asInteger @ (aEndPos at: 'column') asInteger
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitExpression: aNode [
				"generated"
		
		^ self visitJsonTaggedElement: aNode
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitIntegerType: aNode [
    "generated"

    self visitJsonMap: aNode keys: #(name)
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLeft: aNode [

	^ (self visitJsonArray: aNode) first
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLiteral: aNode [
				"generated"
		
		^ self visitJsonTaggedElement: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLiteralExpression: aNode [
	"generated"

	^ self visitJsonMap: aNode keys: #( literal )
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLogicalConstant: aNode [

	^ (self visitJsonMap: aNode keys: #( value )) first
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLogicalExpression: aNode [

	^ (self visitJsonMap: aNode keys: #( expression )) first
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLogicalFactor: aNode [
	"TODO should visit negated as well"

	^ (self visitJsonMap: aNode keys: #( expression )) first
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLogicalPrimary: aNode [

	^ (self visitJsonMap: aNode keys: #( expression )) first
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitMain: aMain [
	"generated"

	^ self
		  visitJsonMap: aMain
		  keys: #( start_pos statement_list end_pos name )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitName: aName [

	^ aName at: 'name'
    
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitProgramUnits: aNode [
		"generated"
			
			^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitRight: aNode [

	^ (self visitJsonArray: aNode) first
]

{ #category : #'as yet unclassified' }
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
	"generated"

	^ aSymbolicName at: 'name'
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitType: aNode [
    "generated"

    ^ self visitJsonTaggedElement: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitTypeReference: aNode [
    "generated"

	^ self visitKey: ((aNode at: 'name') asLowercase capitalized , 'Type') value: aNode.
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitUnsignedIntConstant: aNode [
				"generated"
		
		^ self visitJsonMap: aNode keys: #('value') 
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitUnsignedRealConstant: aNode [

	| result values keys |
	keys := #( start_pos value ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitValue: aNode [
	"generated"

	^ aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitVariable: aNode [
	"comment"

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitVariableDeclarationStatement: aNode [
    "generated"

    ^ self visitJsonMap: aNode keys: #(start_pos declarators type)


]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitVariableDeclarator: aNode [
	"generated"

	^ self visitJsonMap: aNode keys: #( variable dimension_declarators )
]

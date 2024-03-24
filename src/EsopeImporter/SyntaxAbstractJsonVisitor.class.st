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
				
	keys := #( ' , ( (keys reject: [ :e | e = 'tag' ]) joinUsing: ' ') , ' ).
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
		
	^ self visitJsonTaggedElement: aNode'
]

{ #category : #'method generation' }
SyntaxAbstractJsonVisitor >> abstractMethodJsonElement:  selector [

^ selector , ' aNode
	<generated>
'
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

					^ data'
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> generateKeys: aNode [
	
	^ aNode keys reject: [ :e | e = 'tag' ]
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitArgument: aNode [

	^ aNode
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitArithmeticIfStatement: aNode [

	| result values keys |
	keys := #( start_pos s1 s3 s2 expression ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitArrayDeclarators: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitBlockData: aNode [
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitClist: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitComments: aComments [

	"ignore for the moment"
	
	^ #()
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitCommonParameters: aNode [

	<generated>
	| result values keys |
	
	keys := #( name nlist ).
	result := OrderedCollection new.
	aNode do: [ :parameter |
		| dict |
		values := self visitJsonMap: parameter keys: keys.
		dict := Dictionary new.
		keys with: values do: [ :key :value | dict at: key put: value ].
		result add: dict ].

	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitCommonStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos common_parameters ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitControlInfoList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitDataParameters: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitDataStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos data_parameters ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitDataStatementConstant: aNode [

	| result values keys |
	keys := #( occurence constant ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDeclarators: aNode [

	<generated>
	^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitDescriptor: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDimensionDeclarators: aNode [
		<generated>
			
			^ self visitJsonArray: aNode
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitDimensionStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos array_declarators ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitDoStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos statements_list loop_control statement_number ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitElseBlock: aNode [
    <generated>
	| result values keys |
				
	keys := self generateKeys: aNode.
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitElseLabel: aNode [
	
	^ aNode 
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitEntryStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( name start_pos parameters ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitEquivalenceParameters: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitEquivalenceStatement: aNode [

	| result values keys |
	keys := #( start_pos equivalence_parameters ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitExpression: aNode [

	^ self visitJsonElement: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitExternalStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( proc_list start_pos ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitFormat: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitFormatSpecification: aNode [
    <generated>
	| result values keys |
				
	keys := #( slash repeat_factor descriptor ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitFormatStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( label specification ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitFunList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
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

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitGotoStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( var start_pos labels type tag ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitImplicitStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos parameters ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitIncrement: aNode [
	<generated>

]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitInit: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitInquireStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos parameters ).
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

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitIntrinsicStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos fun_list ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitIoList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLabels: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLeft: aNode [

	^ (self visitJsonArray: aNode) first
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitLenSpecification: aNode [
    <generated>
	| result values keys |

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

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitLogicalIfStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( statement start_pos expression ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
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
SyntaxAbstractJsonVisitor >> visitLoopControl: aNode [
    <generated>
	| result values keys |
				
	keys := #( variable_name init increment ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
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
	
	"particular case of common parameter"
	(aName isDictionary and: aName size = 0) ifTrue: [ ^ '' ].

	^ self visitJsonTaggedElement: aName
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitNlist: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitNonzeroUnsignedIntConstant: aNode [

	| result values keys |
	keys := #( start_pos value ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitOccurence: aNode [

	aNode isEmpty
		ifTrue: [ ^ nil ]
		ifFalse: [ ^ self visitJsonTaggedElement: aNode ]
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitOpenParameters: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitOpenStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos open_parameters ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitOperator: aNode [

	^ aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameter: aParameter [

	aParameter = '*' ifTrue: [ ^ aParameter  ].
	
	^ self visitJsonTaggedElement: aParameter  
	
	
    
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitParameterStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos parameters ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameters: aParameters [
	
	^ aParameters isEmpty 
		ifTrue: [ #()]
		ifFalse: [ aParameters collect: [ :each | self visitParameter: each ] ]
    
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitPauseStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitPrintStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( format start_pos io_list label ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitProcList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
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

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitReadStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( format start_pos io_list control_info_list ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitRealType: aNode [

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitRepeatFactor: aNode [
	<generated>
	
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitReturnSpecifier: aNode [

	^ aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitReturnStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitReturnType: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitRewindStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos parameters ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitRhs: aNode [

	^ self visitJsonElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitRight: aNode [
	
	^ (self visitJsonArray: aNode) first
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitS1: aNode [
	<generated>
	
	^ aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitS2: aNode [

	^ aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitS3: aNode [

	^ aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitSign: aNode [

	^ aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitSlash: aNode [
	<generated>

]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitSpecification: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStartPos: aStartPos [
	"generated"

	^ (aStartPos at: 'line') asInteger
	  @ (aStartPos at: 'column') asInteger
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitStatement: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStatementList: aStatementList [
	"generated"

	^ aStatementList collect: [ :each | self visitJsonMap: each ]
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitStatementNumber: aNode [
	<generated>

]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitStatementsList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitStopStatement: aNode [
    <generated>
	| result values keys |
				
	keys := (aNode keys) reject: [ :e | e = 'tag' ].
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitSubroutine: aSubroutine [
	"generated"

	^ self
		  visitJsonMap: aSubroutine
		  keys: #( start_pos parameters end_pos statement_list
		     name )
]

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitSubstring: aNode [

	| result values keys |
	keys := #( lower_bound variable upper_bound ).
	values := self visitJsonMap: aNode keys: keys.

	result := Dictionary new.
	keys with: values do: [ :key :value | result at: key put: value ].
	^ result
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitSymbolicName: aSymbolicName [
	
	^ aSymbolicName at: 'name'
]

{ #category : #'visiting - reflectivity' }
SyntaxAbstractJsonVisitor >> visitTag: aNode [
	<generated>

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

{ #category : #'as yet unclassified' }
SyntaxAbstractJsonVisitor >> visitVar: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
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

{ #category : #'visiting - expressions' }
SyntaxAbstractJsonVisitor >> visitVariableName: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting - statements' }
SyntaxAbstractJsonVisitor >> visitWriteStatement: aNode [
    <generated>
	| result values keys |
				
	keys := #( start_pos control_info_list io_list ).
	values := self visitJsonMap: aNode keys: keys.
				
	result := Dictionary new.
	keys
		with: values
		do: [ :key :value | result at: key put: value ].
	^ result
]

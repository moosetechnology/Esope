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

	self visitJsonMap: aNode keys: #( ' ,
	( (keys reject: [ :e | e = 'tag' ]) joinUsing: ' ' ) ,
	' )
'.
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

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitArgument: aNode [

	^ aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArgumentWithReturnSpecifier: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos return_specifier argument ).

]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArguments: aNode [
		<generated>
			
			^ self visitJsonArray: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArithmeticExpression: aNode [
	"generated"

	^ self visitJsonNode: aNode key: #expression
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitArithmeticIfStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos s1 s3 s2 expression )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitArrayDeclarators: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitArrayElementName: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( name qualifiers_list )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitAssignmentStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos right left )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitAsterisk: aNode [

	^ aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitBinaryExpression: aNode [

	^ self visitJsonMap: aNode keys: #( rhs lhs operator )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitBlockData: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos parameters end_pos statement_list name )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitBlockIfStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos then_statements else_block expression )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitCallStatement: aNode [
   <generated>

	^ self visitJsonMap: aNode keys: #( start_pos name arguments )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitCharacterConstant: aNode [
   <generated>

	^ self visitJsonMap: aNode keys: #( start_pos value )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitCharacterExpression: aNode [

	<generated>

	^ self visitJsonMap: aNode keys: #( expression )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitCharacterType: aNode [

	^ self visitJsonMap: aNode keys: #( len_specification )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitClist: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitComments: aComments [

	"ignore for the moment"
	
	^ #()
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitCommonParameters: aNode [

	<generated>
	| result |

	result := OrderedCollection new.
	aNode do: [ :parameter |
		result add: (self visitJsonMap: parameter keys: #( name nlist )) ].

	^ result
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitCommonStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos common_parameters )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitConstant: aNode [
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitConstantSigned: aNode [
   <generated>

	^ self visitJsonMap: aNode keys: #( sign constant )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitContinueStatement: aNode [
   <generated>

	^ self visitJsonMap: aNode keys: #( start_pos )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitControlInfoList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataImplyDoList: aNode [
    <generated>

	self visitJsonMap: aNode keys: #( m3 dlist m1 m2 )

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataParameters: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos data_parameters )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataStatementConstant: aNode [

	^ self visitJsonMap: aNode keys: #( occurence constant )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDeclarators: aNode [

	<generated>
	^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDescriptor: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDimensionDeclarators: aNode [
		<generated>
			
			^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDimensionStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos array_declarators )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDlist: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDoStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos statements_list loop_control statement_number )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitElseBlock: aNode [

	^ self visitJsonMap: aNode keys: #( else_statements end_if )
]

{ #category : #visiting }
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

	^ self visitJsonMap: aNode keys: #( label )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitEndPos: aEndPos [
	
	^ (aEndPos at: 'line') asInteger @ (aEndPos at: 'column') asInteger
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitEntryStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( name start_pos parameters )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitEquivalenceParameters: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitEquivalenceStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos equivalence_parameters )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitExpression: aNode [

	^ self visitJsonElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitExternalStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( proc_list start_pos )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitFormat: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitFormatSpecification: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( slash repeat_factor descriptor )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitFormatStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( label specification )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitFunList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitFunction: aNode [

	^ self visitJsonMap: aNode keys: #( name parameters return_type start_pos end_pos statement_list )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitFunctionReference: aNode [
   <generated>

	^ self visitJsonMap: aNode keys: #( name )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitGotoStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( var start_pos labels type tag )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos parameters )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitIncrement: aNode [
	<generated>

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitInit: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitInquireStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys:  #( start_pos parameters )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitIntegerType: aNode [

   self subclassResponsibility
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitIntrinsicStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos fun_list )
]

{ #category : #visiting }
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

	^ (jsonDictionary includesKey: 'tag')
		  ifTrue: [ self visitJsonTaggedElement: jsonDictionary ]
		  ifFalse: [
			  jsonDictionary associations collect: [ :assoc |
				  self visitKey: assoc key value: assoc value ] ]
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonMap: jsonDictionary keys: aCollection [
	"visit only the keys listed in aCollection in the jsonDictionary"

	| result |
	result := Dictionary new.
	aCollection
		do: [ :key | result at: key put: (self visitJsonNode: jsonDictionary key: key) ].
	^result
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

	| selector |
	
	selector := self createVisitSelector: key.

	^ self perform: selector with: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLabel: aNode [
	<generated>

	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLabels: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLeft: aNode [

	^ (self visitJsonArray: aNode) first
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLenSpecification: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( asterisk )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLhs: aNode [

	^ self visitJsonElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLiteral: aNode [
				"generated"
		
		^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLiteralExpression: aNode [
	"generated"

	^ self visitJsonMap: aNode keys: #( literal )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLogicalConstant: aNode [

	^self visitJsonNode: aNode key: #value
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLogicalExpression: aNode [

	^self visitJsonNode: aNode key: #expression
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLogicalFactor: aNode [
	"TODO should visit negated as well"

	^self visitJsonNode: aNode key: #expression
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLogicalIfStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( statement start_pos expression )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLogicalPrimary: aNode [

	^self visitJsonNode: aNode key: #expression
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLogicalType: aNode [

	self subclassResponsibility
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLoopControl: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( variable_name init increment )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLowerBound: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitM1: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitM2: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitM3: aNode [
    <generated>

	self visitJsonMap: aNode keys: #(  )

]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitMain: aNode [

	^ self visitJsonMap: aNode keys: #( name start_pos end_pos statement_list )
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitName: aName [

	aName class = ByteString ifTrue: [ ^ aName ].
	
	"particular case of common parameter"
	(aName isDictionary and: aName size = 0) ifTrue: [ ^ '' ].

	^ self visitJsonTaggedElement: aName
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitNlist: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitNonrepeatableEditDescriptor: aNode [
    <generated>

	self visitJsonMap: aNode keys: #( descriptor )

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitNonzeroUnsignedIntConstant: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos value )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitOccurence: aNode [

	aNode isEmpty
		ifTrue: [ ^ nil ]
		ifFalse: [ ^ self visitJsonTaggedElement: aNode ]
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitOpenParameters: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitOpenStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos open_parameters )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitOperator: aNode [

	^ aNode
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitParameter: aParameter [
	"returns a Dictionnary or '*'
	 not very coherent :-("

	(aParameter includesKey: #asterisk) ifTrue: [ ^aParameter at: #asterisk  ].
	
	^ self visitJsonMap: aParameter keys: #(start_pos name)
	
	
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameterStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos parameters )
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitParameters: parameterCollection [
	
	^(parameterCollection ifEmpty: [ #() ])
		collect: [ :each | self visitParameter: each ]
    
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitPauseStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitPrintStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( format start_pos io_list label )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitProcList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitProgramFile: aProgramFile [
	"a program file containing comments, program units, tag (fortran_file) and file name. everything else than program units are ingonred for the moment"

	^ self visitJsonNode: aProgramFile key: #program_units
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitProgramUnits: aNode [

	^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitQualifiersList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitReadStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( format start_pos io_list control_info_list )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitRealType: aNode [

	self subclassResponsibility
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitRepeatFactor: aNode [
	<generated>
	
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitRepeatableEditDescriptor: aNode [
    <generated>

	self visitJsonMap: aNode keys: #( repeated_descriptors )

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitRepeatedDescriptors: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitReturnSpecifier: aNode [

	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitReturnStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitReturnType: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitRewindStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos parameters )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitRhs: aNode [

	^ self visitJsonElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitRight: aNode [
	
	^ (self visitJsonArray: aNode) first
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitS1: aNode [
	<generated>
	
	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitS2: aNode [

	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitS3: aNode [

	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitSign: aNode [

	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitSlash: aNode [
	<generated>

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitSpecification: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitStartPos: aStartPos [
	"generated"

	^ (aStartPos at: 'line') asInteger
	  @ (aStartPos at: 'column') asInteger
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStatement: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStatementList: aStatementList [
	"generated"

	^ aStatementList collect: [ :each | self visitJsonMap: each ]
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStatementNumber: aNode [
	<generated>

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitStatementsList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStopStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos )
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitSubroutine: aSubroutine [

	^ self
		  visitJsonMap: aSubroutine
		  keys: #( name parameters start_pos end_pos statement_list )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitSubstring: aNode [

	^ self visitJsonMap: aNode keys: #( lower_bound variable upper_bound )
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitSymbolicName: aSymbolicName [
	
	^ aSymbolicName at: 'name'
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitTag: aNode [
	<generated>

	"if you are here, you forgot to remove tag from the list of keys to visit"
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitThenStatements: aNode [
		<generated>
			
			^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitType: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitTypeReference: aNode [
    "generated"

	^ self visitKey: ((aNode at: 'name') asLowercase capitalized , 'Type') value: aNode.
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitTypeStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos declarators type )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitUnaryExpression: aNode [

	^ self visitJsonMap: aNode keys: #( expression operator )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitUnsignedIntConstant: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos value )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitUnsignedRealConstant: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos value )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitUpperBound: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitValue: aNode [

	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitVar: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitVariable: aNode [
   <generated>

	^ self visitJsonMap: aNode keys:  #( start_pos name )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitVariableDeclarationStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos declarators type )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitVariableDeclarator: aNode [

	^ self visitJsonMap: aNode keys: #( variable dimension_declarators )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitVariableExpression: aNode [
    <generated>

	^ self visitJsonMap: aNode keys:  #( variable )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitVariableName: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitWriteStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos control_info_list io_list )
]

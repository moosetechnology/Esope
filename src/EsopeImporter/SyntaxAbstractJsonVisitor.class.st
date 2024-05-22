"
An abstract visitor for the JSON output of the Syntax parser.
It declares all the visiting methods required to fully visit the AST

"
Class {
	#name : #SyntaxAbstractJsonVisitor,
	#superclass : #Object,
	#instVars : [
		'commentList'
	],
	#classInstVars : [
		'aNode'
	],
	#category : #'EsopeImporter-Visitor'
}

{ #category : #running }
SyntaxAbstractJsonVisitor >> onFile: aProgramFile [
	"a program file containing comments, program units, tag (fortran_file) and file name"

	^ self visitJsonElement: aProgramFile
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitAlternateReturnSpecifier: aNode [

	^self visitJsonMap: aNode keys: #(start_pos return_specifier label)
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArgument: aNode [

	^self visitJsonElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArgumentWithReturnSpecifier: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos return_specifier argument ).

]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArguments: aNode [
	<generated>

	^self visitJsonArray: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArithmeticConstExpr: aNode [

	^self visitJsonNode: aNode key: #expression
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArithmeticExpression: aNode [
	"generated"

	^ self visitJsonNode: aNode key: #expression
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitArithmeticIfStatement: aNode [
	"why is the expression an array ?"

	| return |
	return := self visitLabeledStatement: aNode keys: #( start_pos labels ).
	return at: #expression put: (self visitExpression: (aNode at: #expression) first).
	^return
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitArrayDeclarators: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitArrayElementName: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( name qualifiers_list )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitAssignmentStatement: aNode [

	^self visitLabeledStatement: aNode keys: #(start_pos left right)
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitAsterisk: aNode [

	^ aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitBinaryExpression: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos right left operator )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitBlockData: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos prog_unit_parameters end_pos statement_list name )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitBlockIfStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos condition then_statements else_block )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitCallStatement: aNode [

	^ self visitLabeledStatement: aNode keys: #( start_pos name arguments )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitCharacterConstExpr: aNode [

	^self visitJsonNode: aNode key: #expression
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitCharacterConstant: aNode [
   <generated>

	^ self visitJsonMap: aNode keys: #( start_pos value )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitCharacterExpression: aNode [

	^ self visitExpression: (aNode at: #expression)
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitCharacterType: aNode [

	self subclassResponsibility
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitComments: theComments [
	"creating an ordered collection of the coments (which are in a Dictionary) where theCachedRepository comments are ordered by their line number (which is itself converted from String to Integer)

	Would have liked to use Dictionnary>>associations instead of #new:streamContents:, but it
	creates an Array, and we need a collection where we will remove elements in the future"

	commentList := OrderedCollection
		new: theComments size
		streamContents: [ :commentCollection |
			 theComments associationsDo: [ :assoc |
				commentCollection nextPut: (assoc key asInteger -> assoc value) ] ].

	commentList sort: [ :a :b | a key < b key ]

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitCommonBlockName: aNode [ 

	^ self visitJsonTaggedElement: aNode 
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitCommonBody: aCollection [

	^self visitJsonArray: aCollection
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitCommonElementName: aNode [ 

	^ self visitJsonTaggedElement: aNode 
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitCommonGroup: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos common_element_name common_block_name )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitCommonStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos common_body )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitComplexType: aNode [

	^'COMPLEX'
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitComputedGotoStatement: aNode [

	^ self visitLabeledStatement: aNode keys: #( var start_pos labels )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitCondition: aNode [ 

	^self visitJsonElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitConstant: aNode [
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitConstantDeclarations: parameterCollection [
	
	^parameterCollection collect: [ :each | self visitParameterAssign: each ]
    
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitConstantSigned: aNode [
   <generated>

	^ self visitJsonMap: aNode keys: #( start_pos sign constant )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitContinueStatement: aNode [

	^ self visitLabeledStatement: aNode keys: #( start_pos )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitControlInfoList: aCollection [
 
   ^aCollection collect: [ :each | self visitJsonTaggedElement: each ]
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitControlInfoOption: aNode [

	^self visitJsonMap: aNode keys: #(start_pos control_option_name control_option_value)
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitControlOptionName: aName [

	^ aName
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitControlOptionValue: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataGroup: aNode [

	<generated>
	^ self
		  visitJsonMap: aNode
		  keys:
		  #( start_pos data_group_constants_list data_group_variables_list )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataGroupConstant: aNode [
   <generated>
 
	^ self visitJsonMap: aNode keys: #( occurence constant )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataGroupConstantsList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataGroupVariable: aNode [

	<generated>
	^ self visitJsonElement: (aNode at: 'variable_name')
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataGroupVariablesList: aNode [

	^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataGroups: aNode [

	<generated>
	^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDataImplyDoList: aNode [
	"keys: dlist init limit increment
	 implied_do_list has the form: (array1, array2,..., indice, indice=init, limit, increment)
	 #dlist will contain: array1, array2,..., indice, indice
	 We remove the last two and add an extra key #variable_name so that it looks like a regular loop_control"

	| map dlist |
	map := self visitJsonMap: aNode keys: #( start_pos init limit increment ).

	dlist := self visitJsonArray: (aNode at: #dlist).
	map at: #dlist put: (dlist allButLast: 2).
	map at: #variable_name put: (dlist last).

	^map


]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDataStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos data_groups )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDeclarators: aNode [

	^self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDescriptor: aNode [

	^aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDimensionDeclarator: aNode [

	<generated>
	^ self
		  visitJsonMap: aNode
		  keys: #( start_pos lower_bound upper_bound )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDimensionDeclarators: aNode [

	<generated>
	^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDimensionStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos array_declarators )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitDlist: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitDoStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos statement_number loop_control statement_list )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitElse: aNode [

	^ self visitJsonMap: aNode keys: #(start_pos statement_list end_if)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitElseBlock: aNode [
	"can be a simple #else containing a statement list or a #else_if, containing another if_statement
	 this is decided by the #tag"

	^self visitJsonElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitElseIf: aNode [
	"same as a block_if, but within an else"

	^self visitBlockIfStatement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEndIf: aNode [

	^ self visitJsonMap: aNode keys: #( label start_pos )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitEndPos: aEndPos [
	
	^ (aEndPos at: 'line') asInteger @ (aEndPos at: 'column') asInteger
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEntryStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( name start_pos parameters )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEquivGroup: aCollection [

	^self visitJsonArray: aCollection 
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEquivalenceEntity: aCollection [

	^ self visitJsonTaggedElement: (aCollection at: 'equivalence_entity')
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEquivalenceGroup: aNode [

	^ self visitJsonMap: aNode keys: #(start_pos equivalence_group_elements)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEquivalenceGroupElements: aCollection [

	^ self visitJsonArray: aCollection
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEquivalenceGroups: aCollection [

	^ aCollection collect: [ :each | self visitJsonTaggedElement: each ]
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitEquivalenceStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos equivalence_groups )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitExpression: aNode [

	^ self visitJsonElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitExternalStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( proc_list start_pos )
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitFile: aFileName [

	^aFileName
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitFormat: aNode [
   <generated>
 
   ^ self visitJsonElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitFormatSpecifier: aNode [
    <generated>

	^ self visitJsonTaggedElement: (aNode at: 'descriptor' )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitFormatStatement: aNode [

	^self visitLabeledStatement: aNode keys: #( start_pos specification )
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitFortranFile: aProgramFile [
	"a program file containing comments, program units, tag (#fortran_file) and file name"

	^ self visitJsonMap: aProgramFile keys: #( comments file program_units )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitFunList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitFunction: aNode [

	^ self visitJsonMap: aNode keys: #( name prog_unit_parameters return_type start_pos end_pos statement_list )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitFunctionReference: aNode [

	^ self visitJsonMap: aNode keys: #( name start_pos )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitElements: anImplicitElements [
	
	^ self visitJsonArray: anImplicitElements
	
	
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitNoneStatement: aNode [

	^self visitLabeledStatement: aNode keys: #( start_pos )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitParameter: anImplicitParameter [
	
	^ self visitJsonMap: anImplicitParameter keys: #(type implicit_elements)
	
	
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitParameters: parameterCollection [
	
	^(parameterCollection ifEmpty: [ #() ])
		collect: [ :each | self visitImplicitParameter: each ]
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitRange: aNode [
	
	^self visitJsonMap: aNode keys: #(implicit_range_lower implicit_range_upper)
	
	
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitRangeLower: aString [
	
	^aString 
	
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitRangeUpper: aString [
	
	^aString 
	
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitImplicitStatement: aNode [

	^self visitLabeledStatement: aNode keys: #( start_pos implicit_parameters )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitIncrement: aNode [

	^self visitJsonElement: aNode

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitInit: aNode [
   <generated>
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitInquireStatement: aNode [

	^ self visitJsonMap: aNode keys:  #( start_pos control_info_list )
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

{ #category : #'visiting statement' }
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
	aNode isArray ifTrue: [ ^ self visitJsonArray: aNode ].
	^aNode
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonKey: key value: aNode [
	"not much to do with JSON, but named that way to highlight the relation with other
	 reflective visit methods"
	| selector |
	
	selector := String streamContents: [ :st |
		st << 'visit'.
		('_' split: key) do: [ :each |
			st << each capitalized ].
		st << ':'
	].

	^ self perform: selector asSymbol with: aNode
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonMap: jsonDictionary [
	"If dicionary contains key 'tag', performs a visit of the whole node for this tag,
	otherwise, perform a visit of each value for their key
	'anno' key always ignored"

	^(jsonDictionary includesKey: 'tag')
		ifTrue: [ self visitJsonTaggedElement: jsonDictionary ]
		ifFalse: [ | result |
			result := Dictionary new: jsonDictionary size.
			jsonDictionary associationsDo: [ :assoc |
				result at: assoc key put: (self visitJsonKey: assoc key value: assoc value) ].
			result ]
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonMap: jsonDictionary keys: aCollection [
	"visit only the keys listed in aCollection in the jsonDictionary
	 all keys or optional, if they are not found, they are not put in the result"

	| result |
	result := Dictionary new.
	aCollection
		do: [ :key |
			jsonDictionary
				at: key
				ifPresent: [ :jsonValue |
					result at: key put: (self visitJsonKey: key value: jsonValue)
				]
		].
	^result
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonNode: aJsonNode key: key [

	^ self visitJsonKey: key value: (aJsonNode at: key)
]

{ #category : #'visiting reflectivity' }
SyntaxAbstractJsonVisitor >> visitJsonTaggedElement: jsonDictionary [

	^ self visitJsonKey: (jsonDictionary at: 'tag') value: jsonDictionary
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLabel: aString [
	
	^aString
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLabelReference: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos label )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLabeledStatement: aNode keys: keyCollection [

	^self visitJsonMap: aNode keys: ({#label} , keyCollection)

]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLabels: aCollection [

   ^self visitJsonArray: aCollection
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLeft: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLenSpecification: aNode [
	"length of a type in a variable declaration (a number or * if len is unspecified)
	similar to #visitLiteral: should be unified"

	^(aNode includesKey: #asterisk)
		ifTrue: [ self visitAsterisk: aNode ]
		ifFalse: [ self visitJsonTaggedElement: aNode ]
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLenSpecifier: aNode [
	"dimension of a character array declaration: an expression or asterisk
	 looks like dimension_declarator but can be asterisk too"

	^(aNode includesKey: #asterisk)
		ifTrue: [ self visitAsterisk: aNode ]
		ifFalse: [ self visitJsonTaggedElement: aNode ]
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLimit: aNode [

	^self visitJsonElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLiteral: aNode [

	^(aNode includesKey: #asterisk)
		ifTrue: [ self visitAsterisk: aNode ]
		ifFalse: [ self visitJsonTaggedElement: aNode ]
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLiteralExpression: aNode [

	^ self visitJsonTaggedElement: (aNode at: 'expression')
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLogicalConstExpr: aNode [

	^self visitJsonNode: aNode key: #expression
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLogicalConstant: aNode [

	^self visitJsonMap: aNode keys: #(value start_pos)
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitLogicalExpression: aNode [

	^self visitJsonNode: aNode key: #expression
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLogicalFactor: aNode [

	^ self visitJsonMap: aNode keys: #(expression negated)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitLogicalIfStatement: aNode [
    <generated>

	^ self visitJsonMap: aNode keys: #( start_pos expression statement )
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

	^ self visitJsonMap: aNode keys: #( start_pos variable_name init limit increment )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitLowerBound: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitMain: aNode [

	^ self visitJsonMap: aNode keys: #( name start_pos end_pos statement_list )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitName: aName [

	aName class = ByteString ifTrue: [ ^ aName ].
	
	"particular case of common parameter"
	(aName isDictionary and: aName size = 0) ifTrue: [ ^ '' ].

	^ self visitJsonTaggedElement: aName
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitNegated: aNode [

	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitNonrepeatableEditDescriptor: aNode [

	^ aNode at: 'value'
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

	^ self visitJsonMap: aNode keys: #( start_pos control_info_list )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitOperator: aNode [

	^ aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitParameter: aParameter [
	"returns a Dictionnary or '*'
	 not very coherent :-("

	(aParameter includesKey: #asterisk) ifTrue: [ ^aParameter at: #asterisk  ].
	
	^ self visitJsonMap: aParameter keys: #(start_pos name)
	
	
    
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameterAssign: aNode [
	
	^self visitJsonMap: aNode keys: #(start_pos symbolic_name expression)
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitParameterStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos constant_declarations )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitPauseStatement: aNode [

	^self visitLabeledStatement: aNode keys: #( start_pos argument )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitPrintStatement: aNode [

	^ self visitLabeledStatement: aNode keys: #( start_pos format io_list )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitProcList: aNode [
   <generated>
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitProgUnitParameters: aCollection [ 

	^self visitJsonArray: aCollection
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitProgramUnits: aNode [

	^ self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitQualifiersList: aNode [
 
   ^ self visitJsonArray: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitReadStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos format control_info_list io_list )
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
    
	^ aNode at: 'value'

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

	^ self visitJsonMap: aNode keys: #( start_pos control_info_list )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitRight: aNode [
	
	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitScalarVariable: aNode [
   <generated>

	^ self visitJsonMap: aNode keys:  #( start_pos variable_name )
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

	^self visitJsonArray: aStatementList
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStatementNumber: aNode [

	^ self visitJsonTaggedElement: aNode
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitStopStatement: aNode [

	^ self visitLabeledStatement: aNode keys: #( start_pos argument )
]

{ #category : #'visiting prog-unit' }
SyntaxAbstractJsonVisitor >> visitSubroutine: aSubroutine [

	^ self
		  visitJsonMap: aSubroutine
		  keys: #( name prog_unit_parameters start_pos end_pos statement_list )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitSubstring: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos lower_bound variable_name upper_bound )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitSymbolicName: aNode [

	^ self visitJsonMap: aNode keys: #( name start_pos )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitThenStatements: aNode [
			
	^self visitJsonArray: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitType: aNode [
		
	^ self visitJsonTaggedElement: aNode
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitTypeReference: aNode [

	| return |
	return := Dictionary new: 2.
	return
		at: #name
		put: (self visitJsonKey: ((aNode at: 'name') asLowercase capitalized , 'Type') value: aNode).
	aNode
		at: #len_specification
		ifPresent: [ :len | return at: #len_specification put: (self visitLenSpecification: len) ].
	^return
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitTypeStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos declarators type )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitUnaryExpression: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos expression operator )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitUnconditionalGotoStatement: aNode [
	"contrary to what it seems, there is only one label possible"

	^self visitLabeledStatement: aNode keys: #( start_pos labels )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> visitUndefinedType: aNode [

	^'UNDEFINED'
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitUnitControlOption: aNode [

	^ self visitJsonMap: aNode keys: #(start_pos unit_option_value) 
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitUnitOptionValue: aNode [

	^ self visitJsonTaggedElement: aNode
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
	"why is this an array ?
	there should be only one var"

   ^ self visitJsonElement: aNode first
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitVariable: aNode [
   <generated>

	^ self visitJsonElement: (aNode at: 'variable_name')
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitVariableDeclarationStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos declarators type )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitVariableDeclarator: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos variable_name dimension_declarators expression )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitVariableExpression: aNode [
    <generated>

	^ self visitJsonMap: aNode keys:  #( variable_name )
]

{ #category : #'visiting expression' }
SyntaxAbstractJsonVisitor >> visitVariableName: aNode [
		
	^ self visitJsonMap: aNode keys: #( start_pos name )
]

{ #category : #'visiting statement' }
SyntaxAbstractJsonVisitor >> visitWriteStatement: aNode [

	^ self visitJsonMap: aNode keys: #( start_pos control_info_list io_list )
]

{ #category : #visiting }
SyntaxAbstractJsonVisitor >> vsitLabels: aCollection [
 
   ^aCollection collect: [ :label | self visitLabelReferrence: label ]
]

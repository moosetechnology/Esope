"
An abstrat visitor for the JSON output of [camfort/fortran-src](https://github.com/camfort/fortran-src)

Defines all the needed `#visitXYZ:` methods and go to the JSON tree
"
Class {
	#name : #FortranAbstractJsonVisitor,
	#superclass : #Object,
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'private - helpers' }
FortranAbstractJsonVisitor >> esopeCommand: anEsopeCommentString [
	"returns a collection of 2 words: {'command' . 'argument'}
	first word after Esope marker is the 'command', after comes the 'argument'"

	| wordBoundaries |
	wordBoundaries := self findWordBoundaries: anEsopeCommentString.

	^(wordBoundaries size > 2)
		ifTrue: [
			{ (anEsopeCommentString copyFrom: wordBoundaries first to: wordBoundaries second) .
			  (anEsopeCommentString copyFrom: wordBoundaries third to: wordBoundaries fourth) }
		]
		ifFalse: [ { anEsopeCommentString copyFrom: wordBoundaries first to: wordBoundaries second } ]
]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> esopeExtraSpan: commentSpan comment: commentText command: esopeCommand [
	"Compute the span of just the Esope command (without 'C@_  ')
	 - same start line
	 - start column must ignore 'C@_  '
	 - same end point"

	| commandStart |
	commandStart := (commentText indexOfSubCollection: (esopeCommand first)).

	^{ (commentSpan first x @ (commentSpan first y + commandStart))
		. commentSpan second }.

]

{ #category : #'private - helpers' }
FortranAbstractJsonVisitor >> findWordBoundaries: anEsopeCommentString [

	"search for word boundaries starting from 6th position"

	| wordBoundaries i inWord |
	self flag: #FIXME. "This not work for #include.
	The #include start from the first position. So its need to be update in order
	to handle this issue.
	"

	wordBoundaries := OrderedCollection new: 6.
	i := 1.
	inWord := false.

	(anEsopeCommentString allButFirst: 5) do: [ :char | "for now, treat . as a letter: lb.pstr"
		(char isLetter or: [ char isDigit or: [ char = $. ]])
			ifTrue: [ 
				inWord ifFalse: [ "begining of a word"
					wordBoundaries add: i + 5.
					inWord := true ] ]
			ifFalse: [ 
				inWord ifTrue: [ "end of a word"
					wordBoundaries add: i + 4.
					inWord := false ] ].
		i := i + 1 ].
	wordBoundaries add: i + 4.

	self flag: #FIXME. "Do not forget to grab the '#' to distinguish between #include and include statement.
	2 dont take the #
	3 take the #
	"
	(anEsopeCommentString beginsWith: '@_#include') ifTrue: [ 
		wordBoundaries at: 1 put: wordBoundaries first - 2 ].

	^ wordBoundaries
]

{ #category : #testing }
FortranAbstractJsonVisitor >> isEsopeComment: aCommentString [
	^aCommentString asLowercase beginsWith: '@_' 
]

{ #category : #testing }
FortranAbstractJsonVisitor >> isEsopeTransformation: aString [

	aString isString ifFalse: [ ^ false ].
	^ #( #d__ #s__ ) includes: aString
]

{ #category : #testing }
FortranAbstractJsonVisitor >> isTaggedStatement: aStatementNode [

	"If aStatementNode has already a statement, no need to do (aStatementNode at: 'statement')"

	^ (aStatementNode at: 'statement' ifAbsent: [ aStatementNode ]) 
		  includesKey: 'tag'
]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> processEsopeComment: anEsopeCommentNode [
	"For Esope comments the treatment is similar for most of them
	 We also return 2 spans:
	- the usual one which is the span of the entire comment
	- the span of just the Esope statement (without 'C@_  ')"

	| esopeCommand commentSpan |
	esopeCommand := self esopeCommand: (anEsopeCommentNode at: 'comment').
	commentSpan := self visitSpan: (anEsopeCommentNode at: 'span').

	^{ commentSpan .
		self
			esopeExtraSpan: commentSpan
			comment: (anEsopeCommentNode at: 'comment')
			command: esopeCommand
	}
	, esopeCommand
]

{ #category : #helpers }
FortranAbstractJsonVisitor >> processEsopeIfComment: anEsopeIfCommentNode [ 
	self shouldBeImplemented.
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitAddition: anAdditionOperatorNode [
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitAnd: anAndOperatorNode [
	^ '.and.'
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitArgs: anEntryArgsList [
	anEntryArgsList ifNil: [ ^#() ].
	^(anEntryArgsList at: 'list') collect: [ :each | self visitJsonElement: each]
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitArgument: anArgumentNode [
	"used for argument in subprogram calls and parameter in subprogram definition
	 So can take different forms :-("

	^(anArgumentNode includesKey: 'tag')
		ifTrue: [ self visitJsonTaggedElement: anArgumentNode ]
		ifFalse: [ self visitJsonMap: anArgumentNode keys: #(span expr) ]
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitArguments: anArgumentList [
	anArgumentList ifNil: [ ^#() ].
	^(anArgumentList at: 'list') collect: [ :each | self visitArgument: each]
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitArrayDeclarationDim: arrayDeclarationDim [

	^self visitJsonMap: arrayDeclarationDim keys: #(span lower upper)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitArrayDeclarationDims: arrayDeclarationDimsList [

	^arrayDeclarationDimsList collect: [ :each |
		self visitArrayDeclarationDim: each ]
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitArrayDimensionBoundary: aLimit [

	^ aLimit ifNotNil: [ self visitJsonMap: aLimit ]
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitAssign_expression: anAssignExpressionNode [
	^self visitJsonMap: anAssignExpressionNode keys: #(span target expression)

]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitAssign_expressionStatement: anAssignExpressionNode [
	"assign_expression and assign_expressionStatement are the same"

	^self visitAssign_expression: anAssignExpressionNode

]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitAttributes: aNode [

	^nil
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitBackspaceStatement: aBackspaceStatementNode [

	^self visitJsonMap: aBackspaceStatementNode keys: #( span specification )

]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitBase_type: aString [
	"to offer the possibility to handle each baseType differently, we create #visitXYZBaseType: methods"

	^ self visitKey: aString , 'BaseType' value: aString
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitBinary: aBinaryExpressionNode [
	^self visitJsonMap: aBinaryExpressionNode keys: #( span left op right)
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitBlockDataBlocks: aBlockDataBlockList [
	"a BlockData contains a list of 'statement' which are tagged 'common' "
	^aBlockDataBlockList collect: [ :each | self visitJsonElement: each ]
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitBlock_data: aBlockDataNode [
	^(self visitJsonMap: aBlockDataNode keys:  #(span name))
	 ,
	 { self visitBlockDataBlocks: (aBlockDataNode at: 'blocks') }
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitBlocks: aBlockList [
	^self visitBody: aBlockList
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitBody: aNode [
	aNode ifNil: [ ^#() ].

	^self visitJsonElement: aNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCall: aCallNode [

	^self visitCallStatement: aCallNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCallStatement: aCallStatementNode [

	^self visitJsonMap: aCallStatementNode keys: #(span function arguments)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCharacterBaseType: aString [
	^aString

]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitCloseStatement: aCloseStatementNode [

	^self visitJsonMap: aCloseStatementNode keys: #( span specification )

]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitComment: aCommentNode [
	"Separates comments that are genuine fortran comments and the one that contain Esope commands"
	| content |
	content := aCommentNode at: 'comment'.

	^(self isEsopeComment: content)
		ifTrue: [  self visitEsopeComment: aCommentNode ]
		ifFalse: [ self visitFortranComment: aCommentNode ]
	
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCommonGroup: aCommonGroupNode [
	^{
		self visitSpan: (aCommonGroupNode at: 'span') .
		self visitCommonGroupName: (aCommonGroupNode at: 'name') .
		self visitCommonGroupVars: (aCommonGroupNode at: 'vars' at: 'list')
	}
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCommonGroupName: aCommonGroupNameNode [
	^aCommonGroupNameNode
		ifNil: [ nil ]
		ifNotNil: [
			{
				self visitSpan: (aCommonGroupNameNode at: 'span') .
	 			aCommonGroupNameNode at: 'value' at: 'contents'
			}
		]
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCommonGroupVars: aCommonGroupVarList [
	^aCommonGroupVarList collect: [ :each | self visitDeclarator: each ]
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCommonStatement: aCommonStatementNode [
	^self visitJsonMap: aCommonStatementNode keys: #(span common_groups)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCommon_groups: aCommonGroupsNode [
	^(aCommonGroupsNode at: 'list') collect: [ :each | self visitCommonGroup: each ]
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitComplexBaseType: aString [
	^aString

]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitConcatenation: anConcatenationOperatorNode [
	^ '//'
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitCondition: aLogicalIfConditionNode [

	^ self visitIfCondition: aLogicalIfConditionNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitConditions: aConditionList [
	^aConditionList collect: [ :aCondition |
		{ self visitIfCondition: aCondition first .
	     self visitThenPart: aCondition second } ]
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitContinueStatement: aContinueStatementNode [
	^self visitSpan: (aContinueStatementNode at: 'span')
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDataGroup: aDataGroup [

	^{
		self visitJsonNode: aDataGroup key: #span .
		self visitDataGroupNames: (aDataGroup at: #names) .
		self visitDataGroupInitializers: (aDataGroup at: #initializers)
	}
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDataGroupInitializers: initializersCollection [
	^self visitJsonArray: (initializersCollection at: #list)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDataGroupNames: namesCollection [

	^self visitJsonArray: (namesCollection at: #list)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDataStatement: aDataStatement [

	^self visitJsonMap: aDataStatement keys: #(span data_groups)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitData_groups: dataGroupCollection [

	^{
		self visitJsonNode: dataGroupCollection key: #span .
		(dataGroupCollection at: #list)
			collect: [ :aDataGroup |
				self visitDataGroup: aDataGroup
			]
	}
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDeclarationStatement: aDeclarationStatementNode [
	"tagged element 'declaration'"

	^self visitJsonMap: aDeclarationStatementNode keys: #(span type attributes declarators)
	
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDeclarator: aDeclaratorNode [
	"visit method for the last two have special names
	 - 'type' contains a string which is not compatible with #visitType:
	 - 'variable' contains an object with a key 'variable' that would create recursive loop
	Note: 'type' is not the data type of the variable but something like 'scalar' or 'array'"

	^(self visitJsonMap: aDeclaratorNode keys: #(span initial length))
	 ,
	{ ((aDeclaratorNode at: 'type') = 'array') ifTrue: [ self visitJsonNode: aDeclaratorNode key: 'dims' ] ifFalse: [ nil ] .
	 self visitDeclaratorVariable: (aDeclaratorNode at: 'variable') }
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDeclaratorType: aString [
	"Note: this is not the data type of a declared variable but something like 'scalar'"
	^aString 
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDeclaratorVariable: aDeclaratorVariableNode [

	^{
		self visitSpan: (aDeclaratorVariableNode at: 'span') .
		self visitDeclaratorVariableContent: (aDeclaratorVariableNode at: 'value' at: 'contents')
	}
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDeclaratorVariableContent: aString [
	^aString
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDeclarators: aDeclaratorsList [
	"visit span and list of declarators"

	^{
		self visitSpan: (aDeclaratorsList at: 'span') .
		(aDeclaratorsList at: 'list') collect: [:decl | self visitDeclarator: decl ]
	}
	
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitDeref: aDerefNode [
	^self visitJsonMap: aDerefNode keys: #(span expression field)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDimensionStatement: aDimensionStatementNode [

	^self visitJsonMap: aDimensionStatementNode keys: #(span declarators)

]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDims: anArrayDeclarationDimsNode [ 

	^self visitArrayDeclarationDims: (anArrayDeclarationDimsNode at: #list)
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitDivision: aDivisionOperatorNode [
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDo: aDoNode [
	^self visitJsonMap: aDoNode keys: #(span label do_spec target body end_label)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitDo_spec: aDoSpecNode [

	^self visitJsonMap: aDoSpecNode keys: #(span initial limit increment)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitElements: anImplicitElementsNode [
	^(anImplicitElementsNode at: 'list')
		collect: [ :each | self visitImplicitStatementRange: each ]
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitEnd_label: aValueNode [
	^self visitJsonElement: aValueNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitEntryStatement: anEntryNode [
	^self visitJsonMap: anEntryNode keys: #(span name args return)
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitEq: anEqualtoOperatorNode [

	^ '.eq.'
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitEqualLabel: aLabelReference [
	^self visitLabelReference: aLabelReference
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitEquivalenceGroup: equivalenceGroupNode [

	^{
		self visitJsonNode: equivalenceGroupNode key: #span .
		(equivalenceGroupNode at: #list)
			collect: [ :var | self visitJsonElement: var ]
	}
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitEquivalenceStatement: anEquivalenceStatementNode [

	^self visitJsonMap: anEquivalenceStatementNode keys: #(span groups) 
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitEqv: aEqvtoOperatorNode [

	^ '.eqv.'
]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeComment: anEsopeCommentNode [
	"we separate each Esope command in a different visit methdo to give opportunity to
	 concrete visitors (subclasses) to treat them differently.
	 But here, they are pretty much all the same, so they come down to the same treatment"

	| key esopeCommand |
	esopeCommand := self esopeCommand: (anEsopeCommentNode at: 'comment').
	key := 'Esope' , esopeCommand first asLowercase capitalized
	       , 'Comment'.

	^ self visitKey: key value: anEsopeCommentNode
]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeEndComment: anEsopeCommentNode [
	"delegate to a method with a more explicit name
		subclasses should override #visitEsopeEndSegmentComment: not this method"

	^self visitEsopeEndsegmentComment: anEsopeCommentNode 
]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeEndsegmentComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitEsopeIfComment: anEsopeIfCommentNode [ 
	^self processEsopeIfComment: anEsopeIfCommentNode
]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeIncludeComment: anEsopeIncludeCommentNode [

	^self processEsopeComment: anEsopeIncludeCommentNode

]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopePointeurComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeSegactComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeSegadjComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeSegdesComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeSeginiComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeSegmentComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : #'visiting esope' }
FortranAbstractJsonVisitor >> visitEsopeSegsupComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitExitStatement: anExitNode [
	^self visitJsonMap: anExitNode keys: #(span var)
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitExponent: aRealLiteralExponentNode [

	^(aRealLiteralExponentNode at: #num) = '0'
		ifTrue: [ nil ]
		ifFalse: [
			(aRealLiteralExponentNode at: #letter)
			,
			(aRealLiteralExponentNode at: #num)
		]
	
	
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitExponentiation: aExponentiationOperatorNode [
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitExpr: anExprNode [
	"Typically a node contains a key 'expr' with value a dictionary containing a tag 'expr'
	 therefore a 1st #visitExpr: will end up calling a 2nd #visitExpr:
	 the 1st executes #ifTrue:, the 2nd executes #ifFalse:"
	^(anExprNode includesKey: 'tag')
		ifTrue: [ self visitJsonTaggedElement: anExprNode ]
		ifFalse: [ self visitJsonElement: (anExprNode at: 'contents') ]
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitExpression: aExpressionNode [
	^self visitJsonElement: aExpressionNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitExternalStatement: anExternalStatementNode [

	^ self visitJsonMap: anExternalStatementNode keys: #( span vars )
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitFalseLiteralValue: aString [
	"Camfort puts 'false' so we return the normal Fortran value instead"
	^'.false.'
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitField: aFieldNode [ 
	^self visitJsonElement: aFieldNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFormat: aFormatDescription [
	"formatDescription is a String"

	^aFormatDescription
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFormatArgument: aFormatArgumentNode [
	^self visitArgument: aFormatArgumentNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFormatStatement: aFormatStatement [

	^self visitJsonMap: aFormatStatement keys: #(span format)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFortranComment: aFortranCommentNode [
	"A real Fortran comment as opposed to a comment that contains an Esope command
	cannot call visitJsonMap: because contains a key 'comment' that would recursively loop on this method"

	^{ self visitSpan: (aFortranCommentNode at: 'span') .
	  aFortranCommentNode at: 'comment' }
	
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFrom: aString [
	"start of a range for an implicit statement: a string of one character"
	^aString
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitFunction: aFunctionNode [
	^(aFunctionNode includesKey: 'blocks')
	 ifTrue: [ self visitFunctionWithBlocks: aFunctionNode ]
	 ifFalse: [ self visitFunctionAsValue: aFunctionNode ]

]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitFunctionAsValue: aFunctionNode [

	^{self visitSpan: (aFunctionNode at: 'span') .
	 self visitFunctionCalledName: (aFunctionNode at: 'value' at: 'contents') }
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFunctionCalledName: aString [
	^aString
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitFunctionParameters: aParameterList [

	aParameterList ifNil: [ ^#() ].
	^self visitJsonArray: (aParameterList at: #list)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFunctionStatement: aFunctionStatementNode [
	"'name' is an object, not a string so, cannot call #visitName: on it"
	^{ self visitSpan: (aFunctionStatementNode at: 'span') .
 	 self visitJsonElement: (aFunctionStatementNode at: 'name') .
	 self visitFunctionParameters: (aFunctionStatementNode at: 'arguments') .
	 self visitFunctionStatementBody: (aFunctionStatementNode at: 'body') }
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFunctionStatementBody: aNode [
	"a specific method for function statement body which contains only 1 statement"
	^self visitJsonElement: aNode
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitFunctionWithBlocks: aFunctionNode [
	
	^{
		self visitJsonNode: aFunctionNode key: #span .

		self visitJsonNode: aFunctionNode key: #name .

		(aFunctionNode at: #type)
			ifNil: [ nil ]
			ifNotNil: [ :type | self visitKey: #type value: type ] .

		self visitFunctionParameters: (aFunctionNode at: 'arguments') .

		self visitBlocks: (aFunctionNode at: 'blocks')
	} 
	"need to deal with keys: result, subprograms"
	
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitFunction_call: aFunctionCallNode [

	^self visitJsonMap: aFunctionCallNode keys: #(span function arguments)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitGotoStatement: aGotoStatementNode [

	^self visitJsonMap: aGotoStatementNode keys: #(span target)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitGoto_computedStatement: aGotoComputedStatementNode [

	^self visitJsonMap: aGotoComputedStatementNode keys:  #(span labels target)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitGreaterLabel: aLabelReference [
	^self visitLabelReference: aLabelReference
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitGroups: anEquivalenceGroupCollection [

	^{
		self visitJsonNode: anEquivalenceGroupCollection key: #span .
		(anEquivalenceGroupCollection at: #list)
			collect: [ :equivalenceGroup |
				self visitEquivalenceGroup: equivalenceGroup
			]
	}
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitGt: aGreaterthanOperatorNode [

	^ '.gt.'
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitGte: anOperatorNode [

	^ '.ge.'
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIOParameter: anIOParameterNode [
	^self visitJsonMap: anIOParameterNode keys: #(span name expr)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIOParameters: anIOParametersCollection [
	^(anIOParametersCollection at: 'list')
			collect: [ :each | self visitIOParameter: each ]

]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIf: anIfNode [
	"The THEN-Part is in 'conditions', the ELSE-PART in 'blocks', if no ELSE-PART, then 'blocks' is nil'
	 ignoring key: end_label"

	^self visitJsonMap: anIfNode keys: #(span label conditions blocks)

]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIfCondition: anIfConditionNode [
	^self visitJsonElement: anIfConditionNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIf_arithmeticStatement: anIfArithmeticStatement [ 
	^(self visitJsonMap: anIfArithmeticStatement keys: #(span expression))
	,
	{
		self visitKey: #lessLabel    value: (anIfArithmeticStatement at: #less) .
		self visitKey: #equalLabel   value: (anIfArithmeticStatement at: #equal) .
		self visitKey: #greaterLabel value: (anIfArithmeticStatement at: #greater)
	}
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIf_logicalStatement: anIfNode [
	"the statement part is special, it has no 'label', so we cannot use the
	default visit_statement:"

	^ (self visitJsonMap: anIfNode keys: #( span condition ))
		,
		{ (self visitJsonTaggedStatement: (anIfNode at: #statement)) }
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitImplicitStatement: anImplicitStatementNode [

	^self visitJsonMap: anImplicitStatementNode keys:  #(span items)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitImplicitStatementRange: anImplicitStatementRangeNode [
	^self visitJsonMap: anImplicitStatementRangeNode keys: #(span from to)
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitImplied_do:  anImpliedDoListsNode [ 
	^{
		self visitSpan: (anImpliedDoListsNode at: 'span') .
		self visitDo_spec: (anImpliedDoListsNode at: 'do_spec')
	}
	,
	((anImpliedDoListsNode at: 'expressions' at: 'list')
		collect: [ :expr | self visitJsonMap: expr ])
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIncrement: anIncrementNode [
	^self visitJsonElement: anIncrementNode
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitIndex: anArrayIndexNode [

	^self visitJsonElement: anArrayIndexNode

]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitIndices: anArrayIndicesNode [
	^self visitJsonArray: (anArrayIndicesNode at: 'list')

]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitInitial: anInitialNode [
	"DO statement initialization, a tagged JSon entity that will redirect to #visitAssign_expression:"
	^self visitJsonElement: anInitialNode
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitInquireStatement: anInquireStatement [ 

	^{
		self visitSpan: (anInquireStatement at: 'span') .
		self visitIOParameters: (anInquireStatement at: 'specification')
	}
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitInteger: anIntegerNode [
	"to be more explicit, Integer nodes are 'transformed' in IntegerLiteralValue nodes"
	^self visitIntegerLiteralValue: (anIntegerNode at: 'contents')
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIntegerBaseType: aString [
	^aString

]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitIntegerLiteralValue: anIntegerLiteralValueNode [
	^anIntegerLiteralValueNode first
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitIntrinsicStatement: anIntrinsicStatement [

	^self visitJsonMap: anIntrinsicStatement keys: #(span vars)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitItems: anImplicitItemsNode [
	"'items' in implicit statement"

	^anImplicitItemsNode
		ifNotNil: [
			{
				self visitJsonNode: anImplicitItemsNode key: #span
				.
				anImplicitItemsNode
					ifNil: [ nil ]
					ifNotNil: [
						(anImplicitItemsNode at: 'list') collect: [ :item |
							self visitJsonMap: item keys: #(span type elements) ]
					]
			}
		]
]

{ #category : #'visiting reflectivity' }
FortranAbstractJsonVisitor >> visitJsonArray: aCollection [
	^aCollection collect: [ :each | self visitJsonElement: each ]
]

{ #category : #'visiting reflectivity' }
FortranAbstractJsonVisitor >> visitJsonElement: aNode [
	aNode ifNil: [ ^nil ].
	aNode isDictionary  ifTrue: [ ^self visitJsonMap: aNode ].
	aNode isArray  ifTrue: [ ^self visitJsonArray: aNode ].
]

{ #category : #'visiting reflectivity' }
FortranAbstractJsonVisitor >> visitJsonMap: jsonDictionary [
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
FortranAbstractJsonVisitor >> visitJsonMap: jsonDictionary keys: aCollection [
	"visit only the keys listed in aCollection in the jsonDictionary"

	^ aCollection collect: [ :key |
		  self visitJsonNode: jsonDictionary key: key
	]
]

{ #category : #'visiting reflectivity' }
FortranAbstractJsonVisitor >> visitJsonNode: aJsonNode key: key [
	^self visitKey: key value: (aJsonNode at: key)
]

{ #category : #'visiting reflectivity' }
FortranAbstractJsonVisitor >> visitJsonTaggedElement: jsonDictionary [
	"similar to #visitJsonNode: , but removes first the 'tag' key from the JsonDisctionary
	 so that it is not visited again (not sure this is needed ...?)"

	| key |
	key := jsonDictionary removeKey: 'tag'.
	^ self visitKey: key value: jsonDictionary
]

{ #category : #'visiting reflectivity' }
FortranAbstractJsonVisitor >> visitJsonTaggedStatement: aStatementNode [
	"a statementNode containing a tagged element
	 Similar to #visitJsonTaggedElement: on the tagged element, but adds 'Statement' to the selector"

	| key value |
	value := aStatementNode at: 'statement' ifAbsent: [ aStatementNode ].
	key := value removeKey: 'tag'.
	^ self visitKey: key , 'Statement' value: value
]

{ #category : #'visiting reflectivity' }
FortranAbstractJsonVisitor >> visitKey: key value: aNode [
	| selector |
	selector := ('visit' , key capitalized , ':') asSymbol.
	^self perform: selector with: aNode

]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitKind: aKindNode [

	^self visitJsonElement: aKindNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitLabel: aLabelNode [
	^self visitJsonElement: aLabelNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitLabelReference: aLabelReference [
	^self visitJsonElement: aLabelReference 
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitLabels: aLabelCollection [ 

	^(aLabelCollection at: 'list') collect: [ :each | self visitLabel: each]
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitLeft: aLeftNode [
	^self visitJsonElement: aLeftNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitLength: aNode [
	^aNode
		ifNil: [  nil ]
		ifNotNil: [ self visitJsonMap: aNode ]
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitLessLabel: aLabelReference [
	^self visitLabelReference: aLabelReference
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitLimit: aLimitNode [
	^self visitJsonElement: aLimitNode
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitList: aListNode [
	"key 'list' used for different things. Once we are in the list we might no not what its elements are.
	 Therefore should be treated upstream and never reach this point
	
	 typically, one will do: ^(aNode at: 'list') collect: [ :each | self visitXYZ: each ] , knowing what are the elements
	of the list and what needs to be called (#visitXYZ:) "

	self shouldNotImplement 
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitLogical: aLogicalNode [
	"to be more explicit, Logical nodes are 'transformed' in LogicalLiteralValue nodes"
	^self visitLogicalLiteralValue: (aLogicalNode at: 'contents')
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitLogicalBaseType: aString [
	^aString

]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitLogicalLiteralValue: aLogicalLiteralValue [
	"to be more explicit, we create #visitTrueLiteralValue: and #visitFalseLiteralValue:"
	^aLogicalLiteralValue first
		ifTrue: [ self visitTrueLiteralValue: aLogicalLiteralValue ]
		ifFalse: [ self visitFalseLiteralValue: aLogicalLiteralValue ]
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitLower: aLowerNode [

	^ self visitArrayDimensionBoundary: aLowerNode
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitLt: aLessthanOperatorNode [

	^ '.lt.'
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitLte:  aLessThanorEqualOperatorNode [ 
	^'.le.'
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitMain: aMainProgramNode [
	^self visitJsonMap: aMainProgramNode keys: #(span name blocks subprograms)
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitMessage: aMessageNode [
	"STOP or PAUSE message"

	^self visitJsonElement: aMessageNode 
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitMeta: aMetaNode [
	^self visitJsonMap: aMetaNode keys: #(miVersion miFilename)
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitMiFilename: aString [
	^aString
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitMiVersion: aString [
	^aString
		
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitMinus: aMinusOperatorNode [
	"unary minus"
	^'-'
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitMultiplication: aMultiplicationOperatorNode [
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitName: aNode [

	^aNode isString
		ifTrue: [ aNode ]
		ifFalse: [ self visitJsonElement: aNode ]
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitNe: aNotEqualtoOperatorNode [

	^ '.ne.'
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitNeqv: aNeqvtoOperatorNode [

	^ '.neqv.'
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitNot: aNotToOperatorNode [

	^ '.not.'
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitOp: anOpNode [

	^self visitJsonTaggedElement: anOpNode
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitOpenStatement: anOpenStatement [ 

	^{
		self visitSpan: (anOpenStatement at: 'span') .
		self visitIOParameters: (anOpenStatement at: 'specification')
	}
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitOr: anOrOperatorNode [
	^ '.or.'
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitParameterStatement: aParameterStatementNode [ 
	^self visitJsonMap: aParameterStatementNode keys: #(span declarators)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitPauseStatement: aPauseStatementNode [
	^self visitJsonMap: aPauseStatementNode keys: #(span message)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitPrintFormat: aPrintFormatNode [

	^self visitJsonElement: aPrintFormatNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitPrintStatement: aPrintStatementNode [
	"format for WRITE and PRINT statements can be quite different, so we created
	 two different visit rules"

	^{ self visitSpan: (aPrintStatementNode at: 'span') .
	 self visitPrintFormat: (aPrintStatementNode at: 'format') .
	 self visitArguments: (aPrintStatementNode at: 'arguments') }
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitProgramFile: aProgramFileNode [
	^self visitJsonMap: aProgramFileNode keys: #(meta program_units)
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitProgram_units: aNode [
	^self visitJsonArray: aNode
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitRange: aRangeNode [
	^{ self visitSpan: (aRangeNode at: 'span') .
 	 self visitJsonElement: (aRangeNode at: 'lower') .
 	 self visitJsonElement: (aRangeNode at: 'upper') .
 	 self visitJsonElement: (aRangeNode at: 'stride')  }
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitReadStatement: aReadStatementNode [

	^{
		self visitSpan: (aReadStatementNode at: 'span') .
		self visitIOParameters: (aReadStatementNode at: 'format') .
		self visitArguments: (aReadStatementNode at: 'arguments')
	}
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitReal: aRealNode [
	"to be more explicit, Real nodes are 'transformed' in RealLiteralValue nodes"
	^self visitRealLiteralValue: (aRealNode at: 'contents')
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitRealBaseType: aString [
	^aString

]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitRealLiteralValue: aRealLiteralValueNode [
	^self visitJsonMap: aRealLiteralValueNode first keys: #(significand exponent)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitReturn: anEntryReturnNode [

	^anEntryReturnNode
		ifNil: [ nil ]
		ifNotNil: [ self shouldBeImplemented ]
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitReturnStatement: aReturnStatementNode [
	^self visitJsonMap: aReturnStatementNode keys: #(span target)
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitReturn_spec: aReturn_specNode [
	^self visitJsonMap: aReturn_specNode keys: #(span target)
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitRewind2Statement: aRewindStatement [ 
	"a form of rewind with only a unit specified:
	 REWIND 3"

	^{
		self visitSpan: (aRewindStatement at: 'span') .
		{ self visitJsonMap: (aRewindStatement at: 'specification') }
	}
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitRewindStatement: aRewindStatement [ 
	"a form of rewind with a list of IOParameters"

	^{
		self visitSpan: (aRewindStatement at: 'span') .
		self visitIOParameters: (aRewindStatement at: 'specification')
	}
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitRight: aRightNode [
	^self visitJsonElement: aRightNode
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitSaveStatement: aSaveStatementNode [

	^self visitJsonMap: aSaveStatementNode keys: #( span vars )

]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitSelector: aSelectorNode [

	^aSelectorNode
		ifNil: [ nil ]
		ifNotNil: [ self visitJsonMap: aSelectorNode keys: #(span kind length) ]
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitSignificand: aRealLiteralSignificandNode [
	^aRealLiteralSignificandNode
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitSingle: anArraySingleIndexNode [
	^self visitJsonMap: anArraySingleIndexNode keys: #(span index)

]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitSpan: aSpanString [
	"converts aSpanString (1:2)-(3:4) into two points {1@2 . 3@4}"

	| one two three four colon dash |
	colon := aSpanString indexOf: $:.
	one := aSpanString copyFrom: 2 to: colon-1.

	dash := aSpanString indexOf: $-.
	two := aSpanString copyFrom: colon+1 to: dash-2.
	
	colon := aSpanString indexOf: $: startingAt: dash.
	three := aSpanString copyFrom: dash+2 to: colon-1.
	
	four := aSpanString copyFrom: colon+1 to: aSpanString size-1.

	^ {one asInteger @ two asInteger .
		three asInteger @ (four asInteger + 1) }
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitSpecification: aSpecificationNode [

	^self visitJsonElement: aSpecificationNode

]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitStar: aStarNode [
	^nil
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitStatement: aStatementNode [
	^(self visitJsonMap: aStatementNode keys: #(span label))
	 ,
	{ ((self isTaggedStatement: aStatementNode)
			ifTrue: [ self visitJsonTaggedStatement: aStatementNode ]
			ifFalse: [ self visitJsonElement: (aStatementNode at: 'statement') ]) }
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitStopStatement: aStopStatementNode [
	^self visitJsonMap: aStopStatementNode keys: #(span message)
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitString: aStringLiteralNode [
	"to be more explicit, String nodes are 'transformed' in StringLiteralValue nodes"
	^self visitStringLiteralValue: aStringLiteralNode
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitStringLiteralValue: aStringLiteralNode [
	"Strings in Fortran are single quotes. And to print a single-quote, it is doubled in the string
	 (same as Pharo).
	fortran-src interprets the string and removes one of the two quotes to leave just one
	 so we need to put back the two quotes"

	^String streamContents: [ :stream |
		(aStringLiteralNode at: 'contents') do: [ :c |
			(c = $') ifTrue: [ stream << c ].
			stream << c
		]
	]
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitSubprograms: aNode [
	^nil
]

{ #category : #'visiting prog-unit' }
FortranAbstractJsonVisitor >> visitSubroutine: aSubroutineNode [
	^self visitJsonMap: aSubroutineNode keys: #(span name arguments blocks)
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitSubscript: aSubscriptNode [

	^self visitJsonMap: aSubscriptNode keys: #(span expression indices)

]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitSubtraction: aSubtractionOperatorNode [
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitTarget: aTargetNode [
	^self visitJsonElement: aTargetNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitThenPart: aThenPartNode [
	^self visitBody: aThenPartNode
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitTo: aString [
	"end of a range for an implicit statement: a string of one character"
	^aString
		ifNil: [ nil ]
		ifNotNil: [ aString ]
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitTrueLiteralValue: aString [
	"Camfort puts 'true' so we return the normal Fortran value instead"
	^'.true.'
]

{ #category : #visiting }
FortranAbstractJsonVisitor >> visitType: aTypeNode [

	^self visitJsonMap: aTypeNode keys: #(span base_type selector)
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitUnary: aUnaryNode [
	^self visitJsonMap: aUnaryNode keys: #(span op expression)
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitUpper: aUpperNode [

	^ self visitArrayDimensionBoundary: aUpperNode
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitValue: aValueNode [
	^{ self visitSpan: (aValueNode at: 'span') .
	 self visitJsonTaggedElement: (aValueNode at: 'value') }
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitVar: anExitStatementVarNode [
	self flag: #TODO.
	^nil
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitVariable: aVariableNode [
	^self visitVariableName: (aVariableNode at: 'contents')
]

{ #category : #'visiting expression' }
FortranAbstractJsonVisitor >> visitVariableName: aString [
	^aString
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitVars: anExternalStatementVarList [
	"ignoring 'span' here"

	^self visitJsonArray: (anExternalStatementVarList at: 'list')
]

{ #category : #'visiting statement' }
FortranAbstractJsonVisitor >> visitWriteStatement: aWriteStatementNode [

	^{
		self visitSpan: (aWriteStatementNode at: 'span') .
		self visitIOParameters: (aWriteStatementNode at: 'format') .
		self visitArguments: (aWriteStatementNode at: 'arguments')
	}
]

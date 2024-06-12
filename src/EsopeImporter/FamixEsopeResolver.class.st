"
For symbol resolution
"
Class {
	#name : #FamixEsopeResolver,
	#superclass : #Object,
	#instVars : [
		'model',
		'errorHandler'
	],
	#category : #'EsopeImporter-Resolver'
}

{ #category : #'private-helper' }
FamixEsopeResolver class >> on: aMooseModel [
	"Answer an instance with same model as aMooseModel."
	^self new
		  model: aMooseModel;
		  yourself
]

{ #category : #accessing }
FamixEsopeResolver >> errorHandler [

	^errorHandler ifNil: [ errorHandler := FortranErrorManager new ]
]

{ #category : #accessing }
FamixEsopeResolver >> errorHandler: anErrorHandler [

	errorHandler := anErrorHandler
]

{ #category : #'private - utility' }
FamixEsopeResolver >> findEntity: entityName inList: famixEntities [

	^ famixEntities
		  detect: [ :entity | entity name = entityName ]
		  ifNone: [ nil ]
]

{ #category : #'private - utility' }
FamixEsopeResolver >> implicitTypeFor: name inProgramUnit: programUnit [
	"find a type according to the first letter of the variable's name"

	^ programUnit dicImplicit at: name first ifAbsent: [ FamixF77TypeUnknown defaultName ]
]

{ #category : #accessing }
FamixEsopeResolver >> model [

	^ model
]

{ #category : #accessing }
FamixEsopeResolver >> model: anObject [

	model := anObject
]

{ #category : #'private-creation' }
FamixEsopeResolver >> newEntity: aFamixClass [
	^aFamixClass new
		mooseModel: model;
		yourself
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> registerImplicitForPU: programUnit range: aRange forType: iASTTypeRef [

	(aRange size = 1)
	ifTrue: [ programUnit dicImplicit at: aRange first put: iASTTypeRef entityName asSymbol ]
	ifFalse: [ 
		(aRange first to: aRange second) do: [ :letter |
			programUnit dicImplicit at: letter put: iASTTypeRef entityName asSymbol
		]
	]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> registerImplicitsDeclarations [

	(self model allWithSubTypesOf: FamixF77ProgramUnit) do: [ :programUnit |
		self errorHandler enterContext: programUnit name.
		self registerImplicitsForPU: programUnit.
		self errorHandler leaveContext
	]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> registerImplicitsForPU: programUnit [

	(programUnit attributeAt: #implicits ifAbsent: [ #() ])
	do: [ :implicitDeclaration | 
		implicitDeclaration ranges
			ifNotNil: [ 
				implicitDeclaration ranges do: [ :aRange | 
					self registerImplicitForPU: programUnit range: aRange forType: implicitDeclaration forType] ]
			ifNil: [ "implicit none"
				programUnit dicImplicit removeAll ]
	]
]

{ #category : #'private - utility' }
FamixEsopeResolver >> removeStoredIAST: anEntity [
	^self removeStoredIAST: anEntity forSymbol: #entity
]

{ #category : #'private - utility' }
FamixEsopeResolver >> removeStoredIAST: anEntity forSymbol: aSymbol [

	| entity |
	entity := anEntity 
		attributeAt: aSymbol 
		ifAbsent: [ nil ].

	anEntity attributeAt: aSymbol put: nil.

	^entity
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> requalifyFunctionDeclaration: external [
	"external decalration of functin followed by a VariableDeclaration of the same function
	 we simply remove the VariableDeclaration"

	external programUnit localVariables
		detect: [ :varDeclaration |
			varDeclaration name = external name
		]
		ifFound: [ :varDeclaration |
			varDeclaration parentBehaviouralEntity: nil.
			model remove: varDeclaration.
		]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> requalifyFunctionDeclarations [
	"VariableDeclaration that are actually functions are simply removed
	We know it is a function because there is an 'external' declaration for that name"

	(model allWithType: FamixF77ExternalDeclaration) do: [ :external |
		self requalifyFunctionDeclaration: external
	]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> requalifyParameterDeclaration: param [
	"looks for a VariableDeclaration in the same program unit with the same name"

	
	param parentBehaviouralEntity localVariables
		detect: [ :varDeclaration |
			varDeclaration name = param name
		]
		ifFound: [ :varDeclaration |
			param declaredType: varDeclaration declaredType.
			varDeclaration parentBehaviouralEntity: nil.
			model remove: varDeclaration
		]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> requalifyParameterDeclarations [
	"For each parameter, try to find a matching VariableDeclaration"

	(model allWithType: FamixF77Parameter) do: [ :param |
		self requalifyParameterDeclaration: param
	]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> requalifyVariableDeclarations [
	"a LocalVariable declaration can be a:
	- Function
	- Parameter
	- LocalVariable"

	self requalifyParameterDeclarations.
	self requalifyFunctionDeclarations.
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolve [

	#( resolveIncludes
		registerImplicitsDeclarations
		requalifyVariableDeclarations
		resolveImplicits
		resolveEsopeVariables
		resolveInvocations
		resolveAccesses) do: [ :step |
		self errorHandler enterContext: step.
		self perform: step.
		self errorHandler leaveContext
	]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAccess: anAccess [

	"- ignore access already resolved (may happen in case of attribute access)
	 - try to find a matching local variable declaration (including parameters)
	 - if not, try to resolve as an implict pointer 
	 - try to find a segment with that attribute (implicitAttribute)
	 - if not, resolve as an implicit variable
	 
	After that, if the variable resolved to a pointer, resolve its attribute access"

	| variableAccessed |

	anAccess variable ifNotNil: [ ^self ].
	(anAccess attributeAt: #parentAccess ifAbsent: [ nil])
		ifNotNil: [ "there is a #parentAccess" ^self ].

	variableAccessed := self removeStoredIAST: anAccess forSymbol: #entity.

	(self resolveAccess: anAccess asLocalVariable: variableAccessed)
	ifNotNil: [ :localVar | anAccess variable: localVar ]
	ifNil: [
		(self resolveAccess: anAccess asImplicitPointer: variableAccessed)
		ifNotNil: [ :pointer | anAccess variable: pointer ]
		ifNil: [
			(self resolveAccess: anAccess asImplicitAttribute: variableAccessed)
			ifNotNil: [ :attribute | anAccess variable: attribute ]
			ifNil: [
				anAccess variable: 
					(self resolveAccess: anAccess asImplicitVariable: variableAccessed)
			]
		]
	].

	(self removeStoredIAST: anAccess forSymbol: #attributeAccess)
		ifNotNil: [ :attributeAccess |
			self resolveAccess: attributeAccess fromPointer: anAccess variable ]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAccess: anAccess asImplicitAttribute: accessedVariable [

	^self
		findEntity: accessedVariable entityName
		inList: (anAccess accessor allTypes flatCollect: [ :type | type attributes ])
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAccess: anAccess asImplicitPointer: variableAccessed [
	"try to find a segment with the same name as the accessed variable"

	self flag: #FIXME. "Issue with an attribute."

	^anAccess accessor allTypes
		detect: [ :type |
			(type class = FamixEsopeSegment) and: 
			[ type name = variableAccessed entityName ]
		]
		ifOne: [ :type |
			(self newEntity: FamixF77Variable)
				name: variableAccessed entityName ;
				parentBehaviouralEntity: anAccess accessor ;
				declaredType: type ;
				yourself
		]
		ifNone: [ nil ].

]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAccess: anAccess asImplicitVariable: variableAccessed [
	"if we are here, we know that the variable was not declared locally
	 so we create it"

	| implicitVariable |
	implicitVariable := self newEntity: FamixF77Variable.
	implicitVariable name: variableAccessed entityName.
	implicitVariable parentBehaviouralEntity: anAccess accessor.
	implicitVariable declaredType: (self resolveImplicitVariableType: implicitVariable).

	^implicitVariable

]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAccess: anAccess asLocalVariable: accessedVariable [

	^self
		findEntity: accessedVariable entityName
		inList: anAccess accessor allLocalVariables
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAccess: anAccess fromPointer: aPointerVariable [

	| variableAccessed |
	variableAccessed := self
		                    removeStoredIAST: anAccess
		                    forSymbol: #entity.
	self assert: variableAccessed isNotNil.

	aPointerVariable declaredType attributes
		detect: [ :att | att name = variableAccessed entityName ]
		ifFound: [ :att | anAccess variable: att ].

	self removeStoredIAST: anAccess forSymbol: #parentAccess
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAccesses [

	(self model allWithSubTypesOf: FamixF77Access) do: [ :access |
		self resolveAccess: access ]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveEsopeVariable: esopeVariable [

	| segments |
	segments := self model allWithType: FamixEsopeSegment.
	segments
		detect: [ :segment | segment name = esopeVariable segment ]
		ifFound: [ :segment | esopeVariable declaredType: segment ]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveEsopeVariables [
	self flag: #FIXME. "Some Esope variables are not labelled as such"
	
	(self model allWithSubTypesOf: FamixF77Variable) 
		do: [ :var | 
			var isEsope ifTrue: [ self resolveEsopeVariable: var ]
		]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveImplicitFunction: function [

	function declaredType:
		(self resolveTypeName:
			(self implicitTypeFor: function name inProgramUnit: function)).

]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveImplicitVariableType: aVariable [

	^self resolveTypeName:
		(self
			implicitTypeFor: aVariable name
			inProgramUnit: aVariable parentBehaviouralEntity)

]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveImplicits [

	(model allWithType: FamixF77Parameter) do: [ :param |
		param declaredType ifNil: [
			param 	declaredType: (self resolveImplicitVariableType: param)
		]
	].

	(model allWithType: FamixF77PUFunction) do: [ :func |
		func declaredType ifNil: [
			self resolveImplicitFunction: func
		]
	] 
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveIncludes [
	"puts FamixF77IncludedFile into the FamixF77Include that include them"

	(self model allWithType: FamixF77Include) 
	do: [ :include |
		(self model allWithType: FamixF77IncludedFile)
			detect: [ :includedFile | includedFile programFile filename asPath basename beginsWith: include filename ]
			ifFound: [ :includedFile | include included: includedFile ]
			ifNone: [ Notification signal: 'IncludedFile: No such file or directory' ]
	]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveInvocables: invocable [

	(model allWithSubTypesOf: FamixF77PUProcedure)
		do: [ :entity |
			((entity name = invocable entityName) and: [ entity parameters size = (invocable arguments ifNil: [ #() ]) size ])
				ifTrue: [ ^ entity ]
		].

	^nil
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveInvocation: anInvocation [

	| invocated |

	invocated := self removeStoredIAST: anInvocation.

	(self resolveInvocables: invocated)
		ifNotNil: [ :invocatedFound |
			anInvocation addCandidate: invocatedFound ]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveInvocations [

	(self model allWithType: FamixF77Invocation) do: [ :invocation |
		self resolveInvocation: invocation ]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveTypeName: aName [

	self flag: 'should test the referring PU (ex: for an included segment)'.

	^(self model allWithSubTypesOf: FamixF77Type)
		detect: [ :type | type name = aName ]
		ifNone: [ self model newTypeUnknown ]
]

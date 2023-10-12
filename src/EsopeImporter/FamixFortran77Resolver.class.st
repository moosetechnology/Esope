"
For symbol resolution
"
Class {
	#name : #FamixFortran77Resolver,
	#superclass : #Object,
	#instVars : [
		'model'
	],
	#category : #'EsopeImporter-Resolver'
}

{ #category : #'private-helper' }
FamixFortran77Resolver class >> on: aMooseModel [
	"Answer an instance with same model as aMooseModel."
	^self new
		  model: aMooseModel;
		  yourself
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> findEntity: entityName fromList: famixEntities [

	^ famixEntities
		  detect: [ :entity | entity name = entityName ]
		  ifFound: [ :entity | entity ]
		  ifNone: [ nil ]
]

{ #category : #'private - utility' }
FamixFortran77Resolver >> implicitTypeFor: name inProgramUnit: programUnit [

	^ programUnit dicImplicit at: name first ifAbsent: [ FamixF77TypeUnknown defaultName ]
]

{ #category : #initialization }
FamixFortran77Resolver >> initialize [

	super initialize
	
]

{ #category : #accessing }
FamixFortran77Resolver >> model [

	^ model
]

{ #category : #accessing }
FamixFortran77Resolver >> model: anObject [

	model := anObject
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> newEntity: aFamixClass [
	^aFamixClass new
		mooseModel: model;
		yourself
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> registerImplicitForPU: programUnit range: aRange forType: iASTTypeRef [

	(aRange size = 1)
	ifTrue: [ programUnit dicImplicit at: aRange first put: iASTTypeRef name asSymbol ]
	ifFalse: [ 
		(aRange first to: aRange second) do: [ :letter |
			programUnit dicImplicit at: letter put: iASTTypeRef name asSymbol
		]
	]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> registerImplicitsDeclarations [

	(self model allWithSubTypesOf: FamixF77ProgramUnit) do: [ :programUnit | 
		self registerImplicitsForPU: programUnit ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> registerImplicitsForPU: programUnit [

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

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> removeFromModel: entity [
	"Set all pointers in the entity to nil beforehand, to make the work of the GarbageCollector easier."
	entity declaredType: nil.
	entity parentBehaviouralEntity: nil.
	entity sourceAnchor: nil.
	self model remove: entity.
]

{ #category : #'private - utility' }
FamixFortran77Resolver >> removeStoredIAST: anEntity [
	^self removeStoredIAST: anEntity forSymbol: #entity
]

{ #category : #'private - utility' }
FamixFortran77Resolver >> removeStoredIAST: anEntity forSymbol: aSymbol [

	| entity |
	entity := anEntity 
		attributeAt: aSymbol 
		ifAbsent: [ nil ].

	anEntity attributeAt: aSymbol put: nil.

	^entity
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyFunction: function [

	| type name |
	name := self
		        implicitTypeFor: function name
		        inProgramUnit: function.
	name ifNotNil: [
		type := self resolveTypeName: name.
		function declaredType: type ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyFunctionDeclaration: external [
	"external decalration of functin followed by a VariableDeclaration of the same function
	 we simply remove the VariableDeclaration"

	external parentBehaviouralEntity localVariables
		detect: [ :varDeclaration |
			varDeclaration name = external name
		]
		ifOne: [ :varDeclaration |
			varDeclaration parentBehaviouralEntity: nil.
			model remove: varDeclaration.
		]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyFunctionDeclarations [
	"VariableDeclaration that are actually functions are simply removed
	We know it is a function because there is an 'external' declaration for that name"

	(model allWithType: FamixF77ExternalDeclaration) do: [ :external |
		self requalifyFunctionDeclaration: external
	]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyParameterDeclaration: param [
	"looks for a VariableDeclaration in the same program unit with the same name"

	
	param parentBehaviouralEntity localVariables
		detect: [ :varDeclaration |
			varDeclaration name = param name
		]
		ifOne: [ :varDeclaration |
			param declaredType: varDeclaration declaredType.
			varDeclaration parentBehaviouralEntity: nil.
			model remove: varDeclaration
		]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyParameterDeclarations [
	"For each parameter, try to find a matching VariableDeclaration"

	(model allWithType: FamixF77Parameter) do: [ :param |
		self requalifyParameterDeclaration: param
	]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyVariableDeclarations [
	"a LocalVariable declaration can be a:
	- Function
	- Parameter
	- LocalVariable"

	self requalifyParameterDeclarations.
	self requalifyFunctionDeclarations.
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolve [

	self resolveIncludes.
	self registerImplicitsDeclarations.
	self requalifyVariableDeclarations.
	self resolveImplicits.
	self resolveEsopeVariables.
	self resolveInvocations.
	self resolveAccesses.
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAccess: anAccess [

	| variableAccessed |

	anAccess variable ifNotNil: [ ^self ].
	(anAccess attributeAt: #parentAccess ifAbsent: [ nil])
		ifNotNil: [ ^self ].

	variableAccessed := self removeStoredIAST: anAccess forSymbol: #entity.

	(self resolveAccess: anAccess asLocalVariable: variableAccessed)
		ifFalse: [ self resolveAccess: anAccess asImplicitVariable: variableAccessed ].

	(self removeStoredIAST: anAccess forSymbol: #attributeAccess)
		ifNotNil: [ :attributeAccess |
			self resolveAccess: attributeAccess fromPointer: anAccess variable ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAccess: anAccess asImplicitVariable: variableAccessed [
	"if we are here, we know that the variable was not declared locally
	 so we create it"

	anAccess accessor
		addLocalVariable: (self
			resolveAsImplicit: variableAccessed
		   fromProgramUnit: anAccess accessor).

	^ true
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAccess: anAccess asLocalVariable: accessedVariable [

	^(self
		retrieveVariable: accessedVariable
		fromProgramUnit: anAccess accessor)
		ifNotNil: [ :localVar |
			anAccess variable: localVar.
			true ]
		ifNil: [ false ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAccess: anAccess fromPointer: aPointerVariable [

	| variableAccessed |
	variableAccessed := self
		                    removeStoredIAST: anAccess
		                    forSymbol: #entity.
	self assert: variableAccessed isNotNil.

	aPointerVariable declaredType entityAttributes
		detect: [ :att | att name = variableAccessed entityName ]
		ifFound: [ :att | anAccess variable: att ].

	self removeStoredIAST: anAccess forSymbol: #parentAccess
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAccesses [

	(self model allWithSubTypesOf: FamixF77Access) do: [ :access |
		self resolveAccess: access ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAsImplicit: anImplicitVariable fromProgramUnit: progUnit [

	| type |
	self flag: #FIXME. "how to build sourceAnchor for newly created var?"

	type := progUnit types
		        ifEmpty: [
			        self resolveTypeName: (self
					         implicitTypeFor: anImplicitVariable entityName
					         inProgramUnit: progUnit) ]
		        ifNotEmpty: [
			        self
				        findEntity: anImplicitVariable entityName
				        fromList: progUnit types ].

	^ (self newEntity: FamixF77Variable)
		  name: anImplicitVariable entityName;
		  declaredType: type;
		  yourself
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveEsopeVariable: esopeVariable [

	| segments |
	segments := self model allWithType: FamixEsopeSegment.
	segments
		detect: [ :segment | segment name = esopeVariable segment ]
		ifOne: [ :segment | esopeVariable declaredType: segment ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveEsopeVariables [

	(self model allWithSubTypesOf: FamixF77Variable) do: [ :var |
			var isEsope
				ifTrue: [ self resolveEsopeVariable: var ] ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveEsopeVariables: esopeVariables [

	esopeVariables do: [ :esopeVariable |
		self resolveEsopeVariable: esopeVariable ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveImplicitFunction: function [

	function declaredType:
		(self resolveTypeName:
			(self implicitTypeFor: function name inProgramUnit: function)).

]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveImplicitParameter: parameter [

	parameter declaredType:
		(self resolveTypeName:
			(self
				implicitTypeFor: parameter name
				inProgramUnit: parameter parentBehaviouralEntity)).

]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveImplicits [

	(model allWithType: FamixF77Parameter) do: [ :param |
		param declaredType ifNil: [
			self resolveImplicitParameter: param
		]
	].


	(model allWithType: FamixF77PUFunction) do: [ :func |
		func declaredType ifNil: [
			self resolveImplicitFunction: func
		]
	] 
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveIncludes [
	"puts FamixF77IncludedFile into the FamixF77Include that include them"

	(self model allWithType: FamixF77Include) do: [ :include | | includedFilename |
		includedFilename := include filename , '.f'.
		
		(self model allWithType: FamixF77IncludedFile)
			detect: [ :includedFile |
					includedFile programFile filename endsWith: includedFilename]
			ifFound: [ :includedFile | include included: includedFile ]
			ifNone: [ Notification signal: 'IncludedFile: No such file or directory' ]
	]
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> resolveInvocables: invocable [

	(model allWithSubTypesOf: FamixF77PUProcedure)
		do: [ :entity |
			((entity name = invocable entityName) and: [ entity parameters size = (invocable arguments ifNil: [ #() ]) size ])
				ifTrue: [ ^ entity ]
		].

	^nil
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveInvocation: anInvocation [

	| invocated |

	invocated := self removeStoredIAST: anInvocation.

	(self resolveInvocables: invocated)
		ifNotNil: [ :invocatedFound |
			anInvocation addCandidate: invocatedFound ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveInvocations [

	(self model allWithType: FamixF77Invocation) do: [ :invocation |
		self resolveInvocation: invocation ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveInvocations: anInvocations [

	anInvocations do: [ :invocation | 
		(invocation sourceText beginsWith: 'write' caseSensitive: false) 
			ifFalse: [ self resolveInvocation: invocation ] ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveTypeName: aName [

	self flag: 'should test the referring PU (ex: for an included segment)'.

	^(self model allWithSubTypesOf: FamixF77Type)
		detect: [ :type | type name = aName ]
		ifNone: [ self model newTypeUnknown ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveTypeName: aName inPU: aProgramUnit [

	(aProgramUnit allTypes)
		detect: [ :type | type name = aName ]
		ifOne: [ :type | ^type ].

	self model intrinsicTypes 
		detect: [ :type | type name = aName ]
		ifOne: [ :type | ^type ].

	^self model newTypeUnknown
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> retrieveParameters: aProgramUnit [
	^aProgramUnit isInvocable
		ifTrue: [ aProgramUnit parameters ]
		ifFalse: [ #() ]
	
		
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> retrieveVariable: variableName fromList: variables [

	^ self findEntity: variableName fromList: variables
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> retrieveVariable: aVariable fromProgramUnit: programUnit [

	"- Search in the known parameters and variables for the one whose name matches the aVariable name"

	"- compare their type also ?"

	| target localVariables |
	target := self
		          findEntity: aVariable entityName
		          fromList:
		          (programUnit types collect: [ :type | type attributes ])
			          flattened.

	target ifNotNil: [ ^ target ].

	target := programUnit isInvocable
		          ifTrue: [ 
			          self
				          retrieveVariable: aVariable entityName
				          fromList: programUnit parameters ]
		          ifFalse: [ nil ].
	target ifNotNil: [ ^ target ].

	localVariables := programUnit isSubroutine
		                  ifTrue: [ programUnit allLocalVariables ]
		                  ifFalse: [ programUnit localVariables ].

	^ self
		  retrieveVariable: aVariable entityName
		  fromList: localVariables
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> retrieveVariable: aVariable fromSegments: segments [

	"- Search in the known segments one whose containing the aVariable name"

	"- compare their type also ?"

	| target attributes |
	attributes := segments collect: [ :segment | segment attributes ].

	target := self
		          retrieveVariable: aVariable entityName
		          fromList: attributes flattened.

	target ifNotNil: [ ^ target ].

	^ self
		  retrieveVariable: (self model allWithType: FamixEsopeSegment)
		  fromList: attributes flattened
]

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

{ #category : #'private - utility' }
FamixFortran77Resolver >> defaultImplicitTyping: name fromProgramUnit: programUnit [

	^ programUnit dicImplicit at: name first
]

{ #category : #'private - utility' }
FamixFortran77Resolver >> findEntity: anEntity forType: aType [
	^((self model allWithType:  aType) 
		select: [ :each | each class = aType 
			and: [ each name = anEntity entityName ]]) first.
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
FamixFortran77Resolver >> removeFromModel: entity [
	"Set all pointers in the entity to nil beforehand, to make the work of the GarbageCollector easier."
	entity declaredType: nil.
	entity parentBehaviouralEntity: nil.
	entity sourceAnchor: nil.
	self model remove: entity.
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyFunction: function [

	| type name |
	name := self
		        defaultImplicitTyping: function name
		        fromProgramUnit: function.
	name ifNotNil: [
		type := self retrieveTypeFrom: name.
		function declaredType: type ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyFunctions [

	| functions |
	functions := (self model allWithType: FamixF77PUFunction).

	functions do: [ :function | self requalifyFunction: function ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyFunctions: functions [

	functions do: [ :function | self requalifyFunction: function ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyParameter: parameter [

	| type name progUnit |
	progUnit := parameter parentBehaviouralEntity.
	"p := (self model allWithType: FamixF77Variable)
		     detect: [ :var | var name = parameter name ]
		     ifFound: [ :var | parameter declaredType: var declaredType ]."

	name := self
		        defaultImplicitTyping: parameter name
		        fromProgramUnit: progUnit.
	name ifNotNil: [
		type := self retrieveTypeFrom: name.
		parameter declaredType: type ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyParameters [

	| parameters |
	parameters := (self model allWithType: FamixF77Parameter).

	parameters do: [ :parameter | self requalifyParameter: parameter ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyParameters: parameters [

	parameters do: [ :parameter | self requalifyParameter: parameter ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyVariableDeclaration: variableDeclaration [

	(self requalifyVariableDeclarationAsParameter: variableDeclaration) 
		ifTrue: [ ^ self ].

	self requalifyVariableDeclarationAsFunction: variableDeclaration
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyVariableDeclarationAsFunction: variableDeclaration [
	| function |
	function := self retrieveInvocables: variableDeclaration name.
	function ifNil: [ ^false ].
	function declaredType: variableDeclaration declaredType.
	self removeFromModel: variableDeclaration.
	^true
		
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyVariableDeclarationAsParameter: variableDeclaration [
	| param |
	param := self 
		retrieveVariable: variableDeclaration name 
		fromList: (self retrieveParameters: variableDeclaration parentBehaviouralEntity).

	param ifNil: [ ^false ].
	param declaredType: variableDeclaration declaredType.
	self removeFromModel: variableDeclaration.
	^true
		
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyVariableDeclarations [

	| variableDeclarations |
	variableDeclarations := (self model allWithType: FamixF77Variable).
	"a LocalVariable declaration can be a:
	- Function
	- Parameter"
	variableDeclarations 
		do: [ :variableDeclaration | self requalifyVariableDeclaration: variableDeclaration ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> requalifyVariableDeclarations: variableDeclarations [
	"a LocalVariable declaration can be a:
	- Function
	- Parameter"
	variableDeclarations 
		do: [ :variableDeclaration | self requalifyVariableDeclaration: variableDeclaration ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolve [

	self resolveIncludes.
	self resolveImplicitsDeclarations.
	self requalifyParameters.
	self requalifyFunctions.
	self resolveEsopeVariables.
	self requalifyVariableDeclarations.
	self resolveAccesses.
	self resolveInvocations
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAccess: anAccess [

	| target varAccessed var varPointer |

	varAccessed := self retrieveStoredIast: anAccess forSymbol: #entity.
	varPointer := self retrieveStoredIast: anAccess forSymbol: #pointer.

	target := varPointer
		          ifNotNil: [ 
			          self
				          retrieveVariable: varAccessed
				          fromSegments: "anAccess accessor types" anAccess accessor allTypes ]
		          ifNil: [ 
			          self
				          retrieveVariable: varAccessed
				          fromProgramUnit: anAccess accessor ].

	target ifNotNil: [ ^ anAccess variable: target ].

	var := self
		       resolveAsImplicit: varAccessed
		       fromProgramUnit: anAccess accessor.
	anAccess accessor addLocalVariable: var.
	^ anAccess variable: var
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAccesses [

	| anAccesses |
	anAccesses := (self model allWithSubTypesOf: FamixF77Access).

	anAccesses do: [ :access | self resolveAccess: access ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAccesses: anAccesses [

	anAccesses do: [ :access | self resolveAccess: access ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveAsImplicit: anImplicitVariable fromProgramUnit: progUnit [

	| type |
	self flag: #FIXME. "how to build sourceAnchor for newly created var?"

	type := progUnit types
		        ifEmpty: [
			        self retrieveTypeFrom: (self
					         defaultImplicitTyping: anImplicitVariable entityName
					         fromProgramUnit: progUnit) ]
		        ifNotEmpty: [
			        self
				        retrieveEntity: anImplicitVariable entityName
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

	| esopeVariables |
	esopeVariables := ((self model allWithSubTypesOf: FamixF77Variable) select: [ :var |
			 var isEsope ]).

	esopeVariables do: [ :esopeVariable |
		self resolveEsopeVariable: esopeVariable ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveEsopeVariables: esopeVariables [

	esopeVariables do: [ :esopeVariable |
		self resolveEsopeVariable: esopeVariable ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveImplicitsDeclarations [

	(self model allWithSubTypesOf: FamixF77ProgramUnit) do: [ :programUnit | 
		self resolveImplicitsFor: programUnit ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveImplicitsDeclarations: programUnits [

	programUnits do: [ :programUnit | 
		self resolveImplicitsFor: programUnit ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveImplicitsFor: programUnit [

	(programUnit attributeAt: #implicits ifAbsent: [ #() ])
	do: [ :implicitDeclaration | 
		implicitDeclaration ranges
			ifNotNil: [ 
				implicitDeclaration ranges flattened do: [ :letter | 
					programUnit dicImplicit
						at: letter
						put: implicitDeclaration forType name asSymbol ] ]
			ifNil: [ 
				Character alphabet do: [ :letter | 
					programUnit dicImplicit at: letter put: nil ] ] ]
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

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveIncludes: includes [

	| includedFiles |
	includedFiles := self model allWithType: FamixF77IncludedFile.
	includes do: [ :include | 
		includedFiles
			detect: [ :includedFile | 
					includedFile programFile filename includesSubstring: include filename ]
			ifFound: [ :includedFile | include included: includedFile ]
			ifNone: [ 
			Notification signal: 'IncludedFile: No such file or directory' ] ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveInvocation: anInvocation [

	| invocated |
	invocated := self retrieveStoredIast: anInvocation.
	(self retrieveInvocables: invocated entityName) ifNotNil: [ 
		:invocatedFound | anInvocation addCandidate: invocatedFound ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveInvocations [

	| anInvocations |
	anInvocations := (self model allWithType: FamixF77Invocation).
	anInvocations do: [ :invocation | 
		(invocation sourceText beginsWith: 'write' caseSensitive: false) 
			ifFalse: [ self resolveInvocation: invocation ] ]
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> resolveInvocations: anInvocations [

	anInvocations do: [ :invocation | 
		(invocation sourceText beginsWith: 'write' caseSensitive: false) 
			ifFalse: [ self resolveInvocation: invocation ] ]
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> retrieveEntity: entityName fromList: famixEntities [

	^ famixEntities
		  detect: [ :entity | entity name = entityName ]
		  ifFound: [ :entity | entity ]
		  ifNone: [ nil ]
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> retrieveInvocables: name [

	^ self
		  retrieveEntity: name
		  fromList: (model allWithSubTypesOf: FamixF77PUProcedure)
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> retrieveParameters: aProgramUnit [
	^aProgramUnit isInvocable
		ifTrue: [ aProgramUnit parameters ]
		ifFalse: [ #() ]
	
		
]

{ #category : #'private - utility' }
FamixFortran77Resolver >> retrieveStoredIast: anEntity [
	^self retrieveStoredIast: anEntity forSymbol: #entity
]

{ #category : #'private - utility' }
FamixFortran77Resolver >> retrieveStoredIast: anEntity forSymbol: aSymbol [
	| entity |
	entity := anEntity 
		attributeAt: aSymbol 
		ifAbsent: [ Notification signal: 'problem with generated entity' ].
	anEntity attributeAt: aSymbol put: nil.
	^entity
]

{ #category : #'symbols resolution' }
FamixFortran77Resolver >> retrieveTypeFrom: aName [

	^ (self model attributeAt: #instrinsicTypes ifAbsent: [
		   self model
			   attributeAt: #unknownType
			   ifAbsent: [ ^ self newEntity: FamixF77TypeUnknown ] ])
		  at: aName
		  ifAbsent: [ self newEntity: FamixF77TypeUnknown ]
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> retrieveVariable: variableName fromList: variables [

	^ self retrieveEntity: variableName fromList: variables
]

{ #category : #'private-creation' }
FamixFortran77Resolver >> retrieveVariable: aVariable fromProgramUnit: programUnit [

	"- Search in the known parameters and variables for the one whose name matches the aVariable name"

	"- compare their type also ?"

	| target localVariables |
	target := self
		          retrieveEntity: aVariable entityName
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

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
	#category : #'EsopeImporter-Importer'
}

{ #category : #'private-helper' }
FamixEsopeResolver class >> on: aMooseModel [
	"Answer an instance with same model as aMooseModel."
	^self new
		  model: aMooseModel;
		  yourself
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> createImplicitVariable: variableName in: anAccessor [
	"if we are here, we know that the variable was not declared locally
	 so we create it"

	| implicitVariable |
	implicitVariable := self newEntity: FamixF77Variable.
	implicitVariable name: variableName.
	implicitVariable parentBehaviouralEntity: anAccessor.
	implicitVariable declaredType: (self resolveImplicitVariableType: implicitVariable).

	^implicitVariable

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
FamixEsopeResolver >> implicitTypeFor: name inProgramUnit: programUnit [
	"find a type according to the first letter of the variable's name"

	^ programUnit implicitDictionary at: name first ifAbsent: [ FamixF77TypeUnknown defaultName ]
]

{ #category : #'private - import' }
FamixEsopeResolver >> mergeVariable: variableToRemove into: variableToKeep [
	"merge meaningfull properties from variableToRemove into variableToKeep
	 then remove links between variableToRemove and other entities (associations are
	 bi-directional, so we actually remove variableToRemove from the other entities),
	 finally remove variableToRemove from model

	 properties of FamixF77Varibale are:
	 - mooseName :						ignore, should be the same (ignoring upper/lower case)
	 - cache :							ignore, should be empty
	 - entityAttributes :				ignore, should be empty
	 - mooseModel :						ignore, should be the same
	 - isEsope :							ignore, keep value of variable1
	 - parentBehaviouralEntity :	ignore, should be the same (clear it in variableToRemove)
	 - incomingAccesses :				merge
	 - name :								ignore, should be the same
	 - isStub :							ignore
	 - sourceAnchor :					merge, keep the first one (clear it in variableToRemove)
	 - declaredType :					ignore, keep value of variableToKeep (clear it in variableToRemove)"

	variableToRemove incomingAccesses do: [ :access |
		access variable: variableToKeep ].

	variableToRemove parentBehaviouralEntity: nil.
	variableToRemove sourceAnchor: nil.
	variableToRemove declaredType: nil.

	model removeEntity: variableToRemove
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
	"for letters in aRange register in implicit dictionary the corresponding iASTTypeRef"

	(aRange size = 1)
	ifTrue: [ programUnit implicitDictionary
		at: aRange first
		put: iASTTypeRef entityName asSymbol ]
	ifFalse: [ 
		(aRange first to: aRange second) do: [ :letter |
			programUnit implicitDictionary 
				at: letter
				put: iASTTypeRef entityName asSymbol
		]
	]
]

{ #category : #run }
FamixEsopeResolver >> registerImplicitsDeclarations [
	"find IMPLICIT declaration statements in all program units and register them
	 in the respective implicitDictionary"

	(self model allWithSubTypesOf: FamixF77ProgramUnit) do: [ :programUnit |
		self errorHandler enterContext: 'on file ' , programUnit name.
		self registerImplicitsForPU: programUnit.
		self errorHandler leaveContext
	]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> registerImplicitsForPU: programUnit [
	"find all IMPLICIT declaration statement in programUnit and register them
	 in the implicitDictionary of this program-unit"

	(programUnit attributeAt: #implicits ifAbsent: [ #() ])
	do: [ :implicitDeclaration | 
		implicitDeclaration ranges
			ifNotNil: [ :ranges |
				ranges do: [ :aRange | 
					self
						registerImplicitForPU: programUnit
						range: aRange
						forType: implicitDeclaration forType] ]
			ifNil: [ "implicit none"
				programUnit implicitDictionary removeAll ]
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
	"looks for a VariableDeclaration in the same program unit with the same name
	 then merge the VariableDeclaration into param, but keeping the declaredType
	 of the VariableDeclaration"

	(self resolveAsLocalVariable: param name in: param parentBehaviouralEntity)
		do: [ :varDeclaration |
			(varDeclaration = param)
			ifFalse: [
				param declaredType: varDeclaration declaredType.
				self mergeVariable: varDeclaration into: param
			]
		]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> requalifyParameterDeclarations [
	"For each parameter, try to find a matching VariableDeclaration to merge them together"

	(model allWithType: FamixF77Parameter) do: [ :param |
		self requalifyParameterDeclaration: param
	]
]

{ #category : #run }
FamixEsopeResolver >> requalifyVariableDeclarations [
	"some LocalVariable entities are actually Functions
	 for some other, there is a Parameter and a LocalVariable for the same Fortran entity"

	self requalifyParameterDeclarations.
	self requalifyFunctionDeclarations.
]

{ #category : #run }
FamixEsopeResolver >> resolve [

	self resolvingSteps do: [ :step |
		self errorHandler enterContext: step.
		self perform: step.
		self errorHandler leaveContext ]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAccess: anAccess [
	"- ignore access already resolved (may happen in case of attribute access)
	 - try to find a matching local variable declaration (including parameters)
	 - if not, try to resolve as an implict pointer 
	 - try to find a segment with that attribute (implicitAttribute)
	 - if not, resolve as an implicit variable
	 
	After that, if the variable resolved to a pointer, resolve its attribute access"

	| variableName |
	anAccess variable ifNotNil: [ ^ self ].
	(anAccess attributeAt: #parentAccess ifAbsent: [ nil ]) ifNotNil: [ "there is a #parentAccess"
		^ self ].

	variableName := (self removeStoredIAST: anAccess forSymbol: #entity)
		                entityName.

	anAccess variable:
		(self resolveVariableNamed: variableName in: anAccess accessor).

	(self removeStoredIAST: anAccess forSymbol: #attributeAccess)
		ifNotNil: [ :attributeAccess |
			self resolveAccess: attributeAccess fromPointer: anAccess variable ]
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

{ #category : #run }
FamixEsopeResolver >> resolveAccesses [

	(self model allWithSubTypesOf: FamixF77Access) do: [ :access |
		self resolveAccess: access ]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAsImplicitAttribute: variableName in: anAccessor [

	^(anAccessor allTypes flatCollect: [ :type | type attributes ])
		select: [ :entity | entity name = variableName ]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAsImplicitPointer: variableName in: anAccessor [
	"try to find a segment with the same name as the accessed variable"

	self flag: #FIXME. "Issue with an attribute."

	^anAccessor allTypes
		select: [ :type |
			(type class = FamixEsopeSegment) and: 
			[ type name = variableName ]
		]
		thenCollect: [ :type |
			(self newEntity: FamixF77Variable)
				name: variableName ;
				parentBehaviouralEntity: anAccessor ;
				declaredType: type ;
				yourself
		]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveAsLocalVariable: variableName in: anAccessor [

	^anAccessor allLocalVariables
		select: [ :entity | entity name = variableName ]
]

{ #category : #run }
FamixEsopeResolver >> resolveDeclaredTypeOfPointers [
	
	self flag: #FIXME. "Some Esope variables are not labelled as such"
	
	(self model allWithSubTypesOf: FamixF77Variable) 
		do: [ :var | 
			var isEsope ifTrue: [ self resolveEsopeVariable: var ]
		]
]

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveEsopeVariable: esopeVariable [
	"sets the declaredType of declared pointer esopeVariable"

	| segments |
	segments := self model allWithType: FamixEsopeSegment.
	segments
		detect: [ :segment | segment name = esopeVariable segment ]
		ifFound: [ :segment | esopeVariable declaredType: segment ]
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

{ #category : #run }
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

{ #category : #run }
FamixEsopeResolver >> resolveIncludes [
	"links FamixF77IncludedFile with the FamixF77Include_s that concern them"

	(self model allWithType: FamixF77Include) 
	do: [ :include |
		(self model allWithType: FamixF77IncludedFile)
			detect: [ :includedFile |
				includedFile programFile filename asPath basename beginsWith: include filename ]
			ifFound: [ :includedFile | include included: includedFile ]
			ifNone: [ Notification signal: ' no such file' , include filename ]
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

{ #category : #run }
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

{ #category : #'symbols resolution' }
FamixEsopeResolver >> resolveVariableNamed: variableName in: accessor [

	| found inCaseOfError |
	inCaseOfError := Notification new
		messageText: 'several variables named ', variableName , ' in ' , accessor name.

	found := self resolveAsLocalVariable: variableName in: accessor.
	(found size > 1) ifTrue: [ inCaseOfError signal ].
	(found size = 1) ifTrue: [ ^found anyOne ].

  found := self resolveAsImplicitPointer: variableName in: accessor.
	(found size > 1) ifTrue: [ inCaseOfError signal ].
	(found size = 1) ifTrue: [ ^found anyOne ].

	found := self resolveAsImplicitAttribute: variableName in: accessor.
	(found size > 1) ifTrue: [ inCaseOfError signal ].
	(found size = 1) ifTrue: [ ^found anyOne ].

	^self createImplicitVariable: variableName in: accessor
]

{ #category : #run }
FamixEsopeResolver >> resolvingSteps [

	^ #( resolveIncludes
		  registerImplicitsDeclarations
	     requalifyVariableDeclarations
		  resolveImplicits
		  #resolveDeclaredTypeOfPointers
	     resolveInvocations
		  resolveAccesses )
]

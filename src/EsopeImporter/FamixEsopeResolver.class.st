"
For symbol resolution
"
Class {
	#name : 'FamixEsopeResolver',
	#superclass : 'Object',
	#instVars : [
		'model',
		'errorHandler'
	],
	#category : 'EsopeImporter-Importer',
	#package : 'EsopeImporter',
	#tag : 'Importer'
}

{ #category : 'as yet unclassified' }
FamixEsopeResolver class >> intrinsicRoutines [

	^#( abort . abs . access . achar . acos . adjustl . adjustr . aimag . aint . alarm . all . allocated . alog . alog10 . amax0 . amax1 . amin0 . amin1 . amod . and . anint . any . asin . associated . atan . atan2 . besj0 . besj1 . besjn . besy0 . besy1 . besyn . bit_size . btest . cabs . ccos . ceiling . cexp . char . chdir . chmod . clog . cmplx . complex . conjg . cos . cosh . count . cpu_time . cshift . csin . csqrt . ctime . ctime . dabs . dacos . dasin . datan . datan2 . date_and_time . dbesj0 . dbesj1 . dbesjn . dbesy0 . dbesy1 . dbesyn . dble . dcos . dcosh . ddim . derf . derfc . dexp . digits . dim . dint . dlog . dlog10 . dmax1 . dmin1 . dmod . dnint . dot_product . dprod . dsign . dsin . dsinh . dsqrt . dtan . dtanh . dtime . eoshift . epsilon . erf . erfc . etime . etime . exit . exp . exponent . fdate . fdate . fget . fgetc . float . floor . flush . fnum . fput . fputc . fraction . fseek . fstat . fstat . ftell . ftell . gerror . getarg . getcwd . getcwd . getenv . getgid . getlog . getpid . getuid . gmtime . hostnm . hostnm . huge . iabs . iachar . iand . iargc . ibclr . ibits . ibset . ichar . idate . idim . idint . idnint . ieor . ierrno . ifix . imag . imagpart . index . int . int2 . int8 . ior . irand . isatty . ishft . ishftc . isign . itime . kill . kind . lbound . len . len_trim . lge . lgt . link . lle . llt . lnblnk . loc . log . log10 . logical . long . lshift . lstat . lstat . ltime . matmul . max . max0 . max1 . maxexponent . maxloc . maxval . mclock . mclock8 . merge . min . min0 . min1 . minexponent . minloc . minval . mod . modulo . mvbits . nearest . nint . not . or . pack . perror . precision . present . product . radix . rand . random_number . random_seed . range . real . realpart . rename . repeat . reshape . rrspacing . rshift . scale . scan . second . second . selected_int_kind . selected_real_kind . set_exponent . shape . short . sign . signal . sin . sinh . sleep . sngl . spacing . spread . sqrt . srand . stat . stat . sum . symlnk . system . system_clock . tan . tanh . time . time8 . tiny . transfer . transpose . trim . ttynam . ttynam . ubound . umask . unlink . unpack . verify . write . xor . zabs . zcos . zexp . zlog . zsin . zsqrt )
]

{ #category : 'private-helper' }
FamixEsopeResolver class >> on: aMooseModel [
	"Answer an instance with same model as aMooseModel."
	^self new
		  model: aMooseModel;
		  yourself
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> ensureVariableNamed: variableName in: famixProgramUnit [

	(famixProgramUnit class = FamixF77PUFunction and: [ variableName = famixProgramUnit name ])
		ifTrue: [ ^nil ].

	^(self resolveVariableNamed: variableName in: famixProgramUnit)
		ifNotNil: [ :localVar | localVar ]
		ifNil: [ famixProgramUnit createUnresolveVariable: variableName with: self ]

]

{ #category : 'accessing' }
FamixEsopeResolver >> errorHandler [

	^errorHandler ifNil: [ errorHandler := FortranErrorManager new ]
]

{ #category : 'accessing' }
FamixEsopeResolver >> errorHandler: anErrorHandler [

	errorHandler := anErrorHandler
]

{ #category : 'private' }
FamixEsopeResolver >> isIntrinsicRoutine: invocated [

	^self class intrinsicRoutines includes: invocated entityName
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> makePointerVariableForEsopeCommand: esopeCmd [
	"esopeCmd is a kind of Access where the variable is an Esope pointeur
	 We need to:
	 - check if there is another variable with the same name in the owner
	 - if so, merge the 2 variables into one"

	(self
		resolveAllVariablesNamed: esopeCmd variable name
		in: esopeCmd accessor)

		do: [ :variable |
			variable = esopeCmd variable
				ifFalse: [ self mergeVariable: variable into: esopeCmd variable ] ]

]

{ #category : 'private' }
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

{ #category : 'accessing' }
FamixEsopeResolver >> model [

	^ model
]

{ #category : 'accessing' }
FamixEsopeResolver >> model: anObject [

	model := anObject
]

{ #category : 'private' }
FamixEsopeResolver >> newEntity: aFamixClass [
	^aFamixClass new
		mooseModel: model;
		yourself
]

{ #category : 'run' }
FamixEsopeResolver >> propagatePointerType [

	(model allWithType: FamixEsopeCommand) do: [ :esopeCmd |
		errorHandler enterContext: esopeCmd commandName.
		self makePointerVariableForEsopeCommand: esopeCmd.
		errorHandler leaveContext
	]
]

{ #category : 'run' }
FamixEsopeResolver >> registerImplicitsDeclarations [
	"find IMPLICIT declaration statements in all program units and register them
	 in the respective implicitDictionary-s"

	(self model allWithSubTypesOf: FamixF77ProgramUnit) do: [ :famixPU |
		self errorHandler enterContext: 'on file ' , famixPU name.
		famixPU registerImplicits.
		self errorHandler leaveContext
	]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> requalifyFunctionDeclaration: external [
	"external declaration of function followed by a VariableDeclaration of the same function
	 we simply remove the VariableDeclaration
	 We remove links with other entities (associations are bi-directional, this remove the
	 variable from the other entities):
	 - parentBehaviouralEntity:
	 - declaredType -- probably useless, varDeclaration should have no declaredType
	 - incomingAccesses -- probably useless, varDeclaration should have no incomingAccesses"

	external programUnit localVariables
		detect: [ :varDeclaration |
			varDeclaration name = external name
		]
		ifFound: [ :varDeclaration |
			varDeclaration parentBehaviouralEntity: nil.
			varDeclaration declaredType: nil.
			varDeclaration incomingAccesses: #().
			model remove: varDeclaration.
		]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> requalifyFunctionDeclarations [
	"VariableDeclaration that are actually functions are simply removed
	We know it is a function because there is an 'external' declaration for that name"

	(model allWithType: FamixF77ExternalDeclaration) do: [ :external |
		self requalifyFunctionDeclaration: external
	]
]

{ #category : 'symbols resolution' }
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

{ #category : 'symbols resolution' }
FamixEsopeResolver >> requalifyParameterDeclarations [
	"For each parameter, try to find a matching VariableDeclaration to merge them together"

	(model allWithType: FamixF77Parameter) do: [ :param |
		self requalifyParameterDeclaration: param
	]
]

{ #category : 'run' }
FamixEsopeResolver >> requalifyVariableDeclarations [
	"some LocalVariable entities are actually Functions
	 for some other, there is a Parameter and a LocalVariable for the same Fortran entity"

	self requalifyParameterDeclarations.
	self requalifyFunctionDeclarations.
]

{ #category : 'run' }
FamixEsopeResolver >> resolve [

	self resolvingSteps do: [ :step |
		self errorHandler enterContext: step.
		self perform: step.
		self errorHandler leaveContext
	]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveAccess: aFamixAccess [
	"set #variable property of anAccess from the IASTVariable it contains.
	 Might create a new Famix variable if none is found

	 - ignore accesses already resolved (may happen in case of attribute access)
	 - if access is pointer.attribute, resolve the parent pointer first, then the attribute
	 - otherwise let the accessor resolve the variable within itself"

	| iastVariable |
	aFamixAccess variable ifNotNil: [ ^self ].

	(aFamixAccess getAndRemoveAttribute: #parentAccess)
		ifNotNil: [ :famixPointerAccess |
			self resolveAccess: famixPointerAccess.
			self resolveAttributeAccess: aFamixAccess forPointer: famixPointerAccess variable.
			^self
		].
 
	iastVariable := aFamixAccess getAndRemoveAttribute: #entity.
	self assert: iastVariable isNotNil.

	(self ensureVariableNamed: iastVariable entityName trim in: aFamixAccess accessor)
		ifNotNil: [ :variable |	aFamixAccess variable: variable ]

]

{ #category : 'run' }
FamixEsopeResolver >> resolveAccesses [
	"Access-es do not have #variable at this point but an IASTVariable
	 sets the #variable property of all Access-es"

	(self model allWithSubTypesOf: FamixF77Access) do: [ :access |
		self resolveAccess: access ]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveAllVariablesNamed: variableName in: accessor [

	| found  |
	found := OrderedCollection new.

	found addAll: (self resolveAsLocalVariable: variableName in: accessor).
	found addAll: (self resolveAsImplicitAttribute: variableName in: accessor).

	^found
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveAsImplicitAttribute: variableName in: anAccessor [

	^(anAccessor allTypes flatCollect: [ :type | type attributes ])
		select: [ :entity | entity name = variableName ]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveAsLocalVariable: variableName in: anAccessor [

	^anAccessor allLocalVariables
		select: [ :entity | entity name = variableName ]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveAttributeAccess: anAccess forPointer: aPointerVariable [
	"resolve access to a segment attribute"

	| variableAccessed |
	variableAccessed := anAccess getAndRemoveAttribute: #entity.
	self assert: variableAccessed isNotNil.

	aPointerVariable declaredType attributes
		detect: [ :att | att name = variableAccessed entityName ]
		ifFound: [ :att | anAccess variable: att ].

]

{ #category : 'run' }
FamixEsopeResolver >> resolveDeclaredTypeOfPointers [
	"sets the declaredType of pointers"

	(self model allWithSubTypesOf: FamixF77Variable) 
		do: [ :var | 
			var isEsope ifTrue: [ self resolveEsopeVariable: var ]
		].

	(self model allWithSubTypesOf: FamixEsopeCommand) 
		do: [ :cmd | 
			(cmd variable declaredType isEsopeSegment)  
				ifFalse: [
					cmd variable attributeAt: #segmentName put: nil.
					self resolveEsopeVariable: cmd variable
				]
		].
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveEsopeVariable: aFamixVariable [
	"sets the declaredType of pointer esopeVariable"

	| allSegments segment segmentName |

	allSegments := self model allWithType: FamixEsopeSegment.
	segmentName := aFamixVariable segment
		ifNil: [ aFamixVariable name ]
		ifNotNil: [ :declaredSegmentName | declaredSegmentName ].

	segment := allSegments
		detect: [ :seg | seg name = segmentName ]
		ifNone: [ self model newSegment
			name: segmentName ;
			isStub: true ;
			yourself
		].

	aFamixVariable declaredType: segment.
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveImplicitFunctionType: function [

	function declaredType ifNotNil: [ ^self ].
	
	function declaredType:
		(self resolveTypeName:
			(function implicitTypeFor: function name)).

]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveImplicitVariableType: aVariable [
	"Tries to guess the type of an implicitly defined variable
	 - can be a pointer to an Esope segment
	 - otherwise uses the implicits declaration of its owner"

	^self resolveTypeName:
		(aVariable parentBehaviouralEntity
			implicitTypeFor: aVariable name)

]

{ #category : 'run' }
FamixEsopeResolver >> resolveImplicits [
	"put a declaredType based on IMPLICIT declarations for all variables with no declaredType"

	(model allWithType: FamixF77Parameter) do: [ :param |
		self setImplicitDeclaredType: param in: param parentBehaviouralEntity
	].

	(model allWithType: FamixF77Variable) do: [ :var |
		self setImplicitDeclaredType: var in: var parentBehaviouralEntity
	].

	(model allWithType: FamixF77StatementFunction) do: [ :func |
		self setImplicitDeclaredType: func in: func parentEntity
	].

	(model allWithType: FamixF77PUFunction) do: [ :func |
		self setImplicitDeclaredType: func in: func
	] 

]

{ #category : 'run' }
FamixEsopeResolver >> resolveIncludes [
	"links FamixF77IncludedFile with the FamixF77Include_s that concern them"

	(self model allWithType: FamixF77Include) 
	do: [ :include |
		(self model allWithType: FamixF77IncludedFile)
			detect: [ :includedFile |
				includedFile programFile filename asPath basename beginsWith: include filename ]
			ifFound: [ :includedFile | include included: includedFile ]
			ifNone: [ Notification signal: ' no such file ' , include filename ]
	]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveInvocables: invocable [
	^(model allWithSubTypesOf: FamixF77PUProcedure)
		detect: [ :entity | 
			(entity name = invocable entityName)
				"and: [ entity parameters size = (invocable arguments ifNil: [ #() ]) size ]"
		]
		ifFound: [ :entity | entity ]
		ifNone: [ nil ]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveInvocation: anInvocation [

	| invocated |

	invocated := anInvocation getAndRemoveAttribute: #entity .

	(self resolveInvocables: invocated)
		ifNotNil: [ :invocatedFound | anInvocation addCandidate: invocatedFound ]
		ifNil: [ (self isIntrinsicRoutine: invocated)
			ifTrue: [ anInvocation addCandidate: (model newIntrinsicRoutine name: invocated entityName) ] ]
]

{ #category : 'run' }
FamixEsopeResolver >> resolveInvocations [

	(self model allWithType: FamixF77Invocation) do: [ :invocation |
		self errorHandler enterContext: ('invocation: ' , invocation signature).
		self resolveInvocation: invocation.
		self errorHandler leaveContext
	]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveTypeName: aName [
	"Finds a FamixType from its name"

	self flag: 'should test the referring PU (ex: for an included segment)'.

	^(self model allWithSubTypesOf: FamixF77Type)
		detect: [ :type | type name = aName ]
		ifNone: [ self model newTypeUnknown ]
]

{ #category : 'symbols resolution' }
FamixEsopeResolver >> resolveVariableNamed: variableName in: accessor [
	| found |
	found := self resolveAllVariablesNamed: variableName in: accessor.

	(found size > 1) ifTrue: [ Exception signal: 'several variables named "', variableName , '" in "' , accessor name , '"' ].
	(found size = 1) ifTrue: [ ^found anyOne ].

	^nil
]

{ #category : 'run' }
FamixEsopeResolver >> resolvingSteps [

	^ #(
		#resolveIncludes
		#registerImplicitsDeclarations
		#requalifyVariableDeclarations

		#resolveAccesses
		#resolveImplicits
		#resolveDeclaredTypeOfPointers
	 	#resolveInvocations
	)

	"#propagatePointerType"

]

{ #category : 'run' }
FamixEsopeResolver >> setImplicitDeclaredType: anEntity in: owner [
	"put a declaredType to anEntity based on IMPLICIT declarations in owner
	 Note: implicit types are intrinsic types so we could simplify the use of #resolveTypeName:
	 (which looks in all the types)"

	anEntity declaredType
		ifNil: [
			anEntity declaredType: 
				(self resolveTypeName:
					(owner implicitTypeFor: anEntity name))
		]

]

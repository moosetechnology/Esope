Extension { #name : 'FamixF77ProgramUnit' }

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> allDeclaredTypesInMyScope [
	"returns all types declared directly in receiver or in the files it includes"

	| return |
	return := Set new.
	return addAll: self types.
	self includes do: [ :inclusion |
		inclusion included
			ifNotNil: [ :includedFile | return addAll: includedFile allDeclaredTypesInMyScope  ]
	].

	^return asOrderedCollection
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> allLocalVariables [

	^self localVariables
	  ,
	(self includes
		flatCollect: [ :include | 
			include included
				ifNil: [#()]
				ifNotNil: [ :included | included localVariables ]
		]
	)
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> createUnresolveVariable: variableName with: resolver isParameterDefinition: isParameterDefinition [
	"If the variable could not be resolved within an access, it means it is a use of an
	 implicit variable
	 - create a LocalVariable within receiver
	 - tries to set the declaredType to something meaningfull"

	| implicitVariable |

	implicitVariable := mooseModel newVariable
		name: variableName ;
		parentBehaviouralEntity: self ;
		yourself.

	implicitVariable declaredType:
		(resolver resolveImplicitVariableType: implicitVariable).

	^implicitVariable

]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> defaultImplicit [

	^ (($a to: $z) collect: [ :char | 
		   ('ijklmn' includes: char)
			   ifTrue:  [ char -> #integer ]
			   ifFalse: [ char -> #real ] ]) asDictionary

]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: programFile isNotNil description: name , ' without parent ProgramFile'.
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> implicitDictionary [

	^ self attributeAt: #implicitDictionary ifAbsentPut: [ self defaultImplicit ]
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> implicitFortranTypeFor: variableName [

	self implicitDictionary
		at: variableName first
		ifPresent: [ :typeName | ^typeName ].

	^nil
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> implicitSegmentTypeFor: variableName [

	self implicitDictionary
		at: variableName
		ifPresent: [ :typeName | ^typeName ].

	^nil
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> implicitTypeFor: variableName [
	"find a type according to the first letter of the variable's name
	 - first search for a segment with that (full) name
	 - then search for a Fortran type from the first letter"

	(self implicitSegmentTypeFor: variableName)
		ifNotNil: [ :typeName | ^typeName ].

	(self implicitFortranTypeFor: variableName)
		ifNotNil: [ :typeName | ^typeName ].

	^FamixF77TypeUnknown defaultName
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> implicits [

	^ self attributeAt: #implicits ifAbsent: [ #() ]
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> localVariableClass [

	^FamixF77Variable
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> registerImplicit: iASTTypeRef range: aRange [
	"for letters in aRange register in receiver's implicit dictionary the corresponding iASTTypeRef"

	(aRange size = 1)
	ifTrue: [ self implicitDictionary
		at: aRange first
		put: iASTTypeRef entityName asSymbol ]
	ifFalse: [ 
		(aRange first to: aRange second) do: [ :letter |
			self implicitDictionary 
				at: letter
				put: iASTTypeRef entityName asSymbol
		]
	]
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> registerImplicitSegment: famixType [
	"registers in the receiver's implicit dictionary the famixType (which should be an EsopeSegment)
	 If the segment's name is one character, it could be confused for a Fortran IMPLICIT declaration"

	self assert: famixType name size > 1.

	self implicitDictionary
		at: famixType name
		put: famixType name

]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> registerImplicits [
	"find all IMPLICIT declaration statement in receiver and register them
	 in its implicitDictionary
	 Additionnally records all segment declared in the receiver (for implicit pointers)"

	(self attributeAt: #implicits ifAbsent: [ #() ])
	do: [ :implicitDeclaration | 
		implicitDeclaration ranges
			ifNotNil: [ :ranges |
				ranges do: [ :aRange | 
					self
						registerImplicit: implicitDeclaration forType
						range: aRange ] ]
			ifNil: [ "implicit none"
				self removeFortranImplicits ]
	].

	(self allDeclaredTypesInMyScope) do: [ :famixType |
		(famixType isEsopeSegment) 
		ifTrue: [ self registerImplicitSegment: famixType ]
	]

]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> removeFortranImplicits [
	"Removes allimplicit declaration for Fortran type
    They are recognized because the key is a letter, not a string"

	self implicitDictionary copy associationsDo: [ :association |
		association key isCharacter
			ifTrue: [ self implicitDictionary removeKey: association key ] ]
]

{ #category : '*EsopeImporter' }
FamixF77ProgramUnit >> symbolTable [
self flag: 'TO REMOVE?'.

	^ self attributeAt: #symbolTable ifAbsentPut: [ Dictionary new ]
]

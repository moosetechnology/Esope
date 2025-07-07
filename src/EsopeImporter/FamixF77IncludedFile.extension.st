Extension { #name : 'FamixF77IncludedFile' }

{ #category : '*EsopeImporter' }
FamixF77IncludedFile >> allTypes [

	"empty collection because members of included files are treated by the including files"

	^#()
]

{ #category : '*EsopeImporter' }
FamixF77IncludedFile >> createUnresolveVariable: variableName with: resolver isParameterDefinition: isParameterDefinition [
	"If a variable was not resolved within the IncludedFile, it means it depends on
	 its includer to define this variable.
	 Therefore we return an UnknownVariable"

	| variable |

	^isParameterDefinition 
		ifTrue: [
			variable := mooseModel newVariable
				name: variableName ;
				parentBehaviouralEntity: self ;
				yourself.

			variable declaredType:
				(resolver resolveImplicitVariableType: variable) ;
				yourself
		]
		ifFalse: [ mooseModel newUnknownVariableNamed: variableName ]

]

{ #category : '*EsopeImporter' }
FamixF77IncludedFile >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: inclusions isNotEmpty description: 'IncludedFile without inclusions'.
]

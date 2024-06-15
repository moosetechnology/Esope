Extension { #name : #FamixF77ProgramUnit }

{ #category : #'*EsopeImporter' }
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

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> createUnresolveVariable: variableName with: resolver [

	| implicitVariable |

	implicitVariable := mooseModel newVariable
		name: variableName ;
		parentBehaviouralEntity: self ;
		yourself.

	implicitVariable declaredType:
		(resolver resolveImplicitVariableType: implicitVariable).

	^implicitVariable

]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> defaultImplicit [

	^ (($a to: $z) collect: [ :char | 
		   ('ijklmn' includes: char)
			   ifTrue:  [ char -> #integer ]
			   ifFalse: [ char -> #real ] ]) asDictionary

]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> famixImportSanityCheck [

	self assert: programFile isNotNil description: 'ProgramUnit without parent ProgramFile'.
]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> implicitDictionary [

	^ self attributeAt: #implicitDictionary ifAbsentPut: [ self defaultImplicit ]
]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> implicits [

	^ self attributeAt: #implicits ifAbsent: [ #() ]
]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> isInvocable [

	^false
]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> isSubroutine [

	^false
]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> localVariableClass [

	^FamixF77Variable
]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> resolveVariable: variableName with: resolver [

	^(resolver resolveVariableNamed: variableName in: self)
		ifNotNil: [ :localVar | localVar ]
		ifNil: [ self createUnresolveVariable: variableName with: resolver ]

]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> symbolTable [

	^ self attributeAt: #symbolTable ifAbsentPut: [ Dictionary new ]
]

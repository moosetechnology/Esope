Extension { #name : #FamixF77ProgramUnit }

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> defaultImplicit [

	^ (($a to: $z) collect: [ :char | 
		   ('ijklmn' includes: char)
			   ifTrue:  [ char -> #integer ]
			   ifFalse: [ char -> #real ] ]) asDictionary

]

{ #category : #'*EsopeImporter' }
FamixF77ProgramUnit >> dicImplicit [

	^ self attributeAt: #dicImplicit ifAbsentPut: [ self defaultImplicit ]
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
FamixF77ProgramUnit >> symbolTable [

	^ self attributeAt: #symbolTable ifAbsentPut: [ Dictionary new ]
]

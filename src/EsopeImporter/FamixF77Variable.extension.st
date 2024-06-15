Extension { #name : #FamixF77Variable }

{ #category : #'*EsopeImporter' }
FamixF77Variable >> famixImportSanityCheck [

	self assert: parentBehaviouralEntity isNotNil description: 'Variable without parentBehaviouralEntity'.
	self assert: declaredType isNotNil description: 'Variable without declaredType'.
]

{ #category : #'*EsopeImporter' }
FamixF77Variable >> segment [

	^self attributeAt: #segmentName ifAbsent: [ nil ]
]

{ #category : #'*EsopeImporter' }
FamixF77Variable >> segment: aString [

	^self attributeAt: #segmentName put: aString
]

Extension { #name : 'FamixF77Variable' }

{ #category : '*EsopeImporter' }
FamixF77Variable >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: parentBehaviouralEntity isNotNil description: 'Variable ', name , ' without parentBehaviouralEntity'.
	self sanityCheck: typing isNotNil description: 'Variable ', name , ' without declaredType'.
]

{ #category : '*EsopeImporter' }
FamixF77Variable >> segment [

	^self attributeAt: #segmentName ifAbsent: [ nil ]
]

{ #category : '*EsopeImporter' }
FamixF77Variable >> segment: aString [

	^self attributeAt: #segmentName put: aString
]

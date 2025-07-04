Extension { #name : 'FamixF77StructuralEntity' }

{ #category : '*EsopeImporter' }
FamixF77StructuralEntity >> segment [

	^self attributeAt: #segmentName ifAbsent: [ nil ]
]

{ #category : '*EsopeImporter' }
FamixF77StructuralEntity >> segment: aString [

	^self attributeAt: #segmentName put: aString
]

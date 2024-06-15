Extension { #name : #MooseObject }

{ #category : #'*EsopeImporter' }
MooseObject >> removeAttributeAt: aSymbol [

	| value |
	value := self attributeAt: aSymbol ifAbsent: [ nil ].

	self removeAttribute: aSymbol.

	^value
]

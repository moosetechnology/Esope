Extension { #name : 'MooseObject' }

{ #category : '*EsopeImporter' }
MooseObject >> getAndRemoveAttribute: aSymbol [

	| value |
	value := self attributeAt: aSymbol ifAbsent: [ nil ].

	self removeAttribute: aSymbol.

	^value
]

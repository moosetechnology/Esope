Extension { #name : 'FASTFortranTDeclaredType' }

{ #category : '*FAST-Esope-Entities-accessing' }
FASTFortranTDeclaredType >> pointeur [
	"Relation named: #pointeur type: #FASTEsopePointeur opposite: #declaredType"

	<generated>
	<derived>
	<FMProperty: #pointeur type: #FASTEsopePointeur opposite: #declaredType>
	<package: #'FAST-Esope-Entities'>
	^ self attributeAt: #pointeur ifAbsent: [ nil ]
]

{ #category : '*FAST-Esope-Entities-accessing' }
FASTFortranTDeclaredType >> pointeur: anObject [

	<generated>
	(self attributeAt: #pointeur ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self pointeur.
		self attributeAt: #pointeur put: anObject.
		otherSide declaredType: nil ]
	ifNotNil: [ 
		self attributeAt: #pointeur put: anObject.
		anObject declaredType: self ]
]

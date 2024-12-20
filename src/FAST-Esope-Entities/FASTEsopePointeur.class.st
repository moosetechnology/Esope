"
pointeur p1.SEG, p2.OTHER_SEG, ..., pN.SEG with N=1, 2, 3,...

## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `declaredType` | `FASTEsopePointeur` | `pointeur` | `FASTFortranTDeclaredType` | |
| `esopeCommand` | `FASTEsopePointeur` | `pointeurs` | `FASTEsopeEsopeCommand` | |



"
Class {
	#name : 'FASTEsopePointeur',
	#superclass : 'FASTEsopeEntity',
	#instVars : [
		'#esopeCommand => FMOne type: #FASTEsopeEsopeCommand opposite: #pointeurs'
	],
	#category : 'FAST-Esope-Entities-Entities',
	#package : 'FAST-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FASTEsopePointeur class >> annotation [

	<FMClass: #Pointeur super: #FASTEsopeEntity>
	<package: #'FAST-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FASTEsopePointeur >> declaredType [
	"Relation named: #declaredType type: #FASTFortranTDeclaredType opposite: #pointeur"

	<generated>
	<FMProperty: #declaredType type: #FASTFortranTDeclaredType opposite: #pointeur>
	^ self attributeAt: #declaredType ifAbsent: [ nil ]
]

{ #category : 'accessing' }
FASTEsopePointeur >> declaredType: anObject [

	<generated>
	(self attributeAt: #declaredType ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self declaredType.
		self attributeAt: #declaredType put: anObject.
		otherSide pointeur: nil ]
	ifNotNil: [ 
		self attributeAt: #declaredType put: anObject.
		anObject pointeur: self ]
]

{ #category : 'accessing' }
FASTEsopePointeur >> esopeCommand [
	"Relation named: #esopeCommand type: #FASTEsopeEsopeCommand opposite: #pointeurs"

	<generated>
	^ esopeCommand
]

{ #category : 'accessing' }
FASTEsopePointeur >> esopeCommand: anObject [

	<generated>
	esopeCommand := anObject
]

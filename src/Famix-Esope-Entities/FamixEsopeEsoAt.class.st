Class {
	#name : #FamixEsopeEsoAt,
	#superclass : #FamixEsopeEsoTransformation,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeEsoAt class >> annotation [

	<FMClass: #EsoAt super: #FamixEsopeEsoTransformation>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #meta }
FamixEsopeEsoAt class >> newFromFortranFunction: aFortranFunction [

	^ (super newFromFortranFunction: aFortranFunction) yourself
]

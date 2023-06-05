Class {
	#name : #FamixEsopeEsoAr,
	#superclass : #FamixEsopeEsoTransformation,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeEsoAr class >> annotation [

	<FMClass: #EsoAr super: #FamixEsopeEsoTransformation>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #'private - utility' }
FamixEsopeEsoAr class >> newFromFortranFunction: aFortranFunction [

	^ (super newFromFortranFunction: aFortranFunction) yourself
]

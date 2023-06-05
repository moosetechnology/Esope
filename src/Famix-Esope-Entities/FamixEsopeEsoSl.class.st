Class {
	#name : #FamixEsopeEsoSl,
	#superclass : #FamixEsopeEsoTransformation,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeEsoSl class >> annotation [

	<FMClass: #EsoSl super: #FamixEsopeEsoTransformation>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #meta }
FamixEsopeEsoSl class >> newFromFortranFunction: aFortranFunction [

	^ (super newFromFortranFunction: aFortranFunction) yourself
]

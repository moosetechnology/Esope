Class {
	#name : #FamixEsopeModel,
	#superclass : #MooseModel,
	#traits : 'FamixEsopeTEntityCreator + FamixFortran77TEntityCreator',
	#classTraits : 'FamixEsopeTEntityCreator classTrait + FamixFortran77TEntityCreator classTrait',
	#category : #'Famix-Esope-Entities-Model'
}

{ #category : #accessing }
FamixEsopeModel class >> allSubmetamodelsPackagesNames [
	<generated>
	^ #(#'Moose-Query' #'Famix-Traits' #'Famix-Fortran77-Entities')
]

{ #category : #meta }
FamixEsopeModel class >> annotation [
	<FMClass: #FamixEsopeModel super: #MooseModel>
	<package: #'Famix-Esope-Entities'>
	<generated>
]

{ #category : #testing }
FamixEsopeModel class >> canBeImportedFromFile [
	<generated>
	^true
]

{ #category : #accessing }
FamixEsopeModel class >> importingContextClass [

	<generated>
	^ FamixEsopeImportingContext
]

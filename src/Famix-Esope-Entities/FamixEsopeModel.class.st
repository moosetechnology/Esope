Class {
	#name : #FamixEsopeModel,
	#superclass : #MooseModel,
	#traits : 'FamixEsopeTEntityCreator + FamixF77TEntityCreator + FamixFortranTEntityCreator',
	#classTraits : 'FamixEsopeTEntityCreator classTrait + FamixF77TEntityCreator classTrait + FamixFortranTEntityCreator classTrait',
	#category : #'Famix-Esope-Entities-Model'
}

{ #category : #accessing }
FamixEsopeModel class >> allSubmetamodelsPackagesNames [
	<generated>
	^ #(#'Moose-Query' #'Famix-Traits' #'Famix-FortranUDT-Entities' #'Famix-Fortran77-Entities')
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

{ #category : #initialization }
FamixEsopeModel >> initialize [

	super initialize.
	self name: 'EsopeMooseModel'.
	self attributeAt: #instrinsicTypes put: self intrinsicTypes.
	self attributeAt: #unknownType put: [ self newTypeUnknown ]
]

{ #category : #'entity creation' }
FamixEsopeModel >> intrinsicTypes [

	^ {
		  (#integer -> (self newTypeIntrinsic name: #integer)).
		  (#real -> (self newTypeIntrinsic name: #real)).
		  (#complex -> (self newTypeIntrinsic name: #complex)).
		  (#logical -> (self newTypeIntrinsic name: #logical)).
		  (#character -> (self newTypeIntrinsic name: #character)) }
		  asDictionary
]

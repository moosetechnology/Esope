Class {
	#name : #FamixEsopeEntity,
	#superclass : #MooseEntity,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeEntity class >> annotation [

	<FMClass: #Entity super: #MooseEntity>
	<package: #'Famix-Esope-Entities'>
	<generated>
	<abstract>
	^ self
]

{ #category : #'private - utility' }
FamixEsopeEntity class >> getNameFrom: anEntity [

	self subclassResponsibility
]

{ #category : #'private - utility' }
FamixEsopeEntity class >> getNameFrom: aFortranComment without: aPrefix [

	^ (((aFortranComment removePrefix: #eso) trim removePrefix: aPrefix)
		  trim removePrefix: ',') trim
]

{ #category : #testing }
FamixEsopeEntity class >> isAbstract [

	<generated>
	^ self == FamixEsopeEntity
]

{ #category : #meta }
FamixEsopeEntity class >> metamodel [

	<generated>
	^ FamixEsopeModel metamodel
]

{ #category : #testing }
FamixEsopeEntity class >> newEntity: famixF77Entity [
	^self new
		  mooseModel: famixF77Entity mooseModel;
		  yourself
]

{ #category : #meta }
FamixEsopeEntity class >> newFromFortranComment: eComment [
	^self new
		  content: eComment;
		  yourself
]

{ #category : #'private - utility' }
FamixEsopeEntity class >> newFromFortranFunction: famixF77Entity [
	^self new
		  eEntity: famixF77Entity;
		  yourself
]

{ #category : #testing }
FamixEsopeEntity >> isAttribute [

	<generated>
	^ false
]

{ #category : #testing }
FamixEsopeEntity >> isStructuralEntity [

	<generated>
	^ false
]

{ #category : #testing }
FamixEsopeEntity >> isType [

	<generated>
	^ false
]

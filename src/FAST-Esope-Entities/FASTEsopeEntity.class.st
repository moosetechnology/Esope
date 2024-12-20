Class {
	#name : 'FASTEsopeEntity',
	#superclass : 'MooseEntity',
	#category : 'FAST-Esope-Entities-Entities',
	#package : 'FAST-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FASTEsopeEntity class >> annotation [

	<FMClass: #Entity super: #MooseEntity>
	<package: #'FAST-Esope-Entities'>
	<generated>
	<abstract>
	^ self
]

{ #category : 'testing' }
FASTEsopeEntity class >> isAbstract [

	<generated>
	^ self == FASTEsopeEntity
]

{ #category : 'meta' }
FASTEsopeEntity class >> metamodel [

	<generated>
	^ FASTEsopeModel metamodel
]

{ #category : 'testing' }
FASTEsopeEntity >> isQueryable [

	<generated>
	^ false
]

{ #category : 'testing' }
FASTEsopeEntity >> isStatement [

	<generated>
	^ false
]

{ #category : 'testing' }
FASTEsopeEntity >> isStatementBlock [

	<generated>
	^ false
]

{ #category : 'testing' }
FASTEsopeEntity >> isType [

	<generated>
	^ false
]

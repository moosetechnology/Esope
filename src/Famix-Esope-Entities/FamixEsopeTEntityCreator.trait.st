"
This trait is used by Famix models.
It provides an API for creating entities and adding them to the model.


"
Trait {
	#name : #FamixEsopeTEntityCreator,
	#category : #'Famix-Esope-Entities-Model'
}

{ #category : #meta }
FamixEsopeTEntityCreator classSide >> annotation [

	<FMClass: #TEntityCreator super: #Object>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newCommand [

	<generated>
	^ self add: FamixEsopeCommand new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newDimentionalInteger [

	<generated>
	^ self add: FamixEsopeDimentionalInteger new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newImplicitPointer [

	<generated>
	^ self add: FamixEsopeImplicitPointer new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegment [

	<generated>
	^ self add: FamixEsopeSegment new
]

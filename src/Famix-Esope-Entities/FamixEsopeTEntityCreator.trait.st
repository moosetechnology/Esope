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
FamixEsopeTEntityCreator >> newImplicitPointer [

	<generated>
	^ self add: FamixEsopeImplicitPointer new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegact [

	<generated>
	^ self add: FamixEsopeSegact new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegadj [

	<generated>
	^ self add: FamixEsopeSegadj new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegdes [

	<generated>
	^ self add: FamixEsopeSegdes new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegini [

	<generated>
	^ self add: FamixEsopeSegini new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegment [

	<generated>
	^ self add: FamixEsopeSegment new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegprt [

	<generated>
	^ self add: FamixEsopeSegprt new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegsup [

	<generated>
	^ self add: FamixEsopeSegsup new
]

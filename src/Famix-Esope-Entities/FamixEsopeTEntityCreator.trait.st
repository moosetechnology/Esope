"
This trait is used by Famix models.
It provides an API for creating entities and adding them to the model.


"
Trait {
	#name : 'FamixEsopeTEntityCreator',
	#category : 'Famix-Esope-Entities-Model',
	#package : 'Famix-Esope-Entities',
	#tag : 'Model'
}

{ #category : 'meta' }
FamixEsopeTEntityCreator classSide >> annotation [

	<FMClass: #TEntityCreator super: #Object>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newCommandSegact [

	<generated>
	^ self add: FamixEsopeCommandSegact new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newCommandSegadj [

	<generated>
	^ self add: FamixEsopeCommandSegadj new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newCommandSegcop [

	<generated>
	^ self add: FamixEsopeCommandSegcop new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newCommandSegdes [

	<generated>
	^ self add: FamixEsopeCommandSegdes new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newCommandSegini [

	<generated>
	^ self add: FamixEsopeCommandSegini new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newCommandSegmov [

	<generated>
	^ self add: FamixEsopeCommandSegmov new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newCommandSegprt [

	<generated>
	^ self add: FamixEsopeCommandSegprt new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newCommandSegsup [

	<generated>
	^ self add: FamixEsopeCommandSegsup new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newImplicitPointer [

	<generated>
	^ self add: FamixEsopeImplicitPointer new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newIntrinsicProcedure [

	<generated>
	^ self add: FamixEsopeIntrinsicProcedure new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newPointer [

	<generated>
	^ self add: FamixEsopePointer new
]

{ #category : 'entity creation' }
FamixEsopeTEntityCreator >> newSegment [

	<generated>
	^ self add: FamixEsopeSegment new
]

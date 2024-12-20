"
This trait is used by Famix models.
It provides an API for creating entities and adding them to the model.


"
Trait {
	#name : 'FASTEsopeTEntityCreator',
	#category : 'FAST-Esope-Entities-Model',
	#package : 'FAST-Esope-Entities',
	#tag : 'Model'
}

{ #category : 'meta' }
FASTEsopeTEntityCreator classSide >> annotation [

	<FMClass: #TEntityCreator super: #Object>
	<package: #'FAST-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newDimensionOperator [

	<generated>
	^ self add: FASTEsopeDimensionOperator new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newEsopeCommand [

	<generated>
	^ self add: FASTEsopeEsopeCommand new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newPointeur [

	<generated>
	^ self add: FASTEsopePointeur new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegact [

	<generated>
	^ self add: FASTEsopeSegact new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegadj [

	<generated>
	^ self add: FASTEsopeSegadj new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegcop [

	<generated>
	^ self add: FASTEsopeSegcop new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegdes [

	<generated>
	^ self add: FASTEsopeSegdes new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegini [

	<generated>
	^ self add: FASTEsopeSegini new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegmenntAttribute [

	<generated>
	^ self add: FASTEsopeSegmenntAttribute new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegment [

	<generated>
	^ self add: FASTEsopeSegment new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegmentNamed: aName [

	<generated>
	^ self add: (FASTEsopeSegment named: aName)
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegmov [

	<generated>
	^ self add: FASTEsopeSegmov new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegprt [

	<generated>
	^ self add: FASTEsopeSegprt new
]

{ #category : 'entity creation' }
FASTEsopeTEntityCreator >> newSegsup [

	<generated>
	^ self add: FASTEsopeSegsup new
]

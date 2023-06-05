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
FamixEsopeTEntityCreator >> newAttribute [

	<generated>
	^ self add: FamixEsopeAttribute new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newAttributeNamed: aName [

	<generated>
	^ self add: (FamixEsopeAttribute named: aName)
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newEsoAr [

	<generated>
	^ self add: FamixEsopeEsoAr new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newEsoAt [

	<generated>
	^ self add: FamixEsopeEsoAt new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newEsoSl [

	<generated>
	^ self add: FamixEsopeEsoSl new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newEsoTransformation [

	<generated>
	^ self add: FamixEsopeEsoTransformation new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newFortranVariable [

	<generated>
	^ self add: FamixEsopeFortranVariable new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newFortranVariableNamed: aName [

	<generated>
	^ self add: (FamixEsopeFortranVariable named: aName)
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newImplicitPointer [

	<generated>
	^ self add: FamixEsopeImplicitPointer new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newParameter [

	<generated>
	^ self add: FamixEsopeParameter new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newPointer [

	<generated>
	^ self add: FamixEsopePointer new
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
FamixEsopeTEntityCreator >> newSegmentCommand [

	<generated>
	^ self add: FamixEsopeSegmentCommand new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegmentCommandNamed: aName [

	<generated>
	^ self add: (FamixEsopeSegmentCommand named: aName)
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegmentNamed: aName [

	<generated>
	^ self add: (FamixEsopeSegment named: aName)
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newSegsup [

	<generated>
	^ self add: FamixEsopeSegsup new
]

{ #category : #'entity creation' }
FamixEsopeTEntityCreator >> newUnknown [

	<generated>
	^ self add: FamixEsopeUnknown new
]

"
This class is used to choose the entities to be imported when loading a model from file.
It is used by `MiImportingContextPresenter` in a `MiImportModelFromFileDialog` to import a FamixEsopeModel.
"
Class {
	#name : 'FamixEsopeImportingContext',
	#superclass : 'FamixImportingContext',
	#category : 'Famix-Esope-Entities-Import',
	#package : 'Famix-Esope-Entities',
	#tag : 'Import'
}

{ #category : 'accessing' }
FamixEsopeImportingContext class >> importedMetamodel [

	<generated>
	^ FamixEsopeModel metamodel
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importCommand [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Command)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importCommandSegact [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #CommandSegact)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importCommandSegadj [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #CommandSegadj)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importCommandSegdes [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #CommandSegdes)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importCommandSegini [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #CommandSegini)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importCommandSegprt [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #CommandSegprt)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importCommandSegsup [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #CommandSegsup)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importImplicitPointer [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #ImplicitPointer)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importIntrinsicProcedure [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #IntrinsicProcedure)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importPointer [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Pointer)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importSegment [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segment)
]

{ #category : 'importing' }
FamixEsopeImportingContext >> importSegmentParameter [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #SegmentParameter)
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportCommand [

	<generated>
	^ self shouldImport: #Command
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportCommandSegact [

	<generated>
	^ self shouldImport: #CommandSegact
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportCommandSegadj [

	<generated>
	^ self shouldImport: #CommandSegadj
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportCommandSegdes [

	<generated>
	^ self shouldImport: #CommandSegdes
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportCommandSegini [

	<generated>
	^ self shouldImport: #CommandSegini
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportCommandSegprt [

	<generated>
	^ self shouldImport: #CommandSegprt
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportCommandSegsup [

	<generated>
	^ self shouldImport: #CommandSegsup
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportImplicitPointer [

	<generated>
	^ self shouldImport: #ImplicitPointer
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportIntrinsicProcedure [

	<generated>
	^ self shouldImport: #IntrinsicProcedure
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportPointer [

	<generated>
	^ self shouldImport: #Pointer
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportSegment [

	<generated>
	^ self shouldImport: #Segment
]

{ #category : 'testing' }
FamixEsopeImportingContext >> shouldImportSegmentParameter [

	<generated>
	^ self shouldImport: #SegmentParameter
]

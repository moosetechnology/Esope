"
This class is used to choose the entities to be imported when loading a model from file.
It is used by `MiImportingContextPresenter` in a `MiImportModelFromFileDialog` to import a FamixEsopeModel.
"
Class {
	#name : #FamixEsopeImportingContext,
	#superclass : #FamixImportingContext,
	#category : #'Famix-Esope-Entities-Import'
}

{ #category : #accessing }
FamixEsopeImportingContext class >> importedMetamodel [

	<generated>
	^ FamixEsopeModel metamodel
]

{ #category : #importing }
FamixEsopeImportingContext >> importAttribute [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Attribute)
]

{ #category : #importing }
FamixEsopeImportingContext >> importEsoAr [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #EsoAr)
]

{ #category : #importing }
FamixEsopeImportingContext >> importEsoAt [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #EsoAt)
]

{ #category : #importing }
FamixEsopeImportingContext >> importEsoSl [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #EsoSl)
]

{ #category : #importing }
FamixEsopeImportingContext >> importEsoTransformation [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #EsoTransformation)
]

{ #category : #importing }
FamixEsopeImportingContext >> importFortranVariable [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #FortranVariable)
]

{ #category : #importing }
FamixEsopeImportingContext >> importImplicitPointer [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #ImplicitPointer)
]

{ #category : #importing }
FamixEsopeImportingContext >> importParameter [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Parameter)
]

{ #category : #importing }
FamixEsopeImportingContext >> importPointer [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Pointer)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegact [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segact)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegadj [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segadj)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegdes [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segdes)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegini [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segini)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegment [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segment)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegmentCommand [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #SegmentCommand)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegsup [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segsup)
]

{ #category : #importing }
FamixEsopeImportingContext >> importUnknown [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Unknown)
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportAttribute [

	<generated>
	^ self shouldImport: #Attribute
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportEsoAr [

	<generated>
	^ self shouldImport: #EsoAr
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportEsoAt [

	<generated>
	^ self shouldImport: #EsoAt
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportEsoSl [

	<generated>
	^ self shouldImport: #EsoSl
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportEsoTransformation [

	<generated>
	^ self shouldImport: #EsoTransformation
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportFortranVariable [

	<generated>
	^ self shouldImport: #FortranVariable
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportImplicitPointer [

	<generated>
	^ self shouldImport: #ImplicitPointer
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportParameter [

	<generated>
	^ self shouldImport: #Parameter
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportPointer [

	<generated>
	^ self shouldImport: #Pointer
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegact [

	<generated>
	^ self shouldImport: #Segact
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegadj [

	<generated>
	^ self shouldImport: #Segadj
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegdes [

	<generated>
	^ self shouldImport: #Segdes
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegini [

	<generated>
	^ self shouldImport: #Segini
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegment [

	<generated>
	^ self shouldImport: #Segment
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegmentCommand [

	<generated>
	^ self shouldImport: #SegmentCommand
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegsup [

	<generated>
	^ self shouldImport: #Segsup
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportUnknown [

	<generated>
	^ self shouldImport: #Unknown
]

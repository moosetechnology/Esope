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
FamixEsopeImportingContext >> importCommand [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Command)
]

{ #category : #importing }
FamixEsopeImportingContext >> importImplicitPointer [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #ImplicitPointer)
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
FamixEsopeImportingContext >> importSegprt [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segprt)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegsup [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segsup)
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportAttribute [

	<generated>
	^ self shouldImport: #Attribute
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportCommand [

	<generated>
	^ self shouldImport: #Command
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportImplicitPointer [

	<generated>
	^ self shouldImport: #ImplicitPointer
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
FamixEsopeImportingContext >> shouldImportSegprt [

	<generated>
	^ self shouldImport: #Segprt
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegsup [

	<generated>
	^ self shouldImport: #Segsup
]

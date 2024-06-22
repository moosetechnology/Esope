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
FamixEsopeImportingContext >> importCommand [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Command)
]

{ #category : #importing }
FamixEsopeImportingContext >> importDimentionalInteger [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #DimentionalInteger)
]

{ #category : #importing }
FamixEsopeImportingContext >> importImplicitPointer [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #ImplicitPointer)
]

{ #category : #importing }
FamixEsopeImportingContext >> importSegment [

	<generated>
	^ self importConcreteEntity: (self class fm3ClassNamed: #Segment)
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportCommand [

	<generated>
	^ self shouldImport: #Command
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportDimentionalInteger [

	<generated>
	^ self shouldImport: #DimentionalInteger
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportImplicitPointer [

	<generated>
	^ self shouldImport: #ImplicitPointer
]

{ #category : #testing }
FamixEsopeImportingContext >> shouldImportSegment [

	<generated>
	^ self shouldImport: #Segment
]

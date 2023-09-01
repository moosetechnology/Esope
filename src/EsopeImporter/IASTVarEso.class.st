Class {
	#name : #IASTVarEso,
	#superclass : #IASTVarAccess,
	#instVars : [
		'entities'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #'instance creation' }
IASTVarEso class >> newFrom: aString [
	self subclassesDo: [ :subclass |
		(subclass realName asLowercase endsWith: aString asLowercase)
		ifTrue: [ ^subclass new ]
	].
	NotYetImplemented signalFor: 'IASTVarEso subclass for: ' , aString
]

{ #category : #'instance creation' }
IASTVarEso class >> realName [
	self subclassResponsibility 
]

{ #category : #accessing }
IASTVarEso >> addEntities: aCollection [

	aCollection asCollection do: [ :element |
		(element class = IASTVarAccess and: [ element isAssigned not ]) ifTrue: [ 
			self entities add: element ] ]
]

{ #category : #accessing }
IASTVarEso >> addRefsEntities: aCollection [

	aCollection do: [ :element |
		(element class = IASTVarAccess or: [ 
			 element class inheritsFrom: IASTVarEso ]) ifTrue: [ 
			self entities add: element ] ]
]

{ #category : #accessing }
IASTVarEso >> arguments: aCollection [

	self entities: aCollection
]

{ #category : #accessing }
IASTVarEso >> entities [

	^ entities
]

{ #category : #accessing }
IASTVarEso >> entities: anObject [

	entities := anObject
]

{ #category : #accessing }
IASTVarEso >> initialize [

	super initialize.

	entities := OrderedCollection new.
]

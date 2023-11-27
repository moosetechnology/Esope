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

{ #category : #initialization }
IASTVarEso >> initialize [
	super initialize.

	entities := OrderedCollection new
]

{ #category : #testing }
IASTVarEso >> isVarAccess [
	^false
]

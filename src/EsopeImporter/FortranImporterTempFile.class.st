Class {
	#name : #FortranImporterTempFile,
	#superclass : #Object,
	#instVars : [
		'name',
		'srcFolder',
		'tempFile'
	],
	#category : #'EsopeImporter-Importer'
}

{ #category : #'instance creation' }
FortranImporterTempFile class >> on: aFileReference [

	^self new
		name: aFileReference basename ;
		srcFolder: aFileReference path ;
		yourself
]

{ #category : #testing }
FortranImporterTempFile >> matches: aFileReference [

	^self matchesName: aFileReference fullName
]

{ #category : #testing }
FortranImporterTempFile >> matchesName: aFilename [

	^self tempFile fullName = aFilename 
]

{ #category : #accessing }
FortranImporterTempFile >> name [

	^ name
]

{ #category : #accessing }
FortranImporterTempFile >> name: anObject [

	name := anObject
]

{ #category : #accessing }
FortranImporterTempFile >> srcFolder [

	^ srcFolder
]

{ #category : #accessing }
FortranImporterTempFile >> srcFolder: anObject [

	srcFolder := anObject
]

{ #category : #accessing }
FortranImporterTempFile >> tempFile [

	^ tempFile
]

{ #category : #accessing }
FortranImporterTempFile >> tempFile: anObject [

	tempFile := anObject
]

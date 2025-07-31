Class {
	#name : 'FamixEsopeImporter',
	#superclass : 'FamixFortranImporter',
	#category : 'EsopeImporter-Importer',
	#package : 'EsopeImporter',
	#tag : 'Importer'
}

{ #category : 'api' }
FamixEsopeImporter class >> onFile: aPathString [

	^super onSourceString: (PPEsopeRewriter onFile: aPathString)
]

{ #category : 'api' }
FamixEsopeImporter class >> onSourceString: aSourceString [

	^super onSourceString: (PPEsopeRewriter onSourceString: aSourceString)
]

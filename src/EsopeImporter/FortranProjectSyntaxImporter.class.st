Class {
	#name : #FortranProjectSyntaxImporter,
	#superclass : #FortranProjectImporter,
	#category : #'EsopeImporter-Importer'
}

{ #category : #accessing }
FortranProjectSyntaxImporter >> f77parser [

	^ '/Users/lsafina/Projects/Syntax/trunk/examples/j77/bin/f77.out -json'
]

{ #category : #accessing }
FortranProjectSyntaxImporter >> getJsonFor: sourceCode [
	"very ugly, but intented for temporary use.
	TO BE REMOVED"
	| fastSrcFile json |
	fastSrcFile := self defaultFASTSource.
	fastSrcFile writeStreamDo: [:stream |
		stream truncate.
		self preprocess: sourceCode to: stream.
		stream lf
	].
	
	self parseFortran77: fastSrcFile.
	
		json := (((self fortranFolderToASTFolder: fastSrcFile parent) / fastSrcFile basename) withExtension: 'f.json') contents.
		^Character space join: (json lines collect: #trimBoth)
]

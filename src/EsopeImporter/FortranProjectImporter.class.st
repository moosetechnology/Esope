"
Responsible to import an Esope project into a Famix model

To use:
```
model := FortranProjectImporter new
	srcFolder: '/path/to/Esope/source/files/' ;
	import.
```

This will import all files with a `*.E` (or `*.e`) extension + all included files (`*.inc`)
This is done in various steps (see `#import`):
- copy Esope files (`*.E`) in a temporary directory (`./Esope/`)
- create special Esope files for included files (in same directory `./Esope/`)
- convert Esope files to Fortran files by annotating Esope instruction (in `./Fortran/`)
- get AST of Fortran files into Json files (in `./AST/`)
- import AST into an intermediate representation
- convert intermediate representation to Famix
- resolve  symbols in Famix

"
Class {
	#name : #FortranProjectImporter,
	#superclass : #Object,
	#instVars : [
		'srcFolder',
		'famixModel',
		'iastmodel'
	],
	#category : #'EsopeImporter-Importer'
}

{ #category : #importing }
FortranProjectImporter class >> import [
	<script>
	^self new
		import
]

{ #category : #accessing }
FortranProjectImporter >> astFolder [
	^'Json'
]

{ #category : #private }
FortranProjectImporter >> copyEsopeFiles [
	self ensureEmptyFolder: self esopeFolder.

	(self srcFolder allChildrenMatching: '*.E') do: [ :esopeFile |
		esopeFile copyTo: (self fileReference: esopeFile into: self esopeFolder)
	]
]

{ #category : #private }
FortranProjectImporter >> ensureEmptyFolder: folderName [
	| fileReference |
	fileReference := folderName asFileReference.
	fileReference exists
		ifTrue: [ fileReference children copy do: [ :childFile | childFile delete ]  ]
		ifFalse: [ fileReference ensureCreateDirectory ]
]

{ #category : #private }
FortranProjectImporter >> ensureFolder: folderName [
	| fileReference |
	fileReference := folderName asFileReference.
	fileReference exists
		ifTrue: [ folderName  ]
		ifFalse: [ fileReference ensureCreateDirectory ]
]

{ #category : #accessing }
FortranProjectImporter >> esopeFolder [
	^'Esope'
]

{ #category : #private }
FortranProjectImporter >> esopeToFortran [

	self ensureEmptyFolder: self fortranFolder.

	(self esopeFolder asFileReference allFiles) do: [ :esopeFile || fortranFile |
		fortranFile := self 
				fileReference: (esopeFile withExtension: 'f')
				into: self fortranFolder.

		PPEsopeRewriter
			rewriteFrom: esopeFile
			to: fortranFile
		]
]

{ #category : #accessing }
FortranProjectImporter >> f77parser [

	^ '/home/anquetil/bin/fortran-src-extras serialize -t json -v77l encode'
]

{ #category : #private }
FortranProjectImporter >> famixResolve [

	(FamixFortran77Resolver on: famixModel)
		resolve
]

{ #category : #private }
FortranProjectImporter >> fileReference: aFileReference into: aFolderName [
	^aFolderName asFileReference / aFileReference basename
]

{ #category : #accessing }
FortranProjectImporter >> fortranFolder [
	^'Fortran'
]

{ #category : #private }
FortranProjectImporter >> fortranToJsonAST [

	self ensureEmptyFolder: self astFolder.

	(self fortranFolder asFileReference allFiles) do: [ :fortranFile || jsonFile |
		jsonFile := self 
				fileReference: (fortranFile withoutExtension)
				into: self astFolder.

	LibC runCommand: ('{1} "{2}" > "{3}.json" 2> "{3}.err"' format: { 
				 self f77parser .
				 fortranFile pathString .
				 jsonFile pathString })
	]
]

{ #category : #private }
FortranProjectImporter >> iASTToFamix [

	| visitor |
	visitor := IASTToFortranVisitor new.

	iastmodel do: [ :iastProgramFile | iastProgramFile accept: visitor ].

	famixModel := visitor model
]

{ #category : #run }
FortranProjectImporter >> import [
	srcFolder ifNil: [ 
		Notification signal: 'Set source folder first'.
		^ self ].
	self srcFolder exists ifFalse: [ 
		Notification signal: srcFolder pathString , ' ''No such file or directory'''.
		^ self ].

	self copyEsopeFiles.
	self includedFilesToEsope.
	self esopeToFortran.
	self fortranToJsonAST.
	self jsonASTToIAST.
	self iASTToFamix.

	self famixResolve.
	
	^famixModel 

]

{ #category : #private }
FortranProjectImporter >> includedFilesToEsope [

	(self srcFolder allChildrenMatching: '*.inc') do: [ :includedFile | 
		(self 
			fileReference: (((includedFile pathString) , '.E') asFileReference)
			into: self esopeFolder)
			writeStreamDo: [ :tmpStream | 
				tmpStream
					<< '      subroutine __$__' ;
					cr ;
					<< includedFile contents ;
					<< '      end' ;
					cr ]
		]
]

{ #category : #private }
FortranProjectImporter >> jsonASTToIAST [

	| visitor |
	visitor := JsonToIASTVisitor new.

	iastmodel := (self astFolder asFileReference allChildrenMatching: '*.json') 
		collect: [ :jsonFile | 
			visitor visitProgramFile: (NeoJSONReader fromString: jsonFile contents) ].

]

{ #category : #accessing }
FortranProjectImporter >> srcFolder [

	^srcFolder asFileReference 
]

{ #category : #accessing }
FortranProjectImporter >> srcFolder: aString [

	srcFolder := aString 
]

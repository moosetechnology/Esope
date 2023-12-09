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

{ #category : #'private - import' }
FortranProjectImporter >> copyEsopeFiles [

	self ensureEmptyFolder: self esopeFolder.
	self copyFilesIn: self srcFolder with: '*.ec'.
	self copyFilesIn: self srcFolder with: '*.E'.
	self copyFilesIn: self srcFolder with: '*.fc'.
	self copyFilesIn: self srcFolder with: '*.F'.
	self copyFilesIn: self srcFolder with: '*.c'.
	self copyFilesIn: self srcFolder with: '*.cxx'.
	self copyFilesIn: self srcFolder with: '*.inc'
]

{ #category : #'private - import' }
FortranProjectImporter >> copyFilesIn: folder with: aPattern [

	(folder allChildrenMatching: aPattern) do: [ :file |
		file copyTo: (self fileReference: file into: self esopeFolder) ]
]

{ #category : #'private - files' }
FortranProjectImporter >> ensureEmptyFolder: folderName [
	| fileReference |
	fileReference := folderName asFileReference.
	fileReference exists
		ifTrue: [ fileReference children copy do: [ :childFile | childFile delete ]  ]
		ifFalse: [ fileReference ensureCreateDirectory ].
	^fileReference
]

{ #category : #'private - files' }
FortranProjectImporter >> ensureFolder: folderName [
	| fileReference |
	fileReference := folderName asFileReference.
	fileReference exists
		ifTrue: [ folderName  ]
		ifFalse: [ fileReference ensureCreateDirectory ].
	^fileReference
]

{ #category : #accessing }
FortranProjectImporter >> esopeFolder [
	^'Esope'
]

{ #category : #'private - import' }
FortranProjectImporter >> esopeToFortran [

	self ensureEmptyFolder: self fortranFolder.

	"self esopeFolder asFileReference allFiles"
	( (self esopeFolder asFileReference allChildrenMatching: '*.ec') 
	, (self esopeFolder asFileReference allChildrenMatching: '*.e'))  do: [
		:esopeFile |
		| fortranFile |
		fortranFile := self
			               fileReference: (esopeFile withExtension: 'f')
			               into: self fortranFolder.

		PPEsopeRewriter rewriteFrom: esopeFile to: fortranFile ]
]

{ #category : #accessing }
FortranProjectImporter >> f77parser [

	^ 'fortran-src-extras serialize -t json -v77l encode '
]

{ #category : #'private - import' }
FortranProjectImporter >> famixResolve [

	(FamixFortran77Resolver on: famixModel)
		resolve
]

{ #category : #'private - files' }
FortranProjectImporter >> fileReference: aFileReference into: aFolderName [
	^aFolderName asFileReference / aFileReference basename
]

{ #category : #'private - import' }
FortranProjectImporter >> fortran: fortranFile toJsonASTFolder: astFolder [

	| jsonFile |
	jsonFile := self
		            fileReference: fortranFile withoutExtension
		            into: astFolder.

	^ LibC runCommand: ('{1} "{2}" > "{3}.json" 2>&1' format: {
				   self f77parser.
				   fortranFile pathString.
				   jsonFile pathString })
]

{ #category : #accessing }
FortranProjectImporter >> fortranFolder [
	^'Fortran'
]

{ #category : #'private - import' }
FortranProjectImporter >> fortranToJsonAST [

	self ensureEmptyFolder: self astFolder.

	self fortranFolder asFileReference allFiles do: [ :fortranFile |
		self fortran: fortranFile toJsonASTFolder: self astFolder  ]
]

{ #category : #'private - import' }
FortranProjectImporter >> iASTToFamix [

	| visitor |
	visitor := IASTToFamixFortranVisitor new.

	iastmodel do: [ :iastProgramFile | iastProgramFile accept: visitor ].

	famixModel := visitor model
]

{ #category : #run }
FortranProjectImporter >> import [

	srcFolder ifNil: [ 
		Warning signal: 'Set source folder first' ].
	self srcFolder exists ifFalse: [ 
		Warning signal: self srcFolder pathString , ' ''No such file or directory''' ].

	UIManager default displayProgress: ''
		from: 0 to: (self importSteps size - 1)
		during: [:bar |
			self importSteps withIndexDo: [ :step :i |
				bar label: step key.
				bar current: i.
				self perform: step value
			] 
		].

	^ famixModel
]

{ #category : #run }
FortranProjectImporter >> importSteps [
	^{ 'Copying Esope Files' -> #copyEsopeFiles .
		'Converting included files to Esope' -> #includedFilesToEsope .
		'De-Esopifying files' -> #esopeToFortran .
		'Fortran to JSon AST' -> #fortranToJsonAST .
		'JSon AST to Intermediary AST' -> #jsonASTToIAST .
		'Intermediary AST to Famix' -> #iASTToFamix .
		'Famix symbol resolution' -> #famixResolve
	}
]

{ #category : #'private - import' }
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

{ #category : #'private - import' }
FortranProjectImporter >> jsonASTToIAST [

	| visitor |
	visitor := JsonToIASTVisitor new.

	iastmodel := (self astFolder asFileReference allChildrenMatching: '*.json') 
		collect: [ :jsonFile | 
			visitor visitProgramFile: (NeoJSONReader fromString: jsonFile contents) ].

]

{ #category : #run }
FortranProjectImporter >> preprocess: sourceCode to: stream [

	| lineStart |
	lineStart := true.

	sourceCode do: [ :c |
		(lineStart and: [ c = Character tab ])
			ifTrue: [ stream << '        ' ]
			ifFalse: [ (c = Character cr)
				ifTrue: [ stream lf ]
				ifFalse: [ stream << c ] ].
		lineStart := ({Character cr . Character lf} includes: c)
	]
]

{ #category : #accessing }
FortranProjectImporter >> srcFolder [

	^srcFolder asFileReference 
]

{ #category : #accessing }
FortranProjectImporter >> srcFolder: aString [

	srcFolder := aString 
]

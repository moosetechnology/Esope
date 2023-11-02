"
Responsible to import an Esope project into a Famix model

To use:
```
model := FortranProjectImporter new
	srcFolder: '/path/to/Esope/source/files/' ;
	includePaths: { list-of-path-containing-included-files } ;
	import.
```

This will import all files with a `*.E` (or `*.e`) extension + all included files (`*.inc`)
This is done in various steps (see `#importSteps`):
- copy Esope files (`*.E`) in a temporary directory (`./Esope/`)
- convert Esope files to Fortran files by annotating Esope instruction (in `./Fortran/`)
- get AST of Fortran files into Json files (in `./AST/`)
- import AST into an intermediate representation
- convert intermediate representation to Famix
- deal with included files (with all the preceedings as substeps)
- resolve  symbols in Famix

"
Class {
	#name : #FortranProjectImporter,
	#superclass : #Object,
	#instVars : [
		'srcFolder',
		'includePaths',
		'includedFiles',
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
	self copyFilesIn: self srcFolder with: '*.E'.
]

{ #category : #'private - import' }
FortranProjectImporter >> copyFilesIn: folder with: aPattern [

	(folder allChildrenMatching: aPattern) do: [ :file |
		file copyTo: (self fileReference: file into: self esopeFolder) ]
]

{ #category : #'private - files' }
FortranProjectImporter >> defaultFASTSource [
	^(self ensureFolder: self fastSrcFolder) / 'tmpFASTSource.f'
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
	(self esopeFolder asFileReference allChildrenMatching: '*.E') do: [
		:esopeFile |
		| fortranFile |
		fortranFile := self
			               fileReference: (esopeFile withExtension: 'f')
			               into: self fortranFolder.

		PPEsopeRewriter rewriteFrom: esopeFile to: fortranFile ]
]

{ #category : #accessing }
FortranProjectImporter >> f77parser [

	^ 'fortran-src-extras serialize -t json -v77l encode'
]

{ #category : #accessing }
FortranProjectImporter >> famixModel [

	^ famixModel
]

{ #category : #'private - import' }
FortranProjectImporter >> famixResolve [

	(FamixFortran77Resolver on: famixModel)
		resolve
]

{ #category : #accessing }
FortranProjectImporter >> fastSrcFolder [
	^'FastTmp'
]

{ #category : #'private - files' }
FortranProjectImporter >> fileReference: aFileReference into: aFolderName [
	^aFolderName asFileReference / aFileReference basename
]

{ #category : #'private - import' }
FortranProjectImporter >> findingIncludedFiles [

	| includedFileNames |
	includedFileNames := Set withAll:
		((famixModel allWithType: FamixF77Include)
			collect: #filename).
		
	includedFiles := includedFileNames collect: [ :filename | self findIncludedFile: filename ]
]

{ #category : #'private - import' }
FortranProjectImporter >> fortran: fortranFile toJsonASTFolder: astFolder [

	| jsonFile |
	jsonFile := self
		            fileReference: fortranFile withoutExtension
		            into: astFolder.

	^ LibC runCommand: ('{1} "{2}" > "{3}.json" 2> "{3}.err"' format: {
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

{ #category : #run }
FortranProjectImporter >> getFASTFor: sourceCode [

	| fastSrcFile |
	fastSrcFile := self defaultFASTSource.
	fastSrcFile writeStreamDo: [:st |
		st truncate.
		st
			<< sourceCode ;
			cr
	].
	
	self fortran: fastSrcFile toJsonASTFolder: self fastSrcFolder.
	^self jsonASTToFAST 
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
		'De-Esopifying files' -> #esopeToFortran .
		'Fortran to JSon AST' -> #fortranToJsonAST .
		'JSon AST to Intermediary AST' -> #jsonASTToIAST .
		'Intermediary AST to Famix' -> #iASTToFamix .
		'Finding included files' -> #findingIncludedFiles .
		'Converting included files to Esope' -> #includedFilesToEsope .
		'De-Esopifying included files' -> #includedEsopeToFortran .
		'Included files Fortran to JSon AST' -> #includedFortranToJsonAST .
		'Included files JSon AST to Intermediary AST' -> #includedJSonASTToIAST .
		'Included files intermediary AST to Famix' -> #includedIASTToFamix .
		'Famix symbol resolution' -> #famixResolve .
	}
]

{ #category : #accessing }
FortranProjectImporter >> includePaths [

	^ includePaths
]

{ #category : #accessing }
FortranProjectImporter >> includePaths: anObject [

	includePaths := anObject
]

{ #category : #'private - import' }
FortranProjectImporter >> includedEsopeToFortran [

	includedFiles do: [ :includedFile |
		| esopeFile fortranFile |
		esopeFile := self includedFileEsopeFile: includedFile.
		fortranFile := self
			fileReference: (esopeFile withExtension: 'f')
			into: self fortranFolder.

		PPEsopeRewriter rewriteFrom: esopeFile to: fortranFile ]
]

{ #category : #'private - import' }
FortranProjectImporter >> includedFileEsopeFile: includedFile [
	^self
		fileReference: (includedFile withExtension: 'incE')
		into: srcFolder
	 	
]

{ #category : #accessing }
FortranProjectImporter >> includedFiles [

	^ includedFiles
]

{ #category : #accessing }
FortranProjectImporter >> includedFiles: anObject [

	includedFiles := anObject
]

{ #category : #'private - import' }
FortranProjectImporter >> includedFilesToEsope [

	includedFiles do: [ :includedFile | 
		(self 
			fileReference: (self includedFileEsopeFile: includedFile)
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
FortranProjectImporter >> includedFortranToJsonAST [

	includedFiles do: [ :includedFile |
		| fortranFile |
		fortranFile := self
			fileReference: (includedFile withExtension: 'f')
			into: self fortranFolder.

		self fortran: fortranFile toJsonASTFolder: self astFolder
	]
]

{ #category : #'private - import' }
FortranProjectImporter >> includedIASTToFamix [

	| visitor |
	visitor := IASTToFamixFortranVisitor new.
	visitor model: famixModel.

	iastmodel do: [ :iastProgramFile | iastProgramFile accept: visitor ].

	famixModel := visitor model
]

{ #category : #'private - import' }
FortranProjectImporter >> includedJSonASTToIAST [

	| visitor |
	visitor := JsonToIASTVisitor new.

	iastmodel := includedFiles
		collect: [ :includedFile |
			|jsonFile | 
			jsonFile := self
				fileReference: (includedFile withExtension: 'json')
				into: self astFolder.
			visitor visitProgramFile: (NeoJSONReader fromString: jsonFile contents) ].

]

{ #category : #initialization }
FortranProjectImporter >> initialize [

	super initialize.

	includePaths := #()
]

{ #category : #'private - import' }
FortranProjectImporter >> jsonASTToFAST [

	| jsonAST |
	jsonAST := self defaultFASTSource withExtension: 'json'.
	^FASTFortranJsonVisitor new visitProgramFile:
		  (jsonAST readStreamDo: [ :str | 
			   NeoJSONReader fromString: str contents ])
]

{ #category : #'private - import' }
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

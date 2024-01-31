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
		'famixModel',
		'iastmodel',
		'srcFolders',
		'includedFiles',
		'includeFolders',
		'defaultFileEncoding',
		'currentStep'
	],
	#category : #'EsopeImporter-Importer'
}

{ #category : #importing }
FortranProjectImporter class >> import [
	<script>
	^self new
		import
]

{ #category : #run }
FortranProjectImporter >> collectIncludedEsopeFiles [

	self srcFolders do: [ :srcFolderName |
		self
			collectIncludedFiles: srcFolderName asFileReference
			inExtensions: self sourceEsopeExtensions.
	]

]

{ #category : #'private - files' }
FortranProjectImporter >> collectIncludedFiles: srcFileReference inExtensions: extensions [
	"collects all included files in file with the given extensions
	Put the result in the instance variable includedFiles"

	includedFiles := Set new.

	srcFileReference isDirectory
	ifTrue: [
		srcFileReference children do: [ :childReference |
			self collectIncludedFiles: childReference inExtensions: extensions ]
	]
	ifFalse: [
		(extensions includes: srcFileReference extension)
			ifTrue: [ self findIncludesIn: srcFileReference] ].

	^includedFiles
]

{ #category : #run }
FortranProjectImporter >> collectIncludedFortranFiles [
	"collects all included files in Fortran source and copy them to working Fortran directory
	Tries to keep the same directory hierarchy"

	| fortranFolder |
	self srcFolders do: [ :srcFolderName |
		self
			collectIncludedFiles: srcFolderName asFileReference
			inExtensions: self sourceFortranExtensions
	].

	fortranFolder := self workingFortranName asFileReference / self workingIncludeName.
	fortranFolder ensureCreateDirectory.

	includedFiles do: [ :fortranFile | self copyIncludedFortranFile: fortranFile to: fortranFolder ]

]

{ #category : #run }
FortranProjectImporter >> copyEsopeFiles [
	"Copy Esope source files into a workingDirectory
	(keeps the same directory hierarchy)"

	self
		copyFilesWithExtension: self sourceEsopeExtensions
		in: self workingEsopeName asFileReference.
]

{ #category : #'private - files' }
FortranProjectImporter >> copyFile: srcReference to: workingFolder [
	"copies a file srcReference to a directory workingFolder"

	srcReference copyTo: workingFolder / (srcReference basename)
]

{ #category : #'private - files' }
FortranProjectImporter >> copyFiles: srcReference extensions: extensions in: workingFolder [
	"copy all files in srcReference with an extension in 'extensions' to the directory workingFolder
	Keeps the src directory hierarchy into the destination folder"

	srcReference isDirectory
	ifTrue: [ | childWorkingReference |
		childWorkingReference := workingFolder / (srcReference basename).
		childWorkingReference ensureCreateDirectory.
		srcReference children do: [ :childReference |
			self copyFiles: childReference extensions: extensions in: childWorkingReference ]
	]
	ifFalse: [
		(extensions includes: srcReference extension)
			ifTrue: [self copyFile: srcReference to: workingFolder] ]
]

{ #category : #'private - files' }
FortranProjectImporter >> copyFilesWithExtension: extensions in: workingFolder [
	"Copy Fortran or Esope source files (depending on extensions) into a workingDirectory
	(keeps the same directory hierarchy)"

	self srcFolders do: [ :srcFolderName |
		self
			copyFiles: srcFolderName asFileReference
			extensions: extensions
			in: workingFolder]
]

{ #category : #run }
FortranProjectImporter >> copyFortranFiles [
	"Copy Fortran source files into a workingDirectory
	(keeps the same directory hierarchy)"

	self
		copyFilesWithExtension: self sourceFortranExtensions
		in: self workingFortranName asFileReference.
]

{ #category : #'private - files' }
FortranProjectImporter >> copyIncludedFortranFile: includedFile to: workingFortranFolder [
	
	| relativePath destFortranFolder |

	relativePath := includedFile isAbsolute
		ifTrue: [
			(includedFile fullName
				copyFrom: 2 to: (includedFile fullName lastIndexOf: $/))
		]
		ifFalse: [ includedFile pathString ].

	destFortranFolder := workingFortranFolder / relativePath.
	destFortranFolder ensureCreateDirectory.

	self copyFile: includedFile to: destFortranFolder
		

]

{ #category : #accessing }
FortranProjectImporter >> defaultFileEncoding [
	"other possibilities are 'latin1', 'utf8', ...
	see `ZnCharacterEncoder knownEncodingIdentifiers` for all possibilities"

	^defaultFileEncoding ifNil: [ 'iso-8859-1' ]
]

{ #category : #accessing }
FortranProjectImporter >> defaultFileEncoding: aString [
	"other possibilities are 'latin1', 'utf8', ...
	see `ZnCharacterEncoder knownEncodingIdentifiers` for all possibilities"

	defaultFileEncoding := aString
]

{ #category : #'private - files' }
FortranProjectImporter >> ensureEmptyFolder: folder [

	folder exists
		ifTrue: [ folder deleteAll  ]
		ifFalse: [ folder ensureCreateDirectory ].
	^folder
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

{ #category : #'private - import' }
FortranProjectImporter >> esope: esopeReference toFortran: fortranFolder [
	"for each Esope file in esopeReference, creates a de-esopified file in fortranFolder
	(keeps the same directory hierarchy)"

	esopeReference isDirectory
	ifTrue: [ | childWorkingReference |
		childWorkingReference := fortranFolder / (esopeReference basename).
		childWorkingReference ensureCreateDirectory.
		esopeReference children do: [ :childReference |
			self esope: childReference toFortran: childWorkingReference ]
	]
	ifFalse: [
		[ PPEsopeRewriter
			rewriteFrom: (esopeReference readStreamEncoded: self defaultFileEncoding)
			to: fortranFolder / (esopeReference basename , '.f')
		]
		on: Error
		do: [ :err |
			self reportError: err onFile: esopeReference fullName
		]
	]
]

{ #category : #run }
FortranProjectImporter >> esopeToFortran [
	"'de-esopifying Esope files to be able to parse them in Fortran
	The result goes in the FortranWorkingDirectory"

	| fortranWorkingFolder |
	fortranWorkingFolder := self workingFortranName asFileReference.

	self workingEsopeName asFileReference children do: [ :esopeChild |
		self esope: esopeChild toFortran: fortranWorkingFolder
	]
]

{ #category : #accessing }
FortranProjectImporter >> f77parser [

	^ 'fortran-src-extras serialize -t json -v77l encode '
]

{ #category : #'private - import' }
FortranProjectImporter >> fakeEsopeProgramUnit: includedFile to: workingEsopeFolder [

	| relativePath destEsopeFolder |

	relativePath := includedFile isAbsolute
		ifTrue: [
			(includedFile fullName
				copyFrom: 2 to: (includedFile fullName lastIndexOf: $/))
		]
		ifFalse: [ includedFile pathString ].

	destEsopeFolder := workingEsopeFolder / self workingIncludeName / relativePath.
	destEsopeFolder ensureCreateDirectory.

	(destEsopeFolder / (includedFile basename , '.E'))
		writeStreamDo: [ :tmpStream | 
			tmpStream
				<< '      subroutine __$__' ;
				cr ;
				<< includedFile contents ;
				<< '      end' ;
				cr ]
		
]

{ #category : #run }
FortranProjectImporter >> famixResolve [

	(FamixFortran77Resolver on: famixModel)
		resolve
]

{ #category : #'private - files' }
FortranProjectImporter >> findIncludesIn: srcFileReference [

	[srcFileReference readStreamEncoded: self defaultFileEncoding do: [ :stream |
		stream contents lines
			do: [ :line |
				(self isIncludeLine: line)
				ifTrue: [ includedFiles add: (self getIncludedFile: line) ]
			]
	]]
	on: Error
	do: [ :err | self reportError: err onFile: srcFileReference fullName ]
]

{ #category : #'private - import' }
FortranProjectImporter >> fortran: f77file toAST: astFolder [

	| jsonFile |

	jsonFile := (self fortranFolderToASTFolder: f77file parent) / (f77file basename , '.json').

	^LibC runCommand: (
		'{1} "{2}" > "{3}.json" 2>&1'
		format: {
			self f77parser.
			f77file fullName.
			jsonFile fullName
		}
	)
]

{ #category : #'private - import' }
FortranProjectImporter >> fortranFolderToASTFolder: fortranFolder [

	| astFolder |
	self flag: #FIXME. "Reproduce the source directory hierarchy or not. 
	If yes: replace the non-commented assignement by the commented one.
	"
	"astFolder := (
		fortranFolder fullName
			copyReplaceAll: self workingFortranName
			with: self workingJsonName
		) asFileReference."
	astFolder := self workingJsonName asFileReference.
	astFolder ensureCreateDirectory.

	^ astFolder
]

{ #category : #run }
FortranProjectImporter >> fortranToAST [
	"A 'standard' Fortran-77 parser goes through all Fortran-77 files (de-esopified or pure)
	and parses each of them to produce a corresponding AST in jsonWorkingFolder"

	(self workingFortranName asFileReference allChildrenMatching: '*.f')
		do: [ :file | self parseFortran77: file ]
]

{ #category : #'private - files' }
FortranProjectImporter >> getIncludedFile: aString [

	| file |
	file := (Character space split: aString) allButFirst
		detect: [ :token | token isNotEmpty ].

	^self unquoteIncludedFile: file
]

{ #category : #run }
FortranProjectImporter >> iASTToFamix [

	| visitor |
	visitor := IASTToFamixFortranVisitor new.

	iastmodel do: [ :iastProgramFile |
		[iastProgramFile accept: visitor]
		on: Error
		do: [ :err | self reportError: err onFile: iastProgramFile filename ]
	].

	famixModel := visitor model
]

{ #category : #run }
FortranProjectImporter >> import [

	srcFolders ifNil: [ 
		Warning signal: 'Set source folders first' ].
	srcFolders ifEmpty: [ 
		Warning signal: 'Set source folders first' ].

	UIManager default displayProgress: ''
		from: 0 to: (self importSteps size - 1)
		during: [:bar |
			self importSteps withIndexDo: [ :step :i |
				currentStep := step.
				bar label: step key.
				bar current: i.
				self perform: step value
			] 
		].

	^ famixModel
]

{ #category : #run }
FortranProjectImporter >> importSteps [
	^{
		'Prepare working folders' -> #prepareWorkingFolders .
		
		'Collecting included Esope files' -> #collectIncludedEsopeFiles .
		'Converting included files to Esope' -> #includedFilesToEsope .
		'Copying Esope Files' -> #copyEsopeFiles .
		'De-Esopifying files' -> #esopeToFortran .
		'Copying Fortran Files' -> #copyFortranFiles .
		'Collecting included Fortran files' -> #collectIncludedFortranFiles .

		'Fortran to JSon AST' -> #fortranToAST .
		'JSon AST to Intermediary AST' -> #jsonASTToIAST .
		'Intermediary AST to Famix' -> #iASTToFamix .
		'Famix symbol resolution' -> #famixResolve
	}
]

{ #category : #accessing }
FortranProjectImporter >> includeFolders [
	^includeFolders ifNil: [ #() ]
]

{ #category : #accessing }
FortranProjectImporter >> includeFolders: aCollection [

	includeFolders := aCollection
]

{ #category : #run }
FortranProjectImporter >> includedFilesToEsope [

	| includeFolderReferences esopeFolder |
	includeFolderReferences := self includeFolders collect: #asFileReference.

	esopeFolder := self workingEsopeName asFileReference.

	includedFiles do: [ :includedFile |
		(self searchIncluded: includedFile among: includeFolderReferences)
			ifNotNil: [ :foundFile | self fakeEsopeProgramUnit: foundFile to: esopeFolder  ]
	]
]

{ #category : #'private - files' }
FortranProjectImporter >> isIncludeLine: aString [

	(aString beginsWith: '#include ') ifTrue: [ ^true ].
	(aString beginsWith: '%INC ') ifTrue: [ ^true ].
	(aString beginsWith: 'include ') ifTrue: [ ^true ].

	^false
]

{ #category : #run }
FortranProjectImporter >> jsonASTToIAST [

	| visitor |
	visitor := JsonToIASTVisitor new.

	iastmodel := (self workingJsonName asFileReference allChildrenMatching: '*.json') 
		collect: [ :jsonFile | 
			[visitor visitProgramFile: (NeoJSONReader fromString: jsonFile contents)]
			on: Error
			do: [ :err |
				self reportError: err onFile: jsonFile fullName.
				IASTErrorEntity new filename: jsonFile fullName ; yourself ]
		]

]

{ #category : #'private - import' }
FortranProjectImporter >> parseFortran77: f77file [

	| jsonFile |

	jsonFile := (self fortranFolderToASTFolder: f77file parent) / f77file basename.

	^LibC runCommand: (
		'{1} "{2}" > "{3}.json" 2>&1'
		format: {
			self f77parser.
			f77file fullName.
			jsonFile fullName
		}
	)
]

{ #category : #run }
FortranProjectImporter >> prepareWorkingFolders [

	self ensureEmptyFolder: self workingEsopeName asFileReference.
	self ensureEmptyFolder: self workingFortranName asFileReference.
	self ensureEmptyFolder: self workingJsonName asFileReference.

]

{ #category : #'private - files' }
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

{ #category : #'error management' }
FortranProjectImporter >> reportError: aString [

	self reportError: aString step: currentStep value asString
]

{ #category : #'error management' }
FortranProjectImporter >> reportError: err onFile: aFileName [

	self reportError: (err messageText , ' on file ' , aFileName)
]

{ #category : #'error management' }
FortranProjectImporter >> reportError: aString step: aSymbol [

	aSymbol trace.
	' -- error: ' trace.
	aString traceCr.
]

{ #category : #'private - import' }
FortranProjectImporter >> searchIncluded: includedFileName among: includeFolderReferences [
	"search for includedFileName in one of the includeFolderReferences
	 if found, returns the file reference of the file, otherwise nil

	 Note: The includedFileName may be a file name ('blah.h'),
	   a path name ('lib/blah.h'), or a filename without extension ('blah')"

	^includeFolderReferences
		detect: [ :folder | (folder / includedFileName)  exists ]
		ifOne: [ :folder | (folder / includedFileName) ]
		ifNone: [ nil ]

]

{ #category : #accessing }
FortranProjectImporter >> sourceEsopeExtensions [

	^#(E e ec)
]

{ #category : #accessing }
FortranProjectImporter >> sourceFortranExtensions [

	^#(F f fc)
]

{ #category : #accessing }
FortranProjectImporter >> srcFolders [

	^srcFolders 
]

{ #category : #accessing }
FortranProjectImporter >> srcFolders: aCollection [

	srcFolders := aCollection 
]

{ #category : #'private - files' }
FortranProjectImporter >> unquoteIncludedFile: fileName [

	^(#( $" $< ) includes: fileName first)
		ifTrue: [ fileName copyFrom: 2 to: fileName size -1 ]
		ifFalse: [ fileName ]
]

{ #category : #accessing }
FortranProjectImporter >> workingEsopeName [

	^'tmpEsopeImport'
]

{ #category : #accessing }
FortranProjectImporter >> workingFortranName [

	^'tmpFortranImport'
]

{ #category : #accessing }
FortranProjectImporter >> workingIncludeName [

	^'tmpIncludeDirectory'
]

{ #category : #accessing }
FortranProjectImporter >> workingJsonName [
	
	^'tmpJsonImport'
]

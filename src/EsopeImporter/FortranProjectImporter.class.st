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
		'includeFolders',
		'defaultFileEncoding',
		'errorHandler',
		'stopOnError',
		'includedFiles',
		'tempFiles',
		'tempEsopeFolder',
		'tempFortranFolder',
		'tempJsonFolder'
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
FortranProjectImporter >> collectFilesIn: srcFileReference withExtensions: extensions [

	^srcFileReference isDirectory
		ifTrue: [
			srcFileReference children flatCollect: [ :childReference |
				self collectFilesIn: childReference withExtensions: extensions ]
		]
		ifFalse: [
			(extensions includes: srcFileReference extension)
				ifTrue: [ { srcFileReference } ]
				ifFalse: [ #() ]
		]
]

{ #category : #run }
FortranProjectImporter >> collectIncludedFileNames [

	^(self collectSrcFilesWithExtensions: self extensionsEsope)
		flatCollectAsSet: [ :srcFileReference | self includedNamesIn: srcFileReference]
]

{ #category : #run }
FortranProjectImporter >> collectSrcFilesWithExtensions: extensions [

	^self srcFolders flatCollect: [ :srcFolderName |
		self collectFilesIn: srcFolderName withExtensions: extensions ]
]

{ #category : #'private - files' }
FortranProjectImporter >> copyFile: srcReference to: destFolder [
	"copies a file srcReference to a directory workingFolder"

	srcReference copyTo: destFolder / srcReference
]

{ #category : #TOREMOVE }
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
			ifTrue: [ self copyFile: srcReference to: workingFolder ] 
	]
]

{ #category : #TOREMOVE }
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

	| destFolder |
	destFolder := self workingEsopeName asFileReference.
	(self collectSrcFilesWithExtensions: self extensionsFortran) do: [ :srcFile |
		self copyFile: srcFile to: destFolder ]

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

	folder exists ifTrue: [ folder deleteAll  ].
	folder ensureCreateDirectory.
	^folder
]

{ #category : #accessing }
FortranProjectImporter >> errorHandler [

	^ errorHandler
]

{ #category : #accessing }
FortranProjectImporter >> errorHandler: anObject [

	errorHandler := anObject
]

{ #category : #'error management' }
FortranProjectImporter >> errors [

	^errorHandler errors
]

{ #category : #'private - import' }
FortranProjectImporter >> esopeFile: esopeFile toFortran: fortranFile [
	"de-esopify esopeFile into fortranFile"

	errorHandler
		handleErrorsFor: 'file:' , esopeFile fullName
		running: [
			PPEsopeRewriter
				rewriteFrom: (esopeFile readStreamEncoded: self defaultFileEncoding)
				to: fortranFile
		]
]

{ #category : #run }
FortranProjectImporter >> esopeToFortran [
	"'de-esopifying Esope files to be able to parse them in Fortran
	The result goes in the FortranWorkingDirectory"

	(self collectSrcFilesWithExtensions: self extensionsEsope) do: [ :srcFile |
		| copiedEsope fortranFolder |
		copiedEsope := self makeFileReference: srcFile localTo: self tempEsopeFolder.
		srcFile copyTo: copiedEsope.
	
		fortranFolder := self makeFileReference: srcFile parent localTo: self tempFortranFolder.
		self esopeFile: copiedEsope toFortran: fortranFolder / (srcFile basename , '.f')
	]
]

{ #category : #accessing }
FortranProjectImporter >> extensionsEsope [
	"Add F and fc as esope files in order to let the ReWriter handle the include statement for this type of file"

	^#(E ec e F fc)
]

{ #category : #accessing }
FortranProjectImporter >> extensionsFortran [

	^#(f for)
]

{ #category : #accessing }
FortranProjectImporter >> extensionsTransformedSources [

	^ #( e f )
]

{ #category : #accessing }
FortranProjectImporter >> f77parser [

	^ 'fortran-src-extras serialize -t json -v77l encode '
]

{ #category : #'private - import' }
FortranProjectImporter >> fakeEsopeProgramUnit: includedFile to: workingEsopeFolder [
	"creates a fake programUnit from an includedFile
	 The includedFile is actually an association containingFolder -> filename
	 Records in originalFileMap the original name of the file and the created fake esope file"

	| destFolder |
	destFolder := self makeFileReference: includedFile parent localTo: workingEsopeFolder.
	destFolder ensureCreateDirectory.

	(destFolder /  (includedFile basename , '.E')) writeStreamDo: [ :tmpStream |
		tmpStream
			<< '      subroutine __$__';
			cr;
			<< includedFile contents;
			<< '      end';
			cr ]
]

{ #category : #run }
FortranProjectImporter >> famixResolve [

	(FamixFortran77Resolver on: famixModel)
		errorHandler: errorHandler ;
		resolve.

]

{ #category : #run }
FortranProjectImporter >> findFiles: fileNames in: folders [
	"try to find files matching one of fileNames in folders
	 returns a FileReference and the folder containing it for each one found"

	^fileNames
		collect: [ :includedFile | self folderContaining: includedFile among: folders ]
		thenReject: #isNil
]

{ #category : #'private - import' }
FortranProjectImporter >> folderContaining: includedFileName among: includeFolderReferences [
	"search for includedFileName in one of the includeFolderReferences
	 if found, returns the folder if found and nil otherwise

	 Note: The includedFileName may be a file name ('blah.h'),
	   a path name ('lib/blah.h'), or a filename without extension ('blah')"

	^includeFolderReferences
		detect: [ :folder | (folder / includedFileName)  exists ]
		ifOne: [ :folder | folder / includedFileName ]
		ifNone: [ nil ]

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
FortranProjectImporter >> fortranToJsonAST [
	"A 'standard' Fortran-77 parser goes through all Fortran-77 files (de-esopified or pure)
	and parses each of them to produce a corresponding AST in jsonWorkingFolder"

	(self workingFortranName asFileReference allChildrenMatching: '*.f')
		do: [ :file | self parseFortran77: file ]
]

{ #category : #'private - files' }
FortranProjectImporter >> getIncludedFileName: aString [

	| file |
	file := (Character space split: aString) allButFirst
		detect: [ :token | token isNotEmpty ].

	^self unquoteIncludedFile: file
]

{ #category : #'error management' }
FortranProjectImporter >> hasErrors [

	^errorHandler isNotEmpty
]

{ #category : #run }
FortranProjectImporter >> iASTToFamix [

	| visitor |
	visitor := IASTToFamixFortranVisitor new.

	iastmodel do: [ :iastProgramFile |
		errorHandler
			handleErrorsFor: 'file:' , iastProgramFile filename
			running: [ iastProgramFile accept: visitor ]
	].

	famixModel := visitor model
]

{ #category : #run }
FortranProjectImporter >> import [

	srcFolders ifNil: [ 
		Warning signal: 'Set source folders first' ].
	srcFolders ifEmpty: [ 
		Warning signal: 'Set source folders first' ].

	errorHandler := FortranErrorManager new.

	UIManager default displayProgress: ''
		from: 0 to: (self importSteps size - 1)
		during: [:bar |
			self importSteps withIndexDo: [ :step :i |
				bar label: step key.
				bar current: i.

				errorHandler
					handleErrorsFor: step value
					running: [ self perform: step value ]
			] 
		].

	^ famixModel
]

{ #category : #run }
FortranProjectImporter >> importSteps [
	^{
		'Converting included files to Esope' -> #includedFilesToEsope .
		'De-Esopifying files' -> #esopeToFortran .
		'Fortran to JSon AST' -> #fortranToJsonAST .

		'JSon AST to Intermediary AST' -> #jsonASTToIAST .
		'Intermediary AST to Famix' -> #iASTToFamix .
		'Famix symbol resolution' -> #famixResolve
	}
]

{ #category : #accessing }
FortranProjectImporter >> includeFolderReferences [

	^ self includeFolders collect: #asFileReference
]

{ #category : #accessing }
FortranProjectImporter >> includeFolders [

	^ includeFolders ifNil: [ #(  ) ]
]

{ #category : #accessing }
FortranProjectImporter >> includeFolders: aCollection [

	includeFolders := aCollection
]

{ #category : #accessing }
FortranProjectImporter >> includedFiles [

	^ includedFiles ifNil: [ includedFiles := Set new ]


]

{ #category : #run }
FortranProjectImporter >> includedFilesToEsope [

	(self findFiles: self collectIncludedFileNames in: self includeFolderReferences)
		do: [ :foundFile | self fakeEsopeProgramUnit: foundFile to: self tempEsopeFolder  ]
]

{ #category : #'private - files' }
FortranProjectImporter >> includedNamesIn: srcFileReference [
	"finds all file inclusions from srcFileReference"

	^errorHandler
		handleErrorsFor: 'file:' , srcFileReference fullName
		running: [
			srcFileReference
				readStreamEncoded: self defaultFileEncoding
				do: [ :stream |
					stream contents lines
						select: [ :line | self isIncludeLine: line]
						thenCollect: [ :line | self getIncludedFileName: line ]
				]
		]

]

{ #category : #initialization }
FortranProjectImporter >> initialize [

	super initialize.

	tempFiles := FortranImporterFileMap new.
]

{ #category : #'private - files' }
FortranProjectImporter >> isIncludeLine: aString [

	(aString beginsWith: '#include ' caseSensitive: false) ifTrue: [ ^true ].
	(aString beginsWith: '%INC ' caseSensitive: false) ifTrue: [ ^true ].
	(aString beginsWith: 'include ' caseSensitive: false) ifTrue: [ ^true ].

	^false
]

{ #category : #run }
FortranProjectImporter >> jsonASTToIAST [

	| visitor iastEntity |
	visitor := JsonToIASTVisitor new.

	iastmodel := (self workingJsonName asFileReference allChildrenMatching: '*.json') 
		collect: [ :jsonFile | 
			errorHandler
				handleErrorsFor: 'file:' , jsonFile fullName
				running: [ 
					iastEntity := visitor visitProgramFile:
						(NeoJSONReader fromString: jsonFile contents) ]
				onErrorDo: [ :err |
					iastEntity := IASTErrorEntity new filename: jsonFile fullName ; yourself
				].

			iastEntity
		]

]

{ #category : #run }
FortranProjectImporter >> makeFileReference: aFileReference localTo: aFolder [

	| parent |
	(aFileReference fullName = '.') ifTrue: [ ^aFolder ].
	(aFileReference fullName = '/') ifTrue: [ ^aFolder ].

	parent := self makeFileReference: aFileReference parent localTo: aFolder.
	parent ensureCreateDirectory.

	^parent / aFileReference basename

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

{ #category : #accessing }
FortranProjectImporter >> srcFolders [

	^srcFolders 
]

{ #category : #accessing }
FortranProjectImporter >> srcFolders: aCollection [

	srcFolders := aCollection 
]

{ #category : #accessing }
FortranProjectImporter >> tempEsopeFolder [

	^tempEsopeFolder
		ifNil: [
			tempEsopeFolder := self ensureEmptyFolder: self workingEsopeName asFileReference
		]

]

{ #category : #accessing }
FortranProjectImporter >> tempFortranFolder [

	^tempFortranFolder
		ifNil: [
			tempFortranFolder := self ensureEmptyFolder: self workingFortranName asFileReference
		]

]

{ #category : #accessing }
FortranProjectImporter >> tempJsonFolder [

	^tempJsonFolder
		ifNil: [
			tempJsonFolder := self ensureEmptyFolder: self workingJsonName asFileReference
		]

]

{ #category : #'private - files' }
FortranProjectImporter >> unquoteIncludedFile: fileName [
	"returns the name of an included file in an include line, without optional quotes"

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

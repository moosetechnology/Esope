"
Responsible to import an Esope project into a Famix model

To use:

## Build an Esope model

change `/path/to/...` in the importer initialiser, regardless of your project's path

### Initialise the project importer
```st
importer := FortranProjectImporter new
	srcFolders:  { '/path/to/source'. '/path/to/anothersource' };
 	includeFolders: { '/path/to/include'. '/path/to/anotherinclude' };
	yourself.
```
### Construct the model
```st
model := importer import.
```

This will import all files with a `*.E` (or `*.ec`) extension + all included files (`*.inc`, `*.seg`,, `*.obg`, ...)
This is done in various steps (see `#importSteps`):
- copy Esope files (`*.E`) in a temporary directory (`./Esope/`)
- create special Esope files for included files (in same directory `./Esope/`)
- convert Esope files to Fortran files by annotating Esope instruction (in `./Fortran/`)
- get AST of Fortran files into Json files (in `./AST/`)
- import AST into an intermediate representation
- convert intermediate representation to Famix
- resolve  symbols in Famix




### Check the importer errors

If an error occurs while importing the project, it will be reported to the importer's `errorHandler` instance variable

```st
error := importer errorHandler.
```
"
Class {
	#name : #FortranProjectImporter,
	#superclass : #Object,
	#instVars : [
		'famixModel',
		'iastmodel',
		'defaultFileEncoding',
		'errorHandler',
		'stopOnError',
		'includedFiles',
		'tempEsopeFolder',
		'tempFortranFolder',
		'tempJsonFolder',
		'resolver',
		'withSanityChecks',
		'includeFolder',
		'srcFolder'
	],
	#category : #'EsopeImporter-Importer'
}

{ #category : #importing }
FortranProjectImporter class >> import [
	<script>
	^self new
		import
]

{ #category : #testing }
FortranProjectImporter class >> isDummySubroutine: aName [
	"name matches: _$ + a sequence of at least one character"

	^ '_$#*' match: aName
]

{ #category : #importing }
FortranProjectImporter class >> parseString: fortranCode [

	| srcFile destFile |
	srcFile  := './srcCode.f' asFileReference ensureDelete.
	destFile := './srcCode.json' asFileReference ensureDelete.

	srcFile writeStreamDo: [ :stream | 
		stream << fortranCode withUnixLineEndings ].

	self new
		parseFortran77File: srcFile to: destFile.

	^destFile contents
]

{ #category : #'private - files' }
FortranProjectImporter >> allLocalizedFilesIn: aFolder [

	^aFolder allFiles collect: [ :file |
		file relativeTo: aFolder absolutePath
	].

]

{ #category : #'private - files' }
FortranProjectImporter >> appendPath: aPath toParent: aFolder [
	"aPath may be a relative or absolute path, we want it 'concatenated' to aFolder
	 to give something like: 'aFolder / aPath' 
	 Additionaly, we make sure the resulting parent path exist so that if it is a file,
	 it can be created"

	| parent |
	(aPath fullName = '') ifTrue: [ ^aFolder ].
	(aPath fullName = '.') ifTrue: [ ^aFolder ].
	(aPath fullName = '/') ifTrue: [ ^aFolder ].

	parent := self appendPath: aPath parent toParent: aFolder.
	parent ensureCreateDirectory.

	^parent / aPath basename

]

{ #category : #'private - files' }
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

{ #category : #'private - files' }
FortranProjectImporter >> collectIncludedFileNames [

	^(self collectSrcFilesWithExtensions: self extensionsEsope)
		flatCollectAsSet: [ :srcFileReference | self includedNamesIn: srcFileReference]
]

{ #category : #'private - files' }
FortranProjectImporter >> collectSrcFilesWithExtensions: extensions [

	^self collectFilesIn: srcFolder withExtensions: extensions
]

{ #category : #'private - files' }
FortranProjectImporter >> copy: aPath to: aFolder [

	aPath asFileReference
		copyTo: (self appendPath: aPath toParent: aFolder)
]

{ #category : #'private - import' }
FortranProjectImporter >> deEsopify: localPath from: srcFolder to: destFolder [
	"de-esopify localPath in srcFolder to fortran file in destFolder"

	| srcFile destFile |
	srcFile := self appendPath: localPath toParent: srcFolder.
	destFile := (self appendPath: localPath toParent: destFolder) withExtension: 'f'.

	errorHandler enterContext: 'file:' , localPath fullName.

	PPEsopeRewriter
		rewriteFrom: (srcFile readStreamEncoded: self defaultFileEncoding)
		to: destFile.

	errorHandler leaveContext
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

{ #category : #'error management' }
FortranProjectImporter >> errorHandler [

	^ errorHandler
]

{ #category : #'error management' }
FortranProjectImporter >> errorHandler: anObject [

	errorHandler := anObject
]

{ #category : #'error management' }
FortranProjectImporter >> errors [

	^errorHandler errors
]

{ #category : #run }
FortranProjectImporter >> esopeToFortran [
	"'de-esopifying Esope files to be able to parse them in Fortran
	The result goes in the FortranWorkingDirectory"

	(self allLocalizedFilesIn: self tempEsopeFolder) do: [ :localPath |
		self deEsopify: localPath from: self tempEsopeFolder to: self tempFortranFolder ].

	(self collectSrcFilesWithExtensions: self extensionsEsope) do: [ :localPath |
		self copy: localPath to: self tempEsopeFolder.
		self deEsopify: localPath from: self tempEsopeFolder to: self tempFortranFolder ]
]

{ #category : #constants }
FortranProjectImporter >> extensionsEsope [
	"Add F and fc as esope files in order to let the ReWriter handle the include statement for this type of file"

	^#(E ec e F fc)
]

{ #category : #constants }
FortranProjectImporter >> extensionsFortran [

	^#(f for)
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
	destFolder := self appendPath: includedFile parent toParent: workingEsopeFolder.
	destFolder ensureCreateDirectory.

	(destFolder /  (includedFile basename , '.E')) writeStreamDo: [ :tmpStream |
		tmpStream
			<< '      subroutine _$' ;
			<< (includedFile basename copy replaceAll: $. with: $_) ;
			cr ;
			<< includedFile contents ;
			<< '      end' ;
			cr ]
]

{ #category : #accessing }
FortranProjectImporter >> famixModel [

	^ famixModel
]

{ #category : #accessing }
FortranProjectImporter >> famixModel: anObject [

	famixModel := anObject
]

{ #category : #run }
FortranProjectImporter >> famixResolve [
	"creates a resolver and resolve all pending names"

	self newResolver
		resolve.

]

{ #category : #'private - files' }
FortranProjectImporter >> findFiles: fileNames in: folder [
	"try to find files matching one of fileNames in #folder
	 for each name returns the first FileReference found and the (sub-)folder containing it"

	^ fileNames
		  collect: [ :includedFile | self relativePathOf: includedFile in: folder ]
		  thenReject: #isNil
]

{ #category : #run }
FortranProjectImporter >> fortranToJsonAST [
	"Goes through all Fortran-77 files (de-esopified or 'pure') and parses each one
	 to produce a corresponding Json AST"

	(self allLocalizedFilesIn: self tempFortranFolder) do: [ :localPath |
		self parseFortran77: localPath from: self tempFortranFolder to: self tempJsonFolder ].

	(self collectSrcFilesWithExtensions: self extensionsFortran) do: [ :localPath |
		localPath asFileReference
			copyTo: (self appendPath: localPath toParent: tempFortranFolder).
		self parseFortran77: localPath from: self tempFortranFolder to: self tempJsonFolder ]
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
		errorHandler enterContext: ('file:' , iastProgramFile filename).
		iastProgramFile accept: visitor.
		errorHandler leaveContext
	].

	famixModel := visitor model
]

{ #category : #run }
FortranProjectImporter >> import [

	srcFolder ifNil: [ Warning signal: 'Set source folder first' ].

	errorHandler := FortranErrorManager new.
	errorHandler stopOnError: self stopOnError.

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
		'Famix symbol resolution' -> #famixResolve .

		'Post import sanity checks' -> #postImportChecks
	}
]

{ #category : #accessing }
FortranProjectImporter >> includeFolder [

	^ includeFolder ifNil: [ self srcFolder ]
]

{ #category : #accessing }
FortranProjectImporter >> includeFolder: folder [
	"folder is either a String of a FileReference"

	includeFolder := folder isString
		ifTrue: [ folder asFileReference ]
		ifFalse: [ folder ]

]

{ #category : #run }
FortranProjectImporter >> includedFilesToEsope [

	(self findFiles: self collectIncludedFileNames in: self includeFolder)
		do: [ :foundFile |
			errorHandler enterContext: foundFile basename.
			self fakeEsopeProgramUnit: foundFile to: self tempEsopeFolder.
			errorHandler leaveContext
		]
]

{ #category : #'private - files' }
FortranProjectImporter >> includedNamesIn: srcFileReference [
	"finds all file inclusions from srcFileReference"

	| value |
	errorHandler	enterContext: 'file:' , srcFileReference fullName.

	value := srcFileReference
		readStreamEncoded: self defaultFileEncoding
		do: [ :stream |
			stream contents lines
				select: [ :line | self isIncludeLine: line]
				thenCollect: [ :line | self getIncludedFileName: line ]
		].

	errorHandler leaveContext.
	
	^value

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

	iastmodel := (self tempJsonFolder allFiles) 
		collect: [ :jsonFile | 
			errorHandler enterContext: jsonFile fullName.
			iastEntity := visitor visitProgramFile:
				(NeoJSONReader fromString: jsonFile contents).
			errorHandler leaveContext.
			iastEntity
		]

]

{ #category : #'private - import' }
FortranProjectImporter >> newResolver [

	^resolver := (FamixEsopeResolver  on: famixModel)
		errorHandler: errorHandler
]

{ #category : #'private - import' }
FortranProjectImporter >> parseFortran77: localPath from: srcFolder to: destFolder [
	"runs fortran77 parser on localPath in srcFolder to JSON file in destFolder"

	| destFile cmdReturn |
	destFile := (self appendPath: localPath toParent: destFolder) withExtension: 'json'.
	destFile parent ensureCreateDirectory.

	cmdReturn := self parseFortran77File: (self appendPath: localPath toParent: srcFolder) to: destFile.

	(cmdReturn = 0) ifTrue: [ ^self ].

	errorHandler error: 'Error while parsing ' , localPath pathString.
	destFile ensureDelete

]

{ #category : #'private - import' }
FortranProjectImporter >> parseFortran77File: srcFileReference to: destFileReference [

	^LibC runCommand: (
		'{1} "{2}" > "{3}" 2>&1'
		format: {
			self f77parser .
			srcFileReference fullName .
			destFileReference fullName
		}
	)
]

{ #category : #run }
FortranProjectImporter >> postImportChecks [

	withSanityChecks ifTrue: [
		famixModel entities do: [ :entity |
			errorHandler enterContext: entity asString.
			entity famixImportSanityCheck.
			errorHandler leaveContext
		]
	]
]

{ #category : #'private - files' }
FortranProjectImporter >> relativePathOf: includedFileName in: folder [
	"search for includedFileName in #folder or sub-folders
	 if found, returns the path relative to #folder and nil otherwise

	 Note: The includedFileName may be a file name ('blah.h'),
	   a path name ('lib/blah.h'), or a filename without extension ('blah')"

	(folder / includedFileName) exists ifTrue: [
		^ folder / includedFileName ].

	folder children do: [ :child |
		(self relativePathOf: includedFileName in: child) ifNotNil: [ :found |
			^ folder / found ] ].

	^ nil
]

{ #category : #accessing }
FortranProjectImporter >> srcFolder [

	^srcFolder 
]

{ #category : #accessing }
FortranProjectImporter >> srcFolder: folder [
	"folder is either a String or a FileReference"

	srcFolder := folder isString
		ifTrue: [ folder asFileReference ]
		ifFalse: [ folder ]

]

{ #category : #'error management' }
FortranProjectImporter >> stopOnError [

	^ stopOnError ifNil: [ false ]
]

{ #category : #'error management' }
FortranProjectImporter >> stopOnError: anObject [

	stopOnError := anObject
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
FortranProjectImporter >> withSanityChecks [

	^ withSanityChecks
]

{ #category : #accessing }
FortranProjectImporter >> withSanityChecks: anObject [

	withSanityChecks := anObject
]

{ #category : #constants }
FortranProjectImporter >> workingEsopeName [

	^'tmpEsopeImport'
]

{ #category : #constants }
FortranProjectImporter >> workingFortranName [

	^'tmpFortranImport'
]

{ #category : #constants }
FortranProjectImporter >> workingJsonName [
	
	^'tmpJsonImport'
]

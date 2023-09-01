"
Responsible to import an Esope project into a Famix model

	1. `#handleIncludedFiles` : used to create a dummy subroutine to wrap the statements defined in the included files.

	To find all kind of included files use this shell command: 
	`grep -iIhR --include=\*.{E,e} -E """"#include (\""""|\<)"""" . | cut -d'.' -f2 | sed 's/.$//' | sort | uniq`
	
	                       +----------------------+
	==> *.(inc|seg|..) --> | #handleIncludedFiles | --> *.(inc|seg|...).E ==>
	                       +----------------------+	
	
	2. #annotateEsopeSourcesFrom: Rewrite Esope source file by hidden """"all"""" the esope constructs

	            +-----------------+
	==> *.E --> | PPEsopeRewriter | --> *.E.f
	            +-----------------+
	
	3. #parseAnnotatedFortranSources: use a traditional fortran77 parser to parse to input source and produce an AST in json format.
	
	           +-----------+
	 *.E.f --> | F77Parser | --> AST (json)
	           +-----------+
	
	4. #json2iast: using visitor for converting jsonAST to an intermediate representation (IASTEntity)
	
	                +--------------------+
	 *.ast.json --> | JsonToIASTVisitor  | --> Model IAST
	                +--------------------+
	
	5. #iast2famix: apply an visitor in AST and reproduce the original code
	
	                +---------------------+
	 Model IAST --> | IASTToFamixVisitor  | --> Model Famix
	                +---------------------+
	
	6. #exportToEsope: apply an visitor in AST and reproduce the original code
	
	                 +-------------------------+
	 Model Famix --> | FamixFortran77Resolver  | --> Model Famix
	                 +-------------------------+

	6. #exportToEsope: apply an visitor in AST and reproduce the original code
	
	                      +-------------------------+
	 Model Famix/FAST --> | Carrefour               | --> Model FAST
	                      +-------------------------+
	
	7. #exportToEsope: apply an visitor in AST and reproduce the original code
	
	               +-----------+
	Model FAST --> | Exporter  | --> *.E.copy
	               +-----------+

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
	visitor := IASTToFamixVisitor new.

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

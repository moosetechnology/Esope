Class {
	#name : #FortranProjectImporter,
	#superclass : #Object,
	#category : #'EsopeImporter-Importer'
}

{ #category : #'private - accessing' }
FortranProjectImporter class >> annotateEsopeSourcesFrom [

	(self srcPath allChildrenMatching: '*.E') do: [ :esopeFile | 
		PPEsopeRewriter
			rewriteFrom: esopeFile
			to: (self rewriterPath / ('' join: { 
						  (esopeFile basename removeSuffix: self esopeSuffix).
						  self fortranSuffix })) pathString ]
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> buildPath [

	^ (self rootPath / self buildPathName) asFileReference ensureCreateDirectory
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> buildPathName [

	^ 'build'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> esopeSuffix [

	^ '.E'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> exportAstFrom: astFile [

	self shouldBeImplemented
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> exportToEsope [

	(self parserPath allChildrenMatching: self jsonFileRegex) do: [ 
		:astFile | self exportAstFrom: astFile ]
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> f77FileRegex [

	^ '*.f'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> f77parser [

	^ 'fortran-src-extras serialize -t json -v77l encode'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> famixResolve: aFamixModel [

	1 halt.
	(FamixFortran77Resolver newFrom: aFamixModel) resolve
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> fortranSuffix [

	^ '.f'
]

{ #category : #'instance creation' }
FortranProjectImporter class >> fromPath: srcPath [

	"
	1. #handleIncludedFiles: used to create a dummy subroutine to wrap the statements defined in the included files.

	To find all kind of included files use this shell command: 
	`grep -iIhR --include=\*.{E,e} -E ""#include (\""|\<)"" . | cut -d'.' -f2 | sed 's/.$//' | sort | uniq`
	
	                       +----------------------+
	==> *.(inc|seg|..) --> | #handleIncludedFiles | --> *.(inc|seg|...).E ==>
	                       +----------------------+	
	
	2. #annotateEsopeSourcesFrom: Rewrite Esope source file by hidden ""all"" the esope constructs

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

	| iastmodel famixModel |
	srcPath exists ifFalse: [ 
		Notification signal:
			'' , srcPath pathString , '' , '''No such file or directory'.
		^ self ].

	self handleIncludedFiles.

	self annotateEsopeSourcesFrom.
	self parseAnnotatedFortranSources.

	iastmodel := self json2Iast.
	famixModel := self iast2Famix: iastmodel.
	self famixResolve: famixModel.
	1 halt.
	"self iasttofamix. ""creer le model famix avec l'ensemble des fichiers.
	
	A chaque include, il previent l'importer de la dependance avec le fichier inclu.
		Dictionary (fichier inclu -> l'ensemble des prog Unit qui l'inclu ).
	Verifier que tous les fichiers inclus ont été rencontrés.
		Sinon trouvé (Fichier non trouvé dans prog unit donc pas possible de le traiter).
	"
	"self famixresolve." ""
	"famixModel asMSEString."
	"self exportToEsope: famixModel."
]

{ #category : #'instance creation' }
FortranProjectImporter class >> handleIncludedFiles [

	(self srcPath allChildrenMatching: '*.inc') do: [ :includedFile | 
		(self srcPath / ('' join: { 
				  includedFile basename.
				  '.E' })) pathString asFileReference writeStreamDo: [ :tmpStream | 
			tmpStream
				<< '      subroutine __$__';
				<< Character cr;
				<< includedFile contents;
				<< '      end';
				<< Character cr ] ]
]

{ #category : #'instance creation' }
FortranProjectImporter class >> iast2Famix: iastmodelFiles [

	| visitor |
	visitor := IASTToFamixVisitor new.
	iastmodelFiles collect: [ :iastProgramFile | 
		iastProgramFile accept: visitor ].
	^ visitor model
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> import [

	<script>
	self fromPath: self srcPath
]

{ #category : #'instance creation' }
FortranProjectImporter class >> json2Iast [

	| visitor progFiles |
	visitor := JsonToIASTVisitor new.

	progFiles := (self parserPath allChildrenMatching: '*.json') 
		             collect: [ :jsonFile | 
			             visitor visitProgramFile:
				             (NeoJSONReader fromString: jsonFile contents) ].

	visitor model: progFiles.
	^ progFiles
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> jsonFileRegex [

	^ '*.json'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> jsonSuffix [

	^ '.json'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> parseAnnotatedFortranSources [

	(self rewriterPath allChildrenMatching: self f77FileRegex) do: [ 
		:annotatedFile | self parseToAst: annotatedFile ]
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> parseToAst: f77file [

	| outputFile |
	outputFile := self parserPath
	              / (f77file basename removeSuffix: self fortranSuffix).
	LibC runCommand: ('{1} "{2}" > "{3}.json" 2> "{3}.err"' format: { 
				 self f77parser.
				 f77file pathString.
				 outputFile pathString })
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> parserPath [

	^ (self buildPath / self parserPathName) asFileReference ensureCreateDirectory
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> parserPathName [

	^ 'parser'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> rewritedEsopeSuffix [

	^ '.E'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> rewriterPath [

	^ (self buildPath / self rewriterPathName) asFileReference ensureCreateDirectory
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> rewriterPathName [

	^ 'rewriter'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> rootPath [

	^ self rootPathName asPath
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> rootPathName [

		^ '/tmp/bookstore'

]

{ #category : #'private - accessing' }
FortranProjectImporter class >> searchPaths [

	^ { self srcPath }
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> srcPath [

	^ (self rootPath / self srcPathName) asFileReference
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> srcPathName [

	^ 'src'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> targetPath [

	^ (self buildPath / self targetPathName) asFileReference ensureCreateDirectory
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> targetPathName [

	^ 'target'
]

Class {
	#name : #FortranProjectImporter,
	#superclass : #FortranAbstractImExporter,
	#category : #'EsopeImporter-Importer'
}

{ #category : #'private - accessing' }
FortranProjectImporter class >> buildPathName [

	^ 'build'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> exportAstFrom: astFile [

	self shouldBeImplemented
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> famixResolve: aFamixModel [

	1 halt.
	(FamixFortran77Resolver newFrom: aFamixModel) resolve
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
FortranProjectImporter class >> parserPathName [

	^ 'parser'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> rewriterPathName [

	^ 'rewriter'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> rootPathName [

		^ '/tmp/bookstore'

]

{ #category : #'private - accessing' }
FortranProjectImporter class >> srcPathName [

	^ 'src'
]

{ #category : #'private - accessing' }
FortranProjectImporter class >> targetPathName [

	^ 'target'
]

Class {
	#name : #IASTToFamixVisitor,
	#superclass : #IASTAbstractVisitor,
	#instVars : [
		'f77sourcefile'
	],
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'private-helper' }
IASTToFamixVisitor class >> getBasename: filename [

	^ filename asFileReference basename
]

{ #category : #'private-helper' }
IASTToFamixVisitor class >> getLines: filename [

	^ filename asFileReference contents lines
]

{ #category : #visiting }
IASTToFamixVisitor >> defaultImplicitTyping: firstLetter [

	"God is real . . . unless declared integer"

	"{ 
		($i -> #TypeInteger).
		($j -> #TypeInteger).
		($k -> #TypeInteger).
		($l -> #TypeInteger).
		($m -> #TypeInteger).
		($n -> #TypeInteger) } asDictionary at: $b ifAbsent: [ #TypeReal ]"

	^ ('ijklmn' includes: firstLetter)
		  ifTrue: [ #TypeInteger ]
		  ifFalse: [ #TypeReal ]
]

{ #category : #visiting }
IASTToFamixVisitor >> ensureInclude: name [

	^ (self model allWithType: FamixFortran77Include)
		  detect: [ :each | each name = name ]
		  ifFound: [ :each | each ]
		  ifNone: [ nil ]
]

{ #category : #initialization }
IASTToFamixVisitor >> f77InstrinsicTypes [

	^ { 
		  (#integer -> (FamixFortran77Type new
			    name: 'integer';
			    mooseModel: model;
			    yourself)).
		  (#real -> (FamixFortran77Type new
			    name: 'real';
			    mooseModel: model;
			    yourself)).
		  (#complex -> (FamixFortran77Type new
			    name: 'complex';
			    mooseModel: model;
			    yourself)).
		  (#logical -> (FamixFortran77Type new
			    name: 'logical';
			    mooseModel: model;
			    yourself)).
		  (#character -> (FamixFortran77Type new
			    name: 'character';
			    mooseModel: model;
			    yourself)).
		  (#doublePrecision -> (FamixFortran77Type new
			    name: 'double precision';
			    mooseModel: model;
			    yourself)) } asDictionary
]

{ #category : #accessing }
IASTToFamixVisitor >> f77sourcefile [

	^ f77sourcefile
]

{ #category : #accessing }
IASTToFamixVisitor >> f77sourcefile: anObject [

	f77sourcefile := anObject
]

{ #category : #initialization }
IASTToFamixVisitor >> initialize [

	super initialize.
	self initializeModel.
	f77sourcefile := ''
]

{ #category : #initialization }
IASTToFamixVisitor >> initializeModel [

	model := FamixEsopeModel new name: 'mooseModelF77'.
	"model
		attributeAt: #intrinsicTypes put: self f77InstrinsicTypes;
		attributeAt: #includes put: Dictionary new"
]

{ #category : #testing }
IASTToFamixVisitor >> isDummySubroutine: name [

	^ name sameAs: '__$__'
]

{ #category : #'private-creation' }
IASTToFamixVisitor >> newIndexedFileAnchor: filename [
	| file |
	file := filename asFileReference.
	^ (self newEntity: FamixFortran77IndexedFileAnchor)
		  startLine: 1;
		  endLine: (file
				   ifExists: [ (self class getLines: filename) size ]
				   ifAbsent: [ 1 ]);
		  startColumn: 1;
		  endColumn: (file
				   ifExists: [ (self class getLines: filename) last size + 1]
				   ifAbsent: [ 1 ]);
		  fileName: file basename;
		  yourself
]

{ #category : #visiting }
IASTToFamixVisitor >> visit: anIASTModel [

	^ anIASTModel accept: self
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTBlockData: aBlockData [

	| blockdata |

	blockdata := (self newEntity: FamixFortran77PUBlockdata)
						sourceAnchor: (self visitIndexedFileAnchor: aBlockData sourceAnchor);
						name: aBlockData entityName;
						yourself.
	stack push: blockdata.
	
	"prossess accesses"
	aBlockData accesses do: [ :access | 
		blockdata addAccess: (access accept: self) ].

	"prossess the comments inside this progUnit"
	aBlockData localComments do: [ :comment | 
		blockdata addComment: (comment accept: self) ].

	stack pop.
	^ blockdata
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTComment: aComment [

	| comment |
	comment := aComment isProgUnit
		           ifTrue: [ self newEntity: FamixFortran77PUComment ]
		           ifFalse: [ 
			           (self newEntity: FamixFortran77Comment)
				           isEsope: aComment isEsope;
				           commentedEntity: stack top ].
	^ comment
		  sourceAnchor: (self visitIndexedFileAnchor: aComment sourceAnchor);
		  content: aComment text;
		  yourself
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTEsopePointer: aPointerVarDeclaration [

	| varPointer |
	varPointer := aPointerVarDeclaration accept:
		              (self spawn: IASTToEsopeVisitor).
	stack top addLocalVariable: varPointer.
	stack top symbolTable at: varPointer name put: varPointer.
	^ varPointer
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTEsopeSegCommand: aSegmentCommand [

	^ aSegmentCommand accept: (self spawn: IASTToEsopeVisitor)
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTEsopeSegment: aSegment [

	| segment |
	segment := aSegment accept: (self spawn: IASTToEsopeVisitor).

	self flag: #FIXME. "link the segment to the prograUnit in which its defined"
	stack top addType: segment.

	^ segment
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTFunction: aFunction [

	| function |
	function := self
		            visitIASTProgramUnit: aFunction
		            toFamix: FamixFortran77PUFunction.
	aFunction parameters do: [ :parameter | 
		function addParameter: (parameter accept: self) ].

	^ function
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTImplicit: anImplicit [

	self flag: #TODO.
	"put implicit info into the FamixFortranProgramFile"
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTInclude: anInclude [

	self flag: #FIXME.
	"how to set the source ?"
	^ (self newEntity: FamixFortran77Include)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: anInclude sourceAnchor);
		  filename: anInclude entityName;
		  includedBy: stack top;
		  "source: stack top programFile;"yourself
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTIncludedFile: anIncludedFile [

	anIncludedFile sourceAnchor
		startLine: anIncludedFile sourceAnchor startLine + 1;
		endLine: anIncludedFile sourceAnchor endLine - 1.

	^ self
		  visitIASTProgramUnit: anIncludedFile
		  toFamix: FamixFortran77IncludedFile
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTInvocation: anInvocation [

	^ (self newEntity: FamixFortran77Invocation)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: anInvocation sourceAnchor);
		  attributeAt: #entity put: anInvocation;
		  sender: stack top;
		  yourself
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTMainProgram: aMainProgram [

	^ self
		  visitIASTProgramUnit: aMainProgram
		  toFamix: FamixFortran77PUMain
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTProgramFile: aProgramFile [

	| progFile |
	self f77sourcefile: aProgramFile filename.
	progFile := (self newEntity: FamixFortran77ProgramFile)
		filename: aProgramFile filename;
		name: aProgramFile filename;
		yourself.

	stack push: progFile.

	aProgramFile progUnits do: [ :progUnit | 
		progFile addProgramUnit: (progUnit accept: self) ].

	stack pop.
	^progFile
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTProgramUnit: aProgramUnit toFamix: aFamixFortranClass [

	| progUnit |
	progUnit := (self newEntity: aFamixFortranClass)
		            sourceAnchor:
			            (self visitIndexedFileAnchor: aProgramUnit sourceAnchor);
		            name: aProgramUnit entityName;
		            yourself.
	stack push: progUnit.

	self createSymbolTableFor: progUnit.

	aProgramUnit body ifNotNil: [ :body | 
		body do: [ :node | 
			node isArray
				ifTrue: [ 
					self flag: #FIXME. "1 halt."
					node flattened
						reject: [ :each | each isPoint ]
						thenDo: [ :stmt | stmt accept: self ] ]
				ifFalse: [ node accept: self ] ] ].

	"aProgramUnit localVariables do: [ :localVariable | 
		progUnit addLocalVariable: (localVariable accept: self) ].

	aProgramUnit accesses do: [ :access | 
		progUnit addAccess: (access accept: self) ].
	
	aProgramUnit invocations do: [ :invocation | 
		progUnit addOutgoingInvocation: (invocation accept: self) ].
	
	aProgramUnit localComments do: [ :comment | 
		progUnit addComment: (comment accept: self) ]."

	progUnit attributeAt: #implicits put: aProgramUnit implicits.

	stack pop.
	^ progUnit
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTSubroutine: aSubroutine [

	| subroutine |
	subroutine := self
		              visitIASTProgramUnit: aSubroutine
		              toFamix: FamixFortran77PUSubroutine.
	aSubroutine parameters do: [ :parameter | 
		subroutine addParameter: (parameter accept: self) ].

	^ subroutine
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTVarEso: aVarEso [

	| varsAccesses |
	varsAccesses := aVarEso accept: (self spawn: IASTToEsopeVisitor).
	"varsAccesses accesses:
		(aVarEso entities collect: [ :entity | entity accept: self ])."
	self flag: #FIXME. "Add this to the current programUnit"
	^ varsAccesses
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTVarEsoAt: aVarEso [

	^ self visitIASTVarEso: aVarEso
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTVarEsoSl: aVarEso [

	^ self visitIASTVarEso: aVarEso
]

{ #category : #visiting }
IASTToFamixVisitor >> visitIASTVariable: aVariable [

	| var |
	var := (self newEntity: stack top localVariableClass)
		       sourceAnchor:
			       (self visitIndexedFileAnchor: aVariable sourceAnchor);
		       name: aVariable entityName;
		       declaredType: (self visitIASTTypeRef: aVariable typeSpec);
		       yourself.
	"stack top symbolTable at: var name put: var."
	self symbolTable: stack top at: var name put: var. 
	stack top addLocalVariable: var.
	^ var
]

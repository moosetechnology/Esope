Class {
	#name : #IASTToFortranVisitor,
	#superclass : #IASTAbstractFamixVisitor,
	#instVars : [
		'f77sourcefile'
	],
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'private-helper' }
IASTToFortranVisitor class >> getBasename: filename [

	^ filename asFileReference basename
]

{ #category : #'private-helper' }
IASTToFortranVisitor class >> getLines: filename [

	^ filename asFileReference contents lines
]

{ #category : #accessing }
IASTToFortranVisitor >> f77sourcefile [

	^ f77sourcefile
]

{ #category : #accessing }
IASTToFortranVisitor >> f77sourcefile: anObject [

	f77sourcefile := anObject
]

{ #category : #initialization }
IASTToFortranVisitor >> initialize [

	super initialize.
	model := FamixEsopeModel new.
	f77sourcefile := ''
]

{ #category : #testing }
IASTToFortranVisitor >> isDummySubroutine: name [

	^ name sameAs: '__$__'
]

{ #category : #visiting }
IASTToFortranVisitor >> visit: anIASTModel [

	^ anIASTModel accept: self
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTBlockData: aBlockData [

	| blockdata |
	blockdata := self model newPUBlockdata
		             sourceAnchor:
			             (self visitIndexedFileAnchor: aBlockData sourceAnchor);
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
IASTToFortranVisitor >> visitIASTComment: aComment [

	| comment |
	comment := aComment isProgUnit
		           ifTrue: [ self newEntity: FamixF77PUComment ]
		           ifFalse: [ 
			           (self newEntity: FamixF77Comment)
				           isEsope: aComment isEsope;
				           commentedEntity: stack top ].
	^ comment
		  sourceAnchor: (self visitIndexedFileAnchor: aComment sourceAnchor);
		  content: aComment text;
		  yourself
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTEsopePointer: aPointerVarDeclaration [

	| varPointer |
	varPointer := aPointerVarDeclaration accept:
		              (self spawn: IASTToEsopeVisitor).
	stack top addLocalVariable: varPointer.
	stack top symbolTable at: varPointer name put: varPointer.
	^ varPointer
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTEsopeSegCommand: aSegmentCommand [

	^ aSegmentCommand accept: (self spawn: IASTToEsopeVisitor)
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTEsopeSegment: aSegment [

	| segment |
	segment := aSegment accept: (self spawn: IASTToEsopeVisitor).

	self flag: #FIXME. "link the segment to the prograUnit in which its defined"
	stack top addType: segment.

	^ segment
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTFunction: aFunction [

	| function |
	function := self
		            visitIASTProgramUnit: aFunction
		            toFamix: FamixF77PUFunction.
	aFunction parameters do: [ :parameter | 
		function addParameter: (parameter accept: self) ].

	^ function
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTImplicit: anImplicit [

	self flag: #TODO.
	"put implicit info into the FamixFortranProgramFile"
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTInclude: anInclude [

	self flag: #FIXME.
	"how to set the source ?"
	^ self model newInclude
		  sourceAnchor:
			  (self visitIndexedFileAnchor: anInclude sourceAnchor);
		  filename: anInclude entityName;
		  includedBy: stack top;
		  yourself
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTIncludedFile: anIncludedFile [

	anIncludedFile sourceAnchor
		startLine: anIncludedFile sourceAnchor startLine + 1;
		endLine: anIncludedFile sourceAnchor endLine - 1.

	^ self
		  visitIASTProgramUnit: anIncludedFile
		  toFamix: FamixF77IncludedFile
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTInvocation: anInvocation [

	^ self model newInvocation
		  sourceAnchor:
			  (self visitIndexedFileAnchor: anInvocation sourceAnchor);
		  attributeAt: #entity put: anInvocation;
		  sender: stack top;
		  yourself
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTMainProgram: aMainProgram [

	^ self
		  visitIASTProgramUnit: aMainProgram
		  toFamix: FamixF77PUMain
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTProgramFile: aProgramFile [

	| progFile |
	self f77sourcefile: aProgramFile filename.
	progFile := self model newProgramFile
		            filename: aProgramFile filename;
		            name: aProgramFile filename;
		            yourself.

	stack push: progFile.

	aProgramFile progUnits do: [ :progUnit |
		progFile addProgramUnit: (progUnit accept: self) ].

	stack pop.
	^ progFile
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTProgramUnit: aProgramUnit toFamix: aFamixFortranClass [

	| progUnit |
	progUnit := (self newEntity: aFamixFortranClass)
		            sourceAnchor:
			            (self visitIndexedFileAnchor: aProgramUnit sourceAnchor);
		            name: aProgramUnit entityName;
		            yourself.
	stack push: progUnit.

	self createSymbolTableFor: progUnit.

	aProgramUnit body ifNotNil: [ :body | 
			body deepFlatten do: [ :expr | expr accept: self ]
	].

	progUnit attributeAt: #implicits put: aProgramUnit implicits.

	stack pop.
	^ progUnit
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTSubroutine: aSubroutine [

	| subroutine |
	subroutine := self
		              visitIASTProgramUnit: aSubroutine
		              toFamix: FamixF77PUSubroutine.
	aSubroutine parameters do: [ :parameter | 
		subroutine addParameter: (parameter accept: self) ].

	^ subroutine
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTVarEso: aVarEso [

	| varsAccesses |
	varsAccesses := aVarEso accept: (self spawn: IASTToEsopeVisitor).
	"varsAccesses accesses:
		(aVarEso entities collect: [ :entity | entity accept: self ])."
	self flag: #FIXME. "Add this to the current programUnit"
	^ varsAccesses
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTVarEsoAt: aVarEso [

	^ self visitIASTVarEso: aVarEso
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTVarEsoSl: aVarEso [

	^ self visitIASTVarEso: aVarEso
]

{ #category : #visiting }
IASTToFortranVisitor >> visitIASTVariable: aVariable [

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

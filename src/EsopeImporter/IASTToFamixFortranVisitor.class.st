Class {
	#name : 'IASTToFamixFortranVisitor',
	#superclass : 'IASTAbstractFamixVisitor',
	#instVars : [
		'f77sourcefile'
	],
	#category : 'EsopeImporter-Visitor',
	#package : 'EsopeImporter',
	#tag : 'Visitor'
}

{ #category : 'private-helper' }
IASTToFamixFortranVisitor class >> getBasename: filename [

	^ filename asFileReference basename
]

{ #category : 'private-helper' }
IASTToFamixFortranVisitor class >> getLines: filename [

	^ filename asFileReference contents lines
]

{ #category : 'accessing' }
IASTToFamixFortranVisitor >> f77sourcefile [

	^ f77sourcefile
]

{ #category : 'accessing' }
IASTToFamixFortranVisitor >> f77sourcefile: anObject [

	f77sourcefile := anObject
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> iASTProgramUnit: aProgramUnit toFamix: aFamixFortranClass [

	| progUnit |
	progUnit := (self newEntity: aFamixFortranClass)
		            sourceAnchor:
			            (self visitIndexedFileAnchor: aProgramUnit sourceAnchor);
		            name: aProgramUnit entityName;
		            yourself.
	stack push: progUnit.

	self createSymbolTableFor: progUnit.

	aProgramUnit body ifNotNil: [ :body | 
		body deepFlatten do: [ :each |
			(each isNil or: [ each isPoint])
			ifFalse: [ each accept: self] ]
	].

	stack pop.
	^ progUnit
]

{ #category : 'initialization' }
IASTToFamixFortranVisitor >> initialize [

	super initialize.
	model := FamixEsopeModel new.
	f77sourcefile := ''
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> ioStatements [

	^ #( write read close open rewind backspace decode encode endfile
	     inquire )
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visit: anIASTModel [

	^ anIASTModel accept: self
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitExpression: anExpression [

	anExpression isCollection
		ifFalse: [ anExpression accept: self ]
		ifTrue: [ 
			anExpression do: [ :subExpr |
				self visitExpression: subExpr ]
		]
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTBlockData: aBlockData [

	| blockdata |
	blockdata := self model newPUBlockdata
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

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTComment: aComment [

	^(self newEntity: FamixF77Comment)
		content: aComment text ;
		commentedEntity: stack top ;
		sourceAnchor: (self visitIndexedFileAnchor: aComment sourceAnchor) ;
		isEsope: aComment isEsope ;
		yourself
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTEsopePointer: aPointerVarDeclaration [

	| varPointer |
	varPointer := aPointerVarDeclaration accept:
		              (self spawn: IASTToFamixEsopeVisitor).
	stack top addLocalVariable: varPointer.
	stack top symbolTable at: varPointer name put: varPointer.
	^ varPointer
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTEsopeSegCommand: aSegmentCommand [

	^ aSegmentCommand accept: (self spawn: IASTToFamixEsopeVisitor)
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTEsopeSegment: aSegment [

	| segment |
	segment := aSegment accept: (self spawn: IASTToFamixEsopeVisitor).

	self flag: #FIXME. "link the segment to the prograUnit in which its defined"
	stack top addType: segment.

	^ segment
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTFunction: aFunction [

	| function |
	function := self
		            iASTProgramUnit: aFunction
		            toFamix: FamixF77PUFunction.
	aFunction returnType ifNotNil: [ 
		 function declaredType: (aFunction returnType accept: self)
	].

	aFunction parameters do: [ :parameter | 
		function addParameter: (parameter accept: self) ].

	^ function
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTIOStatement: anIOStatement [

	^ (anIOStatement arguments
		   ifNotNil: [ :arguments |
			   arguments collect: [ :argument | argument accept: self ] ]
		   ifNil: [ #(  ) ]) , (anIOStatement format
		   ifNotNil: [ :format |
		   format collect: [ :each | each accept: self ] ]
		   ifNil: [ #(  ) ])
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTImplicit: anImplicit [

	anImplicit rules ifNotNil: [ :rules |
		(stack top
			 attributeAt: #implicits
			 ifAbsentPut: [ OrderedCollection new ]
		) addAll: rules 
	]
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTInclude: anInclude [

	self flag: #FIXME.
	"how to set the source ?"
	^ self model newInclude
		  sourceAnchor:
			  (self visitIndexedFileAnchor: anInclude sourceAnchor);
		  filename: anInclude entityName;
		  includedBy: stack top;
		  yourself
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTIncludedFile: anIncludedFile [

	anIncludedFile sourceAnchor
		startLine: anIncludedFile sourceAnchor startLine + 1;
		endLine: anIncludedFile sourceAnchor endLine - 1.

	^ self
		  iASTProgramUnit: anIncludedFile
		  toFamix: FamixF77IncludedFile
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTInvocation: anInvocation [

	anInvocation arguments do: [ :expression |
		self visitExpression: expression ].

	^ self model newInvocation
		sourceAnchor:
			(self visitIndexedFileAnchor: anInvocation sourceAnchor);
		attributeAt: #entity put: anInvocation;
		signature: anInvocation entityName ;
		sender: stack top;
		yourself
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTMainProgram: aMainProgram [

	^ self
		  iASTProgramUnit: aMainProgram
		  toFamix: FamixF77PUMain
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTProgramFile: aProgramFile [

	| progFile |
	self f77sourcefile: aProgramFile filename.
	progFile := self model newProgramFile
		            filename: aProgramFile filename;
		            name: aProgramFile filename;
		            yourself.

	stack push: progFile.

	aProgramFile body do: [ :child || famixComment |
		famixComment := child accept: self.
		child isComment
		ifTrue: [ famixComment commentedEntity: progFile ]
		ifFalse: [ progFile addProgramUnit: famixComment ]
	].

	stack pop.
	^ progFile
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTStatementFunction: aStatementFunctionNode [

	| function |
	function := self
		iASTProgramUnit: aStatementFunctionNode
		toFamix: FamixF77StatementFunction.
	aStatementFunctionNode parameters do: [ :parameter | 
		function addParameter: (parameter accept: self) ].
	
	stack top addStatementFunction: function.

	^ function
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTSubroutine: aSubroutine [

	| subroutine |
	subroutine := self
		iASTProgramUnit: aSubroutine
		toFamix: FamixF77PUSubroutine.

	aSubroutine parameters do: [ :parameter | 
		subroutine addParameter: (parameter accept: self) ].

	^ subroutine
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTVarEso: aVarEso [

	| varsAccesses |
	varsAccesses := aVarEso accept: (self spawn: IASTToFamixEsopeVisitor).
	"varsAccesses accesses:
		(aVarEso entities collect: [ :entity | entity accept: self ])."
	self flag: #FIXME. "Add this to the current programUnit"
	^ varsAccesses
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTVarEsoAt: aVarEso [

	^ self visitIASTVarEso: aVarEso
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTVarEsoSl: aVarEso [

	^ self visitIASTVarEso: aVarEso
]

{ #category : 'visiting' }
IASTToFamixFortranVisitor >> visitIASTVariable: aVariable [

	| var |
	var := (self newEntity: stack top localVariableClass)
		       sourceAnchor:
			       (self visitIndexedFileAnchor: aVariable sourceAnchor);
		       name: aVariable entityName;
				 isEsope: aVariable isEsope;
		       declaredType: (self visitIASTTypeRef: aVariable typeSpec);
		       yourself.
	"stack top symbolTable at: var name put: var."
	self symbolTable: stack top at: var name put: var. 
	stack top addLocalVariable: var.
	^ var
]

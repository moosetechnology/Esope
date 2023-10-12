Class {
	#name : #IASTToFamixEsopeVisitor,
	#superclass : #IASTAbstractFamixVisitor,
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'private-creation' }
IASTToFamixEsopeVisitor >> newType: typeName sourceAnchor: sourceAnchor [

	sourceAnchor startColumn: sourceAnchor endColumn - typeName size.
	^ (self retrieveTypeFrom: typeName) name: typeName
	"sourceAnchor: (self visitIndexedFileAnchor: sourceAnchor);"
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTEsopePointer: aPointerVar [

	| varsNames |
	varsNames := aPointerVar entityName substrings: '.'.
	varsNames size < 2 ifTrue: [ ^ self ].
	"declaredType:
			  (self
				   newType: varsNames second
				   sourceAnchor: aPointerVar sourceAnchor);"
	^ (self model newVariableNamed: varsNames first)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aPointerVar sourceAnchor);
		  isEsope: true;
		  segment: varsNames second;
		  yourself
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTEsopeSegCommand: aSegmentCommand [

	^ (self model newCommand)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aSegmentCommand sourceAnchor);
		  attributeAt: #entity put: aSegmentCommand;
		  commandName: aSegmentCommand esopeCommand;
		  accessor: stack top;
		  yourself
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTEsopeSegment: aSegment [

	| segment |
	segment := self model newSegment
		           sourceAnchor:
			           (self visitIndexedFileAnchor: aSegment sourceAnchor);
		           name: aSegment entityName;
		           yourself.
	stack push: segment.
	self createSymbolTableFor: segment.
	segment attributes: (aSegment declarations collect: [ :variable |
			 variable accept: (self spawn: IASTToFamixFortranVisitor) ]).

	^ stack pop
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTInvocation: anInvocation [

	"In Esope vistior, we know that an invocation is actually an access to an array
	so we create access to each 'argument' (actually indices of the array)
	+ we create an access to the array itself (the 'functino' invoked)"

	| arguments |
	arguments := anInvocation arguments collect: [ :arg | 
		             arg isCollection
			             ifTrue: [ arg do: [ :each | each accept: self ] ]
			             ifFalse: [ arg accept: self ] ].

	^self createFamixF77Access: anInvocation
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTParameter: aParameter [

	^ self createFamixF77Access: aParameter
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTVarEsoAr: aVarEsoAr [

	self flag: #TODO.
	1halt.
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTVarEsoAt: aVarEsoAt [

	| famixAccess attributeAccess  |
	aVarEsoAt entities size < 2 ifTrue: [ ^ self ].

	famixAccess := (aVarEsoAt entities first) accept: self.

	attributeAccess := (aVarEsoAt entities second) accept: self.
	attributeAccess attributeAt: #parentAccess put: famixAccess.
	famixAccess attributeAt: #attributeAccess put: attributeAccess.

	^famixAccess
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTVarEsoSl: aVarEsoSl [

	self flag: #TODO.

	^ aVarEsoSl entities collect: [ :each | each accept: self ]
]

{ #category : #visiting }
IASTToFamixEsopeVisitor >> visitIASTVariable: aVariable [

	^ (self newEntity: FamixFortranAttribute)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aVariable sourceAnchor);
		  name: aVariable entityName;
		  declaredType: (self visitIASTTypeRef: aVariable typeSpec);
		  yourself
]

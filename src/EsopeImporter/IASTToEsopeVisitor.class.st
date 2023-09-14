Class {
	#name : #IASTToEsopeVisitor,
	#superclass : #IASTAbstractFamixVisitor,
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'private-creation' }
IASTToEsopeVisitor >> newType: typeName sourceAnchor: sourceAnchor [

	sourceAnchor startColumn: sourceAnchor endColumn - typeName size.
	^ (self retrieveTypeFrom: typeName) name: typeName
	"sourceAnchor: (self visitIndexedFileAnchor: sourceAnchor);"
]

{ #category : #visiting }
IASTToEsopeVisitor >> visitIASTEsopePointer: aPointerVar [

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
IASTToEsopeVisitor >> visitIASTEsopeSegCommand: aSegmentCommand [

	^ (self model newCommand)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aSegmentCommand sourceAnchor);
		  attributeAt: #entity put: aSegmentCommand;
		  commandName: aSegmentCommand esopeCommand;
		  accessor: stack top;
		  yourself
]

{ #category : #visiting }
IASTToEsopeVisitor >> visitIASTEsopeSegment: aSegment [

	| segment |
	segment := self model newSegment
		           sourceAnchor:
			           (self visitIndexedFileAnchor: aSegment sourceAnchor);
		           name: aSegment entityName;
		           yourself.
	stack push: segment.
	self createSymbolTableFor: segment.
	segment attributes: (aSegment declarations collect: [ :variable |
			 variable accept: (self spawn: IASTToFortranVisitor) ]).

	^ stack pop
]

{ #category : #visiting }
IASTToEsopeVisitor >> visitIASTInvocation: anInvocation [

	| arguments |
	arguments := anInvocation arguments collect: [ :arg | 
		             arg isArray
			             ifTrue: [ arg collect: [ :each | each accept: self ] ]
			             ifFalse: [ arg accept: self ] ].

	^ ({ (self createFamixF77Access: anInvocation) } , arguments)
		  flattened
]

{ #category : #visiting }
IASTToEsopeVisitor >> visitIASTParameter: aParameter [

	^ self createFamixF77Access: aParameter
]

{ #category : #visiting }
IASTToEsopeVisitor >> visitIASTVarEsoAr: aVarEsoAr [

	self flag: #TODO.
	1halt.
]

{ #category : #visiting }
IASTToEsopeVisitor >> visitIASTVarEsoAt: aVarEsoAt [

	| pointerAccess attributeAccess pointer attributes attribute |
	aVarEsoAt entities size < 2 ifTrue: [ ^ self ].

	pointerAccess := aVarEsoAt entities first.
	attributeAccess := aVarEsoAt entities second.

	pointer := pointerAccess class = IASTParameter
		           ifTrue: [ pointerAccess accept: self ]
		           ifFalse: [ 
		           pointerAccess accept: (self spawn: IASTToFortranVisitor) ].	
	
	attributes := attributeAccess accept: self.
	attribute := attributes isArray
		             ifTrue: [ attributes first ]
		             ifFalse: [ attributes ].
	attribute attributeAt: #pointer put: pointerAccess.

	^ { 
		  pointer.
		  attribute }
]

{ #category : #visiting }
IASTToEsopeVisitor >> visitIASTVarEsoSl: aVarEsoSl [

	self flag: #TODO.

	^ aVarEsoSl entities collect: [ :each | each accept: self ]
]

{ #category : #visiting }
IASTToEsopeVisitor >> visitIASTVariable: aVariable [

	^ (self newEntity: FamixFortranAttribute)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aVariable sourceAnchor);
		  name: aVariable entityName;
		  declaredType: (self visitIASTTypeRef: aVariable typeSpec);
		  yourself
]

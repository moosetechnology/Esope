Class {
	#name : 'IASTToFamixEsopeVisitor',
	#superclass : 'IASTAbstractFamixVisitor',
	#category : 'EsopeImporter-Visitor',
	#package : 'EsopeImporter',
	#tag : 'Visitor'
}

{ #category : 'private - helpers' }
IASTToFamixEsopeVisitor >> checkForModSuffix: aFamixEsopeCommand [ 
	| value |
	value := aFamixEsopeCommand attributeAt: #entity ifAbsent: [ nil ].
	value ifNotNil: [ 
		| name index |
		name := value entityName.
		index := name indexOf: $*.
		index > 1
			ifTrue: [
				value entityName: (name copyFrom: 1 to: index - 1).
				((name copyFrom: index + 1 to: name size) asLowercase = 'nomod')
					ifTrue: [ value isWritable: false ]
					ifFalse: [ value isWritable: true ]
			]
	]
]

{ #category : 'visiting' }
IASTToFamixEsopeVisitor >> isAFortranIntrinsicType: typeName [

	^ (#( character integer logical complex real 'double precision' )
		   includes: typeName) not
]

{ #category : 'private-creation' }
IASTToFamixEsopeVisitor >> newEsopeCommand: esopeCommandName [

	| selector |
	selector := ('newCommand' , esopeCommandName asLowercase capitalized) asSymbol.

	^self model perform: selector
]

{ #category : 'private-creation' }
IASTToFamixEsopeVisitor >> newType: typeName sourceAnchor: sourceAnchor [

	sourceAnchor startColumn: sourceAnchor endColumn - typeName size.
	^ (self retrieveTypeFrom: typeName) name: typeName
	"sourceAnchor: (self visitIndexedFileAnchor: sourceAnchor);"
]

{ #category : 'visiting' }
IASTToFamixEsopeVisitor >> visitIASTEsopePointer: aPointerVar [

	| varsNames pointer |
	varsNames := $. split: aPointerVar entityName.

	pointer := (self model newVariableNamed: varsNames first)
		sourceAnchor: (self visitIndexedFileAnchor: aPointerVar sourceAnchor);
		isEsope: true;
		yourself.
	
	varsNames size > 1 
		ifTrue: [ pointer segment: varsNames second ].

	^ pointer
]

{ #category : 'visiting' }
IASTToFamixEsopeVisitor >> visitIASTEsopeSegCommand: aSegmentCommand [

	| esopeCommand |

	esopeCommand := (self newEsopeCommand: aSegmentCommand esopeCommand)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aSegmentCommand sourceAnchor) ;
		  attributeAt: #entity put: aSegmentCommand ;
		  accessor: stack top ;
		  yourself.
		
	self checkForModSuffix: esopeCommand.
	^esopeCommand 
]

{ #category : 'visiting' }
IASTToFamixEsopeVisitor >> visitIASTEsopeSegment: aSegment [

	| segment |
	
	self flag: '#TODO: if we have accesses in the segment, we have to deal with them
		see visitIASTVariable:
	'.
	
	segment := self model newSegment
		           sourceAnchor:
			           (self visitIndexedFileAnchor: aSegment sourceAnchor) ;
		           name: aSegment entityName asLowercase ;
		           yourself.
	stack push: segment.
	self createSymbolTableFor: segment.
	segment attributes: (aSegment declarations collect: [ :variable |
			variable isEsope: (self isAFortranIntrinsicType: variable typeSpec entityName).
			variable accept: (self spawn: IASTToFamixFortranVisitor) ]).

	^ stack pop
]

{ #category : 'visiting' }
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

{ #category : 'visiting' }
IASTToFamixEsopeVisitor >> visitIASTParameter: aParameter [

	^ self createFamixF77Access: aParameter
]

{ #category : 'visiting' }
IASTToFamixEsopeVisitor >> visitIASTVarEsoAt: aVarEsoAt [

	| famixAccess attributeAccess  |
	aVarEsoAt entities size < 2 ifTrue: [ ^ self ].

	famixAccess := (aVarEsoAt entities first) accept: self.

	attributeAccess := (aVarEsoAt entities second) accept: self.
	attributeAccess attributeAt: #parentAccess put: famixAccess.

	^famixAccess
]

{ #category : 'visiting' }
IASTToFamixEsopeVisitor >> visitIASTVarEsoSl: aVarEsoSl [

	self flag: #TODO.

	^ aVarEsoSl entities collect: [ :each | each accept: self ]
]

{ #category : 'visiting' }
IASTToFamixEsopeVisitor >> visitIASTVariable: aVariable [

	^ (self newEntity: FamixFortranAttribute)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aVariable sourceAnchor);
		  name: aVariable entityName;
		  declaredType: (self visitIASTTypeRef: aVariable typeSpec);
		  yourself
]

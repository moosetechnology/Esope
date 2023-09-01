Class {
	#name : #IASTAbstractVisitor,
	#superclass : #Object,
	#instVars : [
		'model',
		'stack'
	],
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'private-creation' }
IASTAbstractVisitor >> createFamixF77Access: anIastObject [

	^ (self newEntity: FamixFortran77Access)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: anIastObject sourceAnchor);
		  attributeAt: #entity put: anIastObject;
		  accessor: stack top;
		  yourself
]

{ #category : #'private-creation' }
IASTAbstractVisitor >> createImplicitsDictionaryFor: anEntity [

	anEntity attributeAt: #dicImplicit put: self defaultImplicit
]

{ #category : #'private-creation' }
IASTAbstractVisitor >> createSymbolTableFor: anEntity [

	anEntity attributeAt: #symbolTable put: Dictionary new
]

{ #category : #'private-creation' }
IASTAbstractVisitor >> defaultImplicit [

	^ (($a to: $z) collect: [ :char | 
		   ('ijklmn' includes: char)
			   ifTrue:  [ char -> #integer ]
			   ifFalse: [ char -> #real ] ]) asDictionary
]

{ #category : #accessing }
IASTAbstractVisitor >> initialize [

	super initialize.
	stack := Stack new.
]

{ #category : #accessing }
IASTAbstractVisitor >> model [

	^ model
]

{ #category : #accessing }
IASTAbstractVisitor >> model: anObject [

	model := anObject
]

{ #category : #'private-creation' }
IASTAbstractVisitor >> newEntity: aClass [

	^ aClass new
		  mooseModel: model;
		  yourself
]

{ #category : #visiting }
IASTAbstractVisitor >> spawn: aVisitorClass [
	^aVisitorClass new
		model: self model ;
		stack: self stack ;
		yourself
]

{ #category : #accessing }
IASTAbstractVisitor >> stack [

	^ stack
]

{ #category : #accessing }
IASTAbstractVisitor >> stack: anObject [

	stack := anObject
]

{ #category : #visiting }
IASTAbstractVisitor >> symbolTable: anEntity at: key [

	^ anEntity attributeAt: key asSymbol ifAbsent: [  ]
]

{ #category : #visiting }
IASTAbstractVisitor >> symbolTable: anEntity at: key put: value [

	(self symbolTable: anEntity at: #symbolTable)
		at: key asSymbol
		put: value
]

{ #category : #visiting }
IASTAbstractVisitor >> visitIASTParameter: aParameter [

	^ (self newEntity: FamixFortran77Parameter)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aParameter sourceAnchor);
		  name: aParameter entityName;
		  yourself
]

{ #category : #visiting }
IASTAbstractVisitor >> visitIASTTypeRef: aType [

	self flag: #TODO. "How to deal with length and kind for example character*20 name produce aType object like:
	- sourceAnchor: ...
	- entityName: TypeCharacter
	- kind: nil"
	^(self newEntity: FamixFortran77Type)
		sourceAnchor: (self visitIndexedFileAnchor: aType sourceAnchor);
		name: aType entityName;
		length: aType length;
		kind: aType kind;
		yourself
]

{ #category : #visiting }
IASTAbstractVisitor >> visitIASTVarAccess: aVarAccess [

	^ (self createFamixF77Access: aVarAccess) isWrite: aVarAccess isWrite
]

{ #category : #visiting }
IASTAbstractVisitor >> visitIndexedFileAnchor: aSourceAnchor [

	^ aSourceAnchor 
		ifNil: [ nil ]
		ifNotNil: [ 
		  (self newEntity: FamixFortran77IndexedFileAnchor)
			  startLine: aSourceAnchor startLine;
			  endLine: aSourceAnchor endLine;
			  startColumn: aSourceAnchor startColumn;
			  endColumn: aSourceAnchor endColumn;
			  fileName: aSourceAnchor fileName;
			  yourself ]
]

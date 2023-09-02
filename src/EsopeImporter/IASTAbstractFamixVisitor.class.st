Class {
	#name : #IASTAbstractFamixVisitor,
	#superclass : #Object,
	#instVars : [
		'model',
		'stack'
	],
	#category : #'EsopeImporter-Visitor'
}

{ #category : #'private-creation' }
IASTAbstractFamixVisitor >> createFamixF77Access: anIastObject [

	^ (self newEntity: FamixFortran77Access)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: anIastObject sourceAnchor);
		  attributeAt: #entity put: anIastObject;
		  accessor: stack top;
		  yourself
]

{ #category : #'private-creation' }
IASTAbstractFamixVisitor >> createImplicitsDictionaryFor: anEntity [

	anEntity attributeAt: #dicImplicit put: self defaultImplicit
]

{ #category : #'private-creation' }
IASTAbstractFamixVisitor >> createSymbolTableFor: anEntity [

	anEntity attributeAt: #symbolTable put: Dictionary new
]

{ #category : #'private-creation' }
IASTAbstractFamixVisitor >> defaultImplicit [

	^ (($a to: $z) collect: [ :char | 
		   ('ijklmn' includes: char)
			   ifTrue:  [ char -> #integer ]
			   ifFalse: [ char -> #real ] ]) asDictionary
]

{ #category : #accessing }
IASTAbstractFamixVisitor >> initialize [

	super initialize.
	stack := Stack new.
]

{ #category : #accessing }
IASTAbstractFamixVisitor >> model [

	^ model
]

{ #category : #accessing }
IASTAbstractFamixVisitor >> model: anObject [

	model := anObject
]

{ #category : #'private-creation' }
IASTAbstractFamixVisitor >> newEntity: aClass [

	^ aClass new
		  mooseModel: model;
		  yourself
]

{ #category : #visiting }
IASTAbstractFamixVisitor >> spawn: aVisitorClass [
	^aVisitorClass new
		model: self model ;
		stack: self stack ;
		yourself
]

{ #category : #accessing }
IASTAbstractFamixVisitor >> stack [

	^ stack
]

{ #category : #accessing }
IASTAbstractFamixVisitor >> stack: anObject [

	stack := anObject
]

{ #category : #visiting }
IASTAbstractFamixVisitor >> symbolTable: anEntity at: key [

	^ anEntity attributeAt: key asSymbol ifAbsent: [  ]
]

{ #category : #visiting }
IASTAbstractFamixVisitor >> symbolTable: anEntity at: key put: value [

	(self symbolTable: anEntity at: #symbolTable)
		at: key asSymbol
		put: value
]

{ #category : #visiting }
IASTAbstractFamixVisitor >> visitIASTCollection: iastCollection [
	^iastCollection entities collect: [ :iastEntity | iastEntity accept: self ]
]

{ #category : #visiting }
IASTAbstractFamixVisitor >> visitIASTParameter: aParameter [

	^ (self newEntity: FamixFortran77Parameter)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aParameter sourceAnchor);
		  name: aParameter entityName;
		  yourself
]

{ #category : #visiting }
IASTAbstractFamixVisitor >> visitIASTTypeRef: aType [

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
IASTAbstractFamixVisitor >> visitIASTVarAccess: aVarAccess [

	^ (self createFamixF77Access: aVarAccess) isWrite: aVarAccess isWrite
]

{ #category : #visiting }
IASTAbstractFamixVisitor >> visitIndexedFileAnchor: aSourceAnchor [

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

Class {
	#name : 'IASTAbstractFamixVisitor',
	#superclass : 'Object',
	#instVars : [
		'model',
		'stack'
	],
	#category : 'EsopeImporter-Visitor',
	#package : 'EsopeImporter',
	#tag : 'Visitor'
}

{ #category : 'private-creation' }
IASTAbstractFamixVisitor >> createFamixF77Access: anIastAccess [
	"For each FamixF77Access we create, we hide the anIastAccess in entityAttributes with the key '#entity'.
	so that the resolver can use the information carried by anIastAccess to resolve that access."

	^self model newAccess
		sourceAnchor: (self visitIndexedFileAnchor: anIastAccess sourceAnchor);
		attributeAt: #entity put: anIastAccess;
		isWrite: false;
		accessor: stack top;
		yourself
]

{ #category : 'private-creation' }
IASTAbstractFamixVisitor >> createImplicitsDictionaryFor: anEntity [

	anEntity attributeAt: #implicitDictionary put: self defaultImplicit
]

{ #category : 'private-creation' }
IASTAbstractFamixVisitor >> createSymbolTableFor: anEntity [

	anEntity attributeAt: #symbolTable put: Dictionary new
]

{ #category : 'private-creation' }
IASTAbstractFamixVisitor >> defaultImplicit [

	^ (($a to: $z) collect: [ :char | 
		   ('ijklmn' includes: char)
			   ifTrue:  [ char -> #integer ]
			   ifFalse: [ char -> #real ] ]) asDictionary
]

{ #category : 'initialization' }
IASTAbstractFamixVisitor >> initialize [

	super initialize.
	stack := Stack new.
]

{ #category : 'initialization' }
IASTAbstractFamixVisitor >> intrinsicTypes [
	^ {
		  #integer -> ((self newEntity: FamixF77TypeIntrinsic) name: #integer).
		  #real -> ((self newEntity: FamixF77TypeIntrinsic) name: #real).
		  #complex -> ((self newEntity: FamixF77TypeIntrinsic) name: #complex).
		  #logical -> ((self newEntity: FamixF77TypeIntrinsic) name: #logical).
		  #character -> ((self newEntity: FamixF77TypeIntrinsic) name: #character) 
		} asDictionary
]

{ #category : 'accessing' }
IASTAbstractFamixVisitor >> model [

	^ model
]

{ #category : 'accessing' }
IASTAbstractFamixVisitor >> model: anObject [

	model := anObject.
	model setIntrinsicTypes
]

{ #category : 'private-creation' }
IASTAbstractFamixVisitor >> newEntity: aClass [

	^ aClass new
		  mooseModel: model;
		  yourself
]

{ #category : 'initialization' }
IASTAbstractFamixVisitor >> retrieveTypeFrom: aName [

	| typeNotFoundBlock |
	typeNotFoundBlock := [ self newEntity: FamixF77TypeUnknown ].

	^ (self model 
		attributeAt: #instrinsicTypes
		ifAbsent: [
		   self model
			   attributeAt: #unknownType
			   ifAbsent: typeNotFoundBlock.
		]
	 ) at: aName ifAbsent: typeNotFoundBlock.
]

{ #category : 'spawn' }
IASTAbstractFamixVisitor >> spawn: aVisitorClass [
	^aVisitorClass new
		model: self model ;
		stack: self stack ;
		yourself
]

{ #category : 'accessing' }
IASTAbstractFamixVisitor >> stack [

	^ stack
]

{ #category : 'accessing' }
IASTAbstractFamixVisitor >> stack: anObject [

	stack := anObject
]

{ #category : 'symbols resolution' }
IASTAbstractFamixVisitor >> symbolTable: anEntity at: key [

	^ anEntity attributeAt: key asSymbol ifAbsent: [  ]
]

{ #category : 'symbols resolution' }
IASTAbstractFamixVisitor >> symbolTable: anEntity at: key put: value [

	(self symbolTable: anEntity at: #symbolTable)
		at: key asSymbol
		put: value
]

{ #category : 'visiting' }
IASTAbstractFamixVisitor >> visitIASTParameter: aParameter [

	^ (self newEntity: FamixF77Parameter)
		  sourceAnchor:
			  (self visitIndexedFileAnchor: aParameter sourceAnchor);
		  name: aParameter entityName;
		  yourself
]

{ #category : 'visiting' }
IASTAbstractFamixVisitor >> visitIASTTypeRef: aType [

	self flag: #TODO. "How to deal with length and kind for example character*20 name produce aType object like:
	- sourceAnchor: ...
	- entityName: TypeCharacter
	- kind: nil"
	
	aType ifNil: [ ^nil ].

	^(self retrieveTypeFrom: aType entityName)
		"sourceAnchor: (self visitIndexedFileAnchor: aType sourceAnchor);"
		length: aType length;
		kind: aType kind;
		yourself
]

{ #category : 'visiting' }
IASTAbstractFamixVisitor >> visitIASTVarAccess: aVarAccess [
	"an aVarAccess can have:
	- indices for example: varAccess(i, j, k) -> i j k are indices
	- dereferencedVariable for example: aVarAccess.deref(...) -> deref is dereferencedVariable
	
	mainAccess correspond to aVarAccess"

	"Distinguish external accesses from other accesses"
	
	| mainAccess |
	mainAccess := (self createFamixF77Access: aVarAccess).
	mainAccess isWrite: aVarAccess isWrite.

	aVarAccess indices deepFlatten
		do: [ :indice |
			(indice class = IASTVarAccess and: [ indice entityName asLowercase ~= 's__' ])
				ifTrue: [ (self createFamixF77Access: indice) isWrite: indice isWrite  ] 
		].
	
	aVarAccess dereferencedVariable 
		ifNotNil: [ :dereferencedVariable | 
			(self createFamixF77Access: dereferencedVariable) 
				isWrite: dereferencedVariable isWrite;
				attributeAt: #parentAccess put: mainAccess
		].

	^ mainAccess
]

{ #category : 'visiting' }
IASTAbstractFamixVisitor >> visitIndexedFileAnchor: aSourceAnchor [

	^ aSourceAnchor ifNil: [ nil ] ifNotNil: [
		  self model newIndexedFileAnchor
			  startLine: aSourceAnchor startLine;
			  endLine: aSourceAnchor endLine;
			  startColumn: aSourceAnchor startColumn;
			  endColumn: aSourceAnchor endColumn;
			  fileName: aSourceAnchor fileName;
			  yourself ]
]

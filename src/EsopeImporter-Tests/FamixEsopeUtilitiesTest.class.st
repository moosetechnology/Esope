Class {
	#name : #FamixEsopeUtilitiesTest,
	#superclass : #TestCase,
	#instVars : [
		'mooseModel',
		'programFile'
	],
	#category : #'EsopeImporter-Tests-Importer'
}

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> anchorFrom: startPoint to: endPoint [

	^ FamixF77IndexedFileAnchor new
		  mooseModel: mooseModel;
		  startLine: startPoint x;
		  startColumn: startPoint y;
		  endLine: endPoint x;
		  endColumn: endPoint y;
		  fileName: 'fortran77.f';
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultAccess: varName [

	^ FamixF77Access new
		  mooseModel: mooseModel ;
		  attributeAt: #entity put: ((self defaultIASTVarAccess: varName) isWrite: false ; yourself) ;
		  isWrite: false ;
		  sourceAnchor: self defaultAnchor ;
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultAnchor [

	^ self anchorFrom: 1 @ 7 to: 2 @ 10
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultAttribute: varName withType: typeName [

	^ (self newEntity: FamixFortranAttribute)
		  sourceAnchor: (self anchorFrom: 2 @ 7 to: 2 @ 19);
		  name: varName;
		  declaredType: (self defaultType: typeName)
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultFunction: name [

	^ (self newEntity: FamixF77PUFunction named: name) programFile:
		  programFile
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultIASTInvocation: name [

	^ IASTInvocation new
		  entityName: name;
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultIASTVarAccess: name [

	^ IASTVarAccess new
		  entityName: name ;
		  isWrite: true ;
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultImplicitNone [

	^ IASTImplicitTypingRule new
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultInvocation: name [

	^ FamixF77Invocation new
		mooseModel: mooseModel ;
		attributeAt: #entity put: (self defaultIASTInvocation: name) ;
		signature: name ;
		sourceAnchor: self defaultAnchor ;
		yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultMain: name [

	^ (self newEntity: FamixF77PUMain named: name) programFile:
		  programFile
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultParameter: name [

	^ self newEntity: FamixF77Parameter named: name
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultProgramFile: aFilename [

	^ (self newEntity: FamixF77ProgramFile named: aFilename)
		  filename: aFilename;
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultProgramUnit: name forType: aFamixClass belongsTo: aFamixProgramFile [

	^ (self newEntity: aFamixClass named: name) programFile:
		  aFamixProgramFile
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultSegment: segmentName with: dictDeclarations [

	^ (self newEntity: FamixEsopeSegment)
		  name: segmentName;
		  sourceAnchor: (self anchorFrom: 2 @ 7 to: 2 @ 8);
		  attributes: (dictDeclarations collect: [ :assoc | 
					   self defaultAttribute: assoc key withType: assoc value ]);
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultSubroutine: name [

	^ (self newEntity: FamixF77PUSubroutine named: name) programFile:
		  programFile
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultSubroutine: name belongsTo: aFamixProgramFile [

	^ (self newEntity: FamixF77PUSubroutine named: name) programFile:
		  aFamixProgramFile
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultType: anIntrinsicFortranType [

	^FamixF77TypeIntrinsic new
		  name: anIntrinsicFortranType;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> defaultVariable: name withType: type [

	^ (self newEntity: FamixF77Variable named: name) declaredType:
		  (self defaultType: type)
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> externalDeclaration: name [

	^ self newEntity: FamixF77ExternalDeclaration named: name
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> iastTypeRef: typeName [

	^ IASTTypeRef new
		  entityName: typeName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> implicitRule: typeName range: ranges [

	^ IASTImplicitTypingRule new
		  forType: (self iastTypeRef: typeName);
		  ranges: ranges;
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> newEntity: aFamixClass [

	^ aFamixClass new
		  mooseModel: mooseModel;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> newEntity: aFamixClass named: aName [

	^ (self newEntity: aFamixClass)
		name: aName
]

{ #category : #'default values' }
FamixEsopeUtilitiesTest >> newPU: aName [

	^ (self newEntity: FamixF77PUSubroutine named: aName)
		  programFile: programFile;
		  yourself
]

{ #category : #running }
FamixEsopeUtilitiesTest >> setUp [

	super setUp.

	mooseModel := FamixEsopeModel new.
	programFile  := self defaultProgramFile: './main.f'.
]

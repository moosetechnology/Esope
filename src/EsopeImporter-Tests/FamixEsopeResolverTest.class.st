Class {
	#name : #FamixEsopeResolverTest,
	#superclass : #TestCase,
	#instVars : [
		'mooseModel',
		'resolver',
		'famixProgFile'
	],
	#category : #'EsopeImporter-Tests-Importer'
}

{ #category : #'default values' }
FamixEsopeResolverTest >> anchorFrom: startPoint to: endPoint [

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
FamixEsopeResolverTest >> defaultAccess: varName [

	^ FamixF77Access new
		  mooseModel: mooseModel ;
		  attributeAt: #entity put: ((self defaultIASTVarAccess: varName) isWrite: false ; yourself) ;
		  isWrite: false ;
		  sourceAnchor: self defaultAnchor ;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultAnchor [

	^ self anchorFrom: 1 @ 7 to: 2 @ 10
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultAttribute: varName withType: typeName [

	^ (self newEntity: FamixFortranAttribute)
		  sourceAnchor: (self anchorFrom: 2 @ 7 to: 2 @ 19);
		  name: varName;
		  declaredType: (self defaultType: typeName)
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultFunction: name [

	^ (self newEntity: FamixF77PUFunction named: name) programFile:
		  famixProgFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultIASTEsopeCommand: commandName name: entityName [

	^ IASTEsopeSegCommand new
		  esopeCommand: commandName;
		  entityName: entityName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultIASTInvocation: name [

	^ IASTInvocation new
		  entityName: name;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultIASTVarAccess: name [

	^ IASTVarAccess new
		  entityName: name ;
		  isWrite: true ;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultImplicitNone [

	^ IASTImplicitTypingRule new
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultInvocation: name [

	^ FamixF77Invocation new
		  mooseModel: mooseModel;
		  attributeAt: #entity put: (self defaultIASTInvocation: name);
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultMain: name [

	^ (self newEntity: FamixF77PUMain named: name) programFile:
		  famixProgFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultParameter: name [

	^ self newEntity: FamixF77Parameter named: name
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultProgramFile: aFilename [

	^ (self newEntity: FamixF77ProgramFile named: aFilename)
		  filename: aFilename;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultProgramUnit: name forType: aFamixClass belongsTo: aFamixProgramFile [

	^ (self newEntity: aFamixClass named: name) programFile:
		  aFamixProgramFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultSegment: segmentName with: dictDeclarations [

	^ (self newEntity: FamixEsopeSegment)
		  name: segmentName;
		  sourceAnchor: (self anchorFrom: 2 @ 7 to: 2 @ 8);
		  attributes: (dictDeclarations collect: [ :assoc | 
					   self defaultAttribute: assoc key withType: assoc value ]);
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultSubroutine: name [

	^ (self newEntity: FamixF77PUSubroutine named: name) programFile:
		  famixProgFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultSubroutine: name belongsTo: aFamixProgramFile [

	^ (self newEntity: FamixF77PUSubroutine named: name) programFile:
		  aFamixProgramFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultType: anIntrinsicFortranType [

	^FamixF77TypeIntrinsic new
		  name: anIntrinsicFortranType;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultVariable: name withType: type [

	^ (self newEntity: FamixF77Variable named: name) declaredType:
		  (self defaultType: type)
]

{ #category : #'default values' }
FamixEsopeResolverTest >> externalDeclaration: name [

	^ self newEntity: FamixF77ExternalDeclaration named: name
]

{ #category : #'default values' }
FamixEsopeResolverTest >> iastTypeRef: typeName [

	^ IASTTypeRef new
		  entityName: typeName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> implicitRule: typeName range: ranges [

	^ IASTImplicitTypingRule new
		  forType: (self iastTypeRef: typeName);
		  ranges: ranges;
		  yourself
]

{ #category : #running }
FamixEsopeResolverTest >> newEntity: aFamixClass [

	^ aFamixClass new
		  mooseModel: mooseModel;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #running }
FamixEsopeResolverTest >> newEntity: aFamixClass named: aName [

	^ (self newEntity: aFamixClass)
		name: aName
]

{ #category : #running }
FamixEsopeResolverTest >> newPU: aName [

	^ (self newEntity: FamixF77PUSubroutine named: aName)
		  programFile: famixProgFile;
		  yourself
]

{ #category : #running }
FamixEsopeResolverTest >> setUp [

	super setUp.

	mooseModel := FamixEsopeModel new.
	resolver := FamixEsopeResolver on: mooseModel.
	famixProgFile  := self defaultProgramFile: './main.f'.
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitDefault [

	"
	      subroutine rtn
	      end
	"

	| pu |

	pu := self defaultSubroutine: 'rtn'.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary size equals: 26.
	
	"testing a few of them"
	self assert: (pu implicitDictionary at: $a) equals: 'real'.
	self assert: (pu implicitDictionary at: $i) equals: 'integer'.
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitMultiple [
	"
      subroutine rtn
      implicit integer(a,d-e)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		      attributeAt: #implicits
		      put:
			      { (self
				       implicitRule: 'integer'
				       range: #( #( $a ) #( $c $d ) )) };
		      yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'real'.
	self assert: (pu implicitDictionary at: $c) equals: 'integer'.
	self assert: (pu implicitDictionary at: $d) equals: 'integer'.
	self assert: (pu implicitDictionary at: $e) equals: 'real'
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitNone [

	"
	      subroutine rtn
	      implicit none
	      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		attributeAt: #implicits put: { self defaultImplicitNone } ;
		yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary isEmpty
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitRange [
	"
      subroutine rtn
      implicit integer(a-c)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		      attributeAt: #implicits
		      put: { (self implicitRule: 'integer' range: #( #( $a $c ) )) };
		      yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'integer'.
	self assert: (pu implicitDictionary at: $c) equals: 'integer'.
	self assert: (pu implicitDictionary at: $d) equals: 'real'
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitSimple [
	"
      subroutine rtn
      implicit integer(a)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		      attributeAt: #implicits
		      put: { (self implicitRule: 'integer' range: #( #( $a ) )) };
		      yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'real'
]

{ #category : #tests }
FamixEsopeResolverTest >> testRequalifyParameterNoVariableDeclaration [

	"
      subroutine sub(var)
      end
	"

	| sub entity |

	sub := (self newPU: 'sub')
		addParameter: (self defaultParameter: 'var') ;
		yourself.

 	resolver resolve.

	self assert: sub parameters size equals: 1.
	entity := sub parameters anyOne.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'real'.


]

{ #category : #tests }
FamixEsopeResolverTest >> testRequalifyVariableDeclarationAsFunction [

	"
      subroutine sub
       external fct
      integer fct
      end
	"

	| sub |

	self flag: #FIXED. "see issue #32"

	sub := (self defaultSubroutine: 'sub')
		addExternalDeclaration: (self externalDeclaration: 'fct') ;
		addLocalVariable: (self defaultVariable: 'fct' withType: #integer) ;
		yourself.

 	resolver resolve.

	self assert: sub localVariables isEmpty.
	self assert: (resolver model allWithType: FamixF77Variable) isEmpty.

	self assert: sub externalDeclarations size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) size equals: 1.

]

{ #category : #tests }
FamixEsopeResolverTest >> testRequalifyVariableDeclarationAsParameter [

	"
      subroutine sub(var)
      integer var
      end
	"

	| sub entity |

	sub := (self newPU: 'sub')
		addParameter: (self defaultParameter: 'var') ;
		addLocalVariable: (self defaultVariable: 'var' withType: #integer) ;
		yourself.

 	resolver resolve.

	self assert: sub localVariables isEmpty.
	self assert: (resolver model allWithType: FamixF77Variable) isEmpty.

	self assert: sub parameters size equals: 1.
	entity := sub parameters anyOne.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'integer'.


]

{ #category : #'test-todo' }
FamixEsopeResolverTest >> testResolveAccessAttributeDeclaredPointer [

	| main access access2 varP typePoint |
	"
      subroutine demo
      segment point
        integer x
      end segment
	   pointeur p.point
      p.x
      end
	"

	typePoint := self newNamedEntity: 'point' toFamix: FamixEsopeSegment.
	typePoint addAttribute: (self newNamedEntity: 'x' toFamix: FamixFortranAttribute).

	varP := self newNamedEntity: 'p' toFamix: FamixF77Variable.
	varP declaredType: typePoint.
	
	access := self newEntity: FamixF77Access.
	access attributeAt: #entity put: (self defaultIASTVarAccess: 'p').

	access2 := self newEntity: FamixF77Access.
	access2 attributeAt: #entity put: (self defaultIASTVarAccess: 'x').

	access attributeAt: #attributeAccess put: access2.
	access2 attributeAt: #parentAccess put: access.

	main := (self defaultMain: 'main')
		addType: typePoint ;
		addLocalVariable: varP ;
		accesses: {access . access2} ;
		yourself.

	self assert: main localVariables size equals: 1.

	resolver resolve.

	self assert: main accesses size equals: 2.

	self assert: access variable equals: varP.
	self assert: access accessor equals: main.

	self assert: access2 variable class equals: FamixFortranAttribute.
	self assert: access2 variable parentType equals: typePoint.
	self assert: access2 accessor equals: main.

]

{ #category : #'test-todo' }
FamixEsopeResolverTest >> testResolveAccessAttributeNoPointer [

	| subrtn access type |
	"
      subroutine demo
      segment point
        integer x
      end segment
      x
      end
	"

	type := self newNamedEntity: 'point' toFamix: FamixEsopeSegment.
	type attributes: {
		(self newNamedEntity: 'x' toFamix: FamixFortranAttribute) }.

	access := self newEntity: FamixF77Access.
	access attributeAt: #entity put: (self defaultIASTVarAccess: 'x').
	
	subrtn := (self defaultSubroutine: 'demo')
		addType: type ;
		addAccess: access ;
		yourself.

	resolver resolve.

	self assert: subrtn accesses size equals: 1.

	self assert: access variable class equals: FamixFortranAttribute.
	self assert: access variable parentType equals: type.
	self assert: access accessor equals: subrtn.

]

{ #category : #'test-todo' }
FamixEsopeResolverTest >> testResolveAccessDeclaredLocalVariable [
	"program main
	 integer var
	 var
	 end
	"

	| main access  |

	main := (self defaultMain: 'main')
		addLocalVariable: (self defaultVariable: 'var' withType: #integer);
		addAccess: (self defaultAccess: 'var');
		yourself.

 	resolver resolve.

	self assert: main accesses size equals: 1.
	access := main accesses first.

	self assert: access variable equals: main localVariables first.
]

{ #category : #'test-todo' }
FamixEsopeResolverTest >> testResolveAccessDeclaredPointerVariable [

	| main access var |
	"
      subroutine demo
      segment point
      end segment
	   pointeur p.point
      p
      end
	"
	var := self newNamedEntity: 'p' toFamix: FamixF77Variable.
	var declaredType: (self newNamedEntity: 'point' toFamix: FamixF77Type).
	
	main := (self defaultMain: 'main')
		addType: (self newNamedEntity: 'point' toFamix: FamixEsopeSegment) ;
		addLocalVariable: var ;
		addAccess: ((self newEntity: FamixF77Access)
			attributeAt: #entity put: (self defaultIASTVarAccess: 'p') ;
			yourself);
		yourself.

	self assert: main localVariables size equals: 1.

	resolver resolve.

	var := main localVariables anyOne.

	self assert: main accesses size equals: 1.

	access := main accesses anyOne.
	self assert: access variable equals: var.
	self assert: access accessor equals: main.

]

{ #category : #'test-todo' }
FamixEsopeResolverTest >> testResolveAccessImplicitLocalVariable [
	"program main
	 var
	 end
	"

	| main access  var |

	main := (self defaultMain: 'main')
		addAccess: (self defaultAccess: 'var');
		yourself.

	self assert: main localVariables size equals: 0.

 	resolver resolve.

	self assert: main localVariables size equals: 1.
	var := main localVariables anyOne.
	self assert: var name equals: 'var'.
	self assert: var declaredType class equals: FamixF77TypeIntrinsic.
	self assert: var declaredType name equals: 'real'.

	self assert: main accesses size equals: 1.

	access := main accesses anyOne.
	self assert: access variable equals: var.
	self assert: access accessor equals: main.

]

{ #category : #'test-todo' }
FamixEsopeResolverTest >> testResolveAccessImplicitPointerVariable [

	| subrtn access var |
	"
      subroutine demo
      segment point
      end segment
      point
      end
	"

	subrtn := (self defaultSubroutine: 'demo')
		addType: ((self newNamedEntity: 'point' toFamix: FamixEsopeSegment)) ;
		addAccess: ((self newEntity: FamixF77Access)
					     attributeAt: #entity put: (self defaultIASTVarAccess: 'point') ;
					     yourself);
		yourself.

	self assert: subrtn localVariables size equals: 0.

	resolver resolve.

	self assert: subrtn localVariables size equals: 1.
	var := subrtn localVariables anyOne.
	self assert: var name equals: 'point'.
	self assert: var declaredType class equals: FamixEsopeSegment.
	self assert: var declaredType name equals: 'point'.

	self assert: subrtn accesses size equals: 1.

	access := subrtn accesses anyOne.
	self assert: access variable equals: var.
	self assert: access accessor equals: subrtn.

]

{ #category : #'test-todo' }
FamixEsopeResolverTest >> testResolveAccessToParameter [

	| subrtn access |
	"
      subroutine demo(x)
        integer x
      x
      end
	"

	access := self newEntity: FamixF77Access.
	access attributeAt: #entity put: (self defaultIASTVarAccess: 'x').
	
	subrtn := (self defaultSubroutine: 'demo')
		addParameter: (self newNamedEntity: 'x' toFamix: FamixF77Parameter) ;
		addAccess: access ;
		yourself.

	resolver resolve.

	self assert: subrtn accesses size equals: 1.

	self assert: access variable class equals: FamixF77Parameter.
	self assert: access accessor equals: subrtn.

]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveDeclaredTypeOfPointers [

	| sub entity type var |
	"
      subroutine demo
      segment point
      end segment
      pointeur p.point
      end
	"
	type := self newEntity: FamixEsopeSegment named: 'point'.
	type attributes: #().

	var := self newEntity: FamixF77Variable named: 'p'.
	var segment: 'point'.
	var isEsope: true.

	sub := (self newPU: 'demo')
		addType: type;
		addLocalVariable: var;
		yourself.

	resolver resolveDeclaredTypeOfPointers.

	self assert: sub localVariables size equals: 1.

	entity := sub localVariables anyOne.
	self assert: entity declaredType equals: type
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveFunctionImplicit [
	"
      function fct()
      implicit charcater(f)
      end
	"

	| sub |

	sub := (self defaultFunction: 'fct')
		       attributeAt: #implicits
		       put: { (self implicitRule: 'character' range: #( #( $f ) )) };
		       yourself.

	resolver resolve.

	self assert: sub declaredType class equals: FamixF77TypeIntrinsic.
	self assert: sub declaredType name equals: 'character'
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveFunctionImplicitWrongParameters [
	"
      function fct()
      implicit character(f)
      end
	"

	| sub |

	sub := self defaultFunction: 'fct'.
	sub addParameter: (self defaultParameter: 'param').
	sub
		attributeAt: #implicits
		put: { (self implicitRule: 'character' range: #( #( $f ) )) }.

	resolver resolve.

	self assert: sub declaredType class equals: FamixF77TypeIntrinsic.
	self assert: sub declaredType name equals: 'character'
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitParameter [

	"
	      function fct(iparam)
	      end
	"

	| function |

	function := (self defaultFunction: 'fct')
		parameters: { (self defaultParameter: 'iparam') } ;
		yourself.

	self assert: function parameters first declaredType isNil.
	
	resolver resolve.

	self
		assert: function parameters first declaredType name
		equals: 'integer'
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitParameterNone [

	"
	      subroutine sub(param)
	      implicit none
	      end
	"

		| entity |

	(self defaultSubroutine: 'sub')
		attributeAt: #implicits put: { self defaultImplicitNone } ;
		addParameter: (self defaultParameter: 'var').

 	resolver resolve.

	self assert: (resolver model allWithSubTypesOf: FamixF77ProgramUnit) size equals: 1.
	
	entity := (resolver model allWithSubTypesOf: FamixF77ProgramUnit) first parameters first.
	self assert: entity declaredType class equals: FamixF77TypeUnknown

]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitParameterRange [
	"
      subroutine sub(var)
      implicit charcater(u-w)
      end
	"

	| entity |

	(self defaultSubroutine: 'sub')
		attributeAt: #implicits
		put: { (self implicitRule: 'character' range: #( #( $u $w ) )) };
		addParameter: (self defaultParameter: 'var').

	resolver resolve.

	self
		assert: (resolver model allWithSubTypesOf: FamixF77ProgramUnit) size
		equals: 1.

	entity := (resolver model allWithSubTypesOf: FamixF77ProgramUnit)
		          first parameters first.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'character'
]

{ #category : #'test-todo' }
FamixEsopeResolverTest >> testResolveIncludeDirective [

	"
+------ point.seg ----------------------------------+
|      subroutine @point_seg@                       |
|      segment point                                |
|      end segment                                  |
|      end                                          |
+---------------------------------------------------+
+------ main.E -------------------------------------+
|      program main                                 |
|#include ""point.seg""                             |
|      end                                          |
+---------------------------------------------------+
"

	| sub main includedFile mainFile |
	includedFile := self defaultProgramFile: 'point.seg.f'.
	mainFile := self defaultProgramFile: 'main.f'.

	sub := (self newNamedEntity: '@point_seg@' toFamix: FamixF77IncludedFile)
		programFile: includedFile ;
		types: { self newNamedEntity: 'point' toFamix: FamixEsopeSegment } ;
		yourself.

	main := (self newNamedEntity: 'main' toFamix: FamixF77PUMain)
		programFile: mainFile ;
		includes: { (self newEntity: FamixF77Include) filename: 'point.seg' } ;
		yourself.

	resolver resolve.

	self assert: (resolver model allWithType: FamixF77IncludedFile) size equals: 1.
	self assert: (resolver model allWithType: FamixF77IncludedFile) first equals: sub.

	self assert: main includes size equals: 1.
	self
		assert: main includes anyOne included
		equals: sub.

	self assert: sub inclusions size equals: 1.
	self assert: sub inclusions anyOne includedBy equals: main.

]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveInvocations [
	| invocation callee caller |
	
	caller := (self defaultMain: 'main')
		addOutgoingInvocation: (self defaultInvocation: 'sub');
		yourself.
		
	callee := self defaultSubroutine: 'sub'.

 	resolver resolve.

	self assert: caller outgoingInvocations size equals: 1.
	invocation := caller outgoingInvocations first.
	
	self assert: invocation class equals: FamixF77Invocation.
	self assert: invocation sender equals: caller.
	
	self assert: invocation candidates size equals: 1.
	self assert: invocation candidates first equals: callee.
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveInvocationsWrongArgumentNumber [
	| invocation callee caller |
	
	caller := (self defaultMain: 'main')
		addOutgoingInvocation: (self defaultInvocation: 'sub');
		yourself.
		
	callee := self defaultSubroutine: 'sub'.
	callee parameters: { self defaultParameter: 'var' }.

 	resolver resolve.

	self assert: caller outgoingInvocations size equals: 1.
	invocation := caller outgoingInvocations first.

	self assert: invocation candidates size equals: 0
]

"
An IASTVisitorF77Test is a test class for testing the behavior of IASTVisitorF77
"
Class {
	#name : 'IASTToFamixVisitorTest',
	#superclass : 'TestCase',
	#instVars : [
		'visitor',
		'programFile'
	],
	#category : 'EsopeImporter-Tests-Visitor',
	#package : 'EsopeImporter-Tests',
	#tag : 'Visitor'
}

{ #category : 'running' }
IASTToFamixVisitorTest >> anchorFrom: startPoint to: endPoint [

	^ IASTIndexedFileAnchor new
		  startLine: startPoint x;
		  startColumn: startPoint y;
		  endLine: endPoint x;
		  endColumn: endPoint y;
		  fileName: 'fortran77.f';
		  yourself
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> attribute: symbol for: famixEntity [

	^ famixEntity attributeAt: symbol ifAbsent: [ nil ]
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultAnchor [

	^ self anchorFrom: 1 @ 7 to: 2 @ 10
]

{ #category : 'default values' }
IASTToFamixVisitorTest >> defaultEmptySegment: segmentName [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: {  };
		  yourself
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultImplicitNone [

	^ IASTImplicit new
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultNamedEntity: entityName for: aClassName [

	^ aClassName new
		  sourceAnchor: self defaultAnchor;
		  entityName: entityName;
		  yourself
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultParameter [

	^ IASTParameter new
		  entityName: 'var';
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : 'default values' }
IASTToFamixVisitorTest >> defaultSegment: segmentName [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: {  };
		  yourself
]

{ #category : 'default values' }
IASTToFamixVisitorTest >> defaultSegment: segmentName with: dictDeclarations [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: (dictDeclarations collect: [ :assoc | 
					   self defaultVariable: assoc key withType: assoc value ]);
		  yourself
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultSegmentComand: commandName on: varName [

	^ IASTEsopeSegCommand new
		  esopeCommand: commandName;
		  entityName: varName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultType: typeName [

	^ IASTTypeRef new
		  entityName: typeName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultVarAccess: name [

	^ self defaultVarAccess: name isWrite: false
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultVarAccess: name isWrite: boolean [

	^ IASTVarAccess new
		  sourceAnchor: self defaultAnchor;
		  isWrite: boolean;
		  entityName: name;
		  yourself
]

{ #category : 'default values' }
IASTToFamixVisitorTest >> defaultVarEsoAt: entities [

	^ IASTVarEsoAt new
		  sourceAnchor: self defaultAnchor;
		  entities:
			  (entities collect: [ :entity | self defaultVarAccess: entity ]);
		  yourself
]

{ #category : 'default values' }
IASTToFamixVisitorTest >> defaultVarEsoSl: entities [

	^ IASTVarEsoSl new
		  sourceAnchor: self defaultAnchor;
		  entities:
			  (entities collect: [ :entity | self defaultVarAccess: entity ]);
		  yourself
]

{ #category : 'default values' }
IASTToFamixVisitorTest >> defaultVariable: assoc [

	^ IASTVariable new
		  sourceAnchor: self defaultAnchor;
		  entityName: assoc key;
		  typeSpec: (IASTTypeRef new
				   sourceAnchor: self defaultAnchor;
				   entityName: assoc value;
				   yourself);
		  yourself
]

{ #category : 'running' }
IASTToFamixVisitorTest >> defaultVariable: varName withType: typeName [

	^ IASTVariable new
		  sourceAnchor: self defaultAnchor;
		  entityName: varName;
		  typeSpec: (self defaultType: typeName);
		  yourself
]

{ #category : 'running' }
IASTToFamixVisitorTest >> implicitRule: typeName range: ranges [

	^ IASTImplicitTypingRule new
		  forType: (self defaultType: typeName);
		  ranges: ranges;
		  yourself
]

{ #category : 'running' }
IASTToFamixVisitorTest >> jsonToIAST: jsonCode [
	| jsonVisitor |
	jsonVisitor := JsonToIASTVisitor new.
	^jsonVisitor visitProgramFile: (NeoJSONReader fromString: jsonCode)
]

{ #category : 'running' }
IASTToFamixVisitorTest >> setUp [
	super setUp.
	
	programFile := IASTProgramFile new filename: 'fortran77.f' ; yourself.
	visitor := IASTToFamixFortranVisitor new.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testComment [

	| entity comment |

	programFile body: { IASTMainProgram new
			 entityName: 'main';
			 body: { IASTComment new
		           text: 'a normal comment' ;
		           yourself. };
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.
	self assert: entity programUnits first comments size equals: 1.

	comment := entity programUnits first comments first.
	self assert: comment class equals: FamixF77Comment.
	self assert: comment sourceText equals: 'a normal comment'.
	self deny: comment isEsope.
	
	self assert: comment commentedEntity equals: entity programUnits first.
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testDummyFamixFortran77Subroutine [

	"
      subroutine _$aFile_inc
      integer l
c@_   segment point
      real abs, ord
c@_   end segment
      end
	"

	| l segment entity |
	l := self defaultVariable: 'l' withType: 'integer'.
	segment := self defaultSegment: 'point' with: { 
			           (#abs -> #real).
			           (#ord -> #real) }.

	programFile body: { (IASTIncludedFile new
			 entityName: '_$aFile_inc';
			 sourceAnchor: self defaultAnchor;
			 body: { 
					 l.
					 segment };
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77IncludedFile.
	self assert: entity name equals: '_$aFile_inc'.

	self assert: entity programFile isNotNil.
	self assert: entity inclusions isEmpty.

	self assert: entity types size equals: 1.
	self assert: entity types first name equals: 'point'.
	self assert: entity types first attributes size equals: 2.
	self assert: entity types first attributes first name equals: 'abs'.
	self assert: entity types first attributes second name equals: 'ord'.


	self assert: entity localVariables size equals: 1.
	self assert: entity localVariables first name equals: 'l'
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeAccessors [

	"
	d__(ptr,attr)
	"

	| d__ entity pointerAccess attributeAccess var |
	d__ := self defaultVarEsoAt: #( #ptr #attr ).

	entity := (FamixF77PUSubroutine new).
	visitor stack push: entity.

	d__ accept: visitor.

	self assert: entity accesses size equals: 2.

	entity accesses do: [ :access |
		var := access attributeAt: #entity ifAbsent: [ nil ].
		self assert: var isNotNil.
		(var entityName = 'ptr')
			ifTrue: [ pointerAccess := access ]
			ifFalse: [ attributeAccess := access ]
	].

	self assert: pointerAccess isNotNil.
	self assert: (pointerAccess attributeAt: #parentAccess ifAbsent: [ nil ]) isNil.

	self assert: attributeAccess isNotNil.
	self
		assert: (attributeAccess attributeAt: #parentAccess ifAbsent: [ nil ])
		equals: pointerAccess.
	var := attributeAccess attributeAt: #entity ifAbsent: [ nil ].
	self assert: var entityName equals: 'attr'.
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeAccessorsWithArg [

	"
	d__(ptr,attr(i))
	"

	| d__ entity var pointerAccess attributeAccess indiceAccess |
	d__ := (self defaultNamedEntity: 'd__' for: IASTVarEsoAt) entities:
		       { 
			       (self defaultNamedEntity: 'ptr' for: IASTVarAccess).
			       ((self defaultNamedEntity: 'attr' for: IASTInvocation) 
				        arguments:
				        { (self defaultNamedEntity: 'i' for: IASTParameter) }) }.

	entity := (FamixF77PUSubroutine new).
	visitor stack push: entity.

	d__ accept: visitor.

	self assert: entity accesses size equals: 3.

	entity accesses do: [ :access |
		var := access attributeAt: #entity ifAbsent: [ nil ].
		self assert: var isNotNil.
		(var entityName = 'ptr')
			ifTrue: [ pointerAccess := access ]
			ifFalse: [
				(var entityName = 'attr')
					ifTrue: [ attributeAccess := access ]
					ifFalse: [ indiceAccess := access ]
			]
	].

	self assert: pointerAccess isNotNil.
	self assert: (pointerAccess attributeAt: #parentAccess ifAbsent: [ nil ]) isNil.

	self assert: attributeAccess isNotNil.
	self
		assert: (attributeAccess attributeAt: #parentAccess ifAbsent: [ nil ])
		equals: pointerAccess.

	self assert: indiceAccess isNotNil.
	self assert: (indiceAccess attributeAt: #parentAccess ifAbsent: [ nil ]) isNil.
	var := indiceAccess attributeAt: #entity ifAbsent: [ nil ].
	self assert: var entityName equals: 'i'.

]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeAccessorsWithArgsWithDot [

	"
	d__(ptr,attr(i,d__(p,j)))
	"

	| d__ entity pAccess jAccess var |
	d__ := (self defaultNamedEntity: 'd__' for: IASTVarEsoAt) entities:
		       { 
			       (self defaultNamedEntity: 'ptr' for: IASTVarAccess).
			       ((self defaultNamedEntity: 'attr' for: IASTInvocation) 
				        arguments: { 
						        (self defaultNamedEntity: 'i' for: IASTParameter).
						        ((self defaultNamedEntity: nil for: IASTVarEsoAt) 
							         entities: { 
									         (self defaultNamedEntity: 'p' for: IASTParameter).
									         (self defaultNamedEntity: 'j' for: IASTParameter) }) }) }.

	entity := (FamixF77PUSubroutine new).
	visitor stack push: entity.

	d__ accept: visitor.

	self assert: entity accesses size equals: 5.

	entity accesses do: [ :access |
		var := access attributeAt: #entity ifAbsent: [ nil ].
		self assert: var isNotNil.
		(var entityName = 'p') ifTrue: [ pAccess := access ].
		(var entityName = 'j') ifTrue: [ jAccess := access ].
	].

	self assert: pAccess isNotNil.
	self assert: (pAccess attributeAt: #parentAccess ifAbsent: [ nil ]) isNil.

	self assert: jAccess isNotNil.
	self
		assert: (jAccess attributeAt: #parentAccess ifAbsent: [ nil ])
		equals: pAccess.

]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeCommandSegactWithSuffix [

	"
	segact ptr*NOMOD
	"

	| famixSegxxx iastSegxxx progFile value |
	iastSegxxx := self defaultSegmentComand: 'segact' on: 'ptr*NOMOD'.

	programFile body: { IASTSubroutine new
			 entityName: 'sub';
			 body: { iastSegxxx };
			 yourself }.

	progFile := programFile accept: visitor.
	
	self assert: progFile programUnits size equals: 1.

	self assert: (visitor model allWithSubTypesOf: FamixEsopeCommand) size equals: 1.
	famixSegxxx := (visitor model allWithSubTypesOf: FamixEsopeCommand) first.
	self assert: famixSegxxx class equals: FamixEsopeCommandSegact.
	
	value := famixSegxxx attributeAt: #entity ifAbsent: [ nil ].
	self assert: value isNotNil.
	
	self assert: value class equals: IASTEsopeSegCommand.
	self assert: value entityName equals: 'ptr'.
	self deny: value isWritable.

]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeCommandSegini [

	"
	segini ptr
	"

	| famixSegini iastSegini progFile |
	iastSegini := self defaultSegmentComand: 'segini' on: 'ptr'.

	programFile body: { IASTSubroutine new
			 entityName: 'sub';
			 body: { iastSegini };
			 yourself }.

	progFile := programFile accept: visitor.
	
	self assert: progFile programUnits size equals: 1.

	self assert: (visitor model allWithSubTypesOf: FamixEsopeCommand) size equals: 1.
	famixSegini := (visitor model allWithSubTypesOf: FamixEsopeCommand) anyOne.
	self assert: famixSegini class equals: FamixEsopeCommandSegini.
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopePointerAccess [
	"SUBROUTINE sub
      ptr.att = 5
      END

	pointer access are recorded as 2 independant accesses (but the second one is for an
	attribute of a segment.
	Here we don't have the segment, so it is only two variableAccess-es"

	| accesses iastVar |
	iastVar := self defaultVarAccess: 'ptr' isWrite: true.
	iastVar dereferencedVariable: (self defaultVarAccess: 'att' isWrite: false).

	programFile body: { IASTSubroutine new
		entityName: 'sub';
		body: { iastVar } ;
		yourself
	}.

	programFile accept: visitor.

	accesses := visitor model allAccesses.
	self assert: accesses size equals: 2.

	self assert: (accesses allSatisfy: [ : acc | acc accessor name = 'sub']).
	self assert: (accesses allSatisfy: [ : acc |
		(acc attributeAt: #entity ifAbsent: [nil])
			isNotNil ]).

	self assert: (accesses anySatisfy: [ : acc |
		(acc attributeAt: #entity ifAbsent: ["impossible"]) entityName = 'ptr']).
	self assert: (accesses anySatisfy: [ : acc |
		(acc attributeAt: #entity ifAbsent: ["impossible"]) entityName = 'att']).
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopePointerAccessWithSegment [
	"SUBROUTINE sub
      ptr.att = 5
      END
	"

	| accesses iastVar segment access |
	iastVar := self defaultVarAccess: 'ptr' isWrite: true.
	iastVar dereferencedVariable: (self defaultVarAccess: 'att' isWrite: false).
	
	visitor model: FamixEsopeModel new.
	segment := (visitor model newSegment name: 'foo').
	segment addAttribute: (visitor model newAttributeNamed: 'att').
	(visitor model newVariableNamed: 'ptr') declaredType: segment.

	programFile body: { IASTSubroutine new
		entityName: 'sub';
		body: { iastVar } ;
		yourself
	}.

	programFile accept: visitor.

	accesses := visitor model allAccesses.
	self assert: accesses size equals: 2.

	access := accesses detect: [:each | 
		(self attribute: #entity for: each) ~= iastVar ].

	self assert: (self attribute: #parentAccess for: access) isNotNil.

	access := self attribute: #parentAccess for: access.
	self assert:  (self attribute: #entity for: access) entityName equals: 'ptr'.
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopePointerDeclaration [
"      program main
      segment, pers
      end segment
      pointeur p1.pers
      end
"

	| entity |
	programFile := self jsonToIAST: '{"meta":{"miVersion":"fortran77","miFilename":"./srcCodeOrigin.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"comment":"@_   segment, pers","span":"(2:1)-(2:19)","tag":"comment"},{"anno":[],"comment":"@_   end segment","span":"(3:1)-(3:17)","tag":"comment"},{"anno":[],"comment":"@_   pointeur p1.pers","span":"(4:1)-(4:22)","tag":"comment"}],"name":"main","span":"(1:7)-(5:9)","subprograms":null,"tag":"main"}]}'.
	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self
		assert: (visitor model allWithType: FamixF77Variable) size
		equals: 1. "p1"

	entity := (visitor model allWithType: FamixF77Variable) first.
	self assert: entity isEsope.
	self assert: entity name equals: 'p1'.
	self assert: entity segment equals: 'pers'.

]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeSegment [

	"
	segment myseg
	 character uname
	 logical status
	 integer age
	end segment
	"

	| segment entity attribute |
	segment := self defaultSegment: 'myseg' with: { 
			           (#uname -> #character).
			           (#status -> #logical).
			           (#age -> #integer) }.

	programFile body: { IASTSubroutine new
			 entityName: 'sub';
			 body: { segment };
			 yourself }.

	entity := programFile accept: visitor.
	
	self assert: entity programUnits size equals: 1.

	self assert: (visitor model allWithType: FamixEsopeSegment) size equals: 1.
	entity := (visitor model allWithType: FamixEsopeSegment) first.
	self assert: entity name equals: 'myseg'.
	self assert: entity isType.
	self assert: entity attributes size equals: 3.
	
	self assert: entity attributes size equals: 3.
	attribute := entity attributes first.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'uname'.
	self assert: attribute declaredType name equals: 'character'.
	
	attribute := entity attributes second.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'status'.
	self assert: attribute declaredType name equals: 'logical'.
	
	attribute := entity attributes third.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'age'.
	self assert: attribute declaredType name equals: 'integer'.
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeSegmentWithAcces [

	"
	segment foo
	 integer bar(nb)
	end segment
	"

	| segment entity attribute access |

	segment := IASTEsopeSegment new
		  entityName: 'foo';
		  declarations: { IASTVariable new
		  			entityName: 'bar';
		  			typeSpec: (IASTTypeRef new entityName: 'integer');
					dimensions: { IASTVarAccess new entityName: 'nb'  };
		  			yourself
		  };
		  yourself.

	programFile body: { IASTSubroutine new
			 entityName: 'sub';
			 body: { segment };
			 yourself }.

	entity := programFile accept: visitor.
	
	self assert: entity programUnits size equals: 1.

	self assert: (visitor model allWithType: FamixEsopeSegment) size equals: 1.
	entity := (visitor model allWithType: FamixEsopeSegment) first.
	self assert: entity name equals: 'foo'.
	self assert: entity isType.
	
	self assert: entity attributes size equals: 1.
	attribute := entity attributes anyOne.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'bar'.
	self assert: attribute declaredType name equals: 'integer'.
	
		
	self assert: entity accesses size equals: 1.
	access := entity accesses anyOne.
	self assert: access class equals: FamixF77Access.
	self assert: access accessor equals: entity.
	self assert: (access attributeAt: #entity ifAbsent: [nil]) entityName equals: 'nb'
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeSegmentWithPointeur [

	"
      segment myseg
        integer a1(n)
c@_      pointeur a2(n).aseg
      end segment
	"

	| segment entity attribute |
	
	self skip: #TODO. "not yet implement".
	
	segment := self defaultSegment: 'myseg' with: { 
			           (#a1 -> #integer).
			           (#status -> #logical).
			           (#age -> #integer) }.

	programFile body: { IASTSubroutine new
			 entityName: 'sub';
			 body: { segment };
			 yourself }.

	entity := programFile accept: visitor.
	
	self assert: entity programUnits size equals: 1.

	self assert: (visitor model allWithType: FamixEsopeSegment) size equals: 1.
	entity := (visitor model allWithType: FamixEsopeSegment) first.
	self assert: entity name equals: 'myseg'.
	self assert: entity isType.
	self assert: entity attributes size equals: 3.
	
	self assert: entity attributes size equals: 3.
	attribute := entity attributes first.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'uname'.
	self assert: attribute declaredType name equals: 'character'.
	
	attribute := entity attributes second.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'status'.
	self assert: attribute declaredType name equals: 'logical'.
	
	attribute := entity attributes third.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'age'.
	self assert: attribute declaredType name equals: 'integer'.
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeSlash [
	
	"In instruction `lb.uref(S__/1)` we just use the s__ for simplicity of the test"
	"
	lb.uref(S__/1)
	"

	| iastVar uref |
	uref := self defaultVarAccess: 'uref' isWrite: false.
	
	iastVar := self defaultVarAccess: 'lb' isWrite: true.
	iastVar indices: { self defaultVarAccess: 's__' isWrite: false }.
	iastVar dereferencedVariable: uref.

	programFile body: { IASTSubroutine new
		entityName: 'sub';
		body: { iastVar } ;
		yourself
	}.

	programFile accept: visitor.

	self assert:  visitor model allAccesses size equals: 2.
	self assert: (visitor model allLocalVariables) size equals: 0
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixEsopeSlashWithLitteralDim [

	"
c  ptr.attr(/1)
	s__(d__(ptr,attr),1)
	"

	| s__ entity access |
	self skip.
	self flag: #TODO.
	s__ := self defaultVarEsoSl: #( #ptr #attr ).

	programFile body: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { s__ };
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self assert: entity programUnits first accesses size equals: 2.

	access := entity programUnits first accesses first.
	self assert: access target isNil.
	self assert: (access attributeAt: #entity ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #entity ifAbsent: [  ]) entityName
		equals: 'ptr'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNil.


	access := entity programUnits first accesses second.
	self assert: access target isNil.
	self assert: (access attributeAt: #entity ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #entity ifAbsent: [  ]) entityName
		equals: 'attr'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #pointer ifAbsent: [  ]) entityName
		equals: 'ptr'
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixExternalDeclaration [

	| entity external iastVar |
	
	iastVar := self defaultVarAccess: 'fct' isWrite: false.
	iastVar annotations: 'external'.

	programFile body: { IASTSubroutine new
		entityName: 'sub';
		body: { iastVar } ;
		yourself
	}.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUSubroutine.
	self assert: entity name equals: 'sub'.
	self assert: entity programFile isNotNil.

	self assert: entity accesses size equals: 0.
	self assert: entity externalDeclarations size equals: 1.
	
	external := entity externalDeclarations anyOne.
	self assert: external class equals: FamixF77ExternalDeclaration.
	self assert: external name equals: 'fct'.
	self assert: external programUnit equals: entity.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77 [

	| entity |
	programFile body: { IASTSubroutine new
		entityName: 'sub';
		body: #();
		yourself
	}.
	programFile accept: visitor.

	self assert: visitor model size equals: 7.
	
	entity := visitor model allWithType: FamixF77ProgramFile.
	self assert: entity size equals: 1.

	entity := visitor model detect: [:each | each class = FamixF77ProgramFile ].
	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUSubroutine.
	self assert: entity name equals: 'sub'.

]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77Call [
	"subroutine mysub
      fct(msg)
      end
"

	| entity iastCall |
	iastCall := IASTInvocation new
		entityName: 'fct' ;
		arguments: { IASTVarAccess new entityName: 'msg' ; isWrite: false ; yourself } ;
		sourceAnchor: self defaultAnchor ;
		yourself.

	programFile body: { IASTSubroutine new
		entityName: 'mysub';
		body: { iastCall };
		yourself
	}.

	programFile accept: visitor.

	self assert: (visitor model allWithType: FamixF77ProgramFile) size equals: 1.
	self assert: (visitor model allWithType: FamixF77ProgramFile) anyOne programUnits size equals: 1.

	entity := (visitor model allWithType: FamixF77ProgramFile) anyOne programUnits anyOne.
	self assert: entity class equals: FamixF77PUSubroutine.

	self assert: entity outgoingInvocations size equals: 1.
	self assert: entity accesses size equals: 1.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77Comment [
	| entity |
	programFile body: { IASTComment new
		text: ' a comment' ;
		isProgUnit: true ;
		yourself  
	}.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 0.
	self assert: entity comments size equals: 1.

	entity := entity comments first.
	self assert: entity class equals: FamixF77Comment.
	self assert: entity content equals: ' a comment'.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77CommentInSubRoutine [
	| entity |
	programFile body: {  IASTSubroutine new
		entityName: 'sub';
		body: { IASTComment new text: ' a comment' ; yourself };
		yourself  }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.
	self assert: entity comments size equals: 0.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUSubroutine.
	self assert: entity comments size equals: 1.

	entity := entity comments first.
	self assert: entity class equals: FamixF77Comment.
	self assert: entity content equals: ' a comment'.
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixFortran77ESOAtWithArrayArgument [
	"Special case of a D__ function call with an array as argument

      subroutine hello
        integer arr(10)
> > >   x = D__(y,arr(z))  < < <
      end
"
	self skip.

	programFile := self jsonToIAST: '{"meta":{"miVersion":"fortran77","miFilename":"/tmp/tmp.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:23)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"dims":{"anno":[],"list":[{"anno":[],"lower":null,"span":"(2:21)-(2:22)","upper":{"anno":[],"span":"(2:21)-(2:22)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}}],"span":"(2:21)-(2:22)"},"initial":null,"length":null,"span":"(2:17)-(2:23)","type":"array","variable":{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"arr","tag":"variable"}}}],"span":"(2:17)-(2:23)"},"span":"(2:9)-(2:23)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:9)-(2:15)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:9)-(3:25)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(3:17)-(3:17)","tag":"value","value":{"contents":"y","tag":"variable"}},"tag":"expr"},"name":null,"span":"(3:17)-(3:17)"},{"anno":[],"expr":{"contents":{"anno":[],"expression":{"anno":[],"span":"(3:19)-(3:21)","tag":"value","value":{"contents":"arr","tag":"variable"}},"indices":{"anno":[],"list":[{"anno":[],"index":{"anno":[],"span":"(3:23)-(3:23)","tag":"value","value":{"contents":"z","tag":"variable"}},"name":null,"span":"(3:23)-(3:23)","tag":"single"}],"span":"(3:23)-(3:23)"},"span":"(3:19)-(3:24)","tag":"subscript"},"tag":"expr"},"name":null,"span":"(3:19)-(3:24)"}],"span":"(3:17)-(3:24)"},"function":{"anno":[],"span":"(3:13)-(3:15)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(3:13)-(3:25)","tag":"function_call"},"span":"(3:9)-(3:25)","tag":"assign_expression","target":{"anno":[],"span":"(3:9)-(3:9)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.
	programFile accept: visitor.

	self assert: (visitor model allWithType: FamixF77Variable) size equals: 1. "arr"
	self assert: (visitor model allWithType: FamixF77Access) size equals: 4. "x, y, arr, z"

]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77Invocation [
	| entity invocation caller callee |

	callee := IASTSubroutine new
		entityName: 'sub';
		yourself.

	caller := IASTMainProgram new
			entityName: 'main';
			body: { IASTInvocation new entityName: 'sub'; yourself };
			yourself.
	programFile body: { callee . caller }.

	programFile accept: visitor.
	entity := visitor model detect: [:each | each class = FamixF77ProgramFile ].

	self assert: entity programUnits first class equals: FamixF77PUSubroutine.
	self assert: entity programUnits second class equals: FamixF77PUMain.

	self assert: entity programUnits second outgoingInvocations size equals: 1.
	invocation := entity programUnits second outgoingInvocations first.
	
	self assert: invocation class equals: FamixF77Invocation.
	self assert: invocation sender equals: entity programUnits second.
	self assert: (invocation attributeAt: #entity ifAbsent: [ nil ] ) isNotNil
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77LocalVariable [

	| entity var |
	programFile body: { IASTSubroutine new
			 entityName: 'sub';
			 body: { (self defaultVariable: 'aVar' withType: 'integer') };
			 yourself }.
	programFile accept: visitor.

	entity := visitor model detect: [:each | each class = FamixF77ProgramFile ].

	self assert: entity programUnits first localVariables size equals: 1.

	var := entity programUnits first localVariables first.
	self assert: var class equals: FamixF77Variable.
	self assert: var name equals: 'aVar'.
	self assert: var declaredType class equals: FamixF77TypeIntrinsic.
	self assert: var declaredType name equals: 'integer'.
	self assert: var parentBehaviouralEntity isNotNil.
	self
		assert: var parentBehaviouralEntity
		equals: entity programUnits first
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77PUBlockdata [

	| entity |
	programFile body: { IASTBlockData new
			 entityName: 'bdata';
			 yourself
	}.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUBlockdata.
	self assert: entity name equals: 'bdata'.
	self assert: entity programFile isNotNil.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77PUFunction [

	| entity |
	programFile body: { IASTFunction new
			 entityName: 'fct';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUFunction.
	self assert: entity name equals: 'fct'.
	self assert: entity programFile isNotNil.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77PUFunctionWithDeclaredType [

	| entity |
	programFile body: { IASTFunction new
			 entityName: 'fct';
			 returnType: (IASTTypeRef new entityName: 'integer');
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUFunction.
	self assert: entity name equals: 'fct'.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'integer'.
	self assert: entity programFile isNotNil.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77PUFunctionWithParameter [

	| entity param |
	programFile body: { IASTFunction new
			 entityName: 'fct';
			 parameters: { self defaultParameter };
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUFunction.
	self assert: entity name equals: 'fct'.
	self assert: entity programFile isNotNil.

	self assert: entity parameters size equals: 1.
	param := entity parameters first.
	self assert: param class equals: FamixF77Parameter.
	self assert: param name equals: 'var'.
	self assert: param parentBehaviouralEntity equals: entity.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77PUMain [

	| entity |
	programFile body: { IASTMainProgram new
			 entityName: 'main';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUMain.
	self assert: entity name equals: 'main'.
	self assert: entity programFile isNotNil.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77ProgramFile [
	| entity |
	programFile accept: visitor.

	self assert: visitor model size equals: 6.

	entity := visitor model allWithType: FamixF77ProgramFile.
	self assert: entity size equals: 1.
	
	entity := entity first.
	self assert: entity class equals: FamixF77ProgramFile.
	self assert: entity filename equals: 'fortran77.f'.
	self assert: entity programUnits size equals: 0
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77SourceAnchor [
	| entity |
	entity := self defaultAnchor accept: visitor.
	
	self assert: entity class equals: FamixF77IndexedFileAnchor.
	self assert: entity fileName equals: 'fortran77.f'.
	self assert: entity startLine equals: 1.
	self assert: entity startColumn equals: 7.
	self assert: entity endLine equals: 2.
	self assert: entity endColumn equals: 10.
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77Subroutine [

	| entity |
	programFile body: { IASTSubroutine new
			 entityName: 'sub';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUSubroutine.
	self assert: entity name equals: 'sub'.
	self assert: entity programFile isNotNil.
	self assert: entity parameters size equals: 0
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testFamixFortran77WriteInvocation [
	"program main
	write(unit=var)
	end "

	| entity caller iastEntity |


	caller := IASTMainProgram new
			entityName: 'main';
			body: { IASTIOStatement new entityName: 'write'; format: { IASTVarAccess new entityName: 'var' }; yourself };
			yourself.
	programFile body: { caller }.

	programFile accept: visitor.
	entity := visitor model detect: [:each | each class = FamixF77ProgramFile ].
	
	self assert: entity programUnits first class equals: FamixF77PUMain.
	self assert: entity programUnits first outgoingInvocations size equals: 0.

	self assert: entity programUnits first accesses size equals: 1.
	
	iastEntity := entity programUnits first accesses first attributeAt: #entity ifAbsent: [ nil ].
	self assert: iastEntity  isNotNil.
	
	self assert: iastEntity entityName equals:  'var'.
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testFamixFunctionReturnValue [
	"
	function f()
	f = 2
	end
	"

	| entity |
	entity := IASTFunction new entityName: 'f'.
	entity body: { (IASTVarAccess new
			 entityName: 'f';
			 isWrite: true) }.

	entity accept: visitor.

	self
		assert:
		(visitor model allWithType: FamixF77PUFunction) anyOne accesses size
		equals: 0
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testImplicitWithRange [

	| entity sub |
	programFile body: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { IASTImplicit new
				rules: { (self implicitRule: 'character' range: { #( $c $f ) }) }
			 };
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	sub := entity programUnits first.

	self assert: sub implicits size equals: 1.

	entity := sub implicits anyOne.
	self assert: entity class equals: IASTImplicitTypingRule.

	self assert: entity ranges size equals: 1.

	entity := entity ranges anyOne.
	self assert: entity size equals: 2.
	self assert: entity first equals: $c.
	self assert: entity second equals: $f
]

{ #category : 'tests-esope' }
IASTToFamixVisitorTest >> testIncludeFamixFortran77Subroutine [

	"
      subroutine test
c@_#include ""point.seg""
      end
	"

	| pf sub include includeStmt |
	includeStmt := IASTInclude new
		               includeCommand: '#include';
		               entityName: 'point.seg';
		               yourself.
	programFile body: { (IASTSubroutine new
			 entityName: 'test';
			 body: { includeStmt };
			 yourself) }.

	pf := programFile accept: visitor.

	self assert: pf programUnits size equals: 1.

	sub := pf programUnits first.
	self assert: sub class equals: FamixF77PUSubroutine.
	self assert: sub includes size equals: 1.

	include := sub includes first.
	self assert: include class equals: FamixF77Include.
	self assert: include filename equals: 'point.seg'.
	self assert: include includedBy equals: sub "
	self assert: include source equals: programFile."
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testMultipleImplicit [

	| entity sub |
	programFile body: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { IASTImplicit new
				rules: { (self implicitRule: 'character' range: #( #( $c ) #( $d $f ) )) }
			 } ;
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	sub := entity programUnits first.

	self assert: sub implicits size equals: 1.

	entity := sub implicits anyOne.
	self assert: entity class equals: IASTImplicitTypingRule.

	self assert: entity ranges size equals: 2.

	entity := entity ranges first.
	self assert: entity size equals: 1.
	self assert: entity anyOne equals: $c.

	entity := sub implicits anyOne ranges second.
	self assert: entity size equals: 2.
	self assert: entity first equals: $d.
	self assert: entity second equals: $f
]

{ #category : 'tests-fortran' }
IASTToFamixVisitorTest >> testSimpleImplicit [

	| entity sub |
	programFile body: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { IASTImplicit new
				rules: { (self implicitRule: 'character' range: { #( $c ) }) }
			};
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	sub := entity programUnits first.

	self assert: sub implicits size equals: 1.

	entity := sub implicits anyOne.
	self assert: entity class equals: IASTImplicitTypingRule.

	self assert: entity ranges size equals: 1.

	entity := entity ranges anyOne.
	self assert: entity size equals: 1.
	self assert: entity anyOne equals: $c.

	entity := sub implicits anyOne.
	self assert: entity forType class equals: IASTTypeRef.
	self assert: entity forType entityName equals: 'character'
]

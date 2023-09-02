"
An IASTVisitorF77Test is a test class for testing the behavior of IASTVisitorF77
"
Class {
	#name : #IASTToFamixVisitorTest,
	#superclass : #TestCase,
	#instVars : [
		'visitor',
		'programFile'
	],
	#category : #'EsopeImporter-Tests-Visitor'
}

{ #category : #running }
IASTToFamixVisitorTest >> anchorFrom: startPoint to: endPoint [

	^ IASTIndexedFileAnchor new
		  startLine: startPoint x;
		  startColumn: startPoint y;
		  endLine: endPoint x;
		  endColumn: endPoint y;
		  fileName: 'fortran77.f';
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultAnchor [

	^ self anchorFrom: 1 @ 7 to: 2 @ 10
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultEmptySegment: segmentName [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: {  };
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultImplicit: ranges for: typeName [

	^ IASTImplicit new
		  forType: (self defaultType: typeName);
		  ranges: ranges;
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultImplicitNone [

	^ IASTImplicit new
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultNamedEntity: entityName for: aClassName [

	^ aClassName new
		  sourceAnchor: self defaultAnchor;
		  entityName: entityName;
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultParameter [

	^ IASTParameter new
		  entityName: 'var';
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultSegment: segmentName [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: {  };
		  yourself
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultSegment: segmentName with: dictDeclarations [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: (dictDeclarations collect: [ :assoc | 
					   self defaultVariable: assoc key withType: assoc value ]);
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultSegmentComand: commandName on: varName [

	^ IASTEsopeSegCommand new
		  esopeCommand: commandName;
		  entityName: varName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultType: typeName [

	^ IASTTypeRef new
		  entityName: typeName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultVarAccess: name [

	^ self defaultVarAccess: name isWrite: false
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultVarAccess: name isWrite: boolean [

	^ IASTVarAccess new
		  sourceAnchor: self defaultAnchor;
		  isWrite: boolean;
		  entityName: name;
		  yourself
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> defaultVarEsoAt: entities [

	^ IASTVarEsoAt new
		  sourceAnchor: self defaultAnchor;
		  entities:
			  (entities collect: [ :entity | self defaultVarAccess: entity ]);
		  yourself
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> defaultVarEsoSl: entities [

	^ IASTVarEsoSl new
		  sourceAnchor: self defaultAnchor;
		  entities:
			  (entities collect: [ :entity | self defaultVarAccess: entity ]);
		  yourself
]

{ #category : #'default values' }
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

{ #category : #running }
IASTToFamixVisitorTest >> defaultVariable: varName withType: typeName [

	^ IASTVariable new
		  sourceAnchor: self defaultAnchor;
		  entityName: varName;
		  typeSpec: (self defaultType: typeName);
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> setUp [
	super setUp.
	
	programFile := IASTProgramFile new filename: 'fortran77.f' ; yourself.
	visitor := IASTToFortranVisitor new.
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateDummyFamixFortran77Subroutine [

	"
      subroutine __$__
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

	programFile progUnits: { (IASTIncludedFile new
			 entityName: 'point.seg';
			 sourceAnchor: self defaultAnchor;
			 body: { 
					 l.
					 segment };
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixFortran77IncludedFile.
	self assert: entity name equals: 'point.seg'.

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

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeAccessors [

	"
	d__(ptr,attr)
	"

	| d__ entity access |
	d__ := self defaultVarEsoAt: #( #ptr #attr ).

	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { d__ };
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

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeAccessorsWithArg [

	"
	d__(ptr,attr(i))
	"

	| d__ entity access |
	d__ := (self defaultNamedEntity: 'd__' for: IASTVarEsoAt) entities:
		       { 
			       (self defaultNamedEntity: 'ptr' for: IASTVarAccess).
			       ((self defaultNamedEntity: 'attr' for: IASTInvocation) 
				        arguments:
				        { (self defaultNamedEntity: 'i' for: IASTParameter) }) }.

	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { d__ };
			 yourself) }.
	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self assert: entity programUnits first accesses size equals: 3.

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
		equals: 'i'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNil.


	access := entity programUnits first accesses third.
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

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeAccessorsWithArgs [

	"
	d__(ptr,attr(i,j))
	"

	| d__ entity access |
	d__ := (self defaultNamedEntity: 'd__' for: IASTVarEsoAt) entities:
		       { 
			       (self defaultNamedEntity: 'ptr' for: IASTVarAccess).
			       ((self defaultNamedEntity: 'attr' for: IASTInvocation) 
				        arguments: { 
						        (self defaultNamedEntity: 'i' for: IASTParameter).
						        (self defaultNamedEntity: 'j' for: IASTParameter) }) }.

	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { d__ };
			 yourself) }.
	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self assert: entity programUnits first accesses size equals: 4.

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
		equals: 'i'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNil.

	access := entity programUnits first accesses third.
	self assert: access target isNil.
	self assert: (access attributeAt: #entity ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #entity ifAbsent: [  ]) entityName
		equals: 'j'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNil.

	access := entity programUnits first accesses at: 4.
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

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeAccessorsWithArgsWithDot [

	"
	d__(ptr,attr(i,d__(p,j)))
	"

	| d__ entity access |
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

	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { d__ };
			 yourself) }.
	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self assert: entity programUnits first accesses size equals: 5.

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
		equals: 'i'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNil.

	access := entity programUnits first accesses third.
	self assert: access target isNil.
	self assert: (access attributeAt: #entity ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #entity ifAbsent: [  ]) entityName
		equals: 'p'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNil.

	access := entity programUnits first accesses at: 4.
	self assert: access target isNil.
	self assert: (access attributeAt: #entity ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #entity ifAbsent: [  ]) entityName
		equals: 'j'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #pointer ifAbsent: [  ]) entityName
		equals: 'p'.

	access := entity programUnits first accesses at: 5.
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

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeAccessorsWithDotArg [

	"
	d__(ptr,attr(d__(p,i)))
	"

	| d__ entity access |
	d__ := (self defaultNamedEntity: nil for: IASTVarEsoAt) entities:
		       { 
			       (self defaultNamedEntity: 'ptr' for: IASTVarAccess).
			       ((self defaultNamedEntity: 'attr' for: IASTInvocation) 
				        arguments:
					        { ((self defaultNamedEntity: nil for: IASTVarEsoAt) 
						         entities: { 
								         (self defaultNamedEntity: 'p' for: IASTParameter).
								         (self defaultNamedEntity: 'i' for: IASTParameter) }) }) }.

	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { d__ };
			 yourself) }.
	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self assert: entity programUnits first accesses size equals: 4.

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
		equals: 'p'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNil.

	access := entity programUnits first accesses at: 3.
	self assert: access target isNil.
	self assert: (access attributeAt: #entity ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #entity ifAbsent: [  ]) entityName
		equals: 'i'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #pointer ifAbsent: [  ]) entityName
		equals: 'p'.

	access := entity programUnits first accesses at: 4.
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

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeCommandSegini [

	"
	segini ptr
	"

	| famixSegini iastSegini progFile |
	iastSegini := self defaultSegmentComand: 'segini' on: 'ptr'.

	programFile progUnits: { IASTSubroutine new
			 entityName: 'sub';
			 body: { iastSegini };
			 yourself }.

	progFile := programFile accept: visitor.
	
	self assert: progFile programUnits size equals: 1.

	self assert: (visitor model allWithType: FamixEsopeCommand) size equals: 1.
	famixSegini := (visitor model allWithType: FamixEsopeCommand) first.
	self assert: famixSegini commandName equals: 'segini'.
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopePointerDeclaration [

	"	
      pointeur ptr.seg
	"

	| var entity |
	var := IASTEsopePointer new
		       sourceAnchor: (self anchorFrom: 2 @ 1 to: 2 @ 23 );
		       entityName: 'ptr.seg';
		       yourself.

	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { var };
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self
		assert: (visitor model allWithType: FamixFortran77Variable) size
		equals: 1.
	entity := (visitor model allWithType: FamixFortran77Variable) first.
	self assert: entity name equals: 'ptr'.
	self assert: entity declaredType name equals: 'seg'.
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeSegment [

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

	programFile progUnits: { IASTSubroutine new
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
	self assert: attribute class equals: FamixEsopeAttribute.
	self assert: attribute name equals: 'uname'.
	self assert: attribute declaredType name equals: 'character'.
	
	attribute := entity attributes second.
	self assert: attribute class equals: FamixEsopeAttribute.
	self assert: attribute name equals: 'status'.
	self assert: attribute declaredType name equals: 'logical'.
	
	attribute := entity attributes third.
	self assert: attribute class equals: FamixEsopeAttribute.
	self assert: attribute name equals: 'age'.
	self assert: attribute declaredType name equals: 'integer'.
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeSlashWithLitteralDim [

	"
c  lb.bref(/1)
	s__(d__(ptr,attr),1)
	"

	| s__ entity access |
	self skip.
	self flag: #TODO.
	s__ := self defaultVarEsoSl: #( #ptr #attr ).

	programFile progUnits: { (IASTSubroutine new
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

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77 [

	| entity |
	programFile progUnits: { IASTSubroutine new
		entityName: 'sub';
		body: #();
		yourself
	}.
	programFile accept: visitor.

	self assert: visitor model size equals: 2.

	entity := visitor model detect: [:each | each class = FamixFortran77ProgramFile ].
	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixFortran77PUSubroutine.
	self assert: entity name equals: 'sub'.

]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77Comment [

	| entity comment |

	programFile progUnits: { IASTMainProgram new
			 entityName: 'main';
			 body: { IASTComment new
		           text: 'a normal comment';
		           yourself. };
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.
	self assert: entity programUnits first comments size equals: 1.

	comment := entity programUnits first comments first.
	self assert: comment class equals: FamixFortran77Comment.
	self assert: comment content equals: 'a normal comment'.
	self deny: comment isEsope.
	
	self assert: comment commentedEntity equals: entity programUnits first.
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77Invocation [
	| entity invocation caller callee |

	callee := IASTSubroutine new
		entityName: 'sub';
		yourself.

	caller := IASTMainProgram new
			entityName: 'main';
			body: { IASTInvocation new entityName: 'sub'; yourself };
			yourself.
	programFile progUnits: { callee . caller }.

	programFile accept: visitor.
	entity := visitor model detect: [:each | each class = FamixFortran77ProgramFile ].

	self assert: entity programUnits first class equals: FamixFortran77PUSubroutine.
	self assert: entity programUnits second class equals: FamixFortran77PUMain.

	self assert: entity programUnits second outgoingInvocations size equals: 1.
	invocation := entity programUnits second outgoingInvocations first.
	
	self assert: invocation class equals: FamixFortran77Invocation.
	self assert: invocation sender equals: entity programUnits second.
	self assert: (invocation attributeAt: #entity ifAbsent: [ nil ] ) isNotNil
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77LocalVariable [

	| entity var |
	programFile progUnits: { IASTSubroutine new
			 entityName: 'sub';
			 body: { (self defaultVariable: 'aVar' withType: 'integer') };
			 yourself }.
	programFile accept: visitor.

	entity := visitor model detect: [:each | each class = FamixFortran77ProgramFile ].

	self assert: entity programUnits first localVariables size equals: 1.

	var := entity programUnits first localVariables first.
	self assert: var class equals: FamixFortran77Variable.
	self assert: var name equals: 'aVar'.
	self assert: var declaredType class equals: FamixFortran77Type.
	self assert: var declaredType name equals: 'integer'.
	self assert: var parentBehaviouralEntity isNotNil.
	self
		assert: var parentBehaviouralEntity
		equals: entity programUnits first
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUBlockdata [

	| entity |
	programFile progUnits: { IASTBlockData new
			 entityName: 'bdata';
			 yourself
	}.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixFortran77PUBlockdata.
	self assert: entity name equals: 'bdata'.
	self assert: entity programFile isNotNil.
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUComment [
	| entity |
	programFile progUnits: { IASTComment new
		text: ' a comment' ;
		isProgUnit: true ;
		yourself  
	}.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixFortran77PUComment.
	self assert: entity content equals: ' a comment'.
	self assert: entity programFile isNotNil.
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUFunction [

	| entity |
	programFile progUnits: { IASTFunction new
			 entityName: 'fct';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixFortran77PUFunction.
	self assert: entity name equals: 'fct'.
	self assert: entity programFile isNotNil.
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUFunctionWithParameter [

	| entity param |
	programFile progUnits: { IASTFunction new
			 entityName: 'fct';
			 parameters: { self defaultParameter };
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixFortran77PUFunction.
	self assert: entity name equals: 'fct'.
	self assert: entity programFile isNotNil.

	self assert: entity parameters size equals: 1.
	param := entity parameters first.
	self assert: param class equals: FamixFortran77Parameter.
	self assert: param name equals: 'var'.
	self assert: param parentBehaviouralEntity equals: entity.
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUMain [

	| entity |
	programFile progUnits: { IASTMainProgram new
			 entityName: 'main';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixFortran77PUMain.
	self assert: entity name equals: 'main'.
	self assert: entity programFile isNotNil.
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77ProgramFile [
	| entity |
	programFile accept: visitor.

	self assert: visitor model size equals: 1.

	entity := visitor model first.
	self assert: entity class equals: FamixFortran77ProgramFile.
	self assert: entity filename equals: 'fortran77.f'.
	self assert: entity programUnits size equals: 0
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77SourceAnchor [
	| entity |
	entity := self defaultAnchor accept: visitor.
	
	self assert: entity class equals: FamixFortran77IndexedFileAnchor.
	self assert: entity fileName equals: 'fortran77.f'.
	self assert: entity startLine equals: 1.
	self assert: entity startColumn equals: 7.
	self assert: entity endLine equals: 2.
	self assert: entity endColumn equals: 10.
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77Subroutine [

	| entity |
	programFile progUnits: { IASTSubroutine new
			 entityName: 'sub';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixFortran77PUSubroutine.
	self assert: entity name equals: 'sub'.
	self assert: entity programFile isNotNil.
	self assert: entity parameters size equals: 0
]

{ #category : #running }
IASTToFamixVisitorTest >> testCreateFamixFortran77SubroutineWithSimpleImplicit [

	| entity sub |
	programFile progUnits: { IASTSubroutine new
			 entityName: 'sub';
			 body: {
			 	self defaultImplicit: { #($c $s) } for: 'character' .
				self defaultImplicit: { #($i $j $k) } for: 'integer' .
			 };
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	sub := entity programUnits first.
	self assert: sub class equals: FamixFortran77PUSubroutine.
	self assert: sub name equals: 'sub'.
	self assert: sub programFile isNotNil.

	self assert: sub implicits size equals: 2.
	self assert: sub implicits first class equals: IASTImplicit.
	self assert: sub implicits second class equals: IASTImplicit.
	
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateIncludeFamixFortran77Subroutine [

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
	programFile progUnits: { (IASTSubroutine new
			 entityName: 'test';
			 body: { includeStmt };
			 yourself) }.

	pf := programFile accept: visitor.

	self assert: pf programUnits size equals: 1.

	sub := pf programUnits first.
	self assert: sub class equals: FamixFortran77PUSubroutine.
	self assert: sub includes size equals: 1.

	include := sub includes first.
	self assert: include class equals: FamixFortran77Include.
	self assert: include filename equals: 'point.seg'.
	self assert: include includedBy equals: sub "
	self assert: include source equals: programFile."
]

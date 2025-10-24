Extension { #name : 'FamixEsopeModel' }

{ #category : '*EsopeImporter' }
FamixEsopeModel >> initialize [

	super initialize.
	self name: 'EsopeMooseModel'.
	"self setIntrinsicTypes."
	self newEsopePSTR
]

{ #category : '*EsopeImporter' }
FamixEsopeModel >> intrinsicTypes [

	^ {
		  (#integer -> (self newTypeIntrinsic name: #integer)).
		  (#real -> (self newTypeIntrinsic name: #real)).
		  (#complex -> (self newTypeIntrinsic name: #complex)).
		  (#logical -> (self newTypeIntrinsic name: #logical)).
		  (#character -> (self newTypeIntrinsic name: #character)) }
		  asDictionary
]

{ #category : '*EsopeImporter' }
FamixEsopeModel >> newEsopePSTR [

"
*-PSTR
*:PSTR    SEGMENT D'ENTETE DES STRUCTURES : NOUVELLE DEFINITION
*:NOMCOD  NOM DU CODE AUQUEL APPARTIENT LA STRUCTURE (CRONOS, APOLLO ..)
*:DATE    DATE DE DEBUT DE JOB
*:HEURE   HEURE DE DEBUT DE JOB
*:TYPSEG  TYPE DES SEGMENTS APPARTENANTS A LA STRUCTURE
*:TYPREF  TYPE DES OBJETS REFERENCES PAR LA STRUCTURE
*:IBSEG   NUMERO MAX. DU SEGMENT AJOUTE A LA STRUCTURE
*:IBREF   NUMERO MAX. DE L'OBJET REFERENCE PAR LA STRUCTURE
*:PNTSEG  POINTEURS DES SEGMENTS APPARTENANTS A LA STRUCTURE
*:PNTREF  POINTEURS DES OBJETS REFERENCES PAR LA STRUCTURE
      SEGMENT , PSTR
        CHARACTER*8 NOMCOD, DATE, HEURE, TYPSEG(NBSEG), TYPREF(NBREF)
        INTEGER     IBSEG, IBREF,        PNTSEG(NBSEG), PNTREF(NBREF)
      ENDSEGMENT

"

"TODO: definition complete"

	^self newSegment
		name: 'PSTR'; 
		attributes: {};
		isStub: true; 
		yourself.
]

{ #category : '*EsopeImporter' }
FamixEsopeModel >> setIntrinsicTypes [

	self attributeAt: #instrinsicTypes put: self intrinsicTypes.
	self attributeAt: #unknownType put: [ self newTypeUnknown ]
]

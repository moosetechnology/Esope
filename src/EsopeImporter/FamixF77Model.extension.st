Extension { #name : 'FamixF77Model' }

{ #category : '*EsopeImporter' }
FamixF77Model >> initialize [

	super initialize.
	self name: 'F77MooseModel'.
	self attributeAt: #instrinsicTypes put: self intrinsicTypes.
	self attributeAt: #unknownType put: [ self newTypeUnknown ]
]

{ #category : '*EsopeImporter' }
FamixF77Model >> intrinsicTypes [
	^ {
		  (#integer -> (self newTypeIntrinsic name: #integer)).
		  (#real -> (self newTypeIntrinsic name: #real)).
		  (#complex -> (self newTypeIntrinsic name: #complex)).
		  (#logical -> (self newTypeIntrinsic name: #logical)).
		  (#character -> (self newTypeIntrinsic name: #character)) 
	} asDictionary
]

{ #category : '*EsopeImporter' }
FamixF77Model >> setIntrinsicTypes [

	self attributeAt: #instrinsicTypes put: self intrinsicTypes.
	self attributeAt: #unknownType put: [ self newTypeUnknown ]
]

Extension { #name : 'FamixEsopeModel' }

{ #category : '*EsopeImporter' }
FamixEsopeModel >> initialize [

	super initialize.
	self name: 'EsopeMooseModel'
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

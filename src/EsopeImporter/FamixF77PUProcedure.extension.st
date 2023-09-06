Extension { #name : #FamixF77PUProcedure }

{ #category : #'*EsopeImporter' }
FamixF77PUProcedure >> allLocalVariables [

	self flag: #FIXME. "Find better way to flatmap types"
	^self localVariables
	  ,
		  (self includes collect: [ :include | 
			   include included localVariables ]) flattened
]

{ #category : #'*EsopeImporter' }
FamixF77PUProcedure >> allTypes [

	self flag: #FIXME. "Find better way to flatmap types"
	^self types
	  , (self includes collect: [ :include | include included types ])
			  flattened
]

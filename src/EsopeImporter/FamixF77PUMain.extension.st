Extension { #name : #FamixF77PUMain }

{ #category : #'*EsopeImporter' }
FamixF77PUMain >> allLocalVariables [

	^self localVariables
	  ,
	(self includes
		flatCollect: [ :include | 
			   include included ifNotNil: [ :included | included localVariables ] ]
	)
]

{ #category : #'*EsopeImporter' }
FamixF77PUMain >> allTypes [

	self flag: #FIXME. "Find better way to flatmap types"
	^self types
	  , 
   (self includes 
		collect: [ :include | include included ifNotNil: [ :included | included types ] ]
	) flattened
]

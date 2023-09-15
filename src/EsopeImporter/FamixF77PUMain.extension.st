Extension { #name : #FamixF77PUMain }

{ #category : #'*EsopeImporter' }
FamixF77PUMain >> allLocalVariables [

	self flag: #FIXME. "Find better way to flatmap types"
	^self localVariables
	  ,
	(self includes
		collect: [ :include | 
			   include included ifNotNil: [ :included | included localVariables ] ]
	) flattened
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

Extension { #name : 'FamixF77PUProcedure' }

{ #category : '*EsopeImporter' }
FamixF77PUProcedure >> allLocalVariables [

	^self parameters , super allLocalVariables

]

{ #category : '*EsopeImporter' }
FamixF77PUProcedure >> allTypes [

	self flag: #FIXME. "Find better way to flatmap types"
	^self types
	  , 
   (self includes 
		flatCollect: [ :include | include included ifNil: [ #() ] ifNotNil: [ :included | included types ] ]
	)
]

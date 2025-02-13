Extension { #name : 'FamixEsopeTEntityCreator' }

{ #category : '*EsopeImporter' }
FamixEsopeTEntityCreator >> newEsopeCommand: esopeCommandName [

	| selector |
	selector := ('newCommand' , esopeCommandName asLowercase capitalized) asSymbol.
	1halt.
	^ self perform: selector
]

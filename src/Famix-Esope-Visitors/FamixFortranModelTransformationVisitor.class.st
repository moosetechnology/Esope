Class {
	#name : 'FamixFortranModelTransformationVisitor',
	#superclass : 'FamixEsopeVisitor',
	#instVars : [
		'puUses',
		'model'
	],
	#category : 'Famix-Esope-Visitors',
	#package : 'Famix-Esope-Visitors'
}

{ #category : 'helpers' }
FamixFortranModelTransformationVisitor >> addUsesIn: puMain file: mainfile and: puModule [

	puUses do: [ :assoc || sender target |
		sender := assoc key.
		target := assoc value.

		"self addUse: target in: sender."
	].

	puUses removeAll.
]

{ #category : 'helpers' }
FamixFortranModelTransformationVisitor >> initialize [

	super initialize.

	model := OrderedCollection new
]

{ #category : 'helpers' }
FamixFortranModelTransformationVisitor >> programFile: programFile in: filename modules: programUnits [

	| puModule puMain |

	puModule := OrderedCollection new.
	puMain := nil.

	programUnits do: [ :progUnit |
		(progUnit class = FASTFortran2kProgramMain)
			ifTrue: [ puMain := progUnit  ]
			ifFalse: [ puModule add: progUnit ]
	].

	puModule ifNotEmpty: [
		programFile addProgramUnit: 
			((self makePuModule: programFile)
					procedures: programUnits;
					yourself)
	].

	puMain ifNotNil: [ programFile addProgramUnit: puMain ].

	self addUsesIn: puMain file: filename and: puModule
]

{ #category : 'visiting' }
FamixFortranModelTransformationVisitor >> visitFamixF77PUFunction: aFamixF77PUFunction [

	^self visitFamixF77ProgramUnit: aFamixF77PUFunction
]

{ #category : 'visiting' }
FamixFortranModelTransformationVisitor >> visitFamixF77PUSubroutine: aFamixF77PUSubroutine [

	^self visitFamixF77ProgramUnit: aFamixF77PUSubroutine
]

{ #category : 'visiting' }
FamixFortranModelTransformationVisitor >> visitFamixF77ProgramFile: aFamixProgramFile [

	| programUnits programFile |
	puUses := OrderedCollection new: 2.
	programUnits := OrderedCollection new.

	programFile := FASTFortran2kProgramFile new 
		"filename: (filename, '90');"
		mooseModel: model;
		comments: (
			aFamixProgramFile comments collect: [ :comment | comment accept: self  ]
		);
		yourself.

	aFamixProgramFile programUnits do: [ :progUnit |
			programUnits add: (progUnit accept: self)
	].

	"self
		programFile: programFile
		in: aFamixProgramFile famix filename
		modules: programUnits."

	^programFile 
	
]

{ #category : 'visiting' }
FamixFortranModelTransformationVisitor >> visitFamixF77ProgramUnit: aProgramUnit [

	| visitor f2kProgramUnit |
	aProgramUnit bindFASTModel.
	visitor := FASTFortranModelTransformationVisitor new.
	f2kProgramUnit := aProgramUnit fast accept: visitor.
	puUses := visitor useNeeded.
	^ f2kProgramUnit
]

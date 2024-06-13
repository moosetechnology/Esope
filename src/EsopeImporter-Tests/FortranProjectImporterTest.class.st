Class {
	#name : #FortranProjectImporterTest,
	#superclass : #TestCase,
	#instVars : [
		'importer'
	],
	#category : #'EsopeImporter-Tests-Importer'
}

{ #category : #running }
FortranProjectImporterTest >> setUp [
	super setUp.

	importer := FortranProjectImporter new.
	importer stopOnError: true.
	importer errorHandler: FortranErrorManager new.
	importer	famixModel: FamixEsopeModel new.

]

{ #category : #tests }
FortranProjectImporterTest >> testMakePointerFromVariable [
	"We have a pointer variable and a normal variable with the same name
	 the 2nd should be merged into the 1st which keeps its declared type and
	 gets the accesses of the 2nd"

	| subroutine variable pointer esopeCommand |

	subroutine := importer famixModel newPUSubroutine name: 'sub'.

	variable := importer famixModel newVariable
		name: 'pointerForASegment' ;
		declaredType: FamixF77TypeIntrinsic new ;
		parentBehaviouralEntity: subroutine.
	pointer  := importer famixModel newVariable
		name: 'pointerForASegment' ;
		declaredType: FamixEsopeSegment new ;
		parentBehaviouralEntity: subroutine.

	importer famixModel newAccess
		accessor: subroutine ;
		variable: variable.
	esopeCommand := importer famixModel newCommand
		accessor: subroutine ;
		variable: pointer.

	self assert: subroutine accesses size equals: 2.
	self assert: subroutine localVariables size equals: 2.

	importer newResolver.
	importer makePointerFromVariable: esopeCommand.

	self assert: subroutine accesses size equals: 2.
	self assert: subroutine localVariables size equals: 1.
]

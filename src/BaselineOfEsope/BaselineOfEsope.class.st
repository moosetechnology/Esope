Class {
	#name : #BaselineOfEsope,
	#superclass : #BaselineOf,
	#category : #BaselineOfEsope
}

{ #category : #baselines }
BaselineOfEsope >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec blessing: #baseline.
			spec description: 'Esope related packages'.
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]

]

{ #category : #baselines }
BaselineOfEsope >> defineDependencies: spec [
	spec
		baseline: 'PetitParser2'
		with: [ spec repository: 'github://kursjan/petitparser2' ];
		
		baseline: 'FamixFortran'
		with: [ spec repository: 'github://moosetechnology/Famix-Fortran' ];
		
		baseline: 'FASTFortran'
		with: [ spec repository: 'github://moosetechnology/FAST-Fortran' ]
]

{ #category : #baselines }
BaselineOfEsope >> defineGroups: spec [

	spec
		group: 'rewriter'
		with: #( 'Esope-Rewriter' 'Esope-Rewriter-Tests' );
		
		group: 'famix'
		with: #( 'Famix-Esope-Entities' 'Famix-Esope-Generator'
			   'Famix-Esope-Tests' )
]

{ #category : #baselines }
BaselineOfEsope >> definePackages: spec [
	spec
		repository: 'github://moosetechnology/Esope';
		package: 'Esope-Rewriter' with: [ spec requires: #(PetitParser2) ];
		package: 'Famix-Esope-Entities' with: [ spec requires: #(FamixFortran) ] ;
		package: 'Famix-Esope-Generator' with: [ spec requires: #(FamixFortran) ]
]

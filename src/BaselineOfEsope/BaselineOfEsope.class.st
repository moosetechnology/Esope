Class {
	#name : 'BaselineOfEsope',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfEsope',
	#package : 'BaselineOfEsope'
}

{ #category : 'baselines' }
BaselineOfEsope >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec description: 'Esope related packages'.
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]

]

{ #category : 'baselines' }
BaselineOfEsope >> defineDependencies: spec [
	spec
		baseline: 'PetitParser2' with: [ spec repository: 'github://kursjan/petitparser2' ];
		baseline: 'FamixFortran' with: [ spec 
			loads: #('all');
			repository: 'github://moosetechnology/Famix-Fortran' 
		]

]

{ #category : 'baselines' }
BaselineOfEsope >> defineGroups: spec [

	spec
		group: 'default' with: #( core );
		group: 'core'
		  with: #( 'EsopeImporter' 'Famix-Esope-Entities' );
		group: 'all'
		  with: #( 'core' 'EsopeImporter-Tests' 'Famix-Esope-Generator' 'Famix-Esope-Tests' )
]

{ #category : 'baselines' }
BaselineOfEsope >> definePackages: spec [
	spec
		package: 'EsopeImporter' with: [ spec requires: #('Famix-Esope-Entities' PetitParser2) ];
		package: 'EsopeImporter-Tests' with: [ spec requires: #(EsopeImporter) ];
		package: 'Famix-Esope-Entities' with: [ spec requires: #(FamixFortran) ];
		package: 'Famix-Esope-Generator' with: [ spec requires: #(FamixFortran) ];
		package: 'Famix-Esope-Tests' with: [ spec requires: #('Famix-Esope-Entities') ]
]

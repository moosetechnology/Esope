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
			spec blessing: #baseline.
			spec description: 'Esope related packages'.
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]

]

{ #category : 'baselines' }
BaselineOfEsope >> defineDependencies: spec [
	spec
		baseline: 'PetitParser2' with: [ spec repository: 'github://kursjan/petitparser2' ];
		baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON' ];
		baseline: 'FamixFortran' with: [ spec repository: 'github://moosetechnology/Famix-Fortran' ]

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
		package: 'EsopeImporter' with: [ spec requires: #('Famix-Esope-Entities' PetitParser2 NeoJSON) ];
		package: 'EsopeImporter-Tests' with: [ spec requires: #(EsopeImporter) ];
		package: 'Famix-Esope-Entities' with: [ spec requires: #(FamixFortran) ];
		package: 'Famix-Esope-Generator' with: [ spec requires: #(FamixFortran) ];
		package: 'Famix-Esope-Tests' with: [ spec requires: #(FamixFortran) ]
]

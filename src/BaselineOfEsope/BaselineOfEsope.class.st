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
		with: [ spec repository: 'github://kursjan/petitparser2' ]
]

{ #category : #baselines }
BaselineOfEsope >> defineGroups: spec [
	spec 
		group: 'core'
		with: #( 'Esope' 'Esope-Tests' )

]

{ #category : #baselines }
BaselineOfEsope >> definePackages: spec [
	spec
		repository: 'github://moosetechnology/Esope';
		package: 'Esope-Rewriter' with: [ spec requires: #(PetitParser2) ];
		package: 'Esope-Rewriter-Tests';
		package: 'Famix-Esope-Entities' with: [ spec requires: #(Famix) ] ;
		package: 'Famix-Esope-Generator' with: [ spec requires: #(Famix) ];
		package: 'Famix-Esope-Tests'
]

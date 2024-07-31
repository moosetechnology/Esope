"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestEsopeImporterTests,
	#superclass : #PackageManifest,
	#category : 'EsopeImporter-Tests-Manifest'
}

{ #category : #'code-critics' }
ManifestEsopeImporterTests class >> ruleShouldntRaiseErrorRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#'EsopeImporter-Tests')) #'2024-06-21T09:10:51.132114+02:00') )
]

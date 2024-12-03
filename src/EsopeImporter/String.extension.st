Extension { #name : 'String' }

{ #category : '*EsopeImporter' }
String >> withPlatformLineEndings [
	"This method should be removed when P13 will be the minimal Pharo version supported"

	^ self withLineEndings: OSPlatform current lineEnding
]

Extension { #name : #AthensAffineTransform }

{ #category : #'*Galleon-External-Trachel' }
AthensAffineTransform >> asFloatTransform [
	^ self copy floatValues; yourself	
]

{ #category : #'*Galleon-External-Trachel' }
AthensAffineTransform >> floatValues [
	"convert all the values to float"
	x := x asFloat.
	y := y asFloat.
	sx := sx asFloat.
	sy := sy asFloat.
	shx := shx asFloat.
	shy := shy asFloat.
	
	
]

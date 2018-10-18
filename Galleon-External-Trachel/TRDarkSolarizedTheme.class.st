Class {
	#name : #TRDarkSolarizedTheme,
	#superclass : #TRSolarizedTheme,
	#category : #'Galleon-External-Trachel-Core-Theme'
}

{ #category : #accessing }
TRDarkSolarizedTheme >> trachelCanvasColor [
	"
	The original Solarized color is:
	^ self base03
	
	However, it does not fit the Pharo Dark theme
	"
	^ Color veryDarkGray
]

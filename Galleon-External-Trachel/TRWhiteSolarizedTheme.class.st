Class {
	#name : #TRWhiteSolarizedTheme,
	#superclass : #TRSolarizedTheme,
	#category : #'Galleon-External-Trachel-Core-Theme'
}

{ #category : #accessing }
TRWhiteSolarizedTheme >> trachelCanvasColor [
	"
	The original Solarized color is:
	^ self base3
	
	However, it does not fit the Pharo Dark theme
	"
	^ Color white
]

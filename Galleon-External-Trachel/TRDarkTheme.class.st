Class {
	#name : #TRDarkTheme,
	#superclass : #TRPlainColorTheme,
	#category : #'Galleon-External-Trachel-Core-Theme'
}

{ #category : #accessing }
TRDarkTheme >> trachelCanvasColor [
	^ Pharo3DarkTheme baseColor
]

{ #category : #accessing }
TRDarkTheme >> transformColor: aColor [
	"
	self new transformColor: (Color red: 0.8 green: 0.5 blue: 0.5)
	"
	^ Color h: aColor hue s: aColor saturation l: (0.5 - ((aColor lightness - 0.5) * 0.8)) alpha: aColor alpha
]
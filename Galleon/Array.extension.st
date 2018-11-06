Extension { #name : #Array }

{ #category : #'*Galleon-GUI' }
Array >> asColor [
	^ Color r: (self at:1)  g: (self at:2)  b: (self at:3)  alpha: (self at:4) 
]

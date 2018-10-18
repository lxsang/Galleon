Extension { #name : #TRCompositeShape }

{ #category : #'*Galleon-GUI' }
TRCompositeShape >> resetShapes [
	self remove.
	shapeAndOffsets removeAll.
]

Class {
	#name : #RHBitmapShape,
	#superclass : #TRBitmapShape,
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHBitmapShape >> encompassingRectangle [
	^Rectangle origin: self position  extent: self form extent. 
]

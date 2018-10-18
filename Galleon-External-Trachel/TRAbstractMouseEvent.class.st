Class {
	#name : #TRAbstractMouseEvent,
	#superclass : #TRUserInputEvent,
	#category : #'Galleon-External-Trachel-Events'
}

{ #category : #testing }
TRAbstractMouseEvent >> isPositionAboveShape [
	^ shape encompassingRectangle containsPoint: self positionFromCamera
]

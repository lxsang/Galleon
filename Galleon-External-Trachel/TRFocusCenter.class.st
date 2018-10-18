Class {
	#name : #TRFocusCenter,
	#superclass : #TRFocusing,
	#category : #'Galleon-External-Trachel-Core'
}

{ #category : #hooks }
TRFocusCenter >> on: canvas [
	| encompassingRectangle  |
	encompassingRectangle := self encompassingRectangleOf: canvas shapes.
	canvas camera translateTo: encompassingRectangle center.
]

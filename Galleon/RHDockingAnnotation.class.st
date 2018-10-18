Class {
	#name : #RHDockingAnnotation,
	#superclass : #RHAnnotationView,
	#category : #'Galleon-GUI'
}

{ #category : #drawing }
RHDockingAnnotation >> createPopUp [
	| shape lbl boxsize bt1 tl |
	lbl := TRLabelShape new text: self text.
	bt1 := self createButton: 'Dock' action: [ self announcer announce: (RHDockingEvent  for: self)].
	shape := TRCompositeShape new.
	boxsize := (lbl extent x max: bt1 extent x + 5) @ (lbl extent y + bt1 extent y + 10).
	shape extent: boxsize.
	tl := lbl extent / 2 - (boxsize / 2) + (5 @ 5).
	shape addShape: lbl translateBy: tl.
	tl := bt1 extent / 2 - (boxsize / 2) + (5 @ 5).
	tl := tl + (0 @ lbl extent y).
	shape addShape: bt1 translateBy: tl.
	^ shape
]

{ #category : #accessing }
RHDockingAnnotation >> icon [
	^ 'docking32.png'
]

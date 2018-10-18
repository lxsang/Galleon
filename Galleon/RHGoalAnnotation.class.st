Class {
	#name : #RHGoalAnnotation,
	#superclass : #RHAnnotationView,
	#category : #'Galleon-GUI'
}

{ #category : #drawing }
RHGoalAnnotation >> createPopUp [
	| shape lbl boxsize bt1 bt2 tl bt3 |
	lbl := TRLabelShape new text: self text.
	bt1 := self createButton: 'Go' action: [ self announcer announce: (RHGoalSetEvent for: self type:#annotation) ].
	bt2 := self createButton: ' + ' action: [ 
		readonly ifFalse:[
		self announcer announce: (RHGoalAddEvent for: self) ]].
	bt3 := self createButton: ' - ' action: [ 
		readonly ifFalse:[
			self announcer announce: (RHGoalRemoveEvent for: self) ]].
	shape := TRCompositeShape new.
	boxsize := (lbl extent x max: bt1 extent x + bt2 extent x + bt3 extent x + 20) @ (lbl extent y + bt1 extent y + 10).
	shape extent: boxsize.
	tl := lbl extent / 2 - (boxsize / 2) + (5 @ 5).
	shape addShape: lbl translateBy: tl.
	tl := bt1 extent / 2 - (boxsize / 2) + (5 @ 5).
	tl := tl + (0 @ lbl extent y).
	shape addShape: bt1 translateBy: tl.
	tl := bt2 extent / 2 - (boxsize / 2) + (5 @ 5).
	tl := tl + ((bt1 extent x + 5) @ lbl extent y).
	shape addShape: bt2 translateBy: tl.
	tl := bt3 extent / 2 - (boxsize / 2) + (5 @ 5).
	tl := tl + ((bt1 extent x + bt2 extent x + 10) @ lbl extent y).
	shape addShape: bt3 translateBy: tl.
	^ shape
]

{ #category : #accessing }
RHGoalAnnotation >> icon [
	^ 'location32.png'
]

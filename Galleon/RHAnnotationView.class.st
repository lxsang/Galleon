Class {
	#name : #RHAnnotationView,
	#superclass : #TRCompositeShape,
	#instVars : [
		'text',
		'readonly',
		'parent',
		'location',
		'orientation',
		'shown',
		'popup',
		'status'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'instance creation' }
RHAnnotationView class >> fromJSONObject: o [
	^self new fromJSONObject: o; yourself
]

{ #category : #'as yet unclassified' }
RHAnnotationView class >> iconsPath [
	|fp|
	fp := 'icons' asFileReference.
	[ fp createDirectory  ] unless: fp exists.
	^fp
]

{ #category : #'as yet unclassified' }
RHAnnotationView class >> iconsUri [
	^'https://github.com/lxsang/ROS-packages/raw/master/inria_demo/icons/'
]

{ #category : #'instance creation' }
RHAnnotationView class >> text: aString [
	^ (self new) text:aString; yourself
]

{ #category : #accessing }
RHAnnotationView >> announcer [
	^self parent announcer
]

{ #category : #convertion }
RHAnnotationView >> asJSONObject [
	^ {('text' -> self text).
	('class' -> self className).
	('position'
		->
			{('x' -> self location x).
			('y' -> self location y)} asDictionary).
	'orientation' -> self orientation} asDictionary
]

{ #category : #accessing }
RHAnnotationView >> canvas [
	^ self parent canvas 
]

{ #category : #drawing }
RHAnnotationView >> closePopUp [
	popup resetShapes.
	self canvas signalUpdate
]

{ #category : #drawing }
RHAnnotationView >> createButton: label action: aBlock [
	| lbl box shape size |
	lbl := TRLabelShape new text: label.
	lbl color: Color black.
	size := lbl extent + 5.
	box := TRBoxShape new.
	box extent: size.
	box color: Color lightGray.
	box strokePaint: Color darkGray.
	shape := TRCompositeShape new.
	shape extent: size.
	shape addShape: box.
	shape addShape: lbl.
	shape when: TRMouseClick do: aBlock.
	^ shape
]

{ #category : #drawing }
RHAnnotationView >> createPopUp [
	^ self subclassResponsibility
]

{ #category : #drawing }
RHAnnotationView >> draw [
	self lock critical: [  self drawAnchor]
	
]

{ #category : #drawing }
RHAnnotationView >> drawAnchor [
	| s icon |
	s := TRBitmapShape new.
	icon := self getIcon.
	s form: icon.
	self addShape: s.
	self canvas addShape: self.
	self translateTo: self location + (0 @ -16).
	s when: TRMouseClick do: [ self togglePopUp ]
]

{ #category : #'instance creation' }
RHAnnotationView >> fromJSONObject: obj [
	| p |
	self text: (obj at: 'text').
	p := obj at: 'position'.
	self location: (p at: 'x') @ (p at: 'y').
	self orientation: (obj at:'orientation')
]

{ #category : #drawing }
RHAnnotationView >> getGrip [
	|shape tri|
	shape := TRCompositeShape new.
	shape extent: 10@10.
	tri := TRPolygonShape new
						vertices:
							{(-5 @ -5).
							(5 @ -5).
							(0 @ 5)}.
	shape addShape: tri.
	^shape
]

{ #category : #accessing }
RHAnnotationView >> getIcon [
	|pf|
	[
	pf := self class iconsPath / (self icon).
	[ 
		ZnClient new
				url: self class iconsUri, (self icon);
				downloadTo: pf
	] unless: pf exists.
	^pf binaryReadStreamDo: [ :stream | PNGReadWriter formFromStream: stream ]
	] on: Error do: [ ^ Smalltalk ui icons info]
]

{ #category : #accessing }
RHAnnotationView >> getWorldPosition [
	^self location * self parent worldModel resolution
]

{ #category : #accessing }
RHAnnotationView >> icon [
	^'pin32.png'
]

{ #category : #initialization }
RHAnnotationView >> initialize [
	super initialize.
	shown := false.
	status := OrderedCollection new.
	readonly := false.
]

{ #category : #accessing }
RHAnnotationView >> location [
	^ location
]

{ #category : #accessing }
RHAnnotationView >> location: anObject [
	location := anObject
]

{ #category : #accessing }
RHAnnotationView >> lock [
	^ self parent lock
]

{ #category : #drawing }
RHAnnotationView >> openPopUp [
	| box shape size grip |
	shape := self createPopUp.
	box := TRBoxShape new.
	size := shape extent + (0 @ 10).
	box extent: shape extent + (5 @ 5).
	box color: Color white.
	popup := TRCompositeShape new.
	popup extent: size.
	popup addShape: box translateBy: 0 @ -10.
	popup addShape: shape translateBy: 0 @ -10.
	grip := self getGrip.
	popup addShape: grip translateBy: 0 @ (size y / 2 - 7).
	popup translateTo: self location - (0 @ (size y / 2 + 32)).
	self canvas addShape: popup.
	self canvas signalUpdate
]

{ #category : #accessing }
RHAnnotationView >> orientation [
	^ orientation
]

{ #category : #accessing }
RHAnnotationView >> orientation: anObject [
	orientation := anObject
]

{ #category : #accessing }
RHAnnotationView >> parent [
	^ parent
]

{ #category : #accessing }
RHAnnotationView >> parent: anObject [
	parent := anObject
]

{ #category : #accessing }
RHAnnotationView >> readonly [
	readonly := true
]

{ #category : #accessing }
RHAnnotationView >> shown [
	^ shown
]

{ #category : #accessing }
RHAnnotationView >> shown: anObject [
	shown := anObject
]

{ #category : #accessing }
RHAnnotationView >> status [
	^ status
]

{ #category : #drawing }
RHAnnotationView >> status: aString [
	| bg lb |
	self lock
		critical: [ self status do: [ :el | self canvas removeShape: el ].
			status := OrderedCollection new.
			aString
				ifNotNil: [ lb := TRStyledLabelShape new text: aString.
					lb color: Color white.
					lb emphasis: TextEmphasis bold.
					lb fontSize: 10.
					bg := TRBoxShape new.
					bg color: Color red.
					bg extent: lb extent - (-3 @ 3).
					bg strokeWidth: 1.0.
					self canvas
						addShape: bg;
						addShape: lb.
					status
						add: lb;
						add: bg.
					lb translateTo: self location + (16 @ -32).
					bg translateTo: self location + (14 @ -29) ].
			self canvas signalUpdate ]
]

{ #category : #accessing }
RHAnnotationView >> text [
	^ text
]

{ #category : #accessing }
RHAnnotationView >> text: anObject [
	text := anObject
]

{ #category : #drawing }
RHAnnotationView >> togglePopUp [
	self lock
		critical: [ self shown
				ifTrue: [ self closePopUp ]
				ifFalse: [ self openPopUp ] ].
	self shown: self shown not
]

{ #category : #drawing }
RHAnnotationView >> undraw [
	self lock critical: [
			popup ifNotNil: [  popup resetShapes ].
			self status do:[:e| self canvas removeShape: e].
			self remove.
			self resetShapes.
			self canvas signalUpdate]
	
]

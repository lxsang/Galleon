Class {
	#name : #RHRobotModelView,
	#superclass : #RHModule,
	#instVars : [
		'model',
		'running',
		'radius',
		'lines',
		'sub'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHRobotModelView class >> readMe [
	^ 'I calculate and display the robot position in the world by accessing to the TF tree.
The transformation used: world''s frame --> my frame'
]

{ #category : #sync }
RHRobotModelView >> desynchronize [
	self undraw.
	self running: false.
	self proxy controller node unsubscribe: sub
	
]

{ #category : #drawing }
RHRobotModelView >> draw: msg [
	| position |
	position := (msg position x / self parent resolution) rounded @ (0 - (msg position y / self parent resolution)) rounded.
	self lock
		critical: [ model size: (self radius / self parent resolution) rounded.
			"[ self canvas removeShape: orientation ] if: self orientation isNotNil."
			self drawArrowFrom: position orientation: msg orientation.
			"self canvas addShape: orientation."
			"self canvas push: orientation behind: self."
			model translateTo: position.
			self canvas signalUpdate ]
]

{ #category : #drawing }
RHRobotModelView >> drawArrowFrom: position orientation: orientation [
	| offset ab newPos a b |
	offset := self getOrientationOffset: orientation.
	newPos := position + offset.
	ab := self arrowHeadOffsetsFor: offset.
	a := ab at: 1.
	b := ab at: 2.
	(self lines at: 1) from: position to: newPos.
	(self lines at: 2) from: newPos to: (newPos x - (5 * a x)) @ (newPos y - (5 * a y)).
	(self lines at: 3) from: newPos to: (newPos x - (5 * b x)) @ (newPos y - (5 * b y))
]

{ #category : #initialization }
RHRobotModelView >> initialize [
	super initialize.
	topic := '/robot_pose'.
	radius := 0.25.
	running := false.
	self initializeModel.
]

{ #category : #initialization }
RHRobotModelView >> initializeModel [
	model := TREllipseShape new
		color: Color red;
		size: 0.25 / 0.05.
	lines := {TRLineShape new color: Color blue. TRLineShape new color: Color blue. TRLineShape new color: Color blue.}.
	self lines do:[:l| self addShape: l].
	self addShape: model
]

{ #category : #accessing }
RHRobotModelView >> lines [
	^ lines
]

{ #category : #accessing }
RHRobotModelView >> model [
	^ model
]

{ #category : #accessing }
RHRobotModelView >> name [
	^ 'Robot model view'
]

{ #category : #sync }
RHRobotModelView >> propertyChange: prop [
	prop name = #topic ifFalse:[^self].
	self desynchronize.
	self initializeModel.
	self synchronize.
]

{ #category : #accessing }
RHRobotModelView >> radius [
	<galleonProperty: #Number>
	^ radius
]

{ #category : #accessing }
RHRobotModelView >> radius: anObject [
	radius := anObject
]

{ #category : #accessing }
RHRobotModelView >> running [
	^ running
]

{ #category : #accessing }
RHRobotModelView >> running: anObject [
	running := anObject
]

{ #category : #sync }
RHRobotModelView >> synchronize [
	self topic ifNil: [ ^ self ].
	self running: true.
	self lock critical: [ self canvas addShape: self ].
	sub := (self proxy controller node buildConnectionFor: self topic)
		typedAs: 'geometry_msgs/Pose';
		for: [ :msg | self draw: msg ];
		connect
]

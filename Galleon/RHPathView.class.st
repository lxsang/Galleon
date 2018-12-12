Class {
	#name : #RHPathView,
	#superclass : #RHModule,
	#instVars : [
		'lines',
		'goal',
		'sub',
		'path_color'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHPathView class >> readMe [
	^'I am the viewer of the ROS poses array in the world'
]

{ #category : #'as yet unclassified' }
RHPathView >> allShapes [
	goal ifNil: [ ^ lines asArray  ].
	^ lines asArray , {goal}
]

{ #category : #sync }
RHPathView >> desynchronize [
	super desynchronize.
	self proxy controller node unsubscribe: sub.
]

{ #category : #'drawing-general' }
RHPathView >> draw: aMsg [
	self translateFromParentDo: [ :tl|
		self lock critical: [ self drawPath: aMsg tl: tl ]
	].
]

{ #category : #'drawing-general' }
RHPathView >> drawPath: aMsg tl: tl [
	| lastPose newPose |
	lastPose := nil.
	lines do: [ :s | self canvas removeShape: s ].
	goal
		ifNil: [ goal := TRLabelShape new text: '+'.
			goal color: Color green.
			self canvas addShape: goal ].
	aMsg poses isEmpty ifFalse:[
		goal translateTo: (self getVertex: aMsg poses last pose tl: tl)].
	lines := OrderedCollection new.
	"i := 0."
	aMsg poses
		do: [ :pose | 
			"i % 10 = 0
				ifTrue: [ "
					lastPose
						ifNil: [ lastPose := self getVertex: pose pose tl:tl ]
						ifNotNil: [ | line |
							newPose := self getVertex: pose pose tl: tl.
							line := TRLineShape new from: lastPose to: newPose.
							line color: self path_color .
							lines add: line.
							self canvas addShape: line.
							self canvas push: line behind: goal.
							lastPose := newPose ] "].
			i := i + 1" ].
	self canvas signalUpdate
]

{ #category : #'drawing-general' }
RHPathView >> getVertex: pose tl: tl [
	^ tl + (((pose position x round:3) / self parent resolution) rounded @ ((0 - (pose position y round:3)) / self parent resolution) rounded)
]

{ #category : #initialization }
RHPathView >> initialize [
	super initialize.
	topic := '/move_base/GlobalPlanner/plan'.
	localframe := 'map'.
	lines := OrderedCollection new.
	path_color := Color red.
]

{ #category : #accessing }
RHPathView >> name [
	^ 'Pose Path view'
]

{ #category : #accessing }
RHPathView >> path_color [
	<galleonProperty: #Color> 
	^ path_color
]

{ #category : #accessing }
RHPathView >> path_color: anObject [
	path_color := anObject
]

{ #category : #sync }
RHPathView >> synchronize [
	self topic ifNil: [ ^ self ].
	"build connection"
	sub := (self proxy controller node buildConnectionFor: self topic)
		typedAs: 'nav_msgs/Path';
		for: [ :msg | self draw: msg ];
		connect
]

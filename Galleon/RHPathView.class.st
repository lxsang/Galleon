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

{ #category : #converting }
RHPathView >> asJSONObject [
	|d|
	d := super asJSONObject.
	d at: 'path_color' put: self path_color asArray.
	^d	
]

{ #category : #sync }
RHPathView >> desynchronize [
	super desynchronize.
	self proxy controller node unsubscribe: sub.
]

{ #category : #'drawing-general' }
RHPathView >> draw: aMsg [
	self lock critical: [ self drawPath: aMsg ]
]

{ #category : #'drawing-general' }
RHPathView >> drawPath: aMsg [
	| lastPose newPose |
	lastPose := nil.
	lines do: [ :s | self canvas removeShape: s ].
	goal
		ifNil: [ goal := TRLabelShape new text: '+'.
			goal color: Color green.
			self canvas addShape: goal ].
	aMsg poses isEmpty ifFalse:[
		goal translateTo: (self getVertex: aMsg poses last pose)].
	lines := OrderedCollection new.
	"i := 0."
	aMsg poses
		do: [ :pose | 
			"i % 10 = 0
				ifTrue: [ "
					lastPose
						ifNil: [ lastPose := self getVertex: pose pose ]
						ifNotNil: [ | line |
							newPose := self getVertex: pose pose.
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
RHPathView >> getVertex: pose [
	^ self translateFromParent + (((pose position x round:3) / self parent resolution) rounded @ ((0 - (pose position y round:3)) / self parent resolution) rounded)
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
	^ path_color
]

{ #category : #accessing }
RHPathView >> path_color: anObject [
	path_color := anObject
]

{ #category : #initialization }
RHPathView >> propList [
	^ super propList, { (RHProperty
		from:
			{(#name -> #localframe).
			(#type -> String)}
		holder: self).
	(RHProperty
		from:
			{(#name -> #topic).
			(#type -> String)}
		holder: self).
	(RHProperty
		from:
			{(#name -> #path_color).
			(#type -> Color)}
		holder: self) }
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

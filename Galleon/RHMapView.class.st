Class {
	#name : #RHMapView,
	#superclass : #RHModule,
	#instVars : [
		'synchronizing',
		'shape',
		'sub'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHMapView class >> readMe [
	^ 'This module subscribe to a map topic and display the returned grid map on the world'
]

{ #category : #sync }
RHMapView >> desynchronize [
	synchronizing := false.
	self undraw.
	self proxy controller node unsubscribe: sub.
	self topic ifNil: [ ^self ].
	"other stuff here"
]

{ #category : #'drawing-general' }
RHMapView >> draw: map [
	self mapToBitmap: map.
	""
]

{ #category : #initialization }
RHMapView >> initialize [
	super initialize.
	localframe := 'map'.
	topic := '/map'.
	synchronizing := false.
	shape := RHBitmapShape new.
	shape extent: 0 @ 0.
	self addShape: shape
]

{ #category : #'drawing-general' }
RHMapView >> lookupColor: value [
	value = -1 ifTrue:[^Color r: 0.8 g: 0.8  b:0.8 ].
	value = 100 ifTrue:[^Color black ].
	value = 0 ifTrue:[^Color white].
	^Color red
]

{ #category : #'drawing-general' }
RHMapView >> mapToBitmap: map [
	| x y c cache |
	cache := Form extent: map info width @ map info height depth: 8.
	1 to: map info width do: [ :i | 
		1 to: map info height do: [ :j | 
			c := self lookupColor: (map data at: (map info height - j) * map info width + i).
			cache colorAt: (i - 1) @ (j - 1) put: c ] ].
	x := ((map info origin position x round: 3) / (map info resolution round: 2)) rounded.
	y := ((map info origin position y abs round: 3) / (map info resolution round: 2) - map info height) rounded.
	self lock
		critical: [ shape extent: cache extent.
			shape form: cache.
			shape translateTo: 0 @ 0.
			shape translateBy: self translateFromParent + (x @ y).
			self canvas signalUpdate ]	"self extent: cache extent."	"Smalltalk garbageCollect."
]

{ #category : #accessing }
RHMapView >> name [
	^ 'Grid Map view'
]

{ #category : #'as yet unclassified' }
RHMapView >> propList [
	^super propList, {  
	(RHProperty
		from:
			{(#name -> #localframe).
			(#type -> String)}
		holder: self).
	(RHProperty
		from:
			{(#name -> #topic).
			(#type -> String)}
		holder: self)
		}
]

{ #category : #sync }
RHMapView >> synchronize [
	synchronizing := false.
	self topic ifNil: [ ^ self ].
	self lock critical:[self canvas addShape: self].
	"build connection"
	sub := (self proxy controller node buildConnectionFor: topic)
		typedAs: 'nav_msgs/OccupancyGrid';
		for: [ :msg | self draw: msg ];
		connect.
	synchronizing := true
]

{ #category : #accessing }
RHMapView >> synchronizing [
	^ synchronizing
]

{ #category : #accessing }
RHMapView >> synchronizing: anObject [
	synchronizing := anObject
]

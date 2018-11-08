Class {
	#name : #RHBatteryMonitor,
	#superclass : #RHModule,
	#instVars : [
		'subscription',
		'dockingpub',
		'docking_topic',
		'defaultDock',
		'isDocked',
		'batteryStatus',
		'max_voltage',
		'automatic_dock_threshold',
		'docking',
		'subscriber'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHBatteryMonitor class >> readMe [
	^ 'I monitor the battery status and handle the docking command. I can command the robot to go to the docking station for charging (if it is available) when the battery status is low'
]

{ #category : #adding }
RHBatteryMonitor >> addDock: anAnnotation [
	defaultDock := anAnnotation 
]

{ #category : #accessing }
RHBatteryMonitor >> automatic_dock_threshold [
	<galleonProperty: #Number>
	^ automatic_dock_threshold
]

{ #category : #accessing }
RHBatteryMonitor >> automatic_dock_threshold: anObject [
	automatic_dock_threshold := anObject
]

{ #category : #accessing }
RHBatteryMonitor >> batteryStatus [
	<galleonProperty: #Number>
	^ batteryStatus
]

{ #category : #accessing }
RHBatteryMonitor >> batteryStatus: anObject [
	batteryStatus := anObject
]

{ #category : #accessing }
RHBatteryMonitor >> defaultDock [
	^ defaultDock
]

{ #category : #sync }
RHBatteryMonitor >> desynchronize [
	"super desynchronize."
	self proxy controller node unsubscribe: subscriber.
	self announcer unsubscribe: self	"RHGoalSetEvent thoroughlyfor: self"
]

{ #category : #sync }
RHBatteryMonitor >> dock: e [
	[ ^ self ] if: self docking.
	[  ^self ] if: self isDocked.
	self docking: true.
	self subscription: (self announcer subscribe: RHGoalReached do: [ :data | self triggerDockingProc ]).
	self announcer announce: (RHGoalSetEvent for: e type: #onestop)
]

{ #category : #accessing }
RHBatteryMonitor >> docking [
	^ docking
]

{ #category : #accessing }
RHBatteryMonitor >> docking: anObject [
	docking := anObject
]

{ #category : #accessing }
RHBatteryMonitor >> docking_topic [
	<galleonProperty: #String>
	^ docking_topic
]

{ #category : #accessing }
RHBatteryMonitor >> docking_topic: anObject [
	docking_topic := anObject
]

{ #category : #accessing }
RHBatteryMonitor >> dockingpub [
	^ dockingpub
]

{ #category : #initialization }
RHBatteryMonitor >> initialize [
	super initialize.
	topic := '/mobile_base/sensors/core'.
	docking_topic := '/robotcmd/dock'.
	max_voltage := 160.
	isDocked := false.
	docking := false.
	defaultDock := nil.
	automatic_dock_threshold := 20	"%"
]

{ #category : #accessing }
RHBatteryMonitor >> isDocked [
	^ isDocked
]

{ #category : #accessing }
RHBatteryMonitor >> isDocked: anObject [
	isDocked := anObject
]

{ #category : #accessing }
RHBatteryMonitor >> max_voltage [
	<galleonProperty: #Number>
	^ max_voltage
]

{ #category : #accessing }
RHBatteryMonitor >> max_voltage: anObject [
	max_voltage := anObject
]

{ #category : #accessing }
RHBatteryMonitor >> monitor: msg [
	self isDocked: (msg charger = 2 or: [ msg charger = 6 ]).
	self batteryStatus: (msg battery * 100 / self max_voltage) asInteger.
	[ self docking: false ] if: self isDocked.
	[ ^ self ] if: self docking.
	[ ^ self ] if: self isDocked.
	[ ^ self ] if: self defaultDock isNil.
	[ ^ self ] if: [ self batteryStatus > self automatic_dock_threshold ].
	self dock: self defaultDock
	"trigger automatic dock"
]

{ #category : #accessing }
RHBatteryMonitor >> name [
	^ 'A Battery monitor'
]

{ #category : #accessing }
RHBatteryMonitor >> subscription [
	^ subscription
]

{ #category : #accessing }
RHBatteryMonitor >> subscription: anObject [
	subscription := anObject
]

{ #category : #sync }
RHBatteryMonitor >> synchronize [
	dockingpub ifNil: [ dockingpub := self proxy controller node topicPublisher: self docking_topic typedAs: 'std_msgs/Bool' ].
	self announcer when: RHDockingEvent do: [ :e | self dock: e data ].
	self announcer when: RHAnnotationEvent do: [ :e | [ self addDock: e data ] if: e data class = RHDockingAnnotation ].
	subscriber := (self proxy controller node buildConnectionFor: topic)
		typedAs: 'kobuki_msgs/SensorState';
		for: [ :msg | self monitor: msg ];
		connect
]

{ #category : #sync }
RHBatteryMonitor >> triggerDockingProc [
	[ ^ self ] unless: self subscription isNotNil.
	self dockingpub send: [ :msg | msg data: true ].
	self announcer removeSubscription: self subscription.
	self subscription: nil.
]

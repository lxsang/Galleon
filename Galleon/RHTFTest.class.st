Class {
	#name : #RHTFTest,
	#superclass : #RHModule,
	#instVars : [
		'running'
	],
	#category : #'Galleon-GUI'
}

{ #category : #sync }
RHTFTest >> desynchronize [ 
	running := false.
	"self undraw "
]

{ #category : #initialization }
RHTFTest >> initialize [
	super initialize.
	localframe := 'laser'.
	running := false.
]

{ #category : #sync }
RHTFTest >> synchronize [
	running := true.
	[ 
		[ running  ] whileTrue: [ self updateRobotPose ]
 	 ] forkAt: Processor userBackgroundPriority.
]

{ #category : #sync }
RHTFTest >> updateRobotPose [
	self tfFrom: 'map' to: 'laser'  do:  [ :tf| tf ifNotNil: [{#map2laser.tf} inspect. self desynchronize ] ].
]

Class {
	#name : #RHTFTest,
	#superclass : #RHModule,
	#category : #'Galleon-GUI'
}

{ #category : #initialization }
RHTFTest >> initialize [
	super initialize.
	localframe := 'laser'
]

{ #category : #sync }
RHTFTest >> synchronize [
	self tfFrom: 'map' to: 'laser'  do:  [ :tf| {#map2laser.tf} inspect ].
	self tfFrom: 'laser' to: 'map'  do:  [ :tf| {#laser2map.tf} inspect ]
]

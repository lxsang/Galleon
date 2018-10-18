Class {
	#name : #RobotheadquaterPackage,
	#superclass : #PhaROSPackage,
	#category : #'Galleon-ROS'
}

{ #category : #'as yet unclassified' }
RobotheadquaterPackage >> draw: msg [
]

{ #category : #scripts }
RobotheadquaterPackage >> scriptTest [
	(self node buildConnectionFor: '/map')
		typedAs: 'nav_msgs/OccupancyGrid';
		for: [ :data |  self draw:data];
		connect
]

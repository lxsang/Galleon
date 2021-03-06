Class {
	#name : #BaselineOfGalleon,
	#superclass : #BaselineOf,
	#category : #BaselineOfGalleon
}

{ #category : #baselines }
BaselineOfGalleon >> baseline: spec [
	<baseline>
	
	spec for: #common do: [ 
		"spec preLoadDoIt: #preload."
		spec project: 'PhaROS' with: [ 
			 spec
				className: #ConfigurationOfPhaROS;
				versionString: #'bleedingEdge';
				repository: 'http://smalltalkhub.com/mc/CAR/PhaROS/main'
		].
		spec baseline: 'Roassal2'
    	with: [  spec repository: 'github://ObjectProfile/Roassal2/src'].
		spec baseline: 'SystemProcess'
    	with: [  spec repository: 'github://lxsang/SystemProcess'].
		spec
			package: 'Galleon';
			group: 'default' with: #('Galleon' 'PhaROS' 'Roassal2' 'SystemProcess')
		]
]

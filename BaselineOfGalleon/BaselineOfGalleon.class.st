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
				versionString: #'stable';
				repository: 'http://smalltalkhub.com/mc/CAR/PhaROS/main'
		].
		 spec baseline: 'Roassal2'
    	with: [  spec repository: 'github://ObjectProfile/Roassal2/src'].
		spec
			package: 'Galleon';
			group: 'default' with: #('Galleon' 'PhaROS' 'Roassal2')
		]
]

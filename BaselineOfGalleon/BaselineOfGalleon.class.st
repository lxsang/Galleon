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
		spec
			package: 'Galleon-External-Trachel';
			package: 'Galleon' with:[ spec requires: #('Galleon-External-Trachel') ];
			group: 'default' with: #('Galleon' 'PhaROS' )
		]
]

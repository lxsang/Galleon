Class {
	#name : #RHMapExporter,
	#superclass : #RTPNGExporter,
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHMapExporter >> viewExtent [
	^ self encompassingRectangle extent asIntegerPoint * self cameraScale 
]

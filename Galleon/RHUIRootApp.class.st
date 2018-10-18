Class {
	#name : #RHUIRootApp,
	#superclass : #DynamicComposableModel,
	#instVars : [
		'view'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHUIRootApp class >> menuCommandOn: t1 [
	<worldMenu>
	(t1 item: #RobotHQ)
		order: 0.1;
		label: 'Galleon Commander';
		icon: Smalltalk ui icons configIcon;
		action: [  ].	"RHFileChooser open:[:t2| t2 inspect ]"
	^ self
]

{ #category : #'as yet unclassified' }
RHUIRootApp class >> open [
	^ self new
		openDialog;
		yourself
]

{ #category : #'as yet unclassified' }
RHUIRootApp class >> open: t1 [
	^ self new
		openDialog: t1;
		yourself
]

{ #category : #'as yet unclassified' }
RHUIRootApp class >> open: t1 title: t2 [
	^ self new
		openDialog: t1 title: t2;
		yourself
]

{ #category : #'as yet unclassified' }
RHUIRootApp class >> openWithTitle: t1 [
	self new openWithTitle: t1.
	^ self
]

{ #category : #services }
RHUIRootApp >> alert: t1 [
	UIManager default alert: t1 title: 'Message'.
	^ self
]

{ #category : #api }
RHUIRootApp >> calibrate:v [
	
]

{ #category : #nodes }
RHUIRootApp >> cleanup [

]

{ #category : #initialization }
RHUIRootApp >> initialize [
	super initialize.
	self whenWindowChanged: [ :w |
		w whenClosedDo: [ self cleanup ] ].
]

{ #category : #accessing }
RHUIRootApp >> model: t1 [
	^ self widgets at: t1
]

{ #category : #dialog }
RHUIRootApp >> openDialog [
	self openDialog: nil.
	^ self
]

{ #category : #dialog }
RHUIRootApp >> openDialog: t1 [
	self openDialog: t1 title: self name.
	^ self
]

{ #category : #actions }
RHUIRootApp >> openDialog: t1 title: t2 [
	^ self subclassResponsibility 
]

{ #category : #dialog }
RHUIRootApp >> openWithTitle: t1 [
	view := self openWithSpec.
	view title: t1.
	view window value announcer when: WindowResizing do: [ :v | self calibrate: v ].
	self calibrate: nil.
	^ self
]

{ #category : #accessing }
RHUIRootApp >> view [
	^ view
]

{ #category : #accessing }
RHUIRootApp >> view: anObject [
	view := anObject
]

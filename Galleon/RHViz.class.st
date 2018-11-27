Class {
	#name : #RHViz,
	#superclass : #RHUIRootApp,
	#instVars : [
		'mousestat',
		'propPanel',
		'viewer',
		'tfListener',
		'proxy',
		'lock',
		'scale',
		'goalpub',
		'annotations'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHViz class >> defaultSpec [
	<spec: #default>
	^ SpecLayout composed
		newColumn: [ :t1 | 
			t1
				newRow: [ :t2 | 
					t2
						newColumn: [ :t3 | 
							t3
								newRow: [ :t4 | t4 add: #nodeMenu ] height: 30;
								newRow: [ :t4 | t4 add: #nodeList ];
								newRow: [ :t4 | t4 add: #propLabel ] height: 20;
								newRow: [ :t4 | t4 add: #propList ]	"height: 250" ]
							width: 210;
						addSplitter;
						newColumn: [ :t3 | 
							t3
								newRow: [ :t4 | t4 add: #toolboxMenu ] height: 30;
								newRow: [ :t4 | t4 add: #middleContent ] ];
						addSplitter ]
			"newRow: [ :t2 | 
					t2 add: #menu width: 400.
					t2 add: #emptyLabel.
					t2 add: #posLabel width: 200 ]
					height: self toolbarHeight;" ];
		yourself
]

{ #category : #'as yet unclassified' }
RHViz class >> menuCommandOn: t1 [
	<worldMenu>
	(t1 item: #RHViz)
		order: 0.1;
		label: 'Visualization';
		parent: #RobotHQ;
		icon: Smalltalk ui icons smallRedoIcon;
		action: [ self openWithTitle: 'Visualization' ].
	^ self
]

{ #category : #actions }
RHViz >> addNode [
	| listui selected obj |
	selected := self nodeList roots at: 1.
	listui := RHListChooser new.
	listui roots: RHModule allSubclasses.
	listui childrenBlock: [ :c | c subclasses ].
	listui displayBlock: [ :c | c asString ].
	listui iconBlock: [ Smalltalk ui icons classIcon ].
	listui
		openDialog: [ :c | 
			obj := c childOf: selected.
			"selected addChild: obj."
			self nodeList updateTree.
			self nodeList resetSelection.
			self nodeList expandAll.
			obj synchronize ]
		title: 'Select a module'.
	^ self
]

{ #category : #accessing }
RHViz >> annotations [
	^ annotations
]

{ #category : #drawing }
RHViz >> arrowHeadOffsetsFor: offset [
	| norm dx dy ud angle ax ay bx by |
	dx := offset x.
	dy := offset y.
	norm := (dx * dx + (dy * dy)) sqrt.
	ud := offset / norm.
	angle := Float pi / 6.
	ax := ud x * angle cos - (ud y * angle sin).
	ay := ud x * angle sin + (ud y * angle cos).
	bx := ud x * angle cos + (ud y * angle sin).
	by := ud y * angle cos - (ud x * angle sin).
	^ {(ax @ ay).
	(bx @ by).
	ud}
]

{ #category : #api }
RHViz >> calibrate: v [
	lock critical: [  
	v 
		ifNil:
			[self viewer extent: self initialCanvasExtent] 
		ifNotNil:
			[ self viewer extent: v newSize ].
		self canvas signalUpdate
	]
]

{ #category : #accessing }
RHViz >> canvas [
	^ viewer trachelCanvas
]

{ #category : #colors }
RHViz >> canvasColor [
	^Color r:0.9  g:0.9  b:0.9 
]

{ #category : #api }
RHViz >> cleanup [
	self worldModel desynchronizeAll.
	self terminateAllProcesses. 
	OSProcess accessor restartChildWatcherProcess

	
]

{ #category : #colors }
RHViz >> defaultLineColor [
	^ Color
		r: 0.43
		g: 0.43
		b: 0.43
		alpha: 1.0
]

{ #category : #display }
RHViz >> displayCursor [
	| action |
	action := self mousestat at: #name.
	action
		caseOf:
			{(#goal -> [ World currentHand showTemporaryCursor: Cursor crossHair ]).
			(#rectangle -> [ World currentHand showTemporaryCursor: Cursor crossHair ]).
			(#polygon -> [ World currentHand showTemporaryCursor: Cursor crossHair ]).
			(#anotate -> [ World currentHand showTemporaryCursor: Cursor crossHair ])}
		otherwise: [ World currentHand showTemporaryCursor: Cursor normal ]
]

{ #category : #actions }
RHViz >> doAction: name [
	self mousestat at: #name put: name.
	self displayCursor
]

{ #category : #actions }
RHViz >> doExportAnnotation [
	| file |
	RHFileChooser
		findFile: [ :f :name | 
			file := f / name.
			[ file delete ] if: file exists.
			self exportAnnotation: f / name ]
]

{ #category : #actions }
RHViz >> doExportConfiguration [
	| file |
	RHFileChooser findFile: [ :f :name | 
		file := f / name.
		[ file delete ] if: file exists.
		self exportConfiguration: f / name ]
]

{ #category : #actions }
RHViz >> doExportMap [
	RHFileChooser
		findDir: [ :t1 :t2 | 
			self exportMap: t1 ]
]

{ #category : #actions }
RHViz >> doImportAnnotation [
	RHFileChooser findFile: [ :f :name | self importAnnotation: f / name ]
]

{ #category : #actions }
RHViz >> doImportConfiguration [
	RHFileChooser findFile: [ :f :name | self importConfiguration: f / name ]
]

{ #category : #drawing }
RHViz >> drawArowFrom: shapes cursor: v [
	| position offset newPos ab a b unit theta |
	position := (shapes at: 1) position.
	offset := v positionFromCamera - position.
	ab := self arrowHeadOffsetsFor: offset.
	unit := ab at: 3.
	a := ab at: 1.
	b := ab at: 2.
	newPos := position + (unit * 15).
	(shapes at: 2) from: position to: newPos.
	(shapes at: 3) from: newPos to: (newPos x - (5 * a x)) @ (newPos y - (5 * a y)).
	(shapes at: 4) from: newPos to: (newPos x - (5 * b x)) @ (newPos y - (5 * b y)).
	theta := unit x arcCos.
	[ ^ 2 * Float pi - theta ] if: unit y > 0.
	^ theta
	"theta := theta % (2.0 * Float pi).
	theta := (theta + (2.0 * Float pi)) % (2.0 * Float pi).
	[ ^ theta ] if: theta <= Float pi.
	^ theta - (2 * Float pi)"
]

{ #category : #drawing }
RHViz >> drawPolygon: v drag: aBool [
	| obj shape |
	(self mousestat at: #name) = #polygon
		ifFalse: [ ^ self ].
	obj := self mousestat at: #vertices ifAbsent: [ nil ].
	obj
		ifNil: [ aBool
				ifFalse: [ obj := {v position} asOrderedCollection.
					self mousestat at: #vertices put: obj ] ]
		ifNotNil: [ aBool
				ifTrue: [ obj size > 1
						ifTrue: [ obj removeLast ] ].
			obj add: v position.
			self canvas removeShape: (self mousestat at: #polygon) ].
	obj ifNil: [ ^ self ].
	lock
		critical: [ shape := TRPolygonShape new
				color: self drawingColor;
				strokePaint: self drawingColor.
			shape vertices: obj.
			self canvas addShape: shape.
			self mousestat at: #polygon put: shape.
			self canvas signalUpdate ]
]

{ #category : #drawing }
RHViz >> drawRectangle: s [
	| obj |
	obj := self mousestat at: #rectangle ifAbsent: [ nil ].
	obj
		ifNotNil: [ ""
			lock
				critical: [ | step |
					step := s step / self canvas camera scale.
					obj extent: obj extent + step.
					obj translateBy: step / 2.
					self canvas signalUpdate ] ]
]

{ #category : #colors }
RHViz >> drawingColor [
	^
			(Color
				r: 0.7
				g: 0.8
				b: 0.98
				alpha: 0.5)
]

{ #category : #export }
RHViz >> exportAnnotation: file [
	| stream collection |
	stream := file writeStream.
	collection := OrderedCollection new.
	self annotations do: [ :a | collection add: a asJSONObject ].
	[stream write: (STONJSON toStringPretty: collection asArray).
	stream close
	] unless: stream isNil
]

{ #category : #export }
RHViz >> exportConfiguration: file [
	| stream  |
	stream := file writeStream.
	[ stream write: (STONJSON toStringPretty: self worldModel asJSONObject ).
	stream close ] unless: stream isNil
]

{ #category : #export }
RHViz >> exportMap: path [
	| exporter v rect origin stream |
	v := RTView new.
	v setCanvas: self canvas.
	"self canvas shapes inspect."
	exporter := RHMapExporter new.
	rect := self canvas encompassingRectangle.
	origin := rect origin x @ (0 - rect corner y).
	origin := origin * self worldModel resolution.
	exporter builder: v.
	exporter fileName: (path / 'map.png') pathString.
	exporter exportToFile.
	stream := (path / 'map.yaml') writeStream.
	stream
		ifNotNil: [ stream
				write: 'image: map.png';
				cr.
			stream
				write: 'resolution: 0.050000';
				cr.
			stream
				write: 'origin: [' , origin x asString , ', ' , origin y asString , ', 0.000000]';
				cr.
			stream
				write: 'negate: 0';
				cr;
				write: 'occupied_thresh: 0.4';
				cr;
				write: 'free_thresh: 0.1'.
			stream close ]
]

{ #category : #drawing }
RHViz >> finishPolygon [
	| shape color stroke |
	self canvas removeShape: (self mousestat at: #polygon).
	color := self mousestat at: #color ifAbsent: [ self obstacleColor ].
	stroke := self mousestat at: #stroke ifAbsent: [ 2.0 ].
	shape := TRPolygonShape new color: color.
	shape strokeWidth: stroke.
	shape vertices: (self mousestat at: #vertices).
	shape
		when: TRMouseDoubleRightClick
		do: [ self lock
				critical: [ self canvas removeShape: shape.
					self canvas signalUpdate ] ].
	self canvas addShape: shape.
	self canvas signalUpdate.
	self mousestat removeKey: #vertices.
	self mousestat removeKey: #polygon
]

{ #category : #drawing }
RHViz >> finishPose: v [
	| obj |
	obj := self mousestat at: #shapes ifAbsent: [ nil ].
	obj
		ifNotNil: [ self mousestat removeKey: #shapes.
			self lock
				critical: [ obj do: [ :e | self canvas removeShape: e ].
					self canvas signalUpdate ] ].
	self setPoseAt: (self mousestat at: #origin) orientation: (self mousestat at: #orientation).
	self mousestat removeKey: #origin.
	self mousestat removeKey: #orientation.
	self mousestat at: #name put: #normal
]

{ #category : #drawing }
RHViz >> finishRectangle: v [
	| obj |
	obj := self mousestat at: #rectangle ifAbsent: [ nil ].
	obj
		ifNotNil: [ obj
				when: TRMouseDoubleRightClick
				do: [ self lock
						critical: [ self canvas removeShape: obj.
							self canvas signalUpdate ] ].
			self lock
				critical: [ obj
						color: self obstacleColor;
						strokePaint: Color black;
						strokeWidth: 2.0.
					self canvas signalUpdate ] ]
]

{ #category : #import }
RHViz >> importAnnotation: file [
	| obj stream |
	stream := file readStream.
	[ obj := STONJSON fromStream: stream.
	stream close ] unless: stream isNil.
	[ ^ self ] if: obj isNil.
	obj
		do: [ :el | 
			| ins |
			ins := (el at: 'class') asClass fromJSONObject: el.
			[self registerAnnotation: ins] unless: ins isNil]
]

{ #category : #import }
RHViz >> importConfiguration: file [
	|  stream ins obj|
	stream := file readStream.
	[ obj := STONJSON fromStream: stream.
	stream close ] unless: stream isNil.
	[ ^ self ] if: obj isNil.
			ins := (obj at: 'class') asClass fromJSONObject: obj.
			ins parent: self.
			self nodeList roots: {ins} asOrderedCollection.
			self nodeList updateTree.
			self nodeList resetSelection.
			self nodeList expandAll.
			ins synchronizeAll 
]

{ #category : #initialization }
RHViz >> initCanvas [
	viewer := self middleContent viewer widget.
	self viewerReset.
	self canvas when: TRMouseMove do: [ :t2 | self onMouseMoveOnCanvas: t2 ].
	self canvas when: TRMouseClick do: [ :t2 | self onMouseClick: t2 ].
	self canvas color: self canvasColor.
	self canvas
		when: TRMouseWheelEvent
			do: [ :t2 | 
			t2 isUp
				ifTrue: [ self zoomIn ].
			t2 isDown
				ifTrue: [ self zoomOut ] ];
		when: TRMouseDragging do: [ :v | self onMouseDrag: v ];
		when: TRMouseLeave do: [ :v | World currentHand showTemporaryCursor: Cursor normal ];
		when: TRMouseDragStart do: [ :v | self onMouseDragStart: v ];
		when: TRMouseDragEnd do: [ :v | self onMouseDragEnd: v ];
		when: TRMouseDoubleClick do:[:v| self onMouseDoubleClick:v].
	^ self
]

{ #category : #initialization }
RHViz >> initialCanvasExtent [
	^ self middleContent spec instance widget extent
]

{ #category : #initialization }
RHViz >> initialExtent [
	^ 1024 @ 768
]

{ #category : #initialization }
RHViz >> initialize [
	lock := Semaphore forMutualExclusion.
	super initialize.
	proxy := PhaROSPackage new.
	tfListener := ROSTFListener new.
	tfListener proxy: proxy.
	mousestat := {(#name -> #normal)} asDictionary.
	scale := 1.0.
	annotations := OrderedCollection new.
	self announcer when: RHAnnotationEvent do: [ :e | [ self registerAnnotation: e data ] if: (e type = #add) ].
	self announcer when: RHAnnotationClearEvent do:[:e| self annotations do:[:el| el undraw.]. self annotations  removeAll].
	^ self
]

{ #category : #initialization }
RHViz >> initializeWidgets [
	| rootnode |
	"menu := self mainMenu.
	menu applyTo: self."
	self instantiateModels: #(#nodeList #TreeModel #propLabel #LabelModel #middleContent #RHCanvasModel).	"#emptyLabel #LabelModel"	"#posLabel #LabelModel"
	self initCanvas.
	self propLabel
		label: 'Properties:';
		emphasis: #bold.
	rootnode := RHWorld childOf: self.
	self nodeList
		displayBlock: [ :t1 | t1 name ];
		childrenBlock: [ :t1 | t1 children ].
	self nodeList iconBlock: [ Smalltalk ui icons objects ].
	self nodeList roots: {rootnode} asOrderedCollection.
	rootnode synchronize.
	self nodeList whenSelectedItemChanged: [ :t1 | self onNodeSelected: t1 ].
	^ self
]

{ #category : #accessing }
RHViz >> lock [
	^ lock
]

{ #category : #initialization }
RHViz >> mainMenu [
	^ MenuModel new
		addGroup: [ :t1 | 
			t1
				addItem: [ :t2 | 
					t2
						name: 'File';
						icon: Smalltalk ui icons openIcon;
						subMenu: self subMenu ] ]
]

{ #category : #accessing }
RHViz >> mousestat [
	^ mousestat
]

{ #category : #accessing }
RHViz >> mousestat: anObject [
	mousestat := anObject
]

{ #category : #display }
RHViz >> moveCamera: step [
	lock
		critical: [ self canvas camera translateBy: 0 @ 0 - (step / self canvas camera scale).
			self canvas signalUpdate ]
]

{ #category : #initialization }
RHViz >> nodeMenu [
	^ MenuModel new
		addGroup: [ :t1 | 
			t1
				addItem: [ :t2 | 
					t2
						name: 'Viz';
						icon: Smalltalk ui icons smallLoadProject;
						subMenu: self subMenu ];
				addItem: [ :t2 | 
					t2
						name: nil;
						description: 'Add node';
						icon: Smalltalk ui icons add;
						action: [ self addNode ] ];
				addItem: [ :t2 | 
					t2
						name: nil;
						description: 'Remove node';
						icon: Smalltalk ui icons changeRemove;
						action: [ self removeNode ] ];
				addItem: [ :t2 | 
					t2
						name: nil;
						description: 'Push up';
						icon: Smalltalk ui icons arrowDoubleUp;
						action: [ self push: #Up ] ];
				addItem: [ :t2 | 
					t2
						name: nil;
						description: 'Push down';
						icon: Smalltalk ui icons arrowDoubleDown;
						action: [ self push: #Down ] ];
				addItem: [ :t2 | 
					t2
						name: nil;
						description: 'Push to top';
						icon: Smalltalk ui icons top;
						action: [ self push: #Top ] ];
				addItem: [ :t2 | 
					t2
						name: nil;
						description: 'Push to bottom';
						icon: Smalltalk ui icons bottom;
						action: [ self push: #Bottom ] ] ]
]

{ #category : #colors }
RHViz >> obstacleColor [
	^ Color r: 0.8 g: 0.8 b: 0.8
]

{ #category : #'event handling' }
RHViz >> onMouseClick: t1 [
	(self mousestat at: #name)
		caseOf:
			{
			(#polygon -> [ self drawPolygon: t1 drag: false ])}
		otherwise: [  ].	"(#goal -> [ self setGoal: t1 position ])."
	^ self
]

{ #category : #'event handling' }
RHViz >> onMouseDoubleClick: t1 [
	(self mousestat at: #name) caseOf: {(#polygon -> [ self finishPolygon ])} otherwise: [  ].
	^ self
]

{ #category : #'event handling' }
RHViz >> onMouseDrag: v [
	(self mousestat at: #name)
		caseOf:
			{(#normal -> [ self moveCamera: v step ]).
			(#rectangle -> [ self drawRectangle: v ]).
			"(#polygon -> [ self drawPolygon: v drag: true ])."
			(#anotate -> [ self tracePose: v ]).
			(#goal -> [ self tracePose: v ])}
			
		otherwise: [  ]
]

{ #category : #'event handling' }
RHViz >> onMouseDragEnd: v [
	(self mousestat at: #name)
		caseOf:
			{(#rectangle -> [ self finishRectangle: v ]).
			(#goal -> [ self finishPose: v ]).
			(#anotate -> [ self finishPose: v ])}
		otherwise: [  ]
]

{ #category : #'event handling' }
RHViz >> onMouseDragStart: v [
	(self mousestat at: #name)
		caseOf:
			{(#rectangle -> [ self traceRectangle: v ]).
			(#anotate -> [ self tracePose: v ]).
			(#goal -> [ self tracePose: v ])}
		otherwise: [  ]
]

{ #category : #'event handling' }
RHViz >> onMouseMoveOnCanvas: t1 [
	"self posLabel label: 'Cursor:' , t1 position asString."

	self mousestat at: #position put: t1 position.
	self displayCursor.
	self drawPolygon: t1 drag: true.
	^ self
]

{ #category : #'event handling' }
RHViz >> onNodeSelected: item [
	propPanel ifNil: [ ^self ].
	item isNil
		ifTrue: [ ^propPanel setItems: {} ].
	propPanel setItems: item propList
]

{ #category : #actions }
RHViz >> openDialog: t1 title: t2 [
	^ self shouldNotImplement 
]

{ #category : #initialization }
RHViz >> propList [
|t1|
t1 := ScrollPane new.
t1 vResizing: #spaceFill;
	hResizing: #spaceFill.
propPanel  := RHPropListUI  new.
propPanel parent: self.
propPanel panelWidth: 190.
t1 scroller addMorph: propPanel.
"propPanel samplePropList."
^t1 asSpecAdapter 
]

{ #category : #accessing }
RHViz >> propPanel [
	^ propPanel
]

{ #category : #accessing }
RHViz >> proxy [
	^ proxy
]

{ #category : #accessing }
RHViz >> proxy: anObject [
	proxy := anObject
]

{ #category : #actions }
RHViz >> push: action [
	| el rnode contents newel |
	el := self nodeList selectedItem.
	el ifNil: [ ^ self ].
	el = self worldModel
		ifTrue: [ ^ self ].
	(MessageSend receiver: self worldModel selector: ('push' , action , ':') asSymbol argument: el content) value.
	newel := nil.
	"self nodeList resetSelection."
	self nodeList updateTree.
	rnode := (self nodeList dependents at: 1) widget nodeList at: 1.
	contents := rnode childrenItems.
	contents
		do: [ :e | 
			e content = el content
				ifTrue: [ newel := e ] ].
	newel
		ifNotNil: [ self nodeList selectedItem: newel.
			newel := (newel dependents at: 1) widget.
			(self nodeList dependents at: 1)
				selectNodePath:
					{rnode.
					newel}.
			self onNodeSelected: el content]
]

{ #category : #actions }
RHViz >> registerAnnotation: obj [
	obj parent: self.
	obj draw.
	self annotations add:obj.
]

{ #category : #api }
RHViz >> removeNode [
	| selected |
	selected := self nodeList selectedItem.
	selected ifNil: [ ^ self ].
	selected content = (self nodeList roots at: 1)
		ifTrue: [ ^ self ].
	selected content desynchronize.
	selected parentNode ifNil: [ self nodeList roots remove: selected content ] ifNotNil: [ selected parentNode content children remove: selected content ].
	self nodeList updateTree.
	self nodeList resetSelection.
]

{ #category : #accessing }
RHViz >> scale [
	^ scale
]

{ #category : #accessing }
RHViz >> scale: anObject [
	scale := anObject
]

{ #category : #actions }
RHViz >> setAnotation: arr [
	| dialog |
	self doAction: #normal.
	dialog := RHAnnotationEdit new.
	dialog roots: RHAnnotationView allSubclasses.
	dialog childrenBlock: [ :c | c subclasses ].
	dialog displayBlock: [ :c | c asString ].
	dialog iconBlock: [ Smalltalk ui icons classIcon ].
	dialog
		openDialog: [ :obj | 
			obj location: (arr at:1).
			obj orientation: (arr at:2).
			self announcer announce: (RHAnnotationEvent for: obj type: #add). ]
		title: 'Set Annotation'.
	^ self
]

{ #category : #actions }
RHViz >> setGoal: arr [
	| model|
	model := self worldModel.
	arr at: 1 put: (arr at: 1) * model resolution.
	self doAction: #normal.
	self announcer announce: (RHGoalSetEvent for: arr type: #position)
]

{ #category : #actions }
RHViz >> setPoseAt: position orientation: angle [
	(self mousestat at: #name)
		caseOf:
			{(#goal
				-> [ self
						setGoal:
							{position.
							angle} ]).
			(#anotate
				-> [ self
						setAnotation:
							{position.
							angle} ])}
		otherwise: [  ]
]

{ #category : #accessing }
RHViz >> subMenu [
	^ MenuModel new
		addGroup: [ :t1 | 
			t1
				addItem: [ :t2 | 
					t2
						name: 'Export Map';
						icon: Smalltalk ui icons glamorousSaveToUrl;
						shortcut: $e command;
						action: [ self doExportMap ] ];
				addItem: [ :t2 | 
					t2
						name: 'Export annotations';
						icon: Smalltalk ui icons glamorousLeftSide;
						action: [ self doExportAnnotation ] ];
				addItem: [ :t2 | 
					t2
						name: 'Import annotations';
						icon: Smalltalk ui icons glamorousRightSide;
						action: [ self doImportAnnotation ] ];
				addItem: [ :t2 | 
					t2
						name: 'Export Configuration';
						icon: Smalltalk ui icons glamorousLeftSide;
						"shortcut: $e command;"
							action: [ self doExportConfiguration ] ];
				addItem: [ :t2 | 
					t2
						name: 'Import Configuration';
						icon: Smalltalk ui icons glamorousRightSide;
						"shortcut: $e command;"
							action: [ self doImportConfiguration ] ] ];
		addGroup: [ :t1 | 
			t1
				addItem: [ :t2 | 
					t2
						name: 'Close';
						shortcut: $k command;
						icon: Smalltalk ui icons smallCancelIcon;
						action: [ self window close ] ] ]
]

{ #category : #api }
RHViz >> terminateAllProcesses [
	|pb |
	pb := ProcessBrowser new.
	
	"Terminate non-critic processes"	
	pb processList do: [ :p |
			(pb nameAndRulesFor: p) second  
				ifFalse: [ "self inform: 'Nope, won''t kill ' , p name.        ... do nothing"  ] 
				ifTrue: [ 
					p priority = Processor userSchedulingPriority ifFalse:[
						pb class terminateProcess: p
				]].
		 ].
	pb updateProcessList.
	self inform: 'PhaROS processes were terminated.'
]

{ #category : #accessing }
RHViz >> tfListener [
	^ tfListener
]

{ #category : #accessing }
RHViz >> tfListener: anObject [
	tfListener := anObject
]

{ #category : #initialization }
RHViz >> toolboxMenu [
	^ MenuModel new
		addGroup: [ :t1 | 
			t1
				addItem: [ :t2 | 
					t2
						name: 'Move camera';
						description: 'Move camera';
						icon: Smalltalk ui icons haloView;
						action: [ self doAction: #normal ] ];
				addItem: [ :t2 | 
					t2
						name: 'Reset view';
						description: 'Reset view';
						icon: Smalltalk ui icons haloDragIcon;
						action: [ self viewerReset ] ];
				addItem: [ :t2 | 
					t2
						name: 'Zoom in';
						description: 'Zoom in';
						icon: Smalltalk ui icons glamorousZoomIn;
						action: [ self zoomIn ] ];
				addItem: [ :t2 | 
					t2
						name: 'Zoom out';
						description: 'Zoom out';
						icon: Smalltalk ui icons glamorousZoomOut;
						action: [ self zoomOut ] ] ];
		addGroup: [ :t1 | 
			t1
				addItem: [ :t2 | 
					t2
						name: 'TF Tree';
						description: 'Inspect the tf tree';
						icon: Smalltalk ui icons hierarchy;
						action: [ self tfListener tree view inspect ] ];
				addItem: [ :t2 | 
					t2
						name: 'Goal';
						description: 'Set goal';
						icon: Smalltalk ui icons glamorousInto;
						action: [ self doAction: #goal ] ];
				addItem: [ :t2 | 
					t2
						name: 'Annotation';
						description: 'Annotation';
						icon: Smalltalk ui icons abstract;
						action: [ self doAction: #anotate ] ];
				addItem: [ :t2 | 
					t2
						name: 'Drawing';
						description: 'Drawing tool';
						icon: Smalltalk ui icons group;
						subMenu:
							(MenuModel new
								addGroup: [ :m1 | 
									m1
										addItem: [ :m2 | 
											m2
												name: 'Rectangle obstacles';
												description: 'Draw Rectangles';
												icon: Smalltalk ui icons group;
												action: [ self doAction: #rectangle ] ];
										addItem: [ :m2 | 
											m2
												name: 'Polygons obstacles';
												description: 'Draw polygons';
												icon: Smalltalk ui icons group;
												action: [ self doAction: #polygon ] ];
										addItem: [ :m2 | 
											m2
												name: 'Free space';
												description: 'Draw freespace';
												icon: Smalltalk ui icons group;
												action: [ 
													self mousestat at:#color put: Color white.
													self mousestat at:#stroke put: 0.0.
													self doAction: #polygon ] ] ]) ] ]
]

{ #category : #drawing }
RHViz >> tracePose: v [
	| shapes create |
	create := false.
	shapes := self mousestat
		at: #shapes
		ifAbsent: [ | list |
			list := {(TREllipseShape new
				size: 10;
				color: Color transparent;
				strokePaint: self defaultLineColor;
				translateTo: v positionFromCamera).
			(TRLineShape new color: self defaultLineColor).
			(TRLineShape new color: self defaultLineColor).
			(TRLineShape new color: self defaultLineColor)}.
			create := true.
			self mousestat at: #shapes put: list.
			self mousestat at: #origin put: v positionFromCamera.
			list ].
	self lock
		critical: [ create
				ifTrue: [ shapes do: [ :e | self canvas addShape: e ] ]
				ifFalse: [ self mousestat at: #orientation put: (self drawArowFrom: shapes cursor: v) ].
			self canvas signalUpdate ]
]

{ #category : #drawing }
RHViz >> traceRectangle:v [
	|obj|
	obj := TRBoxShape new extent: 0 @ 0.
	obj
		color: self drawingColor;
		strokeWidth: 0.
	self mousestat at: #rectangle put: obj.
	lock
		critical: [ obj translateTo: v positionFromCamera.
			self canvas addShape: obj.
			self canvas signalUpdate ]
]

{ #category : #accessing }
RHViz >> viewer [
	^ viewer
]

{ #category : #accessing }
RHViz >> viewer: anObject [
	viewer := anObject
]

{ #category : #api }
RHViz >> viewerReset [
	self canvas camera translateTo: 0 @ 0.
			self scale: 1.0.
			self zooming.
	"self canvas resetShapes"
	^ self
]

{ #category : #accessing }
RHViz >> worldModel [
	^self nodeList roots first
]

{ #category : #initialization }
RHViz >> zoomIn [
	scale := scale + 0.1.
	self zooming
]

{ #category : #initialization }
RHViz >> zoomOut [
	scale := scale - 0.1.
	scale < 0.1
		ifTrue: [ scale := 0.1 ].
	self zooming 
]

{ #category : #animations }
RHViz >> zooming [
	
	lock critical: [ 
		self canvas camera scale: self scale.
		self canvas signalUpdate
	]
]

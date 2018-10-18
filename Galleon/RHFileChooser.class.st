Class {
	#name : #RHFileChooser,
	#superclass : #RHUIRootApp,
	#instVars : [
		'selected',
		'fileBlock',
		'folder'
	],
	#category : #'Galleon-GUI'
}

{ #category : #specs }
RHFileChooser class >> defaultSpec [
	^ SpecLayout composed
		newColumn: [ :c | 
			c
				newRow: [ :t1 | 
					t1
						newColumn: [ :t2 | t2 add: #dList ];
						addSplitter;
						newColumn: [ :t2 | t2 newRow: [ :t3 | t3 add: #fList ] ] ];
				newRow: [ :t1 | t1 newColumn: [ :t2 | t2 add: #selectedFile ] ] height: 25 ]
]

{ #category : #'as yet unclassified' }
RHFileChooser class >> findDir: t1 [
	^ self new
		folder: true;
		openDialog: t1 title: 'Select a folder';
		yourself
]

{ #category : #'as yet unclassified' }
RHFileChooser class >> findFile: t1 [
	^ self new
		folder: false;
		openDialog: t1 title: 'Select a file';
		yourself
]

{ #category : #accessing }
RHFileChooser >> fileBlock [
	^ fileBlock
]

{ #category : #accessing }
RHFileChooser >> fileBlock: anObject [
	fileBlock := anObject
]

{ #category : #accessing }
RHFileChooser >> folder [
	^ folder
]

{ #category : #accessing }
RHFileChooser >> folder: anObject [
	folder := anObject
]

{ #category : #actions }
RHFileChooser >> getFileListIn: t1 [
	t1 isDirectory
		ifFalse: [ ^ {} ].
	^ t1 children select: [ :t2 | t2 asFileReference isFile and: t2 path base ~= '' ]
]

{ #category : #actions }
RHFileChooser >> getFolderListIn: t1 [
	t1 isDirectory
		ifFalse: [ ^ {} ].
	^ t1 children select: [ :t2 | t2 asFileReference isDirectory and: t2 path base ~= '' ]
]

{ #category : #initialization }
RHFileChooser >> initializeDialogWindow: t1 [
	t1 okAction: [ [ selected := self dList selectedItem content ] unless: self dList selectedItem isNil .
	[ selected := nil ] if: self selectedFile text isEmpty.
	selected
		ifNotNil: [ self fileBlock isNotNil
				ifTrue: [ self fileBlock value: selected value: self selectedFile text ] ]].
	^ self
]

{ #category : #initialization }
RHFileChooser >> initializeWidgets [
	self instantiateModels: #(#dList #TreeModel #fList #IconListModel #selectedFile #TextInputFieldModel).
	self dList roots: (self getFolderListIn: FileLocator home asFileReference).
	self dList childrenBlock: [ :t1 | self getFolderListIn: t1 asFileReference ].
	self dList displayBlock: [ :t1 | t1 path basename ].
	self dList iconBlock: [ :t1 | Smalltalk ui icons openIcon ].
	self fList displayBlock: [ :t1 | t1 path basename ].
	self fList icons: [ :t1 | Smalltalk ui icons smallCopyIcon ].
	self dList
		whenSelectedItemChanged: [ :t1 | 
			t1
				ifNotNil: [ self fList items: (self getFileListIn: t1).
					[ self selectedFile text: t1 basename ] if: self folder ] ].
	self fList whenSelectedItemChanged: [ :t1 | [ [ self selectedFile text: t1 basename ] unless: self folder ] unless: t1 isNil ].
	self folder: false.
	self selectedFile autoAccept: true.
	^ self
]

{ #category : #actions }
RHFileChooser >> openDialog: t1 title: t2 [
	self fileBlock: t1.
	selected := nil.
	self
		openDialogWithSpec;
		title: t2.
	^ self
]

{ #category : #accessing }
RHFileChooser >> selected [
	^ selected
]

{ #category : #accessing }
RHFileChooser >> selected: anObject [
	selected := anObject
]

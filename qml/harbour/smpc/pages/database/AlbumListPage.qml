import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.smpc.components 1.0

Page {
	id: albumslistPage
	allowedOrientations: Orientation.All
	property string artistname
	property int lastIndex
	property int lastOrientation

	Loader {
		id: gridViewLoader
		active: false
		anchors.fill: albumslistPage
		sourceComponent: Component {
			SilicaGridView {
				id: albumGridView
				property bool scrolling: sectionScroller.scrolling
				model: albumsModel
				cellWidth: Screen.sizeCategory >= Screen.Large
					? orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted
						? width / 6
						: width / 5
					: orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted
						? width / 4
						: width / 2
				cellHeight: cellWidth
				cacheBuffer: 0
				populate: Transition {
					NumberAnimation {
						properties: "x"
						from: albumGridView.width * 2
						duration: populateDuration
					}
				}
				quickScrollEnabled: jollaQuickscroll
				header: PageHeader {
					title: artistname !== "" ? artistname : qsTr("albums")
					width: parent.width
					height: Theme.itemSizeMedium
				}

				PullDownMenu {
					visible: artistname !== ""
					MenuItem {
						text: qsTr("add albums")
						onClicked: {
							addArtist(artistname)
						}
					}
					MenuItem {
						text: qsTr("play albums")
						onClicked: {
							playArtist(artistname)
						}
					}
				}

				ScrollDecorator {}
				SectionScroller {
					id: sectionScroller
					gridView: albumGridView
					landscape: false
					sectionPropertyName: "sectionprop"
				}
				delegate: AlbumDelegate {}
			}
		}
	}

	Loader {
		id: listviewLoader
		active: false
		anchors.fill: albumslistPage
		//anchors.bottomMargin: quickControlPanel.visibleSize
		sourceComponent: Component {
			SilicaListView {
				id: listView
				clip: true
				model: albumsModel
				quickScrollEnabled: jollaQuickscroll
				populate: Transition {
					NumberAnimation {
						properties: "x"
						from: listView.width * 2
						duration: populateDuration
					}
				}

				header: PageHeader {
					title: artistname !== "" ? artistname : qsTr("albums")
					width: parent.width
					height: Theme.itemSizeMedium
				}

				PullDownMenu {
					enabled: artistname !== ""
					MenuItem {
						text: qsTr("add albums")
						onClicked: {
							addArtist(artistname)
						}
					}
					MenuItem {
						text: qsTr("play albums")
						onClicked: {
							playArtist(artistname)
						}
					}
				}

				ScrollDecorator {}
				SectionScroller {
					listview: listView
					landscape: false
					sectionPropertyName: "sectionprop"
				}
				delegate: AlbumListDelegate {}
				section {
					property: 'sectionprop'
					delegate: SectionHeader {
						text: section
					}
				}
			}
		}
	}

	Loader {
		id: showViewLoader
		active: false
		anchors.fill: parent
		//anchors.rightMargin: quickControlPanel.visibleSize
		sourceComponent: Component {
			PathView {
				id: showView
				property int itemHeight: height / 1.3
				property int itemWidth: itemHeight
				model: albumsModel

				SectionScroller {
					pathview: showView
					landscape: true
					sectionPropertyName: "sectionprop"
					z: 120
					interactive: showView.interactive
				}

				cacheItemCount: pathItemCount + 2
				pathItemCount: 12 // width/itemWidth
				delegate: AlbumShowDelegate {}
				snapMode: PathView.NoSnap

				preferredHighlightBegin: 0.5
				preferredHighlightEnd: 0.5
				clip: true
				path: Path {
					startX: 0
					startY: showView.height / 2
					// Left out
					PathAttribute {
						name: "z"
						value: 0
					}
					PathAttribute {
						name: "delegateRotation"
						value: 80
					}

					// Left flip (bottom)
					PathLine {
						x: (showView.width / 2) - (showView.itemWidth / 2)
						y: showView.height - showView.itemHeight / 2
					}
					PathAttribute {
						name: "z"
						value: 50
					}
					PathAttribute {
						name: "delegateRotation"
						value: 70
					}
					PathPercent {
						value: 0.45
					}

					// Center (bottom)
					PathLine {
						x: showView.width / 2
						y: showView.height - showView.itemHeight / 2
					}
					PathAttribute {
						name: "z"
						value: 100
					}
					PathAttribute {
						name: "delegateRotation"
						value: 0
					}
					PathPercent {
						value: 0.5
					}

					// Right Flip (bottom)
					PathLine {
						x: showView.width / 2 + showView.itemWidth / 2
						y: showView.height - showView.itemHeight / 2
					}
					PathAttribute {
						name: "z"
						value: 50
					}
					PathAttribute {
						name: "delegateRotation"
						value: -70
					}
					PathPercent {
						value: 0.55
					}

					// Right out
					PathLine {
						x: showView.width
						y: showView.height / 2
					}
					PathAttribute {
						name: "z"
						value: 0
					}
					PathAttribute {
						name: "delegateRotation"
						value: -80
					}
					PathPercent {
						value: 1.0
					}
				}
			}
		}
	}

	onStatusChanged: {
		if (status === PageStatus.Activating) {
			if (!orientationTransitionRunning && orientation != lastOrientation) {
				gridViewLoader.active = false
				listviewLoader.active = false
				showViewLoader.active = false
				if (orientation === Orientation.Portrait || orientation === Orientation.PortraitInverted) {
					if (albumView === 0) {
						gridViewLoader.active = true
					} else if (albumView === 1) {
						listviewLoader.active = true
					}
				} else if (orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted) {
					if (useShowView) {
						showViewLoader.active = true
					} else {
						gridViewLoader.active = true
					}
				}
			}
		}
		if (status === PageStatus.Deactivating) {
			lastOrientation = orientation
		}

		if (status === PageStatus.Deactivating && typeof (gridViewLoader.item) != undefined && gridViewLoader.item) {
			lastIndex = gridViewLoader.item.currentIndex
		} else if (status === PageStatus.Activating) {
			if (typeof (gridViewLoader.item) != undefined && gridViewLoader.item) {
				gridViewLoader.item.positionViewAtIndex(lastIndex, GridView.Center)
			}
			requestArtistInfo(artistname)
		} else if (status === PageStatus.Active) {
			if (artistname != "") {
				pageStack.pushAttached(Qt.resolvedUrl("ArtistInfoPage.qml"), {artistname: artistname})
			}
		}
	}

	onOrientationTransitionRunningChanged: {
		if (!orientationTransitionRunning) {
			if (orientation === Orientation.Portrait || orientation === Orientation.PortraitInverted) {
				if (albumView === 0) {
					gridViewLoader.active = true
				} else if (albumView === 1) {
					listviewLoader.active = true
				}
			} else if (orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted) {
				if (useShowView) {
					showViewLoader.active = true
				} else {
					gridViewLoader.active = true
				}
			}
		} else {
			// Deactivating components
			gridViewLoader.active = false
			listviewLoader.active = false
			showViewLoader.active = false
		}
	}

	Component.onDestruction: {
		clearAlbumList()
	}
}
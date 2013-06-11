import QtQuick 1.1
import Sailfish.Silica 1.0


Page {
    id: currentsong_page
    property alias title: titleText.text;
    property alias album: albumText.text;
    property alias artist: artistText.text;
    property alias length: positionSlider.maximumValue;
    //property int lengthtextcurrent:lengthTextcurrent.text;
    property alias lengthtextcomplete:lengthTextcomplete.text;
    property alias position: positionSlider.value;
    property alias bitrate: bitrateText.text;
    property alias shuffle: shuffleButton.checked;
    property alias repeat: repeatButton.checked;
    property alias nr: nrText.text;
    property alias uri: fileText.text;
    property alias audioproperties: audiopropertiesText.text;
    property alias pospressed: positionSlider.pressed;
    property alias volume: volumeSlider.value;
    property alias volumepressed: volumeSlider.pressed;
    property bool playing;
    property int fontsize:theme.fontSizeMedium;
    property int fontsizegrey:theme.fontSizeSmall;
    property bool detailsvisible:true;


    SilicaFlickable
    {
        id: infoFlickable
        anchors {right:parent.right;left:parent.left;bottom:volumeSlider.top;top:parent.top}
        contentHeight: contentColumn.height
        clip: true
        Column {
            id : contentColumn
            PageHeader {
                id: pageHeading
                title: qsTr("current song")
            }
            width: parent.width

            Image{
                id: coverImage
                height: infoFlickable.height - (titleText.height + albumText.height + artistText.height + pageHeading.height)
                width: height
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectCrop
                source: coverimageurl
            }

            Label{id:titleText ;text: "";color:theme.primaryColor; font.pixelSize:fontsize;wrapMode: "WordWrap";anchors.horizontalCenter: parent.horizontalCenter}
            Label{id:albumText ;text: "";color:theme.primaryColor; font.pixelSize:fontsize;wrapMode: "WordWrap";anchors.horizontalCenter: parent.horizontalCenter}
            Label{id:artistText ;text: "";color:theme.primaryColor; font.pixelSize:fontsize;wrapMode: "WordWrap";anchors.horizontalCenter: parent.horizontalCenter}

            TextSwitch
            {
                checked: true
                text: qsTr("details")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: detailsvisible = checked
            }

            Label{text: qsTr("nr.:");color:theme.secondaryColor; font.pixelSize: fontsizegrey; visible: detailsvisible}
            Label{id:nrText ;text: "";color:theme.primaryColor; font.pixelSize:fontsize;wrapMode: "WordWrap";anchors.horizontalCenter: parent.horizontalCenter; visible: detailsvisible}
            Label{text: qsTr("bitrate:");color:theme.secondaryColor; font.pixelSize: fontsizegrey; visible: detailsvisible}
            Label{id:bitrateText ;text: "";color:theme.primaryColor; font.pixelSize:fontsize;wrapMode: "WordWrap";anchors.horizontalCenter: parent.horizontalCenter; visible: detailsvisible}
            Label{text: qsTr("properties:");color:theme.secondaryColor; font.pixelSize: fontsizegrey; visible: detailsvisible}
            Label{id:audiopropertiesText ;text: "";color:theme.primaryColor; font.pixelSize:fontsize;wrapMode: "WordWrap";anchors.horizontalCenter: parent.horizontalCenter; visible: detailsvisible}
            Label{text: qsTr("uri:");color:theme.secondaryColor; font.pixelSize: fontsizegrey; visible: detailsvisible}
            Label{id:fileText ;text: "";color:theme.primaryColor; font.pixelSize:fontsize;wrapMode:"WrapAnywhere" ; visible: detailsvisible;anchors {left:parent.left; right: parent.right;}}
        }
    }
            Slider
            {
                width: parent.width
                anchors {bottom:positionSlider.top;right:parent.right;left:parent.left}
                id: volumeSlider
                stepSize: 1;
                maximumValue: 100
                minimumValue: 0
                valueText: value+"%";
                label: qsTr("volume");
                onPressedChanged: {
                    if(!pressed)
                    {
                        setVolume(value);
                    }
                }
                onValueChanged: {
                    setVolume(value);
                   // valueText = value+"%";
                }
            }

            Slider
            {
                anchors {bottom:buttonRow.top;right:parent.right;left:parent.left}
                width: parent.width
                id: positionSlider
                stepSize: 1;
                label: qsTr("position");
                valueText: "";
                onPressedChanged: {
                    if(!pressed)
                    {
                        seek(value);
                    }
                }
                onValueChanged: {
                    valueText = formatLength(value);
                }
                Label{id:lengthTextcomplete ; text: "";color:theme.primaryColor; font.pixelSize:fontsizegrey;wrapMode: "WordWrap";anchors {right: parent.right; bottom:parent.bottom}}
            }
            Row
            {
                id: buttonRow
                //width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors {bottom:parent.bottom;/*right:parent.right;left:parent.left*/}
                Switch
                {
                    id:shuffleButton
                    icon.source: "image://theme/icon-m-shuffle"
                    onClicked: {
                        setShuffle(checked);
                    }
                }
                IconButton
                {
                    id: prevButton
                    icon.source: "image://theme/icon-m-previous-song"
                    onClicked: prev();
                }
                IconButton
                {
                    id: playButton
                    icon.source:playbuttoniconsource
                    onClicked: play();
                }
                IconButton
                {
                    id: nextButton
                    icon.source: "image://theme/icon-m-next-song"
                    onClicked: next();
                }
                Switch
                {
                    id:repeatButton
                    icon.source: "image://theme/icon-m-repeat"
                    onClicked: {
                        setRepeat(checked);
                    }
                }
            }

            function makeLastFMRequestURL()
            {
                var url = "";
                url = "http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key="+ lastfmapikey + "&artist="+artist+"&album="+album
                console.debug("LastFM url created: " + url);
                coverfetcherXMLModel.source = url;

                coverfetcherXMLModel.reload();


                return url;
            }

            XmlListModel
            {
                id: coverfetcherXMLModel
                query: "/lfm/album/image"
                XmlRole { name: "image"; query: "./string()" }
                XmlRole { name: "size"; query: "@size/string()" }
                onStatusChanged: {
                    console.debug("XML status changed to: "+ status);
                    if(status == XmlListModel.Ready)
                    {
                        if(count>0)
                        {
                            console.debug("Xml model ready, count: "+count);
                            for (var i = 0;i <count;i++)
                            {
                                console.debug("item: "+i);
                                console.debug(coverfetcherXMLModel.get(i).size+":");
                                console.debug(coverfetcherXMLModel.get(i).image);
                            }
                            console.debug("imageurl: " + coverfetcherXMLModel.get(coverfetcherXMLModel.count-1).image);
                            var coverurl = coverfetcherXMLModel.get(coverfetcherXMLModel.count-1).image;
                            if(coverurl !== coverimageurl) {
                                // global
                                coverimageurl = coverfetcherXMLModel.get(coverfetcherXMLModel.count-1).image;
                            }
                        }
                    }
                    if(status == XmlListModel.Error)
                    {
                        console.debug(coverfetcherXMLModel.errorString());
                    }
                }
            }
}
/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/****************************************************************************************
**
** edited by Nightmare 03/2014
** nightsoft@outlook.com
**
****************************************************************************************/
import QtQuick 2.0
import Sailfish.Silica 1.0
//import harbour.tabatimer.tabata 1.0

Dialog {
    id: diaProfileSettings
    //anchors.fill: parent
    canAccept: true
    property int profileID: 0
    DialogHeader {
        acceptText: bSave.checked ? "save permanent" : "Apply once"
    }

    onAccepted: {
        tabata1.setProfile(bTime1.valueSec,bTime2.valueSec,bStartUp.valueSec,slideRounds.value,bMute.checked,bSleep.checked,tProfile.text,bSave.checked,profileID)
    }

    onRejected: {
        //reject
    }
    SilicaFlickable {
        id: flick
        anchors.fill: diaProfileSettings
        contentHeight: colSettings.height
        ScrollDecorator{}

        Column{
            id: colSettings
            width: parent.width
            //height: parent.height
            spacing: Theme.paddingSmall
            PageHeader {
                title: " "
            }

            TextField {
                id: tProfile
                placeholderText: "Profile Name"
                label: "Profile Name"
                text: tabata1.getProfileText(profileID)
                width: parent.width-(2*Theme.paddingSmall)
                anchors.margins: Theme.paddingSmall
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                onTextChanged:{ if(tProfile.text.length>0){diaProfileSettings.canAccept=true}else{diaProfileSettings.canAccept=false}
                }

                validator: RegExpValidator { regExp: /^[0-9,a-zA-Z,\s]{1,}$/ }
            }

            Button {
                id: bStartUp
                text: "delay on start: " + hour + " h " + minute + " min " + second +" sec"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Theme.paddingSmall
                property int hour: tabata1.getProfileHours(tabata1.valStateStartUp(),profileID);
                property int minute: tabata1.getProfileMinutes(tabata1.valStateStartUp(),profileID);
                property int second: tabata1.getProfileSeconds(tabata1.valStateStartUp(),profileID);

                property int valueSec: hour*3600+minute*60+second

                onClicked: {
                    var timedialogS = pageStack.push(Qt.resolvedUrl("TimeDialog.qml"), {
                                                         infotext: "delay Start",
                                                         hour: bStartUp.hour,
                                                         minute: bStartUp.minute,
                                                         second: bStartUp.second
                                                     })
                    timedialogS.accepted.connect(function() {
                        hour = timedialogS.hour
                        minute = timedialogS.minute
                        second = timedialogS.second
                        valueSec = hour*3600+minute*60+second
                        if(!valueSec){valueSec=1}
                    })
                }
            }

            Button {
                id: bTime1
                text: "Interval 1: " + hour + " h " + minute + " min " + second +" sec"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Theme.paddingSmall
                property int hour: tabata1.getProfileHours(tabata1.valStateInt1(),profileID);
                property int minute: tabata1.getProfileMinutes(tabata1.valStateInt1(),profileID);
                property int second: tabata1.getProfileSeconds(tabata1.valStateInt1(),profileID);

                property int valueSec: hour*3600+minute*60+second

                onClicked: {
                    var timedialog1 = pageStack.push(Qt.resolvedUrl("TimeDialog.qml"), {
                                                         infotext: "Interval 1",
                                                         hour: bTime1.hour,
                                                         minute: bTime1.minute,
                                                         second: bTime1.second
                                                     })
                    timedialog1.accepted.connect(function() {
                        hour = timedialog1.hour
                        minute = timedialog1.minute
                        second = timedialog1.second
                        valueSec = hour*3600+minute*60+second
                        if(!valueSec){valueSec=1}
                    })
                }
            }

            Button {
                id: bTime2
                text: "Interval 2: " + hour + " h " + minute + " min " + second +" sec"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Theme.paddingSmall
                property int hour: tabata1.getProfileHours(tabata1.valStateInt2(),profileID);
                property int minute: tabata1.getProfileMinutes(tabata1.valStateInt2(),profileID);
                property int second: tabata1.getProfileSeconds(tabata1.valStateInt2(),profileID);

                property int valueSec: hour*3600+minute*60+second

                onClicked: {
                    var timedialog2 = pageStack.push(Qt.resolvedUrl("TimeDialog.qml"), {
                                                         infotext: "Interval 2",
                                                         hour: bTime2.hour,
                                                         minute: bTime2.minute,
                                                         second: bTime2.second
                                                     })
                    timedialog2.accepted.connect(function() {
                        hour = timedialog2.hour
                        minute = timedialog2.minute
                        second = timedialog2.second
                        valueSec = hour*3600+minute*60+second
                        if(!valueSec){valueSec=1}
                    })
                }
            }

            Slider {
                id: slideRounds
                value: tabata1.getProfileIntervals(profileID)
                minimumValue:1
                maximumValue:100
                stepSize: 1
                width: parent.width
                anchors.margins: Theme.paddingSmall
                valueText: value
                label: "number of intervals"
            }

            TextSwitch{
                id: bMute
                text: "mute notification-sound"
                enabled: true
                checked: tabata1.getProfileMute(profileID)
            }
            TextSwitch{
                id: bSleep
                text: "prevent sleepmode"
                checked: tabata1.getProfilePreventSleep(profileID)
            }
            TextSwitch{
                id: bSave
                text: "save permanent"
                checked: false
            }
        }
    }

}






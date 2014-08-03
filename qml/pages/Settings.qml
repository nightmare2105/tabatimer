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
    id: diaSettings
    //anchors.fill: parent
    canAccept: true
//    DialogHeader {
//        acceptText: bSave.checked ? "Set as Default" : "Apply"
//    }

    onAccepted: {
        tabata1.setSettings(cDefaultProfile.currentIndex,bWarn.checked);
        //tabata1.setProfile(bTime1.valueSec,bTime2.valueSec,bStartUp.valueSec,slideRounds.value,bMute.checked,bSleep.checked,tProfile.text,bSave.checked)
    }

    onRejected: {
        //reject
    }
    SilicaFlickable {
        id: flick
        anchors.fill: diaSettings
        contentHeight: colSettings.height
        ScrollDecorator{}
        PullDownMenu {
            MenuItem {
                id: menuEditActiveProfile
                enabled: true
                visible: true
                text: "Edit Active Profile"
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("ProfileSettings.qml"),{profileID: tabata1.getActiveProfile()});
                }
            }
        }


        Column{
            id: colSettings
            width: parent.width
            //height: parent.height
            spacing: Theme.paddingSmall
            SectionHeader {
                text: " "
            }

            SectionHeader{
                text: "Profiles"
            }
            ComboBox{
                id: cActProfile
                label: "active profile"
                currentIndex: tabata1.getActiveProfile()
                menu: ContextMenu {
                    MenuItem { text: tabata1.getProfileText(0)}
                    MenuItem { text: tabata1.getProfileText(1)}
                    MenuItem { text: tabata1.getProfileText(2)}
                    MenuItem { text: tabata1.getProfileText(3)}
                    MenuItem { text: tabata1.getProfileText(4)}
                    MenuItem { text: tabata1.getProfileText(5)}
                    MenuItem { text: tabata1.getProfileText(6)}
                    MenuItem { text: tabata1.getProfileText(7)}
                    MenuItem { text: tabata1.getProfileText(8)}
                    MenuItem { text: tabata1.getProfileText(9)}
                }
                onCurrentIndexChanged:{
                    var temp=tabata1.setActiveProfile(cActProfile.currentIndex);
                }

            }
            ComboBox{
                id: cDefaultProfile
                label: "default profile"
                currentIndex: tabata1.getDefaultProfile()
                menu: ContextMenu {
                    MenuItem { text: tabata1.getProfileText(0)}
                    MenuItem { text: tabata1.getProfileText(1)}
                    MenuItem { text: tabata1.getProfileText(2)}
                    MenuItem { text: tabata1.getProfileText(3)}
                    MenuItem { text: tabata1.getProfileText(4)}
                    MenuItem { text: tabata1.getProfileText(5)}
                    MenuItem { text: tabata1.getProfileText(6)}
                    MenuItem { text: tabata1.getProfileText(7)}
                    MenuItem { text: tabata1.getProfileText(8)}
                    MenuItem { text: tabata1.getProfileText(9)}
                }
            }

            ComboBox{
                id: cFavProfile1
                label: "shurtcut profile 1"
                currentIndex: tabata1.getFavProfile(1)
                menu: ContextMenu {
                    MenuItem { text: tabata1.getProfileText(0)}
                    MenuItem { text: tabata1.getProfileText(1)}
                    MenuItem { text: tabata1.getProfileText(2)}
                    MenuItem { text: tabata1.getProfileText(3)}
                    MenuItem { text: tabata1.getProfileText(4)}
                    MenuItem { text: tabata1.getProfileText(5)}
                    MenuItem { text: tabata1.getProfileText(6)}
                    MenuItem { text: tabata1.getProfileText(7)}
                    MenuItem { text: tabata1.getProfileText(8)}
                    MenuItem { text: tabata1.getProfileText(9)}
                }
                onCurrentIndexChanged: tabata1.setFavProfile(1,cFavProfile1.currentIndex);
            }
            ComboBox{
                id: cFavProfile2
                label: "shurtcut profile 2"
                currentIndex: tabata1.getFavProfile(2)
                menu: ContextMenu {
                    MenuItem { text: tabata1.getProfileText(0)}
                    MenuItem { text: tabata1.getProfileText(1)}
                    MenuItem { text: tabata1.getProfileText(2)}
                    MenuItem { text: tabata1.getProfileText(3)}
                    MenuItem { text: tabata1.getProfileText(4)}
                    MenuItem { text: tabata1.getProfileText(5)}
                    MenuItem { text: tabata1.getProfileText(6)}
                    MenuItem { text: tabata1.getProfileText(7)}
                    MenuItem { text: tabata1.getProfileText(8)}
                    MenuItem { text: tabata1.getProfileText(9)}
                }
                onCurrentIndexChanged: tabata1.setFavProfile(2,cFavProfile2.currentIndex);
            }

            SectionHeader{
                text: "General"
            }
            TextSwitch{
                id: bWarn
                text: "warn if display stays on\nfor more than 30 minutes"
                checked: tabata1.getProfilePreventSleep()
            }


            Label{
                text: "Version: " + APP_VERSION
                color: Theme.secondaryColor
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontSizeSmall
            }

        }

    }

}






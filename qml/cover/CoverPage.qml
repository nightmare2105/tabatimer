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

import QtQuick 2.0
import Sailfish.Silica 1.0
//import harbour.tabatimer.tabata 1.0

CoverBackground {
    id: cover

    ProgressCircle{
        id: progress
        scale: 2
        visible: true
        anchors.centerIn: parent
        Label {
            //x: Theme.paddingLarge
            id: progressText
            text: tabata1.getAllSecondsLeft()
            anchors.centerIn: parent
            color: Theme.primaryColor
        }
        Connections{
            target: tabata1
            onTabataChanged: { //Update all Labels etc.
                progress.value = tabata1.getTimePercent()
                progressText.text = tabata1.getAllSecondsLeft()
                cAction1.iconSource= !tabata1.getState() ? "image://theme/icon-cover-next" : "image://theme/icon-cover-pause"
            }
        }
    }

    Label {
        id: label
        text: "TabaTimer"
        anchors.margins: 2*Theme.paddingLarge
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

    }

    CoverActionList {
        id: coverAction
        CoverAction {
            id: cAction1
            iconSource: !tabata1.getState() ? "image://theme/icon-cover-next" : "image://theme/icon-cover-pause"
            onTriggered : !tabata1.getState() ? tabata1.start() : tabata1.stop()
        }

    }
}



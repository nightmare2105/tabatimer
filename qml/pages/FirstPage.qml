 /*
 TabaTimer FirstPage.qml
 by Nightmare
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

Page {
    id: page

    function buildText(timer){
        var retval="";
        var temph=tabata1.getProfileHours(timer);
        if(temph>0){
            retval+=temph+" h "
        }
        var temp=tabata1.getProfileMinutes(timer);
        if(temp>0 || temph>0){
            retval+=temp+" min "
        }
        temp=tabata1.getProfileSeconds(timer);
        retval+=temp+" s ";
        return retval;
    }

    function calcFullLengthString(){
        var secs=tabata1.getProfileAllSeconds(tabata1.valStateStartUp());
        secs+=tabata1.getProfileAllSeconds(tabata1.valStateInt1());
        secs+=tabata1.getProfileAllSeconds(tabata1.valStateInt2());

        var hours=Math.floor(secs/3600)
        secs-=hours*3600
        var mins=Math.floor(secs/60)
        secs-=mins*60
        return hours + " h " + mins + " min " + secs + " s" ;
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: page.height
        contentWidth: page.width
        //ScrollDecorator{}
        PullDownMenu {
            MenuItem {
                id: menuSettings
                text: !tabata1.getState() ? "Settings" : "Stop to Change Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
                enabled: !tabata1.getState()
            }
            MenuItem {
                id: menuProfiles
                text: "Manage Profiles"
                onClicked: pageStack.push(Qt.resolvedUrl("Profiles.qml"))
                enabled: !tabata1.getState()
                visible: true
            }


            MenuItem {
                id: menuEditActive
                text: "Edit Active Profile"
                onClicked: pageStack.push(Qt.resolvedUrl("ProfileSettings.qml"),{profileID: tabata1.getActiveProfile()});
                enabled: !tabata1.getState()
                visible: true
            }
        }

        PushUpMenu {
            id: menuPush
            MenuItem {
                id: menuFav1
                text: "loading Settings"
                onClicked: tabata1.setActiveProfile(tabata1.getFavProfile(1));
                enabled: !tabata1.getState()
                visible: true
            }
            MenuItem {
                id: menuFav2
                text: "loading Settings"
                onClicked: tabata1.setActiveProfile(tabata1.getFavProfile(2));
                enabled: !tabata1.getState()
            }
        }


        BackgroundItem{
            id: bStart
            onClicked: tabata1.start();
            visible: true
            height: parent.height

            Connections{
                target: tabata1
                onTabataChanged: { //Update all Labels etc.
                    var temp=tabata1.getProfileAllSeconds(tabata1.valStateInt1())+tabata1.getProfileAllSeconds(tabata1.valStateInt2())+tabata1.getProfileAllSeconds(tabata1.valStateStartUp());
                    if(temp>1800 && tabata1.getProfilePreventSleep() && tabata1.getWarnSleepPower()/* && !tabata1.getState()*/){infoWarn.text="Screen stays active for<br/>"+page.calcFullLengthString(); rWarn.visible=true;}else{infoWarn.text==""; rWarn.visible=false}
                    if(tabata1.getState()==tabata1.valStateInt1()){labelState.text ="\nGo!";}
                    if(tabata1.getState()==tabata1.valStateInt2()){labelState.text ="\nRest...";}
                    if(tabata1.getState()==tabata1.valStateStartUp()){labelState.text ="\nGet Ready";}
                    if(tabata1.getState()==tabata1.valStateStop()){labelState.text ="\nLet's Go?";}

                    menuSettings.text = !tabata1.getState() ? "Settings" : "Stop to Change Settings";
                    menuSettings.enabled = !tabata1.getState();
                    menuProfiles.visible = !tabata1.getState();
                    menuEditActive.enabled = !tabata1.getState();
                    menuEditActive.visible = !tabata1.getState();

                    menuPush.enabled=!tabata1.getState();
                    //menuPush.visible=!tabata1.getState();
                    menuFav1.text=tabata1.getProfileText(tabata1.getFavProfile(1));
                    menuFav2.text=tabata1.getProfileText(tabata1.getFavProfile(2));

                    info.text = !tabata1.getState() ? "touch anywhere to start" : "touch anywhere to stop"
                    progress.value = tabata1.getTimePercent()

                    temp="";
                    if(tabata1.getHoursLeft()){temp=tabata1.getHoursLeft()+":"};
                    if(tabata1.getHoursLeft()||tabata1.getMinutesLeft()){
                        if(tabata1.getMinutesLeft()<10){
                            temp+="0"+tabata1.getMinutesLeft()+":"}
                        if(tabata1.getMinutesLeft()>=10){
                            temp+=tabata1.getMinutesLeft()+":"}
                    }
                    if(tabata1.getSecondsLeft()<10&&(tabata1.getHoursLeft()||tabata1.getMinutesLeft())){temp+="0"};
                    temp+=tabata1.getSecondsLeft();
                    progressText.text=temp;

                    var  tabatastate =tabata1.getState();

                    progressBusy.running=tabata1.getState()
                    progressRound.value= tabata1.getRoundPercent()
                    progressRoundText.text = tabata1.getIntervalLeft();
                    labelIteration.text=tabata1.getProfileIntervals();
                    labelProfile.text=tabata1.getProfileText()
                    labelTime1.text=page.buildText(tabata1.valStateInt1());
                    labelTime2.text=page.buildText(tabata1.valStateInt2());
                    labelTimeStart.text=page.buildText(tabata1.valStateStartUp());

                    progressMins.visible= (tabata1.getHoursLeft(tabatastate)>0 ||tabata1.getMinutesLeft()>0) ? true : false; //anzeigen wenn noch Stunden vorhanden
                    var minmax=tabata1.getProfileHours(tabatastate)>0 ? 60 : tabata1.getProfileMinutes(tabatastate); //wenn Stunden vorhanden, dann Minuten auf 60 beziehen sonst auf anzahl Minuten
                    progressMins.value=(minmax-tabata1.getMinutesLeft())/minmax

                    progressHours.visible= tabata1.getHoursLeft()>0 ? true : false;
                    progressHours.value=(tabata1.getProfileHours(tabatastate)-tabata1.getHoursLeft())/tabata1.getProfileHours(tabatastate)

                    progressSecs.visible= (tabata1.getProfileMinutes(tabatastate)>0 || tabata1.getProfileHours(tabatastate)>0) ? true : false;
                    var secmax=(tabata1.getProfileMinutes(tabatastate)>0 || tabata1.getProfileHours(tabatastate)>0) ? 60 : tabata1.getProfileSeconds(tabatastate); //wenn Stunden vorhanden, dann Minuten auf 60 beziehen sonst auf anzahl Minuten
                    progressSecs.value=(secmax-tabata1.getSecondsLeft())/secmax
                    //console.log("state: " + tabatastate+" testsec: " + testsec+ "left: "+tabata1.getSecondsLeft()+"all secs:" + tabata1.getProfileSeconds(tabatastate))
                }

            }
            Column {
                id: column
                width: parent.width
                height: parent.height
                spacing: 0

                Column {
                    id: column1
                    width: parent.width
                    height: page.height*0.6
                    spacing: Theme.paddingSmall
                    //                PageHeader {
                    //                    title: "TabaTimer"
                    //                }

                    Label {
                        id: labelState
                        text: "\nLet's Go!"
                        font.pixelSize: Theme.fontSizeExtraLarge
                        color: Theme.highlightColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }


                    ProgressCircleBase{
                        id: progress

                        height: parent.height * 0.45
                        width: height
                        visible: true
                        backgroundColor: Theme.highlightDimmerColor
                        progressColor: Theme.highlightColor

                        anchors.horizontalCenter: parent.horizontalCenter
                        Label {
                            //x: Theme.paddingLarge
                            id: progressText
                            text: tabata1.getAllSecondsLeft()
                            anchors.centerIn: parent
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeExtraLarge
                        }
                        ProgressCircleBase{
                            id: progressSecs
                            backgroundColor: Theme.highlightColor
                            progressColor: Theme.highlightDimmerColor
                            height: parent.height * 0.9
                            width: height
                            visible: ! tabata1.getMinutesLeft()>0 ? true : false;
                            anchors.centerIn: parent
                        }
                        ProgressCircleBase{
                            id: progressMins
                            backgroundColor: Theme.highlightColor
                            progressColor: Theme.highlightDimmerColor
                            height: parent.height * 0.8
                            width: height
                            visible: ! tabata1.getMinutesLeft()>0 ? true : false;
                            anchors.centerIn: parent
                        }
                        ProgressCircleBase{
                            id: progressHours
                            backgroundColor: Theme.highlightColor
                            progressColor: Theme.highlightDimmerColor
                            height: parent.height * 0.7
                            width: height
                            visible: ! tabata1.getHoursLeft()>0 ? true : false;
                            anchors.centerIn: parent
                        }

                        BusyIndicator {
                            id: progressBusy
                            running: false
                            size: BusyIndicatorSize.Large
                            anchors.centerIn: parent;
                            scale: 1.4
                        }

                    }
                    Row{
                        id: rRound
                        spacing: Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter
                        Label {
                            id: lRound
                            text: "Iterations left:"
                            color: Theme.highlightColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        ProgressCircle{
                            id: progressRound
                            scale: 1
                            Label {
                                id: progressRoundText
                                text: tabata1.getIntervalLeft()
                                anchors.centerIn: parent
                                color: Theme.primaryColor
                            }
                        }
                    }
                }

                Column {
                    id: column2
                    width: parent.width
                    height: page.height*0.4
                    spacing: Theme.paddingSmall

                    Row{

                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.paddingSmall
                        width: (parent.width-(2*Theme.paddingLarge))
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge
                        Label {

                            text: "Profile:"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            width: parent.width/2
                            textFormat: Text.AlignLeft
                        }
                        Label {
                            id: labelProfile
                            text: "loading Settings"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            width: parent.width/2
                            textFormat: Text.AlignRight
                        }
                    }
                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.paddingSmall
                        width: (parent.width-(2*Theme.paddingLarge))
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge
                        Label {

                            text: "Iterations:"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            textFormat: Text.AlignLeft
                            width: parent.width/2
                        }
                        Label {
                            id: labelIteration
                            text: "loading Settings"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            textFormat: Text.AlignRight
                            width: parent.width/2
                        }
                    }
                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.paddingSmall
                        width: (parent.width-(2*Theme.paddingLarge))
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge
                        Label {

                            text: "Delay on Start:"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            textFormat: Text.AlignLeft
                            width: parent.width/2
                        }
                        Label {
                            id: labelTimeStart
                            text: "loading Settings"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            textFormat: Text.AlignRight
                            width: parent.width/2
                        }
                    }
                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.paddingSmall
                        width: (parent.width-(2*Theme.paddingLarge))
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge
                        Label {

                            text: "Time Interval 1:"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            textFormat: Text.AlignLeft
                            width: parent.width/2
                        }
                        Label {
                            id: labelTime1
                            text: "loading Settings"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            textFormat: Text.AlignRight
                            width: parent.width/2
                        }
                    }
                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.paddingSmall
                        width: (parent.width-(2*Theme.paddingLarge))
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge
                        Label {

                            text: "Time Interval 2:"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            textFormat: Text.AlignLeft
                            width: parent.width/2
                        }
                        Label {
                            id: labelTime2
                            text: "loading Settings"
                            //font.pixelSize:
                            color: Theme.highlightColor
                            textFormat: Text.AlignRight
                            width: parent.width/2
                        }
                    }

                    Label {
                        id: info
                        text: !tabata1.getState() ? "touch anywhere to start" : "touch anywhere to stop"
                        color: Theme.secondaryColor
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: Theme.fontSizeSmall

                    }



                    Rectangle{
                        id: rWarn
                        width: (parent.width-(2*Theme.paddingLarge))
                        height: infoWarn.height
                        color: "red"
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: false
                        opacity: 1
                        Label {
                            id: infoWarn
                            text: ""
                            //color: Theme.secondaryColor
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontSizeSmall

                            width: (parent.width-(2*Theme.paddingLarge))
                        }
                    }
                }
            }
        }
    }
}



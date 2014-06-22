/****************************************************************************************
**
** edited by Nightmare 03/2014
** nightsoft@outlook.com
**
****************************************************************************************/
import QtQuick 2.0
import Sailfish.Silica 1.0


Page{
    id: pProfiles

    onPageContainerChanged:{
        drawItems();
    }

    SilicaListView {
        id: listView
        anchors.fill: pProfiles
        ScrollDecorator{}
        header: PageHeader { title: "Profiles" }
        model: listModel


        ViewPlaceholder {
            enabled: listView.count == 0
            text: "No content"
        }

        delegate: ListItem {
            id: listItem
            menu: contextMenuComponent
            onClicked: {
                tabata1.setActiveProfile(model.index);
                drawItems();
            }
            Label {
                x: Theme.paddingLarge
                text: (model.index+1) + ". " + model.text + (tabata1.getActiveProfile()==index ? " - active" : "") + (tabata1.getDefaultProfile()==index ? " - default" : "")
                anchors.verticalCenter: parent.verticalCenter
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    MenuItem {
                        text: "Edit Profile"
                        onClicked: pageStack.replace(Qt.resolvedUrl("ProfileSettings.qml"),{profileID: model.index})
                    }
                    MenuItem {
                        text: "set as default profile"
                        onClicked: {
                            tabata1.setSettings(model.index,tabata1.getWarnSleepPower());
                            drawItems();
                        }
                    }
                }
            }
        }
    }
    ListModel {
        id: listModel
    }
    function drawItems(){
        listModel.clear();
        for(var index=0; index<tabata1.getProfileNumber();index++){
            listModel.append({"text": tabata1.getProfileText(index)})
        }
    }

}

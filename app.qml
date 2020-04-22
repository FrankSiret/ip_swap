import QtQml 2.2
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.2
import ip_swap 1.0
import "./validateIp.js" as JS

ApplicationWindow {
    id: window
    visible: true
    width: 680
    height: 520

    minimumWidth: 680
    maximumWidth: 800

    minimumHeight: 520
    maximumHeight: 520

    color: "transparent"
    background: Rectangle {
        radius: 4
        color: "#303030"
        border.color: Qt.darker("#303030")
        border.width: 2
    }
    flags: Qt.MSWindowsFixedSizeDialogHint | Qt.FramelessWindowHint

    IpSwap {
        id: ipSwap
        onAddProfile: {
            profileTab.profilesModel.append({"text":_profile})
            profileTab.cb_profiles.currentIndex = profileTab.profilesModel.count - 1
        }
        onAddProfiles: {
            profileTab.profilesModel.clear()
            var index = 0;
            for(var i in _profiles) {
                if( _profiles[i] === _current )
                    index = i;
                profileTab.profilesModel.append({"text":_profiles[i]})
            }
            profileTab.cb_profiles.currentIndex = index
        }
        onAddAdapters: {
            //adapterTab.adaptersModel.clear()
            var index = 0;
            for(var i in _adapters) {
                if( _adapters[i] === _current )
                    index = i
                adapterTab.adaptersModel.append({"text":_adapters[i]})
            }
            adapterTab.cb_adapters.enabled = true
            adapterTab.getAdapter.enabled = true
            adapterTab.cb_adapters.currentIndex = index
        }
        onCleanAdapters: {
            adapterTab.cb_adapters.enabled = false
            adapterTab.adaptersModel.clear()
            adapterTab.getAdapter.enabled = false
        }
        onCleanAdapterTab: {
            adapterTab.adhcp = "";
            adapterTab.aip = "";
            adapterTab.amask = "";
            adapterTab.agateway = "";
            adapterTab.adns1 = "";
            adapterTab.adns2 = "";
        }
        onSetConnected: {
            if( _isConnected ) {
                adapterTab.connected.text = "Connected"
                adapterTab.connected.color = Qt.rgba(0,1,0,1)
            }
            else {
                adapterTab.connected.text = "Disconnected"
                adapterTab.connected.color = Qt.rgba(1,0,0,1)
            }
        }
        onSetDescription: {
            adapterTab.description = _description
            adapterTab.mac = _mac
        }
        onGetIp: {
            adapterTab.adhcp = _dhcp ? "Yes" : "No"
            adapterTab.aip = _ip
            adapterTab.amask = _mask
            adapterTab.agateway = _gateway
        }
        onGetDns: {
            adapterTab.adns1 = _dns1
            adapterTab.adns2 = _dns2
        }
        onSetIp: {
            if(_dhcp)
                profileTab.dhcpProtocol.checked = true
            else profileTab.staticIp.checked = true

            profileTab.ip = _ip
            profileTab.mask = _mask
            profileTab.gateway = _gateway
        }
        onSetDns: {
            profileTab.dns1 = _dns1
            profileTab.dns2 = _dns2
        }
    }

    Component.onCompleted: ipSwap.start()

    MouseArea { /// check max-min window can move and maximization window when is factible
        anchors.fill: parent

        property point lastMousePos: Qt.point(0, 0)
        property bool mousePressed: false
        onPressed: {
            lastMousePos = Qt.point(mouse.x, mouse.y)
        }
        onPositionChanged: {
            var delta = Qt.point(mouse.x - lastMousePos.x,
                                 mouse.y - lastMousePos.y)
            window.x += delta.x
            window.y += delta.y
        }
    }

    RowLayout { /// title bar
        id: layoutTitle
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20

        Label {
            id: labelTitle
            text: "ip swap"
            font.bold: true
            font.pointSize: 14
            Layout.rightMargin: 10
        }

        Rectangle {
            id: buttonAdd
            width: 30
            height: 30
            color: "transparent"

            property color rectColor: "#606060"
            Rectangle {
                width: 17
                height: 3
                color: parent.rectColor
                anchors.centerIn: parent
            }
            Rectangle {
                width: 17
                height: 3
                color: parent.rectColor
                rotation: 90
                anchors.centerIn: parent
            }

            property bool hover: false
            property bool press: false

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { parent.hover = true; parent.rectColor = parent.press ? "#aaa" : "#fff" }
                onExited: { parent.hover = false; parent.rectColor = "#606060" }
                onPressed: { parent.press = true; parent.rectColor = "#aaa" }
                onReleased: { parent.press = false; parent.rectColor = parent.hover ? "#fff" : "#606060" }
                onClicked: {
//                    dialogEasyExecution.typeDialog = "add"
//                    dialogEasyExecution.aliasName1 = ""
//                    dialogEasyExecution.programName = ""
//                    dialogEasyExecution.index = -1
//                    dialogEasyExecution.opened()
//                    dialogEasyExecution.open()
                }
            }
            ToolTip {
                text: "Add"
                delay: 500
                timeout: 2000
                visible: parent.hover
            }
        }

        Rectangle {
            id: buttonSetting
            width: 30
            height: 30
            color: "transparent"

            property var sources: ["qrc:/img/settings1.svg", "qrc:/img/settings2.svg", "qrc:/img/settings3.svg"]
            property string rectSource: sources[0]

            Image {
                id: img1
                source: parent.rectSource
                anchors.centerIn: parent
                sourceSize.width: 17
                fillMode: Image.PreserveAspectFit
            }

            property bool hover: false
            property bool press: false

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { parent.hover = true; parent.rectSource = parent.press ? parent.sources[2] : parent.sources[1] }
                onExited: { parent.hover = false; parent.rectSource = parent.sources[0] }
                onPressed: { parent.press = true; parent.rectSource = parent.sources[2] }
                onReleased: { parent.press = false; parent.rectSource = parent.hover ? parent.sources[1] : parent.sources[0] }
                onClicked: {
                    //dialogConfig.open()
                }
            }
            ToolTip {
                text: "Config"
                delay: 500
                timeout: 2000
                visible: parent.hover
            }
        }

        Rectangle {
            id: buttonHelp
            width: 30
            height: 30
            color: "transparent"

            property color rectColor: "#606060"
            Label {
                text: "?"
                font.bold: true
                font.pointSize: 16
                color: parent.rectColor
                anchors.centerIn: parent
            }

            property bool hover: false
            property bool press: false

            /*MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { parent.hover = true; parent.rectColor = parent.press ? "#aaa" : "#fff" }
                onExited: { parent.hover = false; parent.rectColor = "#606060" }
                onPressed: { parent.press = true; parent.rectColor = "#aaa" }
                onReleased: { parent.press = false; parent.rectColor = parent.hover ? "#fff" : "#606060" }
                onClicked: {

                }
            }*/
            ToolTip {
                text: "Help"
                delay: 500
                timeout: 2000
                visible: parent.hover
            }
        }

        Item {
            width: 1
            Layout.fillWidth: true
        }

        /*Label {
            text: "frank.siret@gmail.com"
            font.pointSize: 9
            color: "#ce93d8"
            property bool hover: false
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Qt.openUrlExternally("mailto:frank.siret@gmail.com")
                }
                onHoveredChanged: {
                    parent.font.underline = parent.hover = !parent.hover
                }
            }
            ToolTip {
                text: "Frank Rodríguez Siret"
                delay: 500
                timeout: 2000
                visible: parent.hover
            }
        }*/

        Rectangle {
            id: buttonClose
            width: 30
            height: 30
            color: "transparent"

            property color rectColor: "#606060"
            Rectangle {
                width: 20
                height: 3
                color: parent.rectColor
                rotation: 45
                anchors.centerIn: parent
            }
            Rectangle {
                width: 20
                height: 3
                color: parent.rectColor
                rotation: -45
                anchors.centerIn: parent
            }

            property bool hover: false
            property bool press: false

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { parent.hover = true; parent.rectColor = parent.press ? "#aaa" : "#fff" }
                onExited: { parent.hover = false; parent.rectColor = "#606060" }
                onPressed: { parent.press = true; parent.rectColor = "#aaa" }
                onReleased: { parent.press = false; parent.rectColor = parent.hover ? "#fff" : "#606060" }
                onClicked: Qt.quit()
            }
        }
    }

    Rectangle { /// resize window
        width: 12
        height: 12
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 2
        color: Qt.rgba(0,0,0,0)
        Image {
            anchors.centerIn: parent
            width: 11
            fillMode: Image.PreserveAspectFit
            source: "qrc:/img/resize.svg"
            opacity: .3
        }
        MouseArea {
            anchors.fill: parent
            property point lastMousePos: Qt.point(0, 0)
            property bool mousePressed: false
            cursorShape: Qt.SizeFDiagCursor
            onPressed: {
                lastMousePos = Qt.point(mouse.x, mouse.y)
            }
            onPositionChanged: {
                var delta = Qt.point(mouse.x - lastMousePos.x,
                                     mouse.y - lastMousePos.y)

                window.width = Math.max(Math.min(window.width + delta.x, maximumWidth), minimumWidth)
                window.height = Math.max(Math.min(window.height + delta.y, maximumHeight), minimumHeight)
            }
        }
    }

    property real mid: .5 * window.width - 30

    RowLayout {
        id: body
        anchors.top: layoutTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: rectButtonSet.top
        anchors.margins: 20
        anchors.bottomMargin: 15
        spacing: 20
        Layout.alignment: "AlignTop"

        AdapterTab {
            id: adapterTab
            Layout.fillWidth: true
            on_ChangeAdapter: ipSwap.changeAdapter(_adapter)
            on_GetInterface: ipSwap.get_interfaces()
            on_CopyToProfile: {
                if(adapterTab.adhcp === "Yes")
                    profileTab.dhcpProtocol.checked = true
                else profileTab.staticIp.checked = true

                profileTab.ip = adapterTab.aip
                profileTab.mask = adapterTab.amask
                profileTab.gateway = adapterTab.agateway
                profileTab.dns1 = adapterTab.adns1
                profileTab.dns2 = adapterTab.adns2
            }
        }
        ProfileTab {
            id: profileTab
            Layout.maximumWidth: 300
            on_ChangeProfile: ipSwap.update_profile(_profile)
            on_SaveProfile: {
                if ( profileTab.dhcpProtocol.checked || JS.isValidIp(profileTab) )
                    saveProfileDialog.open()
            }
        }
    }

    RowLayout {
        id: rectButtonSet
        spacing: 20
        anchors.bottom: parent.bottom
        anchors.right: body.right
        anchors.margins: 20
        anchors.rightMargin: 0
        anchors.bottomMargin: 15
        Button {
            id: b_Set
            text: qsTr("Set")
            Layout.minimumWidth: 80
            onClicked: {
                if ( profileTab.dhcpProtocol.checked || JS.isValidIp(profileTab) )
                    ipSwap.set_addresses(profileTab.dhcpProtocol.checked,
                                         profileTab.ip, profileTab.mask,
                                         profileTab.gateway, profileTab.dns1,
                                         profileTab.dns2, adapterTab.cb_adapters.currentText)
            }
        }
        /*Button {
            id: b_Save
            text: qsTr("Save")
            Layout.minimumWidth: 80
            onClicked: {
                if ( profileTab.dhcpProtocol.checked || JS.isValidIp(profileTab) )
                    saveProfileDialog.open()
            }
        }*/
    }

    property color red: "#f33"

    Dialog {
        id: saveProfileDialog
        modal: true
        title: "Save profile"
        //standardButtons: Dialog.Ok | Dialog.Cancel
        width: 360
        bottomPadding: 9
        rightPadding: 15
        contentItem: ColumnLayout {
            RowLayout {
                spacing: 7
                Label {
                    text: "Profile:"
                }
                TextField {
                    id: profile
                    Layout.fillWidth: true
                    onTextEdited: {
                        if(profileTab.cb_profiles.find(text) !== -1) {
                            textProfileError.text = "This profile is already exists, continue for remplace it?"
                            textProfileError.color = red
                        }
                        else textProfileError.color = "transparent"
                    }
                    Text {
                        id: textProfileError
                        color: "transparent"
                        anchors.top: parent.bottom
                        anchors.topMargin: -5
                        anchors.left: parent.left
                    }
                }
            }
            RowLayout {
                Item {
                    width: 1
                    Layout.fillWidth: true
                }
                Button {
                    text: "Accept"
                    font.pixelSize: 14
                    Layout.minimumWidth: 90
                    highlighted: true
                    flat: true
                    onClicked: {
                        if(profile.text === "") {
                            textProfileError.text = "Specify a name"
                            textProfileError.color = red
                        }
                        else saveProfileDialog.accept()
                    }
                }
                Button {
                    text: "Cancel"
                    font.pixelSize: 14
                    onClicked: saveProfileDialog.reject()
                    Layout.minimumWidth: 90
                    highlighted: true
                    flat: true
                }
            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    saveProfileDialog.reject()
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    saveProfileDialog.accept()
                    event.accepted = true
                }
            }
        }

        onAccepted: {
            ipSwap.save_profile(profileTab.dhcpProtocol.checked,
                                profileTab.ip, profileTab.mask,
                                profileTab.gateway, profileTab.dns1,
                                profileTab.dns2, profile.text)
            profile.text = ""
        }
        onClosed: textProfileError.color = "transparent"
        onOpened: profile.forceActiveFocus()

        x: Math.max(0, window.width / 2 - width / 2)
        y: Math.max(0, window.height / 2 - height / 2 - 20)
    }

    Dialog {
        id: deleteProfileDialog
        modal: true
        property string entity: ""
        title: "Delete profile {" + entity + "}"
        //standardButtons: Dialog.Ok | Dialog.Cancel
        //width: 300
        bottomPadding: 9
        rightPadding: 15
        contentItem: RowLayout {
            focus: true
            Item {
                width: 1
                Layout.fillWidth: true
            }
            Button {
                text: "Accept"
                font.pixelSize: 14
                onClicked: deleteProfileDialog.accept()
                Layout.minimumWidth: 90
                highlighted: true
                flat: true
            }
            Button {
                text: "Cancel"
                font.pixelSize: 14
                onClicked: deleteProfileDialog.reject()
                Layout.minimumWidth: 90
                highlighted: true
                flat: true
            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    deleteProfileDialog.reject()
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    deleteProfileDialog.accept()
                    event.accepted = true
                }
            }
        }

        onAccepted: {
            ipSwap.delete_profile(entity)
            var index = profileTab.cb_profiles.find(entity)
            if(index >= 0) profileTab.profilesModel.remove(index)
            if(index >= profileTab.cb_profiles.count)
                index --
            profileTab.cb_profiles.currentIndex = index
        }

        x: Math.max(0, window.width / 2 - width / 2)
        y: Math.max(0, window.height / 2 - height / 2 - 20)
    }
}

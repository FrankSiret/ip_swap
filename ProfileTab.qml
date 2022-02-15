import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import ip_swap 1.0
import "./validateIp.js" as JS

ColumnLayout {
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    property alias cb_profiles: cb_profiles
    property alias profilesModel: profilesModel
    property alias dhcpProtocol: dhcpProtocol
    property alias staticIp: staticIp
    property alias ip:      l_ip.text
    property alias mask:    l_mask.text
    property alias gateway: l_gateway.text
    property alias dns1:    l_dns1.text
    property alias dns2:    l_dns2.text
    property alias proxy:    l_proxy.text
    property alias port:    l_port.text
    property alias proxy_except:    l_proxy_except.text

    property alias t_ip:      t_ip
    property alias t_mask:    t_mask
    property alias t_gateway: t_gateway
    property alias t_dns1:    t_dns1
    property alias t_dns2:    t_dns2
    property alias t_proxy:    t_proxy
    property alias t_port:    t_port
    property alias t_proxy_except:    t_proxy_except

    signal _saveProfile()
    signal _changeProfile(var _profile)
    Label {
        id: label2
        text: qsTr("Profiles")
    }
    RowLayout {
        spacing: 10
        Layout.rightMargin: 10
        ComboBox {
            id: cb_profiles
            model: ListModel { id: profilesModel }
            Layout.fillWidth: true
            onCurrentTextChanged: {
                _changeProfile(currentText)
            }
        }
        Rectangle {
            id: b_updateDeleteProfile
            width: 25
            height: 25
            color: "transparent"

            enabled: cb_profiles.count > 0

            property var sources: ["qrc:/img/delete1.svg", "qrc:/img/delete2.svg", "qrc:/img/delete3.svg"]
            property string rectSource: sources[0]

            Image {
                id: img1
                source: parent.rectSource
                anchors.centerIn: parent
                sourceSize.width: parent.width - 2
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
                    deleteProfileDialog.entity = cb_profiles.currentText
                    deleteProfileDialog.open()
                }
            }
            ToolTip {
                text: "Delete profile"
                delay: 500
                timeout: 2000
                visible: parent.hover
            }
        }
    }
    Item { width: 1 }
    ColumnLayout {
        spacing: 3
        RowLayout {
            spacing: 10
            Layout.rightMargin: 10
            Layout.fillWidth: true
            //Item { height: 1 }
            RadioButton {
                id: dhcpProtocol
                text: "DHCP"
            }
            RadioButton {
                id: staticIp
                text: "Static Ip"
                checked: true
                onCheckedChanged: {
                    rectDataOverEnabled.opacity = checked ? 0 : .5
                    l_ip.enabled = checked
                    l_mask.enabled = checked
                    l_gateway.enabled = checked
                    l_dns1.enabled = checked
                    l_dns2.enabled = checked
                }
                Rectangle {
                    id: rectRadio
                    anchors.fill: parent
                    anchors.bottomMargin: -10
                    anchors.leftMargin: -5
                    anchors.rightMargin: -5
                    radius: 4
                    z: parent.z - 1
                    color: "#2b2b2b"
                }
            }
            Item { height: 1; Layout.fillWidth: true }
            Rectangle {
                id: b_saveProfiles
                width: 25
                height: 25
                color: "transparent"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                property var sources: ["qrc:/img/save1.svg", "qrc:/img/save2.svg", "qrc:/img/save3.svg"]
                property string rectSource: sources[0]

                Image {
                    source: parent.rectSource
                    anchors.centerIn: parent
                    sourceSize.width: parent.width - 2
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
                    onClicked: _saveProfile()
                }
                ToolTip {
                    text: "Save Profile"
                    delay: 500
                    timeout: 2000
                    visible: parent.hover
                }
            }
            Rectangle {
                id: b_updateProfiles
                width: 25
                height: 25
                color: "transparent"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                property var sources: ["qrc:/img/refresh_1.svg", "qrc:/img/refresh_2.svg", "qrc:/img/refresh_3.svg"]
                property string rectSource: sources[0]

                Image {
                    source: parent.rectSource
                    anchors.centerIn: parent
                    sourceSize.width: parent.width - 2
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
                    onClicked: _changeProfile(cb_profiles.currentText)
                }
                ToolTip {
                    text: "Refresh"
                    delay: 500
                    timeout: 2000
                    visible: parent.hover
                }
            }
        }
        Rectangle {
            id: rectDataOver
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 4
            color: "#2b2b2b"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                anchors.topMargin: 5
                anchors.bottomMargin: 12
//                spacing: 20
                GridLayout {
                    id: rectData
                    rowSpacing: 0
                    columnSpacing: 20
                    columns: 2
                    Label { id: t_ip; text: "IP Address" }
                    TextField {
                        id: l_ip
                        Layout.fillWidth: true
                        selectByMouse: true
                        onTextEdited: text = JS.validateIp(l_ip)
    //                    validator: RegularExpressionValidator { regularExpression: /([0-9]{1,3}[\.]){3,3}[0-9]{1,3}/ }
                        color: t_ip.color
                    }
                    Label { id: t_mask; text: "Subnet Mask" }
                    TextField {
                        id: l_mask
                        Layout.fillWidth: true
                        selectByMouse: true
                        onTextEdited: text = JS.validateIp(l_mask)
    //                    validator: RegularExpressionValidator { regularExpression: /([0-9]{1,3}[\.]){3,3}[0-9]{1,3}/ }
                        color: t_mask.color
                    }
                    Label { id: t_gateway; text: "Default Gateway" }
                    TextField {
                        id: l_gateway
                        Layout.fillWidth: true
                        selectByMouse: true
                        onTextEdited: text = JS.validateIp(l_gateway)
    //                    validator: RegularExpressionValidator { regularExpression: /([0-9]{1,3}[\.]){3,3}[0-9]{1,3}/ }
                        color: t_gateway.color
                    }
                    Label { id: t_dns1; text: "Primary DNS" }
                    TextField {
                        id: l_dns1
                        Layout.fillWidth: true
                        selectByMouse: true
                        onTextEdited: text = JS.validateIp(l_dns1)
    //                    validator: RegularExpressionValidator { regularExpression: /([0-9]{1,3}[\.]){3,3}[0-9]{1,3}/ }
                        color: t_dns1.color
                    }
                    Label { id: t_dns2; text: "Alternative DNS" }
                    TextField {
                        id: l_dns2
                        Layout.fillWidth: true
                        selectByMouse: true
                        onTextEdited: text = JS.validateIp(l_dns2)
                        color: t_dns2.color
                    }
                }
                GridLayout {
                    rowSpacing: 0
                    columnSpacing: 20
                    columns: 2
                    Label { id: t_proxy; text: "Proxy" }
                    TextField {
                        id: l_proxy
                        Layout.fillWidth: true
                        selectByMouse: true
                        color: t_proxy.color
                    }
                    Label { id: t_port; text: "Port" }
                    TextField {
                        id: l_port
                        Layout.fillWidth: true
                        selectByMouse: true
                        onTextEdited: text = JS.validatePort(l_port)
                        color: t_port.color
                    }
                    Label { id: t_proxy_except; text: "Do not use proxy for:"; Layout.columnSpan: 2; Layout.bottomMargin: 10; Layout.topMargin: 10 }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.columnSpan: 2
                        clip: true
                        height: 80
                        color: "transparent"
                        ScrollView {
                            anchors.fill: parent
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            TextArea {
                                property bool isFocus: false
                                id: l_proxy_except
                                selectByMouse: true
                                wrapMode: "WrapAtWordBoundaryOrAnywhere"
                                hoverEnabled: true
                                onFocusChanged: isFocus = focus
                                color: t_proxy_except.color
                                clip: true
                                background: Item {
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#303030"
                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            height: 2
                                            color: l_proxy_except.isFocus ? "#ce93d8" :
                                                                          l_proxy_except.hovered ? "#fff" : "#3b3b3b"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: rectDataOverEnabled
                anchors.fill: rectDataOver
                anchors.bottomMargin: 230
                radius: 4
                color: rectDataOver.color
                opacity: 0
                Behavior on opacity { OpacityAnimator { duration: 100 } }
            }
        }
        SequentialAnimation {
            id: animationError
            loops: 4
            ColorAnimation { id: animationErrorInner1; property: "color"; from: "white"; to: "red" }
            ColorAnimation { id: animationErrorInner2; property: "color"; from: "red"; to: "white" }
        }
    }

    property alias animationError: animationError
    property alias animationErrorInner1: animationErrorInner1
    property alias animationErrorInner2: animationErrorInner2
}

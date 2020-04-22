import QtQml 2.2
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import ip_swap 1.0

ColumnLayout {
    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
    property alias cb_adapters: cb_networkAdapters
    property alias adaptersModel: adaptersModel
    property alias getAdapter: b_getAdapter
    property alias adhcp: l_adhcp.text
    property alias aip: l_aip.text
    property alias amask: l_amask.text
    property alias agateway: l_agateway.text
    property alias adns1: l_adns1.text
    property alias adns2: l_adns2.text
    property alias connected: l_connected
    property alias description: l_description.text
    property alias mac: l_mac.text
    signal _changeAdapter(var _adapter)
    signal _getInterface()
    signal _copyToProfile()
    spacing: 5
    Label {
        id: label1
        text: qsTr("Network Adapter")
    }
    RowLayout {
        spacing: 10
        ComboBox {
            id: cb_networkAdapters
            model: ListModel { id: adaptersModel }
            Layout.fillWidth: true
            onCurrentTextChanged: _changeAdapter(currentText)
        }
        /*Button {
            id: b_getAdapter
            text: qsTr("Update")
            onClicked: _getInterface()
        }*/
    }
    Item {width: 1}
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#2b2b2b"
        radius: 4
        GridLayout {
            anchors.fill: parent
            anchors.margins: 18
            rowSpacing: 10
            columnSpacing: 20
            columns: 2
            Label { id: l_connected; Layout.fillWidth: false; bottomPadding: 5; font.bold: true; Layout.columnSpan: 2 }
            Label { id: l_description; Layout.fillWidth: false; Layout.columnSpan: 2 }
            Label { text: "MAC"; }                          Label { id: l_mac; bottomPadding: 5; }
            Label { text: "DHCP" ;Layout.fillWidth: false } Label { id: l_adhcp ;Layout.fillWidth: true }
            Label { text: "IP Address" }                    Label { id: l_aip ;Layout.fillWidth: false }
            Label { text: "Subnet Mask" }                   Label { id: l_amask }
            Label { text: "Default Gateway" }               Label { id: l_agateway }
            Label { text: "Primary DNS" }                   Label { id: l_adns1 }
            Label { text: "Alternative DNS" }               Label { id: l_adns2 }
        }
        RowLayout {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 17

            Rectangle {
                id: b_copyToProfile
                width: 25
                height: 25
                color: "transparent"

                property var sources: ["qrc:/img/copy1.svg", "qrc:/img/copy2.svg", "qrc:/img/copy3.svg"]
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
                    onClicked: _copyToProfile()
                }
                ToolTip {
                    text: "Copy to Profile"
                    delay: 500
                    timeout: 2000
                    visible: parent.hover
                }
            }
            Rectangle {
                id: b_getAdapter
                width: 25
                height: 25
                color: "transparent"

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
                    onClicked: _changeAdapter(cb_networkAdapters.currentText)
                }
                ToolTip {
                    text: "Refresh"
                    delay: 500
                    timeout: 2000
                    visible: parent.hover
                }
            }
        }
    }
}

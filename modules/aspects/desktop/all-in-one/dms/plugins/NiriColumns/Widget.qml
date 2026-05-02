import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string columnInfo: ""
    property string scriptPath: Quickshell.env("HOME") + "/.config/DankMaterialShell/plugins/NiriColumns/get-columns.sh"
    property string currentOutput: parentScreen ? parentScreen.name : ""

    onCurrentOutputChanged: {
        if (currentOutput !== "") {
            updateInfo();
        }
    }

    Component {
        id: queryProcess
        Process {
            property string targetOutput: ""
            command: [root.scriptPath, targetOutput]
            stdout: SplitParser {
                onRead: line => root.columnInfo = line
            }
            onExited: destroy()
        }
    }

    function updateInfo() {
        if (root.currentOutput === "")
            return;
        queryProcess.createObject(root, {
            targetOutput: root.currentOutput
        }).running = true;
    }

    Process {
        id: eventStream
        command: ["niri", "msg", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (line.match(/(Window opened|Window closed|Workspace focused|focus|layouts)/)) {
                    updateInfo();
                }
            }
        }
    }

    Component.onCompleted: updateInfo()

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: "view_column"
                size: Theme.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
                visible: root.columnInfo !== ""
            }

            StyledText {
                text: root.columnInfo
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.columnInfo !== ""
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: "view_column"
                size: Theme.iconSize
                color: Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.columnInfo !== ""
            }

            StyledText {
                text: root.columnInfo
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.columnInfo !== ""
            }
        }
    }
}

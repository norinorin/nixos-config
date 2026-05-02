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
    property var columnList: []
    property string scriptPath: Quickshell.env("HOME") + "/.config/DankMaterialShell/plugins/NiriColumns/get-columns.sh"
    property string currentOutput: parentScreen ? parentScreen.name : ""
    property real maxWidth: parentScreen ? parentScreen.width * 0.5 : 1000

    property int maxRows: {
        let m = 0;
        if (!columnList)
            return 1;
        for (let i = 0; i < columnList.length; i++) {
            if (columnList[i] && columnList[i].windows && columnList[i].windows.length > m) {
                m = columnList[i].windows.length;
            }
        }
        return m === 0 ? 1 : m;
    }

    property real maxColHeight: {
        let m = 1000;
        if (!columnList)
            return m;
        for (let i = 0; i < columnList.length; i++) {
            let h = 0;
            let c = columnList[i];
            if (!c || !c.windows)
                continue;
            for (let j = 0; j < c.windows.length; j++) {
                h += c.windows[j].height || 0;
            }
            if (h > m)
                m = h;
        }
        return m;
    }

    property real totalColWidth: {
        let w = 0;
        if (!columnList)
            return 0;
        for (let i = 0; i < columnList.length; i++) {
            let colW = 0;
            let c = columnList[i];
            if (!c || !c.windows)
                continue;
            for (let j = 0; j < c.windows.length; j++) {
                if (c.windows[j].width > colW)
                    colW = c.windows[j].width;
            }
            w += colW;
        }
        return w;
    }

    property real scaleFactor: {
        let sH = 260.0 / Math.max(1, maxColHeight);
        let availableW = maxWidth - (columnList ? (columnList.length * Theme.spacingM + Theme.spacingM * 4) : 0);
        let sW = totalColWidth > 0 ? (availableW / totalColWidth) : sH;
        return Math.min(sH, sW);
    }

    property real calculatedPopoutWidth: {
        let w = 0;
        let dmsPopoutComponentMargin = 8;
        if (!columnList)
            return 350;
        for (let i = 0; i < columnList.length; i++) {
            let colW = 0;
            let c = columnList[i];
            if (!c || !c.windows)
                continue;
            for (let j = 0; j < c.windows.length; j++) {
                if (c.windows[j].width > colW)
                    colW = c.windows[j].width;
            }
            w += Math.max(60, colW * scaleFactor);
        }
        w += Math.max(0, columnList.length - 1) * Theme.spacingXS;
        w += Theme.spacingM * 2;
        w += dmsPopoutComponentMargin * 2;
        return Math.max(300, Math.min(maxWidth, w));
    }

    property real calculatedContentHeight: {
        let textH = 24 + Theme.spacingS;
        let blocksH = maxColHeight * scaleFactor;
        let spacingH = Math.max(0, maxRows - 1) * Theme.spacingXS;
        return textH + blocksH + spacingH;
    }

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
                onRead: line => {
                    try {
                        let data = JSON.parse(line);
                        root.columnInfo = data.text;
                        root.columnList = data.columns;
                    } catch (e) {
                        console.error("NiriColumns: Failed to parse JSON", line);
                    }
                }
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

    popoutWidth: root.calculatedPopoutWidth
    popoutHeight: Math.max(150, Math.min(parentScreen ? parentScreen.height * 0.8 : 800, root.calculatedContentHeight + 110))

    popoutContent: Component {
        PopoutComponent {
            id: popoutColumn

            headerText: "Workspace Overview"
            detailsText: "Click a block to focus window"
            showCloseButton: true

            Item {
                width: parent.width
                implicitHeight: root.calculatedContentHeight

                ListView {
                    anchors.fill: parent
                    model: root.columnList
                    orientation: ListView.Horizontal
                    spacing: Theme.spacingXS
                    clip: true
                    leftMargin: Theme.spacingM
                    rightMargin: Theme.spacingM

                    delegate: Column {
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Col " + modelData.column_index
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Column {
                            spacing: Theme.spacingXS

                            Repeater {
                                model: modelData.windows

                                delegate: StyledRect {
                                    width: Math.max(60, modelData.width * root.scaleFactor)
                                    height: Math.max(30, modelData.height * root.scaleFactor)
                                    radius: Theme.cornerRadius
                                    color: modelData.is_focused ? Theme.primaryContainer : (windowMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
                                    border.color: modelData.is_focused ? Theme.primary : Theme.outlineVariant
                                    border.width: 1

                                    Column {
                                        anchors.centerIn: parent
                                        width: parent.width - Theme.spacingXS
                                        spacing: Theme.spacingXS

                                        StyledText {
                                            text: modelData.app_id || "Unknown"
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Bold
                                            color: modelData.is_focused ? Theme.onPrimaryContainer : Theme.surfaceText
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                            width: parent.width
                                        }

                                        StyledText {
                                            text: modelData.title || ""
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: modelData.is_focused ? Theme.onPrimaryContainer : Theme.surfaceVariantText
                                            elide: Text.ElideRight
                                            maximumLineCount: 2
                                            wrapMode: Text.Wrap
                                            horizontalAlignment: Text.AlignHCenter
                                            width: parent.width
                                        }
                                    }

                                    MouseArea {
                                        id: windowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", modelData.id.toString()]);
                                            popoutColumn.closePopout();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

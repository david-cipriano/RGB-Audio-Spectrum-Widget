import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

// Import whatever module provides AudioEngine
// import org.example.audio 1.0

KCMUtils.SimpleKCM {

    id:page

    // must match <entry name="..."> in main.xml
    property alias cfg_captureDeviceIndex: deviceCombo.currentIndex
    property alias cfg_lineThickness: lineThickness.value

    Kirigami.FormLayout {

        // Create it here as well
        AudioEngine { id: audioEngine }

        QQC2.ComboBox {
            id: deviceCombo
            Kirigami.FormData.label: i18n("Capture device:")
            model: audioEngine.getCaptureDevices()
        }

        QQC2.SpinBox {
            id: lineThickness
            Kirigami.FormData.label: i18n("Line thickness:")

            from: 1
            to: 12
            stepSize: 1
        }
    }
}


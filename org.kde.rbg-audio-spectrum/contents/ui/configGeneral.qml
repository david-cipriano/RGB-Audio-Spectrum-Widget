import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

// Import whatever module provides AudioEngine
// import org.example.audio 1.0

KCMUtils.SimpleKCM {

    id:page
    property alias cfg_captureDeviceIndex: deviceCombo.currentIndex
    property alias cfg_captureDeviceName: deviceCombo.currentText
    property alias cfg_lineThickness: lineThickness.value

    Kirigami.FormLayout {

        // Create it here as well
        AudioEngine { id: audioEngine }

        QQC2.ComboBox {
            id: deviceCombo
            Kirigami.FormData.label: i18n("Capture device:")
            model: audioEngine.getCaptureDevices()

            onActivated: {
                page.cfg_captureDeviceName = deviceCombo.currentText
                page.cfg_captureDeviceIndex = deviceCombo.currentIndex
            }
        }

        QQC2.SpinBox {
            id: lineThickness
            Kirigami.FormData.label: i18n("Line thickness:")
            from: 1
            to: 12
            stepSize: 1
        }
    }


    function resolveIndex(devs) {
        if (!devs || devs.length === 0)
            return 0

        // 1) match by saved name
        if (cfg_captureDeviceName && cfg_captureDeviceName.length > 0) {
            const i = devs.indexOf(cfg_captureDeviceName)
            if (i >= 0) return i
        }

        // 2) fallback to saved index if valid
        if (cfg_captureDeviceIndex >= 0 && cfg_captureDeviceIndex < devs.length)
            return cfg_captureDeviceIndex

        // 3) final fallback
        return 0
    }

    Component.onCompleted: {
        const devs = audioEngine.getCaptureDevices() || []
        const idx = resolveIndex(devs)
        deviceCombo.currentIndex = idx

        // self-heal config so it stays consistent
        page.cfg_captureDeviceIndex = idx
        page.cfg_captureDeviceName = (devs[idx] !== undefined) ? devs[idx] : ""
    }
}


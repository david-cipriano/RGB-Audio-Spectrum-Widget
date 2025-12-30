import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import "."

PlasmoidItem {
    id: root
    width: 400
    height: 300

    Plasmoid.title: "RGB Audio Spectrum V1"
    Plasmoid.icon: "audio-x-generic"

    // Transparent background
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    AudioEngine {
        id: audioEngine
        Component.onCompleted: {
            setGain(0.1)
            setFalloff(0.5)
            setBarHeight(0.1)
            startCapture(1)
        }
    }

    // Start capture when the widget loads
    Component.onCompleted: {
        audioEngine.startCapture(plasmoid.configuration.captureDeviceIndex)
    }

    // React to changes made in the configuration dialog
    Connections {
        target: plasmoid.configuration
        function onCaptureDeviceIndexChanged() {
            audioEngine.startCapture(plasmoid.configuration.captureDeviceIndex)
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: 400
        Layout.minimumHeight: 300

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            // ===== Visualizer Area =====
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Canvas {
                    id: canvas
                    anchors.fill: parent
                    antialiasing: true
                    renderTarget: Canvas.FramebufferObject

                    // Tunables
                    property real amplitudeScale: 0.95
                    property real lineWidth: plasmoid.configuration.lineThickness
                    property real topPadding: 16
                    property real bottomPadding: 0


                    function clamp(v, lo, hi) {
                        return Math.max(lo, Math.min(hi, v))
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.clearRect(0, 0, width, height)

                        var mags = audioEngine.magnitudes
                        if (!mags || mags.length < 2)
                            return

                            var n = mags.length
                            var usableH = Math.max(1, height - topPadding - bottomPadding)
                            var baseY = height - bottomPadding
                            var step = width / (n - 1)

                            // ===== Rainbow gradient (full RGB / HSV) =====
                            var grad = ctx.createLinearGradient(0, 0, width, 0)
                            var steps = 36   // increase for even smoother rainbow

                            for (var i = 0; i <= steps; i++) {
                                var t = i / steps
                                grad.addColorStop(t, Qt.hsva(t, 1.0, 1.0, 0.95))
                            }

                            ctx.strokeStyle = grad
                            ctx.lineWidth = lineWidth
                            ctx.lineJoin = "round"
                            ctx.lineCap = "round"

                            function yFor(i) {
                                var m = clamp(mags[i], 0.0, 1.0) * amplitudeScale
                                return baseY - (m * usableH)
                            }

                            // ===== Smooth curve =====
                            ctx.beginPath()
                            ctx.moveTo(0, yFor(0))

                            for (var i = 1; i < n; i++) {
                                var x0 = (i - 1) * step
                                var y0 = yFor(i - 1)
                                var x1 = i * step
                                var y1 = yFor(i)

                                var mx = (x0 + x1) / 2
                                var my = (y0 + y1) / 2

                                ctx.quadraticCurveTo(x0, y0, mx, my)

                                if (i === n - 1) {
                                    ctx.lineTo(x1, y1)
                                }
                            }

                            ctx.stroke()
                    }

                    // Repaint when audio updates
                    Connections {
                        target: audioEngine
                        function onMagnitudesChanged() {
                            canvas.requestPaint()
                        }
                    }

                    // Repaint on resize
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }
            }
        }
    }
}

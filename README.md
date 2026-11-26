# KDE Plasma 6 Desktop Audio Control Widget

A modern, tactile, and highly optimized desktop widget (Plasmoid) for **KDE Plasma 6** featuring hardware-style rotary knobs, live GPU-accelerated VU meters, multi-microphone and multi-output device switching, per-application volume control, and customizable themes.

![KDE Plasma 6](https://img.shields.io/badge/KDE-Plasma%206-blue?logo=kde)
![License](https://img.shields.io/badge/License-GPL%203.0+-green)
![Architecture](https://img.shields.io/badge/Architecture-QML%20%7C%20QtQuick.Shapes%20%7C%20PulseAudioQt-orange)

---

## Features

- **Retro Radio-Style Rotary Knobs**:
  - Tactile rotary dial controls (-135° to +135°) for master output and microphone volume.
  - Interactive with vertical mouse dragging and precision mouse wheel scrolling.
- **Embedded Real-Time VU / Peak Meter**:
  - Live sound intensity / peak amplitude is drawn directly into the knob's arc as a contrasting pulse wave.
  - **100% GPU-Accelerated**: Built with `QtQuick.Shapes` (`PathAngleArc`) and GPU vertex shaders. Zero JavaScript math loops on paint, practically 0.0% CPU overhead even at high refresh rates.
- **Multi-Device Output & Input Switching**:
  - Dedicated dropdown menus (`ComboBox`) to switch both default speaker/headphone output sinks and input microphones (USB, headset, webcam, or line-in) on the fly.
- **Per-Application Volume Control (Apps View)**:
  - Dynamic stream management powered by `PulseAudio.SinkInputModel`. View active audio-playing apps (Spotify, Firefox, games) and control their volume and mute state individually.
- **Single-Click View Toggle**:
  - Compact `[ 🔊 Aygıtlar ⇆ ]` / `[ 📱 Uygulamalar ⇆ ]` pill button to switch seamlessly between master devices and active applications.
- **Multi-Theme Engine**:
  - Switch on the fly between 4 distinct visual themes:
    - **Breeze**: Native KDE Plasma transparent integration.
    - **Warm Vintage Cream**: Vintage radio aesthetic with warm cream cards (`#ebe3d5`), deep navy text (`#1a2744`), and amber gold accents (`#d49a3d`).
    - **Cyber Dark Glass**: Dark translucent glass (`#0f141d`) with vibrant neon cyan and magenta accents.
    - **Nordic Frost**: Polar slate (`#2e3440`), arctic cyan (`#88c0d0`), and crisp white.
- **True Desktop Transparency**:
  - Configured with `Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground` so the widget floats cleanly directly on your desktop wallpaper without any unwanted opaque container frames.
- **PipeWire DSP Optimization**:
  - Automatically detaches `VolumeMonitor` targets when muted to halt PipeWire audio signal DSP processing.

---

## Installation

### Manual / Development Setup (Symlink)

1. Clone the repository into your preferred workspace:
   ```bash
   git clone https://github.com/guitareren/KDE_SOUND_WIDGET.git ~/KDE_SOUND_WIDGET
   ```

2. Link the widget to your local Plasma applets directory:
   ```bash
   mkdir -p ~/.local/share/plasma/plasmoids
   ln -sfn ~/KDE_SOUND_WIDGET ~/.local/share/plasma/plasmoids/org.eren.audiocontrol
   ```

3. Reload Plasma desktop shell to discover the new widget:
   ```bash
   systemctl --user restart plasma-plasmashell
   ```

4. Right-click on your desktop, choose **Add Widgets...**, search for **"Ses Denetimi"** or **"audiocontrol"**, and drag it onto your desktop!

---

## Live Preview (Standalone Window)

You can preview and test the widget in a standalone test window without altering your desktop setup:

```bash
plasmawindowed org.eren.audiocontrol &
```

---

## License

GPL-3.0-or-later.

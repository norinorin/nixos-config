{
  lib,
  pkgs,
  ...
}: let
  port = 55461;

  kanataOSDaPyScript = pkgs.writeText "kanata-osd.py" ''
    import asyncio
    import json
    import signal
    from typing import TypeVar

    import gi

    gi.require_version("Gtk", "4.0")
    gi.require_version("Gtk4LayerShell", "1.0")

    from gi.repository import Gdk, GLib, Gtk, Gtk4LayerShell

    SOCKET_HOST = "localhost"
    SOCKET_PORT = 55461
    OVERLAY_TIMEOUT_MS = 1500
    RECONNECT_DELAY_S = 10
    KANATA_FILE = "/tmp/sb-kanata"
    WAYBAR_SIGNAL = signal.SIGRTMIN + 17
    MARGIN_BOTTOM = 175

    CSS = """
    window { background: transparent; }
    #overlay-box {
        background-color: alpha(@window_bg_color, 0.9);
        color: @window_fg_color;
        border: 1px solid @borders;
        border-radius: 12px;
        padding: 20px 40px;
    }
    label { font-weight: bold; font-size: 24px; }
    """

    T = TypeVar("T")


    class Bail(Exception): ...


    class OverlayWindow(Gtk.Window):
        def __init__(self, monitor):
            super().__init__()
            Gtk4LayerShell.init_for_window(self)
            Gtk4LayerShell.set_monitor(self, monitor)
            Gtk4LayerShell.set_layer(self, Gtk4LayerShell.Layer.OVERLAY)
            Gtk4LayerShell.set_anchor(self, Gtk4LayerShell.Edge.BOTTOM, True)
            Gtk4LayerShell.set_margin(self, Gtk4LayerShell.Edge.BOTTOM, MARGIN_BOTTOM)
            Gtk4LayerShell.set_keyboard_mode(self, Gtk4LayerShell.KeyboardMode.NONE)

            self.label = Gtk.Label(label="Layer: base")
            self.box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            self.box.set_name("overlay-box")
            self.box.set_halign(Gtk.Align.CENTER)
            self.box.append(self.label)
            self.set_child(self.box)

            provider = Gtk.CssProvider()
            provider.load_from_data(CSS.encode())
            Gtk.StyleContext.add_provider_for_display(
                self.get_display(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )
            self.timeout_id = None
            self.set_visible(False)

        def update_layer(self, layer_name: str):
            self.label.set_text(f"Layer: {layer_name}")
            self.set_visible(True)
            if self.timeout_id:
                GLib.source_remove(self.timeout_id)
            self.timeout_id = GLib.timeout_add(OVERLAY_TIMEOUT_MS, self.on_timeout)

        def on_timeout(self):
            self.set_visible(False)
            self.timeout_id = None
            return False


    async def _wait(coro, event):
        coro_task = asyncio.create_task(coro)
        event_task = asyncio.create_task(event.wait())
        done, pending = await asyncio.wait(
            [coro_task, event_task], return_when=asyncio.FIRST_COMPLETED
        )
        for future in pending:
            future.cancel()
        if event_task in done:
            raise Bail()
        return coro_task.result()


    async def kill_waybar():
        process = await asyncio.create_subprocess_exec(
            "/run/current-system/sw/bin/pkill", f"-{WAYBAR_SIGNAL}", "waybar"
        )
        await process.wait()


    async def handle_connection(reader, shutdown_event, windows):
        print("Connection established. Listening for events...")
        while not shutdown_event.is_set():
            try:
                line = await _wait(reader.readline(), shutdown_event)
            except Bail:
                break

            if not line:
                print("Connection closed by peer.")
                break

            line_str = line.decode().strip()
            if '"LayerChange"' in line_str:
                print(f"Got layer change event: {line}")
                try:
                    data = json.loads(line_str)
                    layer = data.get("LayerChange", {}).get("new", "base")
                    with open(KANATA_FILE, "w") as f:
                        if layer != "base":
                            f.write(layer)
                    for window in windows:
                        window.update_layer(layer)
                    asyncio.create_task(kill_waybar())
                except json.JSONDecodeError as e:
                    print(f"Error decoding JSON: {e}")


    async def run_client(shutdown_event, windows):
        while not shutdown_event.is_set():
            try:
                reader, writer = await asyncio.open_connection(SOCKET_HOST, SOCKET_PORT)
                await handle_connection(reader, shutdown_event, windows)
                writer.close()
                await writer.wait_closed()
            except (ConnectionRefusedError, OSError):
                await asyncio.sleep(RECONNECT_DELAY_S)
            except asyncio.CancelledError:
                break


    async def run_gtk_loop(app, shutdown_event):
        context = GLib.MainContext.default()
        while not shutdown_event.is_set():
            while context.pending():
                context.iteration(False)
            await asyncio.sleep(0.01)


    async def main():
        shutdown_event = asyncio.Event()
        loop = asyncio.get_running_loop()
        loop.add_signal_handler(signal.SIGINT, lambda: shutdown_event.set())

        app = Gtk.Application(application_id="com.kanata.osd")
        app.register(None)

        display = Gdk.Display.get_default()
        monitors = display.get_monitors()
        windows = []  # mutable

        def on_monitors_changed(monitors_list, position, removed, added):
            for _ in range(removed):
                if position < len(windows):
                    win = windows.pop(position)
                    win.destroy()

            for i in range(added):
                monitor = monitors_list.get_item(position + i)
                win = OverlayWindow(monitor)
                windows.insert(position + i, win)

        monitors.connect("items-changed", on_monitors_changed)
        on_monitors_changed(monitors, 0, 0, monitors.get_n_items())

        try:
            await asyncio.gather(
                run_client(shutdown_event, windows),
                run_gtk_loop(app, shutdown_event),
                return_exceptions=True,
            )
        except Exception:
            app.quit()


    if __name__ == "__main__":
        try:
            asyncio.run(main())
        except KeyboardInterrupt:
            pass
  '';
  kanataOSD = let
    pythonEnv = pkgs.python3.withPackages (ps: [ps.pygobject3]);
  in
    pkgs.stdenv.mkDerivation {
      name = "kanata-osd";
      dontUnpack = true;

      nativeBuildInputs = [
        pkgs.makeWrapper
        pkgs.wrapGAppsHook4
        pkgs.gobject-introspection
      ];

      buildInputs = [
        pkgs.gtk4
        pkgs.gtk4-layer-shell
        pkgs.gsettings-desktop-schemas
        pythonEnv
      ];

      installPhase = ''
        mkdir -p $out/bin

        makeWrapper ${pythonEnv}/bin/python $out/bin/kanata-osd \
          --add-flags "${kanataOSDaPyScript}" \
          --set LD_PRELOAD "${pkgs.gtk4-layer-shell}/lib/libgtk4-layer-shell.so" \
          ''${gappsWrapperArgs[@]}
      '';
    };
in {
  environment.systemPackages = [
    pkgs.gobject-introspection
  ];
  boot.kernelModules = ["uinput"];
  hardware.uinput.enable = true;
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';
  users.groups.uinput = {};
  systemd.services.kanata-externalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };
  services.kanata = {
    enable = true;
    keyboards = {
      externalKeyboard = {
        inherit port;
        devices = [
          "/dev/input/by-path/pci-0000:00:14.0-usb-0:3:1.0-event-kbd"
        ];
        config = ''
          #|
          note to self:
          - tap shift to enter numarrow layer in which wasd becomes arrow and mjkluio789 becomes numpad
          - fn+alt combos:
          - f10:      mute
          - f11:      voldown
          - f12:      voldup
          - p/prntsc: play/pause
          - pgup:     mediaprev
          - pgdown:   medianext
          - a:        move a window to the left monitor
          - d:        move a window to the right monitor
          |#

          (defsrc
            ;; "virtual" keys. these are the keys that register when fn key is held
            ;; used for the fn+ralt shortcuts (multimedia layer)
            left right prnt f10 f11 f12 pgup pgdn

            ;; actual 60% keyboard
            grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet rctl
          )

          (defalias
            ;; toggle layer aliases
            mmd (layer-toggle multimedia)
            rlt (tap-hold 200 200 ralt @mmd)

            ;; base layers
            bse (layer-switch base)
            nar (layer-switch numarrow) ;; number-arrow layer
          )

          (defalias
            ;; tap rshift to toggle between layers
            rsb (tap-hold-release 200 200 @bse rsft)
            rsa (tap-hold-release 200 200 @nar rsft)
          )

          (deflayer base
            _    _    _    _    _    _    _    _

            ;; actual kb
            grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    @rsa
            lctl lmet lalt           spc            @rlt rmet rctl
          )

          (deflayer numarrow
            _    _    _    _     _    _    _    _

            ;; actual kb
            _    _    _    _     _    _    _    kp7  kp8  kp9  _    _    _    _
            _    _    up   _     _    _    _    kp4  kp5  kp6  _    _    _    _
            _    left down right _    _    _    kp1  kp2  kp3  _    _    _
            _    _    _    _     _    _    nlk  kp0  _    _    _    @rsb
            _    _    _               _              @rlt _    _
          )

          (deflayer multimedia
            M-S-left M-S-right pp mute vold volu  prev next

            ;; actual kb
            _        _         _  _    _    _     _    _    _  _  _    _    _    _
            _        _         _  _    _    _     _    _    _  _  _    _    _    _
            _        _         _  _    _    _     _    _    _  _  _    _    _
            _        _         _  _    _    _     _    _    _  _  _    _
            _        _         _            _               _  _  _
          )
        '';
      };
    };
  };

  specialisation.on-the-go.configuration = {
    system.nixos.tags = ["on-the-go"];
    services.kanata.enable = lib.mkForce false;
  };

  systemd.user.services.kanata-osd = {
    enable = true;
    description = "Kanata OSD";
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${kanataOSD}/bin/kanata-osd";
      Restart = "always";
      RestartSec = "5";
    };
  };
}

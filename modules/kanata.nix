{ pkgs, lib, ... }: {
    boot.kernelModules = [ "uinput" ];
    hardware.uinput.enable = true;
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';
    users.groups.uinput = { };
    systemd.services.kanata-externalKeyboard.serviceConfig = {
        SupplementaryGroups = [
            "input"
            "uinput"
        ];
    };
    services.kanata = {
        enable = lib.mkDefault true;
        keyboards = {
            externalKeyboard = {
                devices = [
                    "/dev/input/by-path/pci-0000:00:14.0-usb-0:3:1.0-event-kbd"
                ];
                port = 55461;
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
        system.nixos.tags = [ "on-the-go" ];
        services.kanata.enable = lib.mkForce false;
    };
}
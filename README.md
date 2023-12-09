# Tizen-HA

This is a small, unofficial companion app written using [flutter-tizen](https://github.com/flutter-tizen/flutter-tizen) to control lights and switches using Home Assistant. To get started, install flutter-tizen and run `flutter-tizen build tpk --device-profile wearable --release` in the `tizenapp/` directory , then install it with `sdb install [tpk name]` after connecting your watch with SDB. This app is being approved on the samsung galaxy store and should probably be available in the next few months for easier installation.

## Supported devices

All devices supported by flutter-tizen should work with this app. This means your watch must be running Tizen 5.5 or above.

## File structure

The code for pairing is one simple python flask file contained in the `server/` directory. I am running it in a docker container. The flutter app itself is contained in `tizenapp/`

## Pairing

On the first run of this app, you will need to pair your watch. To do this, simply follow the instructions in the "config" menu on the watch app.

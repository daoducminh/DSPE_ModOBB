# Mod Don't Starve Pocket Edition using OBB file

## Installation
- Cloning this project.
- Downloading obb file (this project is based on `Don't Starve PE 1.14`, other versions aren't guaranteed)

## Modding

- Update file in `scripts` and `DLC0001/scripts` folders.
> Note: `DLC0001` is setting for Reign of Giants

- Open terminal in root folder. Run these scripts:
```console
foo@bar:~$ zip main.79.com.kleientertainment.doNotStarvePocket.obb /path/to/updated/file
```
For example, if you're updating `actions.lua`
```console
foo@bar:~$ zip main.79.com.kleientertainment.doNotStarvePocket.obb scripts/actions.lua
foo@bar:~$ zip main.79.com.kleientertainment.doNotStarvePocket.obb DLC0001/scripts/actions.lua
```

- Replace the obb file in your device under `Android/obb/com.kleientertainment.doNotStarvePocket`
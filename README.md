# Mod Don't Starve Pocket Edition using OBB file

## Installation
- Cloning this project.
- Downloading obb file.
> This project is based on `Don't Starve PE 1.17` for RoG, and `Don't Starve Shipwrecked 1.27` for SW, other versions aren't guaranteed.

## Getting Started

- Update file in `scripts` and `DLC0001/scripts` folders.
> Note: `DLC0001` is setting for Reign of Giants

- Open terminal in root folder. Run these scripts:
```console
foo@bar:~$ zip main.82.com.kleientertainment.doNotStarvePocket.obb /path/to/updated/file
```
For example, if you're updating `actions.lua`
```console
foo@bar:~$ zip main.82.com.kleientertainment.doNotStarvePocket.obb scripts/actions.lua
foo@bar:~$ zip main.82.com.kleientertainment.doNotStarvePocket.obb DLC0001/scripts/actions.lua
```

- Replace the obb file in your device under `Android/obb/com.kleientertainment.doNotStarvePocket`

## Example

1. Unlock all characters:

```lua
-- ./scripts/playerprofile.lua

function PlayerProfile:IsCharacterUnlocked(character)
	return true
end
```

2. Movement speed, charaters' statistics, etc ...:

```lua
-- ./scripts/tuning.lua
TUNING = {
    STACK_SIZE_LARGEITEM = 9999,
    STACK_SIZE_MEDITEM = 9999,
    STACK_SIZE_SMALLITEM = 9999,
}
```

3. Prepared food:

```lua
-- ./scripts/preparedfoods.lua
local foods = {
    ...
    meatballs =
	{
		test = function(cooker, names, tags) return tags.meat and not tags.inedible end,
		priority = -1,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*5,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = .75,
    },
    ...
}
```

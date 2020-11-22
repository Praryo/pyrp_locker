# pyrp_locker
ESX Praryo RP Locker Script (Inventory HUD Integrated)

### Requirements
------------

- [cron](https://github.com/ESX-Org/cron)
- [esx_addonaccount](https://github.com/ESX-Org/esx_addonaccount)
- [esx_addoninventory](https://github.com/ESX-Org/esx_addoninventory)
- [esx_datastore](https://github.com/ESX-Org/esx_datastore)
- [esx_inventoryhud 2.3+](https://github.com/Trsak/esx_inventoryhud)
- [mythic_notify](https://github.com/JayMontana36/mythic_notify)

### Intergrating Inventorys Tutorial

To integrate this script to esx_inventoryhud, first put the inventoryhud_ui_locker.lua in client folder of your inventory hud and rename it to locker.lua. Second add the locker.lua to the esx_inventoryhud fxmanifest.lua/__resource.lua

```
"client/main.lua",
"client/locker.lua",
```

### You need to send the NUI callback to the javascript. To do that, go to html/js/inventory.js and open it

### Find 

```

if (type === "normal") {
  $(".info-div").hide();
} else if (type === "trunk") {
  $(".info-div").show();
} else if (type === "property") {
  $(".info-div").hide();
}

```
  
### Add

```
if (type === "normal") {
  $(".info-div").hide();
} else if (type === "trunk") {
  $(".info-div").show();
} else if (type === "property") {
  $(".info-div").hide();
} else if (type === "locker") {
  $(".info-div").hide();
}
```

### Find

```
} else if (type === "player" && itemInventory === "second") {
  disableInventory(500);
  $.post("http://esx_inventoryhud/TakeFromPlayer", JSON.stringify({
    item: itemData,
    number: parseInt($("#count").val())
  }));
}
```

### Add

```
} else if (type === "player" && itemInventory === "second") {
  disableInventory(500);
  $.post("http://esx_inventoryhud/TakeFromPlayer", JSON.stringify({
    item: itemData,
    number: parseInt($("#count").val())
  }));
} else if (type === "locker" && itemInventory === "second") {
  disableInventory(500);
  $.post("http://esx_inventoryhud/TakeFromLocker", JSON.stringify({
    item: itemData,
    number: parseInt($("#count").val())
  }));
}
```

### Find

```
} else if (type === "player" && itemInventory === "main") {
  disableInventory(500);
  $.post("http://esx_inventoryhud/PutIntoPlayer", JSON.stringify({
    item: itemData,
    number: parseInt($("#count").val())
  }));
}
```

### Add

```
} else if (type === "player" && itemInventory === "main") {
  disableInventory(500);
  $.post("http://esx_inventoryhud/PutIntoPlayer", JSON.stringify({
    item: itemData,
    number: parseInt($("#count").val())
  }));
} else if (type === "locker" && itemInventory === "main") {
  disableInventory(500);
  $.post("http://esx_inventoryhud/PutIntoLocker", JSON.stringify({
    item: itemData,
    number: parseInt($("#count").val())
  }));
}
```
  
  
  
  
  
  
  

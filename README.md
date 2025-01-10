# Custom Font Installer

[![updated](https://img.shields.io/badge/Updated-Jan_11,_2025-green.svg)](https://github.com/nongthaihoang/custom_font_installer)
[![donate](https://img.shields.io/badge/Chat-Telegram-blue.svg)](https://t.me/ohmyfont)
[![download](https://img.shields.io/badge/Download-↓-yellow.svg)](https://github.com/nongthaihoang/custom_font_installer/raw/master/release/CFI.zip)
[![changelog](https://img.shields.io/badge/Changelog-↻-lightgrey.svg)](https://github.com/nongthaihoang/custom_font_installer/commits/master/)
[![donate](https://img.shields.io/badge/Donate-Paypal-pink.svg)](https://paypal.me/nongthaihoang)

## Description
CFI is a flash-able zip (based on [OMF](https://gitlab.com/nongthaihoang/omftemplate)) that allows installing custom fonts manually via Magisk/TWRP.

## Usage
### Static fonts
- Put your fonts in this path `Internal storage/OhMyFont/CFI`.
- For `sans-serif` font family (i.e. Roboto), rename your fonts as below:
  ```
  Black            -> ubl.ttf
  ExtraBold        -> ueb.ttf
  Bold             -> ub.ttf
  SemiBold         -> usb.ttf
  Medium           -> um.ttf
  Regular          -> ur.ttf
  Light            -> ul.ttf
  ExtraLight       -> uel.ttf
  Thin             -> ut.ttf

  BlackItalic      -> ibl.ttf
  ExtraBoldItalic  -> ieb.ttf
  BoldItalic       -> ib.ttf
  SemiBoldItalic   -> isb.ttf
  MediumItalic     -> im.ttf
  Italic           -> ir.ttf
  LightItalic      -> il.ttf
  ExtraLightItalic -> iel.ttf
  ThinItalic       -> it.ttf

  Condensed-Black            -> cbl.ttf
  Condensed-ExtraBold        -> ceb.ttf
  Condensed-Bold             -> cb.ttf
  Condensed-SemiBold         -> csb.ttf
  Condensed-Medium           -> cm.ttf
  Condensed-Regular          -> cr.ttf
  Condensed-Light            -> cl.ttf
  Condensed-ExtraLight       -> cel.ttf
  Condensed-Thin             -> ct.ttf

  Condensed-BlackItalic      -> dbl.ttf
  Condensed-ExtraBoldItalic  -> deb.ttf
  Condensed-BoldItalic       -> db.ttf
  Condensed-SemiBoldItalic   -> dsb.ttf
  Condensed-MediumItalic     -> dm.ttf
  Condensed-Italic           -> dr.ttf
  Condensed-LightItalic      -> dl.ttf
  Condensed-ExtraLightItalic -> del.ttf
  Condensed-ThinItalic       -> dt.ttf
  ```
- For `monospace`, rename to `mr.ttf`.
- For `emoji`, rename to `e.ttf`.
- For the rest, name your fonts the same as the ones that you want to replace in `/system/fonts`.
- Finally, flash the CFI zip and reboot.

### Variable fonts (VF)
All steps are the same as in static fonts. Except the followings.
- For `sans-serif`, rename VF to `ss.ttf` (upright) and `ssi.ttf` (italic).
- For `monospace`, rename VF to `ms.ttf`.
- Configure axes in the config file `OhMyFont/config.cfg`.

### Note
- You don't need to have all font files listed above, just use what available.
- For `sans-serif`, there must be at least one font `ur.ttf` or `ss.ttf`.
- If using VF, flash the CFI zip for the first time to get the default config file.
- For TWRP support, download the [TWRP](https://gitlab.com/nongthaihoang/oh_my_font/-/raw/master/extensions/twrp.zip) extension and extract it to `OhMyFont` folder.
- Be aware not every font will work properly on Android.

## Google Font Installer
- Download a font from [Google Fonts](https://fonts.google.com).
- Move the download font zip to `Internal storage/OhMyFont/`
- Set `GF = <font zip name>` in the config file `OhMyFont/config.cfg`.  
  E.g. The downloaded font zip is `Roboto_Condensed.zip` then `GF = Roboto_Condensed`.
- Only works with static fonts.

# Custom Font Installer
**Custom Font Installer for Android**

[![updated](https://img.shields.io/badge/Updated-Oct_17,_2021-green.svg)](https://github.com/nongthaihoang/custom_font_installer)
[![forum](https://img.shields.io/badge/Forum-XDA-orange.svg)](https://forum.xda-developers.com/t/module-oh-my-font-improve-android-typography.4215515) 
[![donate](https://img.shields.io/badge/Chat-Telegram-blue.svg)](https://t.me/ohmyfont)
[![download](https://img.shields.io/badge/Download-↓-yellow.svg)](https://github.com/nongthaihoang/custom_font_installer/raw/master/release/CFI.zip)
[![changelog](https://img.shields.io/badge/Changelog-↻-lightgrey.svg)](https://github.com/nongthaihoang/custom_font_installer/commits/master)
[![donate](https://img.shields.io/badge/Donate-Paypal-pink.svg)](https://paypal.me/nongthaihoang)

 
## Description
Install custom fonts manually via Magisk/TWRP (powered by [OMF](https://gitlab.com/nongthaihoang/omftemplate)).

## Usage
### Static fonts
- Put your fonts in `OhMyFont/CFI` folder.
- For `sans-serif` font family (i.e. Roboto), rename your fonts as below:
  ```
  BlackItalic      -> bli.ttf
  Black            -> bl.ttf
  ExtraBoldItalic  -> ebi.ttf
  ExtraBold        -> eb.ttf
  BoldItalic       -> bi.ttf
  Bold             -> b.ttf
  SemiBoldItalic   -> sbi.ttf
  SemiBold         -> sb.ttf
  MediumItalic     -> mi.ttf
  Medium           -> m.ttf
  Italic           -> i.ttf
  Regular          -> r.ttf
  LightItalic      -> li.ttf
  Light            -> l.ttf
  ExtraLightItalic -> eli.ttf
  ExtraLight       -> el.ttf
  ThinItalic       -> ti.ttf
  Thin             -> t.ttf

  Condensed-BlackItalic      -> cbli.ttf
  Condensed-Black            -> cbl.ttf
  Condensed-ExtraBoldItalic  -> cebi.ttf
  Condensed-ExtraBold        -> ceb.ttf
  Condensed-BoldItalic       -> cbi.ttf
  Condensed-Bold             -> cb.ttf
  Condensed-SemiBoldItalic   -> csbi.ttf
  Condensed-SemiBold         -> csb.ttf
  Condensed-MediumItalic     -> cmi.ttf
  Condensed-Medium           -> cm.ttf
  Condensed-Italic           -> ci.ttf
  Condensed-Regular          -> cr.ttf
  Condensed-LightItalic      -> cli.ttf
  Condensed-Light            -> cl.ttf
  Condensed-ExtraLightItalic -> celi.ttf
  Condensed-ExtraLight       -> cel.ttf
  Condensed-ThinItalic       -> cti.ttf
  Condensed-Thin             -> ct.ttf
  ```
- For `monospace`, rename to `mo.ttf`.
- For `emoji`, rename to `e.ttf`.
- For the rest, name your fonts the same as the ones that you want to replace in `/system/fonts`.
- Finally, flash the CFI zip and reboot.

### Variable fonts (VF)
All steps are the same as in static fonts. Only these are different.
- For `sans-serif`, rename VF to `ss.ttf` (uprights) and `ssi.ttf` (italics).
- For `monospace`, rename VF to `ms.ttf`.
- Configure axes in the config file `OhMyFont/config.cfg`.

### Note
- You don't need to have all font files listed above, just use what available.
- In case of `sans-serif`, there must be at least one font `r.ttf` or `ss.ttf`.
- If using VF, flash the CFI zip for the first time to get the default config file.
- For TWRP support, download [twrp](https://gitlab.com/nongthaihoang/oh_my_font/-/raw/master/extensions/twrp.zip) extension and extract to `OhMyFont` folder.
- Be aware that not every font will work on Android properly.

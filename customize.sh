[ ! $MAGISKTMP ] && MAGISKTMP=$(magisk --path)/.magisk
[ -d $MAGISKTMP ] && ORIGDIR=$MAGISKTMP/mirror
FONTDIR=/sdcard/CFI
SYSFONT=$MODPATH/system/fonts
PRDFONT=$MODPATH/system/product/fonts
SYSETC=$MODPATH/system/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop

backup() {
	local backup=/sdcard/cfi-backup.zip
	local backupdir=$TMPDIR/cfi-backup
	local zip=$MODPATH/zip
	chmod 755 $zip
	ui_print "- Backing up"
	mkdir -p $backupdir/system/fonts
	unzip -q $ZIPFILE -d $backupdir
	cp $FONTDIR/* $backupdir/system/fonts
	sed -i '/FONTDIR/d;9,24d;/backup/d' $backupdir/customize.sh
	cd $backupdir
	rm zip $backup
	$zip -q -9 $backup -r *
	rm $zip
}

rename() {
	set bli BlackItalic bl Black bi BoldItalic b Bold mi MediumItalic m Medium i Italic r Regular li LightItalic l Light ti ThinItalic t Thin mo Mono e Emoji
	for i do
		([ -f $SYSFONT/$1.ttf ] || [ -f $SYSFONT/$1.otf ]) && mv $SYSFONT/$1.[to]tf $SYSFONT/$2.ttf
		([ -f $SYSFONT/c$1.ttf ] || [ -f $SYSFONT/c$1.otf ]) && mv $SYSFONT/c$1.[to]tf $SYSFONT/Condensed-$2.ttf
		shift 2; [ $2 ] || break
	done
}

patch() {
	[ -f $ORIGDIR/system/etc/fonts.xml ] && cp $ORIGDIR/system/etc/fonts.xml $SYSXML || abort "! $ORIGDIR/system/etc/fonts.xml: file not found"
	sed -i '/"sans-serif">/,/family>/H;1,/family>/{/family>/G}' $SYSXML
	sed -i ':a;N;$!ba;s/name="sans-serif"//2' $SYSXML
	local count=0
	set BlackItalic Black BoldItalic Bold MediumItalic Medium Italic Regular LightItalic Light ThinItalic Thin
	for i do
		[ -f $SYSFONT/$i.ttf ] && { sed -i "/\"sans-serif\">/,/family>/s/Roboto-$i/$i/" $SYSXML; count=$((count + 1)); }
		[ -f $SYSFONT/Condensed-$i.ttf ] && { sed -i "s/RobotoCondensed-$i/Condensed-$i/" $SYSXML; count=$((count + 1)); }
	done
	[ -f $SYSFONT/Mono.ttf ] && { sed -i 's/DroidSans//' $SYSXML; count=$((count + 1)); }
	[ -f $SYSFONT/Emoji.ttf ] && { sed -i 's/NotoColor//;s/SamsungColor//' $SYSXML; count=$((count + 1)); }
	[ $count -eq 0 ] && rm $SYSXML
}

clean_up() {
	rm $MODPATH/LICENSE
	rmdir -p $SYSETC $PRDFONT
}

pixel() {
	local dest
	if [ -f $ORIGDIR/product/fonts/GoogleSans-Regular.ttf ] || [ -f $ORIGDIR/system/product/fonts/GoogleSans-Regular.ttf ]; then
		dest=$PRDFONT
	elif [ -f $ORIGDIR/system/fonts/GoogleSans-Regular.ttf ]; then
		dest=$SYSFONT
	fi
	if [ $dest ]; then
		set BoldItalic Bold MediumItalic Medium Italic Regular
		for i do cp $SYSFONT/$i.ttf $dest/GoogleSans-$i.ttf; done
		version pxl
	else
		false
	fi
}

oxygen() {
	if [ -f $ORIGDIR/system/fonts/SlateForOnePlus-Regular.ttf ]; then
		set Black Bold Medium Regular Light Thin
		for i do cp $SYSFONT/$i.ttf $SYSFONT/SlateForOnePlus-$i.ttf; done
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Book.ttf
		version oos
	else
		false
	fi
}

miui() {
	if grep -q miui $SYSXML; then
		set Black Bold Medium Regular Light Thin
		for i do
			if [ -f $SYSFONT/$i.ttf ]; then
				if [ $i = Black ]; then
					sed -i '/"mipro-bold"/,/family>/{/700/s/MiLanProVF/Black/;/stylevalue="700"/d}' $SYSXML
					sed -i '/"mipro-heavy"/,/family>/{/400/s/MiLanProVF/Black/;/stylevalue="700"/d}' $SYSXML
				elif [ $i = Bold ]; then
					sed -i '/"mipro"/,/family>/{/700/s/MiLanProVF/Bold/;/stylevalue="400"/d}' $SYSXML
					sed -i '/"mipro-medium"/,/family>/{/700/s/MiLanProVF/Bold/;/stylevalue="480"/d}' $SYSXML
					sed -i '/"mipro-demibold"/,/family>/{/700/s/MiLanProVF/Bold/;/stylevalue="540"/d}' $SYSXML
					sed -i '/"mipro-semibold"/,/family>/{/700/s/MiLanProVF/Bold/;/stylevalue="630"/d}' $SYSXML
					sed -i '/"mipro-bold"/,/family>/{/400/s/MiLanProVF/Bold/;/stylevalue="630"/d}' $SYSXML
				elif [ $i = Medium ]; then
					sed -i '/"mipro-regular"/,/family>/{/700/s/MiLanProVF/Medium/;/stylevalue="400"/d}' $SYSXML
					sed -i '/"mipro-medium"/,/family>/{/400/s/MiLanProVF/Medium/;/stylevalue="400"/d}' $SYSXML
					sed -i '/"mipro-demibold"/,/family>/{/400/s/MiLanProVF/Medium/;/stylevalue="480"/d}' $SYSXML
					sed -i '/"mipro-semibold"/,/family>/{/400/s/MiLanProVF/Medium/;/stylevalue="540"/d}' $SYSXML
				elif [ $i = Regular ]; then
					sed -i '/"mipro"/,/family>/{/400/s/MiLanProVF/Regular/;/stylevalue="340"/d}' $SYSXML
					sed -i '/"mipro-light"/,/family>/{/700/s/MiLanProVF/Regular/;/stylevalue="305"/d}' $SYSXML
					sed -i '/"mipro-normal"/,/family>/{/700/s/MiLanProVF/Regular/;/stylevalue="340"/d}' $SYSXML
					sed -i '/"mipro-regular"/,/family>/{/400/s/MiLanProVF/Regular/;/stylevalue="340"/d}' $SYSXML
				elif [ $i = Light ]; then
					sed -i '/"mipro-thin"/,/family>/{/700/s/MiLanProVF/Light/;/stylevalue="200"/d}' $SYSXML
					sed -i '/"mipro-extralight"/,/family>/{/700/s/MiLanProVF/Light/;/stylevalue="250"/d}' $SYSXML
					sed -i '/"mipro-light"/,/family>/{/400/s/MiLanProVF/Light/;/stylevalue="250"/d}' $SYSXML
					sed -i '/"mipro-normal"/,/family>/{/400/s/MiLanProVF/Light/;/stylevalue="305"/d}' $SYSXML
				elif [ $i = Thin ]; then
					sed -i '/"mipro-thin"/,/family>/{/400/s/MiLanProVF/Thin/;/stylevalue="150"/d}' $SYSXML
					sed -i '/"mipro-extralight"/,/family>/{/400/s/MiLanProVF/Thin/;/stylevalue="200"/d}' $SYSXML
				fi
			fi
		done
		version miui
	else
		false
	fi
}

lg() {
	local lg=false
	if grep -q lg-sans-serif $SYSXML; then
		sed -i '/"lg-sans-serif">/,/family>/{/"lg-sans-serif">/!d};/"sans-serif">/,/family>/{/"sans-serif">/!H};/"lg-sans-serif">/G' $SYSXML
		lg=true
	fi
	if [ -f $ORIGDIR/system/etc/fonts_lge.xml ]; then
		cp $ORIGDIR/system/etc/fonts_lge.xml $SYSETC
		local lgxml=$SYSETC/fonts_lge.xml
		set BlackItalic Black BoldItalic Bold MediumItalic Medium Italic Regular LightItalic Light ThinItalic Thin
		for i do [ -f $SYSFONT/$i.ttf ] && sed -i "/\"default_roboto\">/,/family>/s/Roboto-$i/$i/" $lgxml; done
		lg=true
	fi
	$lg && version lg || false
}

samsung() {
	if grep -q Samsung $SYSXML; then
		sed -i 's/SECRobotoLight-Bold/Medium/;s/SECRobotoLight-//;s/SECCondensed-/Condensed-/' $SYSXML
		version sam
	else
		false
	fi
}

rom() {
	pixel || oxygen || miui || lg || samsung
}

version() { sed -i 3"s/$/-$1&/" $MODPROP; }

### INSTALLATION ###
ui_print "- Installing"
mkdir -p $SYSFONT $SYSETC $PRDFONT
cp $FONTDIR/* $SYSFONT && chmod 644 $SYSFONT/* || abort "! $FONTDIR: no font found"
rename
patch
rom

### CLEAN UP ###
ui_print "- Cleaning up"
clean_up

backup

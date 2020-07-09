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
	local backupdir=$FONTDIR/backup
	local zip=$MODPATH/zip
	chmod 755 $zip
	ui_print "- Backing up"
	ui_print "   "
	mkdir -p $backupdir/fonts
	unzip -q $ZIPFILE -d $backupdir
	cd $backupdir
	cp ../* $backupdir/fonts
	sed -i 's/\/sdcard\/CFI/$MODPATH\/fonts/;9,27d;/backup/d;/clean_up/s/;/; rm -rf $FONTDIR;/' customize.sh
	rm zip $backup
	$zip -q -9 $backup -r *
	rm $zip
	cd $TMPDIR
	rm -rf $backupdir
}

rename() {
	mv $SYSFONT/bli.ttf $SYSFONT/BlackItalic.ttf
	mv $SYSFONT/bl.ttf $SYSFONT/Black.ttf
	mv $SYSFONT/bi.ttf $SYSFONT/BoldItalic.ttf
	mv $SYSFONT/b.ttf $SYSFONT/Bold.ttf
	mv $SYSFONT/mi.ttf $SYSFONT/MediumItalic.ttf
	mv $SYSFONT/m.ttf $SYSFONT/Medium.ttf
	mv $SYSFONT/i.ttf $SYSFONT/Italic.ttf
	mv $SYSFONT/r.ttf $SYSFONT/Regular.ttf
	mv $SYSFONT/li.ttf $SYSFONT/LightItalic.ttf
	mv $SYSFONT/l.ttf $SYSFONT/Light.ttf
	mv $SYSFONT/ti.ttf $SYSFONT/ThinItalic.ttf
	mv $SYSFONT/t.ttf $SYSFONT/Thin.ttf
	mv $SYSFONT/mo.ttf $SYSFONT/Mono.ttf
	mv $SYSFONT/e.ttf $SYSFONT/Emoji.ttf
}

patch() {
	[ -f $ORIGDIR/system/etc/fonts.xml ] && cp $ORIGDIR/system/etc/fonts.xml $SYSXML || abort "! $ORIGDIR/system/etc/fonts.xml: file not found"
	cp $ORIGDIR/system/etc/fonts.xml $SYSXML
	sed -i '/"sans-serif">/,/family>/H;1,/family>/{/family>/G}' $SYSXML
	sed -i ':a;N;$!ba;s/name="sans-serif"//2' $SYSXML
	local count=0
	set BlackItalic Black BoldItalic Bold MediumItalic Medium Italic Regular LightItalic Light ThinItalic Thin
	for i do
		[ -f $SYSFONT/$i.ttf ] && { sed -i "/"sans-serif">/,/family>/s/Roboto-$i/$i/" $SYSXML; count=$((count + 1)); }
		[ -f $SYSFONT/Condensed-$i.ttf ] && { sed -i "s/RobotoCondensed-$i/Condensed-$i/" $SYSXML; count=$((count + 1)); }
	done
	[ -f $SYSFONT/Mono.ttf ] && { sed -i 's/DroidSans//' $SYSXML; count=$((count + 1)); }
	[ -f $SYSFONT/Emoji.ttf ] && { sed -i 's/NotoColor//;s/SamsungColor//' $SYSXML; count=$((count + 1)); }
	[ $count -eq 0 ] && rm $SYSXML
	rmdir -p $SYSFONT && abort "font not found"
}

clean_up() { rmdir -p $SYSETC $PRDFONT; }

version() { sed -i 3"s/$/-$1&/" $MODPROP; }

pixel() {
	local dest
	if [ -f $ORIGDIR/product/fonts/GoogleSans-Regular.ttf ]; then
		dest=$PRDFONT
	elif [ -f $ORIGDIR/system/fonts/GoogleSans-Regular.ttf ]; then
		dest=$SYSFONT
	fi
	if [ $dest ]; then
		set BoldItalic Bold MediumItalic Medium Italic Regular
		for i do cp $SYSFONT/$i.ttf $dest/GoogleSans-$i.ttf; done
		version pxl; PXL=true
	fi
}

oxygen() {
	if [ -f $ORIGDIR/system/fonts/SlateForOnePlus-Regular.ttf ]; then
		set Black Bold Medium Regular Light Thin
		for i do cp $SYSFONT/$i.ttf $SYSFONT/SlateForOnePlus-$i.ttf; done
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Book.ttf
		version oos; OOS=true
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
		version miui; MIUI=true
	fi
}

lg() {
	if grep -q lg-sans-serif $SYSXML; then
		sed -i '/"lg-sans-serif">/,/family>/{/"lg-sans-serif">/!d};/"sans-serif">/,/family>/{/"sans-serif">/!H};/"lg-sans-serif">/G' $SYSXML
		LG=true
	fi
	if [ -f $ORIGDIR/system/etc/fonts_lge.xml ]; then
		cp $ORIGDIR/system/etc/fonts_lge.xml $SYSETC
		local lgxml=$SYSETC/fonts_lge.xml
		set BlackItalic Black BoldItalic Bold MediumItalic Medium Italic Regular LightItalic Light ThinItalic Thin
		for i do
			[ -f $SYSFONT/$i.ttf ] && sed -i "/\"default_roboto\">/,/family>/s/Roboto-$i/$i/" $lgxml
		done
		LG=true
	fi
	$LG && version lg
}

samsung() {
	if grep -q Samsung $SYSXML; then
		sed -i 's/SECRobotoLight-Bold/Medium/;s/SECRobotoLight-//;s/SECCondensed-/Condensed-/' $SYSXML
		version sam; SAM=true
	fi
}

rom() {
	PXL=false; OOS=false; MIUI=false; LG=false; SAM=false
	pixel
	if ! $PXL; then oxygen
		if ! $OOS; then miui
			if ! $MIUI; then lg
				if ! $LG; then samsung
				fi
			fi
		fi
	fi
}

### INSTALLATION ###
ui_print "   "
ui_print "- Installing"
mkdir -p $SYSFONT $SYSETC $PRDFONT
cp $FONTDIR/* $SYSFONT
rename
patch
rom

### CLEAN UP ###
ui_print "- Cleaning up"
clean_up

backup

ORIGDIR=/sbin/.magisk/mirror
FONTDIR=/sdcard/CustomFontInstaller
SYSFONT=$MODPATH/system/fonts
PRDFONT=$MODPATH/system/product/fonts
SYSETC=$MODPATH/system/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop

back_up() {
	BACKUP=/sdcard/cfi_backup.zip
	BACKUPDIR=$FONTDIR/backup
	ZIP=$MODPATH/zip
	ui_print "- Backing up"
	ui_print "   "
	mkdir -p $BACKUPDIR/fonts
	unzip -q $ZIPFILE -d $BACKUPDIR
	cd $BACKUPDIR
	cp ../* $BACKUPDIR/fonts
	sed -i 's/\/sdcard\/CustomFontInstaller/$MODPATH\/fonts/;8,25d;/back_up/d;/clean_up/s/;/; rm -rf $FONTDIR;/' common/install.sh
	rm zip $BACKUP
	$ZIP -q -9 $BACKUP -r *
	rm $ZIP
	cd $MODPATH
	rm -rf $BACKUPDIR
}

patch() {
	cp $ORIGDIR/system/etc/fonts.xml $SYSXML
	sed -i '/\"sans-serif\">/,/family>/H;1,/family>/{/family>/G}' $SYSXML
	sed -i ':a;N;$!ba;s/name=\"sans-serif\"//2' $SYSXML
	COUNT=0
	set BlackItalic Black BoldItalic Bold MediumItalic Medium Italic Regular LightItalic Light ThinItalic Thin
	for i do
		if [ -f $SYSFONT/$i.ttf ]; then
			sed -i "/\"sans-serif\">/,/family>/s/Roboto-$i/$i/" $SYSXML
			COUNT=$((COUNT + 1))
		fi
		if [ -f $SYSFONT/Condensed-$i.ttf ]; then
			sed -i "s/RobotoCondensed-$i/Condensed-$i/" $SYSXML
			COUNT=$((COUNT + 1))
	   	fi
	done
	if [ -f $SYSFONT/Mono.ttf ]; then
		sed -i 's/DroidSans//' $SYSXML
		COUNT=$((COUNT + 1))
	fi
	if [ -f $SYSFONT/Emoji.ttf ]; then
		sed -i 's/NotoColor//;s/SamsungColor//' $SYSXML
		COUNT=$((COUNT + 1))
	fi
	if [ $COUNT -eq 0 ]; then rm $SYSXML; fi
}

clean_up() { rmdir -p $SYSETC $PRDFONT $SYSFONT; }

pixel() {
	if [ -f $ORIGDIR/product/fonts/GoogleSans-Regular.ttf ]; then
		DST=$PRDFONT
	elif [ -f $ORIGDIR/system/fonts/GoogleSans-Regular.ttf ]; then
		DST=$SYSFONT
	fi
	if [ ! -z $DST ]; then
		cp $SYSFONT/Regular.ttf $DST/GoogleSans-Regular.ttf
		cp $SYSFONT/Italic.ttf $DST/GoogleSans-Italic.ttf
		cp $SYSFONT/Medium.ttf $DST/GoogleSans-Medium.ttf
		cp $SYSFONT/MediumItalic.ttf $DST/GoogleSans-MediumItalic.ttf
		cp $SYSFONT/Bold.ttf $DST/GoogleSans-Bold.ttf
		cp $SYSFONT/BoldItalic.ttf $DST/GoogleSans-BoldItalic.ttf
		sed -ie 3's/$/-pxl&/' $MODPROP
		PXL=true
	fi
}

oxygen() {
	if [ -f $ORIGDIR/system/fonts/SlateForOnePlus-Regular.ttf ]; then
		cp $SYSFONT/Black.ttf $SYSFONT/SlateForOnePlus-Black.ttf
		cp $SYSFONT/Bold.ttf $SYSFONT/SlateForOnePlus-Bold.ttf
		cp $SYSFONT/Medium.ttf $SYSFONT/SlateForOnePlus-Medium.ttf
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Regular.ttf
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Book.ttf
		cp $SYSFONT/Light.ttf $SYSFONT/SlateForOnePlus-Light.ttf
		cp $SYSFONT/Thin.ttf $SYSFONT/SlateForOnePlus-Thin.ttf
		sed -ie 3's/$/-oos&/' $MODPROP
		OOS=true
	fi
}

miui() {
	if i=$(grep miui $SYSXML); then
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
		sed -ie 3's/$/-miui&/' $MODPROP
		MIUI=true
	fi
}

lg() {
	if i=$(grep lg-sans-serif $SYSXML); then
		sed -i '/\"lg-sans-serif\">/,/family>/{/\"lg-sans-serif\">/!d};/\"sans-serif\">/,/family>/{/\"sans-serif\">/!H};/\"lg-sans-serif\">/G' $SYSXML
		LG=true
	fi
	if [ -f $ORIGDIR/system/etc/fonts_lge.xml ]; then
		cp $ORIGDIR/system/etc/fonts_lge.xml $SYSETC
		LGXML=$SYSETC/fonts_lge.xml
		set BlackItalic Black BoldItalic Bold MediumItalic Medium Italic Regular LightItalic Light ThinItalic Thin
		for i do
			if [ -f $SYSFONT/$i.ttf ]; then
				sed -i "/\"default_roboto\">/,/family>/s/Roboto-$i/$i/" $LGXML
			fi
		done
		LG=true
	fi
	if $LG; then sed -ie 3's/$/-lg&/' $MODPROP; fi
}

rom() {
	pixel
	if ! $PXL; then oxygen
		if ! $OOS; then miui
			if ! $MIUI; then lg
			fi
		fi
	fi
}

### INSTALLATION ###
ui_print "   "
ui_print "- Installing"

mkdir -p $SYSFONT $SYSETC $PRDFONT
cp $FONTDIR/* $SYSFONT
patch

PXL=false; OOS=false; MIUI=false; LG=false
rom

### CLEAN UP ###
ui_print "- Cleaning up"
clean_up

ui_print "   "
back_up

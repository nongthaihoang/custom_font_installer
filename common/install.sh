FONTDIR=/sdcard/CustomFontInstaller
SYSFONT=$MODPATH/system/fonts
PRDFONT=$MODPATH/system/product/fonts
SYSETC=$MODPATH/system/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop

patch() {
	cp $ORIGDIR/system/etc/fonts.xml $SYSXML
	cp $FONTDIR/* $SYSFONT
	sed -i '/\"sans-serif\">/i \
	<family name="sans-serif">\
		<font weight="100" style="normal">Roboto-Thin.ttf</font>\
		<font weight="100" style="italic">Roboto-ThinItalic.ttf</font>\
		<font weight="300" style="normal">Roboto-Light.ttf</font>\
		<font weight="300" style="italic">Roboto-LightItalic.ttf</font>\
		<font weight="400" style="normal">Roboto-Regular.ttf</font>\
		<font weight="400" style="italic">Roboto-Italic.ttf</font>\
		<font weight="500" style="normal">Roboto-Medium.ttf</font>\
		<font weight="500" style="italic">Roboto-MediumItalic.ttf</font>\
		<font weight="900" style="normal">Roboto-Black.ttf</font>\
		<font weight="900" style="italic">Roboto-BlackItalic.ttf</font>\
		<font weight="700" style="normal">Roboto-Bold.ttf</font>\
		<font weight="700" style="italic">Roboto-BoldItalic.ttf</font>\
	</family>' $SYSXML
	sed -i ':a;N;$!ba; s/name=\"sans-serif\"//2' $SYSXML
 	set BlackItalic Black BoldItalic Bold MediumItalic Medium Italic Regular LightItalic Light ThinItalic Thin
	for i do
			if [ -f $SYSFONT/$i.ttf ]; then
				sed -i "/\"sans-serif\">/,/family>/s/Roboto-$i/$i/" $SYSXML
				sed -i "s/NotoSerif-$i/$i/" $SYSXML
				sed -i "s/SourceSansPro-$i/$i/" $SYSXML
				if [ $i = MediumItalic ]; then sed -i "s/SourceSansPro-SemiBoldItalic/$i/" $SYSXML; fi
				if [ $i = Medium ]; then sed -i "s/SourceSansPro-SemiBold/$i/" $SYSXML; fi
			fi
			if [ -f $SYSFONT/Condensed-$i.ttf ]; then sed -i "s/RobotoCondensed-$i/Condensed-$i/" $SYSXML; fi
	done
	if [ -f $SYSFONT/Mono.ttf ]; then sed -i 's/DroidSans//' $SYSXML; fi
	if [ -f $SYSFONT/Emoji.ttf ]; then sed -i 's/NotoColor//' $SYSXML; fi
}

cleanup() {
	rmdir -p $SYSETC $PRDFONT
}

pixel() {
	if [ -f /product/fonts/GoogleSans-Regular.ttf ]; then
		DEST=$PRDFONT
	elif [ -f /system/fonts/GoogleSans-Regular.ttf ]; then
		DEST=$SYSFONT
	fi
	if [ ! -z $DEST ]; then
		cp $SYSFONT/Regular.ttf $DEST/GoogleSans-Regular.ttf
		cp $SYSFONT/Italic.ttf $DEST/GoogleSans-Italic.ttf
		cp $SYSFONT/Medium.ttf $DEST/GoogleSans-Medium.ttf
		cp $SYSFONT/MediumItalic.ttf $DEST/GoogleSans-MediumItalic.ttf
		cp $SYSFONT/Bold.ttf $DEST/GoogleSans-Bold.ttf
		cp $SYSFONT/BoldItalic.ttf $DEST/GoogleSans-BoldItalic.ttf
		sed -ie 3's/$/-pxl&/' $MODPROP
		PXL=true
	fi
}

oxygen() {
	if [ -f /system/fonts/SlateForOnePlus-Regular.ttf ]; then
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
					sed -i '/\"mipro-bold\"/,/family>/{/700/,/>/s/MiLanProVF/Black/;/stylevalue=\"700\"/d}' $SYSXML
					sed -i '/\"mipro-heavy\"/,/family>/{/400/,/>/s/MiLanProVF/Black/;/stylevalue=\"700\"/d}' $SYSXML
				elif [ $i = Bold ]; then
					sed -i '/\"miui\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"400\"/d}' $SYSXML
					sed -i '/\"miui-bold\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"480\"/d}' $SYSXML
					sed -i '/\"mipro\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"400\"/d}' $SYSXML
					sed -i '/\"mipro-medium\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"480\"/d}' $SYSXML
					sed -i '/\"mipro-demibold\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"540\"/d}' $SYSXML
					sed -i '/\"mipro-semibold\"/,/family>/{/700/,/>/s/MiLanProVF/Bold/;/stylevalue=\"630\"/d}' $SYSXML
					sed -i '/\"mipro-bold\"/,/family>/{/400/,/>/s/MiLanProVF/Bold/;/stylevalue=\"630\"/d}' $SYSXML
				elif [ $i = Medium ]; then
					sed -i '/\"miui-regular\"/,/family>/{/700/,/>/s/MiLanProVF/Medium/;/stylevalue=\"400\"/d}' $SYSXML
					sed -i '/\"miui-bold\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/stylevalue=\"400\"/d}' $SYSXML
					sed -i '/\"mipro-regular\"/,/family>/{/700/,/>/s/MiLanProVF/Medium/;/stylevalue=\"400\"/d}' $SYSXML
					sed -i '/\"mipro-medium\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/stylevalue=\"400\"/d}' $SYSXML
					sed -i '/\"mipro-demibold\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/stylevalue=\"480\"/d}' $SYSXML
					sed -i '/\"mipro-semibold\"/,/family>/{/400/,/>/s/MiLanProVF/Medium/;/stylevalue=\"540\"/d}' $SYSXML
				elif [ $i = Regular ]; then
					sed -i '/\"miui\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
					sed -i '/\"miui-light\"/,/family>/{/700/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
					sed -i '/\"miui-regular\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
					sed -i '/\"mipro\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
					sed -i '/\"mipro-light\"/,/family>/{/700/,/>/s/MiLanProVF/Regular/;/stylevalue=\"305\"/d}' $SYSXML
					sed -i '/\"mipro-normal\"/,/family>/{/700/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
					sed -i '/\"mipro-regular\"/,/family>/{/400/,/>/s/MiLanProVF/Regular/;/stylevalue=\"340\"/d}' $SYSXML
				elif [ $i = Light ]; then
					sed -i '/\"miui-thin\"/,/family>/{/700/,/>/s/MiLanProVF/Light/;/stylevalue=\"250\"/d}' $SYSXML
					sed -i '/\"miui-light\"/,/family>/{/400/,/>/s/MiLanProVF/Light/;/stylevalue=\"250\"/d}' $SYSXML
					sed -i '/\"mipro-thin\"/,/family>/{/700/,/>/s/MiLanProVF/Light/;/stylevalue=\"200\"/d}' $SYSXML
					sed -i '/\"mipro-extralight\"/,/family>/{/700/,/>/s/MiLanProVF/Light/;/stylevalue=\"250\"/d}' $SYSXML
					sed -i '/\"mipro-light\"/,/family>/{/400/,/>/s/MiLanProVF/Light/;/stylevalue=\"200\"/d}' $SYSXML
					sed -i '/\"mipro-normal\"/,/family>/{/400/,/>/s/MiLanProVF/Light/;/stylevalue=\"305\"/d}' $SYSXML
				elif [ $i = Thin ]; then
					sed -i '/\"miui-thin\"/,/family>/{/400/,/>/s/MiLanProVF/Thin/;/stylevalue=\"150\"/d}' $SYSXML
					sed -i '/\"mipro-thin\"/,/family>/{/400/,/>/s/MiLanProVF/Thin/;/stylevalue=\"150\"/d}' $SYSXML
					sed -i '/\"mipro-extralight\"/,/family>/{/400/,/>/s/MiLanProVF/Thin/;/stylevalue=\"200\"/d}' $SYSXML
				fi
			fi
		done
		sed -ie 3's/$/-miui&/' $MODPROP
		MIUI=true
	fi
}

rom() {
	pixel
	if ! $PXL; then oxygen
		if ! $OOS; then miui
		fi
	fi
}

### INSTALLATION ###
ui_print "   "
ui_print "- Installing"

mkdir -p $SYSFONT $SYSETC $PRDFONT
patch

PXL=false; OOS=false; MIUI=false
rom

### CLEAN UP ###
ui_print "- Cleaning up"
cleanup

ui_print "   "

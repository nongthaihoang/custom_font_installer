# CFI Google Font Installer Extension
# 2021/10/29

# Download and install Google Fonts easily.
#
# Only for sans-serif font family. Steps:
# 1. Visit: https://fonts.google.com/?category=Sans+Serif
# 2. Select a font, copy its name.
# 3. Add GF=<fontname>, e.g, GF=Open Sans, to the config file.
# 4. Flash CFI zip and reboot.
#
# If it failed to download the font, you can download it from Google Fonts manually,
# move the downloaded font zip to OMF dir and reflash CFI.
#
# After installing, downloaded font zips are saved to OMF dir.
# Font files are backup to CFI folder.


[ -f $CFI/ur.[to]tf -o -f $CFI/r.[to]tf -o -f $CFI/$Re.[to]tf -o -f $CFI/ss$X ] && {
    ui_print "! Fonts exist in $CFI. Do nothing"
    return
}
[ "${GF:=`valof GF`}" ] && [ -d $CFI ] || return
ui_print "+ Google Font Installer"
local family=`echo $GF | sed 's| |%20|g'`
local font=`echo $GF | sed 's| ||g'`
local link="https://fonts.google.com/download?family=$family"
local zipfile=`echo $GF | sed 's| |_|g'`.zip
local zip=$OMFDIR/$zipfile
local time=`valof GF_timeout`; [ ${time:=30} ]
[ -f $zip ] && unzip -l $zip >/dev/null || {
    ui_print "+ Downloading $font (${time}s timeout)"
    ui_print "  $link"
    wget --spider --no-check-certificate $link || {
        ui_print "! $GF: no font match, make sure font name is correct"
        return
    }
    timeout $time $MAGISKBIN/busybox wget --no-check-certificate -O $zip $link || {
        ui_print "! Download failed"
        ui_print "  Please download the font manually from the above link or Google Fonts"
        ui_print "  And move/rename to $zip"
        ui_print "  Then try again"
        return
    }
}
ui_print "  Extracting $zipfile"
unzip -q $zip -d $FONTS
ui_print "  Installling $font"
rm $CFI/*
set bl $Bl eb $EBo b $Bo sb $SBo m $Me r $Re l $Li el $ELi t $Th
while [ $2 ]; do
    find $FONTS -type f -name "$font*\_$Cn$2$X" -exec mv -n {} $FONTS/c$1$X \;
    find $FONTS -type f -name "$font*-$2$X" ! \( -name "*$Cn*" -o -name "*Expanded-*" \) \
        -exec mv -n {} $FONTS/u$1$X \;
    find $FONTS -type f -name "$font-$2$X" -exec mv -n {} $FONTS/u$1$X \;
    cp $FONTS/[uc]$1$X $CFI
    shift 2
done
set bl $Bl$It eb $EBo$It b $Bo$It sb $SBo$It m $Me$It r $It l $Li$It el $ELi$It t $Th$It
while [ $2 ]; do
    find $FONTS -type f -name "$font*\_$Cn$2$X" -exec mv -n {} $FONTS/d$1$X \;
    find $FONTS -type f -name "$font*-$2$X" ! \( -name "*$Cn*" -o -name "*Expanded-*" \) \
        -exec mv -n {} $FONTS/i$1$X \;
    find $FONTS -type f -name "$font-$2$X" -exec mv -n {} $FONTS/i$1$X \;
    cp $FONTS/[id]$1$X $CFI
    shift 2
done
install_font
[ -f $SYSFONT/$Re$X ] && {
    ui_print "  $font has been installed successfully!"
    ui_print "  and backup to $CFI"
    ver gfi
} || {
    ui_print "! Failed: there is no Regular font style"
    abort "  Please rename fonts manually in $CFI"
}

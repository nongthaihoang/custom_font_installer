. $MODPATH/ohmyfont.sh

### INSTALLATION ###

ui_print '- Installing'

ui_print '+ Prepare'
prep; $FB

ui_print '+ Configure'
config

ui_print '+ Font'
mkdir $FONTS ${CFI:=$OMFDIR/CFI}
cp $CFI/*.[to]tf $FONTS || ui_print "! $CFI: font not found"
[ -f $FONTS/$SS ] || SS=
[ -f $FONTS/$SSI ] || SSI=$SS
[ -f $FONTS/$MS ] || MS=
install_font
false | cp -i $FONTS/*.[to]tf $SYSFONT
$SANS || rm $SYSXML

src

$SANS && {
    ui_print '+ Rom'
    rom
}

bold
finish

[ -d $SYSFONT ] || abort "! No font installed"

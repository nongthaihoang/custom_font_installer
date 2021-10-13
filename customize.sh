. $MODPATH/ohmyfont.sh

### INSTALLATION ###

ui_print '- Installing'

ui_print '+ Prepare'
prep; $FB

ui_print '+ Configure'
config

ui_print '+ Font'
mkdir $FONTS
cp ${CFI:=$OMFDIR/CFI}/* $FONTS || ui_print "! $CFI: font not found"
[ -f $FONTS/$SS ] || SS=
[ -f $FONTS/$SSI ] || SSI=$SS
[ -f $FONTS/$MS ] || MS=
install_font

src

ui_print '+ Rom'
rom

bold
finish

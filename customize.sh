. $MODPATH/ohmyfont.sh

gfi_dl() {
    local family=`echo $@ | sed 's| |%20|g'`
    font=`echo $@ | sed 's| ||g'`
    local link="https://fonts.google.com/download?family=$family"
    local zipfile=`echo $@ | sed 's| |_|g'`.zip
    local zip=$OMFDIR/$zipfile
    local time=`valof GF_timeout`; [ ${time:=30} ]
    [ -f $zip ] && unzip -l $zip >/dev/null || {
        ui_print "  Downloading $font (${time}s timeout)"
        ui_print "  $link"
        wget --spider --no-check-certificate $link || {
            ui_print "! $@: no font match, make sure font name is correct"
            return
        }
        timeout $time $MAGISKBIN/busybox wget --no-check-certificate -O $zip $link || {
            ui_print "! Download failed"
            ui_print "  Please download the font manually from the link above or Google Fonts"
            abort "  Then move/rename the downloaded font to $zip"
        }
    }
    ui_print "  Extracting $zipfile"
    unzip -q $zip -d $gfidir
}

gfi_ren() {
    local fa=${1:-$SA} i
    case $fa in $SA) i=u ;; $SC) i=c ;; $SE) i=s ;; $MO) i=m ;; $SO) i=o ;; esac
    set bl $Bl eb $EBo b $Bo sb $SBo m $Me r $Re l $Li el $ELi t $Th
    while [ $2 ]; do
        [ $i = u ] && {
            $find $gfidir -type f -name "$font*\_$Cn$2$X" -exec mv -n {} $CFI/c$1$X \;
            cp $CFI/c$1$X $CFI
        }
        find $gfidir -type f -name "$font*-$2$X" ! \( -name "*$Cn*" -o -name "*Expanded-*" \) \
            -exec mv -n {} $CFI/$i$1$X \;
        find $gfidir -type f -name "$font-$2$X" -exec mv -n {} $CFI/$i$1$X \;
        cp $CFI/$i$1$X $CFI
        shift 2
    done
    case $fa in $SA) i=i ;; $SC) i=d ;; $SE) i=t ;; $MO) i=n ;; $SO) i=p ;; esac
    set bl $Bl$It eb $EBo$It b $Bo$It sb $SBo$It m $Me$It r $It l $Li$It el $ELi$It t $Th$It
    while [ $2 ]; do
        [ $i = i ] && {
            find $gfidir -type f -name "$font*\_$Cn$2$X" -exec mv -n {} $CFI/d$1$X \;
            cp $CFI/d$1$X $CFI
        }
        find $gfidir -type f -name "$font*-$2$X" ! \( -name "*$Cn*" -o -name "*Expanded-*" \) \
            -exec mv -n {} $CFI/$i$1$X \;
        find $gfidir -type f -name "$font-$2$X" -exec mv -n {} $CFI/$i$1$X \;
        cp $CFI/$i$1$X $CFI
        shift 2
    done
    [ $gfidir ] && rm -rf $gfidir/*
}

gfi() {
    $SANS || $SERF || $MONO || $SRMO || return
    GF=`valof GF` GF_condensed=`valof GF_condensed` GF_mono=`valof GF_mono`
    GF_serif=`valof GF_serif` GF_serif_mono=`valof GF_serif_mono`
    [ "$GF" ] || [ "$GF_mono" ] || [ "$GF_serif" ] || [ "$GF_serif_mono" ] && \
    [ -d $CFI ] || return

    ui_print "+ Google Font Installer"
    local font gfidir=$FONTS/gfi; mkdir $gfidir

    $SANS && {
        [ "$GF" ] && {
            ui_print "> Sans Serif"
            [ -f $CFI/ur.[to]tf -o  -f $CFI/$Re.[to]tf -o -f $CFI/ss$X ] && {
                ui_print "  Fonts exist in $CFI. Do nothing!"
            } || {
                gfi_dl $GF
                ui_print "  Preparing $font"
                gfi_ren $SA
                [ -f $CFI/ur$X ] && {
                    ui_print "  $font has been saved to $CFI!"
                } || {
                    ui_print "! Failed: there is no Regular font style"
                    abort "  Please rename fonts manually in $CFI"
                }
            }
        }
        [ "$GF_condensed" ] && {
            ui_print "> Sans Serif Condensed"
            [ -f $CFI/cr.[to]tf -o  -f $CFI/$Cn$Re.[to]tf ] && {
                ui_print "  Fonts exist in $CFI. Do nothing!"
             || {
                gfi_dl $GF_condensed
                ui_print "  Preparing $font"
                gfi_ren $SC
                [ -f $CFI/cr$X ] && {
                    ui_print "  $font has been saved to $CFI!"
                } || {
                    ui_print "! Failed: there is no Regular font style"
                    abort "  Please rename fonts manually in $CFI"
                }
            }
        }
    }

    $MONO && [ "$GF_mono" ] && {
        ui_print "> Monospace"
        [ -f $CFI/mr.[to]tf -o  -f $CFI/$Mo$Re.[to]tf -o -f $CFI/ms$X ] && {
            ui_print "  Fonts exist in $CFI. Do nothing!"
        } || {
            gfi_dl $GF_mono
            ui_print "  Preparing $font"
            gfi_ren $MO
            [ -f $CFI/mr$X ] && {
                ui_print "  $font has been saved to $CFI!"
            } || {
                ui_print "! Failed: there is no Regular font style"
                abort "  Please rename fonts manually in $CFI"
            }
        }
    }

    $SERF && [ "$GF_serif" ] && {
        ui_print "> Serif"
        [ -f $CFI/sr.[to]tf -o  -f $CFI/$Se$Re.[to]tf -o -f $CFI/ser$X ] && {
            ui_print "  Fonts exist in $CFI. Do nothing!"
        } || {
            gfi_dl $GF_serif
            ui_print "  Preparing $font"
            gfi_ren $SE
            [ -f $CFI/sr$X ] && {
                ui_print "  $font has been saved to $CFI!"
            } || {
                ui_print "! Failed: there is no Regular font style"
                abort "  Please rename fonts manually in $CFI"
            }
        }
    }

    $SRMO && [ "$GF_serif_mono" ] && {
        ui_print "> Serif Monospace"
        [ -f $CFI/or.[to]tf -o  -f $CFI/$So$Re.[to]tf -o -f $CFI/srm$X ] && {
            ui_print "  Fonts exist in $CFI. Do nothing!"
        } || {
            gfi_dl $GF_serif_mono
            ui_print "  Preparing $font"
            gfi_ren $SO
            [ -f $CFI/or$X ] && {
                ui_print "  $font has been saved to $CFI!"
            } || {
                ui_print "! Failed: there is no Regular font style"
                abort "  Please rename fonts manually in $CFI"
            }
        }
    }

    ver gfi
}

### INSTALLATION ###

ui_print '- Installing'

ui_print '+ Prepare'
prep

ui_print '+ Configure'
config

mkdir $FONTS ${CFI:=$OMFDIR/CFI}
gfi
ui_print '+ Font'
cp $CFI/*.[to]tf $FONTS || ui_print "! $CFI: no font found"
[ -f $FONTS/$SS ] || SS=
[ -f $FONTS/`valof SSI` ] || { [ "`valof IR`" ] && SSI=$SS; } || SSI=
[ -f $FONTS/$MS ] || MS=; [ -f $FONTS/$MSI ] || MSI=
[ -f $FONTS/$SER ] || SER=; [ -f $FONTS/$SERI ] || SERI=
[ -f $FONTS/$SRM ] || SRM=; [ -f $FONTS/$SRMI ] || SRMI=
ORISS=$SS ORISSI=$SSI ORISER=$SER  ORISERI=$SERI
ORIMS=$MS ORIMS=$MSI ORISRM=$SRM  ORISRMI=$SRMI
install_font
false | cp -i $FONTS/*.[to]tf $SYSFONT
$SANS || $SERF || $MONO || $SRMO || $EMOJ || rm $SYSXML

src

ui_print '+ Rom'
rom

bold
finish

[ -d $SYSFONT ] || abort "! No font installed"

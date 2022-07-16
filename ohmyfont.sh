# Oh My Font Template
# by nongthaihoang @ GitLab

# enable debugging mode
set -xv

# Magisk and TWRP support
[ -d ${MAGISKTMP:=`magisk --path`/.magisk} ] && \
      ORIDIR=$MAGISKTMP/mirror

# Original paths
[ -d ${ORIPRD:=$ORIDIR/product} ] || \
      ORIPRD=$ORIDIR/system/product
[ -d ${ORISYSEXT:=$ORIDIR/system_ext} ] || \
   ORISYSEXT=$ORIDIR/system/system_ext

      ORISYS=$ORIDIR/system
  ORIPRDFONT=$ORIPRD/fonts
   ORIPRDETC=$ORIPRD/etc
   ORIPRDXML=$ORIPRDETC/fonts_customization.xml
  ORISYSFONT=$ORISYS/fonts
   ORISYSETC=$ORISYS/etc
ORISYSEXTETC=$ORISYSEXT/etc
   ORISYSXML=$ORISYSETC/fonts.xml

# Modules paths
         SYS=$MODPATH/system
         PRD=$SYS/product
     PRDFONT=$PRD/fonts
      PRDETC=$PRD/etc
      PRDXML=$PRDETC/fonts_customization.xml
     SYSFONT=$SYS/fonts
      SYSETC=$SYS/etc
      SYSEXT=$SYS/system_ext
   SYSEXTETC=$SYSEXT/etc
      SYSXML=$SYSETC/fonts.xml
     MODPROP=$MODPATH/module.prop
       FONTS=$MODPATH/fonts
       TOOLS=$MODPATH/tools

        SERV=$MODPATH/service.sh
        POST=$MODPATH/post-fs-data.sh
        UNIN=$MODPATH/uninstall.sh

      OMFDIR=/sdcard/OhMyFont
      OMFVER=`grep ^omfversion= $MODPROP | sed 's|.*=||'`
      
# abbr. vars
     SysFont=/system/fonts
      SysXml=/system/etc/fonts.xml
        Null=/dev/null

# create module paths
mkdir -p $PRDFONT $PRDETC $SYSFONT $SYSETC $SYSEXTETC $FONTS $TOOLS $OMFDIR

# extract data
SH=$MODPATH/ohmyfont.sh
tail -n +$((`grep -an ^PAYLOAD:$ $SH | cut -d : -f 1`+1)) $SH | tar xJf - -C $MODPATH || abort
tar xf $MODPATH/*xz -C $MODPATH &>$Null
rm $SH

# placebo for afdko - print error if not installed
afdko() {
    [ $1 ] && ui_print '! The AFDKO extension is required!'
    false
}

# append text to the end of version string
ver() { sed -i "/^version=/s|$|-$1|" $MODPROP; }

# shortcut for sed fontxml
xml() {
    [ ${XML:=$SYSXML} ]
    case $XML_LIST in
        *$XML*) ;;
            # remove comments
        *)  sed -i '/^[[:blank:]]*<!--.*-->/d;/<!--/,/-->/d' $XML
            # change single quote to double quotes
            sed -i "s|'|\"|g" $XML
            # cut one line <font> tag to new lines
            sed -i "/<$F .*>/s|>|\n&|" $XML
            # merge multiple lines <font> tag into one line
            sed -i "/[[:blank:]]<$F/{:a;N;/>/!ba;s|\n||g}" $XML
            # cut <\font> tag to new line
            sed -i "/<$F.*$FE/s|$FE|\n&|" $XML
            # merge 2 lines <font> tag to one line
            sed -i "/<$F .*>$/{N;s|\n||}" $XML
            # join <\font> to <font> line if any
            sed -i "/<$F /{N;s|\n$FE|$FE|}" $XML
            # water mark
            sed -i "2i<!-- OMF v$OMFVER -->\n" $XML
            # save the font xml paths to xml list
            XML_LIST="$XML $XML_LIST" ;;
    esac
    sed -i "$@" $XML
}

# lowercase to uppercase
up() { echo $@ | tr [:lower:] [:upper:]; }

# Exucute extension scripts, 3 stages:
# 1: script names starts in 0
# 2: script names starts in 1-8
# 3: script names starts in 9
src() {
    local l=`find $OMFDIR -maxdepth 1 -type f -name '*.sh' -exec basename {} \; | sort`
    if   [ "$1" = 0 ]; then l=`echo "$l" | grep '^0'`
    elif [ "$1" = 9 ]; then l=`echo "$l" | grep '^9'`
    else                    l=`echo "$l" | grep '^[^09]'`; fi
    local i
    for i in $l; do ui_print "+ Source $i"
        . $OMFDIR/$i
    done
}

# custom services support in $OMFDIR
svc() {
    local omfserv=$OMFDIR/service.d/*.sh
    local omfpost=$OMFDIR/post-fs-data.d/*.sh
    local omfunin=$OMFDIR/uninstall.d/*.sh

    # check for any custom service scripts
    ls $omfserv &>$Null || \
    ls $omfpost &>$Null || \
    ls $omfunin &>$Null && {
        ui_print '+ Services'

        # service.d
        ls $omfserv &>$Null && {
            echo 'MODDIR=${0%/*}' >> $SERV
            for i in $omfserv; do
                cp $i $MODPATH
                i=`basename $i`
                chmod +x $MODPATH/$i
                echo "\$MODDIR/$i &" >> $SERV
                ui_print "  $i"
            done
        }

        # post-fs-data.d
        ls $omfpost &>$Null && {
            echo 'MODDIR=${0%/*}' >> $POST
            for i in $omfpost; do
                cp $i $MODPATH
                i=`basename $i`
                chmod +x $MODPATH/$i
                echo "\$MODDIR/$i" >> $POST
                ui_print "  $i"
            done
        }

        # uninstall.d
        ls $omfunin &>$Null && {
            echo 'MODDIR=${0%/*}' >> $UNIN
            for i in $omfunin; do
                cp $i $MODPATH
                i=`basename $i`
                chmod +x $MODPATH/$i
                echo "\$MODDIR/$i &" >> $UNIN
                ui_print "  $i"
            done
        }
    }
}

# cp files from $FONT to $SYSFONT, do not overwrite
cpf() {
    [ $# -eq 0 ] && return 1
    local i
    for i in $@; do
        false | cp -i $FONTS/$i ${CPF:=$SYSFONT} &>$Null
    done
}

# Roms i.e. Pixels need to be detected for advanced functions
romprep() {
    src 0
    [ -f $ORIPRDFONT/$GSR ] && grep -q $Gs $ORIPRDXML && \
        PXL=true
}

rom() {
    # Some ROMs are detected as Pixel but they are fake ones.
    # The PXL=false option is to circumvent this situation
    local pxl=`valof PXL`
    [ $PXL ] && [ "$pxl" = false ] && PXL=

    # inject GSVF into fontxml
    $SANS && [ $GS = false -o $GS = $SE ] && {
        local fa=$Gs.* xml=$FONTS/gsvf.xml m=verdana
        xml "/$m/r $xml"
        # Disable gms font service. Thanks to @MrCarb0n's discovery.
        $BOOTMODE && (
            gms=com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider
            pm disable $gms &>$Null
            echo "( sleep 60; pm enable $gms ) &" >> $UNIN
        )
        [ $PXL ] || {
            # VF
            [ $SS ] && {
                local up=$SS it=$SSI
                fontinst r m sb b
            } || {
                # Static
                set $Bo$It bi $Bo b $SBo$It sbi $SBo sb $Me$It mi $Me m $Re r $It ri
                while [ $2 ]; do
                    # manually use font() instead of fontinst() to replace all GS
                    eval "[ $"$1" ] && font $fa $"$1$X" $2"
                    shift 2
                done
            }
        }
    }

    falias source-sans-pro
    roms
    # source extension - 9 (3rd stage)
    src 9
}

roms() {
    # Pixel
    [ $PXL ] && {
        ver pxl
        ! $GS && $SANS || return
        cp $ORIPRDXML $PRDXML
        local XML=$PRDXML fa=$Gs.* i

        # remove GS from PRDXML
        $SANS && [ $GS = false -o $GS = $SE ] && {
            xml "/$FA.*$fa/,${FAE}d"
            XML=
        }

        [ $SS ] && {
            local up=$SS it=$SSI
            fontinst r m sb b

            $STATIC && ln -s $SysFont/$SSS $PRDFONT/$GSR || \
                ln -s $SysFont/$SS $PRDFONT/$GSR
            return
        }

        set $Bo$It bi $Bo b $SBo$It sbi $SBo sb $Me$It mi $Me m $Re r $It ri
        while [ $2 ]; do
            eval [ $"$1" ] && eval font $fa $"$1$X" $2
            shift 2
        done
        eval "[ $"$Re" ] && ln -s $SysFont/$"$Re$X" $PRDFONT/$GSR"
        return
    }

    # OOS11 (basexml)
    [ -f $ORISYSETC/fonts_base.xml ] && {
        cp $SYSXML $SYSETC/fonts_base.xml
        OOS11=true; ver basexml; return
    }

    # COS11/OOS12 (basexml)
    [ -f $ORISYSEXTETC/fonts_base.xml ] && {
        cp $SYSXML $SYSEXTETC/fonts_base.xml
        COS=true; ver xbasexml; return
    }

    # OOS10 (slatexml)
    [ -f $ORISYSETC/fonts_slate.xml ] && {
        cp $SYSXML $SYSETC/fonts_slate.xml
        OOS=true; ver slatexml; return
    }

    # MIUI
    grep -q MIUI $ORISYSXML && {
        ver miui; [ $API -eq 29 ] && return; $SANS || return
        MIUI=`sed -n "/$FA.*\"miui\"/,$FAE{/400.*$N/{s|.*>||;p}}" $SYSXML`

        [ -f $ORISYSFONT/$MIUI ] && ln -s $X $SYSFONT/$MIUI
        [ -f $ORISYSFONT/RobotoVF$X ] && ln -s $X $SYSFONT/RobotoVF$X
        return
    }

    # Samsung
    grep -q Samsung $ORISYSXML && {
        SAM=true; ver sam; $SANS || return
        [ $SS ] && {
            fontab sec-roboto-light $SS r
            fontab sec-roboto-light $SS b M
            fontab sec-roboto-condensed $SS r
            fontab sec-roboto-condensed $SS b
            fontab sec-roboto-condensed-light $SS r L
            return
        }
        eval "[ $"$Re" ] && font sec-roboto-light $"$Re$X" r"
        eval "[ $"$Me" ] && font sec-roboto-light $"$Me$X" b"
        eval "[ $"${Cn%?}$Re" ] && font sec-roboto-condensed $"${Cn%?}$Re$X" r"
        eval "[ $"${Cn%?}$Bo" ] && font sec-roboto-condensed $"${Cn%?}$Bo$X" b"
        eval "[ $"${Cn%?}$Li" ] && font sec-roboto-condensed-light $"${Cn%?}$Li$X" r"
        return
    }

    # LG
    local lg=lg-sans-serif
    grep -q $lg $SYSXML && {
        LG=true; ver lg; $SANS || return
        local lgq="/\"$lg\">/"; local lgf="$lgq,$FAE"
        xml "$lgf{$lgq!d};$SAF{$SAQ!H};${lgq}G"
        return
    }

    # LG (lgexml)
    [ -f $ORISYSETC/fonts_lge.xml ] && {
        cp $SYSXML $SYSETC/fonts_lge.xml
        LGE=true; ver lgexml; return
    }
}

vars() {
    # xml
    FA=family FAE="/\/$FA/" F=font FE="<\/$F>"
    W=weight S=style I=italic N=normal ID=index=
    FF=fallbackFor FW='t el l r m sb b eb bl'
    readonly FA FAE F FE W S I N ID FF FW

    # families
    SE=serif SA=sans-$SE SAQ="/\"$SA\">/" SAF="$SAQ,$FAE"
    SC=$SA-condensed MO=monospace SO=$SE-$MO
    readonly SE SA SAQ SAF SC MO SO

    # styles
    Bl=Black Bo=Bold EBo=Extra$Bo SBo=Semi$Bo Me=Medium
    Th=Thin Li=Light ELi=Extra$Li Re=Regular It=Italic
    Cn=Condensed- St=Static
    readonly Bl Bo EBo SBo Me Th Li ELi Re It Cn St

    # font ext.
    X=.ttf Y=.otf Z=.ttc XY=.[ot]tf XYZ=.[ot]t[tc]
    readonly X Y Z XY XYZ

    # default android font names
    Ro=Roboto Ns=NotoSerif
    Ds=DroidSans$X Dm=DroidSansMono Cm=CutiveMono
    RR=$Ro-$Re$X RS=$Ro$St-$Re$X
    GSR=GoogleSans-$Re$X GSI=GoogleSans-$It$X Gs=google-sans
    readonly Ro Ns Ds Dm Cm RR RS GSR GSI Gs

    # family prefix
    Mo=Mono- Se=Serif- So=SerifMono-
    readonly Mo Se So
}

# prepare font xml for installation
prep() {
    [ -f $ORISYSXML ] || abort; vars; romprep
    # check if fontxml is pre-patched for roboto fallback
    ! grep -q "$FA >" $SysXml && {
        # remove fontxml from installed modules to prevent conflicts 
        find /data/adb/modules -type f -name fonts*xml -delete
        false | cp -i $SysXml $SYSXML && ver '<!>'
        # otherwise just use the maybe-modified one
    } || false | cp -i $ORISYSXML $SYSXML
}

font() {
    local fa=${1:?} f=${2:?} w=${3:-r} s=$N r i

    # check for ttc
    case $f in *c) i=$ID          ;; esac
    # serif
    case $w in *s) r=$SE w=${w%?} ;; esac
    # italics
    case $w in *i) s=$I  w=${w%?} ;; esac
    # convert weight names to numbers
    case $w in
        t ) w=1 ;; el) w=2 ;; l ) w=3 ;;
        r ) w=4 ;; m ) w=5 ;; sb) w=6 ;;
        b ) w=7 ;; eb) w=8 ;; bl) w=9 ;;
    esac
    fa="/$FA.*\"$fa\"/,$FAE" s="${w}00.*$s"
    # italics
    [ $i ] && s="$s.*$i\"[0-9]*"
    # serif; postScriptname
    [ $r ] && s="$s.*\"$r"; s="$s\"[[:blank:]]*[p>]"

    # cut </font> tag to new line
    xml "$fa{/$s/s|$FE|\n&|}"
    # if axis_del is true then remove all <axis> tags
    $axis_del && xml "$fa{/$s/,/$FE/{/$F/!d}}"
    # Replace font name
    xml "$fa{/$s/s|>.*$|>$f|}"
    # check index if ttc
    [ $4 ] && [ $i ] && {
        xml "$fa{/$s/s|$i\".*\"|$i\"$4\"|}"
        return
    }

    # remove all but axes
    shift 3; [ $# -eq 0 -o $? -ne 0 ] && {
        xml "$fa{/$s/{N;s|\n$FE|$FE|}}"
        return
    }
    # axes
    f="$s.*$f" s="/$f/,/$FE/"; local t v a
    while [ $2 ]; do
        t="tag=\"$1\"" v="stylevalue=\"$2\""
        a="<axis $t $v/>"; shift 2
        xml "$fa{$s{/$t/d};/$f/s|$|\n$a|}"
    done
}

# abbreviations font names for font styles configs
ab() {
    local n=z
    # check ups var for manually font style prefix
    [ $ups ] && n=$ups || \
    case $1 in
        $ORISS |$ORISSI ) n=u ;;
        $ORISER|$ORISERI) n=s ;;
        $ORIMS |$ORIMSI ) n=m ;;
        $ORISRM|$ORISRMI) n=o ;;
    esac
    case "$3" in *i)
        case $n in
            u) n=i ;;
#            s) n=t ;;
#            m) n=n ;;
#            o) n=p ;;
            # if ups, check its var
            $ups) [ $its ] && n=$its ;;
        esac
    esac
    [ "$2" = $SC ] && { [ $n = u ] && n=c || { [ $n = i ] && n=d; }; }
    echo $n
}

# shortcut for font() with auto-axes recognition from ab()
fontab() {
    local w=${4:-$3}; case $w in *i) w=${w%?} ;; esac
    eval font $1 $2 $3 \$$(up `ab $2 $1 $3`$w)
}

# shortcut for font() without arguments, auto-read values from predefined vars
fontinst() {
    # VFs
    case $up in *.*)
        [ $up ] && cpf $up
        [ $it ] && cpf $it
        local i
        for i in ${@:-$FW}; do
            [ $up ] && {
                fontab $fa $up $i
                $condensed && [ $fa = $SA ] && fontab $SC $up $i
            }
            [ $it ] && {
                fontab $fa $it ${i}i
                $condensed && [ $fa = $SA ] && fontab $SC $it ${i}i
            }
        done
        return ;;
    esac

    # Static fonts
    set bli $Bl$It bl $Bl ebi $EBo$It eb $EBo bi $Bo$It b $Bo \
        sbi $SBo$It sb $SBo mi $Me$It m $Me ri $It r $Re \
        li $Li$It l $Li eli $ELi$It el $ELi ti $Th$It t $Th
    while [ $2 ]; do
        cpf $up$2$X && font $fa $up$2$X $1 && \
            $condensed && [ $fa = $SA ] && {
                cpf ${up%?}$Cn$2$X && font $SC ${up%?}$Cn$2$X $1 || \
                    { $FULL && font $SC $up$2$X $1; }
            }
        shift 2
    done
}

# makes font styles - thin to black in fontxml
mksty() {
    case $1 in [a-z]*) local fa=$1; shift ;; esac
    local max=${1:-9} min=${2:-1} dw=${3:-1} id=$4 di=${5:-1} fb

    [ $fa ] || local fa=$SA
    local fae="/$FA.*\"$fa\"/,$FAE"
    # if font_del then delete all existing <font> tag in a <family> tag
    $font_del && xml "$fae{/$FA/!d}"

    local i=$max j=0 s
    # index ttc
    [ $id ] && j=$id && id=" $ID\"$j\""
    # fallback for ...
    [ $fallback ] && fb=" $FF=\"$fallback\""
    until [ $i -lt $min ]; do
        for s in $I $N; do
            eval \$$s || continue
            xml "$fae{/$fa/s|$|\n<$F $W=\"${i}00\" $S=\"$s\"$id$fb>$FE|}"
            [ $j -gt 0 ] && j=$(($j-$di)) && id=" $ID\"$j\""
        done
        [ $i -gt 4 -a $(($i-$dw)) -lt 4 ] && \
            i=4 min=4 || i=$(($i-$dw))
    done

    # remove weights
    for i in $wght_del; do xml "$fae{/${i}00/d}"; done
}

# shortcut for mksty(), auto-detect font styles from config (VF) or font files (static)
mkstya() {
    # VFs
    case $up in *.*)
        local wght_del i j=1 k=false
        [ $it ] || local italic=false

        for i in $FW; do
            # check and delete empty font weights
            eval [ \"\$$(up `ab $up`$i)\" ] && k=true || \
                wght_del="$wght_del $j"
            j=$((j+1))
        done
        # if all font styles are empty, make only Regular
        $k || {
            wght_del=
            mksty 4 4
            $condensed && [ $fa = $SA ] && mksty $SC 4 4
            return
        }

        mksty
        $condensed && [ $fa = $SA ] && mksty $SC
        return ;;
    esac

    # Static fonts
    local i=9 italic font_del
    set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
        $SBo$It $SBo $Me$It $Me $It $Re \
        $Li$It $Li $ELi$It $ELi $Th$It $Th
    while [ $2 ]; do
        italic=
        # make font styles based on actual font files
        [ -f $FONTS/$up$1$X ] || italic=false
        [ -f $FONTS/$up$2$X ] && {
            mksty $i $i
            $condensed && [ $fa = $SA ] && mksty $SC $i $i
            font_del=false
        }
        i=$((i-1)); shift 2
    done
}

# make fallback font, i.e., make Roboto a fallback font to avoid missing glyphs
fallback() {
    local faq fae fb
    [ $1 ] && local fa=$1; [ $fa ] || local fa=$SA
    faq="\"$fa\"" fae="/$FA.*$faq/,$FAE"
    # add "fallbackFor" to <font> tags
    [ $fa = $SA ] || fb="/<$F/s|>| $FF=$faq>|;"
    # make new family instead of fallback
    [ $name ] && name=name=\"$name\" fb=

    # remove/replace family name from the 2nd occurrence
    xml "$fae{${fb}H;2,$FAE{${FAE}G}}"
    xml ":a;N;\$!ba;s|name=$faq|$name|2"
    # if fallback, revert changes on the original family
    [ "$fb" ] && xml "$fae{s| $FF=$faq||
        s| postScriptName=\"[^ ]*\"||}"
}

fba() {
    # List of fallback fonts. Used to avoid to make a family fallback twice
    [ "${FBL:=`sed -n "/<$FA *>/,$FAE{/400.*$N/p}" $SYSXML`}" ]
    # Roboto
    if   [ "$fa" = $SA ]; then echo $FBL | grep -q $Ro || fallback
    # NotoSerif
    elif [ "$fa" = $SE ]; then echo $FBL | grep -q $Ns || fallback
    # DroidSansMono
    elif [ "$fa" = $MO ]; then echo $FBL | grep -q $Dm || fallback
    # Cutive Mono
    elif [ "$fa" = $SO ]; then echo $FBL | grep -q $Cm || fallback; fi
}

# assign closest styles to missing ones
lnf(){
    local i j
    # link each style in $1 to a list of $2
    while [ "$2" ]; do
        for i in $1; do
            eval [ $"$i" ] || \
                for j in $2; do
                    eval "[ $"$j" ] && { $i=$"$j"; break; }"
                done
            # if can't find the closest weight, link to Regular/Italic
            eval "[ $"$i" ] || $i=$"$Re""
            eval "[ $"$i$It" ] || $i$It=$"$i""
            # condensed
            eval "[ $"${Cn%?}$i" ] || ${Cn%?}$i=$"$i""
            eval "[ $"${Cn%?}$i$It" ] || ${Cn%?}$i$It=$"$i$It""
        done
        shift 2
    done
}

# rename abbr. names to long ones with ttf extension
rename() {
    set bl $Bl eb $EBo b $Bo sb $SBo m $Me r $Re l $Li el $ELi t $Th
    # unless sans-serif is installed, use prefix "Sans-" in their names
    [ $SANS = true ] && Sa= || Sa=Sans-; readonly Sa
    # uprights
    while [ $2 ]; do
        mv $FONTS/u$1$XY $FONTS/$Sa$2$X
        [ $Sa ] || mv $FONTS/c$1$XY $FONTS/$Cn$2$X
        mv $FONTS/m$1$XY $FONTS/$Mo$2$X
        mv $FONTS/s$1$XY $FONTS/$Se$2$X
        mv $FONTS/o$1$XY $FONTS/$So$2$X
        shift 2
    done
    # italics
    set bl $Bl$It eb $EBo$It b $Bo$It \
        sb $SBo$It m $Me$It r $It \
        l $Li$It el $ELi$It t $Th$It
    while [ $2 ]; do
        mv $FONTS/i$1$XY $FONTS/$Sa$2$X
        [ $Sa ] || mv $FONTS/d$1$XY $FONTS/$Cn$2$X
        mv $FONTS/n$1$XY $FONTS/$Mo$2$X
        mv $FONTS/t$1$XY $FONTS/$Se$2$X
        mv $FONTS/p$1$XY $FONTS/$So$2$X
        shift 2
    done
    # emoji
    set e Emoji
    while [ $2 ]; do
        mv $FONTS/$1$XY $FONTS/$2$X
        shift 2
    done
    # for long names, check if sans-serif is installed or rename them to "Sans-*"
    set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
        $SBo$It $SBo $Me$It $Me $It $Re \
        $Li$It $Li $ELi$It $ELi $Th$It $Th
    for i do
        [ $Sa ] && {
            mv $FONTS/$i$XY $FONTS/$Sa$i$X
            # if sans-serif is not installed, remove its condensed styles
            rm $FONTS/$Cn*$XY
        } || mv $FONTS/$i$XY $FONTS/$i$X
    done
}

# Main font families installation logic
# sans-serif
sans() {
    # assign the default family if no arg. was provided
    local fa=${1:-$SA}
    # make fallback font
    [ $SS ] ||  [ -f $FONTS/$Sa$Re$X ] && fba
    # VF
    [ $SS ] && {
        local up=$SS it=$SSI
        mkstya; fontinst; return
    }
    # Static
    [ $SANS = true ] || local up=$Sa
    # if FULL is true, there must be Regular and make styles
    $FULL && [ ! -f $FONTS/$Sa$Re$X ] && return
    $FULL && mkstya; fontinst
}

# serif
serf() {
    local fa=${1:-$SE}
    [ $SER ] ||  [ -f $FONTS/$Se$Re$X ] && fba
    [ $SER ] && {
        local up=$SER it=$SERI
        mkstya; fontinst; return
    }
    [ -f $FONTS/$Se$Re$X ] || return
    local up=$Se; mkstya; fontinst
}

# monospace
mono() {
    local fa=${1:-$MO}
    [ $MS ] ||  [ -f $FONTS/$Mo$Re$X ] && fba
    [ $MS ] && {
        local up=$MS it=$MSI
        mkstya; fontinst; return
    }
    [ -f $FONTS/$Mo$Re$X ] || return
    local up=$Mo; mkstya; fontinst
}

# serif-monospace
srmo() {
    local fa=${1:-$SO}
    [ $SRM ] ||  [ -f $FONTS/$So$Re$X ] && fba
    [ $SRM ] && {
        local up=$SRM it=$SRMI
        mkstya; fontinst; return
    }
    [ -f $FONTS/$So$Re$X ] || return
    local up=$So; mkstya; fontinst
}

# emoji, i.e. NotoColorEmoji
emoj() { cpf Emoji$X && font und-Zsye Emoji$X r; }

# make a family alias to another
falias() {
    # alias to sans-serif by default
    local fa faq fae to=to=\"${2:-$SA}\"
    fa=${1:?} faq="/\"$fa\">/" fae="$faq,$FAE"
    # insert <alias> tag
    xml "$faq i<alias name=\"$fa\" $to />"
    # delete old family, redirect others to new one
    xml "${fae}d"; xml "s|to=\"$fa\"|$to|"
}

# set Regular/Italic to Medium one
bold() {
    # not VF and BOLD is true
    [ ! $SS ] && $BOLD || return

    ui_print "  Bold"
    # check if Regular is already Medium, otherwise link Regular to Medium and apply changes
    eval "[ $"$Me" = $"$Re" ] || \
        { $Re=$"$Me"; font $SA $"$Re$X" r; fontfix $SYSFONT/$"$Re$X"; }"
    eval "[ $"$Me$It" = $"$It" ] || \
        { $It=$"$Me$It"; font $SA $"$It$X" ri; }"
}

# line height
line() {
    [ "$LINE" != 1.0 ] && afdko 1 || return

    # change font ascender and descender proportionally instead of using Roboto's
    # This is better in term of keeping font quality
    ui_print '  Line spacing'
    # VF: sans-serif
    local i
    [ $SS ] && {
        # make sure SS is not the same as SSI
        for i in `echo $SS $SSI | tr ' ' '\n' | sort -u`; do
            $TOOLS/pyftline $SYSFONT/$i $LINE || break
        done
        return
    }
    # Static
    for i in $(eval echo \$$Bl$It \$$Bl \$$EBo$It \$$EBo \$$Bo$It \$$Bo \
        \$$SBo$It \$$SBo \$$Me$It \$$Me \$$It \$$Re \
        \$$Li$It \$$Li \$$ELi$It \$$ELi \$$Th$It \$$Th | tr ' ' '\n' | sort -u)
    do
        [ -f $SYSFONT/$i$X ] && {
            $TOOLS/pyftline $SYSFONT/$i$X $LINE || abort
        }
    done
}

# insert lookup indexes to a feature tag, e.g. calt, liga
otltag() {
    afdko || return
    
    # extract GSUB table
    local f=${1:?}; shift
    ttx -s -t GSUB -f $f
    
    # insert lookup index values
    local i t=${f%$X}.G_S_U_B_.ttx \
        f=Feature v=value= id=$ID l=LookupListIndex
    for i in $@; do
        sed -i "/<${f}Tag $v\"$OTLTAG\"\/>/,/<\/$f>/{
        /<\/$f>/s|^|<$l $id\"9\" $v\"$i\"/>\n|}" $t
    done
}

# font features
otl() {
    [ "$OTL" ] && afdko || return

    ui_print '  OpenType Layout features...'
    local font ttx otl
    [ $SS ] && {
        for font in `echo $SS $SSI | tr ' ' '\n' | sort -u`; do
            font=$SYSFONT/$font ttx=${font%$X}.G_S_U_B_.ttx otl=

            [ ${OTLTAG:=`valof OTLTAG`} ] && {
                pyftfeatfreeze -v -f $OTL $font $Null &> $TMPDIR/otl || abort
                otl=`cat $TMPDIR/otl | grep Lookups: | grep -o [0-9]*`
                [ "$otl" ] && otltag $font $otl && \
                    $TOOLS/pyftimport $font $ttx || break
            } || \
                pyftfeatfreeze -f $OTL $font $font &>$Null || abort
        done
    } || {
        set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
            $SBo$It $SBo $Me$It $Me $It $Re \
            $Li$It $Li $ELi$It $ELi $Th$It $Th
        for font do
            font=$SYSFONT/$font$X ttx=${font%$X}.G_S_U_B_.ttx otl=

            [ -f $font ] && {
                [ ${OTLTAG:=`valof OTLTAG`} ] && {
                    pyftfeatfreeze -v -f $OTL $font $Null &> $TMPDIR/otl || abort
                    otl=`cat $TMPDIR/otl | grep Lookups: | grep -o [0-9]*`
                    [ "$otl" ] && otltag $font $otl && \
                        $TOOLS/pyftimport $font $ttx || break
                } || \
                    pyftfeatfreeze -f $OTL $font $font &>$Null || abort
            }
        done
    }

    rm $SYSFONT/*.ttx &>$Null
    OTL=
}

# create static instance to fix vlc sub
static() {
    $STATIC && [ $SS ] && afdko || { STATIC=false; return; }
    SSS=${SS%$XY}Static$X
    local s=$(echo $(eval echo $(up $`ab $SS`r)) | sed 's|\([[:alpha:]]\) \([[:digit:]]\)|\1=\2|g')

    ui_print "  Generating static instance (‚â§60s)..."
    timeout 1m fonttools varLib.instancer -q -o $SYSFONT/$SSS $SYSFONT/$SS $s && \
    font $SA $SSS r && \
    $TOOLS/fontfix $SYSFONT/$SSS
}

# replace GS Clock font in the systemui apk
lsc(){
    $SANS && [ $GS = false -a $LSC != false -a $API -ge 31 ] && afdko 1 || return
    ui_print '+ Lock Screen Clock'
    
    local privapp=${ORISYSEXT//$ORIDIR\//}/priv-app
    local app=$privapp/SystemUIGoogle
    [ -d $ORIDIR/${app%G*} ] && app=${app%G*}
    local apk=$app/SystemUIGoogle.apk
    [ -f $ORIDIR/${apk%G*}.apk ] && apk=${apk%G*}.apk
    local modprivapp=$SYS/${privapp//system\//}
    local modapp=$SYS/${app//system\//}
    local modapk=$SYS/${apk//system\//}
    local fdir=$modapp/res/font
    local font=$fdir/google_sans_clock$X

    mkdir -p $fdir
    cp $ORIDIR/$apk $modprivapp || abort

    [ $LSC = def ] && cp $FONTS/LSC$X $font || {
        local lsc
        [ $SS ] && lsc=$SYSFONT/$SS || \
            eval "lsc=$SYSFONT/$"$Re$X""

        [ $LSC = cust ] && {
            [ -f $OMFDIR/lsc$XY ] && {
                lsc=$OMFDIR/lsc$XY
                ui_print '  Custom'
            } || abort '! Font not found!'
        }

        # enable tabular numbers and centered colon
        LSCOTL=`valof LSCOTL`; [ ${LSCOTL:=tnum} ]
        pyftfeatfreeze -f $LSCOTL $lsc $TMPDIR/lsc$X &>$Null

        # only keep numbers and colon
        pyftsubset $TMPDIR/lsc$X --unicodes=u30-3a \
            --passthrough-tables --output-file=$font

        # style
        [ "${LSCSTY:=`valof LSCSTY`}" ] && \
            fonttools varLib.instancer -q -o $font $font \
            `echo $LSCSTY | sed 's|\([[:alpha:]]\) \([[:digit:]]\)|\1=\2|g'`

        # fix padding
        [ ${LSCLINE:=`valof LSCLINE`} ] && $TOOLS/pyftline $font $LSCLINE
        $TOOLS/pyftlsc $font
    }
    # patch apk
    ( cd $modapp
    $TMBIN/zip -qr $modapp.apk *
    $TMBIN/zipalign -p -f 4 $modapp.apk $modapk ) || abort
    rm -r $modapp.apk $modapp/res
}

# fix VF default weight is not Regular, status bar padding
fontfix() {
    $FONTFIX || return
    local i f=$@
    [ "$f" ] || f=`echo $ORISS $ORISSI $ORISER $ORISERI $ORIMS $ORIMSI $ORISRM $ORISRMI \
        $Sa$Re$X $Se$Re$X $Mo$Re$X $So$Re$X | xargs -n1 | sort -u`
    [ "$f" ] && afdko || return

    [ $# -eq 0 ] && {
        for i in $f; do i=$FONTS/$i
            [ -f $i ] && $TOOLS/fontfix $i
        done
        return
    }
    for i in $f; do $TOOLS/fontfix $i; done
}

# spoof static font to Roboto
fontspoof() {
    # only needed for A12+
    [ $API -ge 31 ] && afdko || return
    ui_print '+ Spoof'

    # get rid of RS
    xml "s|$RS|$RR|"
    local id=' index=' ttfs i j k=0 

    # rename  the generated static font to RS
    $STATIC && {
        xml "s|$SSS|$RS|"
        # preserve id 0 for the generated static font
        ttfs=$SYSFONT/$SSS k=1
    }

    # at least one of 4 main families must be installed
    $SANS || $SERF || $MONO || $SRMO || return

    # VF
    for i in `echo $SS $SSI $MS $MSI $SER $SERI $SRM $SRMI | tr ' ' '\n' | sort -u`
    do
        [ -f $SYSFONT/$i ] && {
            xml "s|>$i|$id\"$k\">$RS|"
            ttfs="$ttfs $SYSFONT/$i" k=$((k+1))
        }
    done

    # Static: Regulars must exist
    [ $k != 0 -o -f $SYSFONT/$Sa$Re$X -o -f $SYSFONT/$Se$Re$X -o \
      -f $SYSFONT/$Mo$Re$X -o -f $SYSFONT/$So$Re$X ] || return

    # go through all font families and styles, if a font exists, assign it an id
    for i in "$Sa" $Se $Mo $So; do
        for j in $Th $Th$It $ELi $ELi$It $Li $Li$It \
            $Re $It $Me $Me$It $SBo $SBo$It \
            $Bo $Bo$It $EBo $EBo$It $Bl $Bl$It
        do
            [ -f $SYSFONT/$i$j$X ] && {
                xml "s|>$i$j$X|$id\"$k\">$RS|"
                eval "${i%?}$j"ID=$k
                ttfs="$ttfs $SYSFONT/$i$j$X" k=$((k+1))
            }
            # condensed
            [ -f $SYSFONT/${i%?}$Cn$j$X ] && {
                xml "s|>${i%?}$Cn$j$X|$id\"$k\">$RS|"
                eval "${i%?}${Cn%?}$j"ID=$k
                ttfs="$ttfs $SYSFONT/${i%?}$Cn$j$X" k=$((k+1))
            }
        done
    done

    [ "$ttfs" ] || return
    # make ttc
    otf2otc -o $SYSFONT/$RS $ttfs &>$Null || abort

    # rework on these roms
    if   [ $PXL   ]; then
        ln -sf $SysFont/$RS $PRDFONT/$GSR
        lsc
    elif [ $OOS   ]; then cp $SYSXML $SYSETC/fonts_slate.xml
    elif [ $OOS11 ]; then cp $SYSXML $SYSETC/fonts_base.xml
    elif [ $COS   ]; then cp $SYSXML $SYSEXTETC/fonts_base.xml
    elif [ $LGE   ]; then cp $SYSXML $SYSETC/fonts_lge.xml; fi
    rm $ttfs
}

# read value from the config, strip duplicate spaces
# the 1st argument is the maxium number of values that a variable has
valof() {
    sed -n "s|^$1[[:blank:]]*=[[:blank:]]*||p" $UCONF | \
        sed 's|[[:blank:]][[:blank:]]*| |g;s| $||' | \
        tail -${2:-1}
}

# convert a predifined instance to its preset
styof() {
    [ -f $UCONF ] || return
    # by default, the function acts like valof()
    s=$(valof $1); [ "$s" ] || return

    # if value is not empty, search for its preset
    p=$(sed -n "/^# $s$/{n;s|^# ||;p}" $UCONF | tail -1)

    # if there is no preset corresponding to the value. It's just a normal font style config
    # Which should include common axes
    [ "$p" ] && echo $p || {
        echo $s | grep -Eq 'wdth|opsz|ital|wght|slnt' && \
        echo $s || rm $UCONF
    }
}

# read font styles config for VF
getsty() {
    local i
    for i in `up $FW`; do
        eval ${ups:?}$i=\"`styof $ups$i`\"
        [ $its ] && eval $its$i=\"`styof $its$i`\"
    done
}

config() {
    local dconf dver uver
    # 3 hash signs is used for integrity check
    dconf=$MODPATH/config.cfg dver=`sed -n '/###/,$p' $dconf`
    UCONF=$OMFDIR/config.cfg  uver=`sed -n '/###/,$p' $UCONF`
    [ "$uver" != "$dver" ] && {
        # backup old config and reset
        cp $UCONF $UCONF~; cp $dconf $UCONF
        ui_print '  Reset'
    }

    # main option vars
    SANS=`valof SANS` MONO=`valof MONO` SERF=`valof SERF` SRMO=`valof SRMO`
    FULL=`valof FULL` GS=`valof GS`     BOLD=`valof BOLD` STATIC=`valof STATIC`
    OTL=`valof OTL`   LINE=`valof LINE` LSC=`valof LSC`   FONTFIX=`valof FONTFIX`

    # default values
    [ ${SANS:=true} ]; [ ${SERF:=true} ]; [ ${MONO:=true}  ]; [ ${SRMO:=true}    ]
    [ ${LAST:=true} ]; [ ${GS:=false}  ]; [ ${BOLD:=false} ]; [ ${STATIC:=false} ]
    [ ${LINE:=1.0}  ]; [ ${LSC:=false} ]; [ ${FONTFIX:=true} ]

    # Get VF names
    SS=`valof SS`   SSI=`valof SSI`   MS=`valof MS`   MSI=`valof MSI`
    SER=`valof SER` SERI=`valof SERI` SRM=`valof SRM` SRMI=`valof SRMI`

    # keep original family for auto font styles config detection
    ORISS=$SS ORISSI=$SSI ORISER=$SER ORISERI=$SERI
    ORIMS=$MS ORIMSI=$MSI ORISRM=$SRM ORISRMI=$SRMI

    # read font styles config
    for i in $FW; do i=`up $i`
        eval U$i=\"`styof U$i`\"
        eval I$i=\"`styof I$i`\"
        # check for separated Italic VF
        [ $SSI ] || { eval [ \"\$I$i\" ] && SSI=$SS; }
        # Itaclic, Condensed inherit font styles from Upright
        eval [ \"\${I$i:=\$U$i}\" ]
        eval C$i=\"`styof C$i`\"
        # Condensed links to Upright/Italic instead of the closest Condensed styles
        # to avoid weight mismatch which is worse than styles mismatch
        eval [ \"\${C$i:=\$U$i}\" ]
        eval D$i=\"`styof D$i`\"
        eval [ \"\${D$i:=\$I$i}\" ]
        # monospace
        eval M$i=\"`styof M$i`\"
        # serif
        eval S$i=\"`styof S$i`\"
        # serif-monospace
        eval O$i=\"`styof O$i`\"
    done
}

# these functions only exist for compatibility reason
# when execute font families vars
sans_serif() { true; }
serif() { true; }
serif_monospace() { true; }
monospace() { true; }

# main font installation logic
install_font() {
    rename
    fontfix

    # sans-serif
    $SANS && {
        # check which typeface is installed as sans-serif
        if [ $SANS = true ]; then sans
        elif [ $SANS = $SE ]; then serf $SA; SS=$ORISER SSI=$ORISERI
        elif [ $SANS = $MO ]; then mono $SA; SS=$ORIMS SSI=$ORIMSI
        elif [ $SANS = serif_$MO ]; then srmo $SA; SS=$ORISRM SSI=$ORISRMI; fi

        # initially assign font file names to their corresponding variables
        local f; [ $Sa ] && \
        if [ $SANS = $SE ]; then f=$Se
        elif [ $SANS = $MO ]; then f=$Mo
        elif [ $SANS = serif_$MO ]; then f=$So; fi
        set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
            $SBo$It $SBo $Me$It $Me $It $Re \
            $Li$It $Li $ELi$It $ELi $Th$It $Th
        for i do
            [ -f $SYSFONT/$f$i$X ] && eval $i=$f$i
            [ -f $SYSFONT/${f%?}$Cn$i$X ] && eval ${Cn%?}$i=${f%?}$Cn$i
        done

        # link closest font styles to missing ones
        $FULL && [ ! $SS ] && [ -f $SYSFONT/$f$Re$X ] && {
            # Italic, Condensed Regular/Italic must be not empty
            eval "[ $"$It" ] || $It=$"$Re""
            eval "[ $"${Cn%?}$Re" ] || ${Cn%?}$Re=$"$Re""
            eval "[ $"${Cn%?}$It" ] || ${Cn%?}$It=$"$It""

            # linking font styles logic, e.g. Medium links to SemiBold or Bold
            lnf "$Me $SBo" "$Me $SBo $Bo" "$Bo" "$EBo $Bl $SBo $Me"
            lnf "$EBo $Bl" "$Bl $EBo $Bo $SBo $Me"
            lnf "$Li" "$ELi $Th" "$ELi $Th" "$Th $ELi $Li"
        }

        line; otl; static; bold
    }

    # serif
    $SERF && {
        if [ $SERF = true ]; then serf
        elif [ $SERF = sans_$SE ]; then sans $SE; SER=$ORISS SERI=$ORISSI
        elif [ $SERF = $MO ]; then mono $SE; SER=$ORIMS SERI=$ORIMSI
        elif [ $SERF = serif_$MO ]; then srmo $SE; SER=$ORISRM SERI=$ORISRMI; fi
    }

    # monospace fonts are only allowed to be switched to each other
    # monospace
    $MONO && {
        if [ $MONO = true ]; then mono
        elif [ $MONO = serif_$MO ]; then srmo $MO; MS=$ORISRM MSI=$ORISRMI; fi
    }

    # serif-monospace
    $SRMO && {
        if [ $SRMO = true ]; then srmo
        elif [ $SRMO = $MO ]; then mono $SO; SRM=$ORIMS SRMI=$ORIMSI; fi
    }

    # emoji
    $EMOJ && emoj
}

# remove unused files and folders, set permissions, unmount afdko
finish() {
    find $MODPATH/* -maxdepth 0 \
        ! -name 'system' \
        ! -name 'zygisk' \
        ! -name '*.rule' \
        ! -name '*.prop' \
        ! -name '*.sh' -exec rm -rf {} \;
    find $MODPATH/* -type d -delete &>$Null
    find $MODPATH/system -type f -exec chmod 644 {} \;
    find $MODPATH/system -type d -exec chmod 755 {} \;
    [ "$AFDKO" = true ] && { umount $TERMUX; rmdir -p $TERMUX; }
}

# quick reboot, suitable to see font styles config changes, i.e. change wght value
restart() {
    $BOOTMODE || return
    REBOOT=`valof REBOOT`; ${REBOOT:=false} || return 

    local modpath=/data/adb/modules/$MODID
    ui_print '! Rebooting in 5s...'; sleep 5 
    local old=`find $modpath/system \( -type f -o -type l \) -exec basename {} \;`
    local new=`find $MODPATH/system \( -type f -o -type l \) -exec basename {} \;`
    [ "$old" = "$new" ] || reboot
    cp -r $MODPATH/system $modpath
    setprop ctl.restart zygote || reboot
}

trap restart 0
return

PAYLOAD:
˝7zXZ  Ê÷¥F¿‹Ä†!      §ÎªO‡OˇT] 3 €π·h»?7‰€=Pˆc{A“6≤+<çπÕùÛ∆Ägî.=á¿Æ=l⁄‘e∫Œ`}∑W Ó.Å:61§ÇwÛ·K’ØıJˇΩÈ$,fM~óFÙ Á»ÿ¨i‡≥ –∞µ"z¸a!J ~v¢∑≥∂¡ÏCVÄ:/p™u::÷ÍäEìrs¶.yØRån¥)sæ÷q64éÂêhìQˇ{ÚÄH*ŒçÆ≠’≤7Á>(OÃ◊¥
m>èD•7Éæéäf¿•eätâYõö$Ÿ∂≠JΩõ2VÛ¿z…\hd®¢Çpﬁˆ∫Mv_∑d]≥∆¥‡Òn≠B]Å;™ﬁt)Mº“B˛Ô4ÃãX©_TEÒ÷sœR=o LÖ§÷ÜVp 5C¶huHΩˆ…”€Qy≤¸Q4x"ò@à&B∑qÃbW ˚9R?!a”%∫ÔíY…˚ËLµ˜”e»C}\GoÒæô’πf¶˙	º"Œ1‡IJ!Ó∂òsƒSZ˚u%">Á\J≤ºr©‡Î~X‰–æEz¶Ì°≥Ï}ÿΩÚÜLÎÕè“f¡˙’ À‚]Ô][–Xª¡ø -Å˙qu`x€jAæmœVn±r«Û[å≥ƒß˜‰ ç#kS:DŸ‹Ëãesõ…2⁄2Ñ÷îé¥N†v∂r421$)˘D∆≈‹¬”»1}˛s1ß9Rê¡Ò€À¿,
îÃ≤ÅÄJ¥T¬p¨Øπ:}Dí*¢üë2á]‹ÍqZ¸_p?Œãå"˝ÿk≥Œ*·€º@K`2o∏úò;À|÷)∞Õ•ÎÄ—$Ó
ûÌÕ¥IBè»'0Äû_ãØ%,™CØzWf¿˘ÁQœŒl>Ω‡[P¨Áw]ÉjÉöÓî>[˜˙bˆﬁ[[¢|nr®CŸG¡Ü‚Y˙¨I±¶€0	ÀN‹å+ÑtØ¥‰ox(ﬂâ‡…«}6›OÜô®cgÑ7≤>ç≠1s‘acÓÁ§⁄Ò3Aj¯SsÓ∞ŸUŒPÚêl@ÎŸ/tï
€(ÿ•cT{æ	!ˇLÆÍ∫¸¸»Ã⁄∫[ç—ÊZ¥û<_/>:∆W•IÎ=ÊåæêñˇKlÙóáÖÓ¸ZÎÃ.À˘){˜Ò∂G≠ É’√¬¬«:P!d°Á%Áã6∫Æ√q§!øäôƒtÕ’“«uQM˝dã/ÂŒíﬂëÃöﬁïúIXÍm£^ç]ëiÀ]T◊Wüü[^£#kˇ}*—åÖeü™:∆«ev⁄Ó›q˘≈/¿<¿èDy´éa5a¡;«x∂πÆØEdJKµ⁄5w¸"òJô>Åïõ0o?ﬁR¡ÕØ«€ÛuáóWwÀÿ¸"ñœ_›‚*6LF¥I"0!OŒfË4˜À–∫}ú≤dzµî/É]32;NE¶ƒÄ¬ 5ŸÀ≈?~æ3™;;ôbX≥Œ	¬≥àª)é»ˆä`?D¸ø©X#>ßg±XZ@#~€¥‚£cÙí"u∆PD®ä8ß†ÖVFØ$ì·Â∞ûbÅÍ\DFÇÇQ¥YßØÏÆgµ[≤	jÍˆ[sei«Â3È:(Åx/†Ú\æ˝&tnÄÂè?Ùÿ(yÀß¢Xo˛µñ"4§ù”É)7–ttñÚ<=.„áèüápqrO•1ƒ7‘Ñ!$o´ø¬9êéÙØ®°Ê‡îNÓLªò¸Xsµí—ÿñêC)÷Pæø!◊˜RåÙÜî∆ÂÀ/«Kzç@	üŸv˝Z¯◊Ÿÿ•“Î1Zçå	]ˆı8YﬁªoÏU6√s“tπÈ	&8‚Ç•øù6ŒPbŒ∞Ì•⁄Ma√∏÷∂6±‘÷	<k¸ïM'7ÅY÷üTeë≥WÙ^-ccyìÀaqt?J=>È~‚úfÙµﬂJ˛∏™Lê€õØN°›h ±%®H«„¯“ôy[lL≠À~DS}pº≤ì≤˛˛pq∂∫‡vó)Çsä£9îXM§Ï…	ÎAèjæÿ«ô?p
i_ÍéÄCóÈ úÅ€ß¢ÒËET}á«%à’y◊ú3›`ô™b/q*v‚ôäΩ VË5vé™‰ƒt–,7A◊∆:π)?íÚW3ûˆe√±¡~Jò¥zäh•ü<Då…*ÃtG„”WJø„Ó∆“G–dPÒ®ñwò’åW+ú¯uÍì´’æ»›˙Ã¬»7≤Î¶zÔΩ7÷s∏bÌ>HGBﬂé$IJªΩ¯XMçbÓ‰›≥à} ´ÅA–I<0∫DŸ[“ÿ‚zÍa<˝µ‰Õ˙ !™uƒÍÔ¡nÜYöí`]V∫º¶L±]◊ÙE[∂ï[SGBúúix&œŸÍ¥ú#G¶^/n, æÇ
É3÷‘P€kO‚Ñ›^Ü⁄‚ﬁBÀGYvwO$õ≤°Fà?ì6ò€≠‰k†è≠m6=$íÿ‹˚ö˜⁄¬Ez∏%)—Lz©˙ˆS?¿„‚RÖwœ€÷xªÓºıõƒËÁLüÄäòu?◊TX3ø∂£àøá˝Å ÚÕ˝sdyŸÏÔ]  ´9§¬˝ˇ•N ¯Ä† “+û®±ƒg˚    YZ
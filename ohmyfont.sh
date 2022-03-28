# Oh My Font Template
# by nongthaihoang @ GitLab

# enable debugging mode
set -xv

# Magisk and TWRP support
[ -d ${MAGISKTMP:=`magisk --path`/.magisk} ] && ORIDIR=$MAGISKTMP/mirror
[ -d ${ORIPRD:=$ORIDIR/product}            ] || ORIPRD=$ORIDIR/system/product

# Original paths
  ORIPRDFONT=$ORIPRD/fonts
   ORIPRDETC=$ORIPRD/etc
   ORIPRDXML=$ORIPRDETC/fonts_customization.xml
  ORISYSFONT=$ORIDIR/system/fonts
   ORISYSETC=$ORIDIR/system/etc
ORISYSEXTETC=$ORIDIR/system/system_ext/etc
   ORISYSXML=$ORISYSETC/fonts.xml

# Modules paths
     PRDFONT=$MODPATH/system/product/fonts
      PRDETC=$MODPATH/system/product/etc
      PRDXML=$PRDETC/fonts_customization.xml
     SYSFONT=$MODPATH/system/fonts
      SYSETC=$MODPATH/system/etc
   SYSEXTETC=$MODPATH/system/system_ext/etc
      SYSXML=$SYSETC/fonts.xml
     MODPROP=$MODPATH/module.prop
       FONTS=$MODPATH/fonts
       TOOLS=$MODPATH/tools
      OMFDIR=/sdcard/OhMyFont
      
# abbr. vars
     SysFont=/system/fonts
      SysXml=/system/etc/fonts.xml
        Null=/dev/null

# create module paths
mkdir -p $PRDFONT $PRDETC $SYSFONT $SYSETC $SYSEXTETC $FONTS $TOOLS $OMFDIR

SH=$MODPATH/ohmyfont.sh
tail -n +$((`grep -an ^PAYLOAD:$ $SH | cut -d : -f 1`+1)) $SH | tar xJf - -C $MODPATH || abort
tar xf $MODPATH/*xz -C $MODPATH

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

# cp files from $FONT to $SYSFONT, do not overwrite
cpf() {
    [ $# -eq 0 ] && return 1
    local i
    for i in $@; do
        false | cp -i $FONTS/$i ${CPF:=$SYSFONT} 2>$Null
    done
}

# Roms i.e. Pixels need to be detected for advanced functions
romprep() {
    src 0
    [ -f $ORIPRDFONT/$GSR ] && grep -q $Gs $ORIPRDXML && \
        PXL=true
}

rom() {
    # check if PXL var is set to force use fonts.xml instead of fonts_customizations.xml
    # for GS font spoofing
    local pxl=`valof PXL`
    [ $PXL ] && [ "$pxl" = false ] && PXL=

    # GS font spoofing - try to replace Gapps font
    $SANS && [ $GS = false -o $GS = $SE ] && {
        local fa=$Gs.* xml=$FONTS/gsvf.xml m=verdana
        # Pixel A11-
        [ $PXL ] && [ $API -lt 31 ] && {
                m=$F.*version; XML=$PRDXML
                xml "/$FA.*$fa/,${FAE}d"
        }
        [ $PXL ] && [ $API -ge 31 ] || { xml "/$m/r $xml"; XML=; }
        [ $PXL ] || {
            # VF
            [ $SS ] && {
                for i in r m sb b; do
                    eval font $fa $SS $i \$U`up $i`
                    eval font $fa $SSI ${i}i \$I`up $i`
                done
            } || {
                # Static
                set $Bo$It bi $Bo b $SBo$It sbi $SBo sb $Me$It mi $Me m $Re r $It ri
                while [ $2 ]; do
                    eval "[ $"$1" ] && font $fa $"$1$X" $2"
                    shift 2
                done
            }
        }
    }

   falias source-sans-pro
    
    # Pixel
    [ $PXL ] && {
        ver pxl
        $GS && return
        $SANS || return
        GS_italic=`valof GS_italic`; ${GS_italic:=false}
        cp $ORIPRDXML $PRDXML; local XML=$PRDXML fa=$Gs.* i
        falias lato $Gs-text

        [ $SS ] && {
            local up=$SS it; $GS_italic && it= || it=$SSI
            ln -s /system/fonts/$up $PRDFONT
            [ $it ] && ln -s /system/fonts/$it $PRDFONT
            fontinst r m sb b

            # spoof Lato
            local la=Lato-; ln -s $up $PRDFONT/$la$Re$X && xml "s|$up|$la$Re$X|"
            [ $it ] && ln -s $it $PRDFONT/$la$It$X && xml "s|$it|$la$It$X"

            $STATIC && cp $SYSFONT/$SSS $PRDFONT/$GSR || ln -s $up $PRDFONT/$GSR
            return
        }

        $GS_italic && set $Bo b $SBo sb $Me m $Re r || \
            set $Bo$It bi $Bo b $SBo$It sbi $SBo sb $Me$It mi $Me m $Re r $It ri
        while [ $2 ]; do
            eval [ $"$1" ] && {
                eval ln -s /system/fonts/$"$1$X" $PRDFONT
                eval font $fa $"$1$X" $2
            }
            shift 2
        done
        eval "[ $"$Re" ] && ln -s $"$Re$X" $PRDFONT/$GSR"
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

    # source extension - 9 (3rd stage)
    src 9
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

    # check if Regular is already Medium, otherwise link Regular to Medium and apply changes
    eval "[ $"$Me" = $"$Re" ] || { $Re=$"$Me"; font $SA $"$Re$X" r; }"
    eval "[ $"$Me$It" = $"$It" ] || { $It=$"$Me$It"; font $SA $"$It$X" ri; }"
}

# line height
line() {
    local l=`valof LineHeight`
    [ ${l:=1} != 1.0 ] && afdko || return

    # change font ascender and descender proportionally instead of using Roboto's
    # This is better in term of font quality
    ui_print '+ Line spacing'
    local i
    # sans-serif
    [ $SS ] && {
        for i in `echo $SS $SSI | tr ' ' '\n' | sort -u`; do
            $TOOLS/pyftmetrics $SYSFONT/$i $l || break
        done
        return
    }
    # Static
    set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
        $SBo$It $SBo $Me$It $Me $It $Re \
        $Li$It $Li $ELi$It $ELi $Th$It $Th
    for i do
        [ -f $SYSFONT/$i$X ] && {
            $TOOLS/pyftmetrics $SYSFONT/$i$X $l || break
        }
    done
}

# font features
otl() {
    [ "$OTL" ] && afdko || return

    ui_print '+ OpenType Layout feature...'
    local i
    [ $SS ] && {
        for i in `echo $SS $SSI | tr ' ' '\n' | sort -u`; do
            i=$SYSFONT/$i
            pyftfeatfreeze -f $OTL $i $i > $Null || abort
        done
    } || {
        set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
            $SBo$It $SBo $Me$It $Me $It $Re \
            $Li$It $Li $ELi$It $ELi $Th$It $Th
        for i do
            i=$SYSFONT/$i$X
            [ -f $i ] && {
                pyftfeatfreeze -f $OTL $i $i > $Null || abort
            }
        done
    }

    OTL=
}

# create static instance to fix vlc sub
static() {
    $STATIC && [ $SS ] && afdko || { STATIC=false; return; }
    SSS=${SS%$XY}Static$X
    local s=$(echo $(eval echo $(up $`ab $SS`r)) | sed 's|\([[:alpha:]]\) \([[:digit:]]\)|\1=\2|g')

    ui_print "+ Generating static instance (‚â§60s)..."
    timeout 1m fonttools varLib.instancer -q -o $SYSFONT/$SSS $SYSFONT/$SS $s && \
    font $SA $SSS r
}

# spoof static font to Roboto
fontspoof() {
    # only needed for A12+
    [ $API -ge 31 ] || return
    # get rid of RobotoStatic (RS)
    xml "s|$RS|$RR|"
    local id=' index=' ttfs i j k=0 

    # rename  the generated static font to RS
    $STATIC && {
        xml "s|$SSS|$RS|"
        mv $SYSFONT/$SSS $SYSFONT/$RS
        # preserve id 0 for the generated static font
        ttfs=$SYSFONT/$RS k=1
    }

    # at least one of 4 main families must be installed
    $SANS || $SERF || $MONO || $SRMO || return
    # Regulars must exist
    [ -f $SYSFONT/$Sa$Re$X -o -f $SYSFONT/$Se$Re$X -o \
      -f $SYSFONT/$Mo$Re$X -o -f $SYSFONT/$So$Re$X ] || return
    afdko || return

    # go through all font families and styles, if a font exists, assign it an id
    for i in "$Sa" $Se $Mo $So; do
        for j in $Th $Th$It $ELi $ELi$It $Li $Li$It \
            $Re $It $Me $Me$It $SBo $SBo$It \
            $Bo $Bo$It $EBo $EBo$It $Bl $Bl$It
        do
            [ -f $SYSFONT/$i$j$X ] && {
                ttfs="$ttfs $SYSFONT/$i$j$X"
                xml "s|>$i$j$X|$id\"$k\">$RS|"
                eval "${i%?}$j"ID=$k; k=$((k+1))
            }
            # condensed
            [ -f $SYSFONT/${i%?}$Cn$j$X ] && {
                ttfs="$ttfs $SYSFONT/${i%?}$Cn$j$X"
                xml "s|>${i%?}$Cn$j$X|$id\"$k\">$RS|"
                eval "${i%?}${Cn%?}$j"ID=$k; k=$((k+1))
            }
        done
    done

    [ "$ttfs" ] || return
    ui_print '+ Font spoofing'
    # make ttc
    otf2otc -o $SYSFONT/$RS $ttfs >/dev/null || abort

    # rework on these roms
    if [ $PXL ]; then
        # use Lato (Regular, Medium, Bold), Zilla (SemiBold) for font spoofing
        [ $SS ] || {
            # move static fonts to /product, cause they are not needed anymore
            for i in $Re $It $Me $Me$It $SBo $SBo$It $Bo $Bo$It; do
                eval mv $SYSFONT/$"$i$X" $PRDFONT
            done
            local XML=$PRDXML la=Lato- zs=ZillaSlab-

            # alias Lato, Zilla to GS
            falias lato $Gs-text
            falias zilla-slab-medium $Gs

            # link lato to static fonts and patch fontxml
            for i in $Re $It $Me $Me$It $Bo $Bo$It; do
                eval ln -s $"$i$X" $PRDFONT/$la$i$X
                eval $(echo "xml \"s|>\$$i$X|>$la$i$X|\"")
            done
            # ZillaSlab
            eval ln -s $"$SBo$X" $PRDFONT/$zs$SBo$X
            eval ln -s $"$SBo$It$X" $PRDFONT/$zs$SBo$It$X
            eval $(echo "xml \"s|>\$$SBo$X|>$zs$SBo$X|\"")
            eval $(echo "xml \"s|>\$$SBo$It$X|>$zs$SBo$It$X|\"")
        }
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

    # main var options
    SANS=`valof SANS` MONO=`valof MONO` SERF=`valof SERF` SRMO=`valof SRMO`
    FULL=`valof FULL` GS=`valof GS`     BOLD=`valof BOLD` STATIC=`valof STATIC`
    OTL=`valof OTL`

    # default values
    [ ${SANS:=true} ]; [ ${SERF:=true} ]; [ ${MONO:=true} ];  [ ${SRMO:=true} ]
    [ ${LAST:=true} ]; [ ${GS:=false} ];  [ ${BOLD:=false} ]; [ ${STATIC:=false} ]

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
    find $MODPATH/* -maxdepth 0 ! \( -name 'system' -o -name 'module.prop' \) -exec rm -rf {} \;
    find $MODPATH/* -type d -delete 2>$Null
    find $MODPATH/system -type d -exec chmod 755 {} \;
    find $MODPATH/system -type f -exec chmod 644 {} \;
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
˝7zXZ  Ê÷¥F¿ìÄ†!      mƒ\Â‡Oˇã] 3 €π·h»?7‰€=Pˆc{A“6≤.˜pö\]±õpWN9à”rNÖ'ç§ÌcE»QSfÿ˜©'‰ıf‰˚â=Q„∫‚.—c≤µkJUXG*Éi8-ﬁsY˜˝å<£◊y¥P§≥¶ô%∂{-˙,∫
ä”“ë=∏˚K÷[Ó»õ(=Ê≠É±±|˛ëièÄd»75Èrw∂⁄Q£•l\o§6Qx≥Oﬂ2æ(ﬁ5@
§jî—lp9kò/Æ^x2$pU|ï—„+JÏ…)ÇE"B$ çY€”ô)YÌ°z`CS=`êÒ]è’ 7x
Yâ@°¥!«ˇ2
é„-˛€E8"”–.ôø¸◊6òR~zvûïÖêµ…¸m¨ î•jÖMu,Zn6ƒ,Ã7kplX¥Ïp◊TΩ“°qî”£Û‚öÿŒÁ›~L¥¯U‹3ïWÍ≈|F›µ8ë–'£“U¯Ñ	?≈‡åÛ˙ØA˛ÇÆ¯%@í52ú@S∫3AA∏ı^ 6„1ÓÖ–\Jæ|k∂ÖnéOoÇ[Uu:ÓÜl“2‚∞˛B÷∏Ø∫JEt-ﬁrbBŸ/™—§_)®Û¯Z3F÷l[é©¥PNwâÂìË/qcÈ¸òX≈}¡?È>ı4:q˛39@O#¸π∏U†VûWV€ΩÙ†AàH!ß5—5È⁄ÅÒër(£Bñ§ﬂ¶v00« µ‘<†E§ﬂÙÿÇöËCÚ¶∆Ì Ëç¨@˛Ù•ˆt'èÊäàÆ€ pàì)5⁄‰≈¶›S8Ùòajg©dz,aâƒ%–iz@M¬s¥ÿIùswEßXŸ1|/˜oØ”‰
HNïwC¸b-ÌáqöÔö¶2√dÚªÒÛ‚y\ µ&J9õÉê√ÏÔºœYHØId/ßDíWö˜ë⁄˘Ià-m‚?ÆCﬂTˆJœWÙ∞¬sëÍÑÏd$®V†3:IçY0ì]–`}â~¯~2©Îæy'MVà~ÿéV∂UcÓ ŒD„≈©)ä.≥èÄ˘±_˙.r∞?[cA˛f˜$« ˝ô≥ÎﬂD∫Ø9•Kª@Öß0D‰≠˛»J)f≈¨Û…1&rKuÌS°ì
„L!p‰Ùh⁄wKÀßÉc^)#ÜU™8+ˆçßı“≠U∂±‘‚ÌO\‚Y+õrÙåÿïú˝ñ0Rc∫r'a=∞ÓtQ9bAs¯ Ù€*bÚ’]¨ˇ…¢òi"fl-œÏûò#≠^g˛8¡âD‚ã>≥ózÛï9’Ò±Ô(Ulx{‡®˛¢à]™;jx√π^Üâù≈<}ÄuïÏáí¥åÜƒÏ)åYÏª6„∞¡_I>ûH◊ø@ZçàóÜ≠”s{∞xçüÔ(8¡1§ÕgÀù4Õ6Ú≥H±!òû%/úΩ»=∆≤E#cpaIã…¿‹ÁR‹€lMJ*¡Ce<P¢±©¥iU∂5OxØGO»q#Äïõ5x¿CÇ¡Gn˙ÖÚ†;·Rg#Ú&æùıH—Ñ`ñ@FÖˇºê<ÛíY∏“§K(TR{S1'»‡ìò0ÑJaèY RÀŒŸµ™Mw©‹Y R◊Dñ¿Ä‹ÉJDöFVÇ1M≠‹≈[pDBÂmƒ°kªº©‚gn8˜©j+ó*àª"jÎ¯z6DâV÷^¶ÚÑı/¨‰ÂÇ’ã¡∏ŒrH“¡]ıuE™F ƒà¢JΩ¯»ö'ﬁM 9‹nN˝NçPªd‰jû∏djv«¡£Ñ3˙˘†»£Âº°•wÕ»…⁄ÄåQ“Ë+∂c&ü*Ï›%#ê,ÈEËﬁ√ÕZ¿zx≥·ãº∏q'πJ/`v’≈Å'&;ypÒﬁgıu£Å§sËm|”\Û√k¸…¨™ÜÉÓfŸE€ã6…éÑ„yV∫¬X¢`·Ìz0>‹#Q≤P‹¿F(h\›A•∂(¶'7Ò+We,^ö®N·®®w«TÀíˇ2yuÛyPóÎp?i3Ó⁄∫!S≥›iªºÂ¶¬YCâná`‘ª^ÏH∑§∑sD(\Ö⁄∑±”Rñ ÏZ¥2bøC©Ä	π≈¨‹DÇ∏áu"Fp*@˛ô∞ú=†¿¶ˆë`wÅ%¸Á·GçõÖ—îÇ≥ÿé©Y}o_gxÇHïãJæë kíºO;ª"EF‚v]t†Äù√çÏ[µ«|]<Ô2’dz˚ºÖŒÕ´˚[@ƒ¨0  9k
glÃß ØÄ† Miµ˛±ƒg˚    YZ
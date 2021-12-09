# Oh My Font Template
# by nongthaihoang @ GitLab

set -xv

[ -d ${MAGISKTMP:=`magisk --path`/.magisk} ] && ORIDIR=$MAGISKTMP/mirror
[ -d ${ORIPRD:=$ORIDIR/product} ] || ORIPRD=$ORIDIR/system/product
ORIPRDFONT=$ORIPRD/fonts
ORIPRDETC=$ORIPRD/etc
ORIPRDXML=$ORIPRDETC/fonts_customization.xml
ORISYSFONT=$ORIDIR/system/fonts
ORISYSETC=$ORIDIR/system/etc
ORISYSEXTETC=$ORIDIR/system/system_ext/etc
ORISYSXML=$ORISYSETC/fonts.xml

PRDFONT=$MODPATH/system/product/fonts
PRDETC=$MODPATH/system/product/etc
PRDXML=$PRDETC/fonts_customization.xml
SYSFONT=$MODPATH/system/fonts
SYSETC=$MODPATH/system/etc
SYSEXTETC=$MODPATH/system/system_ext/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop
mkdir -p $PRDFONT $PRDETC $SYSFONT $SYSETC $SYSEXTETC

FONTS=$MODPATH/fonts TOOLS=$MODPATH/tools SH=$MODPATH/ohmyfont.sh
tail -n +$((`grep -an ^PAYLOAD:$ $SH | cut -d : -f 1`+1)) $SH | tar xJf - -C $MODPATH
tar xf $MODPATH/*xz -C $MODPATH
mkdir ${OMFDIR:=/sdcard/OhMyFont}

ver() { sed -i "/^version=/s|$|-$1|" $MODPROP; }

xml() {
    [ ${XML:=$SYSXML} ]
    case $XML_LIST in
        *$XML*) ;;
        *)  sed -i '/<!--.*-->/d;/<!--/,/-->/d' $XML
            sed -i "s|'|\"|g" $XML
            sed -i "/<$F .*>/s|>|\n&|" $XML
            sed -i "/[[:blank:]]<$F/{:a;N;/>/!ba;s|\n||g}" $XML
            sed -i "/<$F.*$FE/s|$FE|\n&|" $XML
            sed -i "/<$F .*>$/{N;s|\n||}" $XML
            sed -i "/<$F /{N;s|\n$FE|$FE|}" $XML
            XML_LIST="$XML $XML_LIST" ;;
    esac
    sed -i "$@" $XML
}

up() { echo $@ | tr [:lower:] [:upper:]; }

src() {
    local l=`find $OMFDIR -maxdepth 1 -type f -name '*.sh' \
        -exec basename {} \; | sort` i
    if [ "$1" = 0 ]; then l=`echo "$l" | grep '^0'`
    elif [ "$1" = 9 ]; then l=`echo "$l" | grep '^9'`
    else l=`echo "$l" | grep '^[^09]'`; fi
    for i in $l; do
        ui_print "+ Source $i"
        . $OMFDIR/$i
    done
}

cpf() {
    [ $# -eq 0 ] && return 1; local i
    for i in $@; do false | cp -i $FONTS/$i ${CPF:=$SYSFONT} 2>/dev/null; done
}

romprep() {
    src 0
    [ -f $ORIPRDFONT/GoogleSans-$Re$X ] && grep -q $Gs $ORIPRDXML && \
        PXL=true && return
}

rom() {
    local pxl=`valof PXL`; [ $PXL ] && [ "$pxl" = false ] && PXL=
    $SANS && $FULL && [ $GS = false ] && {
        local fa=$Gs.* xml=$FONTS/gsvf.xml m=verdana i
        [ $PXL ] && [ $API -lt 31 ] && {
                m=$F.*version; local XML=$PRDXML
                xml "/$FA.*$fa/,${FAE}d"
        }
        [ $PXL ] && [ $API -ge 31 ] || { xml "/$m/r $xml"; XML=; }
        [ $PXL ] || {
            [ $SS ] && {
                for i in r m sb b; do
                    eval font $fa $SS $i \$U`up $i`
                    eval font $fa $SSI ${i}i \$I`up $i`
                done
            } || {
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
        ver pxl; $GS && return; $SANS || return
        GS_italic=`valof GS_italic`; ${GS_italic:=false}
        cp $ORIPRDXML $PRDXML; local XML=$PRDXML fa=$Gs.* i
        falias lato $Gs-text
        [ $SS ] && {
            local up=$SS it; $GS_italic && it= || it=$SSI
            ln -s /system/fonts/$up $PRDFONT
            [ $it ] && ln -s /system/fonts/$it $PRDFONT
            fontinst r m sb b
            local gs=GoogleSans-
            mv $PRDFONT/$up $PRDFONT/$gs$Re$X && xml "s|$up|$gs$Re$X|"
            [ $it ] && mv $PRDFONT/$it $PRDFONT/$gs$It$X && xml "s|$it|$gs$It$X|"
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
        return
    }

    # Oxygen OS 11 (basexml)
    [ -f $ORISYSETC/fonts_base.xml ] && {
        cp $SYSXML $SYSETC/fonts_base.xml
        OOS11=true; ver basexml; return
    }

    # Color OS 11 (basexml)
    [ -f $ORISYSEXTETC/fonts_base.xml ] && {
        cp $SYSXML $SYSEXTETC/fonts_base.xml
        COS=true; ver xbasexml; return
    }

    # Oxygen OS 10 (slatexml)
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

    src 9
}

vars() {
    FA=family FAE="/\/$FA/" F=font FE="<\/$F>"
    W=weight S=style I=italic N=normal ID=index
    FF=fallbackFor FW='t el l r m sb b eb bl'
    readonly FA FAE F FE W S I N ID FF FW

    SE=serif SA=sans-$SE SAQ="/\"$SA\">/" SAF="$SAQ,$FAE"
    SC=$SA-condensed SCQ="/\"$SC\">/" SCF="$SCQ,$FAE"
    MO=monospace SO=$SE-$MO
    readonly SE SA SAQ SAF SC SCQ SCF MO SO

    Bl=Black Bo=Bold EBo=Extra$Bo SBo=Semi$Bo Me=Medium
    Th=Thin Li=Light ELi=Extra$Li Re=Regular It=Italic
    Cn=Condensed- X=.ttf Y=.otf Z=.ttc XY=.[ot]tf XYZ=.[ot]t[tc]
    readonly Bl Bo EBo SBo Me Th Li ELi Re It Cn X Y Z XY XYZ

    Mo=Mono- Se=Serif- So=SerifMono-
    readonly Mo Se So

    FB=fallback

    Gs=google-sans RR=Roboto-$Re$X RS=RobotoStatic-$Re$X
    readonly Gs RR RS
}

prep() {
    [ -f $ORISYSXML ] || abort "! $ORISYSXML not found"
    vars; romprep
    ! grep -q "$FA >" /system/etc/fonts.xml && {
        find /data/adb/modules/ -type f -name fonts*xml -delete
        false | cp -i /system/etc/fonts.xml $SYSXML && ver '<!>'
    } || false | cp -i $ORISYSXML $SYSXML
    sed -n "/<$FA *>/,$FAE{/400.*$N/p}" $SYSXML | \
    grep -q Roboto && readonly FB=
}

font() {
    local fa=${1:?} f=${2:?} w=${3:-r} s=$N r i
    case $f in *c) i=$ID          ;; esac
    case $w in *s) r=$SE w=${w%?} ;; esac
    case $w in *i) s=$I  w=${w%?} ;; esac
    case $w in
        t ) w=1 ;; el) w=2 ;; l ) w=3 ;;
        r ) w=4 ;; m ) w=5 ;; sb) w=6 ;;
        b ) w=7 ;; eb) w=8 ;; bl) w=9 ;;
    esac
    fa="/$FA.*\"$fa\"/,$FAE" s="${w}00.*$s"
    [ $i ] && s="$s.*$i=\"[0-9]*"
    [ $r ] && s="$s.*\"$r"; s="$s\"[[:blank:]]*[p>]"

    xml "$fa{/$s/s|$FE|\n&|}"
    $axis_del && xml "$fa{/$s/,/$FE/{/$F/!d}}"
    xml "$fa{/$s/s|>.*$|>$f|}"
    [ $4 ] && [ $i ] && {
        xml "$fa{/$s/s|$i=\".*\"|$i=\"$4\"|}"
        return
    }

    shift 3; [ $# -eq 0 -o $? -ne 0 ] && {
        xml "$fa{/$s/{N;s|\n.*$FE|$FE|}}"
        return
    }
    f="$s.*$f" s="/$f/,/$FE/"; local t v a
    while [ $2 ]; do
        t="tag=\"$1\"" v="stylevalue=\"$2\""
        a="<axis $t $v/>"; shift 2
        xml "$fa{$s{/$t/d};/$f/s|$|\n$a|}"
    done
}

ab() {
    local n=z
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
            $ups) [ $its ] && n=$its ;;
        esac
    esac
    [ "$2" = $SC ] && { [ $n = u ] && n=c || { [ $n = i ] && n=d; }; }
    echo $n
}

fontab() {
    local w=${4:-$3}; case $w in *i) w=${w%?} ;; esac
    eval font $1 $2 $3 \$$(up `ab $2 $1 $3`$w)
}

fontinst() {
    case $up in *.*)
        local i
        [ $up ] && cpf $up
        [ $it ] && cpf $it
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

mksty() {
    case $1 in [a-z]*) local fa=$1; shift ;; esac
    local max=${1:-9} min=${2:-1} dw=${3:-1} id=$4 di=${5:-1} fb
    [ $fa ] || local fa=$SA; local fae="/$FA.*\"$fa\"/,$FAE"

    $font_del && xml "$fae{/$FA/!d}"; local i=$max j=0 s
    [ $id ] && j=$id && id=" $ID=\"$j\""
    [ $fallback ] && fb=" $FF=\"$fallback\""
    until [ $i -lt $min ]; do
        for s in $I $N; do
            eval \$$s || continue
            xml "$fae{/$fa/s|$|\n<$F $W=\"${i}00\" $S=\"$s\"$id$fb>$FE|}"
            [ $j -gt 0 ] && j=$(($j-$di)) && id=" $ID=\"$j\""
        done
        [ $i -gt 4 ] && [ $(($i-$dw)) -lt 4 ] && \
            i=4 min=4 || i=$(($i-$dw))
    done
    for i in $wght_del; do xml "$fae{/${i}00/d}"; done
}

mkstya() {
    case $up in *.*)
        local wght_del i j=1 k=false
        [ $it ] || local italic=false
        for i in $FW; do
            eval [ \"\$$(up `ab $up`$i)\" ] && k=true || \
                wght_del="$wght_del $j"
            j=$((j+1))
        done
        $k || {
            wght_del=; mksty 4 4
            $condensed && [ $fa = $SA ] && mksty $SC 4 4
            return
        }
        mksty; $condensed && [ $fa = $SA ] && mksty $SC
        return ;;
    esac
    local i=9 italic font_del
    set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
        $SBo$It $SBo $Me$It $Me $It $Re \
        $Li$It $Li $ELi$It $ELi $Th$It $Th
    while [ $2 ]; do
        italic=
        [ -f $FONTS/$up$1$X ] || italic=false
        [ -f $FONTS/$up$2$X ] && {
            mksty $i $i
            [ $fa = $SA ] && mksty $SC $i $i
            font_del=false
        }
        i=$((i-1)); shift 2
    done
}

fallback() {
    local faq fae fb
    [ $1 ] && local fa=$1; [ $fa ] || local fa=$SA
    faq="\"$fa\"" fae="/$FA.*$faq/,$FAE"
    [ $fa = $SA ] || fb="/<$F/s|>| $FF=$faq>|;"
    [ $name ] && name=name=\"$name\" fb=
    xml "$fae{${fb}H;2,$FAE{${FAE}G}}"
    xml ":a;N;\$!ba;s|name=$faq|$name|2"
    [ "$fb" ] && xml "$fae{s| $FF=$faq||
        s| postScriptName=\"[^ ]*\"||}"
}

lnf(){
    local i j
    while [ "$2" ]; do
        for i in $1; do
            eval [ $"$i" ] || \
                for j in $2; do
                    eval "[ $"$j" ] && { $i=$"$j"; break; }"
                done
            eval "[ $"$i" ] || $i=$"$Re""
            eval "[ $"$i$It" ] || $i$It=$"$i""
            eval "[ $"${Cn%?}$i" ] || ${Cn%?}$i=$"$i""
            eval "[ $"${Cn%?}$i$It" ] || ${Cn%?}$i$It=$"$i$It""
        done
        shift 2
    done
}

rename() {
    set bl $Bl eb $EBo b $Bo sb $SBo m $Me r $Re l $Li el $ELi t $Th
    [ $SANS = true ] && Sa= || Sa=Sans-; readonly Sa
    while [ $2 ]; do
        mv $FONTS/u$1$XY $FONTS/$Sa$2$X
        [ $Sa ] || mv $FONTS/c$1$XY $FONTS/$Cn$2$X
        mv $FONTS/m$1$XY $FONTS/$Mo$2$X
        mv $FONTS/s$1$XY $FONTS/$Se$2$X
        mv $FONTS/o$1$XY $FONTS/$So$2$X
        shift 2
    done
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
    set e Emoji
    while [ $2 ]; do
        mv $FONTS/$1$XY $FONTS/$2$X
        shift 2
    done
    set $Bl$It $Bl $EBo$It $EBo $Bo$It $Bo \
        $SBo$It $SBo $Me$It $Me $It $Re \
        $Li$It $Li $ELi$It $ELi $Th$It $Th
    for i do
        [ $Sa ] && {
            mv $FONTS/$i$XY $FONTS/$Sa$i$X
            rm $FONTS/$Cn*$XY
        } || mv $FONTS/$i$XY $FONTS/$i$X
    done
}

sans() {
    local fa=${1:-$SA}
    [ $SS ] ||  [ -f $FONTS/$Sa$Re$X ] && {
        [ $fa = $SA ] && $FB || {
        [ $fa = $SE -o $fa = $MO -o $fa = $SO ] && fallback; }
    }
    [ $SS ] && {
        local up=$SS it=$SSI
        mkstya; fontinst; return
    }
    [ $SANS = true ] || local up=$Sa
    $FULL && [ ! -f $FONTS/$Sa$Re$X ] && return
    $FULL && mkstya; fontinst
}

serf() {
    local fa=${1:-$SE}
    [ $SER ] ||  [ -f $FONTS/$Se$Re$X ] && {
        [ $fa = $SA ] && $FB || {
        [ $fa = $SE -o $fa = $MO -o $fa = $SO ] && fallback; }
    }
    [ $SER ] && {
        local up=$SER it=$SERI
        mkstya; fontinst; return
    }
    [ -f $FONTS/$Se$Re$X ] || return
    local up=$Se; mkstya; fontinst
}

mono() {
    local fa=${1:-$MO}
    [ $MS ] ||  [ -f $FONTS/$Mo$Re$X ] && {
        [ $fa = $SA ] && $FB || {
        [ $fa = $SE -o $fa = $MO -o $fa = $SO ] && fallback; }
    }
    [ $MS ] && {
        local up=$MS it=$MSI
        mkstya; fontinst; return
    }
    [ -f $FONTS/$Mo$Re$X ] || return
    local up=$Mo; mkstya; fontinst
}

srmo() {
    local fa=${1:-$SO}
    [ $SRM ] ||  [ -f $FONTS/$So$Re$X ] && {
        [ $fa = $SA ] && $FB || {
        [ $fa = $SE -o $fa = $MO -o $fa = $SO ] && fallback; }
    }
    [ $SRM ] && {
        local up=$SRM it=$SRMI
        mkstya; fontinst; return
    }
    [ -f $FONTS/$So$Re$X ] || return
    local up=$So; mkstya; fontinst
}

emoj() { cpf Emoji$X && font und-Zsye Emoji$X r; }

falias() {
    local fa faq fae to=to=\"${2:-$SA}\"
    fa=${1:?} faq="/\"$fa\">/" fae="$faq,$FAE"
    xml "$faq i<alias name=\"$fa\" $to />"
    xml "${fae}d"; xml "s|to=\"$fa\"|$to|"
}

bold() {
    [ ! $SS ] && $BOLD || return
    eval "[ $"$Me" = $"$Re" ] || { $Re=$"$Me"; font $SA $"$Re$X" r; }"
    eval "[ $"$Me$It" = $"$It" ] || { $It=$"$Me$It"; font $SA $"$It$X" ri; }"
}

static() {
        $STATIC && [ $SS ] && afdko || { STATIC=false; return; }
        SSS=${SS%$XY}Static$X
        local s=$(echo $(eval echo $(up $`ab $SS`r)) | sed 's|\([[:alpha:]]\) \([[:digit:]]\)|\1=\2|g')
        ui_print "+ Generating static instance (‚â§60s)..."
        timeout 1m fonttools varLib.instancer -q -o $SYSFONT/$SSS $SYSFONT/$SS $s && \
        font $SA $SSS r
}

fontspoof() {
    [ $API -ge 31 ] || return
    local id=' index='
    $STATIC && {
        otf2otc -o $SYSFONT/$RR $ORISYSFONT/$RR $SYSFONT/$SSS >/dev/null || abort
        xml "s|>$SSS|$id\"1\">$RR|"; rm $SYSFONT/$SSS
    }
    $SANS || $SERF || $MONO || $SRMO || return
    [ -f $SYSFONT/$Sa$Re$X -o -f $SYSFONT/$Se$Re$X -o \
      -f $SYSFONT/$Mo$Re$X -o -f $SYSFONT/$So$Re$X ] || return
    afdko || return
    xml "s|$RS|$RR|"; local ttfs i j k=0 
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
            [ -f $SYSFONT/${i%?}$Cn$j$X ] && {
                ttfs="$ttfs $SYSFONT/${i%?}$Cn$j$X"
                xml "s|>${i%?}$Cn$j$X|$id\"$k\">$RS|"
                eval "${i%?}${Cn%?}$j"ID=$k; k=$((k+1))
            }
        done
    done
    [ "$ttfs" ] || return
    ui_print '+ Font spoofing'
    otf2otc -o $SYSFONT/$RS $ttfs >/dev/null || abort

    if [ $PXL ]; then
        [ $SS ] || {
            for i in $Re $It $Me $Me$It $SBo $SBo$It $Bo $Bo$It; do
                eval mv $SYSFONT/$"$i$X" $PRDFONT
            done
            local XML=$PRDXML la=Lato- zs=ZillaSlab-
            falias zilla-slab-medium $Gs
            for i in $Re $It $Me $Me$It $Bo $Bo$It; do
                eval ln -s $"$i$X" $PRDFONT/$la$i$X
                eval $(echo "xml \"s|>\$$i$X|>$la$i$X|\"")
            done
            eval ln -s $"$SBo$X" $PRDFONT/$zs$SBo$X
            eval ln -s $"$SBo$It$X" $PRDFONT/$zs$SBo$It$X
            eval $(echo "xml \"s|>\$$SBo$X|>$zs$SBo$X|\"")
            eval $(echo "xml \"s|>\$$SBo$It$X|>$zs$SBo$It$X|\"")
        }
    elif [ $OOS ]; then cp $SYSXML $SYSETC/fonts_slate.xml
    elif [ $OOS11 ]; then cp $SYSXML $SYSETC/fonts_base.xml
    elif [ $COS ]; then cp $SYSXML $SYSEXTETC/fonts_base.xml
    elif [ $LGE ]; then cp $SYSXML $SYSETC/fonts_lge.xml; fi
    rm $ttfs
}

valof() {
    sed -n "s|^$1[[:blank:]]*=[[:blank:]]*||p" $UCONF | \
    sed 's|[[:blank:]][[:blank:]]*| |g;s| $||' | \
    tail -${2:-1}
}

styof() {
    [ -f $UCONF ] || return
    s=$(valof $1); [ "$s" ] || return
    p=$(sed -n "/^# $s$/{n;s|^# ||;p}" $UCONF | tail -1)
    [ "$p" ] && echo $p || {
        echo $s | grep -Eq 'wdth|opsz|ital|wght|slnt' && \
        echo $s || rm $UCONF
    }
}

config() {
    local dconf dver uver
    dconf=$MODPATH/config.cfg dver=`sed -n '/###/,$p' $dconf`
    UCONF=$OMFDIR/config.cfg uver=`sed -n '/###/,$p' $UCONF`
    [ "$uver" != "$dver" ] && {
        cp $UCONF $UCONF~; cp $dconf $UCONF; ui_print '  Reset'
    }

    SANS=`valof SANS` MONO=`valof MONO` SERF=`valof SERF` SRMO=`valof SRMO`
    FULL=`valof FULL` GS=`valof GS`     BOLD=`valof BOLD` STATIC=`valof STATIC`

    [ ${SANS:=true} ]; [ ${SERF:=true} ]; [ ${MONO:=true} ];  [ ${SRMO:=true} ]
    [ ${LAST:=true} ]; [ ${GS:=false} ];  [ ${BOLD:=false} ]; [ ${STATIC:=false} ]

    SS=`valof SS`   SSI=`valof SSI`   MS=`valof MS`   MSI=`valof MSI`
    SER=`valof SER` SERI=`valof SERI` SRM=`valof SRM` SRMI=`valof SRMI`

    ORISS=$SS ORISSI=$SSI ORISER=$SER ORISERI=$SERI
    ORIMS=$MS ORIMSI=$MSI ORISRM=$SRM ORISRMI=$SRMI

    for i in $FW; do i=`up $i`
        eval U$i=\"`styof U$i`\"
        eval I$i=\"`styof I$i`\"
        [ $SSI ] || { eval [ \"\$I$i\" ] && SSI=$SS; }
        eval [ \"\${I$i:=\$U$i}\" ]
        eval C$i=\"`styof C$i`\"
        eval [ \"\${C$i:=\$U$i}\" ]
        eval D$i=\"`styof D$i`\"
        eval [ \"\${D$i:=\$I$i}\" ]
        eval M$i=\"`styof M$i`\"
        eval S$i=\"`styof S$i`\"
        eval O$i=\"`styof O$i`\"
    done
}

sans_serif() { true; }
serif() { true; }
monospace() { true; }
serif_monospace() { true; }

install_font() {
    rename
    $SANS && {
        if [ $SANS = true ]; then sans
        elif [ $SANS = $SE ]; then serf $SA; SS=$ORISER SSI=$ORISERI
        elif [ $SANS = $MO ]; then mono $SA; SS=$ORIMS SSI=$ORIMSI
        elif [ $SANS = serif_$MO ]; then srmo $SA; SS=$ORISRM SSI=$ORISRMI; fi
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
        $FULL && [ ! $SS ] && [ -f $SYSFONT/$f$Re$X ] && {
            eval "[ $"$It" ] || $It=$"$Re""
            eval "[ $"${Cn%?}$Re" ] || ${Cn%?}$Re=$"$Re""
            eval "[ $"${Cn%?}$It" ] || ${Cn%?}$It=$"$It""
            lnf "$Me $SBo" "$Me $SBo $Bo" "$Bo" "$EBo $Bl $SBo $Me"
            lnf "$EBo $Bl" "$Bl $EBo $Bo $SBo $Me"
            lnf "$Li" "$ELi $Th" "$ELi $Th" "$Th $ELi $Li"
        }
        bold; static
    }
    $SERF && {
        if [ $SERF = true ]; then serf
        elif [ $SERF = sans_$SE ]; then sans $SE; SER=$ORISS SERI=$ORISSI
        elif [ $SERF = $MO ]; then mono $SE; SER=$ORIMS SERI=$ORIMSI
        elif [ $SERF = serif_$MO ]; then srmo $SE; SER=$ORISRM SERI=$ORISRMI; fi
    }
    $MONO && {
        if [ $MONO = true ]; then mono
        elif [ $MONO = serif_$MO ]; then srmo $MO; MS=$ORISRM MSI=$ORISRMI; fi
    }
    $SRMO && {
        if [ $SRMO = true ]; then srmo
        elif [ $SRMO = $MO ]; then mono $SO; SRM=$ORIMS SRMI=$ORIMSI; fi
    }
    $EMOJ && emoj
}

finish() {
    find $MODPATH/* -maxdepth 0 ! \( -name 'system' -o -name 'module.prop' \) -exec rm -rf {} \;
    find $MODPATH/* -type d -delete 2>/dev/null
    find $MODPATH/system -type d -exec chmod 755 {} \;
    find $MODPATH/system -type f -exec chmod 644 {} \;
    [ "$AFDKO" = true ] && umount -r $TERMUX && rmdir -p $TERMUX
}

restart() {
    local reboot=`valof reboot`
    local modpath=/data/adb/modules/$MODID
    ${reboot:=false} && {
        [ -d $modpath/system ] || reboot
        local old=`find $modpath/system -type f -exec basename {} \;`
        local new=`find $MODPATH/system -type f -exec basename {} \;`
        [ "$old" = "$new" ] || reboot
        cp -r $MODPATH/system $modpath
        setprop ctl.restart zygote
    }
}

trap restart 0
return

PAYLOAD:
˝7zXZ  Ê÷¥F¿¿ÄP!       ƒG‡'ˇ∏] 3 €π·h»?7‰€=Pˆc{A“6≤%J)H$lˇZ—et¢Ÿ[´p#ò …ŸŸd1{ì2øQ`ˆFå@ '±Ë˝“$k‹F±ô¥
π›‰NH≠Oj˝mÑ#+ü}ùar*rWΩ›´°’d,ﬂ)¸|T™Â ‹ΩΩ˚£ŸÁÙNmÑ%vÁ‰Å£¬,DÎâjÄ3sâ	vh¬^JœÇñ˘Z9}îäB’^è£†bdR"⁄çêQﬁﬂ’|éÿP2paZ”aY‹
Za´.B~Åyn®˜%{!6°…„ˇs@ã≤¸]!ı≈{≈<Ÿ[›Drwy+j≈H\ØÌË%
£?Ñ≥˛5sÙ±)™µóq¥ä1C\,ƒî≥#Ÿ∑ ,2^⁄∞¨§q8Œ—ó˚¯G!™Ú ‚ƒ“ƒß€{ ≤6Å•
4Cè!Z0Ωô™&:îé]| 3Æ”e‚aD:˛Ó5√∏ıhOœ≈áàt∫Ÿ0)f	í—Ïùf¨.	¸Vtç»Ú3ÁŸÿVìN\Q“Òir÷Z .∂>´à≤ìnèÒŒ∆9P+m‰¿>)ûc˛W  6È¯B. ‹ÄP  “ÍÏ`±ƒg˚    YZ
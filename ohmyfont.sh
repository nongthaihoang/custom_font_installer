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

FONTS=$MODPATH/fonts
tar xf $MODPATH/*xz -C $MODPATH

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
Cn=Condensed- X=.ttf
readonly Bl Bo EBo SBo Me Th Li ELi Re It Cn X

FB=fallback

ver() { sed -i "/^version=/s|$|-$1|" $MODPROP; }

xml() {
    [ ${XML:=$SYSXML} ]
    case $XML_LIST in
        *$XML*) ;;
        *)
            sed -i '/<!--.*-->/d;/<!--/,/-->/d' $XML
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

src() {
    local l=`find $OMFDIR -maxdepth 1 -type f -name '*.sh' -exec basename {} \; | sort` i
    [ "$1" = 0 ] && l=`echo "$l" | grep '^0'` || l=`echo "$l" | grep '^[^0]'`
    for i in $l; do
        ui_print "+ Source $i"
        . $OMFDIR/$i
    done
}

cpf() {
    [ $# -eq 0 ] && return 1; local i
    for i in $@; do false | cp -i $FONTS/$i ${CPF:=$SYSFONT} 2>/dev/null; done
}

fallback() {
    local faq fae fb
    [ $1 ] && local fa=$1; [ $fa ] || local fa=$SA
    faq="\"${fa}\"" fae="/$FA.*$faq/,$FAE"
    [ $fa = $SA ] || fb="/<$F/s|>| $FF=$faq>|;"
    xml "$fae{${fb}H;2,$FAE{${FAE}G}}"
    xml ":a;N;\$!ba;s|name=$faq||2"
}

prep() {
    [ -f $ORISYSXML ] || abort "! $ORISYSXML not found"
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

    shift 3; [ $# -eq 0 ] && {
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

finish() {
    find $MODPATH/* -maxdepth 0 ! \( -name 'system' -o -name 'module.prop' \) -exec rm -rf {} \;
    find $MODPATH/* -type d -delete 2>/dev/null
    find $MODPATH/system -type d -exec chmod 755 {} \;
    find $MODPATH/system -type f -exec chmod 644 {} \;
}

lnf(){
    local i j
    while [ "$2" ]; do
        for i in $1; do
            [ -f $FONTS/$i$X ] || {
                for j in $2; do
                    [ -f $FONTS/$j$X ] && { ln -s $j$X $FONTS/$i$X; break; }
                done
            }
            [ -f $FONTS/$i$X ] || ln -s $Re$X $FONTS/$i$X
            [ -f $FONTS/$i$It$X ] || ln -s $i$X $FONTS/$i$It$X
            [ -f $FONTS/$Cn$i$X ] || ln -s $i$X $FONTS/$Cn$i$X
            [ -f $FONTS/$Cn$i$It$X ] || ln -s $i$It$X $FONTS/$Cn$i$It$X
        done
        shift 2
    done
}

up() { echo $@ | tr [:lower:] [:upper:]; }

rename() {
    set bli $Bl$It bl $Bl ebi $EBo$It eb $EBo bi $Bo$It b $Bo \
        sbi $SBo$It sb $SBo mi $Me$It m $Me i $It r $Re \
        li $Li$It l $Li eli $ELi$It el $ELi ti $Th$It t $Th
    while [ $2 ]; do
        ([ -f $FONTS/$1$X ] || [ -f $FONTS/$1.otf ]) && mv $FONTS/$1.[to]tf $FONTS/$2$X
        ([ -f $FONTS/c$1$X ] || [ -f $FONTS/c$1.otf ]) && mv $FONTS/c$1.[to]tf $FONTS/$Cn$2$X
        shift 2
    done
    set mo Mono e Emoji
    while [ $2 ]; do
        ([ -f $FONTS/$1$X ] || [ -f $FONTS/$1.otf ]) && mv $FONTS/$1.[to]tf $FONTS/$2$X
        shift 2
    done
}

install_font() {
    rename
    $EMOJ && emoji
    $MONO && mono
    $SANS || abort
    cpf $SS && {
        local i j=4 k=4
        for i in m sb b eb bl; do
            eval $(echo "[ \"\$U`up $i`\" ] && j=$((j+1)) || break")
        done
        for i in l el t; do
            eval $(echo "[ \"\$U`up $i`\" ] && k=$((k-1)) || break")
        done
        for i in $SA $SC; do mksty $i $j $k; done
        cpf $SSI
        for i in $FW; do
            eval $(echo font $SA $SS $i \$U`up $i`)
            eval $(echo font $SA $SSI ${i}i \$I`up $i`)
            eval $(echo font $SC $SS $i \$C`up $i`)
            eval $(echo font $SC $SSI ${i}i \$D`up $i`)
        done
        return
    }
    ${FULL:=`valof FULL`} && {
        [ -f $FONTS/$Re$X ] || return
        lnf "$Me $SBo" "$Me $SBo $Bo" "$Bo" "$EBo $Bl $SBo $Me"
        lnf "$EBo $Bl" "$Bl $EBo $Bo $SBo $Me"
        lnf "$Li" "$ELi $Th" "$ELi $Th" "$Th $ELi $Li"
        [ -f $FONTS/$It$X ] || ln -s $Re$X $FONTS/$It$X
        [ -f $FONTS/$Cn$Re$X ] || ln -s $Re$X $FONTS/$Cn$Re$X
        [ -f $FONTS/$Cn$It$X ] || ln -s $It$X $FONTS/$Cn$It$X
        mksty; mksty $SC
        set $Th t $ELi el $Li l $Me m $SBo sb $Bo b $EBo eb $Bl bl
        while [ $2 ]; do
            cp -P $FONTS/$1$X $SYSFONT && font $SA $1$X $2
            cp -P $FONTS/$1$It$X $SYSFONT && font $SA $1$It$X $2i
            cp -P $FONTS/$Cn$1$X $SYSFONT && font $SC $Cn$1$X $2
            cp -P $FONTS/$Cn$1$It$X $SYSFONT && font $SC $Cn$1$It$X $2i
            shift 2
        done
        set $Re r $It ri
        while [ $2 ]; do
            cp -P $FONTS/$1$X $SYSFONT && font $SA $1$X $2
            cp -P $FONTS/$Cn$1$X $SYSFONT && font $SC $Cn$1$X $2
            shift 2
        done
    } || {
        set bli $Bl$It bl $Bl ebi $EBo$It eb $EBo bi $Bo$It b $Bo \
            sbi $SBo$It sb $SBo mi $Me$It m $Me i $It r $Re \
            li $Li$It l $Li eli $ELi$It el $ELi ti $Th$It t $Th
        while [ $2 ]; do
            [ -f $FONTS/$2$X ] && font $SA $2$X $1
            [ -f $FONTS/$Cn$2$X ] && font $SC $Cn$2$X $1
            shift 2
        done
    }
}

emoji() { cpf Emoji$X && font und-Zsye Emoji$X r; }

mono() {
    cpf Mono$X && font $MO Mono$X r && return
    MS=`valof MS` MSI=`valof MSI`; cpf $MS || return
    local i j=4 k=4
    for i in m sb b eb bl; do
        eval $(echo "[ \"\$M`up $i`\" ] && j=$((j+1)) || break")
    done
    for i in l el t; do
        eval $(echo "[ \"\$M`up $i`\" ] && k=$((k-1)) || break")
    done
    [ $MSI ] || local italic=false; mksty $MO $j $k
    for i in $FW; do
        eval $(echo font $MO $MS $i \$M`up $i`)
        [ $MSI ] && eval $(echo font $MO $MSI ${i}i \$M`up $i`)
    done
}

bold() {
    BOLD=`valof BOLD`; [ $SS ] && return
    ${BOLD:=false} && {
        cp `readlink -f $SYSFONT/$Me$X` `readlink -f $SYSFONT/$Re$X`
        cp `readlink -f $SYSFONT/$Me$It$X` `readlink -f $SYSFONT/$It$X`
        [ $PXL ] && {
            ln -sf $Me$X $PRDFONT/$Re$X
            ln -sf $Me$It$X $PRDFONT/$It$X
        }
    }
}

rom() {
    # Pixel
    readonly Gs=GoogleSans
    [ -f $ORIPRDFONT/$Gs-$Re$X ] && cp $ORIPRDXML $PRDXML && {
        PXL=true; ver pxl
        [ ${GS:=`valof GS`} ]; ${GS:=false} && return
        local XML=$PRDXML fa=google-sans.* i
        [ $SS ] && {
            ln -s /system/fonts/$SS $PRDFONT
            ln -s /system/fonts/$SSI $PRDFONT
            for i in r m sb b; do
                eval $(echo font $fa $SS $i \$U`up $i`)
                eval $(echo font $fa $SSI ${i}i \$I`up $i`)
            done
            return
        }
        set $Bo$It bi $Bo b $SBo$It sbi $SBo sb $Me$It mi $Me m $Re r $It ri
        while [ $2 ]; do
            [ -f $SYSFONT/$1$X ] && ln -s /system/fonts/$1$X $PRDFONT
            font $fa $1$X $2
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
        MIUI=true
        [ -f $ORISYSFONT/RobotoVF$X ] && {
            MIUI=eu; ver mieu; return
        }
        ver miui; return
    }

    # Samsung
    grep -q Samsung $ORISYSXML && {
        SAM=true; ver sam
        [ $SS ] && {
            font sec-roboto-light $SS r $UR
            font sec-roboto-light $SS b $UM
            font sec-roboto-condensed $SS r $CR
            font sec-roboto-condensed $SS b $CB
            font sec-roboto-condensed-light $SS r $CL
            return
        }
        font sec-roboto-light $Re$X r
        font sec-roboto-light $Me$X b
        font sec-roboto-condensed $Cn$Re$X r
        font sec-roboto-condensed $Cn$Bo$X b
        font sec-roboto-condensed-light $Cn$Li$X r
        return
    }

    # LG
    local lg=lg-sans-serif
    grep -q $lg $SYSXML && {
        local lgq="/\"$lg\">/" lgf="$lgq,$FAE"
        xml "$lqf{$lgq!d};$SAF{$SAQ!H};${lgq}G"
        LG=true; ver lg; return
    }

    # LG (lgexml)
    [ -f $ORISYSETC/fonts_lge.xml ] && {
        cp $SYSXML $SYSETC/fonts_lge.xml
        LGE=true; ver lgexml; return
    }
}

valof() {
    sed -n "s|^$1[[:blank:]]*=[[:blank:]]*||p" $UCONF | \
    sed 's|[[:blank:]][[:blank:]]*| |g;s| $||' | \
    tail -${2:-1}
}

config() {
    local dconf dver uver
    [ -d ${OMFDIR:=/sdcard/OhMyFont} ] || mkdir $OMFDIR
    dconf=$MODPATH/config.cfg dver=`sed -n '/###/,$p' $dconf`
    UCONF=$OMFDIR/config.cfg uver=`sed -n '/###/,$p' $UCONF`
    [ "$uver" != "$dver" ] && {
        cp $UCONF $UCONF~; cp $dconf $UCONF; ui_print '  Reset'
    }

    SANS=`valof SANS` MONO=`valof MONO`
    SERF=`valof SERF` SRMO=`valof SRMO`

    SS=`valof SS` SSI=`valof SSI`
    [ ${SSI:=$SS} ] && \
    for i in $FW; do i=`up $i`
        eval $(echo U$i=\"`valof U$i`\")
        eval $(echo I$i=\"`valof I$i`\")
        eval $(echo [ \"\${I$i:=\$U$i}\" ])
        eval $(echo C$i=\"`valof C$i`\")
        eval $(echo [ \"\${C$i:=\$U$i}\" ])
        eval $(echo D$i=\"`valof D$i`\")
        eval $(echo [ \"\${D$i:=\$I$i}\" ])
        eval $(echo M$i=\"`valof M$i`\")
        eval $(echo S$i=\"`valof S$i`\")
    done
}

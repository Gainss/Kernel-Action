#!/bin/bash
clang_path="$GITHUB_WORKSPACE/kernel/tool/proton-clang/bin/clang"
gcc_path="$GITHUB_WORKSPACE/kernel/tool/proton-clang/bin/aarch64-linux-gnu-"
gcc_32_path="$GITHUB_WORKSPACE/kernel/tool/proton-clang/bin/arm-linux-gnueabi-"

date="`date +"%Y%m%d%H%M"`"
firstver="Marisa"
device="raphael"
device1="cepheus"
middlever="r23"

args="-j256 O=out \
	ARCH=arm64 \
	SUBARCH=arm64 "

args+="CC=$clang_path \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	CROSS_COMPILE=$gcc_path "

args+="CROSS_COMPILE_ARM32=$gcc_32_path "

clean(){
	make mrproper
	make $args mrproper
}

tg_upload(){
    curl -s https://api.telegram.org/bot"${BOTTOKEN}"/sendDocument -F document=@"${1}" -F chat_id="${CHATID}"
}

tg_notify(){
    curl -s https://api.telegram.org/bot"${BOTTOKEN}"/sendMessage -d parse_mode="Markdown" -d text="${1}" -d chat_id="${CHATID}"
}

log(){
	tg_notify "LOG: ${1}"
}

terminate(){
  log "${1}"
  exit 1
}


build1(){
	export KBUILD_BUILD_USER="G010R0KU"
	export KBUILD_BUILD_HOST="MarisaKernel"
args+="LOCALVERSION=-${middlever}-${date} "
	make $args ${device}_defconfig&&make $args
	if [ $? -ne 0 ]; then
    terminate "Error while building for ${device}!"
    fi
	mkzip1
	tg_notify "Finish building ${device}!"
}

mkzip1(){
	mv -f ~/src/out/arch/arm64/boot/Image-dtb ~/src/anykernel3
	mv -f ~/src/out/arch/arm64/boot/dtbo.img ~/src/anykernel3
	cd ~/src/anykernel3
	zip -r "MarisaKernel-${device}-$middlever-$date.zip" *
	mv -f "MarisaKernel-${device}-$middlever-$date.zip" ${HOME}
	cd ${HOME}
	log "Finish making zip for ${device}!"
	tg_upload "MarisaKernel-${device}-$middlever-$date.zip"
	cd $source
}

build2(){
	export KBUILD_BUILD_USER="G010R0KU"
	export KBUILD_BUILD_HOST="MarisaKernel"
args+="LOCALVERSION=-${middlever}-${date} "
	make $args ${device1}_defconfig&&make $args
	if [ $? -ne 0 ]; then
    terminate "Error while building for ${device1}!"
    fi
	mkzip2
	tg_notify "Finish building ${device1}!"
}

mkzip2(){
	mv -f ~/src/out/arch/arm64/boot/Image-dtb ~/src/anykernel3
	mv -f ~/src/out/arch/arm64/boot/dtbo.img ~/src/anykernel3
	cd ~/src/anykernel3
	zip -r "MarisaKernel-${device1}-$middlever-$date.zip" *
	mv -f "MarisaKernel-${device1}-$middlever-$date.zip" ${HOME}
	cd ${HOME}
	log "Finish making zip for ${device1}!"
	tg_upload "MarisaKernel-${device1}-$middlever-$date.zip"
	cd $source
}

tg_notify "LOG: START BUILDING!"
cd /drone/src
git submodule init
git submodule update

clean
git reset --hard
build1
cd /drone/src
build2
cd /drone/src

log "Build finished for #${DRONE_BUILD_NUMBER} ( ${date} )."

cd ${ANYKERNEL_DIR}
rm *.zip
zip -r9 Gains_Kernel.zip * -x README Gains_Kernel.zip

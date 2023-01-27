DEFCONFIG=virgo_defconfig
OBJ_DIR=`pwd`/.obj
TOOL=$GITHUB_WORKSPACE/kernel/tool/arm/bin/arm-linux-androideabi-
ANYKERNEL_DIR=tool/AnyKernel

if [ ! -d ${OBJ_DIR} ]; then
    mkdir ${OBJ_DIR}
fi

make ARCH=arm O=$OBJ_DIR CROSS_COMPILE=${TOOL} $DEFCONFIG
make -j$(grep -c ^processor /proc/cpuinfo) ARCH=arm O=$OBJ_DIR CROSS_COMPILE=${TOOL}
rm -f ${ANYKERNEL_DIR}/zImage*
rm -f ${ANYKERNEL_DIR}/dtb*
cp $OBJ_DIR/arch/arm/boot/zImage-dtb ${ANYKERNEL_DIR}
cp $OBJ_DIR/drivers/staging/prima/wlan.ko ${ANYKERNEL_DIR}/modules
cd ${ANYKERNEL_DIR}
rm *.zip
zip -r9 Gains_Kernel.zip * -x README Gains_Kernel.zip

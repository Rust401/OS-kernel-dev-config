#!/bin/bash

TARGET=$1
VALID=0

if [ $TARGET = "qcom414" ]; then
LNX_PATH="/home/ruty/ext/qcom414/msm-4.14"
VALID=1
fi

if [ $VALID = "1" ]; then

#find paths for files to be linked
echo start to generate cscope.files in $LNX_PATH
find $LNX_PATH                                                                     \
	-path "$LNX_PATH/arch/*" ! -path "$LNX_PATH/arch/arm64*" -prune -o         \
	-path "$LNX_PATH/include/asm-*" -prune -o                                  \
	-path "$LNX_PATH/tmp*" -prune -o                                           \
	-path "$LNX_PATH/Documentation*" -prune -o                                 \
	-path "$LNX_PATH/scripts*" -prune -o                                       \
	-path "$LNX_PATH/drivers*" -prune -o                                       \
	-name "*.[chxsS]" -print > $LNX_PATH/cscope.files
echo cscope.files generated !

#generate cscope database
echo change dir
cd $LNX_PATH
echo begin to generate cscope database
cscope -b -k -q
echo database generated in cscope.out
cd -
echo change dir back

fi

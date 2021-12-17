#!/bin/bash

TARGET=$1
VALID="false"

#add new linux-kernel dir here
if [ $TARGET = "qcom414" ]; then
LNX_PATH="/home/ruty/ext/qcom414/msm-4.14"
VALID="true"
fi

if [ $TARGET = "oh510" ]; then
LNX_PATH="/home/ruty/ext/linux-kernel/linux"
VALID="true"
fi


if [ $VALID = "true" ]; then

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

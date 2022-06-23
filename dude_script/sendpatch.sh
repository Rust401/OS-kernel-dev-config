REMOTE_PORT=18389
REMOTE_USER=s00417910
REMOTE_IP=123.60.8.121
REMOTE_HOME_PATH=/mnt/sdc4/s00417910

# for remote OH-full
REMOTE_OH_PATH=$REMOTE_HOME_PATH/openHarmony-full
REMOTE_KERNEL_PATH=$REMOTE_OH_PATH/kernel/linux/linux-5.10

REMOTE_OUT_PATH=$REMOTE_OH_PATH/out/rk3568/packages/phone/images
REMOTE_IMG_PATH=$REMOTE_OH_PATH/img

REMOTE_PATCH_NAME=$REMOTE_KERNEL_PATH/dude.patch
REMOTE_BASE_COMMIT=be7d4acccf1345306307c31c0d4b12c15310085c

REMOTE_BUILD_CMD="./build.sh --product-name rk3568 --ccache --target-cpu arm64"

# for remote oh-ws
REMOTE_OH_WS_PATH=$REMOTE_HOME_PATH/ext/oh-ws/kernel_linux_5.10
REMOTE_OH_WS_BASE_COMMIT=fe6b26587dad6e2b94c596add0977afd65ca7043

LOCAL_PATCH_NAME=$PWD/0001-add-uid-based-authority-for-rtg-06211854.patch
LOCAL_BASE_COMMIT=b05cc4c3011f9e11ea178787b25709a1ce9b6582

SSH_TARGET="ssh -t -p $REMOTE_PORT $REMOTE_USER@$REMOTE_IP"

# generated local patch
cd $PWD
git format-patch $LOCAL_BASE_COMMIT

echo "local patch generated!"

# copy patch to remote oh-kernel
scp -P $REMOTE_PORT $LOCAL_PATCH_NAME $REMOTE_USER@$REMOTE_IP:$REMOTE_PATCH_NAME

echo "patch copyed to remote server"

# compile the remote oh-kernel
$SSH_TARGET "cd $REMOTE_KERNEL_PATH;\
             git reset --hard $REMOTE_BASE_COMMIT;\
             git am $REMOTE_PATCH_NAME;\
             rm -rf $REMOTE_OH_PATH/out;\
             cd $REMOTE_OH_PATH; $REMOTE_BUILD_CMD"

# copy output img to safe path
$SSH_TARGET "cp $REMOTE_OUT_PATH/* $REMOTE_IMG_PATH"

echo "img generated in $REMOTE_IMG_PATH"

# apply patch to remote oh-ws
$SSH_TARGET "cd $REMOTE_OH_WS_PATH;\
             git reset --hard $REMOTE_OH_WS_BASE_COMMIT;\
             git am $REMOTE_PATCH_NAME;\
             git push --force"

echo "MR to ws finished!"

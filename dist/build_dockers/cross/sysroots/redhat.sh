# file included from build_centos7/centos8/alma9
# $distr and $image should be set on inclusion of this file

arch=s390x
mkdir $arch
docker run --rm -v $(pwd):/sysroot --arch $arch --security-opt label=disable $image bash /sysroot/in_$distr.sh

. finalize.sh


https://manual.manticoresearch.com/Reporting_bugs#Reporting-bugs
https://manual.manticoresearch.com/Installation/Compiling_from_sources
manticoresearch(tag 6.3.8)/dist/build_dockers/cross/sysroots
wget https://archives.boost.io/release/1.80.0/source/boost_1_80_0.tar.gz
### add "-fno-omit-frame-pointer -mno-omit-leaf-frame-pointer" to cflags and cxxflags in mkboost.sh
vi debian.sh finalize.sh # force s390x arch if running off another arch
vi debian.sh # add podman option --security-opt=label=disable if running with podman+selinux
./build_jammy.sh
mv boost_include.tar s390x/
unzstd --rm s390x/*.zst
sed -i -e 's/-fuse-ld=lld/-fuse-ld=bfd/' ../linux.cmake # ld.lld: error: unknown emulation: elf64_s390
# also add -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer for Fedora build in linux.cmake
( cd .. && ln -s linux.cmake toolchain.cmake && tar --update -f sysroots/s390x/sysroot_jammy_s390x.tar linux.cmake toolchain.cmake )
xz s390x/*.tar

# neither ld.lld nor ld.bdf seems to want to link for x390s
cd manticoresearch/dist/build_dockers/cross/external_toolchain
vi Dockerfile # bottstrap cmake from sources - install libssl-dev and replace 3 lines:
++&& export CXX=clang++-16 \
++&& curl -L https://github.com/Kitware/CMake/releases/download/v$cmakever/cmake-
$cmakever.tar.gz | tar -zx \
++&& cd cmake-$cmakever && ./bootstrap && make && make install
podman build --squash --arch s390x -t manticoresearch/external_toolchain:s390x .

cd manticore
# vi CMakeLists.txt # add set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY") before PROJECT()
vi CMakeLists.txt # add set(UNALIGNED_RAM_ACCESS_EXITCODE "0") see cmake/check_unaligned_ram_access.cmake
# podman run --security-opt=label=disable -it --rm -e CACHEB="../cache" -e DIAGNOSTIC=1 -e PACK_ICUDATA=0 -e NO_TESTS=1 -e DISTR=jammy -e boost=s390x -e sysroot=s390x -e arch=s390x -e CTEST_CMAKE_GENERATOR=Ninja -e CTEST_CONFIGURATION_TYPE=RelWithDebInfo -e WITH_COVERAGE=0 -e SYSROOT_URL="file:///manticore_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/dist/build_dockers/cross/sysroots" -e HOMEBREW_PREFIX="" -e PACK_GALERA=0 -v $(pwd):/manticore_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa manticoresearch/external_toolchain:clang16_cmake3263 bash
podman run --security-opt=label=disable -it --rm -e CACHEB="../cache" -e DIAGNOSTIC=1 -e PACK_ICUDATA=0 -e NO_TESTS=1 -e DISTR=jammy -e boost=s390x -e sysroot=s390x -e arch=s390x -e CTEST_CMAKE_GENERATOR=Ninja -e CTEST_CONFIGURATION_TYPE=RelWithDebInfo -e WITH_COVERAGE=0 -e SYSROOT_URL="file:///manticore_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/dist/build_dockers/cross/sysroots" -e HOMEBREW_PREFIX="" -e PACK_GALERA=0 -v $(pwd):/manticore_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa quay.io/3scale/searchd:external_toolchain_s390x bash
cd /manticore_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/
mkdir -p build && cd build
cmake -DPACK=1 ..
cmake --build . --target package

https://repo.manticoresearch.com/repository/manticoresearch_bookworm/dists/bookworm/main/binary-amd64/manticore-tzdata_1.0.0-240522-a8aa66e_all.deb


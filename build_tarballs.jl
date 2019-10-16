# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "binaryen"
version = v"89.0.0"

# Collection of sources required to build binaryen
sources = [
    "https://github.com/WebAssembly/binaryen.git" =>
    "e2f49d8227f2b71e4dede5cf4074bb9f65e3d77f",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd binaryen/
sed -i -e 's/Windows.h/windows.h/g' src/tools/wasm-reduce.cpp 
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain .
make -j8
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    ExecutableProduct(prefix, "wasm-as", :wasm_as),
    LibraryProduct(prefix, "libbinaryen", :libbinaryen),
    ExecutableProduct(prefix, "wasm-opt", :wasm_opt),
    ExecutableProduct(prefix, "wasm-shell", :wasm_shell),
    ExecutableProduct(prefix, "wasm2js", :wasm2js),
    ExecutableProduct(prefix, "wasm-reduce", :wasm_reduce),
    ExecutableProduct(prefix, "wasm-metadce", :wasm_metadce),
    ExecutableProduct(prefix, "wasm-dis", :wasm_dis),
    ExecutableProduct(prefix, "wasm-ctor-eval", :wasm_ctor_eval),
    ExecutableProduct(prefix, "wasm-emscripten-finalize", :wasm_emscripten_finalize),
    ExecutableProduct(prefix, "asm2wasm", :asm2wasm)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)


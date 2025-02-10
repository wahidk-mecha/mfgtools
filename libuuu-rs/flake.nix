{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem 
  (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) stdenv lib;

      libraries = with pkgs; [
        rustPlatform.bindgenHook
        libusb1
        pkg-config
        glib
        zstd
        bzip2
        cryptopp
        openssl_3
        tinyxml-2
      ];

      packages = with pkgs; [
        cargo
        rustc
        cmake
      ];
    in 
    {
      devShell = pkgs.mkShell {
        nativeBuildInputs = libraries;
        buildInputs = packages;

        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
        LIBUSB_HEADERS = "${pkgs.libusb1.dev}/include";

        BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) \
          $(< ${stdenv.cc}/nix-support/libc-cflags) \
          $(< ${stdenv.cc}/nix-support/cc-cflags) \
          $(< ${stdenv.cc}/nix-support/libcxx-cxxflags) \
          ${lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc}/lib/clang/${lib.getVersion stdenv.cc.cc}/include"} \
          ${lib.optionalString stdenv.cc.isGNU "-isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include"}";
      };
    }
  );
}

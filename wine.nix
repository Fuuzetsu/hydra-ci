{ pkgs ? import <nixpkgs> {} }:
assert pkgs.stdenv.isLinux;
assert pkgs.stdenv.gcc.gcc != null;

let

in rec {
  wine-ffxia = pkgs.lib.genAttrs [ "i686-linux" ] (system:
    let
      pkgs = import <nixpkgs> { inherit system; };

      version = "HEAD-ffxia";
      name = "wine-${version}";
      src = <wine>;

      gecko = pkgs.fetchurl {
        url = "mirror://sourceforge/wine/wine_gecko-2.24-x86.msi";
        sha256 = "0b10f55q3sldlcywscdlw3kd7vl9izlazw7jx30y4rpahypaqf3f";
      };

      gecko64 = pkgs.fetchurl {
        url = "mirror://sourceforge/wine/wine_gecko-2.24-x86_64.msi";
        sha256 = "1j4wdlhzvjrabzr9igcnx0ivm5mcb8kp7bwkpfpfsanbifk7sma7";
      };

      mono = pkgs.fetchurl {
        url = "mirror://sourceforge/wine/wine-mono-4.5.2.msi";
        sha256 = "1bgasysf3qacxgh5rlk7qlw47ar5zgd1k9gb22pihi5s87dlw4nr";
      };

    in
    pkgs.releaseTools.nixBuild {

      inherit version name src;

      patches = [ ./ffxia.patch ];

      buildInputs = with pkgs; [
        pkgconfig
        xlibs.xlibs flex bison xlibs.libXi mesa mesa_noglu.osmesa
        xlibs.libXcursor xlibs.libXinerama xlibs.libXrandr
        xlibs.libXrender xlibs.libXxf86vm xlibs.libXcomposite
        alsaLib ncurses libpng libjpeg lcms fontforge
        libxml2 libxslt openssl gnutls cups makeWrapper
      ];

      # Wine locates a lot of libraries dynamically through dlopen().  Add
      # them to the RPATH so that the user doesn't have to set them in
      # LD_LIBRARY_PATH.
      NIX_LDFLAGS = with pkgs; map (path: "-rpath ${path}/lib ") [
        freetype fontconfig stdenv.gcc.gcc mesa mesa_noglu.osmesa libdrm
        xlibs.libXinerama xlibs.libXrender xlibs.libXrandr
        xlibs.libXcursor xlibs.libXcomposite libpng libjpeg
        openssl gnutls cups
      ];

      # Don't shrink the ELF RPATHs in order to keep the extra RPATH
      # elements specified above.
      dontPatchELF = true;

      postInstall = ''
        install -D ${gecko} $out/share/wine/gecko/${gecko.name}
      '' + pkgs.stdenv.lib.optionalString (pkgs.stdenv.system == "x86_64-linux") ''
        install -D ${gecko} $out/share/wine/gecko/${gecko64.name}
      '' + ''
        install -D ${mono} $out/share/wine/mono/${mono.name}
        wrapProgram $out/bin/wine --prefix LD_LIBRARY_PATH : ${pkgs.stdenv.gcc.gcc}/lib
      '';

      enableParallelBuilding = true;

      meta = {
        homepage = "http://www.winehq.org/";
        license = "LGPL";
        inherit version;
        description = "An Open Source implementation of the Windows API on top of X, OpenGL, and Unix";
        maintainers = [pkgs.stdenv.lib.maintainers.raskin];
        platforms = pkgs.stdenv.lib.platforms.linux;
      };
    });
}

{ stdenv, fetchurl, buildPythonApplication, makeQtWrapper, wrapGAppsHook
, qtbase, pyqt5, jinja2, pygments, pyyaml, pypeg2, glib_networking
, asciidoc, docbook_xml_dtd_45, docbook_xsl, libxml2, libxslt
, gst-plugins-base, gst-plugins-good, gst-plugins-bad, gst-plugins-ugly, gst-libav
, qtwebkit-plugins }:

let version = "0.8.2"; in

buildPythonApplication rec {
  name = "qutebrowser-${version}";
  namePrefix = "";

  src = fetchurl {
    url = "https://github.com/The-Compiler/qutebrowser/releases/download/v${version}/${name}.tar.gz";
    sha256 = "1kfxjdn1dqla8d8gcggp55zcgf4zb77knkfshd213my0iw2yzgcf";
  };

  # Needs tox
  doCheck = false;

  buildInputs = [
    qtbase qtwebkit-plugins
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav
    glib_networking
  ];

  nativeBuildInputs = [
    makeQtWrapper wrapGAppsHook asciidoc docbook_xml_dtd_45 docbook_xsl libxml2 libxslt
  ];

  propagatedBuildInputs = [
    pyyaml pyqt5 jinja2 pygments pypeg2
  ];

  postPatch = ''
    sed -i "s,/usr/share/qutebrowser,$out/share/qutebrowser,g" qutebrowser/utils/standarddir.py
  '';

  postBuild = ''
    a2x -f manpage doc/qutebrowser.1.asciidoc
  '';

  postInstall = ''
    mv $out/bin/qutebrowser $out/bin/.qutebrowser-noqtpath
    makeQtWrapper $out/bin/.qutebrowser-noqtpath $out/bin/qutebrowser

    install -Dm644 doc/qutebrowser.1 "$out/share/man/man1/qutebrowser.1"
    install -Dm644 qutebrowser.desktop \
        "$out/share/applications/qutebrowser.desktop"
    for i in 16 24 32 48 64 128 256 512; do
        install -Dm644 "icons/qutebrowser-''${i}x''${i}.png" \
            "$out/share/icons/hicolor/''${i}x''${i}/apps/qutebrowser.png"
    done
    install -Dm644 icons/qutebrowser.svg \
        "$out/share/icons/hicolor/scalable/apps/qutebrowser.svg"
    install -Dm755 -t "$out/share/qutebrowser/userscripts/" misc/userscripts/*
  '';

  meta = {
    homepage = https://github.com/The-Compiler/qutebrowser;
    description = "Keyboard-focused browser with a minimal GUI";
    license = stdenv.lib.licenses.gpl3Plus;
    maintainers = [ stdenv.lib.maintainers.jagajaga ];
  };
}

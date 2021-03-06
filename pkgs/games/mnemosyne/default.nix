{ fetchurl
, python
}:

python.pkgs.buildPythonApplication rec {
  pname = "mnemosyne";
  version = "2.6.1";

  src = fetchurl {
    url    = "mirror://sourceforge/project/mnemosyne-proj/mnemosyne/mnemosyne-${version}/Mnemosyne-${version}.tar.gz";
    sha256 = "0xcwikq51abrlqfn5bv7kcw1ccd3ip0w6cjd5vnnzwnaqwdj8cb3";
  };

  propagatedBuildInputs = with python.pkgs; [
    pyqt5
    matplotlib
    cherrypy
    cheroot
    webob
    pillow
  ];

  # No tests/ directrory in tarball
  doCheck = false;

  prePatch = ''
    substituteInPlace setup.py --replace /usr $out
    find . -type f -exec grep -H sys.exec_prefix {} ';' | cut -d: -f1 | xargs sed -i s,sys.exec_prefix,\"$out\",
  '';

  postInstall = ''
    mkdir -p $out/share
    mv $out/${python.sitePackages}/$out/share/locale $out/share
    rm -r $out/${python.sitePackages}/nix
  '';

  meta = {
    homepage = https://mnemosyne-proj.org/;
    description = "Spaced-repetition software";
    longDescription = ''
      The Mnemosyne Project has two aspects:

        * It's a free flash-card tool which optimizes your learning process.
        * It's a research project into the nature of long-term memory.

      We strive to provide a clear, uncluttered piece of software, easy to use
      and to understand for newbies, but still infinitely customisable through
      plugins and scripts for power users.

      ## Efficient learning

      Mnemosyne uses a sophisticated algorithm to schedule the best time for
      a card to come up for review. Difficult cards that you tend to forget
      quickly will be scheduled more often, while Mnemosyne won't waste your
      time on things you remember well.

      ## Memory research

      If you want, anonymous statistics on your learning process can be
      uploaded to a central server for analysis. This data will be valuable to
      study the behaviour of our memory over a very long time period. The
      results will be used to improve the scheduling algorithms behind the
      software even further.
    '';
  };
}

{ stdenv
, fetchzip
, fetchpatch
}:

stdenv.mkDerivation rec {
  name = "omeka-s";
  version = "3.1.1";

  src = 
    fetchzip {
      url = "https://github.com/omeka/omeka-s/releases/download/v${version}/omeka-s-${version}.zip";
      hash = "sha256-XLDxljPQFvkEzq6hCpkcDdy53lwQk4MLJoiPbn6ubyw=";
    };

  # Using the zip distribution here so we don't need
  # to take care of fetching dependencies
  #fetchFromGitHub {
  #  owner = "omeka";
  #  repo = "omeka-s";
  #  rev = "v3.1.0";
  #  hash = "sha256-zWkgcRyihgeughynqcuvMdBMjiTh1DD694A0sCEM3oU=";
  #};
 
  patches = [
    (fetchpatch {
      url = "https://github.com/omeka/omeka-s/pull/1789/commits/64789a7c10303ebe68cd56b8b7d8219cade5d199.patch";
      sha256 = "sha256-q/zv4xST2op5Ofhkr94Ol01DqyZpgfwR4Xa8tWWlSCk=";
    })
    (fetchpatch {
      url = "https://github.com/omeka/omeka-s/pull/1789/commits/f829497df7d60e61aa85aa8fcecd9b4616ce2294.patch";
      sha256 = "sha256-MXscWgck6kT0fiNXA7ynqkDhJTRpSKS80YIiEST1+Qk=";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r . $out

    runHook postInstall
  '';
}

{ fetchFromGitHub
, fetchFromGitLab
, stdenv
, fetchpatch
}:

{
  value-suggest =
    #fetchFromGitHub {
    #  owner = "Xentropics";
    #  repo = "ValueSuggest";
    #  # 'ndeterms' branch
    #  rev = "fb28c1afa43169adf0cd8532e636161c83835626";
    #  hash = "sha256-bI9qz0+convjcvz8z/uFwD5/h+tTfwdVRBlDOfvZHf4=";
    #};
    stdenv.mkDerivation {
      pname = "Omeka-S-module-ValueSuggest";
      version = "snapshot";
      src =
        fetchFromGitHub {
          owner = "Xentropics";
          repo = "ValueSuggest";
          # 'ndeterms' branch
          rev = "fb28c1afa43169adf0cd8532e636161c83835626";
          hash = "sha256-bI9qz0+convjcvz8z/uFwD5/h+tTfwdVRBlDOfvZHf4=";
        };
      patches = [
        # https://github.com/Xentropics/ValueSuggest/pull/2 add Dutch localization of AAT
        (fetchpatch {
          url = "https://github.com/Xentropics/ValueSuggest/commit/78aa0df03b8eaec15abbefba1d4e3cfbafcf6c3f.patch";
          sha256 = "sha256-8u6xwV/7g+yH4Yl9nJlTN4vO/6+arpPrsn7Rm2kOKzk=";
        })
      ];
      installPhase = ''
        runHook preInstall
        cp -r . $out
        runHook postInstall
      '';
    };
  generic =
    fetchFromGitLab {
      owner = "Daniel-KM";
      repo = "Omeka-S-module-Generic";
      rev = "a59e2b5fc32b725a5837b4a11ba7baaba78534ba";
      hash = "sha256-XhojKehNefAH5UhQgL1RRxQ1mBK1fdj0BRRIbquhQsI=";
    };
  #clean-url = /home/aengelen/dev/Omeka-S-module-CleanUrl;
  clean-url = stdenv.mkDerivation {
    pname = "Omeka-S-module-CleanUrl";
    version = "snapshot";
    src =
      fetchFromGitLab {
        owner = "Daniel-KM";
        repo = "Omeka-S-module-CleanUrl";
        rev = "b8a0f54300f2dda4d664cca0ffeea135031902a8";
        hash = "sha256-+ahR2IX5WKi1t7r8ki3x+3h9doBbwUx73r6PGLzEFpU=";
      };
    patches = [
      # avoid strict mysql query checking
      (fetchpatch {
        url = "https://gitlab.com/Daniel-KM/Omeka-S-module-CleanUrl/-/commit/e2b2bdad8ed5f233e4b3888391f3b17b54e7f265.patch";
        sha256 = "sha256-r6wdz/ei84s/sOtr7bLW7cKxAuZBT4pKHzVFNvVwf2Y=";
      })
      # fix fetchAllAssociative output
      (fetchpatch {
        url = "https://gitlab.com/Daniel-KM/Omeka-S-module-CleanUrl/-/commit/51abdb1527f8fadfd74cea4b9df24b5c3652a144.patch";
        sha256 = "sha256-5UdRyiq5c/iQcUiCEb1rNt71KzhAxr2Wo7Gtl+hFDiI=";
      })
      # fix media URL's on item pages
      (fetchpatch {
        url = "https://gitlab.com/Daniel-KM/Omeka-S-module-CleanUrl/-/commit/261b5ceb8121c07c053adbd05585ef1f436e11f6.patch";
        sha256 = "sha256-kHLPU6tC2kQZ+BH90o+C69M/PC6OBYr4hyTev2t+ebE=";
      })
      (fetchpatch {
        url = "https://gitlab.com/Daniel-KM/Omeka-S-module-CleanUrl/-/commit/3b3b298c6e2b8f6607dc67986a253c432134bac8.patch";
        sha256 = "sha256-CWlFj7L+DVKVzezTQFgGzqbNgz+TkQhHogtEE9NsavU=";
      })
    ];
    installPhase = ''
      runHook preInstall
      cp -r . $out
      runHook postInstall
    '';
  };
  #clean-url =
  #  fetchFromGitLab {
  #    owner = "Daniel-KM";
  #    repo = "Omeka-S-module-CleanUrl";
  #    rev = "e841ea1804fe584b10da22fc5f03b1272b64b71e";
  #    hash = "sha256-rCtxr/RrmOAWy9EXnmzVftDE0QPC1spm7GZad8ussH0=";
  #  };
  unapi =
    fetchFromGitLab {
      owner = "Daniel-KM";
      repo = "Omeka-S-module-UnApi";
      rev = "1.3.0";
      hash = "sha256-MlD8xKKz/b61dceKfUtvwf8xmlOAEdZYff11P3KDtdY=";
    };
  custom-ontology =
    fetchFromGitLab {
      owner = "Daniel-KM";
      repo = "Omeka-S-module-CustomOntology";
      rev = "3.3.5.1";
      hash = "sha256-+HjcCzC5sQ6Fkxt3WZungyoouM/q9t2U4R7BHF/ry+g=";
    };
}

{ fetchFromGitHub
, fetchFromGitLab
, stdenv
, fetchpatch
}:

{
  value-suggest =
    fetchFromGitHub {
      owner = "Xentropics";
      repo = "ValueSuggest";
      # 'ndeterms' branch
      rev = "fb28c1afa43169adf0cd8532e636161c83835626";
      hash = "sha256-bI9qz0+convjcvz8z/uFwD5/h+tTfwdVRBlDOfvZHf4=";
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
}

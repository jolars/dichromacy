{
  pkgs,
  ...
}:
let
  texlive = pkgs.texliveMedium.withPackages (
    ps: with ps; [
      scheme-basic
      l3build
      beamer
      biblatex
      enumitem
      fileinfo
      hypdoc
      hyperref
      listings
      metalogo
      parskip
      pgf
      pgfopts
      setspace
      standalone
      xurl
      tagpdf
      microtype
      koma-script
      booktabs
      minted
      xcolor
      upquote
      mdwtools
      caption
      float
      fancyvrb
      tcolorbox
      tikzfill
      pdfcol
      fontawesome5
    ]
  );
  l3build-wrapped = pkgs.writeShellScriptBin "l3build-wrapped" ''
    # NOTE: the trailing slash in TEXMF is required
    TEXMF="${texlive}/" ${texlive}/bin/l3build "$@"
  '';
in
{
  packages = [
    pkgs.git
    pkgs.bashInteractive
    pkgs.pandoc
    pkgs.quartoMinimal
    l3build-wrapped
    pkgs.go-task
    pkgs.poppler-utils
  ];

  languages = {
    texlive = {
      enable = true;
      base = texlive;
    };

    javascript = {
      enable = true;

      # corepack.enable = true;

      pnpm = {
        enable = true;

        install = {
          enable = true;
        };
      };
    };

    typescript = {
      enable = true;
    };
  };

  treefmt = {
    enable = true;

    config.programs = {
      nixfmt.enable = true;

      stylua.enable = true;
    };
  };

  git-hooks.hooks = {
    treefmt.enable = true;
  };
}

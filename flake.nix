{
  description = "Evermeet — Automated D&D 5e Character Sheet in Typst (build & local preview environment)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          fontPackages = with pkgs; [
            roboto
            libertinus
            liberation_ttf
            dejavu_fonts
          ];
          fontPath = pkgs.lib.makeSearchPath "share/fonts" fontPackages;
        in
        rec {
          preview-site = pkgs.stdenvNoCC.mkDerivation {
            pname = "evermeet-preview-site";
            version = "0.1.0";
            src = self;

            nativeBuildInputs = with pkgs; [
              bash
              coreutils
              findutils
              gnugrep
              gnused
              typst
              python3
            ];

            TYPST_FONT_PATHS = fontPath;

            buildPhase = ''
              runHook preBuild
              patchShebangs scripts/build_preview.sh
              ./scripts/build_preview.sh
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p "$out"
              cp -r dist/* "$out/"
              runHook postInstall
            '';
          };

          default = preview-site;
        }
      );

      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          fontPackages = with pkgs; [
            roboto
            libertinus
            liberation_ttf
            dejavu_fonts
          ];
          fontPath = pkgs.lib.makeSearchPath "share/fonts" fontPackages;

          buildPreviewApp = pkgs.writeShellApplication {
            name = "build-preview";
            runtimeInputs = with pkgs; [
              bash
              coreutils
              findutils
              gnugrep
              gnused
              typst
              python3
            ];
            text = ''
              export TYPST_FONT_PATHS="${fontPath}''${TYPST_FONT_PATHS:+:$TYPST_FONT_PATHS}"
              ./scripts/build_preview.sh "$@"
            '';
          };

          previewCardApp = pkgs.writeShellApplication {
            name = "preview-card";
            runtimeInputs = with pkgs; [
              bash
              coreutils
              findutils
              gnugrep
              gnused
              typst
              python3
            ];
            text = ''
              export TYPST_FONT_PATHS="${fontPath}''${TYPST_FONT_PATHS:+:$TYPST_FONT_PATHS}"
              PORT="''${PORT:-8000}"
              ./scripts/build_preview.sh
              echo ""
              echo "=================================================================="
              echo "Evermeet Local Card Preview Server"
              echo "------------------------------------------------------------------"
              echo "  Gallery Index : http://localhost:''${PORT}/"
              echo "  Card Pages    :"
              echo "    - http://localhost:''${PORT}/seraphina.html"
              echo "    - http://localhost:''${PORT}/kaelen_rogue.html"
              echo "    - http://localhost:''${PORT}/thokk_barbarian.html"
              echo "    - http://localhost:''${PORT}/cards/seraphina.html"
              echo "    - http://localhost:''${PORT}/cards/kaelen_rogue.html"
              echo "    - http://localhost:''${PORT}/cards/thokk_barbarian.html"
              echo "=================================================================="
              echo "Press Ctrl+C to stop the preview server."
              exec python3 -m http.server "''${PORT}" --directory dist
            '';
          };
        in
        {
          default = {
            type = "app";
            program = "${previewCardApp}/bin/preview-card";
          };
          preview = {
            type = "app";
            program = "${previewCardApp}/bin/preview-card";
          };
          build = {
            type = "app";
            program = "${buildPreviewApp}/bin/build-preview";
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          fontPackages = with pkgs; [
            roboto
            libertinus
            liberation_ttf
            dejavu_fonts
          ];
          fontPath = pkgs.lib.makeSearchPath "share/fonts" fontPackages;

          buildPreviewHelper = pkgs.writeShellScriptBin "build-preview" ''
            set -euo pipefail
            export TYPST_FONT_PATHS="${fontPath}''${TYPST_FONT_PATHS:+:$TYPST_FONT_PATHS}"
            ./scripts/build_preview.sh "$@"
          '';

          previewCardHelper = pkgs.writeShellScriptBin "preview-card" ''
            set -euo pipefail
            export TYPST_FONT_PATHS="${fontPath}''${TYPST_FONT_PATHS:+:$TYPST_FONT_PATHS}"
            PORT="''${1:-''${PORT:-8000}}"
            ./scripts/build_preview.sh
            echo ""
            echo "Serving character cards at http://localhost:''${PORT}/"
            echo "  - http://localhost:''${PORT}/index.html"
            echo "  - http://localhost:''${PORT}/seraphina.html        (or /cards/seraphina.html)"
            echo "  - http://localhost:''${PORT}/kaelen_rogue.html     (or /cards/kaelen_rogue.html)"
            echo "  - http://localhost:''${PORT}/thokk_barbarian.html  (or /cards/thokk_barbarian.html)"
            exec ${pkgs.python3}/bin/python3 -m http.server "''${PORT}" --directory dist
          '';

          watchCardHelper = pkgs.writeShellScriptBin "watch-card" ''
            set -euo pipefail
            export TYPST_FONT_PATHS="${fontPath}''${TYPST_FONT_PATHS:+:$TYPST_FONT_PATHS}"
            CARD_FILE="''${1:-character.typ}"
            OUT_PDF="''${2:-''${CARD_FILE%.typ}.pdf}"
            echo "Watching ''${CARD_FILE} -> ''${OUT_PDF} ..."
            exec ${pkgs.typst}/bin/typst watch --root . "''${CARD_FILE}" "''${OUT_PDF}"
          '';
        in
        {
          default = pkgs.mkShell {
            packages = (with pkgs; [
              typst
              typstyle
              tinymist
              python3
              miniserve
              watchexec
              poppler-utils
              buildPreviewHelper
              previewCardHelper
              watchCardHelper
            ]) ++ fontPackages;

            TYPST_FONT_PATHS = fontPath;

            shellHook = ''
              export TYPST_FONT_PATHS="${fontPath}''${TYPST_FONT_PATHS:+:$TYPST_FONT_PATHS}"
              echo "Evermeet Typst Character Card DevShell loaded."
              echo "Commands available:"
              echo "  build-preview              Compile all character cards & HTML pages into dist/"
              echo "  preview-card [port]        Build & serve dist/ locally (default: http://localhost:8000)"
              echo "  watch-card [file.typ]      Live-compile a single character card PDF with typst watch"
            '';
          };
        }
      );
    };
}

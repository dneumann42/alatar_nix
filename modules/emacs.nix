{ pkgs, ... }:

let
  emacsPackage = pkgs.emacs.pkgs.withPackages (epkgs: with epkgs; [
    cape
    consult
    corfu
    doom-themes
    eglot
    eros
    neotree
    orderless
    use-package
    vertico
  ]);
in
{
  home.packages = with pkgs; [
    emacsPackage
    guile
    guile-lsp-server
    ripgrep
  ];

  home.file.".emacs.d/init.el".text = ''
    (load (expand-file-name "~/.config/emacs/init.el") nil 'nomessage)
  '';

  xdg.configFile."emacs/init.el".source = ../emacs/init.el;
}

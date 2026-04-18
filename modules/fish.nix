{ ... }:
{
  programs.fish = {
    enable = true;
    preferAbbrs = true;

    shellAbbrs = {
      g = "git";
      ga = "git add";
      gb = "git branch";
      gc = "git commit";
      gca = "git commit --amend";
      gco = "git checkout";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate";
      gp = "git push";
      gs = "git status --short --branch";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#desktop";
      rebuild-laptop = "sudo nixos-rebuild switch --flake /etc/nixos#laptop";
      v = "nvim";
      y = "yy";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    functions = {
      mkcd = {
        description = "Create a directory and enter it";
        argumentNames = "dir";
        body = ''
          if test -z "$dir"
              echo "mkcd: missing directory name" >&2
              return 1
          end

          mkdir -p -- "$dir" && cd -- "$dir"
        '';
      };

      fish_prompt = ''
        set -l last_status $status

        if set -q SSH_CONNECTION
            set_color brblack
            printf "%s@%s " $USER (prompt_hostname)
        end

        if set -q DEV_ENV_NAME
            set_color brmagenta
            printf "[nix:%s] " $DEV_ENV_NAME
        else if set -q IN_NIX_SHELL
            set_color brmagenta
            printf "[nix] "
        end

        if fish_is_root_user
            set_color brred
        else
            set_color brcyan
        end
        printf "%s" (prompt_pwd)

        if git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
            set -l branch (git symbolic-ref --quiet --short HEAD 2>/dev/null)
            if test -z "$branch"
                set branch (git rev-parse --short HEAD 2>/dev/null)
            end
            if test -n "$branch"
                set_color bryellow
                printf " [%s]" $branch
            end
        end

        if test $last_status -ne 0
            set_color brred
            printf " (%s)" $last_status
        end

        if fish_is_root_user
            set_color red
            printf " # "
        else
            set_color green
            printf " > "
        end
        set_color normal
      '';
    };

    interactiveShellInit = ''
      set -g fish_greeting

      if test -d "$HOME/.local/bin"
          fish_add_path --move --path "$HOME/.local/bin"
      end
      if test -d "$HOME/.cargo/bin"
          fish_add_path --move --path "$HOME/.cargo/bin"
      end
      if test -d "$HOME/.nimble/bin"
          fish_add_path --move --path "$HOME/.nimble/bin"
      end

      bind \cg 'commandline -f repaint'
    '';
  };
}

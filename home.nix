{
  config,
  pkgs,
  inputs,
  ...
}:
let 
  yazi-flavors = pkgs.fetchFromGitHub {
      owner = "yazi-rs";
      repo = "flavors";
      rev = "main";
      sha256 = "zE/GT9fYi9H6c7iCtcfk5bpnLkv1u6tn/HcofNYtc0c=";
  };
in {
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    eza

    _1password-cli

    sshuttle
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      docker-credential-gcr
    ]))
    kubectl
  ];

  home.file = { };

  home.sessionVariables = { };

  home.shellAliases = {
    ls = "eza";
    ll = "eza --group --header --group-directories-first --long --git";
    lg = "eza --group --header --group-directories-first --long --git --git-ignore";
    le = "eza --group --header --group-directories-first --long --extended";
    lt = "eza --group --header --group-directories-first --tree --level 2";
    lc = "eza --group --header --group-directories-first --across";
    lo = "eza --group --header --group-directories-first --oneline";
  };

  xdg.enable = true;

  programs.home-manager.enable = true;

  # avoid installing gui applications via home-manager
  # just use the native package manager for gui apps

  programs.fish = {
    enable = true;
  };

  programs.git = {
    enable = true;
    
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    signing = {
      signByDefault = true;
      format = "ssh";

      # this comes from a gui app but I don't want to wrap gui apps with
      # nixgl because it seems very unstable, so we're just going to hard-code it
      signer = "/opt/1Password/op-ssh-sign";
    };
    includes = [
      {
        contents = {
          user = {
            email = "justin.pflueger@deepsentinel.com";
            name = "Justin Pflueger";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHSKp5F8pMqDRaofJxak6ShfDsZBz0iw5W1rmyc8cAcH";
          };
        };
      }
    ];
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.ssh = {
    enable = true;
    extraOptionOverrides = {
      "IdentityAgent" = "~/.1password/agent.sock";
    };
    matchBlocks = {
      "*.s3ntin3l.com" = {
        identitiesOnly = true;
        user = "justin.pflueger";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    colors = {
      "dark"    = "1";
      "fg"      = "-1";
      "bg"      = "-1";
      "hl"      = "#5fff87";
      "fg+"     = "-1";
      "bg+"     = "-1";
      "hl+"     = "#ffaf5f";
      "info"    = "#af87ff";
      "prompt"  = "#5fff87";
      "pointer" = "#ff87d7";
      "marker"  = "#ff87d7";
      "spinner" = "#ff87d7";
    };
  };

  programs.yazi = {
    enable = true;
    theme = {
      flavor = {
        dark = "dracula";
      };
    };
    flavors = {
      dracula = "${yazi-flavors}/dracula.yazi";
    };
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.zoxide = {
    enable = true;
  };
}

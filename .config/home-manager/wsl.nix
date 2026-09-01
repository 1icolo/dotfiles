{ pkgs, pkgsUnstable, ... }:

{
  programs.bash = {
    enable = true;
    initExtra = ''
export HOMEW="/mnt/c/Users/j60126942"
export EDITOR=vim
export PATH=$PATH:/home/nico/.codeartsdoer/installers/bin

toggle-proxy() {
  if [[ $(env | grep proxy) ]]; then
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY no_proxy
    echo "Proxy removed."
  else
    export HTTP_PROXY=http://proxy.huawei.com:8080
    export NO_PROXY="127.0.0.1,localhost,7.*,172.32.*,172.31.*,172.30.*,172.29.*,172.28.*,172.27.*,172.26.*,172.25.*,172.24.*,172.23.*,172.22.*,172.21.*,172.20.*,172.19.*,172.18.*,172.17.*,172.16.*,127.0.0.1*,100.9*,100.8*,100.7*,100.69.*,100.68.*,100.67.*,100.66.*,100.65.*,100.64.*,100.126.*,100.125.*,100.124.*,100.123.*,100.122.*,100.121.*,100.120.*,100.11*,100.10*,10.*,*tool.chaspark.net,*papers.chaspark.com,*paper.chaspark.com,*irad.huaweigsc.com,*heds.huaweigsc.com,*cn-north-5-console.huaweicloud.com,*acm.chaspark.com,*.yw-partners.com,*.yw-beta.com,*.yinwang.com,*.pinjiantrip.com,*.inhuawei.com,*.hwtrip.*,*.hwtelcloud.com,*.hwht.*,*.hw3static.com,*.hw3static.cn,*.huaweistatic.com,*.huaweistatic.cn,*.huaweimossel.*,*.huaweimarine.com,*.huawei.com,*.huawei.cn,*.hisilicon.cn,*.hisilicon.*,*.hic.cloud,*.chaspark.net,*.chaspark.com,*.chaspark.cn,*.athuawei.com,*.ai.smartcitysz.com,*.myhuaweicloud.com,*.huaweicloud.com,wo.hicloud.com,wo-dr*.dbankcloud.ru,wo-dr*.dbankcloud.cn,his.chaspark.com,csbjupyter.siye.*.console-his.huaweicloud.com"

    export http_proxy=$HTTP_PROXY
    export HTTPS_PROXY=$HTTP_PROXY
    export https_proxy=$HTTP_PROXY
    export no_proxy=$NO_PROXY
    echo "Proxy added."
  fi
}
    '';
    shellAliases = {
      hm-switch = "git -C ~/.config/home-manager add . && home-manager switch --flake ~/.config/home-manager#nico@x86_64-linux";
      hm-update = "nix flake update --flake ~/.config/home-manager && hm-switch";
      hm-edit = "vim ~/.config/home-manager/wsl.nix";
      cdwin = "cd /mnt/c/Users/j60126942/";
      agent = "which $(codearts)";
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Nico Gabo";
      email = "jan.nico.gabo@h-partners.com";
    };
  };

  home.packages = [
    pkgsUnstable.herdr
    pkgs.httptap
    pkgs.cmatrix
    pkgs.podman
    pkgs.nginx
    pkgs.netcat
    pkgs.tree
    pkgs.anki

    pkgs.nerd-fonts.meslo-lg

    pkgsUnstable.jq

    pkgs.chromium
    pkgsUnstable.zennotes-desktop
  ];
}

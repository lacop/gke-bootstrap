{
  description = "Cloud dev environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils/b1d9ab70662946ef0850d488da1c9019f3a9752a";

    # 1.7.5
    # TODO: requires allowUnfree, switch to opentofu?
    terraform_dep.url = "github:NixOS/nixpkgs/080a4a27f206d07724b88da096e27ef63401a504";

    # 3.14.3
    helm_dep.url = "github:NixOS/nixpkgs/a3ed7406349a9335cb4c2a71369b697cecd9d351";

    # 467.0.0
    gcloud_dep.url = "github:NixOs/nixpkgs/a3ed7406349a9335cb4c2a71369b697cecd9d351";
  };

  outputs = { self, flake-utils, terraform_dep, helm_dep, gcloud_dep }@inputs :
    flake-utils.lib.eachDefaultSystem (system:
    let
      terraform_dep = import inputs.terraform_dep { inherit system; config.allowUnfree = true; };
      helm_dep = inputs.helm_dep.legacyPackages.${system};
      gcloud_dep = inputs.gcloud_dep.legacyPackages.${system};
    in
    {
      devShells.default = helm_dep.mkShell {
        packages = [
          terraform_dep.terraform
          helm_dep.kubernetes-helm
          gcloud_dep.google-cloud-sdk
        ];

        shellHook = ''
          echo -e "\033[0;31mCloud dev env\033[0m"
          echo -e "\033[0;31m-------------\033[0m"
          terraform version | head -n 1
          echo "Helm $(helm version --short)"
          gcloud version | head -n 1
          echo -e "\033[0;31m-------------\033[0m"
          export PS1="nix[cloud]> "
        '';
      };
    });
}
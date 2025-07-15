{ lib, pkgs, ... }: {
  config = lib.mkIf (pkgs.stdenv.isDarwin) {


    # Uncomment line below to remove settings if decide to delete app
    #    home.file.".amethyst.plist" = null;

    # Source aerospace config from the home-manager store
    #    home.file.".amethyst.plist".text = ''
    #
    #    '';
  };
}

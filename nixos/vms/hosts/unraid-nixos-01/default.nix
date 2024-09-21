{
  imports = [ ../../defaults ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
  };

  homelab.modules.services = {
    blocky.enable = true;
    nginx.enable = true;
    paperless.enable = true;
    postgres.enable = true;
  };

  fileSystems = {
    "/mnt/data" = {
      device = "data";
      fsType = "virtiofs";
      options = [
        "nofail"
        "rw"
        "relatime"
      ];
    };
  };
}

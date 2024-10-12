{
  imports = [
    ../../defaults
    ./services
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
  };

  modules.services = {
    caddy.enable = true;
  };
}

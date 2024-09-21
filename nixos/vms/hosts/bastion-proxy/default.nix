{
  imports = [ ../../defaults ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
  };

  # homelab.services =
  #   {
  #   };
}

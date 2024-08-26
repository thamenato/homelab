{
  services.blocky = {
    enable = true;

    settings = {
      ports.dns = 53; # Port for incoming DNS Queries.
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };

      # Define own domain names to IPs
      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        rewrite = {
          home = "lan";
        };
        mapping = {
          "unraid-nixos.lan" = "10.0.10.208";
          "unraid.lan" = "10.0.10.2";
        };
        # zone = '''';
      };

      #Enable Blocking of certian domains.
      blocking = {
        blackLists = {
          #Adblocking
          ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
          #Another filter for blocking adult sites
          adult = [ "https://blocklistproject.github.io/Lists/porn.txt" ];
          #You can add additional categories
        };
        #Configure what block categories are used
        clientGroupsBlock = {
          default = [ "ads" ];
          kids-ipad = [ "ads" "adult" ];
        };
      };
    };
  };

  # firewall (iptables)
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}

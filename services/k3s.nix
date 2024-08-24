{ meta, ... }:
{
  services.k3s =
    let
      initHostname = "unraid-node-01";
      isInit = (meta.hostname == initHostname);
    in
    {
      enable = true;
      role = "server";
      # extraFlags = toString ([
      #   "--write-kubeconfig-mode \"0644\""
      #   "--cluster-init"
      #   "--disable servicelb"
      #   "--disable traefik"
      #   "--disable local-storage"
      # ] ++ (if meta.hostname == "homelab-0" then [ ] else [
      #   "--server https://homelab-0:6443"
      # ]));
      tokenFile = /var/lib/rancher/k3s/server/token;
      clusterInit = isInit;
      serverAddr = (if isInit then "" else "https://${initHostname}:6443");
    };

  networking.firewall = {
    allowedTCPPorts = [
      6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
      2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
      2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    ];
    allowedUDPPorts = [
      8472 # k3s, flannel: required if using multi-node for inter-node networking
    ];
  };
}

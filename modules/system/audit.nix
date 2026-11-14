_: {
  # Kernel audit subsystem + auditd daemon: forensic logging for the
  # post-compromise scenario (xddxdd/nix-cachyos-kernel#110).
  flake.modules.nixos."system/audit" = {
    security.auditd.enable = true;
    # Rotate at 32 MB x 5 files (~160 MB ceiling); suspend writes near disk
    # full so a log flood can't fill the VM disk. Defaults would grow one
    # audit.log unbounded.
    security.auditd.settings = {
      max_log_file = 32;
      max_log_file_action = "rotate";
      num_logs = 5;
      space_left_action = "syslog";
      admin_space_left_action = "suspend";
      disk_full_action = "suspend";
    };
    security.audit = {
      enable = true;
      # Cap the flood rate; unlimited (NixOS default) burns kernel CPU and
      # drops events wholesale once the backlog overflows.
      rateLimit = 154;
      # Baseline: identity/sudo/sshd config changes and sudo executions.
      # Enough to answer "what did they touch" without flooding the log.
      rules =
        [
          "-w /etc/passwd -p wa -k identity"
          "-w /etc/group -p wa -k identity"
          "-w /etc/shadow -p wa -k identity"
          "-w /etc/sudoers -p wa -k sudoers"
          "-w /etc/sudoers.d -p wa -k sudoers"
          "-w /run/wrappers/bin/sudo -p x -k sudo"
          "-w /etc/ssh/sshd_config -p wa -k sshd_config"
        ]
        ++ [
          # Must be last: ruleset immutable until reboot, so root can't disable
          # logging. Rules changes only take effect after a reboot.
          "-e 2"
        ];
    };
    # TODO(when a collector host exists): ship logs off-box with
    # security.auditd.plugins.remote — the only real defense against a root
    # attacker truncating the local logs.
  };

  # Preservation companion (auto-attached with "system/audit"): audit logs
  # live in /var/log/audit, tmpfs on erased-root layouts. No-op on hosts
  # without audit enabled.
  flake.modules.nixos."preservation/system/audit" = {
    config,
    lib,
    ...
  }: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      "/var/log/audit"
    ];
  };
}

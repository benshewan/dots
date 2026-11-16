{
  config,
  ...
}: let
  # Flake-level user name; the NixOS module below shadows `config`.
  username = config.flake.meta.user.username;
in {
  # Kernel audit + auditd: forensic logging for the post-compromise case
  # (xddxdd/nix-cachyos-kernel#110).
  flake.modules.nixos."system/audit" = {
    config,
    lib,
    ...
  }: let
    # Paths come from the options that create them: a rule naming a missing path
    # aborts the whole ruleset.
    home = config.users.users.${username}.home;
    homePreserved = config.modules.preservation.enable && (config.modules.preservation.home or false);
    persistentHome = "${config.modules.preservation.persistentPath}${home}";
    sudo = lib.getExe config.security.sudo.package;
    auditLogDir = builtins.dirOf (config.security.auditd.settings.log_file or "/var/log/audit/audit.log");
    # Only events with a login session (auid set): services and activation run
    # with auid unset.
    human = "-F auid!=unset";
    # Real users only (auid >= 1000).
    session = "-F auid>=1000 -F auid!=unset";
  in {
    security.auditd.enable = true;
    # Rotate at 32 MB x 5 (~160 MB); stop logging before the disk fills.
    security.auditd.settings = {
      max_log_file = 32;
      max_log_file_action = "rotate";
      num_logs = 5;
      space_left_action = "syslog";
      admin_space_left_action = "suspend";
      disk_full_action = "suspend";
    };
    security.audit = {
      # NixOS appends "-e 2" itself: ruleset immutable until reboot.
      enable = "lock";
      # No kernel-side drops; rotation bounds disk usage.
      rateLimit = 0;
      # Boot bursts overflow the default of 1024.
      backlogLimit = 8192;
      rules =
        [
          # /etc/systemd/system and /etc/ssh/sshd_config are symlinks into the
          # store, so the real parent directories are watched instead.
          "-a always,exit -F path=/etc/passwd -F perm=wa ${human} -k identity" # user accounts: names, uids/gids, shells
          "-a always,exit -F path=/etc/group -F perm=wa ${human} -k identity" # group names and memberships
          "-a always,exit -F path=/etc/shadow -F perm=wa ${human} -k identity" # password hashes and expiry data
          "-a always,exit -F path=/etc/sudoers -F perm=wa ${human} -k sudoers" # who may run what as root
          "-a always,exit -F path=/etc/systemd -F perm=wa ${human} -k systemd_units" # systemd unit files (services, timers, sockets)
          "-a always,exit -F path=/etc/ssh -F perm=wa ${human} -k sshd_config" # sshd settings and SSH host private keys
          # Store path, not /run/wrappers/bin/sudo: /run/wrappers does not exist
          # yet when the rules load at sysinit.
          "-w ${sudo} -p x -k sudo" # each sudo run: command plus the original login identity
          "-a always,exit -F arch=b64 -S execve -F euid=0 ${session} -F exe!=${sudo} -k root_exec" # commands a logged-in user runs as root
          "-a always,exit -F arch=b64 -S setuid,setreuid,setresuid,setgid,setregid,setresgid,setgroups,capset ${session} -F exe!=${sudo} -k priv_change" # uid/gid/capability changes made without sudo (su, setuid tools)
          # Mounts without a login session are the boot's own bind mounts (~2k),
          # so only session-owned mounts are logged.
          "-a always,exit -F arch=b64 -S init_module,finit_module,delete_module -k kernel_module" # kernel modules loaded or unloaded
          "-a always,exit -F arch=b64 -S mount,umount2 ${human} -k mount" # filesystems mounted or unmounted from a session
          # `dir=` because a `-w ... -p x` directory watch never matches execve
          # of a file inside it.
          "-a always,exit -F arch=b64 -S execve -F dir=/dev/shm -k tmp_exec" # programs executed from /dev/shm
          "-a always,exit -F arch=b64 -S execve -F dir=/tmp -k tmp_exec" # programs executed from /tmp
        ]
        ++ lib.optionals (config.sops.age.keyFile != null) [
          "-a always,exit -F arch=b64 -S open,openat -F path=${config.sops.age.keyFile} -F perm=r -F success=1 ${human} -k sops_key" # reads of the age private key that decrypts every sops secret
        ]
        ++ lib.optionals homePreserved [
          "-a always,exit -F path=${persistentHome}/.ssh -F perm=wa ${human} -k ssh_keys" # user SSH keys, known_hosts and config in ~/.ssh
        ]
        ++ lib.optionals config.modules.preservation.enable [
          "-a always,exit -F path=${auditLogDir} -F perm=wa ${human} -k audit_tamper" # audit logs deleted, renamed or truncated in /var/log/audit
        ]
        ++ lib.optionals config.services.cron.enable [
          "-a always,exit -F path=/var/cron -F perm=wa ${human} -k cron_jobs" # cron.allow/cron.deny (who may use cron) and the spool directory
          "-a always,exit -F path=/var/cron/tabs -F perm=wa ${human} -k cron_jobs" # user crontab files (scheduled commands per user)
        ];
    };
    systemd.services.audit-rules-nixos = {
      # The ruleset is immutable, so a reload on rebuild always fails and aborts
      # the switch; rule edits apply on the next reboot.
      restartIfChanged = false;
      # Watched paths must exist when the rules load: /var/log/audit and ~/.ssh
      # come from preservation mounts, /var/cron from the tmpfiles rule below
      # (cron itself only creates it at multi-user.target, after sysinit).
      unitConfig.After =
        lib.optionals config.modules.preservation.enable ["preservation.target"]
        ++ lib.optionals config.services.cron.enable ["systemd-tmpfiles-setup.service"];
    };
    systemd.tmpfiles.rules = lib.optionals config.services.cron.enable [
      "d /var/cron 0700 root root - -"
      "d /var/cron/tabs 0700 root root - -"
    ];
    # TODO: ship logs off-box with security.auditd.plugins.remote — the only
    # defense against a root attacker deleting local logs.
  };

  # Preservation companion (auto-attached with "system/audit").
  flake.modules.nixos."preservation/system/audit" = {config, ...}: {
    preservation.preserveAt.${config.modules.preservation.persistentPath}.directories = [
      "/var/log/audit"
    ];
  };
}

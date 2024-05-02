{pkgs, ...}: {
  # Set your time zone.
  time.timeZone = "America/Halifax";
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
}

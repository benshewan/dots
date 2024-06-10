{...}: {
  environment.sessionVariables = {
    _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java'';
  };
}

{pkgs, ...}: {
  home.packages = with pkgs; [
    (jetbrains.webstorm.override {
      vmopts = ''
        --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
        --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
        -javaagent:/home/ben/.config/JetBrains/crack/ja-netfilter.jar=jetbrains
        -Dawt.toolkit.name=WLToolkit
      '';
    })
  ];
}

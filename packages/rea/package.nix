{
  buildNpmPackage,
  fetchFromGitHub,
  fetchzip,
  lib,
  makeWrapper,
  nodejs,
}:
let
  version = "6.8.0";
  rev = "160d821ac9a0310afcb8d1fc427862dd6508add5"; # tag rea-agents-6.8.0
in
buildNpmPackage {
  pname = "rea-agents";
  inherit version;

  # The npm tarball ships the prebuilt dist/ runtime (the GitHub source only has
  # TS src/), but no lockfile — take the lockfile from the tagged source instead.
  src = fetchzip {
    url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${version}.tgz";
    hash = "sha256-Zbi8ttwO9SjVAB0FXs4dFIe1ifQxNbmZ/Su9MJ7OBVE=";
  };

  postPatch = ''
    cp ${fetchFromGitHub {
      owner = "morluto";
      repo = "rea";
      inherit rev;
      hash = "sha256-2ADn3U3lvUoB4tCEpzO0rMfYE4sis+5uBiEazcp0gpI=";
    }}/package-lock.json package-lock.json
    # every nixpkgs node lags REA's required ranges by a patch release; the
    # prebuilt dist is not node-version sensitive, so drop the engines check
    node -e 'const fs=require("fs");const p=JSON.parse(fs.readFileSync("package.json"));delete p.engines;fs.writeFileSync("package.json",JSON.stringify(p,null,2))'
  '';

  npmDepsHash = "sha256-3WPXD+qm5WVfrTEvepKwX5RZBfbLBcPB0uDmKIx4MR8=";
  dontNpmBuild = true;
  dontNpmInstall = true;

  # frida's postinstall tries to download a toolchain from the network; it is
  # only used by REA's macOS/LRDB dynamic-tracer path, not the Ghidra flow.
  npmFlags = ["--ignore-scripts"];

  # npmInstallHook's npm-pack file-copy drops dist/ for this package, so install
  # the already-complete source tree directly (node_modules was pruned above).
  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --no-save --ignore-scripts

    mkdir -p $out/lib/node_modules/rea-agents
    cp -r . $out/lib/node_modules/rea-agents/

    mkdir -p $out/bin
    for bin in rea rea-agents; do
      makeWrapper ${nodejs}/bin/node $out/bin/$bin \
        --add-flags "$out/lib/node_modules/rea-agents/scripts/rea.mjs"
    done

    runHook postInstall
  '';

  nativeBuildInputs = [makeWrapper];

  meta = with lib; {
    description = "Reverse engineer anything from your terminal or agent with one CLI and MCP server";
    longDescription = ''
      REA connects coding agents to reverse-engineering tooling through one CLI
      and MCP server: binary inspection (Ghidra/Hopper/IDA bridges), decompilation,
      xrefs/call graphs, and JS/Electron analysis.
    '';
    homepage = "https://github.com/morluto/rea";
    license = licenses.mit;
    mainProgram = "rea";
    platforms = platforms.linux;
  };
}

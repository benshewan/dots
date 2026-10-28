# Unmerged PR #11: re-add "auto_select_single" option in kdeconnect-send.yazi
# https://github.com/Deepak22903/kdeconnect-send.yazi/pull/11
{...}: final: _prev: {
  yaziPlugins = _prev.yaziPlugins // {
    kdeconnect-send = final.fetchFromGitHub {
      owner = "decromo";
      repo = "kdeconnect-send.yazi";
      rev = "68f7a65";
      sha256 = "sha256-EZeyGZ0BZeZpYvdDL4zCLoVVFV8Qe67irvZkMdYfOV8=";
    };
  };
}

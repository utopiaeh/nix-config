# TencentDB Agent Memory: https://github.com/TencentCloud/TencentDB-Agent-Memory
{
  pkgs,
  inputs,
  osConfig,
  ...
}:

let
  deployDir = "${inputs.tdai-memory}/deploy/global-images";
  apiKeyFile = osConfig.sops.secrets.anthropic_api_key.path;
  stateDir = "$HOME/.local/share/tdai";
  panelUrl = "http://localhost:8125";
  anthropicUrl = "https://api.anthropic.com";
  memoryModel = "claude-haiku-5-5";
  chatModel = "claude-sonnet-5-5";

  tdai-up = pkgs.writeShellApplication {
    name = "tdai-up";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      state="${stateDir}"
      install -d -m 700 "$state"
      # Scripts write .env / .admin-key / .proxy-config next to themselves, so they need a writable copy.
      cp -R --no-preserve=mode ${deployDir}/. "$state/"
      chmod +x "$state"/*.sh
      [ -f "$state/.env" ] || install -m 600 "$state/.env.example" "$state/.env"

      key="$(cat ${apiKeyFile})"
      (
        # shellcheck disable=SC1091
        source "$state/_lib.sh"
        # Memory services append /chat/completions or /messages directly; the proxy adds /v1 itself.
        set_env_value MEMORY_LLM_PROTOCOL anthropic "$ENV_FILE"
        set_env_value MEMORY_LLM_BASE_URL ${anthropicUrl}/v1 "$ENV_FILE"
        set_env_value MEMORY_LLM_MODEL ${memoryModel} "$ENV_FILE"
        set_env_value MEMORY_LLM_API_KEY "$key" "$ENV_FILE"
        set_env_value PROXY_UPSTREAM_URL ${anthropicUrl} "$ENV_FILE"
        set_env_value PROXY_UPSTREAM_MODEL ${chatModel} "$ENV_FILE"
        set_env_value PROXY_UPSTREAM_API_KEY "$key" "$ENV_FILE"
        load_env
        check_ports
      )

      # Skip start-all.sh: its LLM prompt treats EOF as "no" and probes Anthropic with the OpenAI check, so it dies headless.
      "$state/start-memory-core.sh"
      "$state/start-memory-hub.sh"
      PROXY_FULL_STACK=1 "$state/start-proxy.sh"
      echo "Panel: ${panelUrl}  (admin key: $state/.admin-key)"
    '';
  };

  tdai-down = pkgs.writeShellApplication {
    name = "tdai-down";
    text = ''exec "${stateDir}/stop-all.sh" "$@"'';
  };

  tdai-claude = pkgs.writeShellApplication {
    name = "tdai-claude";
    text = ''
      keyfile="$HOME/.config/tdai/user-key"
      if [ ! -s "$keyfile" ]; then
        echo "Missing $keyfile: create a user in the panel (${panelUrl}), save its sk-mem key there, chmod 600." >&2
        exit 1
      fi
      ANTHROPIC_BASE_URL=http://127.0.0.1:8096/claude-code/default \
      ANTHROPIC_AUTH_TOKEN="$(cat "$keyfile")" \
      ANTHROPIC_MODEL="''${ANTHROPIC_MODEL:-${chatModel}}" \
        exec claude "$@"
    '';
  };
in
{
  home.packages = [
    tdai-up
    tdai-down
    tdai-claude
  ];
}

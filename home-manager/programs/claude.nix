{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cc = config.programs.claude-code;
  # One config dir per account; the module exports CLAUDE_CONFIG_DIR=workDir, so plain `claude` is work
  workDir = "${config.home.homeDirectory}/.claude-work";
  personalDir = "${config.home.homeDirectory}/.claude-personal";
in
{
  programs.zsh.shellAliases = {
    claude-work = "CLAUDE_CONFIG_DIR=${workDir} claude";
    claude-personal = "CLAUDE_CONFIG_DIR=${personalDir} claude";
  };

  # The claude-code module only manages one config dir (work), so mirror its CLAUDE.md, skills and
  # settings into the personal one
  home.file.".claude-personal/CLAUDE.md".source = cc.context;
  home.file.".claude-personal/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${workDir}/skills";

  home.activation.claudePersonalSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] (
    lib.hm.generators.mkImpureConfigMerger {
      inherit pkgs;
      path = "${personalDir}/settings.json";
      staticSettings = (pkgs.formats.json { }).generate "claude-personal-settings.json" cc.settings;
      jqOperation = "$dynamic * $static";
      format = "json";
      empty = "{}";
      mode = "600";
    }
  );

  programs.claude-code = {
    enable = true; # package = pkgs.claude-code (claude-code overlay)
    configDir = workDir;

    # Claude and /plugin still write settings.json; declared keys are merged in on switch
    mutableSettings = true;

    settings = {
      # Marketplaces + enabled plugins: Claude installs/updates them itself on startup
      extraKnownMarketplaces = {
        claude-plugins-official.source = {
          source = "github";
          repo = "anthropics/claude-plugins-official";
        };
        caveman.source = {
          source = "github";
          repo = "JuliusBrussee/caveman";
        };
        ponytail.source = {
          source = "github";
          repo = "DietrichGebert/ponytail";
        };
      };
      enabledPlugins = {
        "caveman@caveman" = true; # SessionStart hook → caveman every session
        "ponytail@ponytail" = true; # SessionStart hook → ponytail every session
        "feature-dev@claude-plugins-official" = true;
        "figma@claude-plugins-official" = true;
      };

      permissions = {
        # Hard block, CLAUDE.md rules are only advisory
        deny = [
          "Bash(git commit:*)"
          "Bash(git push:*)"
          # "merge *" (word boundary) so `git merge-base` stays allowed
          "Bash(git merge *)"
          # global flags before the subcommand (git -C dir commit, git -c k=v push)
          "Bash(git * commit *)"
          "Bash(git * push *)"
          "Bash(git * merge *)"
          "Bash(/usr/bin/git commit:*)"
          "Bash(/usr/bin/git push:*)"
          "Bash(/usr/bin/git merge *)"
          "Bash(command git commit:*)"
          "Bash(command git push:*)"
          "Bash(command git merge *)"
          "Bash(gh pr create:*)"
          "Bash(gh pr merge:*)"
          "Bash(git reset --hard:*)"
          "Bash(git clean:*)"
          # secrets: Read tool, plus the common shell reads (other commands can still read them)
          "Bash(cat *secrets/*)"
          "Bash(cat *.env*)"
          "Bash(cat *.ssh/*)"
          "Bash(cat *sops/age/*)"
          "Read(**/.env)"
          "Read(**/.env.local)"
          "Read(**/.env.*.local)"
          "Read(**/.env.dev*)"
          "Read(**/.env.prod*)"
          "Read(**/.env.stag*)"
          "Read(**/.env.test*)"
          "Read(**/.env.qa*)"
          "Read(**/.envrc)"
          "Read(**/*.pem)"
          "Read(**/*.key)"
          "Read(~/.ssh/**)"
          "Read(~/.aws/**)"
          "Read(~/.config/sops/**)"
          "Read(~/.gnupg/**)"
          "Read(**/secrets/**)"
        ];

        # Always prompt, even in auto/accept-edits mode
        ask = [
          "Bash(rm -rf:*)"
          "Bash(rm -fr:*)"
          # can merge PRs / push refs, bypassing the gh pr / git push denies
          "Bash(gh api:*)"
        ];

        # From /fewer-permission-prompts: frequent read-only / check commands
        allow = [
          "Bash(yarn verify)"
          "Bash(yarn lint)"
          "Bash(yarn tsc)"
          "Bash(yarn tsc --noEmit *)"
          "Bash(yarn -s tsc --noEmit *)"
          "Bash(yarn test:run)"
          "Bash(yarn vitest run)"
          "Bash(yarn vitest run *)"
          "Bash(docker compose ps)"
          "Bash(docker compose ps *)"
          "Bash(brew list *)"
          "mcp__claude_ai_Atlassian_MCP__getJiraIssue"
          "mcp__claude_ai_Figma__get_design_context"
          "mcp__claude_ai_Figma__get_metadata"
        ];
      };

      # Run the script bundled with the installed caveman plugin (newest cached version) so it
      # always matches the plugin's state format; prints nothing until the plugin is installed.
      # The prefix tells the work and personal profiles apart, since both share these settings
      statusLine = {
        type = "command";
        command = ''case "$CLAUDE_CONFIG_DIR" in *personal*) printf '[personal] ';; *) printf '[work] ';; esac; f=$(ls -t "''${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/caveman/caveman/*/hooks/caveman-statusline.sh "''${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/caveman/caveman/*/src/hooks/caveman-statusline.sh 2>/dev/null | head -1); [ -n "$f" ] && exec bash "$f"'';
      };
      effortLevel = "medium";
      theme = "dark";
      tui = "fullscreen";
    };

    context = ./claude/CLAUDE.md;

    skills =
      lib.mapAttrs (_: path: "${inputs.mattpocock-skills}/skills/${path}") {
        ask-matt = "engineering/ask-matt";
        code-review = "engineering/code-review";
      }
      // {
        java-coach = ./claude/skills/java-coach;
      };
  };
}

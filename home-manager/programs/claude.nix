{ lib, inputs, ... }:
{
  programs.claude-code = {
    enable = true; # package = pkgs.claude-code (claude-code overlay)

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
          # no commits/pushes/PRs (also covers push --force)
          "Bash(git commit:*)"
          "Bash(git push:*)"
          # "merge *" (word boundary) so `git merge-base` stays allowed
          "Bash(git merge *)"
          # global flags before the subcommand (git -C dir commit, git -c k=v push)
          "Bash(git * commit *)"
          "Bash(git * push *)"
          "Bash(git * merge *)"
          "Bash(gh pr create:*)"
          "Bash(gh pr merge:*)"
          # destructive
          "Bash(git reset --hard:*)"
          "Bash(git clean:*)"
          # secrets (Read tool only; shell reads like `cat .env` are not covered)
          "Read(**/.env*)"
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

      statusLine = {
        type = "command";
        command = ''bash "$HOME/.claude/hooks/caveman-statusline.sh"'';
      };
      effortLevel = "medium";
      theme = "dark";
      tui = "fullscreen";
    };

    # Global rules → ~/.claude/CLAUDE.md
    context = ./claude/CLAUDE.md;

    # mattpocock/skills pinned via flake input
    skills =
      lib.mapAttrs (_: path: "${inputs.mattpocock-skills}/skills/${path}") {
        code-review = "engineering/code-review";
        diagnosing-bugs = "engineering/diagnosing-bugs";
        grill-me = "productivity/grill-me";
        grill-with-docs = "engineering/grill-with-docs";
        grilling = "productivity/grilling";
        prototype = "engineering/prototype";
        tdd = "engineering/tdd";
      }
      // {
        java-coach = ./claude/skills/java-coach;
      };
  };
}

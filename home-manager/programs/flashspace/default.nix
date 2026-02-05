{ ... }:

{
  home = {
    file.".config/scripts/backup_flashspace.sh" = {
      source = ./backup_flashspace.sh;
      executable = true;
    };
  };

}

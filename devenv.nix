{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs;[
    git
    libyaml
    sqlite-interactive
  ];

  languages.ruby.enable = true;
  languages.ruby.version = "3.3.5";
}

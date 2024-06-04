{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.ansible
    pkgs.git
    pkgs.gh
  ];
}


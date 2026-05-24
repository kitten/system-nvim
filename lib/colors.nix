{ lib, ... }:

with lib;
let
  pow = base: exp: foldl' (a: x: x * a) 1 (genList (_: base) exp);
  hexToDec =
    value:
    let
      hexToInt = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };
      chars = stringToCharacters value;
      charsLen = length chars;
    in
    foldl (a: v: a + v) 0 (imap0 (k: v: hexToInt."${v}" * (pow 16 (charsLen - k - 1))) chars);
in
rec {
  hexToRGB =
    str:
    let
      hex = removePrefix "#" str;
      rgbStartIndex = [
        0
        2
        4
      ];
      hexList = builtins.map (x: builtins.substring x 2 hex) rgbStartIndex;
      hexLength = builtins.stringLength hex;
    in
    if hexLength != 6 then
      throw "Unsupported hex string length was ${builtins.toString hexLength} rather than 6"
    else
      builtins.map hexToDec hexList;

  hexToCterm =
    hex:
    let
      rgb = hexToRGB hex;
      r = elemAt rgb 0;
      g = elemAt rgb 1;
      b = elemAt rgb 2;
    in
    (if r < 75 then 0 else (r - 35) / 40) * 6 * 6
    + (if g < 75 then 0 else (g - 35) / 40) * 6
    + (if b < 75 then 0 else (b - 35) / 40)
    + 16;
}

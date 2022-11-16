# AutoRA-Ashitav4
Rebuild of AutoRA for Ashita v4


AutoRA v 1.0.0

AutoRA will only automate ranged attacks if you are actively engaged with a target.  Otherwise it will fire a single ranged attack.

To start auto ranged attacks without commands, use the key:  Ctrl + D
To stop auto ranged attacks in the same manner:  Alt + D

Commands:
/autora [options] <arguments>
  delay <###>      - Sets the combined delay of your ranged weapon and ammo.  Add the 2 delay values together and replace <###> with the sum.
  doffset <###>    - Sets an offset to the ranged attack delay.  Default is 0.  This is used to overcome any issues caused by a laggy connection.  This is typically unnecessary.
  start            - Starts auto attacks with ranged weapon)
  stop             - Stops auto ranged attacks
  haltontp         - Toggles automatic halt upon reaching 1000 TP
  verbose          - Toggles verbose mode.  This will provide feedback on what the addon is doing and why.

# MiniHonorCapped - bot reference

Version 1.1.0. Interface versions: 120100, 50504, 40402, 38002, 38000,
30405, 30300, 20506, 11509 (retail plus the classic client lines). Saved
variables: MiniHonorCappedDB (account-wide).

## What it does

Prints a red warning in the chat window when your Honor currency approaches
or reaches the cap, so you can spend it before losing gains.

- At the warning threshold (default 13000) or more: "You're almost honor capped! (<amount> / 15000)"
- At 15000 honor or more: "You're honor capped!"

## How it works

- Reads Honor from the currency API, trying currency IDs 1901, 1792, then
  392, and falling back to the old GetHonorCurrency function on classic-era
  clients. If none report a value the addon does nothing.
- Checks on login/entering world (always prints if you are over the
  threshold) and whenever currency changes (prints only when the honor
  amount differs from the last warned amount, so it does not spam).

## Settings

A settings page, opened with a slash command (/minihonorcapped, /mhc) or
Options -> AddOns -> MiniHonorCapped. It holds one control:

| Setting | Type | Default | Range |
|---|---|---|---|
| Warning Threshold | slider | 13000 | 0-15000, step 100 |

15000 is a fixed constant (the honor cap never changes) rather than a saved
value, so the slider's own maximum is pinned to it. The message text can
still only be changed by editing the saved variables in MiniHonorCappedDB:

| Key | Default | Meaning |
|---|---|---|
| AlmostCappedFormat | "\|cffff0000You're almost honor capped! (%s / 15000)\|r" | Chat format for the almost-capped message; %s is your honor. |
| CappedFormat | "\|cffff0000You're honor capped!\|r" | Chat format for the capped message. |

Note the "/ 15000" in the default almost-capped text is part of the string,
not derived from the cap; change it too if you edit the format.

## Troubleshooting

- "It never prints anything": you are below 13000 honor, or the client does
  not expose an honor currency the addon recognises.
- "It printed once and stopped": repeat warnings only fire when the honor
  amount changes; a fresh warning also prints on every login/zone-in while
  over the threshold.

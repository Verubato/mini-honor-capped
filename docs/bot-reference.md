# MiniHonorCapped - bot reference

Version 1.0.6. Interface versions: 120100, 50504, 40402, 38002, 38000,
30405, 30300, 20506, 11509 (retail plus the classic client lines). Saved
variables: MiniHonorCappedDB (account-wide).

## What it does

Prints a red warning in the chat window when your Honor currency approaches
or reaches the cap, so you can spend it before losing gains.

- At 13000 honor or more: "You're almost honor capped! (<amount> / 15000)"
- At 15000 honor or more: "You're honor capped!"

## How it works

- Reads Honor from the currency API, trying currency IDs 1901, 1792, then
  392, and falling back to the old GetHonorCurrency function on classic-era
  clients. If none report a value the addon does nothing.
- Checks on login/entering world (always prints if you are over the
  threshold) and whenever currency changes (prints only when the honor
  amount differs from the last warned amount, so it does not spam).

## Settings

No options UI and no slash commands. Thresholds and messages can be changed
by editing the saved variables in MiniHonorCappedDB:

| Key | Default | Meaning |
|---|---|---|
| HonorThreshold | 13000 | Amount at which the "almost capped" warning starts. |
| MaxHonor | 15000 | Amount treated as capped. |
| AlmostCappedFormat | "\|cffff0000You're almost honor capped! (%s / 15000)\|r" | Chat format for the almost-capped message; %s is your honor. |
| CappedFormat | "\|cffff0000You're honor capped!\|r" | Chat format for the capped message. |

Note the "/ 15000" in the default almost-capped text is part of the string,
not derived from MaxHonor; change both if you edit the cap.

## Troubleshooting

- "It never prints anything": you are below 13000 honor, or the client does
  not expose an honor currency the addon recognises.
- "It printed once and stopped": repeat warnings only fire when the honor
  amount changes; a fresh warning also prints on every login/zone-in while
  over the threshold.

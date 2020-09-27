# Clock

The clock module provides two submodules for your mirror; an actual digital clock and a calendar. Both relies on the same server so they are always kept in sync.

## Clock

The clock displays a simple digital clock with following default format `{h24}:{m}:{s}` (i.e. `08:53:10`) and a date with the following default date format `{WDFull} {D} {Mshort}` (i.e. `Monday 20 sept.`).

### Options

- `locale`: (`string`, optional) Language of the module; fallbacks to `en`
- `timezone`: (`string`, optional) Timezone for timeshifting correctly; fallbacks to `UTC`
- `time_format`: (`string`, optional) Format that displays the time; fallbacks to `{h24}:{m}:{s}` (i.e. `08:53:10`)
- `date_format`: (`string`, optional) Format that displays the date; fallbacks to `{WDFull} {D} {Mshort}` (i.e. `Monday 20 sept.`)

## Calendar

The calendar display the current month's calendar with day header, dimmed weekends and today indicator.

### Options

- `locale`: (`string`, optional) Language of the module; fallbacks to `en`
- `timezone`: (`string`, optional) Timezone for timeshifting correctly; fallbacks to `UTC`

## Server

The server simply holds the current date and ticks every second to update itself with the current date. One server powers both the calendar and the clock, there is a diff done on the date so it does not renders on every thick.


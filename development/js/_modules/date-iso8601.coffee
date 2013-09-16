# --- Date ---
# convert ISO 8601 date string to normal JS Date object
# usage: (new Date()).setISO8601( "ISO8601 Time" )
Date.prototype.setISO8601 = (string) ->
  regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
           "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
           "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?"
  d = string.match(new RegExp(regexp))

  offset = 0
  date = new Date(d[1], 0, 1)

  date.setMonth(d[3] - 1) if d[3]
  date.setDate(d[5])      if d[5]
  date.setHours(d[7])     if d[7]
  date.setMinutes(d[8])   if d[8]
  date.setSeconds(d[10])  if d[10]
  date.setMilliseconds(Number("0." + d[12]) * 1000) if d[12]
  if d[14]
    offset = (Number(d[16]) * 60) + Number(d[17])
    offset *= (if (d[15] == '-') then 1 else -1)

  offset -= date.getTimezoneOffset()
  time = (Number(date) + (offset * 60 * 1000))
  @setTime(Number(time))

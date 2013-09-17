q  = require('q')
pg = require('pg')


# --- Config ---
if process.env.NODE_ENV == 'production'
  pgConnectionString = "postgres://map-project:1234@localhost/map-project_production"
else
  pgConnectionString = "postgres://map-project:1234@localhost/map-project_development"


# --- Exports ---
module.exports = (sqlQuery, params=[]) ->
  queryFinished = q.defer()
  pg.connect pgConnectionString, (error, client, done) ->
    if error
      console.log('--> Postgre connection error: ', error)
      queryFinished.reject()
      done()
    else
      client.query sqlQuery, params, (error, results) ->
        if error
          console.log('--> Postgre query error: ', error)
          queryFinished.reject()
        else
          queryFinished.resolve(results.rows)
        done()

  return queryFinished.promise

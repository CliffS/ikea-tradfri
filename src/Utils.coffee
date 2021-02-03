
sleep = (time = 1) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, time * 1000

exports.Sleep = sleep

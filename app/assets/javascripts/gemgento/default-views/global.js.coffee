window.App ||= {}

# Define global methods here
App.intersect = (array_a, array_b) ->
  result = []
  for a in array_a
    for b in array_b
      if a == b && result.indexOf(a) == -1
        result.push(a)

  return result
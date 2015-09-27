Observable = require('zen-observable')
{stream, prop, send, Kefir} = require('../test-helpers.coffee')
throwError = (x) -> throw new Error('error')

describe '[Symbol.observable]', ->
  it 'outputs a compatible Observable', (done) ->
    a = stream()
    values = []
    observable = Observable.from(a)
    observable.subscribe
      next: (x) ->
        values.push(x)
      complete: (x) ->
        expect(values).toEqual([1, 2, 3])
        done()
    send(a, [1, 2, 3, '<end>'])

  it 'unsubscribes stream after an error', ->
    a = stream()
    values = []
    observable = a[Symbol.observable]()
    observable.subscribe(next: (x) -> values.push(x))

    send(a, [1, {error: 2}, 3])
    expect(values).toEqual([1])

  it 'unsubscribes after an exception is thrown in event handler', ->
    a = stream()
    observable = a[Symbol.observable]()
    observable.subscribe(next: throwError)
    expect(-> send(a, [1])).toThrow()
    expect(-> send(a, [1])).not.toThrow()

  it 'unsubscribes on error', ->
    a = stream()
    observable = a[Symbol.observable]()
    observable.subscribe(error: (->), next: throwError)
    send(a, [{error: 'error'}])
    expect(-> send(a, [1])).not.toThrow()

  it 'unsubscribes on error if handler throws an exception', ->
    a = stream()
    observable = a[Symbol.observable]()
    observable.subscribe(error: throwError, next: throwError)
    expect(-> send(a, [{error: 'error'}])).toThrow()
    expect(-> send(a, [1])).not.toThrow()

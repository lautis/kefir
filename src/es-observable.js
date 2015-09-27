const {extend} = require('./utils/objects');

function ESObservable(observable) {
  this._observable = observable;
}

extend(ESObservable.prototype, {
  _dispatch(observer, fn, event) {
    if (event.type === "value" && observer.next) {
      try {
        observer.next(event.value);
      } catch(ex) {
        this._unsubscribe(fn);
        throw ex;
      }
    } else if (event.type == "error") {
      try {
        if (observer.error) {
          observer.error(event.value);
        }
      } finally {
        this._unsubscribe(fn);
      }
    } else if (event.type === "end" && observer.complete) {
      observer.complete(event.value);
    }
  },

  _unsubscribe(fn) {
    this._observable.offAny(fn);
  },

  subscribe(observer) {
    const fn = (event) => this._dispatch(observer, fn, event);
    this._observable.onAny(fn);
    return () => this._observable.offAny(fn);
  }
});


module.exports = ESObservable;

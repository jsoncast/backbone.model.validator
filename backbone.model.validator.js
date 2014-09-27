//
// Copyright (c) 2014 Masayuki Nagamachi <masayuki.nagamachi@gmail.com>
// Distributed under MIT license
//

(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(['underscore'], factory);
  } else if (typeof exports === 'object') {
    module.exports = factory(require('underscore'), require('backbone'));
  } else {
    factory(root._, root.Backbone);
  }
}(this, function (_, Backbone) {
  'use strict';

  function Validator(validation) {
    if (_.isEmpty(validation)) {
      throw new Error('validation must be an empty object');
    }
    return function (attributes, options) {
      var errors = {};
      for (var attr in validation) {
        var validators = validation[attr];
        for (var i = 0; i < validators.length; i++) {
          var validator = validators[i];
          var err = validator(attributes[attr], attr, this);
          if (err) {
            errors[attr] = err;
            break;
          }
        }
        if (_.has(errors, attr)) {
          this.trigger('invalid:' + attr, this, err);
        } else {
          this.trigger('valid:' + attr, this);
        }
      }
      if (_.isEmpty(errors)) {
        return;
      }
      return errors;
    };
  }

  Validator.valid = function(options) {
    return function(val, attr) {};
  };

  Validator.invalid = function(options) {
    options = _.defaults({}, options, {
      error: 'invalid'
    });
    return function(val, attr) { return options.error; };
  };

  Validator.required = function(options) {
    options = _.defaults({}, options, {
      error: 'required'
    });
    return function(val, attr) {
      if (_.isUndefined(val) || _.isNull(val) || _.isNaN(val)) {
        return options.error;
      }
      if (_.isObject(val) && _.isEmpty(val)) {
        return options.error;
      }
      if (_.isString(val) && _.isEmpty(val)) {
        return options.error;
      }
      return;
    };
  };

  Validator.json = function (options) {
    options = _.defaults({}, options, {
      error: 'invalid json'
    });
    return function (val, attr) {
      if (!_.isString(val)) {
        return options.error;
      }
      try {
        JSON.parse(val);
        return;
      } catch (err) {
        return options.error;
      }
    };
  };

  Backbone.Model.Validator = Validator;
  return Validator;
}));

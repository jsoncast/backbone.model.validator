#
# Copyright (c) 2014 Masayuki Nagamachi <masayuki.nagamachi@gmail.com>
# Distributed under MIT license
#

Backbone = require 'backbone'
validator = require './backbone.model.validator'

should = require 'should'
sinon = require 'sinon'

describe 'Backbone.Model', ->

  class Model extends Backbone.Model
    validate: validator
      a: [validator.required()]

  it 'should have Validator', ->
    Backbone.Model.should.have.ownProperty 'Validator', validator

  describe 'isValid', ->

    it 'should return true when a model is valid', ->
      model = new Model a: 1
      model.isValid().should.be.true

    it 'should return false when a model is invalid', ->
      model = new Model
      model.isValid().should.be.false

  describe 'validationError', ->

    it 'should return undefined when a model is valid', ->
      model = new Model a: 1
      model.isValid()
      should(model.validationError).be.null

    it 'should return an object when a model is invalid', ->
      model = new Model
      model.isValid()
      model.validationError.should.be.an.Object
      model.validationError.should.have.ownProperty 'a', 'required'

  describe 'Validator', ->

    spy = null
    beforeEach -> spy = trigger: sinon.spy()
    afterEach -> spy = null

    it 'should be a Function', ->
      validator.should.be.an.instanceOf Function

    it 'should return a Function', ->
      validator({a:[]}).should.be.an.instanceOf Function

    it 'should throw an Error when no arguments are passed', ->
      (-> validator()).should.throw 'validation must be an empty object'

    it 'should throw an Error when null is passed', ->
      (-> validator null).should.throw 'validation must be an empty object'

    it 'should throw an Error when an empty object is passed', ->
      (-> validator {}).should.throw 'validation must be an empty object'

    it 'should return undefined when attributes are valid', ->
      v = validator
        a: [validator.valid()]
        b: [validator.valid(), validator.valid()]
      should(v.call spy, {}).be.undefined

    it 'should fire valid:<attr> events when attributes are valid', ->
      v = validator
        a: [validator.valid()]
        b: [validator.valid(), validator.valid()]
      v.call spy, {}
      spy.trigger.calledTwice.should.be.true
      spy.trigger.alwaysCalledOn(spy).should.be.true
      spy.trigger.calledWith('valid:a', spy).should.be.true
      spy.trigger.calledWith('valid:b', spy).should.be.true

    it 'should return an object when attributes are invalid', ->
      v = validator
        a: [validator.invalid()]
        b: [validator.valid(), validator.invalid()]
      result = v.call(spy, {})
      result.should.be.an.Object
      result.should.have.ownProperty 'a', 'invalid'
      result.should.have.ownProperty 'b', 'invalid'

    it 'should fire invalid:<attr> events when attributes are invalid', ->
      v = validator
        a: [validator.invalid()]
        b: [validator.valid(), validator.invalid()]
      v.call spy, {}
      spy.trigger.calledTwice.should.be.true
      spy.trigger.alwaysCalledOn(spy).should.be.true
      spy.trigger.calledWith('invalid:a', spy, 'invalid').should.be.true
      spy.trigger.calledWith('invalid:b', spy, 'invalid').should.be.true

    it 'should stop validation when a validator return a string', ->
      valid = sinon.spy validator.valid()
      invalid = sinon.spy validator.invalid()
      v = validator a: [invalid, valid]
      v.call spy, {}
      valid.called.should.be.false
      invalid.calledOnce.should.be.true
      invalid.returned('invalid').should.be.true

    describe 'valid', ->

      it 'should be a Function', ->
        validator.valid.should.be.an.instanceOf Function

      it 'should return a Function', ->
        validator.valid().should.be.an.instanceOf Function

      it 'should always return undefined', ->
        v = validator.valid()
        should(v 1, 'a').be.undefined

    describe 'invalid', ->

      it 'should be a Function', ->
        validator.invalid.should.be.an.instanceOf Function

      it 'should return a Function', ->
        validator.invalid().should.be.an.instanceOf Function

      it 'should always return a string', ->
        v = validator.invalid()
        should(v 1, 'a').be.a.String.equal 'invalid'

      it 'should always return a options.error', ->
        v = validator.invalid error: 'error'
        should(v 1, 'a').be.a.String.equal 'error'

    describe 'required', ->

      test = (v, e) ->
        v(undefined, 'a').should.be.a.String.equal e
        v(null, 'a').should.be.a.String.equal e
        v(NaN, 'a').should.be.a.String.equal e
        v('', 'a').should.be.a.String.equal e
        v({}, 'a').should.be.a.String.equal e
        v([], 'a').should.be.a.String.equal e

      it 'should be a Function', ->
        validator.required.should.be.an.instanceOf Function

      it 'should return a Function', ->
        validator.required().should.be.an.instanceOf Function

      it 'should return undefined when a value is valid', ->
        v = validator.required()
        should(v 1, 'a').be.undefined

      it 'should return a string when a value is invalid', ->
        v = validator.required()
        test v, 'required'

      it 'should return a options.error when a value is invalid', ->
        v = validator.required error: 'error'
        test v, 'error'

    describe 'json', ->

      test = (v, e) ->
        v(1, 'a').should.be.a.String.equal e
        v([1], 'a').should.be.a.String.equal e
        v({a:1}, 'a').should.be.a.String.equal e
        v('', 'a').should.be.a.String.equal e
        v('a', 'a').should.be.a.String.equal e
        v('{a:1}', 'a').should.be.a.String.equal e

      it 'should be a Function', ->
        validator.json.should.be.an.instanceOf Function

      it 'should return a Function', ->
        validator.json().should.be.an.instanceOf Function

      it 'should return undefined when a value is valid', ->
        v = validator.json()
        should(v '1', 'a').be.undefined

      it 'should return a string when a value is invalid', ->
        v = validator.json()
        test v, 'invalid json'

      it 'should return a options.error when a value is invalid', ->
        v = validator.json error: 'error'
        test v, 'error'

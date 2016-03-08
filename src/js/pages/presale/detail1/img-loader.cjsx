React = require 'react'
Status =
    PENDING: 'pending'
    LOADING: 'loading'
    LOADED: 'loaded'
    FAILED: 'failed'
T = React.PropTypes
View = React.createClass
    propTypes:
        src: T.string
        onLoad: T.func
        onError: T.func

    getDefaultProps: ->
        src: ''

    getInitialState: ->
        @init @props

    init: (props) ->
        status: if props.src then Status.LOADING else Status.PENDING

    componentDidMount: ->
        if @state.status is Status.LOADING
            @createLoader()

    componentWillReceiveProps: (nextProps)->
        if @props.src isnt nextProps.src
            @setState @init nextProps

    componentDidUpdate: (prevProps, prevState) ->
        if @state.status is Status.LOADING and not @img
            @createLoader()

    componentWillUnmount: ->
        @destroyLoader()

    createLoader: () ->
        @destroyLoader();  # We can only have one loader at a time.

        @img = new Image();
        @img.onload = @handleLoad;
        @img.onerror = @handleError;
        @img.src = @props.src;

    destroyLoader: () ->
        if @img
            @img.onload = null;
            @img.onerror = null;
            @img = null;

    handleLoad: (event) ->
        @setState
            status: Status.LOADED
        if @props.onLoad
            @props.onLoad @img, @img.width, @img.height, event
        @destroyLoader()


    handleError: (error) ->
        @destroyLoader()
        @setState
            status: Status.FAILED

        if @props.onError
            @props.onError error

    render: ->
        <div className="img-loader">
            <img src="#{staticPrefix}/images/loading.gif" />
        </div>

module.exports = View

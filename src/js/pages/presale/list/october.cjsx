React = require 'react'
liteFlux = require 'lite-flux'
Header = require './header'
Block1 = require './block-1'
Block2 = require './block-2'
Block3 = require './block-3'
ImgLoader = require './img-loader'
Store = require './_stores/presales-home'
Action = Store.getAction()
storeName = 'presales-home'

View = React.createClass
    mixins: [liteFlux.mixins.storeMixin(storeName)]

    getInitialState: ->
        Action.getList()
        {}

    block1onLoad: () ->
        Action.setBlock1ImgInitStatus yes
    getBlock2Data: () ->
        store = @state[storeName]
        current = store.current
        current.sliders.map (item, i) ->
            item.media.full_path



    render: ->
        store = @state[storeName]
        list = store.list
        current = store.current
        block1ImgInit = store.block1ImgInit
        if list and list.length

            if not block1ImgInit
                <ImgLoader src={current.covers.media.full_path} onLoad={@block1onLoad}></ImgLoader>
            else
                <div>
                    <Header />
                    <Block1 covers={current.covers.media.full_path}/>
                    <Block2 data={@getBlock2Data()} />
                    <Block3 />
                </div>
        else
            <div className="img-loader">
                <img src="#{staticPrefix}/images/loading.gif" />
            </div>


ReactDom.render <View />, $('#presale-container')[0]

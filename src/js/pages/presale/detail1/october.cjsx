React = require 'react'
liteFlux = require 'lite-flux'
window.liteFlux = liteFlux
Header = require './header'
Block1 = require './block-1'
# 2,3 合并为 2.
Block2 = require './block-2'
Block4 = require './block-4'
Block6 = require './block-6'
BlockImg = require './block-7'
ImgLoader = require './img-loader'
Store = require './_stores/presales-home'
Action = Store.getAction()
storeName = 'presales-home'
window.staticPrefix = cdn_prefix
data =
    block1: staticPrefix + '/images/presales/detail/1/01.jpg'
    block2:
        title: '黑色，永不过时的经典'
        desc: ''
        list: [
            {
                title: ''
                desc: ''
                img: staticPrefix + '/images/presales/detail/1/03.png'
            }
            {
                title: '黑色'
                desc: '黑色不仅代表庄重，也代表着神秘、性感和魅惑。黑天鹅餐桌的设计灵感源自一场跨越三个世纪的精湛演绎《天鹅湖》，奔放、充满力量、直抵内心。黑色幕布拉开，成熟、冷静、沉着的少女，看她如何演绎黑色的纯粹和经典……'
                img: staticPrefix + '/images/presales/detail/1/03.png'
                img2: staticPrefix + '/images/presales/detail/1/02.png'
            }
            {
                title: ''
                desc: ''
                img: staticPrefix + '/images/presales/detail/1/03.png'
            }
        ]
    block4: [
        title: '如少女的灵魂一舞，致敬传统工匠精神'
        desc: [
            '优雅地将摩登元素铺排在0.6MM水曲柳木皮中，并用漂亮的开放漆作为外壳，不惧岁月的磨砺。'
            '多边形拐角削切工艺，兼顾生活触碰的柔和度，无处不在的贴心呵护。'
        ]
        background: staticPrefix + '/images/presales/detail/1/04.png'
        position: 'right'
    ,
        title: '流畅曲线造型，兼具力量与柔美的一款餐桌'
        desc: [
            '优雅地将摩登元素铺排在0.6MM水曲柳木皮中，并用漂亮的开放漆作为外壳，不惧岁月的磨砺。'
            '多边形拐角削切工艺，兼顾生活触碰的柔和度，无处不在的贴心呵护。'
        ]
        background: staticPrefix + '/images/presales/detail/1/05.png'
        position: 'left'
    ,
        title: '餐厅日常，也变得趣味盎然'
        desc: [
            '简洁的外观设计搭配无以伦比的美腿，修长中凸显小巧玲珑，特显摩登曲线美。'
            '以写实手法勾勒简约轮廓，典雅素净，令室内生活主题更加浓缩经典。'
        ]
        background: staticPrefix + '/images/presales/detail/1/06.png'
        position: 'right'
    ]
    block5: [
        img: staticPrefix + '/images/presales/detail/1/07.jpg'
    ]
    block6: [
        img: staticPrefix + '/images/presales/detail/1/a.jpg'
        desc: '25MM中纤板台面，实用和耐用的双重考量。 '
    ,
        img: staticPrefix + '/images/presales/detail/1/b.jpg'
        desc: '顶级开放漆面料，可以触摸到的温度肌理。'
    ,
        img: staticPrefix + '/images/presales/detail/1/c.jpg'
        desc: '多边形拐角工艺，45°精密拼角，细微处也讲究。'
    ,
        img: staticPrefix + '/images/presales/detail/1/d.jpg'
        desc: '多面削切桌腿，窈窕，弧度与桌面造型相得益彰。'
    ]
    block7: [
        img: staticPrefix + '/images/presales/detail/1/e.jpg'
        desc: '将复杂凝练于简洁的设计之中，如同将梦想寄予于芭蕾舞，惊艳了时光，温柔了岁月。'
    ]

View = React.createClass
    mixins: [liteFlux.mixins.storeMixin(storeName)]
    getInitialState: ->
        Action.initPresales window.presale, window.server_time
        block1: no

    block1onLoad: () ->
        @setState
            block1: yes

    render: ->
        data = data
        if not @state.block1
            <div>
                <ImgLoader src={data.block1} onLoad={@block1onLoad}></ImgLoader>
                <Header />
            </div>
        else
            <div>
                <Header />
                <Block1 data={data.block1}/>
                <Block2 data={data.block2} />
                <Block4 data={data.block4} />
                <BlockImg data={data.block5} />
                <Block6 data={data.block6} />
                <BlockImg data={data.block7} />
            </div>

ReactDom.render <View />, $('#presale-container')[0]

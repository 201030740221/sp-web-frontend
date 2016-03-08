TabPane = React.createClass
    render: ->
        return (
            <div className="rc-tabs-content">
                {@props.children}
            </div>
        )

Tab = React.createClass
    getInitialState: ->
        activeKey: @props.defaultActiveKey

    getDefaultProp: ->
        onChange: ->

    onNavClick: (key)->
        oldKey = @state.activeKey
        @setState activeKey: key, =>
            @props.onChange(key) if key isnt oldKey

    renderNav: ->
        items = React.Children.map @props.children, (child) =>
            key = child.key
            cls = 'item'
            cls = cls + ' active' if key is @state.activeKey
            return <li className={cls} key={key} onClick={@onNavClick.bind(null, key)}>{child.props.tab}</li>

        <ul className="rc-tabs-nav u-clearfix">
            {items}
        </ul>

    renderContent: ->
        content = []
        React.Children.map @props.children, (child) =>
            content.push child if child.key is @state.activeKey
        content

    render: ->
        return (
            <div className="rc-tabs">
                {@renderNav()}
                {@renderContent()}
            </div>
        )

Tab.TabPane = TabPane;

module.exports = Tab

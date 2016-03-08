# cart
define ['modules/components/loginbox'], (Loginbox)->

    # SP.log "init Modules"

    # 初始化登录组件
    ReactDom.render <Loginbox pageType="page" />, document.getElementById('loginbox-wrap')

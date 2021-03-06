id = $('#category_id').val()
data = JSON.parse $('#articles').val()
View = React.createClass
    getInitialState: ->
        data: data
        loading: no

    loadMore: () ->
        store = @state.data
        list = store.data
        @setState
            loading: yes

        webapi.lesson.articles({
            category_id: id
            page: store.current_page + 1
            page_size: 10
        }).then (res) =>
            if res.code is 0
                data = res.data
                data.data = list.concat data.data
                @setState
                    data: data
                    loading: no


    renderList: () ->
        store = @state.data
        list = store.data
        list.map (item, i) =>
            cover = item.cover
            cover_html = null

            if cover and cover.media and cover.media.full_path
                cover_html = (
                    <a href="/lesson/detail/#{item.id}.html">
                        <img src={cover.media.full_path} alt="" />
                    </a>
                )

            <li className="u-mb_40" key={i}>
                {cover_html}
                <a href="/lesson/detail/#{item.id}.html">
                    <h3 className="u-f30">{item.title}</h3>
                </a>
                <div className="u-f14 u-color_gray">{item.description}</div>
                <a href="/lesson/detail/#{item.id}.html" className="underline-link u-mt_20">阅读更多</a>
            </li>

    renderBtn: () ->
        store = @state.data
        loading = @state.loading
        if loading is yes
            <img src="/static/images/loading.gif" className="u-ma u-block" />
        else
            if data.current_page < data.last_page
                <a className="topic-load-more-btn" href="javascript:;" onClick={@loadMore} >发现更多</a>
            else
                <span className="topic-load-more-btn">没有更多了</span>


    render: ->
        <div>
            <ul>
                {@renderList()}
            </ul>
            <div className="topic-load-more u-f14">
                {@renderBtn()}
            </div>
        </div>

$container = $('.topic-list')
ReactDom.render <View />, $container[0]

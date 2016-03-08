React = require 'react'
SetMessageModal = require './set-message-modal'
ModalBox = require 'modules/react-modal-box/index.cjsx'
View = React.createClass

    showModal: (event)->
        event.preventDefault()
        if SP.isLogined()
            @modal = new ModalBox
                width: 440
                top: 100
                mask: true
                closeBtn: true
                component: <SetMessageModal close={@hideModal} requesterid={@props.requesterid} />

            @modal.show()
        else
            SP.login()

    hideModal: () ->
        @modal.destroy()


    render: ->
        className = SP.classSet "btn btn-larger-big btn-color-black", @props.className
        <a href="javascript:;" className={className} onClick={this.showModal}>开售提醒我！</a>
module.exports = View

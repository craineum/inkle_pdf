@MarkupMapElement = React.createClass
  getInitialState: ->
    { void: false }
  handleElementType: ->
    @setState { void: !@state.void }
  handleRemoveMarkupMap: ->
    React.unmountComponentAtNode @getDOMNode().parentNode
    event.preventDefault()

  render: ->
    element_show = if @state.void then ' hidden' else ' show'
    void_show = if @state.void then ' show' else ' hidden'
    React.DOM.div className: 'markup-map', children: [
      React.DOM.div className: 'col-xs-3'
      React.DOM.div children:
        React.DOM.label className: 'col-xs-2', children: [
          React.DOM.input
            type: 'checkbox'
            name: 'void_elements[]'
            onChange: @handleElementType
          ' Void Element'
        ]
      React.DOM.div className: "markup-map-element #{element_show}", children: [
        React.DOM.div className: 'col-xs-2', children:
          React.DOM.input
            type: 'text'
            name: 'open_tags[]'
            className: 'form-control'
            placeholder: '^--'
        React.DOM.div className: 'col-xs-2', children:
          React.DOM.input
            type: 'text'
            name: 'end_tags[]'
            className: 'form-control'
            placeholder: '--^'
        React.DOM.div className: 'col-xs-2', children:
          React.DOM.input
            type: 'text'
            name: 'html_tags[]'
            className: 'form-control'
            placeholder: 'sup'
      ]
      React.DOM.div className: "markup-map-void-element #{void_show}", children: [
        React.DOM.div className: 'col-xs-2', children:
          React.DOM.input
            type: 'text'
            name: 'void_tags[]'
            className: 'form-control'
            placeholder: '**'
        React.DOM.div className: 'col-xs-2 col-xs-offset-2', children:
          React.DOM.input
            type: 'text'
            name: 'void_html_tags[]'
            className: 'form-control'
            placeholder: 'br'
      ]
      React.DOM.div className: 'col-xs-1', children:
        React.DOM.button
          type: 'button'
          onClick: @handleRemoveMarkupMap
          children: '-'
    ]

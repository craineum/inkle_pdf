@MarkupMapping = React.createClass
  handleAddMarkupMap: ->
    element = React.createElement MarkupMapElement
    container = document.createElement 'div'
    React.render element, container
    document.getElementById('markup_maps').appendChild(container)
    event.preventDefault()

  render: ->
    React.DOM.div children: [
      React.DOM.div className: 'markup-mapping-header', children: [
        React.DOM.div
          className: 'col-xs-2 col-xs-offset-5'
          children: 'Open Tag/Tag'
        React.DOM.div className: 'col-xs-2', children: 'Close Tag'
        React.DOM.div className: 'col-xs-3', children: 'HTML Tag'
      ]
      React.DOM.label
        className: 'col-xs-3 control-label'
        children: 'Markup Mapping'
      React.DOM.div id: 'markup_maps', children: [
        React.DOM.div children: [
          React.createElement MarkupMapElement
          React.DOM.div className: 'col-xs-1', children:
            React.DOM.button
              type: 'button'
              onClick: @handleAddMarkupMap
              children: '+'
        ]
      ]
    ]

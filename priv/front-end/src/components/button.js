import React, {Component} from 'react'

export default class Button extends Component {
  render () {
    const { clickEvent, title } = this.props;

    return(
      <div>
        <button onClick={clickEvent}>
          {title}
        </button>
      </div>
    )
  }
}
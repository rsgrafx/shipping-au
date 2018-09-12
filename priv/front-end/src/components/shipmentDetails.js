import React, {Component} from 'react'

export default class ShipmentDetails extends Component {
  state = {
    packageInfo: {
      influencer_id: this.props.influencer_id
    }
  }
  changeDetails = (details) => {
    this.setState((state) => ({state, ...details}))
  }

  render() {
    return(
      <form>
        <input onChange={this.changeDetails}></input>
      </form>
    )
  }
}
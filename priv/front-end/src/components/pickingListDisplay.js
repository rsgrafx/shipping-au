import React, {Component} from 'react'
import * as SendleAPI from '../sendleApi.js'

import Influencer from './influencer.js'

export default class PickingListDisplay extends Component {
  state = {
    data: {},
    participants: []
  }

  componentWillMount() {
    const {match} = this.props.router
    SendleAPI.get(match.params.campaign_id)
      .then(campaign => this.setState((prevState) => ({...campaign})))
  }

  updateParcelInfo(parcelInfo) {
    this.setState((prevState) => {
     return {participants: prevState.participants.concat(parcelInfo)}
    }, () => console.log(this.state))
  }

  render() {
    const {data} = this.state
    return(
        <div>
          <h3>{data.campaign_name}</h3>
          {
            data.participants !== undefined &&
            data.participants.map(
              (influencer) => (<Influencer
                profile={influencer}
                products={data.products}
                updateParcelInfo={this.updateParcelInfo}/>
              )
            )
          }
          <button className="btn btn-block">Submit Entries</button>
        </div>)
  }
}
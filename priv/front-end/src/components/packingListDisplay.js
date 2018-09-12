import React, {Component} from 'react'
import * as SendleAPI from '../sendleApi.js'

import Influencer from './influencer.js'

export default class PackingListDisplay extends Component {
  state = {
    data: {}
  }

  componentWillMount() {
    const {match} = this.props.router
    SendleAPI.get(match.params.campaign_id)
      .then(campaign => this.setState({...campaign}))
  }

  render() {
    const {data} = this.state
    return(
        <div>
          <h3>{data.campaign_name}</h3>
          {
            data.participants !== undefined &&
            data.participants.map(
              (influencer) => (<Influencer profile={influencer} products={data.products}/>)
            )
          }
        </div>)
  }
}
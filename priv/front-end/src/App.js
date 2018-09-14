import React, { Component } from 'react';
import {Route, Link} from 'react-router-dom'
import './App.css';

import Home from './Home.js';

import PickingListDisplay from './components/pickingListDisplay.js'
import PackingListDisplay from './components/packingListDisplay.js'
import MockCampaign from './mockCampaign'

import * as SendleAPI from './sendleApi.js'

class SendleApiApp extends Component {

  state = {
    pickingLists: [],
    packingLists: [],
    influencers: [],
  }

  componentWillMount() {
    SendleAPI.getAllPickingLists()
      .then((result) => {
        this.setState((prevState) => ({pickingLists: result.data}))
      })

    SendleAPI.getPackingLists()
    .then((result) => {
      this.setState((prevState) => ({
          packingLists: result.data
      }))
    })
  }

  render() {
    return (
      <div className="App">
        <header className="App-header text-left">
          <Link to="/">
            <img src={'https://vamp.me/wp-content/uploads/2018/05/LOGO-Copy@2x_preview.png'} className="pull-left App-logo" alt="logo" />
          </Link>
          <h2>Sendle API integration Example</h2>
        </header>
        <div className="container">
          <Route exact path="/" render={() => <Home lists={this.state} /> } />
          <Route exact path="/mockCampaign" render={() => <MockCampaign lists={this.state} /> } />
          <Route exact path="/pickingList/:campaign_id" render={(router) => <PickingListDisplay
              router={router}
            /> } />
          <Route exact path="/packingList/:campaign_id" render={(router) => <PackingListDisplay
              router={router}
            /> } />
        </div>
      </div>
    );
  }
}

export default SendleApiApp;

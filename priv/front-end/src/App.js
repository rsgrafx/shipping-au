import React, { Component } from 'react';
import {Route, Link} from 'react-router-dom'
import './App.css';

import Home from './Home.js';
import PickingLists from './components/pickingList.js'
import PickingListDisplay from './components/pickingListDisplay.js'

import * as SendleAPI from './sendleApi.js'

class SendleApiApp extends Component {

  state = {
    pickingLists: [],
    influencers: [],
  }

  componentWillMount() {
    SendleAPI.getAllPickingLists()
      .then((result) => {
        this.setState((prevState) => ({pickingLists: result.data}))
      })
  }

  render() {
    return (
      <div className="App">
        <header className="App-header">
          <Link to="/">
            <img src={'https://vamp.me/wp-content/uploads/2018/05/LOGO-Copy@2x_preview.png'} className="App-logo" alt="logo" />
          </Link>
          <h1 className="App-title">Sendle API Service</h1>
        </header>
        <div className="container">
        <Route exact path="/" render={() => <PickingLists lists={this.state.pickingLists} /> } />
        <Route exact path="/pickingList/:campaign_id" render={(router) => <PickingListDisplay
            router={router}
          /> } />
        </div>
      </div>
    );
  }
}

export default SendleApiApp;
